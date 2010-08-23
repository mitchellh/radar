require 'test_helper'

class SinatraIntegrationTest < Test::Unit::TestCase
  context "sinatra integration class" do
    setup do
      @klass = Radar::Integration::Sinatra
    end

    should "not allow integration via the actual integration" do
      assert_raises(RuntimeError) { @klass.integrate!(nil) }
    end
  end
end
