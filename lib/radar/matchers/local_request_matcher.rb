module Radar
  module Matchers
    # A matcher which matches exceptions if the request is from
    # a local IP. The IPs which constitute a "local request" are
    # those which match any of the following:
    #
    #     [/^127\.0\.0\.\d{1,3}$/, "::1", /^0:0:0:0:0:0:0:1(%.*)?$/]
    #
    # If there is no request information found in the exception event
    # data, then it will not match.
    #
    # This matcher expects the IP to be accessible at `event.to_hash[:request][:remote_ip]`,
    # though this is configurable. Examples of usage are shown below:
    #
    #     app.match :local_request
    #
    # With a custom IP field:
    #
    #     app.match :local_request, :remote_ip_getter => lamdba { |event| event.to_hash[:remote_ip] }
    #
    class LocalRequestMatcher
      attr_accessor :localhost
      attr_accessor :remote_ip_getter

      def initialize(opts=nil)
        (opts || {}).each do |k,v|
          send("#{k}=", v)
        end

        @localhost        ||= [/^127\.0\.0\.\d{1,3}$/, "::1", /^0:0:0:0:0:0:0:1(%.*)?$/]
        @remote_ip_getter ||= Proc.new { |event| event.to_hash[:request][:remote_ip] }
      end

      def matches?(event)
        remote_ip = remote_ip_getter.call(event)
        localhost.any? { |local_ip| local_ip === remote_ip }
      rescue Exception
        # Any exceptions assume that we didn't match.
        false
      end
    end
  end
end
