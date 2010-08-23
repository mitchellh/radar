require "rubygems"
require "bundler/setup"
require "radar"

# Create a Radar::Application, configured to simply log to the
# STDERR stream.
app = Radar::Application.new(:rack_example) do |a|
  a.reporter :io, :io_object => STDERR
end

# Use the Radar Rack middleware for the created application,
# and make the Rack app just throw an exception so we can see it
# working.
use Rack::Radar, :application => app
run lambda { |env|
  raise "Uh oh, an error!"
  [200, { "Content-Type" => "text/html" }, ["This shouldn't be reached."]]
}
