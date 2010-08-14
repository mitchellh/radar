require 'test_helper'

class ApplicationTest < Test::Unit::TestCase
  context "application class" do
    setup do
      @klass = Radar::Application
      @instance = @klass.new
    end

    context "configuration" do
      setup do
        @instance.config.reporters.clear
      end

      should "be able to configure an application" do
        @instance.config.reporter(nil)
        assert !@instance.config.reporters.empty?
      end

      should "be able to configure using a block" do
        @instance.config do |config|
          config.reporter(nil)
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

    # Untested: Application#rescue_at_exit! since I'm not aware of an
    # [easy] way of testing it without spawning out a separate process.
  end
end
