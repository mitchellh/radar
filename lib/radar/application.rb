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

    @@registered = {}
    @@mutex = Mutex.new

    attr_reader :name
    attr_reader :creation_location

    def_delegators :config, :reporters, :data_extensions, :matchers, :filters,
                            :reporter, :data_extension, :match, :filter

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
    # @return [Application]
    def initialize(name, register=true)
      @@mutex.synchronize do
        raise ApplicationAlreadyExists.new("'#{name}' already defined at '#{self.class.find(name).creation_location}'") if self.class.find(name)

        @name = name
        @creation_location = caller.first
        yield self if block_given?
        @@registered[name] = self if register
      end
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

      # If there are matchers, then verify that at least one matches
      # before continuing
      if !config.matchers.empty?
        return if !config.matchers.values.find do |m|
          m.call(data) && logger.info("Reporting exception. Matches: #{m}")
        end
      end

      # Report the exception to each of the reporters
      logger.info "Invoking reporters for exception: #{exception.class}"
      config.reporters.values.each do |reporter|
        reporter.call(data)
      end
    end

    # Hooks this application into the `at_exit` handler so that
    # application crashing exceptions are properly reported.
    def rescue_at_exit!
      logger.info "Attached to application exit."
      at_exit { report($!) if $! }
    end

    # Integrate this application with some external system, such as
    # Rack, Rails, Sinatra, etc. For more information on Radar integrations,
    # please read the user guide.
    def integrate(integrator, *args, &block)
      integrator = Support::Inflector.constantize("Radar::Integration::#{Support::Inflector.camelize(integrator)}") if !integrator.is_a?(Class)
      integrator.integrate!(self, *args, &block)
    end

    # Converts application to a serialization-friendly hash.
    #
    # @return [Hash]
    def to_hash
      { :name => name }
    end
  end
end
