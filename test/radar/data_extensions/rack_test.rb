require 'test_helper'

class RackDataTest < Test::Unit::TestCase
  context "rack data extension class" do
    setup do
      @klass = Radar::DataExtensions::Rack
      @instance = @klass.new(create_exception_event)
    end

    should "be able to convert to a hash" do
      assert @instance.respond_to?(:to_hash)
    end
  end
end
