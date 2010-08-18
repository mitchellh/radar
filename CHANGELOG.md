## 0.2.0 (unreleased)

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
