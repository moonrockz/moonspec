# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Overview

This module (`moonrockz/moonspec`) is a **BDD test framework** for MoonBit
inspired by [Cucumber](https://cucumber.io/). It parses Gherkin `.feature`
files, matches steps using Cucumber Expressions, executes scenarios with tag
filtering, and reports results through pluggable formatters.

The framework supports three integration modes:

1. **Codegen** -- generate `_test.mbt` files from `.feature` files for native
   `moon test` execution
2. **Runner API** -- programmatic step registration and execution from MoonBit
   code
3. **CLI** -- command-line tool with `gen` (codegen), `check` (validation),
   and `version` subcommands

### Architecture Summary

```
moonrockz/moonspec
├── src/
│   ├── core/            # Foundation types, step registry, and step definitions
│   │   ├── types.mbt        # Ctx (step execution context), ScenarioInfo, StepInfo, StepHandler
│   │   ├── registry.mbt     # StepRegistry — given/when/then/step + find_match + use_library
│   │   ├── setup.mbt        # Setup facade — wraps StepRegistry + ParamTypeRegistry + HookRegistry
│   │   ├── hook_registry.mbt # HookRegistry — registration-based lifecycle hooks (6 types)
│   │   ├── step_def.mbt     # StepDef — first-class step definitions (given/when/then/step constructors)
│   │   ├── step_library.mbt # StepLibrary trait — composable step definition groups
│   │   ├── world.mbt        # World trait
│   │   ├── error.mbt        # MoonspecError hierarchy (ParseError, UndefinedStep, etc.)
│   │   ├── snippet.mbt      # Snippet generator for undefined steps
│   │   ├── suggest.mbt      # "Did you mean?" suggestions for undefined steps
│   │   └── lib.mbt          # Package entry point
│   ├── runner/          # Scenario execution engine
│   │   ├── results.mbt      # StepStatus, ScenarioStatus, *Result, RunSummary
│   │   ├── executor.mbt     # Sequential step executor
│   │   ├── feature.mbt      # Feature executor (Gherkin integration)
│   │   ├── outline.mbt      # Scenario Outline expansion
│   │   ├── tags.mbt         # Tag expression parser and evaluator
│   │   ├── run.mbt          # Top-level run() orchestrator
│   │   └── lib.mbt          # Package entry point
│   ├── format/          # Output formatters
│   │   ├── formatter.mbt    # Formatter trait (event-driven)
│   │   ├── pretty.mbt       # Human-readable console output
│   │   ├── messages.mbt     # Cucumber Messages (NDJSON)
│   │   ├── junit.mbt        # JUnit XML for CI integration
│   │   └── lib.mbt          # Package entry point
│   ├── codegen/         # Test file generation
│   │   ├── codegen.mbt      # .feature → _test.mbt generator
│   │   └── moon.pkg         # Package config
│   └── cmd/main/        # CLI entry point
│       ├── main.mbt         # CLI binary
│       └── moon.pkg         # Package config (is_main: true)
├── docs/plans/          # Design and implementation plans
├── .beads/              # Issue tracking database
└── mise-tasks/          # File-based mise tasks
```

### Processing Pipeline

```
.feature file → @gherkin.parse() → GherkinDocument
             → extract scenarios + expand outlines
             → filter by tag expression
             → World::configure() → Setup (StepRegistry + ParamTypeRegistry, with StepLibrary composition)
             → for each step:
                 → StepRegistry::find_match(text) → (handler, args)
                 → execute handler → StepResult
                 → on undefined: generate snippet + "did you mean?" suggestions
             → aggregate → ScenarioResult → FeatureResult → RunResult
             → run_or_fail: raise MoonspecError on failure
             → Formatter::on_*() events → output
```

### Package Dependency Graph

```
core  ←─────  runner  ←─── cmd/main
  │              │
  │              ↓
  │           format
  │
  └──────────  codegen
```

External dependencies:

| Package                           | Purpose                     |
|-----------------------------------|-----------------------------|
| `moonrockz/gherkin`              | Gherkin parser              |
| `moonrockz/cucumber-expressions` | Step pattern matching       |
| `moonrockz/cucumber-messages`    | Cucumber Messages protocol  |
| `moonbitlang/x`                  | Standard library extensions |
| `moonbitlang/async`              | Async execution primitives  |
| `moonbitlang/regexp`             | Regular expressions         |

## Project Structure

- MoonBit packages are organized per directory, for each directory, there is a
  `moon.pkg` (DSL format) or `moon.pkg.json` file listing its dependencies.
  Each package has its files and blackbox test files (common, ending in
  `_test.mbt`) and whitebox test files (ending in `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod` file listing about the
  module and some meta information.

## Design Philosophy

This project follows **functional design principles**. These are non-negotiable:

- **Algebraic data types (ADTs)**: Model domain concepts using enums (sum types)
  and structs (product types). Use ADTs to make the type system express the
  domain precisely. Examples: `Ctx`, `StepStatus`, `ScenarioStatus`.

- **Make invalid states unrepresentable**: Design types so that illegal
  combinations cannot be constructed. If a state shouldn't exist, the type
  system should prevent it -- not runtime checks.

- **Avoid primitive obsession**: Do not use raw `String`, `Int`, or `Bool` where
  a domain-specific type is appropriate. Wrap primitives in meaningful types.

- **Prefer immutability**: Default to immutable data. Use `mut` only when
  mutation is clearly necessary and localized.

- **Pattern matching over conditionals**: Use `match` expressions to
  exhaustively handle all variants of an enum.

- **Total functions**: Functions should handle all possible inputs. Use `raise`
  with typed `suberror` for parse failures. Return `Option` instead of panicking.

- **Event-driven formatting**: Formatters implement the `Formatter` trait with
  lifecycle callbacks (`on_run_start`, `on_step_finish`, etc.) rather than
  post-hoc result processing.

## Test-Driven Development (TDD)

This project practices **strict TDD**. Tests are written **before**
implementation code. This is not optional.

### The TDD Cycle

For every piece of new functionality, follow **Red-Green-Refactor**:

1. **Red**: Write a failing test that describes the desired behavior. Run it.
   Confirm it fails for the right reason.
2. **Green**: Write the **minimum** implementation code to make the test pass.
3. **Refactor**: Clean up the implementation while keeping tests green.

### Using `#declaration_only` for Spec-First Design

MoonBit's `#declaration_only` attribute lets you define function signatures
before implementing them:

```moonbit
#declaration_only
pub fn StepRegistry::find_match(
  self : StepRegistry,
  text : String,
  keyword? : String,
) -> StepMatchResult {
  ...
}
```

Use this to sketch out the public API, write tests against it, then fill in
implementations as tests go green.

### Testing Conventions

- Use `inspect(value, content="expected")` for snapshot testing
- Use `assert_eq` for stable, well-defined results
- Use `_wbtest.mbt` files for whitebox tests (access to private internals)
- Run `moon test --update` to refresh snapshots when behavior changes
- Run `moon coverage analyze > uncovered.log` to check coverage

## Coding Convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in a file called `deprecated.mbt` in each
  directory.

## Conventional Commits

All commit messages MUST follow **[Conventional Commits](https://www.conventionalcommits.org)**:

```
type(scope): description
```

### Commit Types

| Type       | Purpose                    | Version bump |
|------------|----------------------------|-------------|
| `feat`     | New feature                | MINOR        |
| `fix`      | Bug fix                    | PATCH        |
| `refactor` | Code restructuring         | -            |
| `perf`     | Performance improvement    | -            |
| `docs`     | Documentation only         | -            |
| `test`     | Adding/updating tests      | -            |
| `build`    | Build system changes       | -            |
| `ci`       | CI/CD configuration        | -            |
| `chore`    | Maintenance tasks          | -            |
| `style`    | Code formatting (no logic) | -            |

Breaking changes: add `!` after type (e.g., `feat(runner)!: change return type`).

### Scopes

| Scope     | Package              |
|-----------|----------------------|
| `core`    | `src/core/`          |
| `runner`  | `src/runner/`        |
| `format`  | `src/format/`        |
| `codegen` | `src/codegen/`       |
| `cmd`     | `src/cmd/main/`      |

## Mise Tasks

All build, test, and release operations are **file-based mise tasks** in
`mise-tasks/`. Use `mise run <task>` to execute them.

| Task                  | Purpose                                        |
|-----------------------|------------------------------------------------|
| `test:unit`           | Run MoonBit unit tests (`moon test`)           |
| `hooks:install`       | Install the git hooks (lefthook; they call `bd hooks run`) |
| `release:version`     | Compute next version from conventional commits |
| `release:credentials` | Set up mooncakes.io credentials (CI only)      |
| `release:publish`     | Publish package to mooncakes.io                |

### Creating New Tasks

New tasks go in `mise-tasks/` as executable scripts with `#MISE` metadata.
Use subdirectories for namespacing: `mise-tasks/build/native` becomes
`build:native`.

**Rules:**
- **Always** use file-based tasks in `mise-tasks/` -- never add inline TOML
  tasks to `.mise.toml`.
- The `.mise.toml` file contains only `[tools]` -- no `[tasks]` sections.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `mise run test:unit` to check tests pass. MoonBit supports snapshot
  testing; when changes affect outputs, run `moon test --update` to refresh
  snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. Use snapshot tests to record current
  behavior. You can use `moon coverage analyze > uncovered.log` to see which
  parts of your code are not covered by tests.

## Release Process

This project publishes to **mooncakes.io** (MoonBit package registry) and
**GitHub Releases**.

- Releases triggered by pushing a tag matching `v*` or via workflow_dispatch
- Requires `MOONCAKES_USER_TOKEN` org secret in GitHub Actions
- Pre-publish checks: `moon check`, `moon test`, `moon fmt`
- Package published as `moonrockz/moonspec` on mooncakes.io

## Work Tracking

**bd (beads) is the primary tracker for all work.** GitHub Issues are the
public intake for reports from outside contributors.

- Track every task, bug, feature and epic in bd. Do NOT use markdown TODO
  lists or other tracking methods.
- Mirror each GitHub issue into bd with `--external-ref gh-<number>`, and keep
  the two in step: when the bd issue closes, close the GitHub issue.
- A pull request that resolves a GitHub issue says `Closes #<number>` in its
  body. Name the bd issue in the body too.
- Work lands on `main` through pull requests (squash merge). Branch first;
  do not push to `main` unless the user says so for that change.
- bd runs with `agent.profile: team-maintainer` (`.beads/config.yaml`):
  commit, `bd sync` and push are routine parts of the work. An explicit
  "do not commit" or "do not push" from the user still wins, and pushes go to
  your branch, not to `main`.

## Persistent Memory

Store knowledge that must outlive the session with `bd remember`. Do not use
`MEMORY.md` files or any agent's own memory store for this project; bd
memories sync through `refs/dolt/data`, so every machine and agent sees them.

```bash
bd remember "insight" --key <slug>   # store, or update the memory with that key
bd memories <keyword>                # search
bd recall <key>                      # read one
```

`bd prime` (the SessionStart hook) injects the memories into each session.

<!-- BEGIN BEADS INTEGRATION -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT
use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: syncs through a Dolt remote on the Git origin
  (`refs/dolt/data`), separate from source branches
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:moonspec-123 --json
bd create "Issue title" --description="..." --external-ref gh-12 --json   # mirror a GitHub issue
```

**Claim and update:**

```bash
bd update moonspec-42 --status in_progress --json
bd update moonspec-42 --priority 1 --json
```

**Complete work:**

```bash
bd close moonspec-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Storage and Sync

- bd stores issues in an embedded Dolt database at `.beads/embeddeddolt/`
  (not committed).
- Git worktrees share the database of the main checkout. Do not create a
  database inside a worktree.
- Cross-machine sync uses a Dolt remote on the GitHub origin. Dolt keeps issue
  history under `refs/dolt/data`, separate from source branches:
  - `bd sync` — pull, check for conflicts, and push in one step.
  - `bd dolt pull` / `bd dolt push` — the individual steps.
- Issue changes need no commit or pull request: `bd sync` publishes them to
  `refs/dolt/data`.
- `.beads/issues.jsonl` is a passive export (`bd export -o .beads/issues.jsonl`)
  for viewers and interchange. It is gitignored; do not commit it.

### Setup on a Fresh Clone

```bash
bd bootstrap            # clones refs/dolt/data from origin and wires the Dolt remote
mise run hooks:install  # installs lefthook git hooks (these call `bd hooks run <hook>`)
git config beads.role maintainer   # or contributor
```

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT duplicate tracking systems (GitHub issues are mirrored, not tracked twice)

<!-- END BEADS INTEGRATION -->

## Landing the Plane (Session Completion)

When you end a work session, complete ALL steps below. Work is NOT complete
until the pushes succeed.

1. **File issues for remaining work** in bd.
2. **Run quality gates** if code changed: `mise run test:unit`,
   `moon info && moon fmt`.
3. **Update issue status**: close finished work, update in-progress items.
4. **Push** (mandatory):
   ```bash
   bd sync                  # publish issue changes to refs/dolt/data
   git pull --rebase
   git push                 # your branch; open or update its pull request
   git status               # MUST show "up to date with origin"
   ```
5. **Clean up**: clear stashes, prune merged branches.
6. **Hand off**: give context for the next session.

Never stop before pushing; that leaves work stranded on one machine. If a push
fails, resolve the cause and retry.
