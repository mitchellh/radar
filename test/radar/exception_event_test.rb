require 'test_helper'

class ExceptionEventTest < Test::Unit::TestCase
  context "ExceptionEvent class" do
    setup do
      @klass = Radar::ExceptionEvent
      @instance = create_exception_event
    end

    should "generate a uniqueness hash" do
      assert @instance.uniqueness_hash, "should have generated a uniqueness hash"
    end

    should "have a timestamp of when the exception occurred" do
      assert @instance.occurred_at
      assert @instance.occurred_at.is_a?(Time)
    end

    should "not have extra data by default" do
      assert @instance.extra.empty?
    end

    should "allow for extra data to be present" do
      @instance = create_exception_event(:foo => :bar)
      assert_equal :bar, @instance.extra[:foo]
    end

    context "to_hash" do
      context "data extensions" do
        setup do
          @extension = Class.new do
            def initialize(event); @event = event; end
            def to_hash; { :exception => { :foo => :bar } }; end
          end

          @instance.application.config.data_extensions.use @extension
          @result = @instance.to_hash
        end

        should "include data extensions if defined" do
          assert @result[:exception].has_key?(:foo), "instance should have key: foo"
          assert_equal :bar, @result[:exception][:foo]
        end

        should "deep merge information" do
          assert @result[:exception].has_key?(:klass)
        end
      end
    end

    context "to_json" do
      should "just jsonify hash output" do
        assert_equal @instance.to_hash.to_json, @instance.to_json
      end
    end
  end
end
