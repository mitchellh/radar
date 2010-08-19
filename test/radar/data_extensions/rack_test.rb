require 'test_helper'

class RackDataTest < Test::Unit::TestCase
  context "rack data extension class" do
    setup do
      @klass = Radar::DataExtensions::Rack
      @event = create_exception_event
      @instance = @klass.new(@event)
    end

    should "be able to convert to a hash" do
      assert @instance.respond_to?(:to_hash)
      assert @instance.to_hash.is_a?(Hash)
    end

    should "merge in only HTTP headers" do
      @event.extra[:rack_env] = {
        "HTTP_CONTENT_TYPE" => "text/html",
        "other"    => "baz"
      }

      result = @instance.to_hash
      assert result[:request][:headers].has_key?("Content-Type")
      assert !result[:request][:headers].has_key?("other")
    end

    context "merging in rack environment properly" do
      setup do
        @event.extra[:rack_env] = {
          "HTTP_CONTENT_TYPE" => "text/html",
          "other"             => 7,
          "else"              => Class.new.new
        }

        @result = @instance.to_hash[:request][:rack_env]
      end

      should "not merge in the HTTP headers" do
        assert !@result.has_key?("HTTP_CONTENT_TYPE")
      end

      should "merge in the numeric value as-is" do
        assert_equal 7, @result["other"]
      end

      should "merge in the foreign class as a string" do
        assert_equal @event.extra[:rack_env]["else"].to_s, @result["else"]
      end
    end
  end
end
