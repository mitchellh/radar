module Radar
  # Represents an internal radar error. This class is made so its easy
  # for users of radar to catch all radar related errors.
  class Error < StandardError; end
  class ApplicationAlreadyExists < Error; end
end
