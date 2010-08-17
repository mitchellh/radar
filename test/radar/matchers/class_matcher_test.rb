require 'test_helper'

class ClassMatcherTest < Test::Unit::TestCase
  context "class matcher class" do
    setup do
      @klass = Radar::Matchers::ClassMatcher
    end

    should "match if the class match exactly" do
      standard_event = create_exception_event { raise StandardError.new("An error") }
      assert @klass.new(RuntimeError).matches?(create_exception_event)
      assert !@klass.new(RuntimeError).matches?(standard_event)
    end

    should "match regular expressions properly" do
      standard_event = create_exception_event { raise StandardError.new("An error") }
      assert @klass.new(/.*Error/).matches?(create_exception_event)
      assert @klass.new(/.*Error/).matches?(standard_event)
    end

    should "match subclasses if specified" do
      assert @klass.new(Exception, :include_subclasses => true).matches?(create_exception_event)
      assert !@klass.new(Exception).matches?(create_exception_event)
    end
  end
end
