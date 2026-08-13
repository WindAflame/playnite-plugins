# Playnite kit - RetroArch Steam with save-sync through Romm

Bridges Playnite, the Steam build of RetroArch, and a self-hosted RomM server. Auto-configures emulator profiles, fetches cores on launch, and syncs saves and states on game start/exit.

## Development

- Astral/uv
- Latest python

Deps:
- RetroArch profile : https://github.com/JosefNemec/Playnite/blob/master/source/Playnite/Emulation/Emulators/RetroArch/emulator.yaml
- Save-sync : https://github.com/Covin90/romm-retroarch-sync

## RetroArch (Steam) Playnite profile

`src/convert-retroarch-to-steam-compatiblity.py` fetches Playnite's official RetroArch
emulator definition and rewrites each profile to launch through the Steam client
(`steam.exe -applaunch 1118310 ...`) instead of `retroarch.exe` directly, so Steam Input,
the overlay, and playtime tracking keep working — this matters on a handheld like the
ROG Ally where a direct exe launch bypasses all of that. Core/info folder paths don't
change: the Steam build's layout is identical to standalone, it just lacks a built-in
core updater (see `fetch-core.ps1`).

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