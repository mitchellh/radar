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

## Documentation and User Guide

While the quick start is below, you can find details documentation by visiting
the [user guide](http://radargem.com/doc/file.user_guide.html) and [website](http://radargem.com).

## Quick Start

### Installation

Radar is packaged as a RubyGem, just install it like any other:

    gem install radar

### Your First Application

Each configured Radar instance is known as an _application_. The ability
to encapsulate all your error reporting configuration into applications
allows your app and all its depedencies to have Radar built-in, without
overlapping. So the first thing to do with Radar is to create a new
Radar application and configure it:

    Radar::Application.new(:my_application) do |app|
      app.reporter :file
      app.rescue_at_exit!
    end

The above tells your application to do the following:

* Use a _file reporter_ to report errors. **Reporters** allow Radar to notify
  literally any sort of service of errors. In this case, Radar will simply output
  errors to a file. Multiple reporters can be configured.
* `rescue_at_exit!` tells Radar to rescue any app-crashing errors. Radar will hook
  into the Ruby callback when your app crashes and reports that error quickly
  before crashing.

There are _tons_ more which can be configured on an application, such as
filters, routes, and more. See the `examples` directory for a bunch of
examples which you can run right away.

Of course, the above application will only automatically catch exceptions that
crash your app. Perhaps somewhere in the middle of your application you want to
report an exception which you caught. You can do that too:

    Radar[:my_application].report(exception)

### 3rd Party Framework Integration

Out of the box, Radar can integrate with Rack, Rails 2, Rails 3, and Sinatra.
By "integrate," we mean that Radar will automatically catch exceptions during
web requests and report them along with adding some nice contextual information
about the request. There is nothing special about these integrations, they're
simply pre-configured Radar applications with a certain set of data extensions.
It is still up to you to configure everything else.

Since integration is [documented in great detail](http://radargem.com/doc/file.user_guide.html)
in the user guide, a brief example is show here:

    Radar::Application.new(:my_rails_app) do |app|
      # ... other config here

      app.integrate :rails3
    end

That's it! Same with Rack, Sinatra, etc.

### What sort of data is recorded?

When an exception is raised, Radar grabs it and wraps it up as an _exception event_.
This event is then passed onto reporters which do something about it. A JSON
representation of a bare exception event is shown below, but keep it mind that
this can be easily extended to add application-specific information or context-sensitive
information with **data extensions**.

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
