require 'test_helper'

class ExceptionDataTest < Test::Unit::TestCase
  context "exception data class" do
    setup do
      @klass = Radar::ExceptionData

      begin
        raise "I am an error"
      rescue => e
        @exception = e
        @instance = @klass.new(@exception)
      end
    end

    should "allow access to the exception" do
      assert_equal @exception, @instance.exception
    end

    should "convert to a hash" do
      result = @instance.to_hash
      assert result.is_a?(Hash)
      assert_equal "RuntimeError", result[:klass].to_s
    end
  end
end
