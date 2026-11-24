# Deployment forms (#43)

The runtime has two supported shapes. Both keep the sentinel in a separate
process that does not share the agent's mutable AST or working set.

## Form A: per-user cloud VM

- one VM per user;
- `agent` runs the inbox/harness/tool loop;
- `sentinel` runs the approval/red-line check and holds the protected
  policy files read-only;
- both use the `aura-ci` digest and Aura SHA locked in `aura.toml`;
- secrets and personal data stay in the user's VM, never in the image.

## Form B: local agent + separate sentinel

- the agent runs on the user's machine;
- the sentinel is a separate process with read-only access to
  `sentinel/` and the policy files;
- killing the agent does not remove the sentinel's deny path; the admin
  or supervisor can still ask the sentinel for a decision;
- no device-to-device sync in this PR (explicitly out of scope).

## Isolation check

`scripts/sentinel_isolation.sh` copies the sentinel plane to a read-only
file, runs the agent tamper fixture against it, then runs the sentinel
fixture in a separate process. It requires:

```text
agent-write=denied
sentinel-decision=deny
sentinel-approval=pending
sentinel-isolation=ok
```

The check runs in CI. A cloud deployment still has to apply the same
ownership/read-only rule at the VM boundary; this repository does not
claim a production cloud control plane.
