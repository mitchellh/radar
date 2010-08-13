# Radar

* Source: [http://github.com/mitchellh/radar](http://github.com/mitchellh/radar)
* IRC: `#vagrant` on Freenode

Radar is a tool which provides a drop-in solution to catching and reporting
errors in your Ruby applications in customizable ways.

Radar is different from available tools such as Hoptoad and Exceptional
since the former are built with Rails apps in mind, logging to a central
server, whereas Radar was initially built for [Vagrant](http://vagrantup.com),
a command line tool. And instead of solely logging to a central server,
Radar supports logging in configurable ways (to a file, to a server, to
a growl notification, etc.)

## Quick Start

    gem install radar

Then just begin logging exceptions in your application:

    $radar = Radar::Application.new
    $radar.report(exception)

You can also tell Radar to attach itself to Ruby's `at_exit` hook
so it can catch application-crashing exceptions automatically:

    $radar.rescue_at_exit!

Both of the above methods can be used together, of course.

The reason for Radar requiring instantiation (rather than exposing
various class methods) is clear: So that dependencies of a project
which may also be using Radar don't collide. Imagine you configure
Radar to dump exception reports to directory `foo`, but one of your
dependencies configures it to dump to directory `bar`, which overrides
your configuration. To facilitate multiple Radar instances running
in a single app, Radar requires instantiating an application.

## Documentation and User Guide

For more details on configuring Radar, please view the user guide
which is available in the [user_guide](#) file.

^^^ COMING SOON ^^^

## Contributing

To hack on Radar, you'll need [bundler](http://github.com/carlhuda/bundler) which
can be installed with a simple `gem install bundler`. Then, do the following:

    bundle install
    rake

This will run the test suite, which should come back all green! Then you're
good to go.
