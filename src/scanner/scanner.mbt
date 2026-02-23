///|
/// Scan MoonBit source code for moonspec attributes.
pub fn scan_source(source : String, file_name : String) -> ScanResult {
  let (impls, _errors) = @parser.parse_string(source, name=file_name)
  let step_fns : Array[StepFnInfo] = []
  let world_configs : Array[WorldConfigInfo] = []
  walk_impls(impls, file_name, step_fns, world_configs)
  { step_fns, world_configs }
}

///|
fn walk_impls(
  impls : @list.List[@syntax.Impl],
  file_name : String,
  step_fns : Array[StepFnInfo],
  world_configs : Array[WorldConfigInfo]
) -> Unit {
  match impls {
    More(head, tail~) => {
      process_impl(head, file_name, step_fns, world_configs)
      walk_impls(tail, file_name, step_fns, world_configs)
    }
    Empty => ()
  }
}

///|
fn process_impl(
  impl_ : @syntax.Impl,
  file_name : String,
  step_fns : Array[StepFnInfo],
  world_configs : Array[WorldConfigInfo]
) -> Unit {
  match impl_ {
    TopFuncDef(fun_decl~, ..) =>
      process_func_def(fun_decl, file_name, step_fns)
    TopTypeDef(type_decl) =>
      process_type_def(type_decl, file_name, world_configs)
    _ => ()
  }
}

///|
fn process_func_def(
  fun_decl : @syntax.FunDecl,
  file_name : String,
  step_fns : Array[StepFnInfo]
) -> Unit {
  walk_attrs_for_step(fun_decl.attrs, fun_decl, file_name, step_fns)
}

///|
fn walk_attrs_for_step(
  attrs : @list.List[@attribute.Attribute],
  fun_decl : @syntax.FunDecl,
  file_name : String,
  step_fns : Array[StepFnInfo]
) -> Unit {
  match attrs {
    More(attr, tail~) => {
      match extract_step_attr(attr) {
        Some((keyword, pattern)) => {
          let info = build_step_fn_info(
            keyword, pattern, fun_decl, file_name,
          )
          step_fns.push(info)
        }
        None => ()
      }
      walk_attrs_for_step(tail, fun_decl, file_name, step_fns)
    }
    Empty => ()
  }
}

///|
/// Extract step keyword and pattern from a moonspec step attribute.
/// Returns Some((keyword, pattern)) for #moonspec.given/when/then("pattern"),
/// or None if not a moonspec step attribute.
fn extract_step_attr(
  attr : @attribute.Attribute
) -> (String, String)? {
  match attr.parsed {
    Some(Apply(id, props)) => {
      guard id.qual == Some("moonspec") else { return None }
      let keyword = id.name
      guard keyword == "given" || keyword == "when" || keyword == "then" else {
        return None
      }
      let pattern = extract_string_from_props(props)
      match pattern {
        Some(p) => Some((keyword, p))
        None => None
      }
    }
    _ => None
  }
}

///|
fn extract_string_from_props(
  props : @list.List[@attribute.Prop]
) -> String? {
  match props {
    More(head, ..) =>
      match head {
        Expr(String(s)) => Some(s)
        _ => None
      }
    Empty => None
  }
}

///|
fn build_step_fn_info(
  keyword : String,
  pattern : String,
  fun_decl : @syntax.FunDecl,
  file_name : String
) -> StepFnInfo {
  let fn_name = fun_decl.name.name
  let line = fun_decl.name.loc.start.lnum
  let is_method = first_param_is_self(fun_decl.decl_params)
  let raises = has_error_type(fun_decl.error_type)
  let (world_type, params) = extract_params(fun_decl.decl_params)
  {
    keyword,
    pattern,
    fn_name,
    world_type,
    params,
    is_method,
    raises,
    source_file: file_name,
    line,
  }
}

///|
fn has_error_type(error_type : @syntax.ErrorType) -> Bool {
  match error_type {
    NoErrorType => false
    Noraise(..) => false
    _ => true
  }
}

///|
fn first_param_is_self(
  decl_params : @list.List[@syntax.Parameter]?
) -> Bool {
  match decl_params {
    Some(More(first, ..)) =>
      match first {
        Positional(binder~, ..) => binder.name == "self"
        Labelled(binder~, ..) => binder.name == "self"
        _ => false
      }
    _ => false
  }
}

///|
fn extract_params(
  decl_params : @list.List[@syntax.Parameter]?
) -> (String, Array[ParamInfo]) {
  match decl_params {
    Some(params) => extract_params_from_list(params)
    None => ("Unit", [])
  }
}

///|
fn extract_params_from_list(
  params : @list.List[@syntax.Parameter]
) -> (String, Array[ParamInfo]) {
  // First param is self/world type, rest are cucumber params
  match params {
    More(first, tail~) => {
      let world_type = extract_param_type(first)
      let cucumber_params = collect_params(tail)
      (world_type, cucumber_params)
    }
    Empty => ("Unit", [])
  }
}

