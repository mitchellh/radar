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


## Getting Started

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

# MORE COMING SOON
