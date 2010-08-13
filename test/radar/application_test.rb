require 'test_helper'

class ApplicationTest < Test::Unit::TestCase
  context "application class" do
    setup do
      @klass = Radar::Application
      @instance = @klass.new
    end

    context "configuration" do
      should "be able to configure an application" do
        @instance.config.storage_directory = "foo"
        assert_equal "foo", @instance.config.storage_directory
      end

      should "be able to configure using a block" do
        @instance.config do |config|
          config.storage_directory = "foo"
        end

        assert_equal "foo", @instance.config.storage_directory
      end
    end
  end
end
