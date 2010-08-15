require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  context "configuration" do
    setup do
      @klass = Radar::Config
      @instance = @klass.new
    end

    context "reporters" do
      setup do
        @reporter_klass = Class.new
      end

      teardown do
        @instance.reporters.clear
      end

      should "initially have no reporters" do
        assert @instance.reporters.empty?
      end

      should "be able to add reporters" do
        @instance.reporter @reporter_klass
        assert !@instance.reporters.empty?
        assert @instance.reporters.first.is_a?(@reporter_klass)
      end

      should "yield the reporter instance if a block is given" do
        @reporter_klass.any_instance.expects(:some_method).once
        @instance.reporter @reporter_klass do |reporter|
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
        assert_equal [Radar::DataExtensions::HostEnvironment], @instance.data_extensions
      end

      should "be able to add data extensions" do
        @instance.data_extension @extension
        assert !@instance.data_extensions.empty?
      end
    end
  end
end
