# Creates/updates the "RetroArch (Steam)" Custom emulator profiles from
# Playnite's own bundled "retroarch" built-in definition, so games launch
# through steam.exe -applaunch instead of retroarch.exe directly (keeps
# Steam Input/overlay/playtime tracking working). Custom profiles set
# Executable/Arguments directly, so - unlike a built-in-style emulator.yaml
# drop-in - there's no Installation Directory / StartupExecutable regex
# conflict between finding steam.exe and finding the cores\ folder, and no
# manual per-core profile entry needed.
#
# The "RetroArch (Steam)" emulator itself must already exist (Library >
# Emulators > Add > Custom emulator, name it exactly "RetroArch (Steam)") -
# $PlayniteApi.Database.Emulators.Add(...) throws NotSupportedException for
# every overload when called from a script, so creating the emulator entity
# itself isn't possible here; only syncing its CustomProfiles is.
#
# TrackingMode = Directory / TrackingPath = RetroArch's install folder is set
# on every generated profile so Playnite watches for any process running
# from that folder instead of the short-lived "steam.exe -applaunch" stub
# (which exits almost immediately after handing off to the already-running
# Steam client) - otherwise Playnite thinks the game exited right away and
# re-shows its own window while the game is still starting up behind it.
# TrackingMode = ProcessName with "retroarch.exe" was tried first and
# correctly detected game start, but never detected RetroArch closing;
# Directory mode handles both correctly.
#
# InstallDir is also set on the emulator itself (not just TrackingPath on
# each profile) - fetch-core.ps1 and PlayniteRommSaveSyncKit's
# pull-sync-save.ps1 both resolve RetroArch's folder from it.

param(
    [Parameter(Mandatory)]
    $PlayniteApi
)

$emulatorProfileName = "RetroArch (Steam)"

function Get-SteamInstallation {
    $steamRegPath = "HKCU:\Software\Valve\Steam"
    if (-not (Test-Path $steamRegPath)) {
        throw "Steam installation not found in registry ($steamRegPath)."
    }

    $steamPath = (Get-ItemProperty -Path $steamRegPath -Name "SteamPath").SteamPath -replace '/', '\'
    if (-not (Test-Path $steamPath)) {
        throw "Steam path not found at '$steamPath'."
    }

    $steamExe = Join-Path $steamPath "steam.exe"
    if (-not (Test-Path $steamExe)) {
        throw "steam.exe not found at '$steamExe'."
    }

    return [pscustomobject]@{
        Path       = $steamPath
        Executable = $steamExe
    }
}

function Get-SteamLibraryPaths {
    param(
        [Parameter(Mandatory)]
        [string]$SteamPath
    )

    $libraryPaths = [System.Collections.Generic.List[string]]::new()
    $libraryPaths.Add($SteamPath)

    $libraryFoldersPath = Join-Path $SteamPath "steamapps\libraryfolders.vdf"
    if (Test-Path $libraryFoldersPath) {
        $vdfContent = Get-Content -Path $libraryFoldersPath -Raw
        $pathMatches = [regex]::Matches($vdfContent, '"path"\s+"([^"]+)"')
        foreach ($m in $pathMatches) {
            $libraryPaths.Add(($m.Groups[1].Value -replace '\\\\', '\'))
        }
    }

    return $libraryPaths | Select-Object -Unique
}

function Find-RetroArchInstallDir {
    param(
        [Parameter(Mandatory)]
        [string[]]$LibraryPaths
    )

    foreach ($lib in $LibraryPaths) {
        $candidate = Join-Path $lib "steamapps\common\RetroArch"
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "RetroArch install not found in any Steam library. Install RetroArch via Steam first (app id 1118310)."
}

function Get-PlayniteRetroArchDefinition {
    param(
        [Parameter(Mandatory)]
        $PlayniteApi
    )

    $definition = $PlayniteApi.Emulation.GetEmulator("retroarch")
    if ($null -eq $definition) {
        throw "Playnite's built-in RetroArch definition was not found."
    }
    return $definition
}

function Get-RetroArchSteamEmulator {
    param(
        [Parameter(Mandatory)]
        $PlayniteApi
    )

    $emulator = $PlayniteApi.Database.Emulators | Where-Object { $_.Name -eq $emulatorProfileName } | Select-Object -First 1
    if ($null -eq $emulator) {
        throw "No emulator named '$emulatorProfileName' found.`n`nCreate it once manually: Library > Emulators > Add > Custom emulator, name it exactly '$emulatorProfileName', save, then run this sync again."
    }
    return $emulator
}

# Creates or updates a single Custom profile from a source (built-in
# definition) profile. Returns $true when a new profile was added, $false
# when an existing one was updated.
function Sync-CustomEmulatorProfile {
    param(
        [Parameter(Mandatory)]
        $Emulator,
        [Parameter(Mandatory)]
        $SourceProfile,
        [Parameter(Mandatory)]
        [string]$SteamExe,
        [Parameter(Mandatory)]
        [string]$RetroArchDir
    )

    $existing = $Emulator.CustomProfiles | Where-Object { $_.Name -eq $SourceProfile.Name } | Select-Object -First 1
    $isNew = $null -eq $existing
    if ($isNew) {
        $existing = New-Object Playnite.SDK.Models.CustomEmulatorProfile
        $existing.Id = [guid]::NewGuid()
        $existing.Name = $SourceProfile.Name
        $Emulator.CustomProfiles.Add($existing)
    }

    $existing.Executable = $SteamExe
    $existing.Arguments = "-applaunch 1118310 $($SourceProfile.StartupArguments)"
    $existing.ImageExtensions = $SourceProfile.ImageExtensions
    $existing.TrackingMode = [Playnite.SDK.Models.TrackingMode]::Directory
    $existing.TrackingPath = $RetroArchDir

    return $isNew
}

function Sync-RetroArchSteamProfiles {
    param(
        [Parameter(Mandatory)]
        $PlayniteApi
    )

    try {
        $steam = Get-SteamInstallation
        $libraryPaths = Get-SteamLibraryPaths -SteamPath $steam.Path
        $retroArchDir = Find-RetroArchInstallDir -LibraryPaths $libraryPaths
        $definition = Get-PlayniteRetroArchDefinition -PlayniteApi $PlayniteApi
        $emulator = Get-RetroArchSteamEmulator -PlayniteApi $PlayniteApi
    } catch {
        $PlayniteApi.Dialogs.ShowMessage($_.Exception.Message)
        return
    }

    if ($null -eq $emulator.CustomProfiles) {
        $emulator.CustomProfiles = New-Object 'System.Collections.ObjectModel.ObservableCollection[Playnite.SDK.Models.CustomEmulatorProfile]'
    }
    $emulator.InstallDir = $retroArchDir

    $added = 0
    $updated = 0
    foreach ($sourceProfile in $definition.Profiles) {
        $isNew = Sync-CustomEmulatorProfile -Emulator $emulator -SourceProfile $sourceProfile -SteamExe $steam.Executable -RetroArchDir $retroArchDir
        if ($isNew) { $added++ } else { $updated++ }
    }

    try {
        $PlayniteApi.Database.Emulators.Update($emulator)
        $PlayniteApi.Dialogs.ShowMessage("$emulatorProfileName: $added new, $updated updated profile(s) synced.`nInstall dir: $retroArchDir")
    } catch {
        $PlayniteApi.Dialogs.ShowMessage("Failed to save emulator profiles: $_")
    }
}

Sync-RetroArchSteamProfiles -PlayniteApi $PlayniteApi
