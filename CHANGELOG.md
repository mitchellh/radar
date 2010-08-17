## 0.2.0 (unreleased)

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
