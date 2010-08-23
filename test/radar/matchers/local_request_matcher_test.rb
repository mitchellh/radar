require 'test_helper'

class LocalRequestMatcherTest < Test::Unit::TestCase
  context "class matcher class" do
    setup do
      @klass = Radar::Matchers::LocalRequestMatcher
      @hash = {}
      @event = create_exception_event
      @event.stubs(:to_hash).returns(@hash)
    end

    should "match if the IP matches a local IP" do
      @hash[:request] = { :remote_ip => "127.0.0.1" }
      assert @klass.new.matches?(@event)
    end

    should "not match if the IP does not match a local IP" do
      @hash[:request] = { :remote_ip => "33.33.33.10" }
      assert !@klass.new.matches?(@event)
    end

    should "not match if the field doesn't exist" do
      assert !@klass.new.matches?(@event)
    end
  end
end
