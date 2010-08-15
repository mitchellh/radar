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
  end
end
