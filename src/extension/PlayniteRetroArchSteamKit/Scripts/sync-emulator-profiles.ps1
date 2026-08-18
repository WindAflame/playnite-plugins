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

param(
    [Parameter(Mandatory)]
    $PlayniteApi
)

$steamRegPath = "HKCU:\Software\Valve\Steam"
if (-not (Test-Path $steamRegPath)) {
    $PlayniteApi.Dialogs.ShowMessage("Steam installation not found in registry ($steamRegPath).")
    exit 0
}

$steamPath = (Get-ItemProperty -Path $steamRegPath -Name "SteamPath").SteamPath -replace '/', '\'
$steamExe = Join-Path $steamPath "steam.exe"
if (-not (Test-Path $steamExe)) {
    $PlayniteApi.Dialogs.ShowMessage("steam.exe not found at '$steamExe'.")
    exit 0
}

$libraryPaths = [System.Collections.Generic.List[string]]::new()
$libraryPaths.Add($steamPath)
$libraryFoldersPath = Join-Path $steamPath "steamapps\libraryfolders.vdf"
if (Test-Path $libraryFoldersPath) {
    $vdfContent = Get-Content -Path $libraryFoldersPath -Raw
    $pathMatches = [regex]::Matches($vdfContent, '"path"\s+"([^"]+)"')
    foreach ($m in $pathMatches) {
        $libraryPaths.Add(($m.Groups[1].Value -replace '\\\\', '\'))
    }
}

$retroArchDir = $null
foreach ($lib in ($libraryPaths | Select-Object -Unique)) {
    $candidate = Join-Path $lib "steamapps\common\RetroArch"
    if (Test-Path $candidate) {
        $retroArchDir = $candidate
        break
    }
}

if ($null -eq $retroArchDir) {
    $PlayniteApi.Dialogs.ShowMessage("RetroArch install not found in any Steam library. Install RetroArch via Steam first (app id 1118310).")
    exit 0
}

$definition = $PlayniteApi.Emulation.GetEmulator("retroarch")
if ($null -eq $definition) {
    $PlayniteApi.Dialogs.ShowMessage("Playnite's built-in RetroArch definition was not found.")
    exit 0
}

$emulator = $PlayniteApi.Database.Emulators | Where-Object { $_.Name -eq "RetroArch (Steam)" } | Select-Object -First 1
if ($null -eq $emulator) {
    $PlayniteApi.Dialogs.ShowMessage("No emulator named 'RetroArch (Steam)' found.`n`nCreate it once manually: Library > Emulators > Add > Custom emulator, name it exactly 'RetroArch (Steam)', save, then run this sync again.")
    exit 0
}
$emulator.InstallDir = $retroArchDir

if ($null -eq $emulator.CustomProfiles) {
    $emulator.CustomProfiles = New-Object 'System.Collections.ObjectModel.ObservableCollection[Playnite.SDK.Models.CustomEmulatorProfile]'
}

$added = 0
$updated = 0
foreach ($sourceProfile in $definition.Profiles) {
    $existing = $emulator.CustomProfiles | Where-Object { $_.Name -eq $sourceProfile.Name } | Select-Object -First 1
    if ($null -eq $existing) {
        $existing = New-Object Playnite.SDK.Models.CustomEmulatorProfile
        $existing.Id = [guid]::NewGuid()
        $existing.Name = $sourceProfile.Name
        $emulator.CustomProfiles.Add($existing)
        $added++
    } else {
        $updated++
    }

    $existing.Executable = $steamExe
    $existing.Arguments = "-applaunch 1118310 $($sourceProfile.StartupArguments)"
    $existing.ImageExtensions = $sourceProfile.ImageExtensions
    $existing.TrackingMode = [Playnite.SDK.Models.TrackingMode]::Directory
    $existing.TrackingPath = $retroArchDir
}

try {
    $PlayniteApi.Database.Emulators.Update($emulator)
    $PlayniteApi.Dialogs.ShowMessage("RetroArch (Steam): $added new, $updated updated profile(s) synced.`nInstall dir: $retroArchDir")
} catch {
    $PlayniteApi.Dialogs.ShowMessage("Failed to save emulator profiles: $_")
}
