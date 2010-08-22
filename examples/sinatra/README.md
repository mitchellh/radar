# Radar Examples: Sinatra

This example shows Radar's Sinatra integration.

## Usage

First make sure you install the dependencies using Bundler, then just
run `rackup` (`bundle exec` is used to verify that it uses the bundle
environment to get the binary):

    bundle install
    ruby example.rb

Then access `localhost:4567`, which should throw an exception. Go back
to your console and see that Radar caught and reported the exception!
