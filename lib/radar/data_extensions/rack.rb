require 'radar/data_extensions/request_helper'

module Radar
  module DataExtensions
    # Data extensions which adds information about a rack request,
    # if it exists in the `:rack_request` extra data of the {ExceptionEvent}.
    class Rack
      include RequestHelper

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

        if @event.extra[:rack_env]
          Support::Hash.deep_merge!(result, :request => { :headers => extract_http_headers(@event.extra[:rack_env]) })
          Support::Hash.deep_merge!(result, :request => { :rack_env => extract_rack_env(@event.extra[:rack_env]) })
        end

        result
      end

      protected

      # Extracts the rack environment, ignoring HTTP headers and
      # converting the values to strings if they're not an Array
      # or Hash.
      def extract_rack_env(env)
        env.inject({}) do |acc, data|
          k, v = data

          if !(k =~ /^HTTP_/)
            v = v.to_s if !v.is_a?(Array) && !v.is_a?(Hash) && !v.is_a?(Integer)
            acc[k] = v
          end

          acc
        end
      end
    end
  end
end
