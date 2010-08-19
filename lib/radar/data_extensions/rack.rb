module Radar
  module DataExtensions
    # Data extensions which adds information about a rack request,
    # if it exists in the `:rack_request` extra data of the {ExceptionEvent}.
    class Rack
      def initialize(event)
        @event = event
      end

      def to_hash
        result = {}

        request = @event.extra[:rack_request]
        if request
          Support::Hash.deep_merge!(result, { :request => {
              :request_method => request.request_method.to_s,
              :url        => request.url.to_s,
              :parameters => request.params,
              :remote_ip  => request.ip
            }
          })
        end

        Support::Hash.deep_merge!(result, :request => { :headers => extract_http_headers(@event.extra[:rack_env]) }) if @event.extra[:rack_env]
        result
      end

      protected

      def extract_http_headers(env)
        env.inject({}) do |acc, data|
          k, v = data

          if k =~ /^HTTP_(.+)$/
            # Convert things like HTTP_CONTENT_TYPE to Content-Type (standard
            # HTTP header style)
            k = $1.to_s.split("_").map { |c| c.capitalize }.join("-")
            acc[k] = v
          end

          acc
        end
      end
    end
  end
end
