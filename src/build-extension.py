"""
Copy every script extension under src/extension/ into dist/, ready to be
dropped into <Playnite install dir>/Extensions/.

There's no fetch/transform step here - each src/extension/<name> folder is
delivered as-is. This script only exists so dist/ stays build output and
never holds hand-edited source directly. Loops over every extension folder
so adding a new one (e.g. the future RomM save-sync extension) doesn't
require touching this script.
"""

import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
EXTENSIONS_DIR = REPO_ROOT / "src" / "extension"
DIST_DIR = REPO_ROOT / "dist"


def main() -> int:
    if not EXTENSIONS_DIR.is_dir():
        print(f"Extensions directory not found: {EXTENSIONS_DIR}", file=sys.stderr)
        return 1

    extension_dirs = [d for d in EXTENSIONS_DIR.iterdir() if d.is_dir()]
    if not extension_dirs:
        print(f"No extension folders found under {EXTENSIONS_DIR}", file=sys.stderr)
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
