# Step Definitions

Step definitions connect Gherkin steps to MoonBit code. Each step in a `.feature`
file is matched against registered patterns, and the corresponding handler
function is executed.

This guide covers the World struct, step registration (both typed and
context-based), Cucumber Expressions, context and arguments, custom parameter
types, step libraries, data tables, doc strings, error handling, and the
experimental attribute-based approach.

---

## World Struct

The **World** is a struct that holds per-scenario state. moonspec creates a
fresh instance for each scenario, so scenarios are isolated from one another.

### Basic World with `derive(Default)`

```moonbit
struct CalcWorld {
  mut result : Int
} derive(Default)
```

The `derive(Default)` annotation auto-generates a constructor that
zero-initializes all fields. For `Int` that means `0`, for `String` it means
`""`, for `Array` it means `[]`, and so on.

### Custom Default Implementation

When you need non-trivial initial state, implement `Default` manually:

```moonbit
struct AppWorld {
  mut balance : Int
  mut currency : String
}

impl Default for AppWorld with default() {
  { balance: 1000, currency: "USD" }
}
```

### Reference Type Semantics

MoonBit structs are **reference types**. When closures capture `self` inside
`configure`, all step handlers share the same instance. Mutations made in one
step are immediately visible in subsequent steps within the same scenario:

```moonbit
impl @moonspec.World for CalcWorld with configure(self, setup) {
  // Given step mutates self.result
  setup.given1("a starting value of {int}", fn(n : Int) {
    self.result = n
  })
  // Then step reads the mutation from the Given step
  setup.then1("the value should be {int}", fn(expected : Int) {
    assert_eq!(self.result, expected)
  })
}
```

There is no need for shared pointers or explicit synchronization -- all handlers
for a single scenario operate on the same struct instance.

---

## Step Registration

Steps are registered inside the `World::configure` method, which receives a
`Setup` instance. moonspec offers two approaches: **typed step registration**
(recommended) and **context-based registration** (for advanced use cases).

### Typed Step Registration (Recommended)

Typed methods use an arity suffix to indicate how many parameters the handler
takes. Parameters are extracted and converted automatically via the
`FromStepArg` trait -- no manual pattern matching needed.

The naming convention is `keyword` + `arity`, e.g. `given0`, `when2`, `then1`.
Arities 0--22 are supported for all four keywords.

#### Zero-Argument Steps

```moonbit
setup.given0("an empty shopping cart", fn() {
  self.cart.clear()
})
```

#### Single-Argument Steps

```moonbit
setup.given1("a balance of {int}", fn(n : Int) {
  self.balance = n
})
```

#### Multi-Argument Steps

```moonbit
setup.when2("I add {int} and {int}", fn(a : Int, b : Int) {
  self.result = a + b
})

setup.when3("I add {string} with quantity {int} at price {int}", fn(
  name : String, qty : Int, price : Int,
) {
  self.cart.push({ name, quantity: qty, price })
})
```

#### Assertions in Then Steps

Handlers can raise errors for assertions. The `raise Error` is part of the
handler signature:

```moonbit
setup.then1("the result should be {int}", fn(expected : Int) {
  assert_eq!(self.result, expected)
})

setup.then0("the cart should be empty", fn() {
  assert_eq!(self.cart.length(), 0)
})
```

#### Accessing Ctx with `_ctx` Variants

When you need the full `Ctx` (for scenario metadata, step info, or
attachments), use the `_ctx` variant. `Ctx` is always the **last** parameter:

```moonbit
setup.given1_ctx("a user named {string}", fn(name : String, ctx : Ctx) {
  self.user = name
  self.feature = ctx.scenario().feature_name
})

setup.given0_ctx("an empty cart", fn(ctx : Ctx) {
  self.cart.clear()
  println("Starting: " + ctx.scenario().scenario_name)
})
```

#### Supported Types

The `FromStepArg` trait maps `StepValue` variants to MoonBit types:

