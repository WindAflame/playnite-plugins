# Playnite kit - RetroArch Steam with save-sync through Romm

Bridges Playnite, the Steam build of RetroArch, and a self-hosted RomM server. Auto-configures emulator profiles, fetches cores on launch, and syncs saves and states on game start/exit.

## Development

- Astral/uv
- Latest python

## Dependencies

- Save-sync : https://github.com/Covin90/romm-retroarch-sync

## RetroArch (Steam) emulator profiles

RetroArch's official Playnite definition has ~100 profiles (one per libretro core), each
launching `retroarch.exe` directly. To keep Steam Input, the overlay, and playtime
tracking working — this matters on a handheld like the ROG Ally, where a direct exe
launch bypasses all of that — games need to launch through
`steam.exe -applaunch 1118310 ...` instead.

`src/extension/PlayniteRetroarchRommKit/Scripts/sync-emulator-profiles.ps1` (run from the
extension's main menu action, see below) generates these as **Custom** emulator profiles,
which set `Executable`/`Arguments` directly:

- Reads Playnite's own bundled `retroarch` definition via `$PlayniteApi.Emulation.GetEmulator("retroarch")`.
- Resolves `steam.exe`'s path from the registry (`HKCU:\Software\Valve\Steam`) and
  RetroArch's actual install folder by parsing `steamapps\libraryfolders.vdf` — no manual
  path entry.
- Sets `TrackingMode = Directory` (watches for any process running from RetroArch's
  folder) on every generated profile, so Playnite correctly detects both game start and
  RetroArch closing.

One manual, one-time step is required: `$PlayniteApi.Database.Emulators.Add(...)` throws
`NotSupportedException` for every overload when called from a script, so the sync script
can't create the `Emulator` entity itself — only sync its profiles. Create it once:
Library > Emulators > Add > Custom emulator, name it exactly `RetroArch (Steam)`, save,
then run the sync. See [dist/README.md](dist/README.md) for the full end-user steps.

## PlayniteRetroarchRommKit extension

`src/extension/PlayniteRetroarchRommKit` is a Playnite [script
extension](https://api.playnite.link/docs/tutorials/extensions/scripting.html). It hooks:

- `OnGameStarting`: runs `fetch-core.ps1` (downloads the profile's libretro core from the
  buildbot if missing — the Steam build has no built-in core updater) then
  `pull-sync-save.ps1`.
- `OnGameStopped`: runs `push-sync-save.ps1`.
- `GetMainMenuItems`: adds "Sync RetroArch (Steam) profiles", which runs
  `sync-emulator-profiles.ps1` (see above).

Both `OnGameStarting`/`OnGameStopped` are guarded by a check that the game's play action
actually targets the emulator named `RetroArch (Steam)` — those events fire for every
game in the library, not just RetroArch ones.

**Playnite invokes each of these as a scriptblock detached from the rest of the
module** — confirmed on hardware: a call from `OnGameStarting` to a sibling function
defined elsewhere in `main.psm1` fails at runtime with "not recognized as a cmdlet",
even though it's the same file. All logic is therefore inlined in each hook instead of
shared through a helper, and `$PlayniteApi` is passed explicitly into `Scripts\*.ps1`
files rather than relied on as an ambient variable.

Run

```
uv run src/build-extension.py
```

to copy it into `dist/PlayniteRetroarchRommKit` (no fetch/transform needed here — this
just keeps `dist/` as build output only). See [dist/README.md](dist/README.md) for the
end-user install steps.

Targets Playnite 10's PowerShell script extensions. Support for those is slated for
removal in Playnite 11, at which point this would need to become a C# `GenericPlugin`
instead.