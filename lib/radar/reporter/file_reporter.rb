require 'fileutils'

module Radar
  class Reporter
    # Reports exceptions by dumping the JSON data out to a file on the
    # local filesystem. The reporter is configurable:
    #
    # ## Configurable Values
    #
    # ### `output_directory`
    #
    # Specifies the directory where the outputted files are stored. This value
    # can be either a string or a lambda which takes an {ExceptionEvent} as its
    # only parameter. The reporter will automatically attempt to make the configured
    # directory if it doesn't already exist. Examples of both methods of specifying
    # the directory are shown below:
    #
    #     reporter.output_directory = "~/hard/coded/path"
    #
    # Or:
    #
    #     reporter.output_directory = lambda { |event| "~/.radar/errors/#{event.application.name}" }
    #
    # ### `prune_time`
    #
    # Specifies the maximum age (in seconds) that a previously outputted file
    # is allowed to reach before being pruned. When an exception is raised, the
    # FileReporter will automatically prune existing files which are older than
    # the specified amount. By default this is `nil` (no pruning occurs).
    #
    #     # One week:
    #     reporter.prune_time = 60 * 60 * 24 * 7
    #
    class FileReporter
      attr_accessor :output_directory
      attr_accessor :prune_time

      def initialize
        @output_directory = lambda { |event| "~/.radar/errors/#{event.application.name}" }
        @prune_time = nil
      end

      def report(event)
        output_file = File.join(File.expand_path(output_directory(event)), "#{event.occurred_at.to_i}-#{event.uniqueness_hash}.txt")
        directory = File.dirname(output_file)

        # Attempt to make the directory if it doesn't exist
        FileUtils.mkdir_p directory

        # Prune files if enabled
        prune(directory) if prune_time

        # Write out the JSON to the output file
        File.open(output_file, 'w') { |f| f.write(event.to_json) }
      end

      # Prunes the files in the given directory according to the age limit
      # set by the {#prune_time} variable.
      #
      # @param [String] directory Directory to prune
      def prune(directory)
        Dir[File.join(directory, "*.txt")].each do |file|
          next unless File.file?(file)
          next unless (Time.now.to_i - File.ctime(file).to_i) >= prune_time.to_i
          File.delete(file)
        end
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
