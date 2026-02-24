# DocString & DataTable Step Arguments Design

## Goal

Support DocString and DataTable Gherkin step arguments in moonspec, exposing them to step handlers as typed, immutable values appended to the existing `Array[StepArg]`.

## Background

Gherkin steps can have block arguments attached — either a DocString (multi-line text with optional media type) or a DataTable (rows of cells). The gherkin parser and cucumber-messages pickle format already support both. The gap is in moonspec's compiler, executor, and type system.

Related issues: moonspec-7og (DocString), moonspec-1ke (DataTable).

## Architecture

**Approach: Append to `Array[StepArg]`** — follows cucumber-jvm, cucumber-ruby, and cucumber-js conventions. When a step has an attached DocString or DataTable, it appears as the last element of the `args` array passed to the handler. No handler signature change, no breaking change.

## New Types

All new types live in `src/core/types.mbt`. Mutable `Array` fields are never exposed directly — each collection is wrapped in a dedicated type that exposes only `ArrayView`, indexed access, and length.

### Cells

Wraps a row's cell values. Prevents mutation of the underlying array.

```moonbit
pub(readonly) struct Cells {
  priv data : Array[String]
  fn new(data : Array[String]) -> Cells
} derive(Show, Eq)

fn Cells::new(data : Array[String]) -> Cells {
  { data }
}

pub fn Cells::values(self : Cells) -> ArrayView[String] { self.data[:] }
pub fn Cells::get(self : Cells, index : Int) -> String { self.data[index] }
pub fn Cells::length(self : Cells) -> Int { self.data.length() }
```

### Row

A single row in a DataTable. The `cells` field is `Cells` (immutable wrapper).

```moonbit
pub(readonly) struct Row {
  cells : Cells
  fn new(cells : Array[String]) -> Row
} derive(Show, Eq)

fn Row::new(cells : Array[String]) -> Row {
  { cells: Cells(cells) }
}
```

### Rows

Wraps the array of rows. Prevents mutation of the row collection.

```moonbit
pub(readonly) struct Rows {
  priv data : Array[Row]
  fn new(data : Array[Row]) -> Rows
} derive(Show, Eq)

fn Rows::new(data : Array[Row]) -> Rows {
  { data }
}

pub fn Rows::values(self : Rows) -> ArrayView[Row] { self.data[:] }
pub fn Rows::get(self : Rows, index : Int) -> Row { self.data[index] }
pub fn Rows::length(self : Rows) -> Int { self.data.length() }
```

### Column

A named column derived from the header row.

```moonbit
pub(readonly) struct Column {
  name : String
  index : Int
  fn new(name~ : String, index~ : Int) -> Column
} derive(Show, Eq)

fn Column::new(name~ : String, index~ : Int) -> Column {
  { name, index }
}
```

### Columns

Wraps the array of columns. Provides lookup by name.

```moonbit
pub(readonly) struct Columns {
  priv data : Array[Column]
  fn new(data : Array[Column]) -> Columns
} derive(Show, Eq)

fn Columns::new(data : Array[Column]) -> Columns {
  { data }
}

pub fn Columns::values(self : Columns) -> ArrayView[Column] { self.data[:] }
pub fn Columns::get(self : Columns, index : Int) -> Column { self.data[index] }
pub fn Columns::length(self : Columns) -> Int { self.data.length() }
pub fn Columns::find(self : Columns, name : String) -> Column? {
  for col in self.data {
    if col.name == name { return Some(col) }
  }
  None
}
```

### DataTable

Constructed from raw rows. First row is treated as headers (columns). All rows (including the header row) are stored.

