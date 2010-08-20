# Radar User's Guide

## Overview

Radar is a tool which provides a drop-in solution to catching and reporting
errors in your Ruby application via customizable mediums. A quick feature
breakdown of Radar:

  - Reporters allow Radar to report anywhere: a file, a server, email, etc.
  - Data extensions to add additional contextual data to exceptions
  - Matchers to filter exceptions which Radar reports
  - Run multiple Radar "applications" side-by-side to catch and report
    different exceptions to different places
  - Integration with 3rd party software: Rack, Rails 3.

## Installation

Install via RubyGems:

    gem install radar

Or specify in your own library or application's `Gemfile` or `gemspec` so
that the gem is included properly.

## Basic Usage

### Setup

First, as early as possible in your application so that Radar can begin
catching exceptions right away, create a new {Radar::Application}
instance for your own app, replacing `my_application` with a unique name for your
application.

    Radar::Application.new(:my_application)

But this alone won't do anything, since you haven't configured any reporters
for the application. Reporters are what handle taking an {Radar::ExceptionEvent ExceptionEvent}
and doing something with it (such as storing it in a file, reporting it to a
remote server, etc.). Radar comes with some built-in reporters. Below, we configure
the application to log errors to a file (by default at `~/.radar/errors/my_application`):

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use :file
    end

### Reporting Errors

Once the application is setup, there are two methods to report errors:

