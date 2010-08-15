require 'test_helper'

class ApplicationTest < Test::Unit::TestCase
  context "application class" do
    setup do
      @klass = Radar::Application
      @instance = @klass.create("bar", false)
    end

    context "creating" do
      teardown do
        @klass.clear!
      end

      should "be able to create for a name" do
        instance = @klass.create("foo")
        assert_equal "foo", instance.name
      end

      should "be able to lookup after created" do
        instance = @klass.create("foo")
        assert_equal instance, @klass.find("foo")
      end

      should "allow creation of unregistered applications" do
        instance = @klass.create("foo", false)
        assert_nil @klass.find("foo")
      end

      should "raise an exception if duplicate name is used" do
        assert_raises(Radar::ApplicationAlreadyExists) {
          @klass.create("foo")
          @klass.create("foo")
        }
      end

      should "yield with the instance if a block is given" do
        @klass.create("foo") do |instance|
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
        @instance.config.reporter(@reporter)
        assert !@instance.config.reporters.empty?
      end

      should "be able to configure using a block" do
        @instance.config do |config|
          config.reporter(@reporter)
        end

        assert !@instance.config.reporters.empty?
      end
    end

    context "reporting" do
      setup do
        # The fake reporter class
        reporter = Class.new do
          def report(environment)
            raise "success"
          end
        end

        # Setup the application to use the fake reporter
        @instance.config do |config|
          config.reporter reporter
        end
      end

      should "call report on each registered reporter" do
        assert_raises(RuntimeError) do
          begin
            @instance.report(Exception.new)
          rescue => e
            assert_equal "success", e.message
            raise
          end
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
