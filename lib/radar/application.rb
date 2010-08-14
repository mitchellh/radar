module Radar
  # Represents an instance of Radar for a given application. Every
  # application which uses Radar must instantiate an {Application}.
  class Application
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