| Handler Type       | StepValue Variants                            | Expression Types               |
|--------------------|-----------------------------------------------|--------------------------------|
| `Int`              | `IntVal`                                      | `{int}`                        |
| `Double`           | `FloatVal`, `DoubleVal`                       | `{float}`, `{double}`         |
| `Int64`            | `LongVal`                                     | `{long}`                       |
| `Byte`             | `ByteVal`                                     | `{byte}`                       |
| `String`           | `StringVal`, `WordVal`, `AnonymousVal`        | `{string}`, `{word}`, `{}`    |
| `BigInt`           | `BigIntegerVal`                               | `{biginteger}`                 |
| `@decimal.Decimal` | `BigDecimalVal`                               | `{bigdecimal}`                 |
| `@any.Any`         | `CustomVal`                                   | custom types                   |
| `DataTable`        | `DataTableVal`                                | data tables                    |
| `DocString`        | `DocStringVal`                                | doc strings                    |

Type mismatches raise a descriptive error at runtime.

#### Keyword Summary

All four keywords follow the same pattern:

```moonbit
setup.given0("...", fn() { ... })        // Given
setup.when1("...", fn(a : Int) { ... })  // When
setup.then2("...", fn(a : String, b : Int) { ... })  // Then
setup.step0("...", fn() { ... })         // Step (matches any keyword)
```

### Context-Based Registration (Advanced)

The original `setup.given(pattern, fn(ctx) { ... })` form gives full access
to the `Ctx` object. Use this when you need manual control over argument
extraction or when the typed API doesn't fit your use case:

```moonbit
setup.given("a balance of {int}", fn(ctx) {
  match ctx[0] {
    { value: IntVal(n), .. } => self.balance = n
    _ => ()
  }
})
setup.when("they log in", fn(_ctx) { self.logged_in = true })
setup.then("the result should be {int}", fn(ctx) raise {
  match ctx[0] {
    { value: IntVal(expected), .. } => assert_eq(self.result, expected)
    _ => ()
  }
})
setup.step("the system is ready", fn(_ctx) { () }) // matches any keyword
```

Context-based handlers have the signature `(Ctx) -> Unit raise Error`.

---

## Cucumber Expressions

