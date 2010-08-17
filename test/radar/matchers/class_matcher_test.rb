require 'test_helper'

class ClassMatcherTest < Test::Unit::TestCase
  context "class matcher class" do
    setup do
      @klass = Radar::Matchers::ClassMatcher
    end

    should "match if the class matches" do
      assert @klass.new(RuntimeError).matches?(create_exception_event)
    end

    should "not match non-matching classes" do
      event = create_exception_event do
        raise StandardError.new("An error")
      end

      assert !@klass.new(RuntimeError).matches?(event)
    end
  end
end
