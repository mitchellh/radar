## 0.4.0 (unreleased)

  - Added a `LocalRequestMatcher` to detect local requests for web
    applications. [GH-27]
  - Added rejecters, which are the opposite as matchers. If any rejecter
    matches, then the error is not reported.
  - You can now enable reporters, data extensions, etc using the singular
    version: `app.reporter`, `app.data_extension`, etc. [GH-25]
  - Rails 2 integration added.
  - Sinatra integration documented.
  - Reporters can now take just a block which takes a single parameter
    `event`.
  - Matchers can now take just a block which takes a single parameter `event`. [GH-24]
  - Added a `Hoptoad` reporter! Radar is now a drop-in replacement for
    Hoptoad. [GH-21]
  - Fixed issue with `LoggerReporter` not being able to use the Rails
    logger.
  - The backtrace in an `ExceptionEvent` is now a `Backtrace` object,
    which is a subclass of Array. This is because backtraces are now
    parsed to extract the file, line, and method of each entry.

## 0.3.0 (August 21, 2010)

  - Added `KeyFilter` to filter out specific keys in the data hash.
  - Added filters, which are called after data extensions as a way
    to filter out information (passwords, shorten backtrace, etc.) [GH-19]
  - Added `LoggerReporter` to log to any `Logger` object. [GH-20]
  - Rails 3 integration. See user guide for more information.
  - Rack integration. See user guide for more information. [GH-13]
  - Added `IoReporter` to log to any `IO` object.
  - Refinements to `FileReporter` and sprinkled logger statements around.
  - Lightweight logging mechanism added so that you can verify Radar is doing
    its job. [GH-9]

## 0.2.0 (August 17, 2010)

  - Built in matcher: `:backtrace` (or `BacktraceMatcher`) which checks that
    the backtrace includes the given text. [GH-18]
  - Built in matcher: `:class` (or `ClassMatcher`) which checks against the
    exception class. [GH-17]
  - Add `config.match` to conditionally match exceptions before reporting
    them so that exceptions can be better filtered per application. [GH-11]
  - Changed the way reporters and data extensions are enabled. You must now
    use methods `use`, `swap`, `insert`, `delete`, etc. See the user guide
    for details. [GH-16]
  - Added `prune_time` configuration to `FileReporter` which automatically prunes
    files older than the specified age. [GH-15]
  - Extra data in the form of a hash can be passed to `Application#report` now,
    which is available in `ExceptionEvent#extra`, so that reporters and data
    extensions can take advantage of this. [GH-14]
  - Added LICENSE file. Oops!

## 0.1.0

  - Initial version.
