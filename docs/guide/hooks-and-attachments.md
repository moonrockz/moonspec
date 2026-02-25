# Hooks and Attachments

moonspec provides six lifecycle hooks that let you run code at specific points
during test execution, plus an attachment API for embedding files, logs, and
links into the Cucumber Messages output stream.

Both features are registered inside your World's `configure` method through the
`Setup` object.

---

## Lifecycle Hooks

Hooks are registered by calling methods on the `setup` parameter inside your
World's `configure` implementation. There are three levels -- run, scenario
(case), and step -- each with a "before" and "after" variant.

### Registering Hooks

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  // --- Run-level hooks ---
  setup.before_test_run(fn(ctx) {
    println("Suite starting")
  })
  setup.after_test_run(fn(ctx, result) {
    println("Suite finished")
  })

  // --- Scenario-level hooks ---
  setup.before_test_case(fn(ctx) {
    let name = ctx.scenario().scenario_name
    println("Starting scenario: " + name)
  })
  setup.after_test_case(fn(ctx, result) {
    let name = ctx.scenario().scenario_name
    println("Finished scenario: " + name)
  })

  // --- Step-level hooks ---
  setup.before_test_step(fn(ctx) {
    let text = ctx.step().text
    println("Running step: " + text)
  })
  setup.after_test_step(fn(ctx, result) {
    let text = ctx.step().text
    println("Completed step: " + text)
  })

  // Step definitions follow...
  setup.given("something", fn(_args) { () })
}
```

### Run-Level Hooks

```moonbit
setup.before_test_run(fn(ctx : @moonspec.RunHookCtx) { ... })
setup.after_test_run(fn(ctx : @moonspec.RunHookCtx, result : @moonspec.HookResult) { ... })
```

Run-level hooks execute once per test run. `before_test_run` fires before the
first scenario begins. `after_test_run` fires after the last scenario completes.

Use these for global setup and teardown: starting a database, launching a
server, or writing a summary report.

### Scenario-Level Hooks

```moonbit
setup.before_test_case(fn(ctx : @moonspec.CaseHookCtx) { ... })
setup.after_test_case(fn(ctx : @moonspec.CaseHookCtx, result : @moonspec.HookResult) { ... })
```

Scenario-level hooks execute once for each scenario (test case). The context
object provides `ctx.scenario()` which returns a `ScenarioInfo` containing the
feature name, scenario name, and tags.

If a `before_test_case` hook raises an error, all steps in that scenario are
marked as Skipped and the scenario is marked as Failed.

The `after_test_case` hook is always called, even if the before hook failed.
This guarantees cleanup code runs regardless of outcome.

### Step-Level Hooks

```moonbit
setup.before_test_step(fn(ctx : @moonspec.StepHookCtx) { ... })
setup.after_test_step(fn(ctx : @moonspec.StepHookCtx, result : @moonspec.HookResult) { ... })
```

Step-level hooks execute once for each step within each scenario. The context
provides both `ctx.scenario()` (returning `ScenarioInfo`) and `ctx.step()`
(returning `StepInfo` with `keyword` and `text` fields).

The `after_test_step` hook is always called regardless of whether the step
passed or failed.

---

## Hook Context Objects

Each hook level has its own context type. All three implement the `Attachable`
trait (covered below).

### RunHookCtx

Available in `before_test_run` and `after_test_run`. Provides only the
attachment methods -- there is no scenario or step metadata at run level.

### CaseHookCtx

Available in `before_test_case` and `after_test_case`. Provides:

- `ctx.scenario()` -- returns `ScenarioInfo`

`ScenarioInfo` has the following fields:

| Field            | Type           | Description                     |
|------------------|----------------|---------------------------------|
| `feature_name`   | `String`       | Name of the feature             |
| `scenario_name`  | `String`       | Name of the scenario            |
| `tags`           | `Array[String]`| Tags applied to the scenario    |

### StepHookCtx

Available in `before_test_step` and `after_test_step`. Provides:

- `ctx.scenario()` -- returns `ScenarioInfo`
- `ctx.step()` -- returns `StepInfo`

`StepInfo` has the following fields:

| Field     | Type     | Description                          |
|-----------|----------|--------------------------------------|
| `keyword` | `String` | The Gherkin keyword (Given, When, etc.) |
| `text`    | `String` | The step text after the keyword      |

---

## HookResult

After-hooks receive a `HookResult` as their second parameter, indicating
whether the preceding phase passed or failed.

```moonbit
pub enum HookResult {
  Passed
  Failed(Array[HookError])
}
```

`HookError` is an enum with structured error details:

```moonbit
pub enum HookError {
  StepFailed(step~ : String, keyword~ : StepKeyword, message~ : String)
  ScenarioFailed(feature_name~ : String, scenario_name~ : String, message~ : String)
}
```

You can pattern-match on the result to take different actions:

```moonbit
setup.after_test_case(fn(ctx, result) {
  match result {
    @moonspec.HookResult::Passed => ()
    @moonspec.HookResult::Failed(errors) =>
      for err in errors {
        match err {
          @moonspec.HookError::StepFailed(step~, message~, ..) =>
            ctx.attach("FAILED step: " + step + " -- " + message, "text/plain")
          @moonspec.HookError::ScenarioFailed(scenario_name~, message~, ..) =>
            ctx.attach("FAILED scenario: " + scenario_name + " -- " + message, "text/plain")
        }
      }
  }
})
```

---

## Hook Behavior Rules

1. **Register only what you need.** Unregistered hooks are never called. There
   is no overhead for hook types you do not use.

2. **Multiple hooks per type.** You can register more than one hook for the same
   type. They execute in registration order.

3. **After-hooks always run.** An `after_test_case` hook runs even if
   `before_test_case` raised an error. An `after_test_step` hook runs even if
   the step failed. This makes after-hooks reliable for cleanup and diagnostics.

4. **Run-level hooks bracket everything.** `before_test_run` fires before the
   first scenario. `after_test_run` fires after the last scenario. They run
   exactly once per invocation of `@moonspec.run`.

5. **Hook errors are reported.** If a before-hook raises, the test phase it
   guards is marked as failed. The error is captured and passed to the
   corresponding after-hook via `HookResult::Failed`.

---

## Attachments

Attachments let you embed additional data -- logs, screenshots, JSON payloads,
external links -- into the Cucumber Messages output stream. Any reporting tool
that consumes Cucumber Messages can display these attachments.

All hook context types (`RunHookCtx`, `CaseHookCtx`, `StepHookCtx`) and the
step execution context (`Ctx`) implement the `Attachable` trait:

```moonbit
pub trait Attachable {
  attach(Self, String, String, file_name? : String) -> Unit
  attach_bytes(Self, Bytes, String, file_name? : String) -> Unit
  attach_url(Self, String, String) -> Unit
  pending_attachments(Self) -> Array[PendingAttachment]
}
```

### attach(body, media_type, file_name?)

Attach text content with a MIME type. The body is stored with IDENTITY encoding
(no transformation).

```moonbit
// Plain text
ctx.attach("User was logged in as admin", "text/plain")

