require 'test_helper'

class KeyFilterTest < Test::Unit::TestCase
  context "key filter class" do
    setup do
      @klass = Radar::Filters::KeyFilter
    end

    should "filter out the given key" do
      @instance = @klass.new(:key => :password)
      data =  { :request  => { :password => "foo" },
                :rack_env => { :params => { "password" => "foo" } } }

      result = @instance.filter(data)
      assert_equal @instance.filter_text, data[:request][:password]
      assert_equal @instance.filter_text, data[:rack_env][:params]["password"]
    end

    should "filter out multiple keys" do
      @instance = @klass.new(:key => [:password, :username])
      data = { :request => { :username => "foo", :password => "foo" } }

      result = @instance.filter(data)
      assert_equal @instance.filter_text, data[:request][:username]
      assert_equal @instance.filter_text, data[:request][:password]
    end
  end
end