1. Manually call the {Radar::Application#report report} method on the application.
2. Tell the application to {Radar::Application#rescue_at_exit! rescue at exit} so
   Radar automatically catches any exceptions before your application crashes.

Calling the report method manually:

    app = Radar::Application.new(:my_application)
    app.report(exception)

The use case for this is in a `rescue` block somewhere, and forces Radar
to report the given exception.

Telling Radar to catch exceptions on exit is equally simple, and can be
used in conjunction with the above method as well:

    app = Radar::Application.new(:my_application)
    app.rescue_at_exit!

Now, whenever your application is about to crash (an exception not caught by
a `rescue`), Radar will catch your exception and report it just prior to
crashing.

# Features

## Reporters

On its own, Radar does nothing but catch and shuttle exceptions to reporters. Without
reporters, Radar is basically useless! A reporter is a class which takes an
{Radar::ExceptionEvent} and does something with it. Its easier to get a better idea
of what this means with a few examples:

* `FileReporter` - Stores the data from an exception on the filesystem for each
  exception.
* `ServerReporter` - Transfers information about an exception to some remote
  server.

### Enabling and Configuring a Reporter

Reporters are enabled using the appilication configuration:

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use :file
    end

And can be configured by passing a block to the reporter, which is yielded with
the instance of that reporter:

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use :file do |reporter|
        reporter.output_directory = "~/.radar/exceptions"
      end
    end

Radar also allows multiple reporters to be used, which are then called
in the order they are defined when an exception occurs:

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use FileReporter
      app.config.reporters.use AnotherReporter
    end

As you can see from the above examples, a reporter takes both a symbol
or a class. If a symbol is given, Radar expects the class to be camelcased
suffixed with `Reporter` and be under the `Radar::Reporter` namespace.
For example, if you used the symbol `:my_place`, it would expect the reporter
to be at `Radar::Reporter::MyPlaceReporter`. To avoid this, you can always
use the class explicitly.

### Built-in Reporters

#### FileReporter

{Radar::Reporter::FileReporter FileReporter} outputs exception information as JSON to a file
on the local filesystem. The filename is in the format of `timestamp-uniquehash.txt`,
where `timestamp` is the time that the exception occurred and `uniquehash` is the
{Radar::ExceptionEvent#uniqueness_hash}.

The directory where these files will be stored is configurable:

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use :file do |reporter|
        reporter.output_directory = "~/my_application_errors"
      end
    end

You may also use a lambda. Below is also the default value for the FileReporter:

    reporter.output_directory = lambda { |event| "~/.radar/#{event.application.name}" }

A few notes:

* The FileReporter does not automatically handle cleaning up old exception files or reporting
  these files to any remote server. It is up to you, if you wish, to clean up old
  exception information.
* The JSON output is compressed JSON, and is not pretty printed. It is up to you to take the
  JSON and pretty print it if you wish it to be easily human readable. There are
  [services](http://jsonformatter.curiousconcept.com/) out there to do this.

For complete documentation on this reporter, please see the actual {Radar::Reporter::FileReporter}
page.

#### IoReporter

{Radar::Reporter::IoReporter IoReporter} outputs the exception event JSON to
any IO object (`stdout`, `stderr`, a net stream, etc.).

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use :io, :io_object => STDOUT
    end

#### LoggerReporter

{Radar::Reporter::LoggerReporter LoggerReporter} outputs the exception event JSON
to any `Logger` object. This is useful if you want to integrate Radar with an
existing logging system, or if you simply want a backup for your exceptions (e.g.
report to both a server and a logger).

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use :logger, :log_object => Logger.new(STDOUT), :log_level => :error
    end

`log_level` will default to `:error` if not specified.

### Custom Reporters

It is very easy to write custom reporters. A reporter is simply a class which
responds to `report` and takes a single {Radar::ExceptionEvent} as a parameter.
Below is an example of a reporter which simply prints out that an error
occurred:

    class StdoutReporter
      def report(event)
        puts "An exception occurred! Message: #{event.exception.message}"
      end
    end

And then using that reporter is just as easy:

    Radar::Application.new(:my_application) do |app|
      app.config.reporters.use StdoutReporter
    end

## Data Extensions

Data extensions allow you to easily extend the data represented by {Radar::ExceptionEvent#to_hash}.
By default, Radar only sends a small amount of information about the host environment and the
exception when an exception occurs. Often its more helpful to get more information about the
environment to more easily track down a bug. Some examples:

* HTTP request headers for a web application
* Configuration settings for a desktop application

### Defining Data Extensions

Data extensions are defined with classes which are expected to be initialized
with a reference to a {Radar::ExceptionEvent} and must implement the `to_hash`
method. Below is a data extension to add the output of `uname -a` to the event:

    class UnameExtension
      def initialize(event)
        @event = event
      end

      def to_hash
        { :uname => `uname -a` }
      end
    end

### Enabling Data Extensions

Data extensions are enabled via the application configuration like most other
things:

    Radar::Application.new(:my_application) do |app|
      app.config.data_extensions.use UnameExtension
    end

### Built-In Data Extensions

By default, {Radar::ExceptionEvent#to_hash} (view the source) returns very little
information on its own. To be as general and extensible as possible, even the data
such as information about the host are created using built-in data extensions.
Some of these are enabled by default, which are designated by the `*` on the name.

* {Radar::DataExtensions::HostEnvironment HostEnvironment}* - Adds information about the
  host such as Ruby version and operating system.

`*`: Enabled by default on every application.

## Matchers

Matchers allow Radar applications to conditionally match exceptions so that
a Radar application doesn't catch unwanted exceptions, such as exceptions which
may not be caused by the library in question, or perhaps exceptions which aren't
really exceptional.

### Enabling a Matcher

Matchers are enabled in the application configuration:

    Radar::Application.new(:app) do |app|
      app.config.match :class, StandardError
      app.config.match :backtrace, /file.rb$/
    end

As you can see, multiple matchers may be enabled. In this case, as long as at
least one matches, then the exception will be reported. The first argument to
{Radar::Config#match match} is a symbol or class of a matcher. If it is a symbol,
the symbol is constantized and expects to exist under the `Radar::Matchers` namespace.
If it is a class, that class will be used as the matcher. Any additional arguments
are passed directly into the initializer of the matcher. For more information
on writing a custom matcher, see the section below.

If no matchers are specified (the default), then all exceptions are caught.

### Built-in Matchers

#### `:backtrace`

A matcher which matches against the backtrace of the exception. It allows:

* Match that a string is a substring of a line in the backtrace
* Match that a regexp matches a line in the backtrace
* Match one of the above up to a maximum depth in the backtrace

Examples of each are shown below (respective to the above order):

    app.config.match :backtrace, "my_file.rb"
    app.config.match :backtrace, /.+_test.rb/
    app.config.match :backtrace, /.+_test.rb/, :depth => 5

If an exception doesn't have a backtrace (can happen if you don't actually
`raise` an exception, but instantiate one) then the matcher always returns
`false`.

#### `:class`

A matcher which matches against the class of the exception. It is configurable
so it can check against:

* An exact match
* Match class or any subclasses
* Match a regexp name of a class

Examples of each are shown below (in the above order):

    app.config.match :class, StandardError
    app.config.match :class, StandardError, :include_subclasses => true
    app.config.match :class, /.*Error/

### Custom Matchers

Matchers are simply classes which respond to `matches?` which returns a boolean
noting if the given {Radar::ExceptionEvent} matches. If true, then the exception
is reported, otherwise other matchers are tried, or if there are no other matchers,
the exception is ignored.

Below is a simple custom matcher which only matches exceptions with the
configured message:

    class ErrorMessageMatcher
      def initialize(message)
        @message = message
      end

      def matches?(event)
        event.exception.message == @message
      end
    end

And the usage is shown below:

    Radar::Application.new(:app) do |app|
      app.config.match ErrorMessageMatcher, "sample message"
    end

And this results in the following behavior:

    raise "Hello, World"   # not reported
    raise "sample message" # reported since it matches the message

## Integration with Other Software

### Rack

Radar provides a lightweight Rack middleware to catch and report errors to a
specified Radar application. Below is a sample `config.ru` file which would
catch any exceptions by the rack application:

    require "rubygems"
    require "radar"

    app = Radar::Application.new(:my_app)
    app.config.reporters.use :io, :io_object => STDOUT

    use Rack::Radar, :application => app
    run YourWebApp

If `YourWebApp` were to throw any exceptions, `Rack::Radar` would catch it,
report it to `app`, and reraise the exception.

Using the Rack middleware also enables the rack data extension, which provides
additional information about the rack request and environment. Sample output
of only the additional information is shown below:

    { "request": {
        "request_method": "GET",
        "url": "http://localhost:9292/favicon.ico",
        "parameters": {},
        "remote_ip": "127.0.0.1",
        "rack_env": { ... }
      }
    }

### Rails 3

Radar can integrate very easily with any Rails 3 application to automatically
catch any Rails exceptions as well as provide additional information captured
when the exception was raised. First, add Radar to your `Gemfile`:

    gem "radar"

Then `bundle install` so you pull down the gem. Then install Radar by
running the built-in generator:

    rails generate radar

This will create the necessary initializer and let you know what further
steps to take to setup Radar. Radar will already work with your application at this point,
but it won't report to anywhere by default, so at the very least you must
open up `config/initializers/radar.rb` and add a reporter.

## Internals Logging

Radar provides a lightweight internal log which logs information which
can be used to easily solve the following problems:

* Verifying that Radar is working
* Investigating why Radar is/isn't reporting certain exceptions
* Storing more information _in case_ something goes wrong

By default, the logger is disabled, but it can easily be enabled on a
per-application basis by specifying where it should log:

    Radar::Application.new(:app) do |app|
      app.config.log_location = "/var/log/radar/my_app.log"
    end

Multiple applications may be logged to the same place without issue.
