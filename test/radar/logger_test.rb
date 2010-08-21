require 'test_helper'

class LoggerTest < Test::Unit::TestCase
  context "logger class" do
    setup do
      @klass = Radar::Logger
    end

    should "return true, temporarily" do
      assert true
    end
  end
end
