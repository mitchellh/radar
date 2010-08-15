require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  context "configuration" do
    setup do
      @klass = Radar::Config
      @instance = @klass.new

      @reporter_klass = Class.new
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
end
