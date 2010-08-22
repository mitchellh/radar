module Radar
  module Integration
    # Allows drop-in integration with Rails 3 for Radar. This
    # basically enables a middleware in your Rails 3 application
    # which catches any exceptions and adds some additional
    # information to the exception (such as the rack environment,
    # request URL, etc.)
    class Rails3
      def self.integrate!(app)
        raise ArgumentError.new("Rails integration requires a Rails application to be defined.") if !Rails.application

        # For now just use the Rack::Radar
        Rails.application.config.middleware.use "Rack::Radar", :application => app
      end
    end
  end
end