// JSON payload
ctx.attach("{\"status\": \"ok\", \"count\": 42}", "application/json")

// With an optional file name
ctx.attach(log_contents, "text/plain", file_name="debug.log")
```

### attach_bytes(data, media_type, file_name?)

Attach binary content. The bytes are automatically Base64-encoded before being
stored in the message stream.

```moonbit
// Attach a screenshot
ctx.attach_bytes(png_bytes, "image/png", file_name="screenshot.png")

// Attach a PDF report
ctx.attach_bytes(pdf_bytes, "application/pdf", file_name="report.pdf")
```

### attach_url(url, media_type)

Attach a reference to an external URL. The content is not fetched or embedded --
only the URL is recorded. Reporting tools can render this as a link.

```moonbit
// Link to CI build logs
ctx.attach_url("https://ci.example.com/builds/123/log", "text/plain")

// Link to an external screenshot
ctx.attach_url("https://cdn.example.com/screenshots/fail-01.png", "image/png")
```

### Where Attachments Appear

Attachments are emitted as `Attachment` (for embedded content) or
`ExternalAttachment` (for URL references) envelopes in the Cucumber Messages
stream. They are:

- Visible in `MessagesFormatter` output (NDJSON format)
- Consumable by any tool that reads Cucumber Messages (HTML reporters, CI
  integrations, dashboards)

Attachments created in step hooks or step handlers are associated with the
current step. Attachments created in scenario hooks are associated with the
scenario. Attachments created in run hooks are associated with the test run.

---

## Common Patterns

### Capture Diagnostics on Failure

Attach debugging information only when a scenario fails. The `after_test_case`
hook receives a `HookResult` that you can inspect:

```moonbit
setup.after_test_case(fn(ctx, result) {
  match result {
    @moonspec.HookResult::Failed(_) => {
      ctx.attach("screenshot data here", "image/png")
      ctx.attach("{\"page\": \"/checkout\", \"user\": \"test@example.com\"}", "application/json")
    }
    _ => ()
  }
})
```

### Log Step Execution

Trace every step as it runs by attaching a message in a before-step hook:

```moonbit
setup.before_test_step(fn(ctx) {
  let info = ctx.step()
  ctx.attach("Executing: " + info.keyword + " " + info.text, "text/plain")
})
```

### Track Step Timing

Record how long each step takes by combining before and after step hooks with
shared mutable state:

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.before_test_step(fn(_ctx) {
    self.step_start_time = now()
  })
  setup.after_test_step(fn(ctx, _result) {
    let elapsed = now() - self.step_start_time
    ctx.attach("Duration: " + elapsed.to_string() + "ms", "text/plain")
  })

  // ... step definitions ...
}
```

