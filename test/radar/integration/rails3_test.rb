require 'test_helper'
require 'rails'

class Rails3IntegrationTest < Test::Unit::TestCase
  context "rails3 integration class" do
    setup do
      @klass = Radar::Integration::Rails3
      @app = Radar::Application.new(:app, :register => false)
    end

    teardown do
      # HACK I don't think rails was ever intended to work this way,
      # but I'm able to clear out the application using this.
      Rails.application = nil
    end

    should "raise an argument error if an application is not specified" do
      assert_raises(ArgumentError) { @klass.integrate!(@app) }
    end

    should "integrate with a rails application" do
      # NOTE This test used to actually initialize the rails application
      # but it was creating a `log/` directory in the toplevel which was
      # pretty annoying. So this suffices for now.
      rails_app = Class.new(Rails::Application)
      assert_nothing_raised { @klass.integrate!(@app) }
    end
  end
end
