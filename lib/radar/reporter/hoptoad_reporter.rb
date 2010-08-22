require 'builder'
require 'net/http'

module Radar
  class Reporter
    # Reports exceptions to the Hoptoad server (http://hoptoadapp.com).
    class HoptoadReporter
      API_VERSION = "2.0"
      NOTICES_URL = "/notifier_api/v2/notices/"

      # Hoptoad service API key
      attr_accessor :api_key

      # HTTP settings
      attr_accessor :host
      attr_accessor :headers
      attr_accessor :secure
      attr_accessor :http_open_timeout
      attr_accessor :http_read_timeout

      # Proxy settings
      attr_accessor :proxy_host
      attr_accessor :proxy_port
      attr_accessor :proxy_user
      attr_accessor :proxy_pass

      # Notifier information. This defaults to Radar information.
      attr_accessor :notifier_name
      attr_accessor :notifier_version
      attr_accessor :notifier_url

      def initialize(opts=nil)
        (opts || {}).each do |k,v|
          send("#{k}=", v)
        end

        @host              ||= 'hoptoadapp.com'
        @headers           ||= { 'Content-type' => 'text/xml', 'Accept' => 'text/xml, application/xml' }
        @secure            ||= false
        @http_open_timeout ||= 2
        @http_read_timeout ||= 5

        @notifier_name     ||= "Radar"
        @notifier_version  ||= Radar::VERSION
        @notifier_url      ||= "http://radargem.com"
      end

      def report(event)
        raise ArgumentError.new("`api_key` is required.") if !api_key

        http = Net::HTTP.Proxy(proxy_host, proxy_port, proxy_user, proxy_pass).new(url.host, url.port)
        http.read_timeout = http_read_timeout
        http.open_timeout = http_open_timeout
        http.use_ssl      = secure

        response = begin
                     http.post(url.path, event_xml(event), headers)
                   rescue TimeoutError => e
                     event.application.logger.error("#{self.class}: POST timeout.")
                     nil
                   end

        if !response.is_a?(Net::HTTPSuccess)
          event.application.logger.error("#{self.class}: Failed to send: #{response.body}")
        end
      end

      # Converts an event to the properly formatted XML for transmission
      # to Hoptoad.
      def event_xml(event)
        builder = Builder::XmlMarkup.new
        builder.instruct!
        xml = builder.notice(:version => API_VERSION) do |notice|
          notice.tag!("api-key", api_key)

          notice.notifier do |notifier|
            notifier.name(notifier_name)
            notifier.version(notifier_version)
            notifier.url(notifier_url)
          end

          notice.error do |error|
            error.tag!("class", event.exception.class.to_s)
            error.message(event.exception.message)
            error.backtrace do |backtrace|
              backtrace.line(:number => 42, :file => "/foo/bar/baz", :method => "bob")
            end
          end

          notice.tag!("server-environment") do |env|
            env.tag!("project-root", "TODO")
            env.tag!("environment-name", "TODO")
          end
        end

        xml.to_s
      end

      # Returns a URI object pointed to the proper endpoint for the
      # Hoptoad API.
      def url
        protocol = secure ? 'https' : 'http'
        port     = secure ? 443 : 80

        URI.parse("#{protocol}://#{host}:#{port}").merge(NOTICES_URL)
      end
    end
  end
end
