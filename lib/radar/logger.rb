require 'logger'
require 'fileutils'

module Radar
  # A lightweight logger which logs what Radar does to a single
  # configurable location. This logger is simply meant as a way
  # you can verify that Radar is working as intended, and not meant
  # as a logger of every exception's data; this is the job of {Reporter}s.
  class Logger < ::Logger
    attr_reader :application

    def initialize(application)
      @application = application
      super(log_location)
    end

    def format_message(severity, timestamp, progname, message)
      "[#{application.name}][#{severity[0,1].upcase}][#{timestamp}] -- #{message}\n"
    end

    # Returns the location of the logfile. This is configurable using
    # {Config#log_location=}.
    #
    # @returns [String]
    def log_location
      location = @application.config.log_location
      location = location.is_a?(Proc) ? location.call(application) : location

      if location.is_a?(String)
        directory = File.dirname(location)
        FileUtils.mkdir_p(directory) if !File.directory?(directory)
      end

      location
    end
  end
end
