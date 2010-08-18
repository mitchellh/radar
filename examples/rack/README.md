# Radar Examples: Rack

This example shows Radar's Rack integration.

## Usage

First make sure you install the dependencies using Bundler, then just
run `rackup` (`bundle exec` is used to verify that it uses the bundle
environment to get the binary):

    bundle install
    bundle exec rackup

Then access `localhost:9292`, which should throw an exception. Go back
to your console and see that Radar caught and reported the exception!
