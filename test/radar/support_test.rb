require 'test_helper'

class SupportTest < Test::Unit::TestCase
  context "Support class" do
    setup do
      @klass = Radar::Support
    end

    context "hash" do
      should "deep merge simple hashes" do
        result = @klass::Hash.deep_merge({ :a => 1 }, { :b => 2 })
        assert_equal 1, result[:a]
        assert_equal 2, result[:b]
      end

      should "support deep merging" do
        a = { :a => { :a => 1 } }
        b = { :a => { :b => 2 } }

        result = @klass::Hash.deep_merge(a, b)
        assert_equal 1, result[:a][:a]
        assert_equal 2, result[:a][:b]
      end
    end

    context "inflector" do
      setup do
        @klass = @klass::Inflector
      end

      should "camelize a string" do
        assert_equal "ActiveRecord", @klass.camelize("active_record")
        assert_equal "ActiveRecord::Errors", @klass.camelize("active_record/errors")
      end

      should "constantize a string" do
        assert_equal Radar::Application, @klass.constantize("Radar::Application")
        assert_equal Radar::Reporter::FileReporter, @klass.constantize("Radar::Reporter::FileReporter")
      end
    end
  end
end
