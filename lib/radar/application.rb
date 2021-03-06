require 'thread'
require 'forwardable'

module Radar
  # A shortcut for {Application.find}.
  def [](*args)
    Application.find(*args)
  end
  module_function :[]

  # Represents an instance of Radar for a given application. Every
  # application which uses Radar must instantiate an {Application}.
  class Application
    extend Forwardable

    @@registered = {}                 # Hash of registered applications
    @@mutex = Mutex.new               # Mutex used to lock certain actions on applications.

    attr_reader :parent               # Parent application, if there is one (routes have a parent)
    attr_reader :name                 # The name of the application
    attr_reader :creation_location    # The location where the application was created, in the code
    attr_reader :routes               # An array of all the defined routes on this application
    attr_reader :last_reported        # The exception instance that was reported last (most recently)

    def_delegators :config, :reporters, :data_extensions, :matchers, :filters, :rejecters,
                            :reporter, :data_extension, :match, :filter, :reject

    # Looks up an application which was registered with the given name.
    #
    # @param [String] name Application name.
    # @return [Application]
    def self.find(name)
      @@registered[name]
    end

    # Removes all registered applications. **This is only exposed for testing
    # purposes.**
    def self.clear!
      @@registered.clear
    end

    # Creates a new application with the given name and registers
    # it for lookup later. If a block is given, it will be yielded with
    # the new instantiated {Application} so you can also {#config} it
    # all in one go.
    #
    # @param [String] name Application name. This must be unique for
    #   any given application or an exception will be raised.
    # @param [Boolean] register Registers the application globally
    #   so it can be accessed via {find}. Name must be unique in this case.
    # @return [Application]
    def initialize(name, options=nil)
      options = { :register => true, :parent => nil }.merge(options || {})

      @@mutex.synchronize do
        if options[:register]
          raise ApplicationAlreadyExists.new("'#{name}' already defined at '#{self.class.find(name).creation_location}'") if self.class.find(name)
          @@registered[name] = self
        end
      end

      @name = name
      @creation_location = caller.first
      @parent = options[:parent]
      @routes = []
      yield self if block_given?
    end

    # Configures the application by returning the configuration
    # object. If a block is given, the configuration object will be
    # passed into it, allowing for a cleaner way of configuring your
    # applications.
    #
    #     $app = Radar::Application.new
    #     $app.config do |config|
    #       config.reporters.use Radar::Reporter::FileReporter
    #     end
    #
    # You can also just use it without a block:
    #
    #    $app.config.reporters.use Radar::Reporter::FileReporter
    #
    # @yield [Config] Configuration object, only if block is given.
    # @return [Config]
    def config
      @_config ||= Config.new
      yield @_config if block_given?
      @_config
    end

    # Returns the logger for the application. Each application gets
    # their own logger which is used for lightweight (single line)
    # logging so users can sanity check that Radar is working as
    # expected.
    #
    # @return [Logger]
    def logger
      @_logger ||= Logger.new(self)
    end

    # Reports an exception. This will send the exception on to the
    # various reporters configured for this application. If any
    # matchers are defined, using {Config#match}, then at least one
    # must match for the report to go forward to reporters.
    #
    # @param [Exception] exception
    def report(exception, extra=nil)
      data = ExceptionEvent.new(self, exception, extra)

      # If there are rejecters, then verify that they all fail
      if !config.rejecters.empty?
        config.rejecters.values.each do |r|
          if r.call(data)
            logger.info("Ignoring exception. Matches rejecter: #{r}")
            return
          end
        end
      end

      # If there are matchers, then verify that at least one matches
      # before continuing
      if !config.matchers.empty?
        return if !config.matchers.values.find do |m|
          m.call(data) && logger.info("Reporting exception. Matches: #{m}")
        end
      end

      # Mark this as the last reported exception, before the reporting actually
      # happens
      @last_reported = exception

      # Report the exception to each of the reporters
      logger.info "Invoking reporters for exception: #{exception.class}"
      config.reporters.values.each do |reporter|
        reporter.call(data)
      end

      # Report the exception to each of the routes
      routes.each do |route|
        route.report(exception, extra)
      end
    end

    # Hooks this application into the `at_exit` handler so that
    # application crashing exceptions are properly reported.
    def rescue_at_exit!
      logger.info "Attached to application exit."
      at_exit { report($!) if $! && !last_reported.equal?($!) }
    end

    # Integrate this application with some external system, such as
    # Rack, Rails, Sinatra, etc. For more information on Radar integrations,
    # please read the user guide.
    def integrate(integrator, *args, &block)
      integrator = Support::Inflector.constantize("Radar::Integration::#{Support::Inflector.camelize(integrator)}") if !integrator.is_a?(Class)
      integrator.integrate!(self, *args, &block)
    end

    # Creates a new route within the application. A route is a new, self-contained
    # {Application} instance which can have its own set of matchers, reporters,
    # etc. but {#report} is invoked at the same time as the parent application.
    # An optional name can be given to the route which will assist in viewing log
    # files of the application.
    #
    # @param [String] name Name of the route.
    # @return [Application]
    def route(name=nil, &block)
      block = Proc.new {} if !block_given?
      name ||= "route_#{routes.length}"

      # Create a new application with the given name, making sure to
      # _not_ register it, since this is not a top-level application.
      app = self.class.new(name, { :register => false, :parent => self }, &block)
      routes.push(app)
      app
    end

    # A method used by {ExceptionEvent} to get all the inherited values
    # of the {Config::UseArray} with the given name.
    #
    # @return [Config::UseArray]
    def inherited_use_array(name)
      current = config.send(name)
      return current if !parent
      current.merge(parent.config.send(name))
    end

    # Converts application to a serialization-friendly hash.
    #
    # @return [Hash]
    def to_hash
      { :name => name }
    end
  end
end
