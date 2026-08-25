"""
Pack every plugin already copied into dist/ (see build-extension.py) into a
.pext file under dist/pext/, using Playnite's own Toolbox.exe.

Runs the exact same packing loop on a dev machine and in CI (release.yml) -
the only difference between the two is where Toolbox.exe comes from: CI
downloads a pinned Playnite release, a dev machine points --toolbox at an
existing Playnite install.

Reads the list of plugins from plugins/ (not by listing dist/'s
subdirectories) so it doesn't try to pack unrelated dist/ output that isn't
a plugin, like docs/ or its own pext/ output folder.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PLUGINS_DIR = REPO_ROOT / "plugins"
DIST_DIR = REPO_ROOT / "dist"
PEXT_DIR = DIST_DIR / "pext"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--toolbox",
        default=os.environ.get("PLAYNITE_TOOLBOX"),
        help="Path to Playnite's Toolbox.exe (defaults to the PLAYNITE_TOOLBOX env var).",
    )
    args = parser.parse_args()

    if not args.toolbox:
        print(
            "No Toolbox.exe path given - pass --toolbox <path> or set the "
            "PLAYNITE_TOOLBOX env var to the Toolbox.exe of a Playnite install.",
            file=sys.stderr,
        )
        return 1

    toolbox_exe = Path(args.toolbox)
    if not toolbox_exe.is_file():
        print(f"Toolbox.exe not found at '{toolbox_exe}'.", file=sys.stderr)
        return 1

    if not PLUGINS_DIR.is_dir():
        print(f"Plugins directory not found: {PLUGINS_DIR}", file=sys.stderr)
        return 1

    plugin_names = [d.name for d in PLUGINS_DIR.iterdir() if d.is_dir()]
    if not plugin_names:
        print(f"No plugin folders found under {PLUGINS_DIR}", file=sys.stderr)
        return 1

    PEXT_DIR.mkdir(parents=True, exist_ok=True)

    for name in plugin_names:
        plugin_dist_dir = DIST_DIR / name
        if not plugin_dist_dir.is_dir():
            print(
                f"'{plugin_dist_dir}' not found - run tools/build-extension.py first.",
                file=sys.stderr,
            )
            return 1

        subprocess.run(
            [str(toolbox_exe), "pack", str(plugin_dist_dir), str(PEXT_DIR)],
            check=True,
        )
        print(f"Packed {plugin_dist_dir} into {PEXT_DIR}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
