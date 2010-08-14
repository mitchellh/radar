module Radar
  # Represents an instance of Radar for a given application. Every
  # application which uses Radar must instantiate an {Application}.
  class Application
    @@registered = {}

    attr_reader :name
    attr_reader :creation_location

    # Creates a new application with the given name and registers
    # it for lookup later. If a block is given, it will be yielded with
    # the new instantiated {Application} so you can also {#config} it
    # all in one go.
    #
    # @param [String] name Application name. This must be unique for
    #   any given application or an exception will be raised.
    # @return [Application]
    def self.create(name, register=true)
      result = new(name, caller.first)
      yield result if block_given?
      @@registered[name] = result if register
      result
    end

    # Looks up an application which was registered with {create} with
    # the given name.
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

    # Initialize a new application instance with the given name. This
    # method **should not be called** directly. Instead, please use the
    # {create} method.
    #
    # @param [String] name Application name. This must be unique for
    #   any given application.
    def initialize(name, creation_location)
      raise "Radar::Application '#{name}' already defined at '#{self.class.find(name).creation_location}'" if self.class.find(name)
      @name = name
      @creation_location = creation_location
    end

    # Configures the application by returning the configuration
    # object. If a block is given, the configuration object will be
    # passed into it, allowing for a cleaner way of configuring your
    # applications.
    #
    #     $app = Radar::Application.new
    #     $app.config do |config|
    #       config.storage_directory = "foo"
    #     end
    #
    # @yield [Config] Configuration object, only if block is given.
    # @return [Config]
    def config
      @_config ||= Config.new
      yield @_config if block_given?
      @_config
    end

    # Reports an exception. This will send the exception on to the
    # various reporters configured for this application.
    #
    # @param [Exception] exception
    def report(exception)
      data = ExceptionEvent.new(self, exception)

      # Report the exception to each of the reporters
      config.reporters.each do |reporter|
        reporter.instance.report(data)
      end
    end

    # Hooks this application into the `at_exit` handler so that
    # application crashing exceptions are properly reported.
    def rescue_at_exit!
      at_exit { report($!) if $! }
    end

    # Converts application to a serialization-friendly hash.
    def to_hash
      # TODO
      {}
    end
  end
end
