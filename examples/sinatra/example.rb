require "rubygems"
require "bundler/setup"
require "radar"
require "sinatra"

Radar::Application.new(:sinatra_example) do |a|
  a.reporter :io, :io_object => STDERR
end

class MyApp < Sinatra::Base
  use Rack::Radar, :application => Radar[:sinatra_example]

  get '/' do
    raise "UH OH"
  end
end

MyApp.run!
