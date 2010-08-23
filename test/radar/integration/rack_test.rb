require 'test_helper'

class RackIntegrationTest < Test::Unit::TestCase
  context "rack integration class" do
    setup do
      @klass = Radar::Integration::Rack
    end

    should "not allow integration via the actual integration" do
      assert_raises(RuntimeError) {
        @klass.integrate!(nil)
      }
    end
  end

  context "rack middleware" do
    setup do
      require 'rack'
      @klass = Rack::Radar
      @rack_app = mock("rack_app")
      @application = Radar::Application.new(:app, false)
    end

    should "raise an exception if no application is specified" do
      assert_raises(ArgumentError) {
        @klass.new(@rack_app)
      }
    end

    should "raise an exception if invalid application is specified" do
      assert_raises(ArgumentError) {
        @klass.new(@rack_app, :application => 7)
      }
    end

    should "enable the rack data extension" do
      @klass.new(@rack_app, :application => @application)
      assert @application.config.data_extensions.values.include?(Radar::DataExtensions::Rack)
    end

    should "call the next middleware properly" do
      @rack_app.expects(:call).returns(:result)
      assert_equal :result, @klass.new(@rack_app, :application => @application).call({})
    end

    should "report and reraise any exceptions raised" do
      @rack_app.expects(:call).raises(RuntimeError)
      @application.expects(:report).with() do |exception, extra|
        assert exception.is_a?(RuntimeError)
        assert extra[:rack_request]
        assert extra[:rack_env]
        assert_equal({:foo => :bar}, extra[:rack_env])
        true
      end

      assert_raises(RuntimeError) {
        @klass.new(@rack_app, :application => @application).call(:foo => :bar)
      }
    end
  end
end
