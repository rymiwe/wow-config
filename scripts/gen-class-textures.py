"""Generate subtle class-themed (and per-character custom) chat panel textures.

Output goes to ChatPanelThemes/Media/<name>.tga as 512x256 TGA RGBA, transparent
base so ElvUI's panelColor controls overall darkness/transparency.
"""

from PIL import Image, ImageDraw, ImageFilter, ImageChops
from pathlib import Path
import random
import math

OUT_DIR = Path(__file__).parent.parent / "_anniversary_" / "Interface" / "AddOns" / "ChatPanelThemes" / "Media"
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H = 512, 256

CLASS_COLORS = {
    "druid":   (110, 180, 90),
    "warrior": (180, 70, 60),
    "paladin": (200, 170, 80),
    "shaman":  (60, 130, 200),
    "mage":    (130, 190, 230),
    "priest":  (220, 220, 200),
    "rogue":   (180, 175, 130),
    "hunter":  (140, 100, 60),
    "warlock": (130, 80, 180),
}

# ---------------------------------------------------------------------------
# Shape primitives
# ---------------------------------------------------------------------------

def draw_leaf(draw, cx, cy, size, angle, color, alpha):
    fill = color + (alpha,)
    for i in range(int(size)):
        t = i / size
        w = math.sin(t * math.pi) * size * 0.35
        x = cx + math.cos(angle) * (i - size/2)
        y = cy + math.sin(angle) * (i - size/2)
        draw.ellipse((x - w, y - w*0.5, x + w, y + w*0.5), fill=fill)

def draw_strawberry(img, cx, cy, size, alpha=235):
    """Bright red strawberry with green calyx and yellow seeds.
    Drawn onto a small RGBA layer then composited so seeds layer cleanly."""
    s = int(size)
    layer = Image.new("RGBA", (s*2+8, s*2+8), (0,0,0,0))
    d = ImageDraw.Draw(layer)
    ox, oy = s + 4, s + 4  # local center
    red = (215, 55, 55, alpha)
    red_dark = (160, 35, 35, alpha)
    green = (95, 165, 70, alpha)
    green_dark = (60, 120, 50, alpha)
    seed = (255, 235, 130, alpha)
    # Body: rounded teardrop pointing down
    body_pts = [
        (ox - s*0.42, oy - s*0.25),
        (ox - s*0.48, oy + s*0.05),
        (ox - s*0.30, oy + s*0.45),
        (ox - s*0.05, oy + s*0.58),
        (ox + s*0.05, oy + s*0.58),
        (ox + s*0.30, oy + s*0.45),
        (ox + s*0.48, oy + s*0.05),
        (ox + s*0.42, oy - s*0.25),
        (ox + s*0.20, oy - s*0.35),
        (ox - s*0.20, oy - s*0.35),
    ]
    d.polygon(body_pts, fill=red)
    # Subtle shading - darker bottom
    d.polygon([
        (ox - s*0.30, oy + s*0.45),
        (ox - s*0.05, oy + s*0.58),
        (ox + s*0.05, oy + s*0.58),
        (ox + s*0.30, oy + s*0.45),
    ], fill=red_dark)
    # Seeds (small yellow dots)
    random.seed(int(cx*7 + cy*13))
    for _ in range(6):
        sx = ox + random.uniform(-s*0.32, s*0.32)
        sy = oy + random.uniform(-s*0.20, s*0.45)
        d.ellipse((sx-1.5, sy-2.5, sx+1.5, sy+2.5), fill=seed)
    # Calyx (green star on top) - 5 pointed leaves
    for i in range(5):
        a = -math.pi/2 + (i - 2) * 0.55
        tx = ox + math.cos(a) * s*0.30
        ty = oy - s*0.30 + math.sin(a) * s*0.15
        d.polygon([
            (ox + math.cos(a + 0.3) * s*0.10, oy - s*0.30 + math.sin(a + 0.3) * s*0.05),
            (tx, ty),
            (ox + math.cos(a - 0.3) * s*0.10, oy - s*0.30 + math.sin(a - 0.3) * s*0.05),
        ], fill=green)
    # Center stem highlight
    d.ellipse((ox-s*0.06, oy-s*0.36, ox+s*0.06, oy-s*0.26), fill=green_dark)
    # Composite onto target image
    img.alpha_composite(layer, (int(cx) - ox, int(cy) - oy))

