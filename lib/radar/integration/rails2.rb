require 'radar/integration/rails2/action_controller_rescue'

module Radar
  module Integration
    # Allows drop-in integration with Rails 2 for Radar. This monkeypatches
    # `ActionController::Base` to capture errors and also enables a data
    # extension to extract the Rails 2 request information into the exception
    # event.
    class Rails2
      @@integrated_apps = []

      def self.integrate!(app)
        # Only monkeypatch ActionController::Base once
        ActionController::Base.send(:include, ActionControllerRescue) if @@integrated_apps.empty?

        # Only integrate each application once
        if !@@integrated_apps.include?(app)
          app.data_extensions.use :rails2
          @@integrated_apps << app
        end
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
