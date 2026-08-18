# Playnite script extension - hooks fetch-core/save-sync into the RetroArch
# (Steam) emulator profile (Id: retroarch_steam in emulator.yaml) so the user
# never has to run the .ps1 scripts by hand.
#
# OnGameStarting/OnGameStopped fire for every game in the library, so each
# handler first checks whether the game's play action actually targets the
# retroarch_steam emulator before doing anything. Playnite invokes these two
# functions as scriptblocks detached from the rest of this module, so they
# can't call sibling functions defined here (confirmed: doing so raises
# "not recognized as a cmdlet" at runtime even though the function is right
# there in the same file) - the matching logic is therefore inlined in both
# instead of shared through a helper.

function OnGameStarting()
{
    param($evenArgs)

    $emulator = $PlayniteApi.Database.Emulators | Where-Object { $_.BuiltInConfigId -eq "retroarch_steam" } | Select-Object -First 1
    if ($null -eq $emulator)
    {
        return
    }

    $playAction = $evenArgs.Game.GameActions | Where-Object { $_.IsPlayAction -eq $true } | Select-Object -First 1
    if (($null -eq $playAction) -or
        ($playAction.Type -ne "Emulator") -or
        ($playAction.EmulatorId -ne $emulator.Id))
    {
        return
    }

    & "$PSScriptRoot\Scripts\fetch-core.ps1" -PlayniteApi $PlayniteApi -Emulator $emulator -EmulatorProfileId $playAction.EmulatorProfileId
    & "$PSScriptRoot\Scripts\pull-sync-save.ps1"
}

function OnGameStopped()
{
    param($evenArgs)

    $emulator = $PlayniteApi.Database.Emulators | Where-Object { $_.BuiltInConfigId -eq "retroarch_steam" } | Select-Object -First 1
    if ($null -eq $emulator)
    {
        return
    }

    $playAction = $evenArgs.Game.GameActions | Where-Object { $_.IsPlayAction -eq $true } | Select-Object -First 1
    if (($null -eq $playAction) -or
        ($playAction.Type -ne "Emulator") -or
        ($playAction.EmulatorId -ne $emulator.Id))
    {
        return
    }

    & "$PSScriptRoot\Scripts\push-sync-save.ps1"
}

Export-ModuleMember -Function OnGameStarting, OnGameStopped
