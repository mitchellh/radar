require 'radar/data_extensions/request_helper'

module Radar
  module DataExtensions
    # Takes a `:rails2_request` from the {ExceptionEvent} extra data which is
    # added by the rails 2 integrator and extracts it into the data hash.
    #
    # **This data extension is automatically enabled by the Rails 2 integrator.**
    class Rails2
      include RequestHelper

      def initialize(event)
        @event = event
      end

      def to_hash
        request = @event.extra[:rails2_request]
        return if !request

        { :request => {
            :request_method => request.request_method.to_s,
            :url => request.url.to_s,
            :parameters => request.parameters,
            :remote_ip => request.remote_ip,
            :headers => extract_http_headers(request.env)
          }
        }
      end
    end
  end
end
