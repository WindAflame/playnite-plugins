# TODO (not implemented): push the local save/state for the game that just
# stopped up to RomM, so other devices see it. Called from main.psm1's
# OnGameStopped - see the TODOs there for how $Emulator/$EmulatorProfileId/
# $Game get passed in.
#
# Mirrors pull-sync-save.ps1's TODOs (same credential source, same
# saves/states directory resolution, same game-to-RomM-entry matching
# question) - see that file first. Additional points specific to push:
#
# 1. TODO: only push if the local save file's mtime is newer than what
#    pull-sync-save.ps1 last pulled (or than what RomM currently has) -
#    otherwise every single game stop re-uploads unchanged saves.
# 2. TODO: RetroArch writes save states as a numbered set of files
#    (game.state, game.state1, game.state2, ...) plus a .srm for the
#    battery save - decide whether v1 syncs just the .srm or also states,
#    and how multiple state slots map onto whatever RomM's save API
#    supports (single save per game? multiple?).
# 3. TODO: same "find the actual RomM upload endpoint" research as
#    pull-sync-save.ps1 - check romm-retroarch-sync's source and RomM's API
#    docs rather than guessing.

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

Write-Warning "push-sync-save.ps1 is not implemented yet - RomM save sync is a work in progress."
exit 0
