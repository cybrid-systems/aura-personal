#!/usr/bin/env bash
# PR-5 (#43): a separate, read-only sentinel process.
#
# The agent process gets a read-only copy of the sentinel plane; a write
# fails at the filesystem boundary, and the sentinel process independently
# denies an unapproved external action. This is the local-form isolation
# check, not a claim that a cloud VM is deployed.
set -euo pipefail
cd "$(dirname "$0")/.."

AURA_BIN="${AURA_BIN:-}"
if [[ -z "$AURA_BIN" ]]; then
  AURA_BIN="$(command -v aura || true)"
fi
[[ -n "$AURA_BIN" ]] || { echo "sentinel-isolation: AURA_BIN missing" >&2; exit 2; }

tmp="$(mktemp -d)"
cleanup() { chmod -R u+w "$tmp" 2>/dev/null || true; rm -rf "$tmp"; }
trap cleanup EXIT

cp sentinel/plane.aura "$tmp/sentinel.aura"
chmod 444 "$tmp/sentinel.aura"
before="$(sha256sum "$tmp/sentinel.aura" | awk '{print $1}')"

SENTINEL_PATH="$tmp/sentinel.aura" AURA_SANDBOX=off \
  "$AURA_BIN" run scripts/fixtures/agent_tamper.aura >"$tmp/agent.out" 2>&1
AURA_SANDBOX=off "$AURA_BIN" run scripts/fixtures/sentinel_check.aura \
  >"$tmp/sentinel.out" 2>&1

cat "$tmp/agent.out"
cat "$tmp/sentinel.out"
grep -qx 'agent-write=denied' "$tmp/agent.out"
grep -qx 'sentinel-decision=deny' "$tmp/sentinel.out"
grep -qx 'sentinel-approval=pending' "$tmp/sentinel.out"
after="$(sha256sum "$tmp/sentinel.aura" | awk '{print $1}')"
[[ "$before" == "$after" ]] || { echo "sentinel-isolation: sentinel changed" >&2; exit 1; }
echo "sentinel-isolation=ok"
