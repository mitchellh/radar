require 'test_helper'

class ReporterTest < Test::Unit::TestCase
  context "reporter class" do
    setup do
      @klass = Radar::Reporter
      @instance = @klass.new
    end

    should "raise an exception for an unimplemented reporter" do
      assert_raises(RuntimeError) { @instance.report(nil) }
    end
  end
end
