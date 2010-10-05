module Radar
  module Matchers
    # A matcher which matches exceptions which contain a certain
    # file in their backtrace.
    #
    #     app.match :backtrace, "my_file"
    #     app.match :backtrace, %r{lib/my_application}
    #     app.match :backtrace, %r{lib/my_application}, :depth => 5
    #
    # By default this will search the entire backtrace, unless a depth
    # is specified.
    class BacktraceMatcher
      def initialize(file, opts=nil)
        @file = file
        @opts = { :depth => nil }.merge(opts || {})
      end

      def matches?(event)
        return false if !event.exception.backtrace

        event.exception.backtrace.each_with_index do |line, depth|
          return true if @file.is_a?(Regexp) && line =~ @file
          return true if @file.is_a?(String) && line.include?(@file)
          return false if @opts[:depth] && @opts[:depth].to_i <= (depth + 1)
        end

        false
      end
    end
  end
end
