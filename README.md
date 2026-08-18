# Playnite kit - RetroArch Steam with save-sync through Romm

Bridges Playnite, the Steam build of RetroArch, and a self-hosted RomM server. Auto-configures emulator profiles, fetches cores on launch, and syncs saves and states on game start/exit.

## Development

- Astral/uv
- Latest python

## Dependencies

- RetroArch profile : https://github.com/JosefNemec/Playnite/blob/master/source/Playnite/Emulation/Emulators/RetroArch/emulator.yaml
- Save-sync : https://github.com/Covin90/romm-retroarch-sync

## RetroArch (Steam) Playnite profile

`src/convert-retroarch-to-steam-compatiblity.py` fetches Playnite's official RetroArch
emulator definition and rewrites each profile to launch through the Steam client
(`steam.exe -applaunch 1118310 ...`) instead of `retroarch.exe` directly, so Steam Input,
the overlay, and playtime tracking keep working — this matters on a handheld like the
ROG Ally where a direct exe launch bypasses all of that. Core/info folder paths don't
change: the Steam build's layout is identical to standalone, it just lacks a built-in
core updater (see `src/extension/PlayniteRetroarchRommKit/Scripts/fetch-core.ps1`).

Run it with:

```
uv run src/convert-retroarch-to-steam-compatiblity.py
```

This writes `dist/RetroArchSteam/emulator.yaml`. Playnite loads emulator definitions by
scanning `<Playnite install dir>/Emulation/Emulators/*/emulator.yaml` at startup —
confirmed on Playnite 10.56: dropping `dist/RetroArchSteam` in there makes
"RetroArch (Steam)" show up in the emulator picker. `dist/` is the delivery directory —
its contents are what an end user copies into their Playnite install; see
[dist/README.md](dist/README.md) for the end-user instructions.

**Not yet verified on hardware:** emulator *discovery* works, but whether Playnite
accepts a profile where the launched executable (`steam.exe`) lives outside the folder
holding the cores (`steamapps\common\RetroArch\`) — i.e. a full end-to-end game launch —
hasn't been confirmed yet.

## PlayniteRetroarchRommKit extension

`emulator.yaml` has no hook for running a script around a game launch, so
`fetch-core.ps1`/`pull-sync-save.ps1`/`push-sync-save.ps1` can't be wired in there.
Instead, `src/extension/PlayniteRetroarchRommKit` is a Playnite [script
extension](https://api.playnite.link/docs/tutorials/extensions/scripting.html): it
hooks `OnGameStarting` (runs `fetch-core.ps1` then `pull-sync-save.ps1`) and
`OnGameStopped` (runs `push-sync-save.ps1`), guarded by a check that the game's play
action actually targets the `retroarch_steam` emulator — those events fire for every
game in the library, not just RetroArch ones.

Run

```
uv run src/build-extension.py
```

to copy it into `dist/PlayniteRetroarchRommKit` (no fetch/transform needed here,
unlike the emulator profile above — this just keeps `dist/` as build output only).
See [dist/README.md](dist/README.md) for the end-user install steps.

Targets Playnite 10's PowerShell script extensions. Support for those is slated for
removal in Playnite 11, at which point this would need to become a C# `GenericPlugin`
instead.