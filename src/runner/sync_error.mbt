///|
/// An execution option or host operation unsupported by synchronous execution.
#derive(Debug)
pub suberror SyncExecutionError {
  ParallelNotSupported
  HostIoFailed(operation~ : String, path~ : String, message~ : String)
}

///|
pub extend SyncExecutionError with @moonbitlang/core/debug.Debug::{to_repr}
