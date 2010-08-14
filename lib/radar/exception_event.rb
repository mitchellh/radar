module Radar
  # Represents the event of an exception being captured. This class
  # contains references to the {Application} and exception which is
  # raised.
  class ExceptionEvent
    attr_reader :application
    attr_reader :exception

    def initialize(application, exception)
      @application = application
      @exception = exception
    end

    def to_hash
      { :application => application.to_hash,
        :exception => {
          :klass => exception.class.to_s,
          :message => exception.message,
          :backtrace => exception.backtrace
        }
      }
    end
  end
end
