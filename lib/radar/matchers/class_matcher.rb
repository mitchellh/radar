module Radar
  module Matchers
    # A matcher which matches exceptions with a specific class.
    #
    #     app.config.match :class => StandardError
    #
    class ClassMatcher
      def initialize(klass)
        @klass = klass
      end

      def matches?(event)
        event.exception.class == @klass
      end
    end
  end
end
