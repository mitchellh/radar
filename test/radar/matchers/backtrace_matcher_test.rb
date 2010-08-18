require 'test_helper'

class BacktraceMatcherTest < Test::Unit::TestCase
  context "backtrace matcher class" do
    setup do
      @klass = Radar::Matchers::BacktraceMatcher
    end

    should "match if the backtrace matches a regexp" do
      standard_event = create_exception_event { raise StandardError.new("An error") }
      assert @klass.new(%r{/matchers/(.+)_test.rb}).matches?(standard_event)
      assert !@klass.new(%r{/not_matchers/(.+)_test.rb}).matches?(standard_event)
    end

    should "match if the backtrace includes a substring" do
      standard_event = create_exception_event { raise StandardError.new("An error") }
      assert @klass.new("backtrace_matcher_test.rb").matches?(standard_event)
      assert !@klass.new("not_real_matcher_test.rb").matches?(standard_event)
    end

    should "match only up to the specified depth" do
      standard_event = create_exception_event { raise StandardError.new("An error") }
      assert @klass.new("test_helper.rb", :depth => 5).matches?(standard_event)
      assert !@klass.new("test_helper.rb", :depth => 1).matches?(standard_event)
    end
  end
end
