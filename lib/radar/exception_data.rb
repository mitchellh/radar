module Radar
  # This class takes an exception and exposes various information
  # about it, as well as provides a reasonable {#to_json} method
  # for serialization.
  class ExceptionData
    attr_reader :exception

    def initialize(exception)
      @exception = exception
    end

    # Converts the exception data to a programmer friendly hash which
    # can then be serialized however it needs to be.
    def to_hash
      { :occured_at => Time.now,
        :klass => @exception.class.to_s,
        :backtrace => @exception.backtrace,
        :message => @exception.message }
    end
  end
end
