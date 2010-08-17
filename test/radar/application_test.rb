require 'test_helper'

class ApplicationTest < Test::Unit::TestCase
  context "application class" do
    setup do
      @klass = Radar::Application
      @instance = @klass.new("bar", false)
    end

    context "initializing" do
      teardown do
        @klass.clear!
      end

      should "be able to create for a name" do
        instance = @klass.new("foo")
        assert_equal "foo", instance.name
      end

      should "be able to lookup after created" do
        instance = @klass.new("foo")
        assert_equal instance, @klass.find("foo")
      end

      should "allow creation of unregistered applications" do
        instance = @klass.new("foo", false)
        assert_nil @klass.find("foo")
      end

      should "raise an exception if duplicate name is used" do
        assert_raises(Radar::ApplicationAlreadyExists) {
          @klass.new("foo")
          @klass.new("foo")
        }
      end

      should "yield with the instance if a block is given" do
        @klass.new("foo") do |instance|
          assert instance.is_a?(@klass)
        end
      end
    end

    context "configuration" do
      setup do
        @instance.config.reporters.clear

        @reporter = Class.new
      end

      should "be able to configure an application" do
        @instance.config.reporters.use @reporter
        assert !@instance.config.reporters.empty?
      end

      should "be able to configure using a block" do
        @instance.config do |config|
          config.reporters.use @reporter
        end

        assert !@instance.config.reporters.empty?
      end
    end

    context "reporting" do
      should "call report on each registered reporter" do
        reporter = Class.new do
          def report(environment); raise "success"; end
        end

        @instance.config.reporters.use reporter

        assert_raises(RuntimeError) do
          begin
            @instance.report(Exception.new)
          rescue => e
            assert_equal "success", e.message
            raise
          end
        end
      end

      should "add extra data to the event if given" do
        reporter = Class.new do
          def report(event); raise event.extra[:foo]; end
        end

        @instance.config.reporters.use reporter

        begin
          @instance.report(Exception.new, :foo => "BAR")
        rescue => e
          assert_equal "BAR", e.message
        end
      end
    end

    context "to_hash" do
      setup do
        @hash = @instance.to_hash
      end

      should "contain name" do
        assert_equal @instance.name, @hash[:name]
      end
    end

    # Untested: Application#rescue_at_exit! since I'm not aware of an
    # [easy] way of testing it without spawning out a separate process.
  end
end
