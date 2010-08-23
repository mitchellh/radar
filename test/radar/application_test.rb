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

        @reporter = Class.new do
          def report(event); end
        end
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

    context "logger" do
      should "provide a logger which is initialized on access" do
        Radar::Logger.expects(:new).with(@instance).once.returns("foo")
        @instance.logger
        @instance.logger
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

      context "with a matcher" do
        setup do
          @matcher = Class.new do
            def matches?(event); event.extra[:foo] == :bar; end
          end

          @reporter = Class.new do
            def report(event); raise "Reported"; end
          end

          @instance.config.reporters.use @reporter
          @instance.config.match @matcher
        end

        should "not report if a matcher is specified and doesn't match" do
          assert_nothing_raised { @instance.report(Exception.new, :foo => :wrong) }
        end

        should "report if a matcher matches" do
          assert_raises(RuntimeError) { @instance.report(Exception.new, :foo => :bar) }
        end
      end

      context "with a rejecter" do
        setup do
          @rejecter = Class.new do
            def matches?(event); event.extra[:foo] == :bar; end
          end

          @instance.reject @rejecter
          @instance.reporter { |event| raise "Reported" }
        end

        should "not report if a rejecter is specified and matches" do
          assert_nothing_raised { @instance.report(Exception.new, :foo => :bar) }
        end

        should "report if the rejecter doesn't match" do
          assert_raises(RuntimeError) { @instance.report(Exception.new) }
        end
      end
    end

    context "integrations" do
      should "integrate with built-in integrators" do
        Radar::Integration::Rack.expects(:integrate!).with(@instance)
        @instance.integrate(:rack)
      end

      should "integrate with specified classes" do
        Radar::Integration::Rack.expects(:integrate!).with(@instance)
        @instance.integrate(Radar::Integration::Rack)
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

    context "delegation to config" do
      # Test delegating of accessors
      [:reporters, :data_extensions, :matchers, :filters, :rejecters].each do |attr|
        should "delegate #{attr}" do
          assert_equal @instance.config.send(attr), @instance.send(attr)
        end
      end

      # Test delegating of methods.
      [:reporter, :data_extension, :match, :filter, :reject].each do |method|
        should "delegate `#{method}` method" do
          @instance.config.expects(method).once
          @instance.send(method)
        end
      end
    end

    # Untested: Application#rescue_at_exit! since I'm not aware of an
    # [easy] way of testing it without spawning out a separate process.
  end
end
