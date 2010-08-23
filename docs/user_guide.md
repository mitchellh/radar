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
  - Integration with frameworks: Rack, Rails 2, Rails 3, and Sinatra.

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
      app.reporter :file
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

### Framework Integration

Radar provides framework integration out of the box for Rack, Rails 2, Rails 3, and
Sinatra. These all require little or no extra configuration to your Radar
applications.

For more information on framework integration, see the [framework integration section](#__toc__section33).

## Terminology

Although you've already seen a basic example, I think its a good idea to
go over terminology quickly before moving onto to the details of every feature:

  - **application** - A single exception reporter which can contain its own
    set of matchers, reporters, data extensions, etc.
  - **reporter** - A reporter takes Radar-generated exception data when an
    exception is reported and does _something_ with it such as save it to a file,
    store it on a server, etc.
  - **data extension** - Adds additional contextual information to the exception
    event hash before it is sent to the reporters.
  - **matcher** - An exception must adhere to at least one matcher for Radar
    to send the exception to reporters. This allows for filtering of specific
    exceptions.
  - **filter** - A class or proc that filters the data before it is reported.
    This allows you to filter passwords, for example.
  - **integration** - The act of integrating Radar with 3rd party software,
    such as Rack or Rails.

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
      app.reporter :file
    end

And can be configured by passing a block to the reporter, which is yielded with
the instance of that reporter:

    Radar::Application.new(:my_application) do |app|
      app.reporter :file do |reporter|
        reporter.output_directory = "~/.radar/exceptions"
      end
    end

Radar also allows multiple reporters to be used, which are then called
in the order they are defined when an exception occurs:

    Radar::Application.new(:my_application) do |app|
      app.reporter FileReporter
      app.reporter AnotherReporter
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
      app.reporter :file do |reporter|
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
      app.reporter :io, :io_object => STDOUT
    end

#### LoggerReporter

{Radar::Reporter::LoggerReporter LoggerReporter} outputs the exception event JSON
to any `Logger` object. This is useful if you want to integrate Radar with an
existing logging system, or if you simply want a backup for your exceptions (e.g.
report to both a server and a logger).

    Radar::Application.new(:my_application) do |app|
      app.reporter :logger, :log_object => Logger.new(STDOUT), :log_level => :error
    end

`log_level` will default to `:error` if not specified.

#### HoptoadReporter

{Radar::Reporter::HoptoadReporter HoptoadReporter} sends an exception event to
the [Hoptoad service](http://hoptoadapp.com). If Radar is integrated with a Rack
or Rails application, then the reporter will automatically add request information
to the Hoptoad notice as well.

    Radar::Application.new(:my_application) do |app|
      app.reporter :hoptoad, :api_key => "your_key_here"
    end

There are many other options which can be set, though `api_key` is the only required
one. See the class docs for more information.

**Note:** Due to a limitation of the Hoptoad service, only a very specific
set of data can be sent to the service. Therefore, your data extension information
likely won't be sent to Hoptoad.

### Custom Reporters

It is very easy to write custom reporters. A reporter is either a class which
responds to `report` and takes a single {Radar::ExceptionEvent} as a parameter,
or it is a lambda function which takes a single {Radar::ExceptionEvent} as a
parameter. Below is an example of a lambda function reporter which simply
prints out that an error occurred to `stdout`:

    Radar::Application.new(:my_application) do |app|
      app.reporter do |event|
        puts "An exception occurred! Message: #{event.exception.message}"
      end
    end

And the same example as above except implemented using a class:

    class StdoutReporter
      def report(event)
        puts "An exception occurred! Message: #{event.exception.message}"
      end
    end

    Radar::Application.new(:my_application) do |app|
      app.reporter StdoutReporter
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
      app.data_extension UnameExtension
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
      app.match :class, StandardError
      app.match :backtrace, /file.rb$/
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

    app.match :backtrace, "my_file.rb"
    app.match :backtrace, /.+_test.rb/
    app.match :backtrace, /.+_test.rb/, :depth => 5

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

    app.match :class, StandardError
    app.match :class, StandardError, :include_subclasses => true
    app.match :class, /.*Error/

#### `:local_request`

A matcher which matches if a web request came from a local address. This
matcher requires that a remote IP be available at `event.to_hash[:request][:remote_ip]`
(which is set by the Rack and Rails data extensions if you're using it
in any framework).

Examples of how it can be used below:

    app.match :local_request
    app.match :local_request, :remote_ip_getter => Proc.new { |event| event.to_hash[:my_ip] }
    app.match :local_request, :localhost => /^192\.168\.0\.1$/

Usually the defaults are what you want. Also, this matcher is more useful
as a rejecter, typically, since you don't want local requests during
development firing off exception reports:

    app.reject :local_request

### Custom Matchers

Matchers are simply classes which respond to `matches?` or a lambda function,
both of which are expected to take a single {Radar::ExceptionEvent} as a
parameter and must return a boolean `true` or `false. If true, then the exception
is reported, otherwise other matchers are tried, or if there are no other matchers,
the exception is ignored.

Below is a simple custom matcher which only matches exceptions with a
specific message, implemented using a lambda function:

    Radar::Application.new(:app) do |app|
      app.match do |event|
        event.exception.message == "Hello"
      end
    end

And now the same matcher as above is implemented using a class, with a
little more flexibility:

    class ErrorMessageMatcher
      def initialize(message)
        @message = message
      end

      def matches?(event)
        event.exception.message == @message
      end
    end

    Radar::Application.new(:app) do |app|
      app.match ErrorMessageMatcher, "Hello"
    end

Both of the above result in the following behavior:

    raise "Hello, World"   # not reported
    raise "Hello"          # reported since it matches the message

As you can see, for quick, easy matchers, lambda functions are the way to
go and provide an easy solution to matching. However, if you need more
customizability or complex logic, classes are the ideal solution.

### Rejecters

Matchers are useful for setting up a whitelist of exactly what is allowed
to be reported. Sometimes it is more useful to setup a blacklist, instead
(or a combination of the both). "Rejecters" is the term given to the blacklist,
although they use the exact same matchers as above. The only difference is
that if any of the rejecters match, then the error is not reported.

Another important difference is that rejecters take precedence over matchers.
This means that even if a matcher would have matched the exception, if
a rejecter matches it, then the exception will never be reported by Radar.

Using rejecters is the exact same as matchers, and use the exact same
classes:

    Radar::Application.new(:app) do |app|
      app.reject :backtrace, "my_file.rb"
    end

## Filters

Filters provide a method of filtering the data hash just before it is sent
to any reporters. This allows you to filter passwords, modify fields, etc.

### Using a Filter

There are two ways to use a filter: as a class or as a lambda.

#### Lambda

The easiest way, if the filtering is really simple, is to just
use a lambda. Below is a small example:

    Radar::Application.new(:my_app) do |app|
      app.filter do |data|
        data.delete(:password)
        data
      end
    end

This filter would delete the `:password` key from the data hash, and returns
the new data hash.

#### Class

You can also create a filtering class if that is more convenient or if
there is more complex logic in the filtering. The class must respond to
`filter`.

    class MyPasswordFilter
      def filter(data)
        data.delete(:password)
        data
      end
    end

    Radar::Application.new(:my_app) do |app|
      app.filter MyPasswordFilter
    end

This does the same thing, functionally, as the previous lambda example. However,
it is clear to see how a class would enable you to more easily encapsulate more
complex filtering logic.

### Built-in Filters

#### KeyFilter

The {Radar::Filters::KeyFilter KeyFilter} filters specific keys out of the result
data and replaces it with specified text ("[FILTERED]" by default). Below we
configure the key filter to filter passwords:

    Radar::Application.new(:my_app) do |app|
      app.filter :key, :key => :password
    end

Then, assuming an exception is raised at some point and the following event data
is created:

    { :request  => { :password => "foo" },
      :rack_env => { :query => { :password => "foo" } } }

Then before it is sent to reporters it will be filtered into this:

    { :request  => { :password => "[FILTERED]" },
      :rack_env => { :query => { :password => "[FILTERED]" } } }

There are many options which can be sent to `KeyFilter`, please see the
class documentation for more details.

## Integration with Other Software

### Rack

Radar provides a lightweight Rack middleware to catch and report errors to a
specified Radar application. Below is a sample `config.ru` file which would
catch any exceptions by the rack application:

    require "rubygems"
    require "radar"

    app = Radar::Application.new(:my_app)
    app.reporter :io, :io_object => STDOUT

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

### Rails 2

Radar can integrate with any Rails 2 application to automatically
catch any exceptions thrown by actions as well as provide additional
information capture when the exception is raised. First, add the `radar`
dependency to your environment (via a `Gemfile` or `environment.rb`) and
make sure it is installed. Then create an initializer in `config/initializers/radar.rb`
to create your application:

    Radar::Application.new(:my_app) do |app|
      # Enable any reporters here and configure the app as usual

      # Integrate with rails 2
      app.integrate :rails2
    end

Radar will immediately begin to catch and report any errors.

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

### Sinatra

Radar can easily integrate with Sinatra, since Sinatra is built on top of
Rack. Below is a very simple example Sinatra application showing Radar
integration:

    require "rubygems"
    require "sinatra"
    require "radar"

    # First define the Radar application, like normal.
    Radar::Application.new(:my_app) do |app|
      # ...
    end

    # And the Sinatra application
    class MyApp < Sinatra::Base
      use Rack::Radar, :application => Radar[:my_app]

      get "/" do
        raise "BOOM!"
      end
    end

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
