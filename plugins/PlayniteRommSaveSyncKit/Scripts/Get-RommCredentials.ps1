# TODO (not implemented): read connection info from the "RomM Library
# Importer" extension (https://github.com/rommapp/playnite-plugin) instead
# of asking the user to enter RomM credentials a second time.
#
# That extension is a compiled C# GameLibrary plugin, not something this
# script extension can call into directly - the only viable integration
# point is its settings file on disk:
#
#   %AppData%\Playnite\ExtensionsData\<its GUID, without the "RomM_" name
#   prefix Playnite shows elsewhere - e.g. "9700aa21-447d-41b4-a989-acd38f407d9f"
#   for the id "RomM_9700aa21-447d-41b4-a989-acd38f407d9f">\config.json
#
# Verified fields present in that file (values redacted, keys/shapes are
# real - inspected live on 2026-08-19):
#   RomMHost           - server base URL
#   RomMClientToken    - API token, used when UseBasicAuth is false
#   UseBasicAuth        - bool; when true, use RomMUsername/RomMPassword
#                          instead of the token (both empty when unused)
#   RomMUsername / RomMPassword
#   RomMUser            - display username, not itself a credential
#   Mappings[]          - EmulatorId / EmulatorProfileId / RomMPlatformId /
#                          DestinationPath per configured platform mapping;
#                          could let us reuse its RomM platform IDs instead
#                          of re-deriving them
#   RomMPlatforms[]     - cached RomM platform list (id, slug, name, ...)
#
# TODO: confirm this file's location/id doesn't change across RomM Library
# Importer versions before depending on it, and decide the fallback UX if
# it's not installed or not yet configured (this extension should probably
# refuse to run rather than ask for credentials itself, to avoid storing a
# second copy of the user's RomM password/token).
#
# TODO: figure out whether RomMClientToken needs any additional
# Authorization header formatting (e.g. "Bearer <token>") - not verified,
# check RomM's API docs / the RomM Library Importer source before assuming.

param(
    [Parameter(Mandatory)]
    [string]$PlayniteDataDir  # e.g. Join-Path $env:LOCALAPPDATA "Playnite" - TODO: confirm how a script extension should resolve this (is there a $PlayniteApi.Paths.* for it, rather than hardcoding %LOCALAPPDATA%\Playnite?).
)

throw "Not implemented - see TODOs in this file."
