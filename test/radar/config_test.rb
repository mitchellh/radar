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
  end
end
