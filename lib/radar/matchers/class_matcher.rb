module Radar
  module Matchers
    # A matcher which matches exceptions with a specific class.
    #
    #     app.config.match :class, StandardError
    #     app.config.match :class, StandardError, :include_subclasses => true
    #     app.config.match :class, /.*Error/
    #
    class ClassMatcher
      def initialize(klass, opts=nil)
        @klass = klass
        @opts = { :include_subclasses => false }.merge(opts || {})
      end

      def matches?(event)
        return event.exception.class.to_s =~ @klass if @klass.is_a?(Regexp)
        return event.exception.class == @klass if !@opts[:include_subclasses]

        # Check for subclass matches
        current = event.exception.class
        while current
          return true if current == @klass
          current = current.superclass
        end

        false
      end
    end
  end
end