moonspec uses [Cucumber Expressions](https://github.com/cucumber/cucumber-expressions)
to match step text and extract typed parameters. The following built-in
parameter types are supported:

| Parameter      | StepValue Variant              | Example Pattern             |
|----------------|--------------------------------|-----------------------------|
| `{int}`        | `IntVal(Int)`                  | `"I have {int} items"`      |
| `{float}`      | `FloatVal(Double)`             | `"priced at {float}"`       |
| `{double}`     | `DoubleVal(Double)`            | `"ratio is {double}"`       |
| `{long}`       | `LongVal(Int64)`               | `"id is {long}"`            |
| `{byte}`       | `ByteVal(Byte)`                | `"byte {byte}"`             |
| `{short}`      | `ShortVal(Int)`                | `"port {short}"`            |
| `{bigdecimal}` | `BigDecimalVal(@decimal.Decimal)` | `"amount {bigdecimal}"`  |
| `{biginteger}` | `BigIntegerVal(BigInt)`        | `"value {biginteger}"`      |
| `{string}`     | `StringVal(String)`            | `"named {string}"`          |
| `{word}`       | `WordVal(String)`              | `"as {word}"`               |
| custom         | `CustomVal(@any.Any)`          | user-defined                |

The difference between `{string}` and `{word}`:
- `{string}` matches text enclosed in double quotes (e.g., `"Alice"`)
- `{word}` matches a single unquoted word with no spaces (e.g., `active`)

---

## Ctx and StepArg

When a step handler is called, it receives a `Ctx` object that provides access
to the matched arguments and metadata about the running scenario and step.

### Accessing Arguments

Each captured parameter is a `StepArg` with two fields:

```moonbit
pub struct StepArg {
  value : StepValue   // The typed, pattern-matchable value
  raw : String        // The original text from the feature file
}
```

Access arguments by index using bracket syntax or the `arg` method:

```moonbit
let first = ctx[0]     // bracket syntax
let second = ctx.arg(1) // explicit method
```

### Pattern Matching a Single Argument

```moonbit
setup.given("a balance of {int}", fn(ctx) {
  match ctx[0] {
    { value: IntVal(n), .. } => self.balance = n
    _ => ()
  }
})
```

The `..` in the pattern ignores the `raw` field.

### Pattern Matching Multiple Arguments

Use a tuple match for steps with multiple parameters:

```moonbit
setup.when("I transfer {int} to {string}", fn(ctx) {
  match (ctx[0], ctx[1]) {
    (
      { value: IntVal(amount), .. },
      { value: StringVal(recipient), .. },
    ) => {
      self.balance = self.balance - amount
      self.last_transfer_to = recipient
    }
    _ => ()
  }
})
```

### Other Ctx Methods

| Method          | Returns              | Description                           |
|-----------------|----------------------|---------------------------------------|
| `ctx.args()`    | `ArrayView[StepArg]` | View of all matched arguments         |
| `ctx.value(i)`  | `StepValue`          | Shorthand for `ctx[i].value`          |
| `ctx.scenario()` | `ScenarioInfo`      | Feature name, scenario name, and tags |
| `ctx.step()`    | `StepInfo`           | Current step keyword and text         |

`ScenarioInfo` contains:

```moonbit
pub struct ScenarioInfo {
  feature_name : String
  scenario_name : String
  tags : Array[String]
}
```

`StepInfo` contains:

```moonbit
pub struct StepInfo {
  keyword : String
  text : String
}
```

---

## Custom Parameter Types

You can define custom parameter types that match specific patterns in step text.

### Simple Custom Type (String Matching)

Use `add_param_type_strings` to register a custom type with string regex
patterns. This is the most common approach since it does not require importing
the `cucumber-expressions` package directly:

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.add_param_type_strings("color", ["red|blue|green"])
  setup.given("I pick a {color} cucumber", fn(ctx) {
    match ctx[0] {
      { value: CustomVal(any), .. } => {
        let color : String = any.to()
        self.selected_color = color
      }
      _ => ()
    }
  })
}
```

Custom parameter values arrive as `CustomVal(@any.Any)`. Use `any.to()` to
unbox them to the expected type.

### Custom Type with RegexPattern

If you need to use `@cucumber_expressions.RegexPattern` directly:

```moonbit
setup.add_param_type("color", [
  @cucumber_expressions.RegexPattern("red|blue|green"),
])
```

### Custom Type with Transformer

A transformer converts the matched text into a specific value. This is useful
when you want automatic type conversion:

```moonbit
setup.add_param_type_strings(
  "upper",
  ["\\w+"],
  transformer=@cucumber_expressions.Transformer::new(fn(groups) {
    @cucumber_expressions.ParamValue::CustomVal(
      @any.of(groups[0][:].to_upper().to_string()),
    )
  }),
)

setup.given("I say {upper}", fn(ctx) {
  match ctx[0] {
    { value: CustomVal(any), raw, .. } => {
      let v : String = any.to()  // "HELLO" (transformed)
      // raw is "hello" (original text)
    }
    _ => ()
  }
})
```

The transformer receives an array of matched groups and must return a
`@cucumber_expressions.ParamValue`. Wrap the result with
`@cucumber_expressions.ParamValue::CustomVal(@any.of(value))` for custom types.

---

## StepLibrary Trait

For larger projects, you can organize step definitions into composable groups
using the `StepLibrary` trait. This keeps step definitions modular and
reusable.

### Defining a Step Library

```moonbit
struct CartSteps {
  world : EcomWorld
}

fn CartSteps::new(world : EcomWorld) -> CartSteps {
  { world, }
}

impl @moonspec.StepLibrary for CartSteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::given0("an empty shopping cart", fn() {
      self.world.cart.clear()
    }),
    @moonspec.StepDef::when3(
      "I add {string} with quantity {int} at price {int}",
      fn(name : String, qty : Int, price : Int) {
        self.world.cart.push({ name, quantity: qty, price })
      },
    ),
    @moonspec.StepDef::then0("the cart should be empty", fn() {
      assert_eq!(self.world.cart.length(), 0)
    }),
  ]
  defs[:]
}
```

### StepDef Constructors

`StepDef` provides typed arity-suffixed constructors that mirror the `Setup`
methods, plus the original context-based constructors:

**Typed (recommended):**

- `StepDef::given0(pattern, handler)` through `StepDef::given22(pattern, handler)`
- Same for `when`, `then`, `step`
- `_ctx` variants: `StepDef::given0_ctx(pattern, handler)` etc.

**Context-based (advanced):**

- `StepDef::given(pattern, handler)` -- Given keyword
- `StepDef::when(pattern, handler)` -- When keyword
- `StepDef::then(pattern, handler)` -- Then keyword
- `StepDef::step(pattern, handler)` -- Any keyword

All constructors accept an optional `source? : StepSource` parameter for
source location tracking.

Each returns a `StepDef` value. The `steps` method must return an
`ArrayView[StepDef]`, so end with `defs[:]` to create a view from the array.

### Composing Libraries in the World

```moonbit
struct EcomWorld {
  cart : Array[CartItem]
  inventory : Map[String, Int]
  mut order_total : Int
} derive(Default)

