require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  context "configuration" do
    setup do
      @klass = Radar::Config
      @instance = @klass.new
    end

    context "reporters" do
      setup do
        @reporter_klass = Class.new do
          def report(event); end
        end
      end

      teardown do
        @instance.reporters.clear
      end

      should "initially have no reporters" do
        assert @instance.reporters.empty?
      end

      should "be able to add reporters" do
        @instance.reporters.use @reporter_klass
        assert !@instance.reporters.empty?
      end

      should "be able to add reporters using the shortcut singular method" do
        @instance.reporter @reporter_klass
        assert !@instance.reporters.empty?
      end

      should "be able to add reporters via built-in symbols" do
        @instance.reporters.use :file
        assert !@instance.reporters.empty?
      end

      should "yield the reporter instance if a block is given" do
        @reporter_klass.any_instance.expects(:some_method).once
        @instance.reporters.use @reporter_klass do |reporter|
          reporter.some_method
        end
      end
    end

    context "data extensions" do
      setup do
        @extension = Class.new do
          def initialize(event)
          end
        end
      end

      teardown do
        @instance.data_extensions.clear
      end

      should "initially have some data extensions" do
        assert_equal [Radar::DataExtensions::HostEnvironment], @instance.data_extensions.values
      end

      should "be able to add data extensions" do
        @instance.data_extensions.use @extension
        assert !@instance.data_extensions.empty?
      end

      should "be able to add data extensions via the shortcut singular method" do
        @instance.data_extension @extension
        assert !@instance.data_extensions.empty?
      end

      should "be able to add built-in extensions via symbols" do
        @instance.data_extensions.use :rack
        assert_equal Radar::DataExtensions::Rack, @instance.data_extensions.values.last
      end
    end

    context "matchers" do
      setup do
        @matcher = Class.new do
          def matches?(event); false; end
        end
      end

      teardown do
        @instance.matchers.clear
      end

      should "initially have no matchers" do
        assert @instance.matchers.empty?
      end

      should "be able to add matchers" do
        @instance.match @matcher
        assert !@instance.matchers.empty?
      end

      should "be able to use built-in matchers as symbols" do
        @instance.match :class, Object
        assert @instance.matchers.values.first
      end

      should "key the matchers by name if given" do
        @instance.match :class, Object
        assert @instance.matchers.index(:class)
      end
    end

    context "rejecters" do
      setup do
        @rejecter = Class.new do
          def matches?(event); end
        end
      end

      teardown do
        @instance.rejecters.clear
      end

      should "initially have no rejecters" do
        assert @instance.rejecters.empty?
      end

      should "be able to add rejecters" do
        @instance.reject @rejecter
        assert !@instance.rejecters.empty?
      end
    end

    context "filters" do
      teardown do
        @instance.filters.clear
      end

      should "not have any filters by default" do
        assert @instance.filters.empty?
      end

      should "raise an ArgumentError if no class or lambda is given" do
        assert_raises(ArgumentError) { @instance.filters.use }
      end

      should "be able to use just a block" do
        assert_nothing_raised {
          @instance.filters.use do |foo|
          end
        }
        assert_equal 1, @instance.filters.length
      end

      should "be able to add filters using the shortcut singular method" do
        @instance.filter {}
        assert_equal 1, @instance.filters.length
      end
    end
  end

  context "UseArray class" do
    setup do
      @klass = Radar::Config::UseArray
      @instance = @klass.new
    end

    should "allow inserting objects via use" do
      assert @instance.empty?
      @instance.use(:foo)
      assert !@instance.empty?
    end

    should "store the length" do
      assert_equal 0, @instance.length
      @instance.use(:foo)
      @instance.use(:bar)
      assert_equal 2, @instance.length
    end

    should "allow inserting objects at specific indexes" do
      @instance.use(:foo)
      @instance.insert(0, :bar)
      assert_equal [:bar, :foo], @instance.values
    end

    should "allow inserting objects at specified key" do
      @instance.use(:foo)
      @instance.insert_before(:foo, :bar)
      assert_equal [:bar, :foo], @instance.values
    end

    should "allow inserting objects after specified key" do
      @instance.use(:foo)
      @instance.insert_after(:foo, :bar)
      assert_equal [:foo, :bar], @instance.values
    end

    should "raise an exception if inserting after a nonexistent key" do
      assert_raises(ArgumentError) {
        @instance.insert_after(:foo, :bar)
      }
    end

    should "allow swapping objects" do
      @instance.use(:foo)
      @instance.swap(:foo, :bar)
      assert_equal :bar, @instance.values.first
    end

    should "allow deleting objects" do
      @instance.use(:foo)
      @instance.delete(:foo)
      assert @instance.empty?
    end

    should "allow querying for the values in the array" do
      @instance.use(:foo)
      @instance.use(:bar)
      assert_equal [:foo, :bar], @instance.values
    end

    should "return the index of the given items" do
      @instance.use(:foo)
      @instance.use(:bar)

      assert_equal 0, @instance.index(:foo)
      assert_equal 1, @instance.index(:bar)
    end

    should "return the numeric index untouched if given" do
      assert_equal 12, @instance.index(12)
    end

    should "be able to merge multiple use arrays with the merge method" do
      other = @klass.new

      @instance.use(:foo)
      other.use(:bar)

      merged = @instance.merge(other)
      assert_equal [:foo, :bar], merged.values
    end
  end
end
