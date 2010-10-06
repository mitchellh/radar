# Radar

* Source: [http://github.com/mitchellh/radar](http://github.com/mitchellh/radar)
* IRC: `#vagrant` on Freenode
* User Guide: [http://radargem.com/doc/file.user_guide.html](http://radargem.com/doc/file.user_guide.html)
* Website: [http://radargem.com](http://radargem.com)

Radar is an ultra-configurable exception reporting library for Ruby which
lets you report errors in your applications any way you want. Read about
the [rationale behind Radar](http://radargem.com/rationale.html).

## Brief Feature Breakdown

  - Reporters allow Radar to report anywhere: a file, a server, email, etc.
  - Data extensions enable you to add additional contextual data to exceptions
  - Matchers are able to filter which exceptions are reported
  - Filters remove sensitive data from exceptions
  - Routes allow different exceptions events to be handled differently
  - Run multiple Radar "applications" side-by-side, so your application and
    libraries can all have Radar integrated and running together in harmony
  - Integration with 3rd party software: Rack, Rails 2, Rails 3, and Sinatra
  - Drop-in replacement and integration with [Hoptoad](http://hoptoadapp.com)

## Quick Start

    gem install radar

Then just begin logging exceptions in your application:

    r = Radar::Application.new(:my_application)
    r.reporter :file
    r.report(exception)

You can also tell Radar to attach itself to Ruby's `at_exit` hook
so it can catch application-crashing exceptions automatically:

    r.rescue_at_exit!

Both of the above methods can be used together, of course.

Since the above enabled the `FileReporter` for the application, reported
exceptions will be stored in a text file on the local filesystem, by default
at `~/.radar/errors/my_application`. Sample contents of the exception
data generated by default is shown below. Note that you can add your own
custom data to this output by using data extensions (covered in the user
guide).

    {
       "application":{
          "name":"my_application"
       },
       "exception":{
          "klass":"RuntimeError",
          "message":"This was an example exception",
          "backtrace":[
             "test.rb:28:in `<main>'"
          ],
          "uniqueness_hash":"296d169e7928c4433ccfcf091b4d737aabe83dcb"
       },
       "occurred_at":1281894743,
       "host_environment":{
          "ruby_version":"1.9.2",
          "ruby_pl":-1,
          "ruby_release_date":"2010-07-11",
          "ruby_platform":"x86_64-darwin10.4.0"
       }
    }

Also, instead of assigning the application to a variable, you may also
look it up later anywhere in your application:

    Radar::Application.find(:my_application).report(exception)

    # Or the shorthand:
    Radar[:my_application].report(exception)

## Documentation and User Guide

For more details on configuring Radar, please view the
[user guide](http://radargem.com/doc/file.user_guide.html), which
is a detailed overview of Radar and all of its features.

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
