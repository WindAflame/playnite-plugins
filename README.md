# Playnite Plugins

Bridges [Playnite](https://playnite.link/), the Steam build of RetroArch, and a
self-hosted [RomM](https://github.com/rommapp/romm) server.

For install steps and per-plugin guides, see the docs site in [`docs`](docs)
(`npm install && npm run dev --workspace docs` to preview it locally).

## Plugins

| Plugin                                                            | Status         | What it does                                                                              |
| ------------------------------------------------------------------ | -------------- | ------------------------------------------------------------------------------------------- |
| [RetroArch (Steam)](plugins/PlaynitePlugins-RetroArchSteam)      | Usable         | Auto-configures RetroArch (Steam) emulator profiles in Playnite and fetches missing libretro cores on launch. |
| [RomM Save Sync](plugins/PlayniteRommSaveSyncKit)                 | Scaffold only  | Will sync saves/states with RomM on game start/exit. Not implemented yet — see the TODOs in that folder. |

Each is a Playnite [script
extension](https://api.playnite.link/docs/tutorials/extensions/scripting.html)
(PowerShell), targeting Playnite 10.x — support for script extensions is slated for
removal in Playnite 11.

## Repo layout

- `plugins/<name>/` — one Playnite script extension per folder.
- `docs/` — the Astro Starlight docs site (source for the guide linked above).
- `tools/` — the Python scripts below.
- `dist/` — build output only, never hand-edited. Single output location for every
  project in the repo:
  - `dist/<plugin>/` — each plugin, copied as-is.
  - `dist/pext/<plugin>.pext` — each plugin packed for Playnite.
  - `dist/docs/` — the built docs site.

## Development

- Plugins: [uv](https://docs.astral.sh/uv/) + Python.
  - `uv run tools/build-extension.py` copies every plugin under `plugins/` into `dist/`.
  - `uv run tools/pack-extensions.py --toolbox <path to Playnite's Toolbox.exe>` packs
    each `dist/<plugin>` into `dist/pext/<plugin>.pext` (needs `dist/<plugin>` to exist
    first). Point `--toolbox` at `Toolbox.exe` from any local Playnite install, or set the
    `PLAYNITE_TOOLBOX` env var instead of passing the flag every time. The release
    workflow runs this same script — the only difference is where its `Toolbox.exe` comes
    from (a Playnite version downloaded fresh in CI, vs. whatever's already installed on
    your machine locally).
- Docs site: `npm install` then `npm run dev --workspace docs` to preview, or
  `npm run build --workspace docs` to build straight into `dist/docs/`.

Implementation notes and gotchas (e.g. why profiles are synced instead of created, why
hook logic can't be shared through a helper function) live as comments next to the code
they explain, in each plugin's `main.psm1` and `Scripts/*.ps1`.
