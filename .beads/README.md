# Beads issue tracking

This repository uses Beads with embedded Dolt. The database and its history
sync through `refs/dolt/data` on the GitHub remote. `.beads/issues.jsonl` is
a tracked issue snapshot for inspection and interchange, not the live database.

## Set up a clone or worktree

Install Beads 1.3.0 or later, then run these commands from the repository root:

```bash
bd bootstrap --yes
chmod 700 .beads
git config beads.role maintainer
bd hooks install --beads
git config core.hooksPath .beads/hooks
bd ready
```

Use `contributor` instead of `maintainer` when working as an external contributor.
Bootstrap restores the configured Dolt remote without replacing existing history.
Each worktree needs a local database unless it has a Beads redirect to another
worktree. Run bootstrap in a new worktree before using the tracker.
The relative hook path makes Git use the hooks in the current worktree. Set it
after installing hooks, since the installer can select the main checkout's path.

If `bd` reports `no beads database found`, run `bd bootstrap --yes` again.
Do not use a destructive reinitialization to recover a clone with remote history.

## Work with issues

```bash
bd ready
bd list --status open
bd show <issue-id>
bd create "Describe the work" --type task --priority 2
bd update <issue-id> --status in_progress
bd close <issue-id> --reason "Describe the completed work and validation"
```

## Sync and publish

```bash
bd sync
bd export --output .beads/issues.jsonl
```

`bd sync` pulls and pushes Dolt history independently of the Git code branch.
Auto-export refreshes the JSONL snapshot after writes, at most once per minute.
Use the explicit export above before committing tracker changes so the snapshot
contains the latest remote issues and local updates. Commit the snapshot and
push the Git branch as part of the normal session completion workflow.

## Check the installation

```bash
bd dolt status
bd hooks list
bd doctor --check-health
bd doctor --check=conventions
```

The local Dolt database, locks, and runtime files are ignored by Git. Keep the
tracked configuration, hooks, and issue snapshot in version control.
