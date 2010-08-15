require 'fileutils'

module Radar
  class Reporter
    # Reports exceptions by dumping the JSON data out to a file on the
    # local filesystem. The reporter is configurable:
    #
    # * {#output_directory=}
    #
    class FileReporter
      attr_accessor :output_directory

      def initialize
        @output_directory = lambda { |event| "~/.radar/errors/#{event.application.name}" }
      end

      def report(event)
        output_file = File.join(File.expand_path(output_directory(event)), "#{event.occurred_at.to_i}-#{event.uniqueness_hash}.txt")

        # Attempt to make the directory if it doesn't exist
        FileUtils.mkdir_p File.dirname(output_file)

        # Write out the JSON to the output file
        File.open(output_file, 'w') { |f| f.write(event.to_json) }
      end

      # Returns the currently configured output directory. If `event` is given
      # as a parameter and the currently set directory is a lambda, then the
      # lambda will be evaluated then returned. If no event is given, the lambda
      # is returned as-is.
      def output_directory(event=nil)
        return @output_directory.call(event) if event && @output_directory.is_a?(Proc)
        @output_directory
      end
    end
  end
end
