# TODO (not implemented): pull the newest save/state for the launched game
# from RomM into RetroArch's local save folder, before the game actually
# starts. Called from main.psm1's OnGameStarting - see the TODOs there for
# how $Emulator/$EmulatorProfileId/$Game get passed in.
#
# Approach, inspired by https://github.com/Covin90/romm-retroarch-sync
# (a standalone desktop app doing the same sync, not a Playnite extension -
# re-read its actual source under /src before implementing, the README
# alone doesn't document the API calls or matching logic):
#
# 1. TODO: get RomM host + auth from Get-RommCredentials.ps1 (or wherever
#    that lands).
# 2. TODO: resolve RetroArch's save directory. Two sources, in order:
#      a. Auto-detect: if the "RetroArch (Steam)" emulator (from
#         PlayniteRetroArchSteamKit) exists, its InstallDir + "\saves" and
#         "\states" are almost certainly right (same folder
#         sync-emulator-profiles.ps1 resolves via the registry/vdf lookup).
#      b. Manual override: TODO add a GetMainMenuItems action (or per-game
#         setting?) letting the user point at a different saves/states
#         folder, for setups where RetroArch's default paths were changed
#         (custom retroarch.cfg savefile_directory / savestate_directory -
#         TODO: consider reading those instead of assuming the default
#         <RetroArch>\saves\ subfolder).
# 3. TODO: figure out how to identify which RomM library entry corresponds
#    to $Game - by ROM filename? Playnite GameId stored as a RomM field?
#    Check what identifiers the RomM Library Importer already stores on
#    imported games (it owns Game.GameId/PluginId for RomM-sourced games -
#    reuse that instead of re-matching by filename if possible).
# 4. TODO: call RomM's API to list/download that game's save(s) - find the
#    actual endpoints (RomM API docs / romm-retroarch-sync source), don't
#    guess a URL shape here.
# 5. TODO: conflict resolution - compare remote save's timestamp against
#    the local file's (if one already exists) and only overwrite if the
#    remote one is newer. Skip entirely if there's no local file and no
#    remote save either.

param(
    [Parameter(Mandatory)]
    $PlayniteApi,
    [Parameter(Mandatory)]
    $Emulator,
    [Parameter(Mandatory)]
    [string]$EmulatorProfileId,
    [Parameter(Mandatory)]
    $Game
)

Write-Warning "pull-sync-save.ps1 is not implemented yet - RomM save sync is a work in progress."
exit 0
