require 'test_helper'

class HoptoadReporterTest < Test::Unit::TestCase
  context "hoptoad reporter class" do
    setup do
      @klass = Radar::Reporter::HoptoadReporter
    end

    should "default notifier information to Radar" do
      instance = @klass.new
      assert_equal "Radar", instance.notifier_name
      assert_equal Radar::VERSION, instance.notifier_version
      assert !instance.notifier_url.empty?
    end

    should "require an API key" do
      assert_raises(ArgumentError) { @klass.new.report(create_exception_event) }
    end
  end
end
