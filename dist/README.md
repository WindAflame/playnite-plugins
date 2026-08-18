# Playnite kit - RetroArch (Steam) - install guide

`dist/PlayniteRetroArchSteamKit/` is the only thing you need to drop into your
Playnite install. It sets up the "RetroArch (Steam)" emulator itself (~100
profiles, one per libretro core) and downloads missing cores automatically -
no manual `emulator.yaml` drop, no Installation Directory guesswork, no
symlink. It does not touch saves or RomM at all - that's a separate,
not-yet-developed extension.

## Requirements

- RetroArch installed through Steam: https://store.steampowered.com/app/1118310
- Playnite 10.x with PowerShell script extensions (this support is slated
  for removal in Playnite 11).

## Install

1. Copy the whole `PlayniteRetroArchSteamKit` folder into
   `<Playnite install dir>\Extensions\`.
2. Restart Playnite.
3. Create the emulator shell once: Library > Emulators > Add > **Custom
   emulator**, name it exactly `RetroArch (Steam)`, save. (Playnite's
   scripting API can't create a new emulator entity by itself - it can only
   sync profiles into one that already exists, so this one step stays
   manual.)
4. Main menu > **"Sync RetroArch (Steam) profiles"**. A dialog confirms how
   many profiles were created/updated. Re-run this any time (e.g. after a
   RetroArch update) to refresh the profile list.
5. Assign the emulator (and the profile matching each platform's core) to
   your games as usual, either per-game or through Playnite's default
   emulation settings for a platform.
6. Launch a game - if its core is missing, you should see a "Core '...' not
   found. Downloading..." message before the game starts.

## Troubleshooting

- **"Sync" says RetroArch wasn't found:** it looks for RetroArch under
  `steamapps\common\RetroArch` in every Steam library listed in
  `steamapps\libraryfolders.vdf`. Make sure RetroArch is actually installed
  through Steam first.
- **No such emulator / sync says it doesn't exist:** the Custom emulator
  must be named exactly `RetroArch (Steam)` (step 3 above) before syncing.
- **Core doesn't download / no visible error:** Playnite runs
  `OnGameStarting` as an isolated scriptblock with no console attached, so
  errors don't surface anywhere visible by default. Use Playnite's built-in
  debug console (main menu > Extensions, `Ctrl+V` then Enter to load
  `$PlayniteApi`) to call the scripts under `Scripts\` directly and see
  their output.

## Uninstall

Delete `<Playnite install dir>\Extensions\PlayniteRetroArchSteamKit` and the
"RetroArch (Steam)" emulator (Library > Emulators), then restart Playnite.
