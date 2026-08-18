# Playnite kit - RetroArch (Steam) + RomM - install guide

`dist/` contains two independent things to drop into your Playnite install.
You need both for cores to auto-download; only the first is required to get
RetroArch (Steam) working as a regular emulator.

## 1. RetroArch (Steam) emulator profile (`dist/RetroArchSteam/`)

Playnite emulator definition that launches games through Steam
(`steam.exe -applaunch 1118310 ...`) instead of `retroarch.exe` directly, so
Steam Input, the overlay, and playtime tracking keep working - this matters
on a handheld like the ROG Ally where a direct exe launch bypasses all of
that.

**Requirements**
- RetroArch installed through Steam: https://store.steampowered.com/app/1118310

**Install**
1. Copy the whole `RetroArchSteam` folder into
   `<Playnite install dir>\Emulation\Emulators\`.
2. Restart Playnite. "RetroArch (Steam)" should now show up under
   Library > Emulators.
3. Open it and set **Installation Directory** to RetroArch's folder inside
   your Steam library, e.g.
   `<Steam library>\steamapps\common\RetroArch`.
4. Assign the emulator (and the profile matching each platform's core) to
   your games as usual, either per-game or through Playnite's default
   emulation settings for a platform.

**Known limitation:** whether Playnite accepts this Installation Directory /
executable split (`steam.exe` living outside the folder that holds
`cores\`) for a real, end-to-end game launch hasn't been confirmed on
hardware yet - only that the emulator and its profiles show up correctly.
If launches fail, check Playnite's log first.

## 2. PlayniteRetroarchRommKit extension (`dist/PlayniteRetroarchRommKit/`)

Playnite script extension that hooks into game start/stop for the
"RetroArch (Steam)" emulator above (matched by its built-in config id
`retroarch_steam`, so it only activates for games using that emulator):

- **On game start:** downloads the libretro core the launched profile needs
  from the [libretro buildbot](https://buildbot.libretro.com/nightly/windows/x86_64/latest/)
  if it isn't already present in RetroArch's `cores\` folder - the Steam
  build has no built-in core updater, unlike standalone RetroArch.
- **On game stop:** intended to sync save files with a self-hosted RomM
  server. **Not implemented yet** - installing the extension today only
  gets you automatic core downloads.

**Requirements**
- Playnite 10.x with PowerShell script extensions (this support is slated
  for removal in Playnite 11).
- The RetroArch (Steam) emulator profile above, already configured.

**Install**
1. Copy the whole `PlayniteRetroarchRommKit` folder into
   `<Playnite install dir>\Extensions\`.
2. Restart Playnite.
3. Launch a game through "RetroArch (Steam)" - if its core is missing, you
   should see a "Core '...' not found. Downloading..." message before the
   game starts.

## Uninstall

Delete `<Playnite install dir>\Emulation\Emulators\RetroArchSteam` and/or
`<Playnite install dir>\Extensions\PlayniteRetroarchRommKit`, then restart
Playnite.
