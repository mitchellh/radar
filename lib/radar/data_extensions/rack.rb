module Radar
  module DataExtensions
    # Data extensions which adds information about a rack request,
    # if it exists in the `:rack_request` extra data of the {ExceptionEvent}.
    class Rack
      def initialize(event)
        @event = event
      end

      def to_hash
        request = @event.extra[:rack_request]
        if request
          { :request => {
              :request_method => request.request_method.to_s,
              :url        => request.url.to_s,
              :parameters => request.params,
              :remote_ip  => request.ip
            }
          }
        end
      end
    end
  end
end
