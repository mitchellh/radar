require 'builder'
require 'net/http'
require 'net/https'

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
        request_data = request_info(event)

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

          if !request_data.empty?
            notice.request do |request|
              request.url(request_data[:url])
              request.component(request_data[:controller])
              request.action(request_data[:action])

              if !request_data[:parameters].empty?
                request.params do |params|
                  xml_vars_for_hash(params, request_data[:parameters])
                end
              end

=begin
              # TODO: Session
              # TODO: This is not working:
              if !request_data[:cgi_data].empty?
                request.tag!("cgi-data") do |cgi|
                  xml_vars_for_hash(cgi, request_data[:cgi_data])
                end
              end
=end
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

      # Returns information about the request based on the event, such
      # as URL, controller, action, parameters, etc.
      def request_info(event)
        return @_request_info if @_request_info

        # Use the hash of the event so that if any filters deleted data, it is properly
        # removed.
        hash = event.to_hash.dup
        hash[:request] ||= {}
        hash[:request][:rack_env] ||= {}

        @_request_info = {}

        if hash[:request]
          @_request_info[:url]        = hash[:request][:url]
          @_request_info[:parameters] = hash[:request][:rack_env]['action_dispatch.request.parameters'] ||
            hash[:request][:parameters] ||
            {}
          @_request_info[:controller] = @_request_info[:parameters]['controller']
          @_request_info[:action]     = @_request_info[:parameters]['action']
          @_request_info[:cgi_data]   = hash[:request][:rack_env] || {}
          # TODO: Session
        end

        @_request_info
      end

      # Turns a hash into the proper XML vars
      def xml_vars_for_hash(builder, hash)
        hash.each do |k,v|
          if v.is_a?(Hash)
            builder.var(:key => k.to_s) { |b| xml_vars_for_hash(b, v) }
          else
            builder.var(v.to_s, :key => k.to_s)
          end
        end
      end
    end
  end
end