impl @moonspec.World for EcomWorld with configure(self, setup) {
  setup.use_library(CartSteps::new(self))
  setup.use_library(InventorySteps::new(self))
  setup.use_library(CheckoutSteps::new(self))
}
```

Each library struct holds a reference to the world, so all libraries share the
same state through MoonBit's reference semantics.

---

## Data Tables

Gherkin data tables are passed to step handlers as the **last argument** with
type `DataTableVal(DataTable)`.

### Feature File

```gherkin
Scenario: Users
  Given the following users
    | name  | age |
    | Alice | 30  |
    | Bob   | 25  |
  Then there should be 2 users
```

### Step Handler

Using the typed API, declare the parameter as `DataTable`:

```moonbit
setup.given1("the following users", fn(table : DataTable) {
  self.users = table.as_maps()
})
```

Or with the context-based API:

```moonbit
setup.given("the following users", fn(ctx) {
  match ctx[0] {
    { value: DataTableVal(table), .. } =>
      self.users = table.as_maps()
    _ => ()
  }
})
```

### DataTable API

| Method        | Returns                       | Description                                          |
|---------------|-------------------------------|------------------------------------------------------|
| `rows()`      | `Rows`                        | All rows including the header row                    |
| `columns()`   | `Columns`                     | Column metadata derived from the header row          |
| `as_maps()`   | `Array[Map[String, String]]`  | Data rows (excluding header) as column-keyed maps    |
| `row_count()`  | `Int`                        | Total number of rows (including header)              |
| `col_count()`  | `Int`                        | Number of columns                                    |

**Row access:**

```moonbit
let first_data_row = table.rows().get(1)        // index 0 is the header
let cell_value = first_data_row.cells.get(0)     // first cell as String
```

**Column access:**

```moonbit
let cols = table.columns()
let name_col = cols.find("name")  // returns Column?
match name_col {
  Some(col) => {
    let idx = col.index  // column index for cell lookup
  }
  None => ()
}
```

**Map-based access** (most common):

```moonbit
let maps = table.as_maps()
// maps = [{"name": "Alice", "age": "30"}, {"name": "Bob", "age": "25"}]
for row in maps {
  let name = row["name"]
  let age = row["age"]
}
```

Note that `as_maps()` skips the header row and returns only data rows. All cell
values are strings.

---

## Doc Strings

Gherkin doc strings are passed to step handlers as the **last argument** with
type `DocStringVal(DocString)`.

### Feature File

```gherkin
Scenario: JSON payload
  Given a JSON payload
    """json
    {"key": "value"}
    """
  Then the payload should contain "key"
  Then the media type should be "json"
