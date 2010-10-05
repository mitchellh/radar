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

    should "include a backtrace from the exception" do
      assert @instance.backtrace
      assert_equal @instance.exception.backtrace, @instance.backtrace.original
    end

    should "not have extra data by default" do
      assert @instance.extra.empty?
    end

    should "allow for extra data to be present" do
      @instance = create_exception_event(:foo => :bar)
      assert_equal :bar, @instance.extra[:foo]
    end

    context "checking matcher" do
      should "return true if matches" do
        result = @instance.match? do |event|
          event.exception.message == @instance.exception.message
        end

        assert result
      end

      should "return false if matching fails" do
        result = @instance.match? do |event|
          event.exception.message == "Don't match me"
        end

        assert !result
      end
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

        should "deep merge properly even if to_hash returns nil" do
          @extension.any_instance.stubs(:to_hash).returns(nil)
          assert_nothing_raised { @instance.to_hash }
        end

        should "cache the generated hash" do
          assert @instance.to_hash.equal?(@instance.to_hash)
        end
      end

      context "filters" do
        should "have an application key by default" do
          assert @instance.to_hash.has_key?(:application)
        end

        should "not filter out the application key with filter" do
          @instance.application.config.filters.use do |data|
            data.delete(:application)
            data
          end

          assert !@instance.to_hash.has_key?(:application)
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
