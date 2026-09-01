# Contributing

Thanks for considering a contribution to this repo.

## Before you start

- Check the [Plugins table](README.md#plugins) for the current status of each
  plugin. `RomM Save Sync` is a scaffold only — its sync logic isn't implemented
  yet, so that's the area most open to contribution. See the TODOs in
  [`plugins/PlayniteRommSaveSyncKit`](plugins/PlayniteRommSaveSyncKit).
- For anything beyond a small fix, open an issue first to discuss the change
  before writing code — it saves both of us time if the approach needs
  adjusting.

## Development setup

See the [Development](README.md#development) section of the README for the
build/preview commands (plugins use [uv](https://docs.astral.sh/uv/) + Python
tooling, the docs site uses npm workspaces).

## Making changes

- One logical change per pull request.
- Match the existing code style in the file you're editing.
- Implementation notes and non-obvious gotchas (e.g. why something is done a
  certain way) belong as comments next to the code they explain, in
  `main.psm1` / `Scripts/*.ps1` — not in the PR description only.
- If you change plugin behavior, update the relevant guide under
  [`docs/src/content/docs/plugins/`](docs/src/content/docs/plugins/).
- Run `uv run tools/build-extension.py` (and `pack-extensions.py` if you're
  testing the packed `.pext`) to confirm the plugin still builds before
  opening the PR.

## Submitting a pull request

1. Fork the repo and create a branch from `main`.
2. Make your changes and commit with a clear, descriptive message.
3. Open a pull request describing what changed and why.

## License

This project is licensed under the [PolyForm Noncommercial License
1.0.0](LICENSE) — noncommercial use only. By submitting a contribution, you
agree that it will be distributed under the same license.
