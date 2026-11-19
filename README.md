# claude_devcontainer_mapping

A personal [dev container feature](https://containers.dev/implementors/features/) that installs
Claude Code in any dev container and shares the host's `~/.claude` with it: settings, login,
skills, plugins and memory. Nothing in the project's own `devcontainer.json` changes.

## What the `claude-host` feature does

- Bind-mounts the host's `~/.claude` at `/mnt/claude-host`.
- Links the container user's `~/.claude` to that mount.
- Sets `CLAUDE_CONFIG_DIR=/mnt/claude-host`, so the container's `.claude.json` is kept in
  `~/.claude/.claude.json` on the host and survives rebuilds. The host's own `~/.claude.json` is
  not shared.
- Installs Claude Code with the native installer as the container's remote user, so it can update
  itself, and links `claude` into `/usr/local/bin`.

## Use

Add the feature to every dev container through the VS Code user setting:

```json
"dev.containers.defaultFeatures": {
  "ghcr.io/raffael0/claude_devcontainer_mapping/claude-host:1": {}
}
```

The host must have a `~/.claude` directory, or the container won't start.

### Sharing project memory

Claude Code keeps memory per absolute project path, in `~/.claude/projects/<path with / as ->/`.
Inside a container the project is at `/workspaces/<folder>`, so link that name to the host
project's folder once, on the host:

```sh
cd ~/.claude/projects
ln -s -- -home-<user>-<path>-<repo> -workspaces-<repo>
```

Characters other than letters and digits become `-` (`customer_software_setup` becomes
`customer-software-setup`).

## Release

Run the **Release dev container features** workflow (Actions tab). It publishes
`ghcr.io/raffael0/claude_devcontainer_mapping/claude-host`. The package must then be set to public
in its GitHub package settings, or VS Code can't pull it.

Bump `version` in `src/claude-host/devcontainer-feature.json` before each release.

## Test without releasing

Copy `src/claude-host` into a project's `.devcontainer/` folder, add `"./claude-host": {}` to its
`features`, rebuild, and don't commit either change.
