module Radar
  module Integration
    # Allows drop-in integration with Sinatra for Radar. This class
    # should not ever actually be used {Application#integrate}. Instead,
    # use the middlware provided by {Rack::Radar}.
    #
    #     Radar::Application.new(:app) do |app|
    #       # configure...
    #     end
    #
    #     class MyApp < Sinatra::Base
    #       use Rack::Radar, :application => Radar[:app]
    #     end
    #
    class Sinatra
      def self.integrate!(app)
        raise "To enable Sinatra integration, please use `Rack::Radar` middleware instead. View the user guide for more information."
      end
    end
  end
end
