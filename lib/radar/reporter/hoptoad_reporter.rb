require 'builder'
require 'net/http'

module Radar
  class Reporter
    # Thanks to the Hoptoad Notifier library for the format of the XML and
    # also the `net/http` code. Writing this reporter would have been much
    # more trying if Thoughtbot's code wasn't open.

    # Reports exceptions to the Hoptoad server (http://hoptoadapp.com). Enabling
    # this in your Radar application is easy:
    #
    #     app.reporters.use :hoptoad, :api_key => "hoptoad-api-key"
    #
    # The API key is your project's API key which can be found on the Hoptoad
    # website. There are many additional options which can be set, but the most
    # useful are probably `project_root` and `environment_name`. These will be
    # auto-detected in a Rails application but for all others, its helpful
    # to set them:
    #
    #     app.reporters.use :hoptoad do |r|
    #       r.api_key          = "api-key"
    #       r.project_root     = File.expand_path("../../", __FILE__)
    #       r.environment_name = "development"
    #     end
    #
    class HoptoadReporter
      API_VERSION = "2.0"
      NOTICES_URL = "/notifier_api/v2/notices/"

      # Options which should be set:
      attr_accessor :api_key
      attr_accessor :project_root
      attr_accessor :environment_name

      # The rest can probably be left alone:
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

        @project_root      ||= '/not/set'
        @environment_name  ||= 'radar'

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
              event.backtrace.each do |entry|
                backtrace.line(:number => entry.line, :file => entry.file, :method => entry.method)
              end
            end
          end

          notice.tag!("server-environment") do |env|
            env.tag!("project-root", project_root)
            env.tag!("environment-name", environment_name)
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
