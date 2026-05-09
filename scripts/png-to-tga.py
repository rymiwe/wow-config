"""Convert a PNG (or any Pillow-readable image) to TGA for ChatPanelThemes.

Usage:
    python scripts/png-to-tga.py <input.png> <character-or-class-name>

Examples:
    python scripts/png-to-tga.py ~/Downloads/druid_panel.png druid
    python scripts/png-to-tga.py C:/Users/me/Pictures/ocisly.png ocisly

The output filename is <name>.tga (lowercased), written into
_anniversary_/Interface/AddOns/ChatPanelThemes/Media/.

After conversion, ensure the name maps in ChatPanelThemes.lua:
    CHAR_TEXTURE = { Ocisly = "ocisly" }       -- per-character override
    CLASS_TEXTURE = { DRUID = "druid" }        -- per-class default
"""

from PIL import Image
from pathlib import Path
import sys

if len(sys.argv) != 3:
    print(__doc__)
    sys.exit(1)

src = Path(sys.argv[1]).expanduser()
name = sys.argv[2].lower()

if not src.exists():
    print(f"ERROR: source file not found: {src}")
    sys.exit(1)

out_dir = Path(__file__).parent.parent / "_anniversary_" / "Interface" / "AddOns" / "ChatPanelThemes" / "Media"
out_dir.mkdir(parents=True, exist_ok=True)
dst = out_dir / f"{name}.tga"

img = Image.open(src).convert("RGBA")
# 512x256 is the convention for ChatPanelThemes textures (2:1 matches ElvUI
# panel ratio). Resize if input is wildly different. Lanczos for quality.
TARGET = (512, 256)
if img.size != TARGET:
    print(f"Resizing {img.size} -> {TARGET}")
    img = img.resize(TARGET, Image.LANCZOS)

img.save(dst)
print(f"Wrote {dst} ({img.size})")
print(f"\nNext steps:")
print(f"  1. Map this texture in ChatPanelThemes.lua:")
print(f"     CHAR_TEXTURE = {{ [\"<CharacterName>\"] = \"{name}\" }}")
print(f"     OR")
print(f"     CLASS_TEXTURE = {{ <CLASS_TOKEN> = \"{name}\" }}")
print(f"  2. /rl in WoW")
