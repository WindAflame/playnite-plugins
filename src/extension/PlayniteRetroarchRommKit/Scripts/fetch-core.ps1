# Called from main.psm1 (OnGameStarting) for every RetroArch (Steam) launch.
# emulator.yaml (built-in emulator definitions) has no per-profile Scripts tab,
# so $Emulator and the profile id are received as parameters instead of being
# injected by Playnite the way they would be for a manually attached "before
# launch" script.
#
# The core name is read directly from StartupArguments
# (".. -L \"cores\xxx_libretro.dll\" ..") rather than guessed from the profile
# name, which doesn't always match the core file name (ex: "Beetle PSX HW" ->
# mednafen_psx_hw_libretro.dll). StartupArguments isn't exposed on the
# installed profile (BuiltInEmulatorProfile): it comes from the built-in
# emulator definition via $PlayniteApi.Emulation.

param(
    [Parameter(Mandatory)]
    $PlayniteApi,
    [Parameter(Mandatory)]
    $Emulator,
    [Parameter(Mandatory)]
    [string]$EmulatorProfileId
)

$builtinProfile = $Emulator.BuiltinProfiles | Where-Object { $_.Id -eq $EmulatorProfileId } | Select-Object -First 1
if ($null -eq $builtinProfile) {
    Write-Warning "Emulator profile '$EmulatorProfileId' not found on '$($Emulator.Name)'."
    exit 0
}

$definition = $PlayniteApi.Emulation.GetEmulator($Emulator.BuiltInConfigId)
$definitionProfile = $definition.Profiles | Where-Object { $_.Name -eq $builtinProfile.BuiltInProfileName } | Select-Object -First 1
if ($null -eq $definitionProfile) {
    Write-Warning "Profile definition '$($builtinProfile.BuiltInProfileName)' not found in '$($Emulator.BuiltInConfigId)'."
    exit 0
}

$match = [regex]::Match($definitionProfile.StartupArguments, 'cores\\([^"\\]+\.dll)')
if (-not $match.Success) {
    Write-Warning "Could not extract the core name from StartupArguments."
    exit 0
}
$core = $match.Groups[1].Value

$coresDir = Join-Path $Emulator.InstallDir 'cores'
$corePath = Join-Path $coresDir $core

if (Test-Path $corePath) {
    exit 0
}

Write-Host "Core '$core' not found. Downloading..."

if (-not (Test-Path $coresDir)) { New-Item -ItemType Directory -Path $coresDir -Force | Out-Null }

$zipUrl  = "https://buildbot.libretro.com/nightly/windows/x86_64/latest/$core.zip"
$zipPath = Join-Path $coresDir "$core.zip"

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $coresDir -Force
    Remove-Item $zipPath -ErrorAction SilentlyContinue
    Write-Host "Core '$core' installed successfully."
} catch {
    Write-Error "Failed to download core '$core': $_"
    exit 1
}

exit 0
