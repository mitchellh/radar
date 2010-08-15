require 'json'

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

    # A hash of information about this exception event. This includes
    # {Application#to_hash} as well as information about the exception.
    # This also includes any {Config#data_extension data_extensions} if
    # specified.
    #
    # @return [Hash]
    def to_hash
      result = { :application => application.to_hash,
        :exception => {
          :klass => exception.class.to_s,
          :message => exception.message,
          :backtrace => exception.backtrace
        }
      }

      if !application.config.data_extensions.empty?
        application.config.data_extensions.each do |extension|
          Support::Hash.deep_merge!(result, extension.new(self).to_hash)
        end
      end

      result
    end

    # JSONified {#to_hash} output.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end
  end
end
