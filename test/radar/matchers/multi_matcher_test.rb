require 'test_helper'

class MultiMatcherTest < Test::Unit::TestCase
  context "multi matcher class" do
    setup do
      @klass = Radar::Matchers::MultiMatcher
    end

    should "match if all the matchers return true" do
      instance = @klass.new do |m|
        m.match { |event| true }
        m.match { |event| true }
        m.match { |event| true }
      end

      assert instance.matches?(create_exception_event)
    end

    should "fail if not all matchers return true" do
      instance = @klass.new do |m|
        m.match { |event| true }
        m.match { |event| false }
        m.match { |event| true }
      end

      assert !instance.matches?(create_exception_event)
    end

    should "match if all rejecters succeed" do
      instance = @klass.new do |m|
        m.reject { |event| false }
        m.reject { |event| false }
        m.reject { |event| false }
      end

      assert instance.matches?(create_exception_event)
    end

    should "not match if any rejecters do not pass" do
      instance = @klass.new do |m|
        m.reject { |event| false }
        m.reject { |event| true }
        m.reject { |event| false }
      end

      assert !instance.matches?(create_exception_event)
    end

    should "work with mixing and matching" do
      instance = @klass.new do |m|
        m.match { |event| true }
        m.reject { |event| false }
      end

      assert instance.matches?(create_exception_event)
    end
  end
end
