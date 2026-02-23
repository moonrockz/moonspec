///|
pub(all) struct ParamInfo {
  name : String
  type_name : String
} derive(Show, Eq)

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
} derive(Show, Eq)

///|
pub(all) struct WorldConfigInfo {
  type_name : String
  init_fn : String?
  source_file : String
  line : Int
} derive(Show, Eq)

///|
pub(all) struct ScanResult {
  step_fns : Array[StepFnInfo]
  world_configs : Array[WorldConfigInfo]
} derive(Show, Eq)