```

### Step Handler

Using the typed API, declare the parameter as `DocString`:

```moonbit
setup.given1("a JSON payload", fn(doc : DocString) {
  self.payload = doc.content        // The text content
  self.media = doc.media_type       // Optional media type (String?)
})
```

Or with the context-based API:

```moonbit
setup.given("a JSON payload", fn(ctx) {
  match ctx[0] {
    { value: DocStringVal(doc), .. } => {
      self.payload = doc.content
      self.media = doc.media_type
    }
    _ => ()
  }
})
```

### DocString Fields

| Field        | Type      | Description                                       |
|--------------|-----------|---------------------------------------------------|
| `content`    | `String`  | The text between the triple-quote delimiters       |
| `media_type` | `String?` | The optional media type annotation (e.g., `json`)  |

---

## Error Handling in Steps

### Assertions in Then Steps

Then-step handlers typically use assertions that can raise errors:

```moonbit
setup.then1("the balance should be {int}", fn(expected : Int) {
  assert_eq!(self.balance, expected)
})
```

MoonBit provides several built-in assertion functions:

- `assert_eq!(actual, expected)` -- asserts equality
- `assert_true!(condition)` -- asserts a boolean is true
- `fail!("message")` -- unconditionally fails with a message

### What Happens When a Step Fails

When a step handler raises an error:

1. The current step is marked as **failed**.
2. All remaining steps in the scenario are marked as **skipped**.
3. The scenario is marked as **failed**.
4. After-hooks still run (receiving the failure information via `HookResult`).
5. Execution continues with the next scenario.

### Failing Explicitly

Use `fail!()` to signal a failure with a descriptive message:

```moonbit
setup.then0("the item should be in stock", fn() {
  match self.inventory.get(self.last_checked_item) {
    Some(stock) => assert_true!(stock > 0)
    None => fail!("Item not found in inventory")
  }
})
```

---

## Attribute-Based Step Registration (Experimental)

moonspec provides an alternative, attribute-based approach to step registration.
Instead of writing closures inside `configure`, you annotate standalone
functions with `#moonspec.given`, `#moonspec.when`, and `#moonspec.then`
attributes. A code generator then produces the `configure` implementation.

### Marking the World Struct

Annotate your world struct with `#moonspec.world`:

```moonbit
#moonspec.world
struct TodoWorld {
  todos : Array[TodoItem]
} derive(Default)
```

### Writing Step Functions

Each step function takes the world struct as its first parameter, followed by
typed parameters extracted from the Cucumber Expression. The parameter types
are inferred from the function signature:

```moonbit
#moonspec.given("a todo list")
fn given_todo_list(world : TodoWorld) -> Unit {
  world.todos.clear()
}

#moonspec.when("I add a todo {string}")
fn when_add_todo(world : TodoWorld, title : String) -> Unit {
  world.todos.push(TodoItem::{ title, completed: false })
}

#moonspec.then("I should have {int} todos")
fn then_todo_count(world : TodoWorld, count : Int) -> Unit raise Error {
  assert_eq(world.todos.length(), count)
}
```

Note the differences from the closure-based approach:

- Parameters are **typed MoonBit values** (e.g., `String`, `Int`) instead of
  `StepArg` objects. The code generator handles the pattern matching.
- The world struct is the first explicit parameter instead of a captured `self`.
- Functions that need assertions must declare `raise Error` in their signature.

### Multiple Parameters

Functions can accept multiple extracted parameters:

```moonbit
#moonspec.given("I have {int} completed and {int} pending todos")
fn given_mixed_todos(world : TodoWorld, completed : Int, pending : Int) -> Unit {
  world.todos.clear()
  for i = 0; i < completed; i = i + 1 {
    world.todos.push(TodoItem::{ title: "completed-" + i.to_string(), completed: true })
  }
  for i = 0; i < pending; i = i + 1 {
    world.todos.push(TodoItem::{ title: "pending-" + i.to_string(), completed: false })
  }
}
```

### Generating the Configure Implementation

Run the code generator to produce the `World::configure` implementation:

```bash
moonspec gen steps
```

This scans your source files for `#moonspec.world` and `#moonspec.given/when/then`
attributes, then generates a file containing the `impl @moonspec.World for
TodoWorld with configure(self, setup) { ... }` block. The generated code wires
up each annotated function with the appropriate `setup.given/when/then` call
and argument extraction logic.

The generated file includes a hash comment so that `moonspec gen steps` can
detect when regeneration is needed.

### When to Use Each Approach

**Typed step registration** (`setup.given1`, `StepDef::when2`, etc.) is the
recommended default. It handles argument extraction automatically and produces
clean, readable handlers.

**Context-based registration** (`setup.given("...", fn(ctx) { ... })`) is
useful when you need manual control over argument extraction or want to
access `Ctx` without using the `_ctx` variants.

**Attribute-based registration** (`#moonspec.given`, etc.) works well when
you prefer standalone functions over closures and a flatter file structure.
The code generator handles all the wiring.

For a complete working example, see the
[todolist example](https://github.com/moonrockz/moonspec/tree/main/examples/todolist).
