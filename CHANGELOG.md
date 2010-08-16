## 0.2.0 (unreleased)

  - Added `prune_time` configuration to `FileReporter` which automatically prunes
    files older than the specified age. [closes GH-15]
  - Extra data in the form of a hash can be passed to `Application#report` now,
    which is available in `ExceptionEvent#extra`, so that reporters and data
    extensions can take advantage of this. [closes GH-14]
  - Added LICENSE file. Oops!

## 0.1.0

  - Initial version.
