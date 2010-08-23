require 'test_helper'

class Rails2DataTest < Test::Unit::TestCase
  context "rails 2 data extension class" do
    setup do
      @klass = Radar::DataExtensions::Rails2
      @instance = @klass.new(create_exception_event)
    end

    should "be able to convert to a hash" do
      assert @instance.respond_to?(:to_hash)
    end
  end
end