///|
fn extract_param_type(param : @syntax.Parameter) -> String {
  match param {
    Positional(ty~, ..) => type_to_string(ty)
    Labelled(ty~, ..) => type_to_string(ty)
    Optional(ty~, ..) => type_to_string(ty)
    QuestionOptional(ty~, ..) => type_to_string(ty)
    DiscardPositional(ty~, ..) => type_to_string(ty)
  }
}

///|
fn type_to_string(ty : @syntax.Type?) -> String {
  match ty {
    Some(Name(constr_id~, ..)) =>
      match constr_id.id {
        Ident(name~) => name
        Dot(pkg~, id~) => pkg + "." + id
      }
    Some(Option(ty~, ..)) =>
      type_to_string(Some(ty)) + "?"
    Some(Tuple(..)) => "Tuple"
    Some(Arrow(..)) => "Arrow"
    Some(Any(..)) => "_"
    Some(Object(constr_id)) =>
      match constr_id.id {
        Ident(name~) => name
        Dot(pkg~, id~) => pkg + "." + id
      }
    None => "Unknown"
  }
}

///|
fn collect_params(
  params : @list.List[@syntax.Parameter]
) -> Array[ParamInfo] {
  let result : Array[ParamInfo] = []
  collect_params_loop(params, result)
  result
}

///|
fn collect_params_loop(
  params : @list.List[@syntax.Parameter],
  result : Array[ParamInfo]
) -> Unit {
  match params {
    More(param, tail~) => {
      let info = param_to_info(param)
      result.push(info)
      collect_params_loop(tail, result)
    }
    Empty => ()
  }
}

///|
fn param_to_info(param : @syntax.Parameter) -> ParamInfo {
  match param {
    Positional(binder~, ty~) =>
      { name: binder.name, type_name: type_to_string(ty) }
    Labelled(binder~, ty~) =>
      { name: binder.name, type_name: type_to_string(ty) }
    Optional(binder~, ty~, ..) =>
      { name: binder.name, type_name: type_to_string(ty) }
    QuestionOptional(binder~, ty~) =>
      { name: binder.name, type_name: type_to_string(ty) }
    DiscardPositional(ty~, ..) =>
      { name: "_", type_name: type_to_string(ty) }
  }
}

///|
fn process_type_def(
  type_decl : @syntax.TypeDecl,
  file_name : String,
  world_configs : Array[WorldConfigInfo]
) -> Unit {
  walk_attrs_for_world(type_decl.attrs, type_decl, file_name, world_configs)
}

///|
fn walk_attrs_for_world(
  attrs : @list.List[@attribute.Attribute],
  type_decl : @syntax.TypeDecl,
  file_name : String,
  world_configs : Array[WorldConfigInfo]
) -> Unit {
  match attrs {
    More(attr, tail~) => {
      match extract_world_attr(attr) {
        Some(init_fn) => {
          let info : WorldConfigInfo = {
            type_name: type_decl.tycon,
            init_fn,
            source_file: file_name,
            line: type_decl.tycon_loc.start.lnum,
          }
          world_configs.push(info)
        }
        None => ()
      }
      walk_attrs_for_world(tail, type_decl, file_name, world_configs)
    }
    Empty => ()
  }
}

///|
/// Extract world config from a moonspec.world attribute.
/// Returns:
///   None - not a moonspec.world attr
///   Some(None) - moonspec.world with no init
///   Some(Some(init)) - moonspec.world with init fn
fn extract_world_attr(
  attr : @attribute.Attribute
) -> String?? {
  match attr.parsed {
    Some(Apply(id, props)) => {
      guard id.qual == Some("moonspec") && id.name == "world" else {
        return None
      }
      let init_fn = extract_init_from_props(props)
      Some(init_fn)
    }
    Some(Ident(id)) => {
      guard id.qual == Some("moonspec") && id.name == "world" else {
        return None
      }
      Some(None)
    }
    _ => None
  }
}

///|
fn extract_init_from_props(
  props : @list.List[@attribute.Prop]
) -> String? {
  match props {
    More(head, tail~) =>
      match head {
        Labeled("init", expr) => Some(expr_to_string(expr))
        _ => extract_init_from_props(tail)
      }
    Empty => None
  }
}

///|
fn expr_to_string(expr : @attribute.Expr) -> String {
  match expr {
    Ident(id) =>
      match id.qual {
        Some(q) => q + "::" + id.name
        None => id.name
      }
    String(s) => s
    Bool(b) => b.to_string()
    Apply(id, _) =>
      match id.qual {
        Some(q) => q + "::" + id.name
        None => id.name
      }
  }
}
