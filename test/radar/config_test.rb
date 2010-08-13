require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  context "configuration" do
    setup do
      @klass = Radar::Config
      @instance = @klass.new
    end

    should "initially have no reporters" do
      assert @instance.reporters.empty?
    end

    should "be able to add reporters" do
      @instance.reporter :foo
      assert !@instance.reporters.empty?
      assert @instance.reporters.first.is_a?(Radar::Config::LazyReporter)
    end
  end

  context "lazy reporter" do
    setup do
      @klass = Radar::Config::LazyReporter
    end

    should "not initialize the class on initialization" do
      klass = Class.new
      klass.expects(:new).never

      @klass.new(klass)
    end

    should "load the klass on demand" do
      klass = Class.new
      instance = @klass.new(klass)

      klass.expects(:new).once.returns(7)
      instance.instance
      instance.instance
    end

    should "pass instance into block if given" do
      klass = Class.new

      proc = Proc.new {}
      proc.expects(:call).once
      instance = @klass.new(klass) do |r|
        assert r.is_a?(klass)
        proc.call
      end

      instance.instance
    end
  end
end
