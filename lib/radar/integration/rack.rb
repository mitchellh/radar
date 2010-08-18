module Radar
  module Integration
    # Allows drop-in integration with Rack for Radar. This class
    # should not ever actually be used with {Application#integrate}.
    # Instead, use the middleware provided by {Rack::Radar}, passing
    # in your application like so:
    #
    #     use Rack::Radar, :application => radar_app
    #
    class Rack
      def self.integrate!(app)
        raise "To enable Rack integration, please do: `use Rack::Radar, :application => app` instead."
      end
    end
  end
end

module Rack
  # A rack middleware which allows Radar to catch any exceptions
  # thrown down a Rack app and report it to the given Radar application.
  #
  #     use Rack::Radar, :application => radar_app
  #
  class Radar
    def initialize(app, opts=nil)
      @app = app
      @opts = { :application => nil }.merge(opts || {})
      raise ArgumentError.new("Must provide a radar application in `:application`") if !@opts[:application] || !@opts[:application].is_a?(::Radar::Application)

      # Enable the rack data extension
      @opts[:application].config.data_extensions.use :rack
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      @opts[:application].report(e, :rack_request => Rack::Request.new(env))
      raise
    end
  end
end
