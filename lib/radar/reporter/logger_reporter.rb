module Radar
  class Reporter
    # A reporter which logs to a Ruby `Logger`-like object (any object
    # which responds to the various log levels). This reporter is useful
    # if you wish to integrate Radar into your already existing logging
    # systems.
    #
    #     app.config.reporters.use :logger, :log_object => Logger.new(STDOUT)
    #     app.config.reporters.use :logger, :log_object => Logger.new(STDOUT), :log_level => :warn
    #
    class LoggerReporter
      attr_accessor :log_object
      attr_accessor :log_level

      def initialize(opts=nil)
        (opts || {}).each do |k,v|
          send("#{k}=", v)
        end
      end

      def report(event)
        raise ArgumentError.new("#{self.class} `log_object` must be set to a valid logger.") if !log_object.is_a?(Logger)
        raise ArgumentError.new("#{self.class} `log_object` must respond to specified `log_level`.") if !log_object.respond_to?(log_level)

        log_object.send(log_level, event.to_json)
      end
    end
  end
end
