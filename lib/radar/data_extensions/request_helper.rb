module Radar
  module DataExtensions
    # A mixin which contains helper methods for dealing with request
    # objects.
    module RequestHelper
      # Extracts only the HTTP headers from the rack environment,
      # converting them to the proper HTTP format: `HTTP_CONTENT_TYPE`
      # to `Content-Type`
      #
      # @param [Hash] env
      # @return [Hash]
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
