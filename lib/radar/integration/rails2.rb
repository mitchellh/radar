require 'radar/integration/rails2/action_controller_rescue'

module Radar
  module Integration
    # Allows drop-in integration with Rails 3 for Radar. This
    # basically enables a middleware in your Rails 3 application
    # which catches any exceptions and adds some additional
    # information to the exception (such as the rack environment,
    # request URL, etc.)
    class Rails2
      @@integrated_apps = []

      def self.integrate!(app)
        # Only monkeypatch ActionController::Base once
        ActionController::Base.send(:include, ActionControllerRescue) if @@integrated_apps.empty?

        # Only integrate each application once
        @@integrated_apps << app if !@@integrated_apps.include?(app)
      end

      # Returns all the Radar applications which have been integrated with
      # Rails 2, in the order that they were integrated. This Array is `dup`ed
      # so that no modifications can be made to it.
      def self.integrated_apps
        @@integrated_apps.dup
      end
    end
  end
end
