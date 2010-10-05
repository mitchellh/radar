module Radar
  module Matchers
    # A matcher which matches any or all other matchers. This matcher
    # is meant as a way to match on multiple conditions as an AND expression,
    # since normally apps are OR (if any matchers match, it is reported).
    # The following is an example of the usage of the multi-matcher:
    #
    #     app.match :multi do |m|
    #       m.match :backtrace, "my_file"
    #       m.match :class, StandardError
    #     end
    #
    # The above will match only if the backtrace contains "my_file" _and_
    # the class of the exception is a `StandardError`.
    class MultiMatcher
      def initialize
        raise ArgumentError, "A block must be given for a multimatcher." if !block_given?

        # Create a new configuration object (to store our matchers!) and yield
        # it so it can be setup by the user.
        @config = Config.new
        yield @config
      end

      def matches?(event)
        [:matchers, :rejecters].each do |type|
          result = @config.send(type).values.all? do |matcher|
            # Call the matcher against our event, and flip the value if we're
            # looking at a rejecter.
            value = matcher.call(event)
            value = !value if type == :rejecters
            value
          end

          # Short circuit if we already know we're going to fail
          return false if !result
        end

        # If we reach this point, it must be true, since we short circuit
        # failures above.
        true
      end
    end
  end
end
