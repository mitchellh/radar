module Radar
  module Integration
    class Rack
      def integrate!(app)
        raise "To enable Rack integration, please do: `use Rack::Radar, :application => app` instead."
      end
    end
  end
end

module Rack
  # TODO: Not done yet
  class Radar
    def initialize(app, opts=nil)
      @app = app
    end

    def call(env)
      @app.call(env)
    end
  end
end
