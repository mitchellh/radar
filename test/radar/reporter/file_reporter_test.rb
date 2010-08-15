require 'test_helper'

class FileReporterTest < Test::Unit::TestCase
  context "file reporter class" do
    setup do
      @klass = Radar::Reporter::FileReporter
      @instance = @klass.new
    end

    should "allow output directory to be a lambda" do
      @instance.output_directory = lambda { |event| event.application.name }
      event = create_exception_event
      assert_equal event.application.name, @instance.output_directory(event)
    end

    should "allow output directory to be a string" do
      value = "value"
      @instance.output_directory = value
      assert_equal value, @instance.output_directory
    end

    should "just return the lambda if no event is given to read" do
      @instance.output_directory = lambda {}
      assert @instance.output_directory.is_a?(Proc)
    end
  end
end
