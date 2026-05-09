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

# All prompts share the GitHub dark-mode aesthetic spine: near-black base
# (#0d1117 / #161b22 territory), heavily muted single-accent color, extreme
# negative space, ultra-low contrast. Think GitHub README header backgrounds:
# nothing screams, everything whispers.
_BASE = (
    "GitHub dark mode aesthetic. Pure background color RGB(13,17,23) "
    "(near-black with slight blue undertone), filling 75 to 85 percent of the "
    "image. Extremely subtle, low-contrast, low-saturation. Wallpaper texture, "
    "2:1 horizontal aspect ratio. NO text, NO logos, NO bright colors, NO high "
    "contrast. Refined developer-tool aesthetic. Suitable as a chat backdrop "
    "where white text must read clearly. "
)

PRESETS = {
    "druid_kid": _BASE + (
        "Single muted accent color: dusty sage green RGB(60,90,55). "
        "A few sparse abstract motifs only barely visible against the dark base: "
        "tiny simplified strawberry silhouettes, abstract paw-print pad shapes, "
        "and one small crescent moon. All elements at extremely low alpha so they "
        "fade nearly into the background. Asymmetric, mostly empty composition."
    ),
    "druid": _BASE + (
        "Single muted accent color: dusty sage green RGB(60,90,55). "
        "Sparse abstract leaf silhouettes barely visible against the dark base. "
        "Asymmetric composition with significant negative space. Like a GitHub "
        "repo header for an open-source nature library."
    ),
    "warlock": _BASE + (
        "Single muted accent color: dusty violet RGB(85,60,110). "
        "A few faint smoke wisps and abstract rune fragments barely visible "
        "against the dark base. Asymmetric, mostly empty composition. Like a "
        "GitHub repo header for an obscure cryptographic library."
    ),
    "mage": _BASE + (
        "Single muted accent color: dusty cool blue RGB(70,95,130). "
        "A few abstract crystalline fractures and angular geometric traces "
        "barely visible against the dark base. Asymmetric composition. Like a "
        "GitHub repo header for a mathematical algorithm library."
    ),
    "paladin": _BASE + (
        "Single muted accent color: dusty olive-gold RGB(115,100,55). "
        "A few abstract heraldic fragments and faint geometric flourishes barely "
        "visible against the dark base. Asymmetric composition. Like a GitHub "
        "repo header for a security audit toolkit."
    ),
    "shaman": _BASE + (
        "Single muted accent color: dusty teal RGB(55,90,100). "
        "A few faint elemental wave traces and abstract symbol fragments barely "
        "visible against the dark base. Asymmetric composition. Like a GitHub "
        "repo header for a distributed systems library."
    ),
    "priest": _BASE + (
        "Single muted accent color: faded warm cream RGB(120,115,95). "
        "A few abstract radial light traces barely visible against the dark base. "
        "Asymmetric composition. Like a GitHub repo header for a documentation "
        "static-site generator."
    ),
    "rogue": _BASE + (
        "Single muted accent color: dusty tan RGB(105,95,75). "
        "A few faint dagger-edge traces and abstract leather grain patterns "
        "barely visible against the dark base. Asymmetric composition. Like a "
        "GitHub repo header for a privacy-focused tool."
    ),
    "hunter": _BASE + (
        "Single muted accent color: weathered umber RGB(95,75,55). "
        "A few faint arrow traces and abstract wood-grain patterns barely "
        "visible against the dark base. Asymmetric composition. Like a GitHub "
        "repo header for a tracking/observability library."
    ),
    "warrior": _BASE + (
        "Single muted accent color: rust red RGB(110,55,50). "
        "A few faint blade-edge streaks and abstract impact marks barely visible "
        "against the dark base. Asymmetric composition. Like a GitHub repo "
        "header for a low-level performance library."
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
