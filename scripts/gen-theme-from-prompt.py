"""End-to-end: prompt -> Pollinations.ai -> TGA in ChatPanelThemes/Media/.

No API key, no manual save, no UI clicks. Pollinations is a free public image
generation service (Flux model, no auth required).

Usage:
    python scripts/gen-theme-from-prompt.py <name> "<prompt>"
    python scripts/gen-theme-from-prompt.py <name> --preset <preset>

Examples:
    python scripts/gen-theme-from-prompt.py ocisly --preset druid_kid
    python scripts/gen-theme-from-prompt.py warlock --preset warlock
    python scripts/gen-theme-from-prompt.py mychar "purple wisps with subtle stars, 2:1 wallpaper"

Output: _anniversary_/Interface/AddOns/ChatPanelThemes/Media/<name>.tga
"""

from PIL import Image
from pathlib import Path
import sys
import urllib.parse
import urllib.request
import io
import hashlib

OUT_DIR = Path(__file__).parent.parent / "_anniversary_" / "Interface" / "AddOns" / "ChatPanelThemes" / "Media"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Generation defaults. 1024x512 from Pollinations -> downscale to 512x256 for
# better edge quality vs requesting 512x256 directly.
GEN_W, GEN_H = 1024, 512
TARGET = (512, 256)
MODEL = "flux"  # flux is Pollinations' best free model

PRESETS = {
    "druid_kid": (
        "Subtle designery wallpaper texture, 2:1 horizontal aspect ratio. "
        "Dark forest-green watercolor wash background with soft painterly grain. "
        "Sparse abstracted decorative motifs: small simplified strawberry silhouettes "
        "in muted dusty rose, abstract paw-print pad shapes in cream-colored ink, "
        "one delicate crescent moon in pale gold tucked into a corner. "
        "Asymmetric balanced composition, ~60 percent negative space. "
        "Inspired by boutique stationery and high-end children's book illustration. "
        "Refined never cartoonish. NO text, NO bright colors, NO realistic detail. "
        "Pure pattern wallpaper style suitable as a chat backdrop where white text reads clearly."
    ),
    "druid": (
        "Subtle designery wallpaper texture, 2:1 horizontal aspect ratio. "
        "Dark forest-green watercolor wash with painterly organic grain. "
        "Sparse abstracted leaf shapes: simplified silhouettes of oak fern and clover "
        "in muted sage and emerald inks. Asymmetric composition with delicate vine "
        "traces and significant negative space. "
        "Style references Japanese ink-wash botanical art crossed with modern boutique "
        "stationery. NO realistic detail, NO bright colors. "
        "Suitable as a chat backdrop where white text reads clearly."
    ),
    "warlock": (
        "Subtle designery wallpaper texture, 2:1 horizontal aspect ratio. "
        "Deep charcoal-purple watercolor wash with smoky organic grain. "
        "Sparse abstracted motifs: faint wisp tendrils in muted fel-green, "
        "simplified rune fragments in dusty violet, one barely-visible pentagram "
        "traced in pale gold tucked into a corner. Heavily asymmetric, lots of "
        "negative space. Style references occult tarot card backs crossed with "
        "high-end stationery. NO realistic skulls or demons, NO bright neon colors. "
        "Suitable as a chat backdrop where white text reads clearly."
    ),
    "mage": (
        "Subtle designery wallpaper texture, 2:1 horizontal aspect ratio. "
        "Deep midnight-blue watercolor wash with crystalline grain. "
        "Sparse abstracted motifs: faint frost-fractal shapes in pale cyan, "
        "simplified arcane sigil fragments in muted lavender, delicate snowflake "
        "silhouettes scattered minimally. Asymmetric composition, lots of negative "
        "space. Style references frosted glass etching crossed with ornate book "
        "endpapers. NO bright magic effects. NO sci-fi detail. "
        "Suitable as a chat backdrop where white text reads clearly."
    ),
    "paladin": (
        "Subtle designery wallpaper texture, 2:1 horizontal aspect ratio. "
        "Deep ochre-and-charcoal watercolor wash with parchment grain. "
        "Sparse heraldic motifs: faint cross-and-laurel fragments in muted gold leaf, "
        "simplified shield outlines in dusty bronze, one delicate sunburst tucked "
        "into a corner. Asymmetric, lots of negative space. Style references "
        "medieval illuminated manuscripts crossed with boutique stationery. "
        "NO bright gold gleam, NO realistic armor. "
        "Suitable as a chat backdrop where white text reads clearly."
    ),
}

def fetch(prompt: str, seed: int | None = None) -> bytes:
    qs = {
        "width": GEN_W,
        "height": GEN_H,
        "model": MODEL,
        "nologo": "true",
        "enhance": "false",  # we craft the prompt ourselves; no LLM rewrite
        "private": "true",
    }
    if seed is not None:
        qs["seed"] = seed
    url = f"https://image.pollinations.ai/prompt/{urllib.parse.quote(prompt)}?{urllib.parse.urlencode(qs)}"
    print(f"Fetching: {url[:120]}...")
    req = urllib.request.Request(url, headers={"User-Agent": "wow-config/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read()

def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    name = sys.argv[1].lower()
    if sys.argv[2] == "--preset":
        if len(sys.argv) < 4 or sys.argv[3] not in PRESETS:
            print(f"Unknown preset. Available: {', '.join(PRESETS)}")
            sys.exit(1)
        prompt = PRESETS[sys.argv[3]]
    else:
        prompt = sys.argv[2]

    # Deterministic seed from prompt so same prompt -> same image (idempotent reruns).
    seed = int(hashlib.sha256(prompt.encode()).hexdigest()[:8], 16)
    raw = fetch(prompt, seed=seed)

    img = Image.open(io.BytesIO(raw)).convert("RGBA")
    if img.size != TARGET:
        print(f"Resizing {img.size} -> {TARGET}")
        img = img.resize(TARGET, Image.LANCZOS)

    dst = OUT_DIR / f"{name}.tga"
    img.save(dst)
    print(f"Wrote {dst} ({img.size})")
    print(f"\nMap in ChatPanelThemes.lua if not already:")
    print(f"  CHAR_TEXTURE = {{ [\"<CharacterName>\"] = \"{name}\" }}")
    print(f"  -- or --")
    print(f"  CLASS_TEXTURE = {{ <CLASS> = \"{name}\" }}")
    print(f"\nThen /rl in WoW.")

if __name__ == "__main__":
    main()
