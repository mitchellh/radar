module Radar
  # This class defines the interface for a {Reporter}. A reporter
  # is a class which takes exception information and "reports" it
  # in some way. Examples of reporters (note that not all of these
  # may be implemented; they are ideas):
  #
  # - FileReporter - Logs the exception out to a timestamped
  #   file in a specified directory.
  # - ServerReporter - Logs the exception to a server somewhere for
  #   later retrieval.
  # - GrowlReporter - Causes a Growl notification to occur, noting
  #   that an exception occurred.
  #
  # From the examples above it is clear to see that the reporter doesn't
  # necessarilly need to store the exception information anywhere, it
  # is simply required to take some action in the event that an exception
  # occurred.
  #
  # Radar allows for multiple reporters to be used together, so a reporter
  # doesn't need to do everything. They're meant to be small units of
  # functionality.
  #
  class Reporter
    # Report the environment.
    def report(environment)
      raise "Implement the `report` method in #{self.class}"
    end
  end
end
