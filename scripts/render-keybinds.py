#!/usr/bin/env python3
"""Render a wow-config keybind profile as a dark-theme keyboard diagram.

Usage:
    python3 scripts/render-keybinds.py profiles/keybinds/<id>.json -o out.png
    python3 scripts/render-keybinds.py --all
    python3 scripts/render-keybinds.py profiles/keybinds/ryan-paladin-anniversary.json \\
        --suggest '1=Holy Strike' -o /tmp/preview.png

Requires Pillow. Looks for Geist (or IBM Plex Sans / DejaVu) on this box.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
PROFILE_DIR = ROOT / "profiles" / "keybinds"
DEFAULT_RENDER_DIR = PROFILE_DIR / "renders"

SCALE = 2  # draw large, then downscale for crisp edges and type

# --- palette -----------------------------------------------------------------
BG = (11, 13, 18)
PANEL = (17, 21, 29)
PANEL_LINE = (36, 42, 54)
KEY_EMPTY = (28, 32, 42)
KEY_BORDER = (50, 56, 70)
TEXT = (236, 230, 220)
MUTED = (138, 146, 162)
DIM = (90, 98, 112)
GOLD = (212, 175, 90)
GOLD_DIM = (140, 116, 62)
WHITE = (255, 255, 255)

ROLES = {
    "rotation": {"color": (218, 168, 72), "label": "Rotation"},
    "cc": {"color": (220, 96, 90), "label": "CC / interrupt"},
    "defensive": {"color": (96, 148, 230), "label": "Defensive"},
    "heal": {"color": (90, 186, 130), "label": "Heal"},
    "buff": {"color": (168, 130, 220), "label": "Buff"},
    "movement": {"color": (120, 138, 154), "label": "Movement"},
    "utility": {"color": (80, 176, 176), "label": "Utility"},
}

VALID_ROLES = set(ROLES)
VALID_MODS = {None, "", "none", "shift", "alt", "ctrl"}

FONT_CANDIDATES = [
    Path("/usr/share/fonts/truetype/sand-box/google/Geist/Geist-VariableFont_wght.ttf"),
    Path("/usr/share/fonts/truetype/sand-box/google/IBM Plex Sans/IBMPlexSans-VariableFont_wdth,wght.ttf"),
    Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
]
ITALIC_CANDIDATES = [
    Path("/usr/share/fonts/truetype/sand-box/google/Geist/Geist-Italic-VariableFont_wght.ttf"),
    Path("/usr/share/fonts/truetype/sand-box/google/IBM Plex Sans/IBMPlexSans-Italic-VariableFont_wdth,wght.ttf"),
    Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf"),
]


def _first_font(paths):
    for p in paths:
        if p.exists():
            return p
    raise FileNotFoundError("No usable font found (Geist / IBM Plex Sans / DejaVu)")


FONT_PATH = _first_font(FONT_CANDIDATES)
ITALIC_PATH = _first_font(ITALIC_CANDIDATES)


def font(size: int, weight: int = 400, italic: bool = False) -> ImageFont.FreeTypeFont:
    path = ITALIC_PATH if italic else FONT_PATH
    f = ImageFont.truetype(str(path), size)
    try:
        f.set_variation_by_axes([weight])
    except Exception:
        pass
    return f


def mix(a, b, t: float):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def lighten(c, t: float):
    return mix(c, WHITE, t)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap_words(draw, text: str, fnt, max_w: int) -> list[str]:
    # Keep URLs intact; only wrap on spaces.
    if not text:
        return [""]
    if "://" in text and text_size(draw, text, fnt)[0] <= max_w:
        return [text]
    words = text.split()
    if not words:
        return [""]
    lines, cur = [], words[0]
    for w in words[1:]:
        trial = f"{cur} {w}"
        if text_size(draw, trial, fnt)[0] <= max_w:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    lines.append(cur)
    return lines


def fit_lines(draw, text: str, max_w: int, max_h: int, max_size: int, min_size: int, weight: int):
    """Return (font, lines, line_h) that fit inside max_w x max_h."""
    for size in range(max_size, min_size - 1, -1):
        fnt = font(size, weight)
        lines = wrap_words(draw, text, fnt, max_w)
        if len(lines) > 3:
            continue
        # Prefer 2 lines for long names when a single long line is tight
        w, h = text_size(draw, "Ag", fnt)
        line_h = h + max(2, size // 6)
        total_h = line_h * len(lines) - max(2, size // 6)
        widest = max(text_size(draw, ln, fnt)[0] for ln in lines)
        if widest <= max_w and total_h <= max_h:
            return fnt, lines, line_h
    fnt = font(min_size, weight)
    lines = wrap_words(draw, text, fnt, max_w)
    if len(lines) > 3:
        lines = lines[:2] + [" ".join(lines[2:])]
        # last line may still overflow; that's ok, we tried
    w, h = text_size(draw, "Ag", fnt)
    return fnt, lines, h + 2


# --- keyboard geometry -------------------------------------------------------
# Left-hand cluster: Esc, number row through 6, letters through B, modifiers.

KEY_W = 114
KEY_H = 124
GAP = 10
RADIUS = 18
UNIT = KEY_W  # used for width multipliers

# (key_id, label, width_in_units)
ROWS = [
    [
        ("ESC", "Esc", 1.0),
        ("`", "`", 1.0),
        ("1", "1", 1.0),
        ("2", "2", 1.0),
        ("3", "3", 1.0),
        ("4", "4", 1.0),
        ("5", "5", 1.0),
        ("6", "6", 1.0),
    ],
    [
        ("TAB", "Tab", 1.5),
        ("Q", "Q", 1.0),
        ("W", "W", 1.0),
        ("E", "E", 1.0),
        ("R", "R", 1.0),
        ("T", "T", 1.0),
    ],
    [
        ("CAPS", "Caps", 1.75),
        ("A", "A", 1.0),
        ("S", "S", 1.0),
        ("D", "D", 1.0),
        ("F", "F", 1.0),
        ("G", "G", 1.0),
    ],
    [
        ("LSHIFT", "Shift", 2.25),
        ("Z", "Z", 1.0),
        ("X", "X", 1.0),
        ("C", "C", 1.0),
        ("V", "V", 1.0),
        ("B", "B", 1.0),
    ],
    [
        ("LCTRL", "Ctrl", 1.5),
        ("LALT", "Alt", 1.5),
        ("SPACE", "Space", 3.25),
    ],
]


def row_width_units(row):
    return sum(w for _, _, w in row) + (len(row) - 1) * (GAP / UNIT)


KEYBOARD_W_UNITS = max(row_width_units(r) for r in ROWS)
KEYBOARD_W = int(KEYBOARD_W_UNITS * UNIT + (len(ROWS[1]) ) * 0)  # computed from units
KEYBOARD_W = int(KEYBOARD_W_UNITS * UNIT)
# row_width_units already includes gaps as GAP/UNIT, so width in px:
def row_width_px(row):
    return int(sum(w * UNIT for _, _, w in row) + GAP * (len(row) - 1))


KEYBOARD_W = max(row_width_px(r) for r in ROWS)
KEYBOARD_H = len(ROWS) * KEY_H + (len(ROWS) - 1) * GAP


def key_boxes(origin):
    """Return dict key_id -> (x0,y0,x1,y1,label)."""
    ox, oy = origin
    boxes = {}
    y = oy
    for row in ROWS:
        x = ox
        for kid, label, w in row:
            ww = int(w * KEY_W)
            boxes[kid] = (x, y, x + ww, y + KEY_H, label)
            x += ww + GAP
        y += KEY_H + GAP
    return boxes


def norm_mod(mod):
    if mod in (None, "", "none"):
        return None
    return str(mod).lower()


def norm_key(key: str) -> str:
    k = str(key).strip().upper()
    aliases = {
        "GRAVE": "`",
        "TILDE": "`",
        "BACKTICK": "`",
        "ESCAPE": "ESC",
        "SHIFTL": "LSHIFT",
        "SHIFT": "LSHIFT",
        "CTRL": "LCTRL",
        "CONTROL": "LCTRL",
        "ALT": "LALT",
        "MOUSE4": "MOUSE4",
        "BUTTON4": "MOUSE4",
        "M4": "MOUSE4",
        "MOUSE5": "MOUSE5",
        "BUTTON5": "MOUSE5",
        "M5": "MOUSE5",
        "MOUSE3": "MOUSE3",
        "BUTTON3": "MOUSE3",
        "M3": "MOUSE3",
        "MIDDLE": "MOUSE3",
    }
    return aliases.get(k, k)


def index_binds(binds):
    """Map (key, mod) -> bind dict."""
    out = {}
    unplaced = []
    keyboard_ids = {kid for row in ROWS for kid, _, _ in row}
    mouse_ids = {"MOUSE3", "MOUSE4", "MOUSE5"}
    for b in binds:
        key = norm_key(b.get("key", ""))
        mod = norm_mod(b.get("mod"))
        if key not in keyboard_ids and key not in mouse_ids:
            unplaced.append(b)
            continue
        out[(key, mod)] = b
    return out, unplaced


# --- drawing -----------------------------------------------------------------
def rounded(draw, box, fill, outline, width=2, radius=RADIUS):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_key(draw, box, label, bind, layer_tag=None, suggest=None, footer=None):
    x0, y0, x1, y1, _ = box if len(box) == 5 else (*box, None)
    # box is x0,y0,x1,y1
    if len(box) == 5:
        x0, y0, x1, y1, cap = box
    else:
        x0, y0, x1, y1 = box
        cap = label
    w, h = x1 - x0, y1 - y0
    role = (bind or {}).get("role")
    action = (bind or {}).get("action")
    badge = (bind or {}).get("badge")
    color = ROLES[role]["color"] if role in ROLES else None
    footer = footer or suggest

    if bind and color:
        fill = mix(KEY_EMPTY, color, 0.28)
        border = mix(KEY_BORDER, color, 0.45)
        accent = color
    else:
        fill = KEY_EMPTY
        border = KEY_BORDER
        accent = None

    # suggested keys (no main bind, only a suggestion) get a dashed gold feel
    if not bind and suggest:
        fill = mix(KEY_EMPTY, GOLD, 0.16)
        border = GOLD_DIM

    rounded(draw, (x0, y0, x1, y1), fill, border, width=2, radius=min(RADIUS, h // 4))

    if accent:
        # left rail
        rail = 5
        draw.rounded_rectangle(
            (x0 + 2, y0 + 8, x0 + 2 + rail, y1 - 8),
            radius=2,
            fill=accent,
        )

    # cap label
    cap_font = font(20, 500)
    cap_col = lighten(color, 0.55) if color else DIM
    draw.text((x0 + 10, y0 + 6), cap, font=cap_font, fill=cap_col)

    # badge (TBC, etc.)
    if badge:
        bf = font(13, 650)
        tw, th = text_size(draw, badge, bf)
        bx1, by0 = x1 - 10, y0 + 7
        bx0, by1 = bx1 - tw - 10, by0 + th + 6
        pill = mix(fill, (0, 0, 0), 0.25)
        draw.rounded_rectangle((bx0, by0, bx1, by1), radius=6, fill=pill, outline=GOLD_DIM, width=1)
        draw.text((bx0 + 5, by0 + 2), badge, font=bf, fill=GOLD)

    # action text
    if action:
        pad_x = 12
        top = y0 + 28
        bottom = y1 - (22 if (suggest or footer) else 10)
        fnt, lines, line_h = fit_lines(
            draw, action, max_w=w - pad_x * 2, max_h=bottom - top,
            max_size=26, min_size=16, weight=600,
        )
        text_col = lighten(color, 0.72) if color else TEXT
        total = line_h * len(lines)
        ty = top + max(0, (bottom - top - total) // 2)
        for ln in lines:
            lw, _ = text_size(draw, ln, fnt)
            tx = x0 + (w - lw) // 2
            draw.text((tx, ty), ln, font=fnt, fill=text_col)
            ty += line_h

    foot = None
    foot_color = GOLD
    if suggest:
        foot = f"Forever: {suggest}" if not str(suggest).lower().startswith("forever") else suggest
    elif footer:
        foot = footer
        foot_color = MUTED
    if foot:
        sf = font(13, 500, italic=True)
        max_w = w - 16
        if text_size(draw, foot, sf)[0] > max_w:
            sf = font(12, 500, italic=True)
        sw, sh = text_size(draw, foot, sf)
        if sw > max_w:
            # last-ditch shrink
            sf = font(11, 500, italic=True)
            sw, sh = text_size(draw, foot, sf)
        draw.text((x0 + (w - sw) // 2, y1 - sh - 7), foot, font=sf, fill=foot_color)


def draw_panel_label(draw, x, y, text):
    f = font(20, 600)
    draw.text((x, y), text.upper(), font=f, fill=MUTED)
    tw, th = text_size(draw, text.upper(), f)
    return th


def draw_keyboard(draw, origin, binds, suggestions, title=None, footers=None):
    ox, oy = origin
    header_h = 0
    if title:
        header_h = draw_panel_label(draw, ox, oy, title) + 16
    boxes = key_boxes((ox, oy + header_h))
    footers = footers or {}
    for kid, box in boxes.items():
        bind = binds.get((kid, None))
        sug = suggestions.get(kid)
        draw_key(draw, box, box[4], bind, suggest=sug, footer=footers.get(kid))
    # return bottom-right
    last = list(boxes.values())[-1]
    return boxes, last[3]


def draw_mouse(draw, origin, binds, h_target):
    """Small mouse with side buttons M4/M5 and wheel M3."""
    ox, oy = origin
    title_h = draw_panel_label(draw, ox, oy, "Mouse") + 16
    oy += title_h

    body_w, body_h = 168, max(240, min(320, h_target - title_h))
    # leave room for side buttons
    side_w = 86
    mx = ox + side_w + 10
    my = oy
    # body
    rounded(draw, (mx, my, mx + body_w, my + body_h), mix(KEY_EMPTY, (0, 0, 0), 0.1), KEY_BORDER, 2, 70)

    # seam
    cx = mx + body_w // 2
    draw.line((cx, my + 18, cx, my + int(body_h * 0.55)), fill=KEY_BORDER, width=2)

    # wheel / M3
    m3 = binds.get(("MOUSE3", None))
    ctrl_m3 = binds.get(("MOUSE3", "ctrl"))
    shift_m3 = binds.get(("MOUSE3", "shift"))
    wy0 = my + 36
    wheel = (cx - 16, wy0, cx + 16, wy0 + 52)
    color = ROLES.get((m3 or {}).get("role"), {}).get("color")
    fill = mix(KEY_EMPTY, color, 0.4) if color else mix(KEY_EMPTY, TEXT, 0.08)
    rounded(draw, wheel, fill, KEY_BORDER if not color else mix(KEY_BORDER, color, 0.5), 2, 10)
    capf = font(14, 600)
    draw.text((cx - text_size(draw, "M3", capf)[0] // 2, wy0 + 6), "M3", font=capf, fill=TEXT)
    # M3 action under wheel, inside body
    labels = []
    if m3:
        labels.append(m3["action"])
    if ctrl_m3:
        labels.append(f"Ctrl: {ctrl_m3['action']}")
    if shift_m3:
        labels.append(f"Shift: {shift_m3['action']}")
    if not labels:
        labels = ["(unbound)"]
    ly = wy0 + 62
    for i, lab in enumerate(labels):
        weight = 600 if i == 0 else 500
        fnt, lines, line_h = fit_lines(draw, lab, body_w - 24, 48, 16, 12, weight)
        col = TEXT if i == 0 and m3 else MUTED
        for ln in lines:
            lw, _ = text_size(draw, ln, fnt)
            draw.text((mx + (body_w - lw) // 2, ly), ln, font=fnt, fill=col)
            ly += line_h
        ly += 4

    # side buttons M4 (upper), M5 (lower)
    def side_btn(by, key_id, name):
        bind = binds.get((key_id, None))
        box = (ox, by, ox + side_w, by + 108)
        # reuse draw_key with custom cap
        x0, y0, x1, y1 = box
        w, h = x1 - x0, y1 - y0
        role = (bind or {}).get("role")
        action = (bind or {}).get("action")
        color = ROLES[role]["color"] if role in ROLES else None
        fill = mix(KEY_EMPTY, color, 0.28) if color else KEY_EMPTY
        border = mix(KEY_BORDER, color, 0.45) if color else KEY_BORDER
        rounded(draw, box, fill, border, 2, 14)
        if color:
            draw.rounded_rectangle((x0 + 2, y0 + 8, x0 + 7, y1 - 8), radius=2, fill=color)
        cf = font(16, 600)
        draw.text((x0 + 10, y0 + 8), name, font=cf, fill=lighten(color, 0.55) if color else DIM)
        if action:
            fnt, lines, line_h = fit_lines(draw, action, w - 16, h - 36, 18, 12, 600)
            ty = y0 + 32
            col = lighten(color, 0.72) if color else TEXT
            for ln in lines:
                lw, _ = text_size(draw, ln, fnt)
                draw.text((x0 + (w - lw) // 2, ty), ln, font=fnt, fill=col)
                ty += line_h
        else:
            f = font(14, 400, italic=True)
            t = "unbound"
            lw, _ = text_size(draw, t, f)
            draw.text((x0 + (w - lw) // 2, y0 + 48), t, font=f, fill=DIM)

    side_btn(my + 20, "MOUSE4", "M4")
    side_btn(my + 20 + 108 + 12, "MOUSE5", "M5")

    return mx + body_w, my + body_h


def draw_legend(draw, x, y, used_roles, max_w):
    f = font(20, 600)
    draw.text((x, y), "COLORS", font=f, fill=MUTED)
    y += 34
    lf = font(20, 500)
    roles = ["rotation", "cc", "defensive", "heal", "buff", "movement", "utility"]
    # measure labels and wrap into rows that fit max_w
    gap = 28
    r = 9
    cx, row_y = x, y
    for role in roles:
        label = ROLES[role]["label"]
        tw, th = text_size(draw, label, lf)
        item_w = r * 2 + 8 + tw + gap
        if cx > x and cx + item_w - gap > x + max_w:
            cx = x
            row_y += 34
        col = ROLES[role]["color"]
        draw.ellipse((cx, row_y + 4, cx + r * 2, row_y + 4 + r * 2), fill=col)
        draw.text((cx + r * 2 + 8, row_y), label, font=lf, fill=TEXT)
        cx += item_w
    return row_y + 36


def draw_notes(draw, x, y, width, notes):
    if not notes:
        return y
    f = font(20, 600)
    draw.text((x, y), "NOTES", font=f, fill=MUTED)
    y += 32
    body = font(20, 400)
    for note in notes:
        # bullet
        draw.ellipse((x + 2, y + 8, x + 10, y + 16), fill=GOLD_DIM)
        lines = wrap_words(draw, note, body, width - 28)
        for i, ln in enumerate(lines):
            draw.text((x + 18, y), ln, font=body, fill=MUTED if i or True else TEXT)
            y += 28
        y += 4
    return y


def unique_layer_binds(binds_index, mod):
    """Binds on this modifier that are not mere mirrors of the un-shifted key."""
    out = {}
    for (key, m), b in binds_index.items():
        if m != mod or key in {"MOUSE3", "MOUSE4", "MOUSE5"}:
            continue
        if mod == "shift":
            base = binds_index.get((key, None))
            if base and base.get("action") == b.get("action"):
                continue
        out[key] = b
    return out


def profile_has_layer(binds_index, mod):
    unique = unique_layer_binds(binds_index, mod)
    if not unique:
        return False
    # A lone bags / UI shortcut is shown as a footer on the base key,
    # not as a whole second keyboard.
    if mod == "shift" and all(b.get("role") == "utility" for b in unique.values()):
        return False
    return True


def compact_shift_footers(binds_index):
    unique = unique_layer_binds(binds_index, "shift")
    if not unique or not all(b.get("role") == "utility" for b in unique.values()):
        return {}
    footers = {}
    for key, b in unique.items():
        action = b.get("action") or ""
        footers[key] = f"Shift: {action}"
    return footers


def layer_index(binds_index, mod):
    """Treat binds with this modifier as the 'base' layer of a second keyboard."""
    out = {}
    for (key, m), b in binds_index.items():
        if m == mod:
            out[(key, None)] = b
    return out


def render_profile(profile: dict, outfile: Path, suggestions: dict | None = None, title_override=None):
    suggestions = suggestions or {}
    binds, unplaced = index_binds(profile.get("binds") or [])
    title = title_override or profile.get("title") or profile.get("id")
    subtitle = profile.get("subtitle") or ""
    source = profile.get("source") or {}
    credit_line = ""
    if source.get("credit") or source.get("name"):
        bits = [b for b in (source.get("credit"), source.get("name")) if b]
        # de-dupe while keeping order
        seen = set()
        bits = [b for b in bits if not (b in seen or seen.add(b))]
        credit_line = "  ·  ".join(bits)

    notes = list(profile.get("notes") or [])
    # Shift-mirror note is often already in notes; add unplaced
    for b in unplaced:
        notes.append(
            f"Not shown on this left-hand board: {b.get('mod') or ''} {b.get('key')} — {b.get('action')}"
        )

    used_roles = {b.get("role") for b in (profile.get("binds") or []) if b.get("role") in ROLES}

    has_alt = profile_has_layer(binds, "alt")
    has_shift = profile_has_layer(binds, "shift")
    has_ctrl_keys = profile_has_layer(binds, "ctrl")

    # canvas plan (at SCALE=2 coords we'll just draw at 2x from the start)
    pad = 56
    title_block = 130
    gap_y = 36
    mouse_w = 86 + 10 + 168  # side + body
    gutter = 48

    kb_x = pad
    kb_y = pad + title_block
    mouse_x = kb_x + KEYBOARD_W + gutter
    content_w = mouse_x + mouse_w

    # estimate height
    alt_h = (40 + KEYBOARD_H) if has_alt else 0
    shift_h = (40 + KEYBOARD_H) if has_shift else 0
    ctrl_h = (40 + KEYBOARD_H) if has_ctrl_keys else 0
    legend_h = 80
    notes_h = 32 + 32 * max(1, len(notes)) + 20 * sum(
        max(0, len(n) // 110) for n in notes
    )
    img_w = content_w + pad
    img_h = (
        pad
        + title_block
        + KEYBOARD_H
        + gap_y
        + (alt_h + gap_y if has_alt else 0)
        + (shift_h + gap_y if has_shift else 0)
        + (ctrl_h + gap_y if has_ctrl_keys else 0)
        + legend_h
        + notes_h
        + pad
    )

    # draw at SCALE
    W, H = img_w * SCALE, img_h * SCALE
    # Actually: UNIT is already 92 which is chunky enough. Don't scale geometry —
    # draw 1x at high res (UNIT=92 is already retina-ish for ~1100px keyboards).
    # Bump canvas to include padding only.
    # Recompute with a safety margin.
    img_w = max(img_w, kb_x + KEYBOARD_W + gutter + mouse_w + pad)
    img = Image.new("RGB", (img_w, img_h), BG)
    draw = ImageDraw.Draw(img)

    # title
    tf = font(44, 650)
    draw.text((pad, pad + 8), title, font=tf, fill=TEXT)
    sy = pad + 8 + 54
    if subtitle:
        sf = font(22, 400)
        lines = wrap_words(draw, subtitle, sf, img_w - pad * 2)
        for ln in lines:
            draw.text((pad, sy), ln, font=sf, fill=MUTED)
            sy += 28
    if credit_line:
        cf = font(20, 400)
        draw.text((pad, sy), credit_line, font=cf, fill=DIM)

    boxes, kb_bottom = draw_keyboard(
        draw, (kb_x, kb_y), binds, suggestions, title="Base layer",
        footers=compact_shift_footers(binds),
    )
    mouse_bottom_target = kb_bottom - (kb_y + 36)  # roughly keyboard height
    mx2, my2 = draw_mouse(draw, (mouse_x, kb_y), binds, h_target=KEYBOARD_H)
    y = max(kb_bottom, my2) + gap_y

    if has_shift:
        boxes_s, y = draw_keyboard(
            draw, (kb_x, y), layer_index(binds, "shift"), {}, title="Shift layer"
        )
        y += gap_y
    if has_alt:
        boxes_a, y = draw_keyboard(
            draw, (kb_x, y), layer_index(binds, "alt"), {}, title="Alt layer"
        )
        y += gap_y
    if has_ctrl_keys:
        boxes_c, y = draw_keyboard(
            draw, (kb_x, y), layer_index(binds, "ctrl"), {}, title="Ctrl layer"
        )
        y += gap_y

    y = draw_legend(draw, pad, y, used_roles, img_w - pad * 2)
    y += 16
    y = draw_notes(draw, pad, y, img_w - pad * 2, notes)

    # crop leftover empty bottom if our estimate was generous
    crop_h = min(img_h, y + pad)
    if crop_h < img_h - 8:
        img = img.crop((0, 0, img_w, crop_h))

    outfile = Path(outfile)
    outfile.parent.mkdir(parents=True, exist_ok=True)
    img.save(outfile, "PNG", optimize=True)
    return outfile, unplaced, img.size


def load_profile(path: Path) -> dict:
    data = json.loads(path.read_text())
    missing = [k for k in ("id", "class", "source", "binds") if k not in data]
    if missing:
        raise ValueError(f"{path} missing fields: {', '.join(missing)}")
    if "url" not in (data.get("source") or {}) or "credit" not in (data.get("source") or {}):
        raise ValueError(f"{path} source must include url and credit")
    for i, b in enumerate(data["binds"]):
        for req in ("key", "mod", "action", "role"):
            if req not in b:
                raise ValueError(f"{path} bind[{i}] missing {req}")
        if norm_mod(b["mod"]) not in {None, "shift", "alt", "ctrl"}:
            raise ValueError(f"{path} bind[{i}] bad mod: {b['mod']!r}")
        if b["role"] not in VALID_ROLES:
            raise ValueError(f"{path} bind[{i}] bad role: {b['role']!r}")
    return data


def parse_suggestions(items: list[str]) -> dict:
    """'1=Holy Strike' -> {'1': 'Holy Strike'}"""
    out = {}
    for item in items or []:
        if "=" not in item:
            raise ValueError(f"--suggest expects KEY=Name, got {item!r}")
        k, name = item.split("=", 1)
        out[norm_key(k)] = name.strip()
    return out


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("profile", nargs="?", help="Path to a profile JSON")
    p.add_argument("-o", "--output", help="Output PNG path")
    p.add_argument("--all", action="store_true", help=f"Render every profile in {PROFILE_DIR}")
    p.add_argument("--suggest", action="append", default=[], help="Overlay a suggestion, e.g. 1='Holy Strike'")
    p.add_argument("--title", help="Override the title on the image")
    args = p.parse_args(argv)

    suggestions = parse_suggestions(args.suggest)

    if args.all:
        files = sorted(PROFILE_DIR.glob("*.json"))
        if not files:
            print(f"No profiles in {PROFILE_DIR}", file=sys.stderr)
            return 1
        rc = 0
        for f in files:
            prof = load_profile(f)
            out = DEFAULT_RENDER_DIR / f"{prof['id']}.png"
            path, unplaced, size = render_profile(prof, out)
            extra = f"  unplaced={unplaced}" if unplaced else ""
            print(f"wrote {path} {size[0]}x{size[1]}{extra}")
        return rc

    if not args.profile:
        p.print_help()
        return 2
    prof_path = Path(args.profile)
    prof = load_profile(prof_path)
    out = Path(args.output) if args.output else DEFAULT_RENDER_DIR / f"{prof['id']}.png"
    path, unplaced, size = render_profile(prof, out, suggestions, title_override=args.title)
    print(f"wrote {path} {size[0]}x{size[1]}")
    if unplaced:
        print("unplaced:", json.dumps(unplaced, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
