require 'test_helper'

class LoggerReporterTest < Test::Unit::TestCase
  context "logger reporter class" do
    setup do
      @klass = Radar::Reporter::LoggerReporter
    end

    should "raise an argument error if no logger is given" do
      assert_raises(ArgumentError) { @klass.new.report(create_exception_event) }
    end

    should "raise an argument error if the logger doesn't respond to the log level" do
      assert_raises(ArgumentError) { @klass.new(:log_object => Logger.new(nil), :log_level => :bananas).report(create_exception_event) }
    end
  end
end
