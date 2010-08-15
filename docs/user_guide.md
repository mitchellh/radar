# Radar User's Guide

## Overview

Radar is a tool which provides a drop-in solution to catching and reporting
errors in your Ruby application via customizable mediums.

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
      app.config.reporter Radar::Reporter::FileReporter
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
      app.config.reporter FileReporter
    end

And can be configured by passing a block to the reporter, which is yielded with
the instance of that reporter:

    Radar::Application.new(:my_application) do |app|
      app.config.reporter FileReporter do |reporter|
        reporter.storage_directory = "~/.radar/exceptions"
      end
    end

Radar also allows multiple reporters to be used, which are then called
in the order they are defined when an exception occurs:

    Radar::Application.new(:my_application) do |app|
      app.config.reporter FileReporter
      app.config.reporter AnotherReporter
    end

### Built-in Reporters

#### FileReporter

{Radar::Reporter::FileReporter FileReporter} outputs exception information as JSON to a file
on the local filesystem. The filename is in the format of `timestamp-uniquehash.txt`,
where `timestamp` is the time that the exception occurred and `uniquehash` is the
{Radar::ExceptionEvent#uniqueness_hash}.

The directory where these files will be stored is configurable:

    Radar::Application.new(:my_application) do |app|
      app.config.reporter Radar::Reporter::FileReporter do |reporter|
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
      app.config.reporter StdoutReporter
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
      app.config.data_extension UnameExtension
    end

### Built-In Data Extensions

By default, {Radar::ExceptionEvent#to_hash} (view the source) returns very little
information on its own. To be as general and extensible as possible, even the data
such as information about the host are created using built-in data extensions.
Some of these are enabled by default, which are designated by the `*` on the name.

* {Radar::DataExtensions::HostEnvironment HostEnvironment}* - Adds information about the
  host such as Ruby version and operating system.

`*`: Enabled by default on every application.
