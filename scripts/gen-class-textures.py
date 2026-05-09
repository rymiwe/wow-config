"""Generate subtle class-themed chat panel textures.

Each texture is a low-contrast organic pattern in the class color, designed to
be readable as a chat backdrop (text contrast wins over decoration). 256x128
TGA RGBA - small enough that ElvUI tiles or stretches it cleanly.

Output: ChatPanelThemes/Media/<class>.tga
"""

from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import random
import math

OUT_DIR = Path(__file__).parent.parent / "_anniversary_" / "Interface" / "AddOns" / "ChatPanelThemes" / "Media"
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H = 256, 128

# Per-class palette: (R, G, B) accent color (low saturation)
CLASS_COLORS = {
    "druid":   (110, 180, 90),     # leaf green
    "warrior": (180, 70, 60),      # blood red
    "paladin": (200, 170, 80),     # gold
    "shaman":  (60, 130, 200),     # elemental blue
    "mage":    (130, 190, 230),    # frost cyan
    "priest":  (220, 220, 200),    # holy white-gold
    "rogue":   (180, 175, 130),    # leather tan
    "hunter":  (140, 100, 60),     # weathered wood
    "warlock": (130, 80, 180),     # fel purple
}

def draw_leaf(draw, cx, cy, size, angle, color, alpha):
    """A simple leaf shape: two arcs forming a pointed oval."""
    fill = color + (alpha,)
    for i in range(int(size)):
        # leaf is symmetric around its long axis
        t = i / size
        w = math.sin(t * math.pi) * size * 0.35
        x = cx + math.cos(angle) * (i - size/2)
        y = cy + math.sin(angle) * (i - size/2)
        draw.ellipse(
            (x - w, y - w*0.5, x + w, y + w*0.5),
            fill=fill,
        )

def gen_druid():
    """Druid: scattered leaf shapes on FULLY TRANSPARENT base.
    Texture is just the leaf pattern - ElvUI's panel color provides the
    backdrop, so panel feel and chat readability stay tunable in /ec.
    Vertically flipped before save because Pillow writes TGA bottom-up
    and WoW expects top-down."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = CLASS_COLORS["druid"]
    random.seed(42)
    # Higher density + higher alpha = more distinct pattern. The leaves are
    # the WHOLE texture now (no dark base), so we want them clearly visible.
    for _ in range(35):
        cx = random.randint(-10, W + 10)
        cy = random.randint(-10, H + 10)
        size = random.randint(20, 50)
        angle = random.uniform(0, math.pi * 2)
        alpha = random.randint(140, 220)
        draw_leaf(draw, cx, cy, size, angle, color, alpha)
    img = img.filter(ImageFilter.GaussianBlur(radius=0.8))
    img = img.transpose(Image.FLIP_TOP_BOTTOM)
    return img

def gen_generic(class_name, base_dark, density=20):
    """Fallback: noise + scattered soft blobs in class color."""
    color = CLASS_COLORS[class_name]
    img = Image.new("RGBA", (W, H), base_dark + (255,))
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    random.seed(hash(class_name) & 0xFFFF)
    for _ in range(density):
        cx = random.randint(-10, W + 10)
        cy = random.randint(-10, H + 10)
        r = random.randint(8, 30)
        a = random.randint(15, 35)
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color + (a,))
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=2.5))
    return Image.alpha_composite(img, overlay)

# Generate Druid (POC)
druid = gen_druid()
druid.save(OUT_DIR / "druid.tga")
print(f"Wrote {OUT_DIR / 'druid.tga'} ({druid.size})")
