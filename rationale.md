---
layout: default
title: Rationale
---
# Rationale Behind Radar

Exception handling libraries aren't new to Ruby. There have been others:
[hoptoad notifier](http://github.com/thoughtbot/hoptoad_notifier) and
[exceptional](http://github.com/contrast/exceptional) to name a couple.
Both of the previous exception notifiers, however, suffer from the
same problems Radar hopes to resolve:

* They require you to use their own respective services for viewing and
  managing exceptions.
* They limit the data they send out. For example: You can't easily add
  new fields to the exceptions without workarounds.
* They're both tied to web applications. Hoptoad can send some general
  exception notifications but this isn't too useful without more contextual
  information (see above point). It would be nice to have automatic
  exception reporting in desktop applications as well.
* No backup plans. What if their services are down? There is no way to
  log the same exception data to a file for example, as well.

The above are the major points. There are other minor areas where Radar
improves upon these libraries as well, but for the purpose of this page,
they are ignored. Feel free to ask anytime, and I'll gladly explain.

## The Solution: Radar

Radar solves all of the above points. Radar doesn't aim to compete with
these services. On the contrary, its quite easy to extend Radar to work
with the above example services. You can think of Radar as "one more level
of abstraction" above these services, providing a unified interface to
multiple methods of reporting exceptions.

Below is a list, respective to the above, of how Radar solve each of
the mentioned problems:

* Different **reporters** allow Radar to send exception information to
  different services such as a file, a server, a system notification, or
  anything else you can imagine.
* Configurable **data extensions** allow you to easily add more information
  to exception events, such as configuration information, environmental
  information, etc.
* Due to the flexibility of **reporters** and **data extensions**, Radar
  can report errors for any sort of applications, or even just libraries.
* A Radar application can have multiple **reporters**, so if one fails,
  the others still likely work, and provide a nice backup solution.

## Get Started!

If you're convinced, go ahead and [get started](/) by starting on the
home page.

Not convinced? Please voice your concerns to [me](http://github.com/mitchellh),
since I'm interested in hearing them.
