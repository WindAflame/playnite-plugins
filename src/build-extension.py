"""
Copy the PlayniteRetroarchRommKit script extension source into dist/, ready
to be dropped into <Playnite install dir>/Extensions/.

Unlike convert-retroarch-to-steam-compatiblity.py, there's no fetch/transform
step here - src/extension/PlayniteRetroarchRommKit is delivered as-is. This
script only exists so dist/ stays build output and never holds hand-edited
source directly.
"""

import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = REPO_ROOT / "src" / "extension" / "PlayniteRetroarchRommKit"
OUTPUT_DIR = REPO_ROOT / "dist" / "PlayniteRetroarchRommKit"


def main() -> int:
    if not SOURCE_DIR.is_dir():
        print(f"Source directory not found: {SOURCE_DIR}", file=sys.stderr)
        return 1

    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    shutil.copytree(SOURCE_DIR, OUTPUT_DIR)

    print(f"Copied {SOURCE_DIR} to {OUTPUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
