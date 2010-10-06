$:.unshift File.expand_path('../../lib', __FILE__)

require "rubygems"
require "bundler/setup"
require "test/unit"
require "shoulda"
require "mocha"
require "radar"

class Test::Unit::TestCase
  # Returns a real {Radar::ExceptionEvent} object with a newly created
  # {Radar::Application} and a valid (has a backtrace) exception.
  def create_exception_event(extra=nil)
    application = Radar::Application.new(:foo, :register => false)
    exception = nil

    begin
      yield if block_given?
      raise "Something bad happened!"
    rescue => e
      exception = e
    end

    Radar::ExceptionEvent.new(application, exception, extra)
  end
end
