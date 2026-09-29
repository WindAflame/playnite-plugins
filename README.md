<!-- trunk-ignore-all(markdownlint/MD033) -->
<!-- trunk-ignore(markdownlint/MD041) -->
<div align="center">

  <img src="docs/src/assets/playnite.svg" height="180px" width="auto" alt="Playnite Plugins logo">
    <h3 style="font-size: 25px;">
    Playnite plugins for RetroArch (Steam) and RomM.
  </h3>

<br>

[![Version](https://img.shields.io/github/v/release/WindAflame/playnite-plugins?label=Version)](https://github.com/WindAflame/playnite-plugins/releases/latest)
[![License: PolyForm Noncommercial](https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-blue)](LICENSE)

[![CI: Release](https://img.shields.io/github/actions/workflow/status/WindAflame/playnite-plugins/release.yml?label=CI%3A%20Release)](https://github.com/WindAflame/playnite-plugins/actions/workflows/release.yml)
[![CI: Deploy](https://img.shields.io/github/actions/workflow/status/WindAflame/playnite-plugins/deploy-docs.yml?label=CI%3A%20Deploy)](https://github.com/WindAflame/playnite-plugins/actions/workflows/deploy-docs.yml)

  </div>
</div>

# Overview

This repository hosts plugins that bridge [Playnite](https://playnite.link/), the Steam build of RetroArch, and a self-hosted [RomM](https://github.com/rommapp/romm) server.

## Plugins

| Plugin                                                      | Status        | What it does                                                                                                  |
| ----------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------- |
| [RetroArch (Steam)](plugins/PlaynitePlugins-RetroArchSteam) | Usable        | Auto-configures RetroArch (Steam) emulator profiles in Playnite and fetches missing libretro cores on launch. |
| [RomM Save Sync](plugins/PlayniteRommSaveSyncKit)           | Scaffold only | Will sync saves/states with RomM on game start/exit. Not implemented yet — see the TODOs in that folder.      |

Each is a Playnite [script
extension](https://api.playnite.link/docs/tutorials/extensions/scripting.html)
(PowerShell), targeting Playnite 10.x — support for script extensions is slated for
removal in Playnite 11.

## Development

Requirements: [uv](https://docs.astral.sh/uv/) (plugins tooling), npm (docs site) and
`make`. Run `make help` to list every target.

| Command                                | What it does                                                            |
| -------------------------------------- | ----------------------------------------------------------------------- |
| `make build`                           | Copies every plugin under `plugins/` into `dist/`.                      |
| `make pack TOOLBOX=<path/Toolbox.exe>` | Builds, then packs each `dist/<plugin>` into `dist/pext/<plugin>.pext`. |
| `make install`                         | Installs the docs site dependencies (`npm install`).                    |
| `make docs-dev`                        | Previews the docs site locally.                                         |
| `make docs-build`                      | Builds the docs site into `dist/docs/`.                                 |
| `make clean`                           | Removes `dist/`.                                                        |

`make pack` needs `Toolbox.exe` from any local Playnite install: pass it as `TOOLBOX=...`,
or set the `PLAYNITE_TOOLBOX` env var once instead. The release workflow runs the same
packing script — the only difference is where its `Toolbox.exe` comes from (a Playnite
version downloaded fresh in CI, vs. whatever's already installed on your machine).

Each target is a thin wrapper around `uv run tools/*.py` or `npm run ... --workspace docs`,
so you can still run those directly if `make` isn't available (e.g. plain Windows).

Implementation notes and gotchas (e.g. why profiles are synced instead of created, why
hook logic can't be shared through a helper function) live as comments next to the code
they explain, in each plugin's `main.psm1` and `Scripts/*.ps1`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[PolyForm Noncommercial License 1.0.0](LICENSE) — noncommercial use only.
