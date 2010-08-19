module Radar
  module Integration
    # Allows drop-in integration with Rails 3 for Radar. This
    # basically enables a middleware in your Rails 3 application
    # which catches any exceptions and adds some additional
    # information to the exception (such as the rack environment,
    # request URL, etc.)
    class Rails3
      def self.integrate!(app, opts=nil)
        opts ||= {}
        raise ArgumentError.new("Must specify a `:rails_app` to point to your Rails 3 application.") if !opts[:rails_app]

        # For now just use the Rack::Radar
        opts[:rails_app].config.middleware.use "Rack::Radar", :application => app
      end
    end
  end
end
