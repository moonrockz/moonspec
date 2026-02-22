# Claude Code Project Instructions

## Commit Messages

All commits MUST use **Conventional Commits** format:

```
type(scope): description
```

Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `style`

## Build & Test

Use **`mise run`** for all operations:

```bash
mise run test:unit        # MoonBit unit tests
```

## Mise Tasks

Tasks are **file-based scripts** in `mise-tasks/`. Never add inline `[tasks]` to `.mise.toml`.
