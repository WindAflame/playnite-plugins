# Playnite script extension - hooks fetch-core/save-sync into the RetroArch
# (Steam) emulator profile (Id: retroarch_steam in emulator.yaml) so the user
# never has to run the .ps1 scripts by hand.
#
# OnGameStarting/OnGameStopped fire for every game in the library, so each
# handler first checks whether the game's play action actually targets the
# retroarch_steam emulator before doing anything.

$script:RetroArchSteamEmulatorId = $null

function Get-RetroArchSteamEmulatorId()
{
    if ($null -eq $script:RetroArchSteamEmulatorId)
    {
        $emulator = $PlayniteApi.Database.Emulators |
            Where-Object { $_.BuiltInConfigId -eq "retroarch_steam" } |
            Select-Object -First 1

        if ($null -ne $emulator)
        {
            $script:RetroArchSteamEmulatorId = $emulator.Id
        }
    }

    return $script:RetroArchSteamEmulatorId
}

function Test-IsRetroArchSteamGame($game)
{
    $emulatorId = Get-RetroArchSteamEmulatorId
    if ($null -eq $emulatorId)
    {
        return $false
    }

    $playAction = $game.GameActions | Where-Object { $_.IsPlayAction -eq $true } | Select-Object -First 1

    return ($null -ne $playAction) -and
        ($playAction.Type -eq "Emulator") -and
        ($playAction.EmulatorId -eq $emulatorId)
}

function OnGameStarting()
{
    param($evenArgs)

    if (-not (Test-IsRetroArchSteamGame $evenArgs.Game))
    {
        return
    }

    & "$PSScriptRoot\Scripts\fetch-core.ps1"
    & "$PSScriptRoot\Scripts\pull-sync-save.ps1"
}

function OnGameStopped()
{
    param($evenArgs)

    if (-not (Test-IsRetroArchSteamGame $evenArgs.Game))
    {
        return
    }

    & "$PSScriptRoot\Scripts\push-sync-save.ps1"
}

Export-ModuleMember -Function OnGameStarting, OnGameStopped