Because MoonBit structs are reference types, mutations to `self` in one hook
are visible in the other.

### Global Setup and Teardown

Use run-level hooks for resources that span the entire test suite:

```moonbit
setup.before_test_run(fn(ctx) {
  ctx.attach("Test suite started", "text/plain")
  // Initialize database connection pool
  // Start mock server
  // Seed test data
})

setup.after_test_run(fn(_ctx, _result) {
  // Shut down mock server
  // Close database connections
  // Generate coverage report
})
```

### Tag-Based Conditional Logic

Use scenario tags to conditionally run setup code:

```moonbit
setup.before_test_case(fn(ctx) {
  let tags = ctx.scenario().tags
  if tags.contains("@slow") {
    ctx.attach("Running slow test -- extended timeout", "text/plain")
  }
  if tags.contains("@database") {
    // Reset database to clean state
  }
})
```

### Report Scenario Errors in Detail

Iterate over structured errors in after-case hooks to produce detailed reports:

```moonbit
setup.after_test_case(fn(ctx, result) {
  match result {
    @moonspec.HookResult::Failed(errors) =>
      for err in errors {
        let msg = match err {
          @moonspec.HookError::StepFailed(step~, keyword~, message~, ..) =>
            "Step '" + step + "' (" + keyword.to_string() + ") failed: " + message
          @moonspec.HookError::ScenarioFailed(scenario_name~, message~, ..) =>
            "Scenario '" + scenario_name + "' failed: " + message
        }
        ctx.attach(msg, "text/plain")
      }
    _ => ()
  }
})
```

---

## Summary

| Hook                  | When it runs               | Context type   | Receives result? |
|-----------------------|----------------------------|----------------|------------------|
| `before_test_run`     | Once, before all scenarios | `RunHookCtx`   | No               |
| `after_test_run`      | Once, after all scenarios  | `RunHookCtx`   | Yes              |
| `before_test_case`    | Before each scenario       | `CaseHookCtx`  | No               |
| `after_test_case`     | After each scenario        | `CaseHookCtx`  | Yes              |
| `before_test_step`    | Before each step           | `StepHookCtx`  | No               |
| `after_test_step`     | After each step            | `StepHookCtx`  | Yes              |

| Attachment method | Content type | Encoding | Use case                    |
|-------------------|-------------|----------|-----------------------------|
| `attach`          | Text/string | IDENTITY | Logs, JSON, HTML            |
| `attach_bytes`    | Binary      | BASE64   | Screenshots, PDFs, archives |
| `attach_url`      | URL ref     | N/A      | External logs, CI links     |
