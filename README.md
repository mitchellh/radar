# Radar

* Source: [http://github.com/mitchellh/radar](http://github.com/mitchellh/radar)
* IRC: `#vagrant` on Freenode

Radar is a tool which provides a drop-in solution to catching and reporting
errors in your Ruby libraries and apps to a radar server in the cloud.

Radar is different from available tools such as Hoptoad and Exceptional
since the former are built with Rails apps in mind, whereas Radar is
built for the more general case, and can also handle local logging in
addition to pushing to a remote server.

**Note:** The server portion of Radar is as of yet incomplete. This is
planned for the near future but not yet implemented.


## Quick Start

    gem install radar

Then just begin logging exceptions in your application:

    Radar.report(exception)

You can also tell Radar to attach itself to Ruby's `at_exit` hook
so it can catch application-crashing exceptions automatically:

    Radar.rescue_at_exit!

Both of the above methods can be used together, of course.

## Documentation and User Guide

For more details on configuring Radar, please view the user guide
which is available in the [user_guide](#) file.

^^^ COMING SOON ^^^

## Contributing

To hack on Radar, you'll need [bundler](http://github.com/carlhuda/bundler) which
can be installed with a simple `gem install bundler`. Then, do the following:

    bundle install
    rake

This will run the test suite, which should come back all green! Then you're
good to go.
