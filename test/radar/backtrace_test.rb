require 'test_helper'

class BacktraceTest < Test::Unit::TestCase
  context "backtrace class" do
    setup do
      @klass = Radar::Backtrace
      @instance = @klass.new(["test.rb:14:in `bar'", "test.rb:10:in `foo'", "test.rb:18:in `<main>'"])
    end

    should "be an array" do
      assert @instance.is_a?(Array)
    end

    should "properly parse a backtrace" do
      assert_equal 3, @instance.length
      assert @instance.all? { |x| x.is_a?(Radar::Backtrace::Entry) }
    end

    # This happens if an exception is created, not raised.
    should "be empty if backtrace is nil" do
      instance = @klass.new(Exception.new("test").backtrace)
      assert instance.empty?
    end
  end

  context "backtrace entry class" do
    setup do
      @klass = Radar::Backtrace::Entry
      @instance = @klass.new("test.rb:14:in `bar'")
    end

    should "properly parse out the file, line, and method" do
      assert_equal "test.rb", @instance.file
      assert_equal "14", @instance.line
      assert_equal "bar", @instance.method
    end

    should "turn into json nicely" do
      assert @instance.to_json
    end
  end
end
