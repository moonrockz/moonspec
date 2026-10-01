# Agentic Instructions

Common agentic instructions are in AGENTS.md, imported here:

@AGENTS.md

Only place claude specific agentic instructions in this file.

## Claude Code

- Track work in bd only (see AGENTS.md > Work Tracking). Do not use the
  TodoWrite or TaskCreate tools.
- Store persistent knowledge with `bd remember`, not in Claude Code auto
  memory (`MEMORY.md`). See AGENTS.md > Persistent Memory.
- Use `mise run <task>` for builds and tests, not ad hoc command chains.
