require 'test_helper'

class ReporterTest < Test::Unit::TestCase
  context "reporter class" do
    setup do
      @klass = Radar::Reporter

      @app = Radar::Application.new
      @instance = @klass.new(@app)
    end

    should "make the app available" do
      assert_equal @app, @instance.app
    end

    should "raise an exception for an unimplemented reporter" do
      assert_raises(RuntimeError) { @instance.report(nil) }
    end
  end
end
