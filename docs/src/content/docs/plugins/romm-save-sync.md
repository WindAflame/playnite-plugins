---
title: RomM Save Sync
description: Status and design notes for the (not yet implemented) RomM save-sync plugin.
---

:::caution[Not implemented yet]
This plugin is a scaffold only. The hooks exist and are wired up, but the actual save/state
sync logic is not written yet — see the source for the full TODO list.
:::

Once implemented, this plugin will sync saves/states with a self-hosted
[RomM](https://github.com/rommapp/romm) server on game start/exit, for games launched
through the [RetroArch (Steam)](/plugins/retroarch-steam/) plugin.

It depends on the third-party [RomM Library
Importer](https://github.com/rommapp/playnite-plugin) extension for RomM credentials (API
token or user:pwd) instead of asking for them again.

## Design notes for contributors

See the TODO comments in `plugins/PlayniteRommSaveSyncKit/` for the confirmed integration
point and open questions:

- `main.psm1` — hook wiring (`OnGameStarting` / `OnGameStopped`) and the emulator-matching
  logic, copied as-is from the RetroArch (Steam) plugin.
- `Scripts/Get-RommCredentials.ps1` — reading credentials from the RomM Library Importer's
  settings file (`ExtensionsData\<its guid>\config.json`).
- `Scripts/pull-sync-save.ps1` / `Scripts/push-sync-save.ps1` — the actual sync logic
  (not yet implemented), and the open questions around RomM API endpoints and save/state
  file matching.

Save-sync reference implementation (a standalone desktop app doing the same sync outside
Playnite, not a Playnite extension):
https://github.com/Covin90/romm-retroarch-sync
