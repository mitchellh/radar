require 'test_helper'

class IoReporterTest < Test::Unit::TestCase
  context "io reporter class" do
    setup do
      @klass = Radar::Reporter::IoReporter
    end

    should "be fine if no io_object is given" do
      assert_nothing_raised {
        @klass.new.report(create_exception_event)
      }
    end

    should "raise an ArgumentError if a non-IO object is given" do
      @instance = @klass.new :io_object => 7
      assert_raises(ArgumentError) { @instance.report(create_exception_event) }
    end
  end
end
