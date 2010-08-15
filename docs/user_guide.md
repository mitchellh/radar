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

First, as early as possible in your application so that Radar can begin
catching exceptions right away, create a new {Radar::Application}
instance for your own app, replacing `my_application` with a unique name for your
application.

    Radar::Application.new(:my_application)

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

None yet!

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
