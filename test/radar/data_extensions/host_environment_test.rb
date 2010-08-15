require 'test_helper'

class HostEnvironmentDataTest < Test::Unit::TestCase
  context "host environment class" do
    setup do
      @klass = Radar::DataExtensions::HostEnvironment
      @instance = @klass.new(create_exception_event)
    end

    should "be able to convert to a hash" do
      result = @instance.to_hash
      assert result.is_a?(Hash)
    end
  end
end
