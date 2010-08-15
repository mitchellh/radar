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
      should "not include extension key if no data extensions are enabled" do
        assert !@instance.to_hash.has_key?(:extension), "instance should not have key: extension"
      end

      should "include data extensions if defined" do
        extension = Class.new do
          def initialize(event); @event = event; end
          def to_hash; { :foo => :bar }; end
        end

        @application.config.data_extension extension

        result = @instance.to_hash
        assert result.has_key?(:extension), "instance should have key: extension"
        assert_equal :bar, result[:extension][:foo]
      end
    end
  end
end
