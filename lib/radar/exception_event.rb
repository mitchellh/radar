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
      result = { :application => application.to_hash,
        :exception => {
          :klass => exception.class.to_s,
          :message => exception.message,
          :backtrace => exception.backtrace
        }
      }

      if !application.config.data_extensions.empty?
        # If data extensions are configured, then append those to
        # the event hash.
        result[:extension] = {}

        application.config.data_extensions.each do |extension|
          result[:extension].merge!(extension.new(self).to_hash)
        end
      end

      result
    end
  end
end
