///|
pub(all) struct ParamInfo {
  name : String
  type_name : String
} derive(Debug, Eq)

///|
pub extend ParamInfo with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ParamInfo with Eq::{not_equal, equal}

///|
pub(all) struct StepFnInfo {
  keyword : String
  pattern : String
  fn_name : String
  world_type : String
  params : Array[ParamInfo]
  is_method : Bool
  raises : Bool
  source_file : String
  line : Int
} derive(Debug, Eq)

///|
pub extend StepFnInfo with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepFnInfo with Eq::{not_equal, equal}

///|
pub(all) struct WorldConfigInfo {
  type_name : String
  init_fn : String?
  source_file : String
  line : Int
} derive(Debug, Eq)

///|
pub extend WorldConfigInfo with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend WorldConfigInfo with Eq::{not_equal, equal}

///|
pub(all) struct ScanResult {
  step_fns : Array[StepFnInfo]
  world_configs : Array[WorldConfigInfo]
} derive(Debug, Eq)

///|
pub extend ScanResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ScanResult with Eq::{not_equal, equal}
