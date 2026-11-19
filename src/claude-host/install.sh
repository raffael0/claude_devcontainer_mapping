#!/usr/bin/env bash
# Installs Claude Code (native installer) for the container's remote user, so its
# auto-updater can write to its own install, and puts `claude` on everyone's PATH.
set -euo pipefail

user="${_REMOTE_USER:-root}"
home="${_REMOTE_USER_HOME:-/root}"

if ! command -v curl >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y --no-install-recommends curl ca-certificates
        rm -rf /var/lib/apt/lists/*
    else
        echo "claude-host: curl is missing and apt-get isn't available to install it" >&2
        exit 1
    fi
fi

if [ "$user" = root ]; then
    bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
else
    su "$user" -s /bin/bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
fi

ln -sf "$home/.local/bin/claude" /usr/local/bin/claude

# The host's ~/.claude is mounted at /mnt/claude-host (see devcontainer-feature.json);
# make ~/.claude point there too. The installer leaves an empty ~/.claude and
# ~/.claude.json behind, which would otherwise be in the way.
rm -rf "$home/.claude" "$home/.claude.json"
ln -s /mnt/claude-host "$home/.claude"
chown -h "$user": "$home/.claude"