def draw_pug(img, cx, cy, size, alpha=240):
    """Cute pug face: floppy ears, smushed nose, bug eyes."""
    s = int(size)
    layer = Image.new("RGBA", (s*2+8, s*2+8), (0,0,0,0))
    d = ImageDraw.Draw(layer)
    ox, oy = s + 4, s + 4
    cream = (215, 195, 155, alpha)
    cream_dark = (175, 150, 110, alpha)
    dark = (45, 30, 25, alpha)
    pink = (230, 165, 165, alpha)
    # Floppy ears (triangle shapes)
    d.polygon([(ox-s*0.55, oy-s*0.15), (ox-s*0.40, oy-s*0.55), (ox-s*0.20, oy-s*0.10)], fill=dark)
    d.polygon([(ox+s*0.55, oy-s*0.15), (ox+s*0.40, oy-s*0.55), (ox+s*0.20, oy-s*0.10)], fill=dark)
    # Head (rounded square-ish)
    d.ellipse((ox-s*0.45, oy-s*0.30, ox+s*0.45, oy+s*0.55), fill=cream)
    # Forehead wrinkle
    d.line([(ox-s*0.18, oy-s*0.08), (ox+s*0.18, oy-s*0.08)], fill=cream_dark, width=2)
    d.line([(ox-s*0.20, oy-s*0.02), (ox+s*0.20, oy-s*0.02)], fill=cream_dark, width=2)
    # Black mask around eyes/snout
    d.ellipse((ox-s*0.32, oy+s*0.05, ox+s*0.32, oy+s*0.45), fill=dark)
    # Eyes (big and bulgy)
    d.ellipse((ox-s*0.28, oy+s*0.05, ox-s*0.08, oy+s*0.25), fill=(250, 250, 245, alpha))
    d.ellipse((ox+s*0.08, oy+s*0.05, ox+s*0.28, oy+s*0.25), fill=(250, 250, 245, alpha))
    d.ellipse((ox-s*0.22, oy+s*0.10, ox-s*0.12, oy+s*0.20), fill=dark)
    d.ellipse((ox+s*0.12, oy+s*0.10, ox+s*0.22, oy+s*0.20), fill=dark)
    # Smushed nose
    d.ellipse((ox-s*0.10, oy+s*0.25, ox+s*0.10, oy+s*0.38), fill=dark)
    # Tongue
    d.ellipse((ox-s*0.06, oy+s*0.40, ox+s*0.06, oy+s*0.50), fill=pink)
    img.alpha_composite(layer, (int(cx) - ox, int(cy) - oy))

def draw_crescent_moon(img, cx, cy, size, alpha=180):
    """Crescent moon - large circle with offset cutout."""
    s = int(size)
    layer = Image.new("RGBA", (s*2+8, s*2+8), (0,0,0,0))
    d = ImageDraw.Draw(layer)
    ox, oy = s + 4, s + 4
    pale = (245, 240, 215, alpha)
    # Full circle
    d.ellipse((ox-s, oy-s, ox+s, oy+s), fill=pale)
    # Cutout: smaller circle offset to upper-right makes the crescent
    cut = Image.new("RGBA", (s*2+8, s*2+8), (0,0,0,0))
    cd = ImageDraw.Draw(cut)
    cd.ellipse((ox-s*0.45, oy-s*1.05, ox+s*1.55, oy+s*0.95), fill=(0,0,0,255))
    # Apply cutout: where cut alpha > 0, set layer alpha to 0
    layer_pixels = layer.load()
    cut_pixels = cut.load()
    for x in range(layer.width):
        for y in range(layer.height):
            if cut_pixels[x,y][3] > 0:
                layer_pixels[x,y] = (0,0,0,0)
    img.alpha_composite(layer, (int(cx) - ox, int(cy) - oy))

# ---------------------------------------------------------------------------
# Texture compositions
# ---------------------------------------------------------------------------

def gen_druid():
    """Generic Druid: scattered leaves, transparent base."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = CLASS_COLORS["druid"]
    random.seed(42)
    for _ in range(35):
        cx = random.randint(-10, W + 10)
        cy = random.randint(-10, H + 10)
        size = random.randint(20, 50)
        angle = random.uniform(0, math.pi * 2)
        alpha = random.randint(140, 220)
        draw_leaf(draw, cx, cy, size, angle, color, alpha)
    img = img.filter(ImageFilter.GaussianBlur(radius=0.8))
    # Pillow TGA writes top-down already; do NOT flip (was inverting shapes).
    return img

def gen_ocisly():
    """Ocisly (kid's Balance Druid): pugs + strawberries + crescent moons.
    Strawberries dominate (8), pugs sprinkled (3), moons accent (3).
    Transparent base so ElvUI panel color shows through."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    random.seed(2025)
    # Crescent moons first (background layer in spirit)
    moon_positions = [(80, 50), (340, 70), (440, 200)]
    for cx, cy in moon_positions:
        size = random.randint(28, 38)
        draw_crescent_moon(img, cx, cy, size, alpha=130)
    # Strawberries scattered
    used = list(moon_positions)
    for _ in range(8):
        for _ in range(20):  # try up to 20 times to find non-overlapping spot
            cx = random.randint(40, W - 40)
            cy = random.randint(40, H - 40)
            if all((cx-ux)**2 + (cy-uy)**2 > 70**2 for ux, uy in used):
                used.append((cx, cy))
                break
        size = random.randint(28, 40)
        draw_strawberry(img, cx, cy, size)
    # Pugs (fewer, larger)
    for _ in range(3):
        for _ in range(20):
            cx = random.randint(50, W - 50)
            cy = random.randint(50, H - 50)
            if all((cx-ux)**2 + (cy-uy)**2 > 90**2 for ux, uy in used):
                used.append((cx, cy))
                break
        size = random.randint(38, 50)
        draw_pug(img, cx, cy, size)
    # WoW reads TGA top-down; Pillow writes bottom-up.
    # Pillow TGA writes top-down already; do NOT flip (was inverting shapes).
    return img

# ---------------------------------------------------------------------------
# Render
# ---------------------------------------------------------------------------

druid = gen_druid()
druid.save(OUT_DIR / "druid.tga")
print(f"Wrote {OUT_DIR / 'druid.tga'} ({druid.size})")

ocisly = gen_ocisly()
ocisly.save(OUT_DIR / "ocisly.tga")
print(f"Wrote {OUT_DIR / 'ocisly.tga'} ({ocisly.size})")
