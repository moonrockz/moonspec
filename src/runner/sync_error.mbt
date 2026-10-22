///|
/// An execution option or host operation unsupported by synchronous execution.
pub suberror SyncExecutionError {
  ParallelNotSupported
  HostIoFailed(operation~ : String, path~ : String, message~ : String)
} derive(Debug)

///|
pub extend SyncExecutionError with @moonbitlang/core/debug.Debug::{to_repr}
