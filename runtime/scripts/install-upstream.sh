#!/usr/bin/env bash
# Upstream install of the template runtime plugin.
#
# Replace this file with the real install of the release pinned in
# `compat/RELEASE`: download or build that release and place the upstream
# binary it ships (the descriptor's `[runtime] program`) into `$UPSTREAM_BIN`.
# The binary must answer the descriptor's `version_probe.args`
# (`--version`) with the bare `MAJOR.MINOR.PATCH` release from
# `compat/RELEASE`, and on a plain launch it must print an `idle_prompt`
# screen phrase (like `ready`) and stay running.
#
# The CI smoke step runs this script with the repository root as the
# working directory and `UPSTREAM_BIN` set to an absolute directory; the
# local smoke check does the same (see "Local checks" in README.md). The
# shipped placeholder below installs no real upstream: it writes a
# self-contained `example` stub that satisfies the smoke contract above, so
# a repository generated from the template stays green with only the names
# changed. It uses no network access.
set -euo pipefail

if [ -z "${UPSTREAM_BIN:-}" ]; then
  echo "install-upstream.sh: UPSTREAM_BIN is unset" >&2
  exit 1
fi
mkdir -p "$UPSTREAM_BIN"

version="$(sed -e 's/#.*//' compat/RELEASE | grep -v '^[[:space:]]*$' | tail -n 1 || true)"
if [ -z "$version" ]; then
  echo "install-upstream.sh: no release in compat/RELEASE" >&2
  exit 1
fi
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "install-upstream.sh: invalid release '$version' in compat/RELEASE (want MAJOR.MINOR.PATCH)" >&2
  exit 1
fi

cat > "$UPSTREAM_BIN/example" <<EOF
#!/bin/sh
if [ "\$1" = "--version" ]; then
  echo "$version"
  exit 0
fi
printf '\\033]2;example\\007\\033[2J\\033[H\$ ready\\n\$ '
exec sleep 300
EOF
chmod +x "$UPSTREAM_BIN/example"
