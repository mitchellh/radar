module Radar
  class Reporter
    # A reporter which simply dumps the event JSON out to some IO
    # object. If you're outputting to a file, you should look into
    # {FileReporter} instead, which will automatically create unique
    # filenames per exception.
    #
    # Some uses for this reporter:
    #
    #   - Output to `stderr`, since a process's `stderr` may be redirected
    #     to a log file already.
    #   - Output to `stdout`, just for testing.
    #   - Output to some network IO stream to talk to a server across
    #     a network.
    #
    class IoReporter
      attr_accessor :io_object

      def initialize(opts=nil)
        opts ||= {}
        @io_object = opts[:io_object]
      end

      def report(event)
        return if !io_object
        raise ArgumentError.new("IoReporter `io_object` must be an IO object.") if !io_object.is_a?(IO)

        # Straight push the object to the object and flush immediately
        io_object.puts(event.to_json)
        io_object.flush
      end
    end
  end
end
