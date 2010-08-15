module Radar
  module DataExtensions
    # Data extension which adds information about the host environment:
    #
    # * Operating system
    # * Ruby version
    #
    class HostEnvironment
      def initialize(event)
        @event = event
      end

      def to_hash
        { :host_environment => {
            :ruby_version      => (RUBY_VERSION rescue '?'),
            :ruby_pl           => (RUBY_PATCHLEVEL rescue '?'),
            :ruby_release_date => (RUBY_RELEASE_DATE rescue '?'),
            :ruby_platform     => (RUBY_PLATFORM rescue '?')
          }
        }
      end
    end
  end
end
