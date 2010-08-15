require 'test_helper'

class ExceptionEventTest < Test::Unit::TestCase
  context "ExceptionEvent class" do
    setup do
      @klass = Radar::ExceptionEvent

      @application = Radar::Application.create(:foo, false)
      @exception = StandardError.new("Something bad happened!")
      @instance = @klass.new(@application, @exception)
    end

    context "to_hash" do
      should "include data extensions if defined" do
        extension = Class.new do
          def initialize(event); @event = event; end
          def to_hash; { :foo => :bar }; end
        end

        @application.config.data_extension extension

        result = @instance.to_hash
        assert result.has_key?(:foo), "instance should have key: foo"
        assert_equal :bar, result[:foo]
      end
    end

    context "to_json" do
      should "just jsonify hash output" do
        assert_equal @instance.to_hash.to_json, @instance.to_json
      end
    end
  end
end
