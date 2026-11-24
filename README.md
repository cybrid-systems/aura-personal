# aura-personal

Single-user personal runtime built from the Aura bootstrap seed
([aura-agents#37](https://github.com/cybrid-systems/aura-agents/issues/37)).
It is a separate repository on purpose: the conductor/incubator remains
`aura-agents`.

## Inbox and tools

- `runtime/inbox.aura`: long-lived messages, timers, webhook-shaped input,
  cancellable watches and a budget freeze. Persistent cron and inbound
  HTTP are reported as degraded (`aura#5414`, `aura#5415`).
- `runtime/approval.aura`: default-deny external actions, timeouts,
  explicit approved requests and scoped expiring grants.
- `runtime/memory.aura`: per-user persisted memory with provenance,
  PIN/challenge/withdraw; withdrawn memories are not authority.
- `runtime/harness.aura`: queued/claimed/completed tasks with leases,
  recovery, per-task audit, fail-closed tool table and budget fuse.
- `runtime/graduation.aura`: N unattended rounds, handoff and bounded
  post-graduation escalation.

## Run

```bash
aura run runtime/main.aura
aura test
bash scripts/sentinel_isolation.sh
aura run bootstrap/run.aura
```

The sentinel plane (`sentinel/plane.aura`) is frozen and is not part of
any evolvable genome. Ingested text never becomes a grant or capability.
The bootstrap seed is owned by this repository, not by the conductor.

See `docs/principles.md`, `docs/seed.md`, and `docs/deploy.md`.
