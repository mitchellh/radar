module Radar
  module Integration
    class Rails2
      module ActionControllerRescue
        def self.included(base)
          # Unfortunate alias method chain... solution: upgrade to rails 3 ;)
          base.send(:alias_method, :rescue_action_without_radar, :rescue_action)
          base.send(:alias_method, :rescue_action, :rescue_action_with_radar)
          base.send(:protected, :rescue_action)
        end

        private

        def rescue_action_with_radar(exception)
          report_exception_to_radar(exception)
          rescue_action_without_radar(exception)
        end

        # Report an exception to all Radar applications which chose to integrate
        # with Rails 2.
        def report_exception_to_radar(exception)
          Radar::Integration::Rails2.integrated_apps.each do |app|
            app.report(exception, :rails2_request => request)
          end
        end
      end
    end
  end
end

