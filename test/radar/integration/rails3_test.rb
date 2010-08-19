require 'test_helper'

class Rails3IntegrationTest < Test::Unit::TestCase
  context "rails3 integration class" do
    setup do
      @klass = Radar::Integration::Rails3
      @app = Radar::Application.new(:app, false)
    end

    should "raise an argument error if an application is not specified" do
      assert_raises(ArgumentError) { @klass.integrate!(@app, :rails_app => nil) }
    end

    # TODO: Add rails to gemfile and test it?
  end
end