```moonbit
pub(readonly) struct DataTable {
  rows : Rows
  columns : Columns
  fn new(raw_rows : Array[Array[String]]) -> DataTable
} derive(Show, Eq)

fn DataTable::new(raw_rows : Array[Array[String]]) -> DataTable {
  let columns = if raw_rows.length() > 0 {
    Columns(raw_rows[0].mapi(fn(i, name) { Column(name~, index=i) }))
  } else {
    Columns([])
  }
  let rows = Rows(raw_rows.map(fn(cells) { Row(cells) }))
  { rows, columns }
}

pub fn DataTable::as_maps(self : DataTable) -> Array[Map[String, String]]
pub fn DataTable::row_count(self : DataTable) -> Int
pub fn DataTable::col_count(self : DataTable) -> Int
```

`as_maps()` skips the header row and returns one `Map[String, String]` per data row, keyed by column names.

### DocString

Multi-line text with optional media type (e.g., `"""json`).

```moonbit
pub(readonly) struct DocString {
  content : String
  media_type : String?
  fn new(content~ : String, media_type? : String) -> DocString
} derive(Show, Eq)

fn DocString::new(content~ : String, media_type? : String) -> DocString {
  { content, media_type }
}
```

### StepValue Variants

Two new variants added to the existing enum:

```moonbit
pub(all) enum StepValue {
  // ... existing 12 variants ...
  DocStringVal(DocString)
  DataTableVal(DataTable)
}
```

## Compiler Changes

**File:** `src/runner/compiler.mbt`

`compile_step()` currently hardcodes `argument: None`. Change to extract the gherkin step's `argument` field and compile it into `PickleStepArgument`:

- `StepArgument::DocString(ds)` → `PickleStepArgument { docString: Some(PickleDocString { content: ds.content, mediaType: ds.media_type }), dataTable: None }`
- `StepArgument::DataTable(dt)` → `PickleStepArgument { docString: None, dataTable: Some(PickleTable { rows: ... }) }`

For Scenario Outlines, apply `<placeholder>` substitution inside DocString content and DataTable cell values.

## Executor Changes

**File:** `src/runner/executor.mbt`

After `registry.find_match(step.text)` returns `Matched(step_def, args)`:

1. Check `step.argument` for a `PickleStepArgument`
2. If present, convert to `StepArg` with the appropriate `StepValue` variant
3. Append as the last element of `args`
4. Call `(step_def.handler.0)(args)` as before

## Handler Usage

### DocString

```gherkin
Given a JSON payload
  """json
  {"name": "Alice", "age": 30}
  """
```

```moonbit
setup.given("a JSON payload", fn(args) {
  match args[0] {
    { value: DocStringVal(doc), .. } => {
      let content = doc.content         // "{\"name\": \"Alice\", \"age\": 30}"
      let media = doc.media_type        // Some("json")
    }
    _ => ()
  }
})
```

### DataTable

```gherkin
Given the following users
  | name  | age |
  | Alice | 30  |
  | Bob   | 25  |
```

```moonbit
setup.given("the following users", fn(args) {
  match args[0] {
    { value: DataTableVal(table), .. } => {
      for row in table.rows.values() {       // ArrayView[Row]
        let name = row.cells.get(0)          // "Alice"
      }
      let maps = table.as_maps()             // [{name: "Alice", age: "30"}, ...]
      let col = table.columns.find("name")   // Some(Column { name: "name", index: 0 })
    }
    _ => ()
  }
})
```

### Mixed: text params + block argument

```gherkin
When I POST to "/api/users"
  """json
  {"name": "Alice"}
  """
```

```moonbit
setup.when("I POST to {string}", fn(args) {
  // args[0] = { value: StringVal("/api/users"), .. }
  // args[1] = { value: DocStringVal(...), .. }
})
```

The block argument is always the last element of `args`.

## Non-Goals

- DocString/DataTable in codegen output (generated tests don't inline block arguments — they load from `.feature` files)
- Typed DataTable cell parsing (cells are always strings — users parse as needed)
- DataTable diff/comparison utilities (can add later)

## No Breaking Changes

- Handler signature stays `(Array[StepArg]) -> Unit raise Error`
- Existing handlers don't receive new arg types unless the `.feature` file has block arguments
- New `StepValue` variants are additive
