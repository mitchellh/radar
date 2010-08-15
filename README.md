# Radar

* Source: [http://github.com/mitchellh/radar](http://github.com/mitchellh/radar)
* IRC: `#vagrant` on Freenode

Radar is a tool which provides a drop-in solution to catching and reporting
errors in your Ruby applications in customizable ways.

Radar is not a typical exception notifier such as Hoptoad and Exceptional
since the former are built with Rails apps in mind, logging to a central
server. Instead, Radar was initially built for [Vagrant](http://vagrantup.com),
a command line tool. And instead of solely logging to a central server,
Radar supports logging in configurable ways (to a file, to a server, to
a growl notification, etc.)

## Quick Start

    gem install radar

Then just begin logging exceptions in your application:

    r = Radar::Application.new(:my_application)
    r.report(exception)

You can also tell Radar to attach itself to Ruby's `at_exit` hook
so it can catch application-crashing exceptions automatically:

    r.rescue_at_exit!

Both of the above methods can be used together, of course.

Instead of assigning the application to a variable, you may also
look it up later anywhere in your application:

    Radar::Application.find(:my_application).report(exception)

    # Or the shorthand:
    Radar[:my_application].report(exception)

## Documentation and User Guide

For more details on configuring Radar, please view the user guide
which is available in the [user_guide](https://github.com/mitchellh/radar/blob/master/docs/user_guide.md) file.

## Reporting Bugs and Requesting Features

Please use the [issues section](http://github.com/mitchellh/radar/issues) to report
bugs and request features. This section is also used as the TODO area for the
Radar gem.

## Contributing

To hack on Radar, you'll need [bundler](http://github.com/carlhuda/bundler) which
can be installed with a simple `gem install bundler`. Then, do the following:

    bundle install
    rake

This will run the test suite, which should come back all green! Then you're
good to go.

The general steps to contributing a new change are:

1. Fork the repository
2. Make your changes, writing tests if necessary
3. Open an [issue](http://github.com/mitchellh/radar/issues) with the feature and
   a link to your fork or a gist with a patch.
4. Wait patiently, for I am but one man.
