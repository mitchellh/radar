---
layout: default
title: Welcome
---
<div class="banner">
  Radar is an ultra-configurable exception reporting library for Ruby
  which lets you report errors in your applications any way you want.
  Learn more about the <a href="/rationale.html">rationale</a>
  behind Radar.
</div>

# Getting Started

Enabling Radar in an existing application is a snap:

{% highlight bash %}
$ gem install radar
{% endhighlight %}

Then define a Radar application as early as possible in your own application:

{% highlight ruby %}
Radar::Application.new(:my_app) do |app|
  app.reporters.use :file
  app.rescue_at_exit!
end
{% endhighlight %}

This alone will begin catching and recording exceptions to the filesystem
(by default at `~/.radar/errors/my_app`). The `rescue_at_exit!` call on the
app tells Radar to catch any application-crashing exceptions as well.

# More Power!

Radar is customizable in almost every way:

* **Reporters** allow you to configure where Radar sends exceptions to:
  a file, a server, email, Hoptoad, etc. Anywhere you want!
* **Data Extensions** enable you to add more information to exception
  events, such as application configuration, environmental information,
  etc.
* **Matchers** will tell an application exactly what kind of exceptions
  to report. Only interested in exceptions from a specific file? No problem.
* **Filters** allow you to filter the exception data before it is sent
  to the reporters. This lets you filter out sensitive information such
  as passwords, or if you just want to remove a field since its unnecessary,
  you can do that here, as well.

# User Guide

For all the details on how to use Radar, please see the [user guide](#),
which covers everything in great detail.
