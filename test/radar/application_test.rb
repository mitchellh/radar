require 'test_helper'

class ApplicationTest < Test::Unit::TestCase
  context "application class" do
    setup do
      @klass = Radar::Application
      @instance = @klass.new
    end

    context "configuration" do
      setup do
        @instance.config.reporters.clear
      end

      should "be able to configure an application" do
        @instance.config.reporter(nil)
        assert !@instance.config.reporters.empty?
      end

      should "be able to configure using a block" do
        @instance.config do |config|
          config.reporter(nil)
        end

        assert !@instance.config.reporters.empty?
      end
    end

    context "reporting" do

    end

    # Untested: Application#rescue_at_exit! since I'm not aware of an
    # [easy] way of testing it without spawning out a separate process.
  end
end
