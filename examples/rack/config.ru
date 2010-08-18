require "rubygems"
require "bundler/setup"
require "radar"

# Create a custom reporter which will just dump the info JSON to
# STDOUT.
class StdoutReporter
  def report(event)
    puts event.to_json
  end
end

# Create a Radar::Application, configured how we want it.
app = Radar::Application.new(:rack_example) do |a|
  a.config.reporters.use StdoutReporter
end

# Use the Radar Rack middleware for the created application,
# and make the Rack app just throw an exception so we can see it
# working.
use Rack::Radar, :application => app
run lambda { |env|
  raise "Uh oh, an error!"
  [200, { "Content-Type" => "text/html" }, ["This shouldn't be reached."]]
}
