---
title: Getting Started
description: What this repo contains and how the plugins fit together.
---

This repo bridges [Playnite](https://playnite.link/), the Steam build of RetroArch, and a
self-hosted [RomM](https://github.com/rommapp/romm) server. It's organized as a monorepo
with one folder per Playnite plugin under `plugins/`, plus this documentation site:

- **[RetroArch (Steam)](../plugins/retroarch-steam/)**: auto-configures RetroArch (Steam)
  emulator profiles and fetches missing libretro cores on launch. Self-contained, no RomM
  involved. Usable today.
- **[RomM Save Sync](../plugins/romm-save-sync/)**: will sync saves/states with RomM on game
  start/exit. Scaffold only, not implemented yet.

Both are Playnite [script
extensions](https://api.playnite.link/docs/tutorials/extensions/scripting.html) (PowerShell),
targeting Playnite 10.x.

## Installing a plugin

Each plugin has its own guide with exact steps — see the **Plugins** section in the sidebar.
In short: grab the packaged `.pext` for the plugin you want from the [GitHub
Releases](https://github.com/WindAflame/playnite-plugins/releases) page and
open it with Playnite.

## Building from source

The repo uses [uv](https://docs.astral.sh/uv/) for the Python build tooling and npm
workspaces for this documentation site.

```sh
# Copy every plugin under plugins/ into dist/, ready to be packed or dropped
# straight into <Playnite install dir>/Extensions/
uv run tools/build-extension.py

# Pack each dist/<plugin> into dist/pext/<plugin>.pext, using Toolbox.exe from
# any local Playnite install (or set PLAYNITE_TOOLBOX instead of --toolbox)
uv run tools/pack-extensions.py --toolbox "<path to Playnite>\Toolbox.exe"
```

The GitHub Actions release workflow runs this same `pack-extensions.py` script and
attaches its output to the release — the only difference is it downloads a pinned
Playnite version first instead of using a local install.

To run this documentation site locally:

```sh
npm install
npm run dev --workspace docs      # preview
npm run build --workspace docs    # build into dist/docs/
```
