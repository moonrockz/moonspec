# DocString & DataTable Step Arguments Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add DocString and DataTable support to moonspec step handlers, exposing Gherkin block arguments as typed, immutable `StepArg` values.

**Architecture:** New wrapper types (`Cells`, `Row`, `Rows`, `Column`, `Columns`, `DataTable`, `DocString`) in `src/core/types.mbt` with `pub(readonly)` structs and struct constructors. Two new `StepValue` variants (`DocStringVal`, `DataTableVal`). Compiler populates `PickleStepArgument` from gherkin AST. Executor appends block argument as last `StepArg` before calling handler. No handler signature change.

**Tech Stack:** MoonBit, moonspec core/runner packages, gherkin parser (moonrockz/gherkin), cucumber-messages (moonrockz/cucumber-messages)

**Test command:** `mise run test:unit` (runs `moon test --target js`)

**Design doc:** `docs/plans/2026-02-24-docstring-datatable-design.md`

---

### Task 1: Add Cells wrapper type

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "Cells constructor and accessors" {
  let cells = Cells(["Alice", "30", "admin"])
  assert_eq(cells.length(), 3)
  assert_eq(cells.get(0), "Alice")
  assert_eq(cells.get(2), "admin")
  let view = cells.values()
  assert_eq(view.length(), 3)
  assert_eq(view[1], "30")
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `Cells` type not defined

**Step 3: Write minimal implementation**

Add to `src/core/types.mbt` (after the existing `StepInfo` struct at the end of the file):

```moonbit
///|
/// Immutable wrapper around an array of cell values in a DataTable row.
pub(readonly) struct Cells {
  priv data : Array[String]
  fn new(data : Array[String]) -> Cells
} derive(Show, Eq)

///|
fn Cells::new(data : Array[String]) -> Cells {
  { data }
}

///|
/// Return an immutable view of the cell values.
pub fn Cells::values(self : Cells) -> ArrayView[String] {
  self.data[:]
}

///|
/// Return the cell value at the given index.
pub fn Cells::get(self : Cells, index : Int) -> String {
  self.data[index]
}

///|
/// Return the number of cells.
pub fn Cells::length(self : Cells) -> Int {
  self.data.length()
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add Cells immutable wrapper type"
```

---

### Task 2: Add Row type

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "Row constructor wraps cells" {
  let row = Row(["Alice", "30"])
  assert_eq(row.cells.length(), 2)
  assert_eq(row.cells.get(0), "Alice")
  assert_eq(row.cells.get(1), "30")
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `Row` type not defined

**Step 3: Write minimal implementation**

Add to `src/core/types.mbt` (after `Cells`):

```moonbit
///|
/// A single row in a DataTable, wrapping its cell values in an immutable Cells.
pub(readonly) struct Row {
  cells : Cells
  fn new(cells : Array[String]) -> Row
} derive(Show, Eq)

///|
fn Row::new(cells : Array[String]) -> Row {
  { cells: Cells(cells) }
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add Row type with Cells wrapper"
```

---

### Task 3: Add Rows wrapper type

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "Rows constructor and accessors" {
  let rows = Rows([Row(["a", "b"]), Row(["c", "d"])])
  assert_eq(rows.length(), 2)
  assert_eq(rows.get(0).cells.get(0), "a")
  assert_eq(rows.get(1).cells.get(1), "d")
  let view = rows.values()
  assert_eq(view.length(), 2)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `Rows` type not defined

**Step 3: Write minimal implementation**

Add to `src/core/types.mbt` (after `Row`):

```moonbit
///|
/// Immutable wrapper around an array of rows in a DataTable.
pub(readonly) struct Rows {
  priv data : Array[Row]
  fn new(data : Array[Row]) -> Rows
} derive(Show, Eq)

///|
fn Rows::new(data : Array[Row]) -> Rows {
  { data }
}

///|
/// Return an immutable view of the rows.
pub fn Rows::values(self : Rows) -> ArrayView[Row] {
  self.data[:]
}

///|
/// Return the row at the given index.
pub fn Rows::get(self : Rows, index : Int) -> Row {
  self.data[index]
}

///|
/// Return the number of rows.
pub fn Rows::length(self : Rows) -> Int {
  self.data.length()
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add Rows immutable wrapper type"
```

---

### Task 4: Add Column and Columns types

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "Column constructor" {
  let col = Column(name="age", index=1)
  assert_eq(col.name, "age")
  assert_eq(col.index, 1)
}

///|
test "Columns accessors and find" {
  let cols = Columns([Column(name="name", index=0), Column(name="age", index=1)])
  assert_eq(cols.length(), 2)
  assert_eq(cols.get(0).name, "name")
  let view = cols.values()
  assert_eq(view.length(), 2)
  match cols.find("age") {
    Some(c) => {
      assert_eq(c.name, "age")
      assert_eq(c.index, 1)
    }
    None => fail("expected to find 'age'")
  }
  assert_true(cols.find("missing") is None)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `Column` and `Columns` types not defined

**Step 3: Write minimal implementation**

Add to `src/core/types.mbt` (after `Rows`):

```moonbit
///|
/// A named column in a DataTable, derived from the header row.
pub(readonly) struct Column {
  name : String
  index : Int
  fn new(name~ : String, index~ : Int) -> Column
} derive(Show, Eq)

///|
fn Column::new(name~ : String, index~ : Int) -> Column {
  { name, index }
}

///|
/// Immutable wrapper around an array of columns in a DataTable.
pub(readonly) struct Columns {
  priv data : Array[Column]
  fn new(data : Array[Column]) -> Columns
} derive(Show, Eq)

///|
fn Columns::new(data : Array[Column]) -> Columns {
  { data }
}

///|
/// Return an immutable view of the columns.
pub fn Columns::values(self : Columns) -> ArrayView[Column] {
  self.data[:]
}

///|
/// Return the column at the given index.
pub fn Columns::get(self : Columns, index : Int) -> Column {
  self.data[index]
}

///|
/// Return the number of columns.
pub fn Columns::length(self : Columns) -> Int {
  self.data.length()
}

///|
/// Find a column by name, returning None if not found.
pub fn Columns::find(self : Columns, name : String) -> Column? {
  for col in self.data {
    if col.name == name {
      return Some(col)
    }
  }
  None
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add Column and Columns immutable wrapper types"
```

---

### Task 5: Add DataTable type

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "DataTable constructor derives columns from header row" {
  let table = DataTable([["name", "age"], ["Alice", "30"], ["Bob", "25"]])
  assert_eq(table.row_count(), 3)
  assert_eq(table.col_count(), 2)
  assert_eq(table.columns.get(0).name, "name")
  assert_eq(table.columns.get(1).name, "age")
  assert_eq(table.columns.get(1).index, 1)
  assert_eq(table.rows.get(1).cells.get(0), "Alice")
  assert_eq(table.rows.get(2).cells.get(1), "25")
}

///|
test "DataTable.as_maps skips header row" {
  let table = DataTable([["name", "age"], ["Alice", "30"], ["Bob", "25"]])
  let maps = table.as_maps()
  assert_eq(maps.length(), 2)
  assert_eq(maps[0]["name"], Some("Alice"))
  assert_eq(maps[0]["age"], Some("30"))
  assert_eq(maps[1]["name"], Some("Bob"))
  assert_eq(maps[1]["age"], Some("25"))
}

///|
test "DataTable empty" {
  let table = DataTable([])
  assert_eq(table.row_count(), 0)
  assert_eq(table.col_count(), 0)
  assert_eq(table.as_maps().length(), 0)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `DataTable` type not defined

**Step 3: Write minimal implementation**

Add to `src/core/types.mbt` (after `Columns`):

```moonbit
///|
/// A DataTable from a Gherkin step. First row is treated as column headers.
/// All data is immutable — rows and columns are wrapped in Rows/Columns types.
pub(readonly) struct DataTable {
  rows : Rows
  columns : Columns
  fn new(raw_rows : Array[Array[String]]) -> DataTable
} derive(Show, Eq)

///|
fn DataTable::new(raw_rows : Array[Array[String]]) -> DataTable {
  let columns = if raw_rows.length() > 0 {
    Columns(
      raw_rows[0].mapi(fn(i, name) { Column(name~, index=i) }),
    )
  } else {
    Columns([])
  }
  let rows = Rows(raw_rows.map(fn(cells) { Row(cells) }))
  { rows, columns }
}

///|
/// Return the total number of rows (including the header row).
pub fn DataTable::row_count(self : DataTable) -> Int {
  self.rows.length()
}

///|
/// Return the number of columns.
pub fn DataTable::col_count(self : DataTable) -> Int {
  self.columns.length()
}

///|
/// Convert data rows (excluding header) to an array of maps keyed by column name.
pub fn DataTable::as_maps(self : DataTable) -> Array[Map[String, String]] {
  let result : Array[Map[String, String]] = []
  if self.rows.length() <= 1 {
    return result
  }
  let headers = self.columns.values()
  for i = 1; i < self.rows.length(); i = i + 1 {
    let row = self.rows.get(i)
    let map : Map[String, String] = {}
    for j = 0; j < headers.length(); j = j + 1 {
      map[headers[j].name] = row.cells.get(j)
    }
    result.push(map)
  }
  result
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add DataTable type with as_maps convenience"
```

---

### Task 6: Add DocString type

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "DocString constructor with media type" {
  let doc = DocString(content="hello world", media_type="json")
  assert_eq(doc.content, "hello world")
  assert_eq(doc.media_type, Some("json"))
}

///|
test "DocString constructor without media type" {
  let doc = DocString(content="plain text")
  assert_eq(doc.content, "plain text")
  assert_eq(doc.media_type, None)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `DocString` type not defined

**Step 3: Write minimal implementation**

Add to `src/core/types.mbt` (after `DataTable`):

```moonbit
///|
/// A DocString from a Gherkin step — multi-line text with optional media type.
/// Media type is specified after the opening delimiter: `"""json`
pub(readonly) struct DocString {
  content : String
  media_type : String?
  fn new(content~ : String, media_type? : String) -> DocString
} derive(Show, Eq)

///|
fn DocString::new(content~ : String, media_type? : String) -> DocString {
  { content, media_type }
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add DocString type with optional media_type"
```

---

### Task 7: Add StepValue variants and update Show/Eq

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "StepArg with DocStringVal" {
  let doc = DocString(content="hello", media_type="json")
  let arg : StepArg = { value: DocStringVal(doc), raw: "" }
  match arg {
    { value: DocStringVal(d), .. } => {
      assert_eq(d.content, "hello")
      assert_eq(d.media_type, Some("json"))
    }
    _ => fail("expected DocStringVal")
  }
}

///|
test "StepArg with DataTableVal" {
  let table = DataTable([["name"], ["Alice"]])
  let arg : StepArg = { value: DataTableVal(table), raw: "" }
  match arg {
    { value: DataTableVal(t), .. } => {
      assert_eq(t.row_count(), 2)
      assert_eq(t.rows.get(1).cells.get(0), "Alice")
    }
    _ => fail("expected DataTableVal")
  }
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `DocStringVal` and `DataTableVal` variants not defined on `StepValue`

**Step 3: Write minimal implementation**

Modify `StepValue` enum in `src/core/types.mbt` — add two new variants at the end:

```moonbit
pub(all) enum StepValue {
  // ... existing 12 variants ...
  CustomVal(@any.Any)
  DocStringVal(DocString)
  DataTableVal(DataTable)
}
```

Add arms to the `Show` implementation:

```moonbit
DocStringVal(d) => {
  let mt = match d.media_type {
    Some(t) => t
    None => ""
  }
  logger.write_string("DocStringVal(media_type=\{mt})")
}
DataTableVal(t) => logger.write_string("DataTableVal(\{t.row_count()}x\{t.col_count()})")
```

Add arms to the `Eq` implementation:

```moonbit
(DocStringVal(a), DocStringVal(b)) => a == b
(DataTableVal(a), DataTableVal(b)) => a == b
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add DocStringVal and DataTableVal to StepValue enum"
```

---

### Task 8: Update re-exports in facade

**Files:**
- Modify: `src/lib.mbt`

**Step 1: Add new types to the `pub using @core` block**

In `src/lib.mbt`, add the new types to the existing `pub using @core` block:

```moonbit
pub using @core {
  // ... existing re-exports ...
  type StepInfo,
  type Cells,
  type Row,
  type Rows,
  type Column,
  type Columns,
  type DataTable,
  type DocString,
  type Setup,
  // ... rest unchanged ...
}
```

**Step 2: Run test to verify it compiles**

Run: `mise run test:unit`
Expected: PASS (no new tests needed — this is just re-exports)

**Step 3: Commit**

```bash
git add src/lib.mbt
git commit -m "feat: re-export DataTable and DocString types from facade"
```

---

### Task 9: Compile step arguments from gherkin AST to pickle

**Files:**
- Modify: `src/runner/compiler.mbt`
- Modify: `src/runner/compiler_wbtest.mbt`

**Step 1: Write the failing tests**

Add to `src/runner/compiler_wbtest.mbt`:

```moonbit
///|
test "compile_pickles: step with doc string" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://docstring",
    "Feature: DocString\n\n  Scenario: S1\n    Given a payload\n      \"\"\"\n      hello world\n      \"\"\"\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  assert_eq(pickles[0].steps.length(), 1)
  assert_true(pickles[0].steps[0].argument is Some(_))
  match pickles[0].steps[0].argument {
    Some(arg) => {
      assert_true(arg.docString is Some(_))
      match arg.docString {
        Some(ds) => assert_eq(ds.content, "hello world")
        None => fail("expected docString")
      }
    }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: step with doc string media type" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://docstring-mt",
    "Feature: DocString\n\n  Scenario: S1\n    Given a payload\n      \"\"\"json\n      {\"key\": \"value\"}\n      \"\"\"\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].argument {
    Some(arg) =>
      match arg.docString {
        Some(ds) => {
          assert_eq(ds.mediaType, Some("json"))
        }
        None => fail("expected docString")
      }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: step with data table" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://datatable",
    "Feature: DataTable\n\n  Scenario: S1\n    Given the following users\n      | name  | age |\n      | Alice | 30  |\n      | Bob   | 25  |\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  match pickles[0].steps[0].argument {
    Some(arg) => {
      assert_true(arg.dataTable is Some(_))
      match arg.dataTable {
        Some(dt) => {
          assert_eq(dt.rows.length(), 3) // header + 2 data rows
          assert_eq(dt.rows[0].cells[0].value, "name")
          assert_eq(dt.rows[1].cells[0].value, "Alice")
        }
        None => fail("expected dataTable")
      }
    }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: outline substitutes in doc string" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://outline-ds",
    "Feature: Outline DS\n\n  Scenario Outline: S1\n    Given a payload\n      \"\"\"\n      hello <name>\n      \"\"\"\n\n    Examples:\n      | name  |\n      | Alice |\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].argument {
    Some(arg) =>
      match arg.docString {
        Some(ds) => assert_eq(ds.content, "hello Alice")
        None => fail("expected docString")
      }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: outline substitutes in data table cells" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://outline-dt",
    "Feature: Outline DT\n\n  Scenario Outline: S1\n    Given the data\n      | col   |\n      | <val> |\n\n    Examples:\n      | val   |\n      | hello |\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].argument {
    Some(arg) =>
      match arg.dataTable {
        Some(dt) => assert_eq(dt.rows[1].cells[0].value, "hello")
        None => fail("expected dataTable")
      }
    None => fail("expected argument")
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — arguments are all `None`

**Step 3: Write minimal implementation**

Modify `compile_step` in `src/runner/compiler.mbt`. Replace `argument: None` (line 113) with argument compilation logic:

```moonbit
fn compile_step(
  step : @gherkin.Step,
  ids : IdCounter,
  last_type : @cucumber_messages.PickleStepType?,
  headers : Array[String],
  values : Array[String],
) -> (@cucumber_messages.PickleStep, @cucumber_messages.PickleStepType?) {
  let mapped = map_keyword_type(step.keyword_type)
  let effective_type = match mapped {
    Some(t) => Some(t)
    None => last_type
  }
  let mut text = step.text
  for i = 0; i < headers.length(); i = i + 1 {
    text = string_replace_compiler(text, "<" + headers[i] + ">", values[i])
  }
  let argument : @cucumber_messages.PickleStepArgument? = match step.argument {
    Some(@gherkin.StepArgument::DocString(ds)) => {
      let mut content = ds.content
      for i = 0; i < headers.length(); i = i + 1 {
        content = string_replace_compiler(content, "<" + headers[i] + ">", values[i])
      }
      Some({
        docString: Some({ content, mediaType: ds.media_type }),
        dataTable: None,
      })
    }
    Some(@gherkin.StepArgument::DataTable(dt)) => {
      let rows : Array[@cucumber_messages.PickleTableRow] = []
      for row in dt.rows {
        let cells : Array[@cucumber_messages.PickleTableCell] = []
        for cell in row.cells {
          let mut value = cell.value
          for i = 0; i < headers.length(); i = i + 1 {
            value = string_replace_compiler(value, "<" + headers[i] + ">", values[i])
          }
          cells.push({ value })
        }
        rows.push({ cells })
      }
      Some({ docString: None, dataTable: Some({ rows }) })
    }
    None => None
  }
  let pickle_step : @cucumber_messages.PickleStep = {
    id: ids.next_step_id(),
    text,
    astNodeIds: [step.id],
    type_: effective_type,
    argument,
  }
  (pickle_step, effective_type)
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/compiler.mbt src/runner/compiler_wbtest.mbt
git commit -m "feat(runner): compile DocString and DataTable from gherkin AST to pickle"
```

---

### Task 10: Executor appends block argument to step args

**Files:**
- Modify: `src/runner/executor.mbt`
- Modify: `src/runner/executor_wbtest.mbt`

**Step 1: Write the failing tests**

Add to `src/runner/executor_wbtest.mbt`:

```moonbit
///|
test "execute_scenario passes doc string as last arg" {
  let setup = @core.Setup::new()
  let mut received_content = ""
  let mut received_media_type : String? = None
  setup.given("a payload", fn(args) {
    match args[0] {
      { value: @core.StepValue::DocStringVal(doc), .. } => {
        received_content = doc.content
        received_media_type = doc.media_type
      }
      _ => ()
    }
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a payload",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: Some({
        docString: Some({ content: "hello world", mediaType: Some("json") }),
        dataTable: None,
      }),
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="DocString",
    pickle_id="p1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(received_content, "hello world")
  assert_eq(received_media_type, Some("json"))
}

///|
test "execute_scenario passes data table as last arg" {
  let setup = @core.Setup::new()
  let mut received_rows = 0
  let mut first_name = ""
  setup.given("the following users", fn(args) {
    match args[0] {
      { value: @core.StepValue::DataTableVal(table), .. } => {
        received_rows = table.row_count()
        first_name = table.rows.get(1).cells.get(0)
      }
      _ => ()
    }
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "the following users",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: Some({
        docString: None,
        dataTable: Some({
          rows: [
            { cells: [{ value: "name" }, { value: "age" }] },
            { cells: [{ value: "Alice" }, { value: "30" }] },
          ],
        }),
      }),
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="DataTable",
    pickle_id="p1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(received_rows, 2)
  assert_eq(first_name, "Alice")
}

///|
test "execute_scenario appends doc string after text params" {
  let setup = @core.Setup::new()
  let mut url = ""
  let mut body = ""
  setup.when("I POST to {string}", fn(args) {
    match args[0] {
      { value: @core.StepValue::StringVal(u), .. } => url = u
      _ => ()
    }
    match args[1] {
      { value: @core.StepValue::DocStringVal(doc), .. } => body = doc.content
      _ => ()
    }
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "I POST to \"http://example.com\"",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Action),
      argument: Some({
        docString: Some({ content: "{\"name\":\"Alice\"}", mediaType: Some("json") }),
        dataTable: None,
      }),
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Mixed",
    pickle_id="p1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(url, "http://example.com")
  assert_eq(body, "{\"name\":\"Alice\"}")
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — handler receives empty args (no DocString/DataTable appended)

**Step 3: Write minimal implementation**

In `src/runner/executor.mbt`, find the `Matched(step_def, args)` arm (around line 234). Add block argument extraction between the match and the handler call:

```moonbit
Matched(step_def, args) =>
  try {
    // Append block argument (DocString/DataTable) as last StepArg
    match step.argument {
      Some(arg) =>
        match (arg.docString, arg.dataTable) {
          (Some(ds), _) => {
            let doc = @core.DocString(
              content=ds.content,
              media_type?=ds.mediaType,
            )
            args.push({ value: DocStringVal(doc), raw: ds.content })
          }
          (_, Some(dt)) => {
            let raw_rows = dt.rows.map(fn(row) {
              row.cells.map(fn(cell) { cell.value })
            })
            let table = @core.DataTable(raw_rows)
            args.push({ value: DataTableVal(table), raw: "" })
          }
          _ => ()
        }
      None => ()
    }
    (step_def.handler.0)(args)
    (StepStatus::Passed, None)
  }
```

**Note:** The `args` array from `find_match` is already a fresh `Array[StepArg]` — appending to it is safe and doesn't leak state.

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/executor.mbt src/runner/executor_wbtest.mbt
git commit -m "feat(runner): append DocString/DataTable as last StepArg in executor"
```

---

### Task 11: End-to-end test with inline feature text

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt`

**Step 1: Write the e2e test**

Add to `src/runner/e2e_wbtest.mbt`:

```moonbit
///|
struct DocWorld {
  mut payload : String
  mut media : String?
  mut users : Array[Map[String, String]]
} derive(Default)

///|
impl @core.World for DocWorld with configure(self, setup) {
  setup.given("a JSON payload", fn(args) {
    match args[0] {
      { value: @core.StepValue::DocStringVal(doc), .. } => {
        self.payload = doc.content
        self.media = doc.media_type
      }
      _ => ()
    }
  })
  setup.given("the following users", fn(args) {
    match args[0] {
      { value: @core.StepValue::DataTableVal(table), .. } =>
        self.users = table.as_maps()
      _ => ()
    }
  })
  setup.then("the payload should be {string}", fn(args) raise {
    match args[0] {
      { value: @core.StepValue::StringVal(expected), .. } =>
        assert_eq(self.payload, expected)
      _ => ()
    }
  })
  setup.then("the media type should be {string}", fn(args) raise {
    match args[0] {
      { value: @core.StepValue::StringVal(expected), .. } =>
        assert_eq(self.media, Some(expected))
      _ => ()
    }
  })
  setup.then("there should be {int} users", fn(args) raise {
    match args[0] {
      { value: @core.StepValue::IntVal(n), .. } =>
        assert_eq(self.users.length(), n)
      _ => ()
    }
  })
  setup.then("user {int} should have name {string}", fn(args) raise {
    match (args[0], args[1]) {
      (
        { value: @core.StepValue::IntVal(idx), .. },
        { value: @core.StepValue::StringVal(name), .. },
      ) => assert_eq(self.users[idx - 1]["name"], Some(name))
      _ => ()
    }
  })
}

///|
async test "end-to-end: doc string with media type" {
  let content =
    #|Feature: DocString
    #|
    #|  Scenario: JSON payload
    #|    Given a JSON payload
    #|      """json
    #|      {"key": "value"}
    #|      """
    #|    Then the payload should be "{"key": "value"}"
    #|    Then the media type should be "json"
  let result = run(
    DocWorld::default,
    RunOptions([FeatureSource::Text("test://docstring", content)]),
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
}

///|
async test "end-to-end: data table" {
  let content =
    #|Feature: DataTable
    #|
    #|  Scenario: Users
    #|    Given the following users
    #|      | name  | age |
    #|      | Alice | 30  |
    #|      | Bob   | 25  |
    #|    Then there should be 2 users
    #|    Then user 1 should have name "Alice"
  let result = run(
    DocWorld::default,
    RunOptions([FeatureSource::Text("test://datatable", content)]),
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
}
```

**Step 2: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Note:** If the DocString content assertion for `{"key": "value"}` has quoting issues in MoonBit multi-line strings, adjust the expected string accordingly. The important thing is the content is received correctly.

**Step 3: Commit**

```bash
git add src/runner/e2e_wbtest.mbt
git commit -m "test: add end-to-end tests for DocString and DataTable"
```

---

### Task 12: Final cleanup — format, check, full test

**Files:**
- All modified files

**Step 1: Run formatter**

```bash
moon fmt
```

**Important:** `moon fmt` may strip the `as` keyword from `.pkg` import aliases. If any `.pkg` files are modified, revert them:

```bash
git checkout -- src/core/moon.pkg src/runner/moon.pkg
```

**Step 2: Run moon check**

```bash
moon check --target js
```

Expected: No errors

**Step 3: Run full test suite**

```bash
mise run test:unit
```

Expected: All tests pass (previous 192 + new tests added in this plan)

**Step 4: Commit formatting changes (if any)**

```bash
git add -u
git commit -m "style: apply moon fmt formatting"
```

---

Plan complete and saved to `docs/plans/2026-02-24-docstring-datatable-plan.md`. Two execution options:

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

Which approach?
