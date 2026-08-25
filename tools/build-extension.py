"""
Copy every Playnite plugin under plugins/ into dist/, ready to be dropped
into <Playnite install dir>/Extensions/.

There's no fetch/transform step here - each plugins/<name> folder is
delivered as-is. This script only exists so dist/ stays build output and
never holds hand-edited source directly. Loops over every plugin folder so
adding a new one doesn't require touching this script.
"""

import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PLUGINS_DIR = REPO_ROOT / "plugins"
DIST_DIR = REPO_ROOT / "dist"


def main() -> int:
    if not PLUGINS_DIR.is_dir():
        print(f"Plugins directory not found: {PLUGINS_DIR}", file=sys.stderr)
        return 1

    extension_dirs = [d for d in PLUGINS_DIR.iterdir() if d.is_dir()]
    if not extension_dirs:
        print(f"No plugin folders found under {PLUGINS_DIR}", file=sys.stderr)
        return 1

    for source_dir in extension_dirs:
        output_dir = DIST_DIR / source_dir.name
        if output_dir.exists():
            shutil.rmtree(output_dir)
        shutil.copytree(source_dir, output_dir)
        print(f"Copied {source_dir} to {output_dir}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
