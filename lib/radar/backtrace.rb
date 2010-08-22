module Radar
  # The backtrace class helps to parse the given Ruby backtrace
  # lines into proper file, line, and method, so it can better be
  # organized and filtered later.
  class Backtrace < Array
    attr_reader :original

    def initialize(backtrace)
      @original = backtrace
      parse if backtrace
    end

    protected

    # Parses the backtrace into the proper {Line} objects which
    # are inserted into the array.
    def parse
      original.each do |line|
        push(Entry.new(line))
      end
    end

    # Represents a single line of a backtrace, giving access to the
    # file, line, and method.
    class Entry < Hash
      def initialize(line)
        # Regex pulled from HoptoadNotifier. Thanks!
        _, file, line, method = line.match(/^([^:]+):(\d+)(?::in `([^']+)')?$/).to_a
        self[:file] = file
        self[:line] = line
        self[:method] = method
      end

      # Helpers to access the file, line, and method.
      [:file, :line, :method].each do |attr|
        define_method(attr) do
          self[attr]
        end
      end
    end
  end
end
