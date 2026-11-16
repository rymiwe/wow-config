#!/usr/bin/env python3
"""Generate KeyKit profiles: YAML -> JSON -> the addon's Profiles.lua.

1. profiles/source/forever-keymaps.yaml (Ryan's keymaps, every class and spec)
   becomes one JSON per class, spec and level step in profiles/keybinds/forever/.
2. Every JSON in profiles/keybinds/ (and forever/) becomes Profiles.lua.

    python3 scripts/gen-keykit-profiles.py
    python3 scripts/gen-keykit-profiles.py --check   # exit 1 if anything is stale,
                                                     # or a spec's steps don't add up to its at_60

Standard library only (no Pillow needed, unlike render-keybinds.py).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROFILE_DIR = ROOT / "profiles" / "keybinds"
BINDINGS = ROOT / "templates" / "_forever_" / "bindings-cache.wtf"
KEYMAPS = ROOT / "profiles" / "source" / "forever-keymaps.yaml"
FOREVER_DIR = PROFILE_DIR / "forever"
OUT = ROOT / "_forever_" / "Interface" / "AddOns" / "KeyKit" / "Profiles.lua"

VALID_ROLES = {"rotation", "cc", "defensive", "heal", "buff", "movement", "utility"}
MOD_PREFIX = {None: "", "alt": "ALT-", "ctrl": "CTRL-", "shift": "SHIFT-"}

# Profile key names (same aliases as render-keybinds.py) -> WoW binding key names.
KEY_ALIASES = {
    "GRAVE": "`", "TILDE": "`", "BACKTICK": "`",
    "ESC": "ESCAPE", "CAPS": "CAPSLOCK",
    "MOUSE3": "BUTTON3", "M3": "BUTTON3", "MIDDLE": "BUTTON3",
    "MOUSE4": "BUTTON4", "M4": "BUTTON4",
    "MOUSE5": "BUTTON5", "M5": "BUTTON5",
}

# Plain-English action names that are Blizzard binding commands, not spells.
COMMANDS = {
    "autorun": "TOGGLEAUTORUN",
    "move forward": "MOVEFORWARD",
    "move backward": "MOVEBACKWARD",
    "strafe left": "STRAFELEFT",
    "strafe right": "STRAFERIGHT",
    "jump": "JUMP",
    "bags": "OPENALLBAGS",
    "target nearest enemy": "TARGETNEARESTENEMY",
}

# Labels that name a spell with a note on it. The spellbook name is on the right.
# (Forever's Feral Charge is the bear-form one; the YAML spells that out.)
SPELL_ALIASES = {"Feral Charge (Bear)": "Feral Charge"}

# Actions KeyKit can show but not set: rings from other addons, cursor tricks.
PREVIEW_ONLY = {"raid markers"}


def norm_mod(mod):
    if mod in (None, "", "none"):
        return None
    mod = str(mod).lower()
    if mod not in MOD_PREFIX:
        raise ValueError(f"bad mod {mod!r}")
    return mod


def wow_key(key: str) -> str:
    k = str(key).strip().upper()
    return KEY_ALIASES.get(k, k)


def apply_target(bind: dict):
    """Return (kind, value) for SetBinding*, or (None, None) for preview only."""
    if bind.get("command"):
        return "cmd", bind["command"]
    if bind.get("item"):
        return "item", bind["item"]
    action = bind["action"].strip()
    if action in SPELL_ALIASES:
        return "spell", SPELL_ALIASES[action]
    low = action.lower()
    if low in COMMANDS:
        return "cmd", COMMANDS[low]
    if "(" in action or low in PREVIEW_ONLY:
        return None, None
    return "spell", action


def lua_str(s) -> str:
    s = str(s)
    s = s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "")
    return f'"{s}"'


def level_band(p: dict) -> str:
    if p.get("levels"):
        return str(p["levels"])
    if p.get("level"):
        return f"{p['level']}"
    return "any"


def summary(p: dict) -> str:
    if p.get("summary"):
        return p["summary"]
    if p.get("subtitle"):
        return p["subtitle"]
    notes = p.get("notes") or []
    return notes[0] if notes else ""


def load(path: Path) -> dict:
    p = json.loads(path.read_text(encoding="utf-8"))
    for f in ("id", "class", "source", "binds"):
        if f not in p:
            raise ValueError(f"{path.name}: missing {f}")
    if not (p["source"] or {}).get("url"):
        raise ValueError(f"{path.name}: source.url is required")
    for i, b in enumerate(p["binds"]):
        for f in ("key", "mod", "action", "role"):
            if f not in b:
                raise ValueError(f"{path.name}: bind[{i}] missing {f}")
        if b["role"] not in VALID_ROLES:
            raise ValueError(f"{path.name}: bind[{i}] bad role {b['role']!r}")
        norm_mod(b["mod"])
    return p


# --- forever-keymaps.yaml -> JSON -------------------------------------------
# PyYAML is not assumed. The file has one fixed shape, so this reader accepts
# exactly that shape and stops on anything else:
#   class:
#     "Spec":
#       changes:
#         LEVEL:
#           "KEY": "Spell" | null
#       at_60:
#         "KEY": "Spell"

_LINE = re.compile(r'^( *)(?:"([^"]*)"|([A-Za-z_0-9]+)):(?: (.*))?$')


def _scalar(raw: str):
    raw = raw.strip()
    if raw == "null":
        return None
    if len(raw) >= 2 and raw[0] == raw[-1] == '"':
        return raw[1:-1]
    raise ValueError(f"unexpected value {raw!r}")


def read_keymaps(path: Path = KEYMAPS) -> dict:
    data: dict = {}
    cls = spec = section = level = None
    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        m = _LINE.match(line)
        if not m:
            raise ValueError(f"{path.name}:{n}: cannot read {line!r}")
        indent, key = len(m.group(1)), m.group(2) if m.group(2) is not None else m.group(3)
        value = m.group(4)
        where = f"{path.name}:{n}"
        if indent == 0 and value is None:
            cls = key
            data[cls] = {}
        elif indent == 2 and value is None:
            spec = key
            data[cls][spec] = {"changes": {}, "at_60": {}}
        elif indent == 4 and value is None and key in ("changes", "at_60"):
            section, level = key, None
        elif indent == 6 and section == "changes" and value is None:
            level = int(key)
            data[cls][spec]["changes"][level] = {}
        elif indent == 8 and section == "changes" and level is not None:
            data[cls][spec]["changes"][level][key] = _scalar(value)
        elif indent == 6 and section == "at_60" and value is not None:
            data[cls][spec]["at_60"][key] = _scalar(value)
        else:
            raise ValueError(f"{where}: unexpected line {line!r}")
    return data


def split_key(raw: str):
    """'Shift F' -> ('F', 'shift'); 'Mouse 5' -> ('MOUSE5', None); '1' -> ('1', None)."""
    parts = raw.split()
    mod = None
    if parts[0].lower() in ("shift", "alt", "ctrl"):
        mod = parts.pop(0).lower()
    key = "".join(parts).upper()
    if not re.fullmatch(r"[0-9A-Z`]|MOUSE[345]", key):
        raise ValueError(f"unknown key {raw!r}")
    return key, mod


# Role colours for the preview. Ryan's paladin roles first, then name rules.
ROLE_BY_NAME = {
    "Hearthstone": "utility", "Attack": "rotation", "Auto Shot": "rotation", "Shoot": "rotation",
    "Blessing of Protection": "buff", "Lay on Hands": "heal",
    "Divine Intervention": "defensive", "Hammer of Justice": "cc",
}
ROLE_RULES = [
    ("defensive", r"Divine (Protection|Shield)|Barkskin|Shield Wall|Last Stand|Evasion|Ice Block|Ice Barrier|"
                  r"Mana Shield|Power Word: Shield|Fade|Feign Death|Vanish|Frenzied Regeneration|Shield Block|"
                  r"Retaliation|Deterrence|Unending|Sacrifice|Death Coil|Stoneform|Shadow Ward|Fire Ward|Frost Ward|"
                  r"Cloak of Shadows|Enraged Regeneration|Spell Reflection|Recklessness$"),
    ("cc", r"Polymorph|Hibernate|Entangling Roots|Fear|Sap|Gouge|Kick|Counterspell|Bash|Pummel|Shield Bash|"
           r"Repentance|Scatter|Freezing Trap|Frost Trap|Banish|Shackle|Psychic Scream|Howl|Seduction|Blind|"
           r"Kidney Shot|Cheap Shot|Intimidating|Concussive|Frost Nova|Hamstring|Wing Clip|Earth Shock|"
           r"Silence|Mind Control|Scare Beast|Turn Undead|Taunt|Growl|Challenging|Mocking Blow|Intimidation|"
           r"Pounce|Maim|Garrote|Piercing Howl|Cone of Cold|Wyvern|Intercept|Feral Charge|"
           r"Distract|Curse of Tongues|Spell Lock|Hammer of Justice"),
    ("heal", r"Heal|Healing|Rejuvenation|Regrowth|Renew|Holy Light|Flash of Light|Mend|Tranquility|Rebirth|"
             r"Resurrect|Redemption|Revive|Ancestral Spirit|Cure|Remove|Purify|Cleanse|Abolish|Dispel|Prayer of|"
             r"Lesser Heal|Chain Heal|Bandage|Swiftmend|Lifebloom|Drain Life|Health Funnel|Purge|Cleansing"),
    ("movement", r"Dash|Sprint|Blink|Travel Form|Aquatic Form|Cheetah|Pack|Ghost Wolf|Disengage|"
                 r"Slow Fall|Levitate|Water Walking|Unending Breath|Water Breathing|Stealth|Prowl"),
    ("utility", r"Hearthstone|Track|Conjure|Summon|Portal|Teleport|Create|Ritual|Pick Lock|Detect|Sense|"
                r"Eye of|Eyes of|Far Sight|Astral Recall|Enslave|Soulstone|Spellstone|Firestone|Healthstone|"
                r"Tame|Feed Pet|Call Pet|Dismiss|Revive Pet|Beast Lore|Disarm Trap|Poison|Evocation|"
                r"Mind Vision|Fishing|First Aid|Cannibalize|Find|Pick Pocket|Feign"),
    ("buff", r"Blessing|Aura|Seal|Mark of the Wild|Gift of the Wild|Thorns|Fortitude|Armor|Intellect|"
             r"Shout|Aspect|Form$|Stance|Totem|Weapon|Righteous Fury|Inner Fire|Divine Spirit|Shadow Protection|"
             r"Power Infusion|Innervate|Omen|Amplify|Dampen|Presence|Shield$|Lightning Shield|Water Shield|"
             r"Fear Ward|Battle Shout|Bloodrage|Berserker Rage|Rage$|Fury$|Arcane Brilliance|"
             r"Combustion|Inner Focus|Elemental Mastery|Nature's Swiftness|Tiger's Fury|Rapid Fire|"
             r"Bestial Wrath|Adrenaline Rush|Blade Flurry|Cold Blood|Preparation|Sweeping Strikes|Death Wish|"
             r"Demon Skin|Demon Armor|Soul Link|Fel Domination|Dark Pact|Life Tap"),
]


def role_for(spell: str, paladin_roles: dict) -> str:
    if spell in ROLE_BY_NAME:
        return ROLE_BY_NAME[spell]
    if spell in paladin_roles:
        return paladin_roles[spell]
    for role, pattern in ROLE_RULES:
        if re.search(pattern, spell):
            return role
    return "rotation"


def slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


MOD_ORDER = {None: 0, "shift": 1, "alt": 2, "ctrl": 3}
KEY_ORDER = "`123456QWERTASDFGZXCVBH"


def _bind_sort(item):
    (key, mod), _ = item
    return (MOD_ORDER[mod], KEY_ORDER.find(key) if key in KEY_ORDER else 100, key)


def _pretty_key(raw: str) -> str:
    key, mod = split_key(raw)
    key = {"MOUSE4": "Mouse 4", "MOUSE5": "Mouse 5", "MOUSE3": "Mouse 3"}.get(key, key)
    return f"{mod.capitalize()}-{key}" if mod else key


def keymap_profiles(data: dict, paladin_roles: dict) -> tuple[dict[str, dict], list[str]]:
    """Return ({filename: profile}, problems). Each step is cumulative."""
    out: dict[str, dict] = {}
    problems: list[str] = []
    for cls, specs in data.items():
        for spec, body in specs.items():
            levels = sorted(body["changes"])
            state: dict[str, str] = {}
            for i, lvl in enumerate(levels):
                changes = body["changes"][lvl]
                for raw, spell in changes.items():
                    if spell is None:
                        state.pop(raw, None)
                    else:
                        state[raw] = spell
                top = levels[i + 1] - 1 if i + 1 < len(levels) else 60
                band = f"{lvl}-{top}" if top > lvl else f"{lvl}"
                new = [f"{_pretty_key(k)} {v}" for k, v in changes.items() if v is not None]
                gone = [_pretty_key(k) for k, v in changes.items() if v is None]
                what = ", ".join(new) if new else "no new keys"
                if gone:
                    what += "; cleared " + ", ".join(gone)
                binds = {}
                for raw, spell in state.items():
                    binds[split_key(raw)] = spell
                pid = f"forever-{cls}-{slug(spec)}-{lvl:02d}"
                out[pid + ".json"] = {
                    "id": pid,
                    "title": f"{spec} {cls}, level {band}",
                    "subtitle": f"New at {lvl}: {what}",
                    "summary": f"{spec} {cls} keys as of level {lvl}. New: {what}.",
                    "class": cls,
                    "level": lvl,
                    "levels": band,
                    "spec": spec,
                    "flavor": "forever",
                    "source": {
                        "name": "Ryan's Forever keymaps (profiles/source/forever-keymaps.yaml)",
                        "url": "https://github.com/rymiwe/wow-config",
                        "credit": "Ryan Weiss",
                    },
                    "notes": [
                        "Apply the step that matches your level. Spells you haven't learned yet are skipped.",
                        "Each step builds on the one before, so applying the next step over this one is safe.",
                        "Talent spells are not included. Put those on an empty key yourself.",
                    ],
                    "binds": [
                        dict(
                            {"key": key, "mod": mod, "action": spell, "role": role_for(spell, paladin_roles)},
                            **({"item": spell} if spell == "Hearthstone" else {}),
                        )
                        for (key, mod), spell in sorted(binds.items(), key=_bind_sort)
                    ],
                }
            want = {split_key(k): v for k, v in body["at_60"].items()}
            got = {split_key(k): v for k, v in state.items()}
            if got != want:
                diff = sorted(set(got.items()) ^ set(want.items()), key=str)
                problems.append(f"{cls}/{spec}: replaying changes does not equal at_60: {diff}")
    return out, problems


PALADIN_ROLES = {
    "Attack": "rotation", "Blessing of Kings": "buff", "Blessing of Might": "buff",
    "Blessing of Protection": "buff", "Blessing of Wisdom": "buff", "Cleanse": "heal",
    "Concentration Aura": "buff", "Consecration": "rotation", "Devotion Aura": "buff",
    "Divine Intervention": "defensive", "Divine Protection": "defensive", "Divine Shield": "defensive",
    "Exorcism": "rotation", "Fire Resistance Aura": "buff", "Flash of Light": "heal",
    "Frost Resistance Aura": "buff", "Hammer of Justice": "cc", "Hammer of Wrath": "rotation",
    "Hearthstone": "utility", "Holy Light": "heal", "Holy Strike": "rotation", "Holy Wrath": "rotation",
    "Judgement": "rotation", "Lay on Hands": "heal", "Purify": "heal", "Retribution Aura": "buff",
    "Righteous Fury": "buff", "Seal of Fury": "buff", "Seal of Justice": "buff",
    "Seal of Righteousness": "buff", "Seal of the Crusader": "buff", "Shadow Resistance Aura": "buff",
}


def json_text(p: dict) -> str:
    return json.dumps(p, indent=2, ensure_ascii=False) + "\n"


def bar_keys() -> dict[str, str]:
    """Key -> action-bar command from the Forever bindings template.

    KeyKit uses this to find the bar slot a key fires, so Apply can put the
    spell on that button instead of binding the key straight to the spell.
    """
    out = {}
    for line in BINDINGS.read_text(encoding="utf-8").splitlines():
        parts = line.split()
        if len(parts) == 3 and parts[0] == "bind" and "BUTTON" in parts[2] and parts[2][0] in "AME":
            if parts[2].startswith(("ACTIONBUTTON", "MULTIACTIONBAR", "ELVUIBAR")):
                out[parts[1]] = parts[2]
    return out


def used_keys(data: dict, mod: str) -> set[str]:
    """Keys with this modifier that any spec of any class binds."""
    raw = set()
    for specs in data.values():
        for body in specs.values():
            raw |= set(body["at_60"])
            for step in body["changes"].values():
                raw |= {k for k, v in step.items() if v}
    return {key for key, m in map(split_key, raw) if m == mod}


# Formless classes (Hunter, Mage, Paladin, Priest, Shaman, Warlock) get full keyboard-shaped
# Shift and Ctrl layers: each copies the plain layer, button for button. Plain bar 1 -> Shift
# bar 2 / Ctrl bar 9, plain bar 3 -> Shift bar 8 / Ctrl bar 10 (ElvUI pages 2, 8, 9, 10).
FORMLESS_BARS = {"shift": {"ACTIONBUTTON": "ELVUIBAR2BUTTON", "MULTIACTIONBAR3BUTTON": "ELVUIBAR8BUTTON"},
                 "ctrl": {"ACTIONBUTTON": "ELVUIBAR9BUTTON", "MULTIACTIONBAR3BUTTON": "ELVUIBAR10BUTTON"}}


def formless_keys(data: dict) -> dict[str, str]:
    """SHIFT-/CTRL-key -> its own button on the Shift/Ctrl bars, for classes without forms.

    KeyKit overlays these on BAR_KEYS only for those classes. The template binds the compact
    Shift layer, which the form classes (Druid, Rogue, Warrior) keep, and no Ctrl keys.
    """
    plain = {k: c for k, c in bar_keys().items() if "-" not in k}
    out = {}
    for mod, bars in FORMLESS_BARS.items():
        for key, cmd in plain.items():
            m = re.match(r"^(ACTIONBUTTON|MULTIACTIONBAR3BUTTON)(\d+)$", cmd)
            if m:
                out[f"{mod.upper()}-{key}"] = bars[m.group(1)] + m.group(2)
        used = used_keys(data, mod)
        if not used <= set(plain):
            raise ValueError(f"{mod} keys outside the plain layout: {sorted(used - set(plain))}")
    return out


def render(profiles: list[tuple[Path, dict]], formless: dict[str, str]) -> tuple[str, list[str]]:
    out = [
        "-- GENERATED by scripts/gen-keykit-profiles.py from profiles/keybinds/*.json.",
        "-- Do not edit by hand: edit the JSON and re-run the script.",
        "local _, ns = ...",
        "ns.PROFILES = {",
    ]
    report = []
    for path, p in profiles:
        src = p["source"]
        out.append("  {")
        out.append(f"    id = {lua_str(p['id'])},")
        out.append(f"    title = {lua_str(p.get('title') or p['id'])},")
        out.append(f"    class = {lua_str(p['class'])},")
        out.append(f"    levels = {lua_str(level_band(p))},")
        if p.get("spec"):
            out.append(f"    spec = {lua_str(p['spec'])},")
        if isinstance(p.get("level"), int):
            lo, _, hi = level_band(p).partition("-")
            out.append(f"    minLevel = {int(lo)}, maxLevel = {int(hi or lo)},")
        out.append(f"    note = {lua_str(summary(p))},")
        out.append(f"    url = {lua_str(src['url'])},")
        out.append(f"    credit = {lua_str(src.get('credit', ''))},")
        out.append("    binds = {")
        applied = preview = 0
        for b in p["binds"]:
            mod = norm_mod(b["mod"])
            base = wow_key(b["key"])
            kind, value = apply_target(b)
            fields = [
                f"key = {lua_str(MOD_PREFIX[mod] + base)}",
                f"base = {lua_str(base)}",
                f"layer = {lua_str(mod or 'none')}",
                f"label = {lua_str(b['action'])}",
                f"role = {lua_str(b['role'])}",
            ]
            if kind:
                fields += [f"kind = {lua_str(kind)}", f"value = {lua_str(value)}"]
                applied += 1
            else:
                preview += 1
            out.append("      { " + ", ".join(fields) + " },")
        out.append("    },")
        out.append("  },")
        report.append((p["class"], applied, preview))
    out.append("}")
    keys = bar_keys()
    out.append(f"-- Key -> bar button, from {BINDINGS.relative_to(ROOT).as_posix()}")
    out.append("ns.BAR_KEYS = {")
    for k, cmd in keys.items():
        out.append(f"  [{lua_str(k)}] = {lua_str(cmd)},")
    out.append("}")
    out.append("-- Shift and Ctrl key -> its own bar button, for classes without forms (Hunter, Mage, Paladin, Priest, Shaman, Warlock)")
    out.append("ns.FORMLESS_KEYS = {")
    for k, cmd in formless.items():
        out.append(f"  [{lua_str(k)}] = {lua_str(cmd)},")
    out.append("}")
    by_class: dict[str, list[int]] = {}
    for cls, applied, preview in report:
        c = by_class.setdefault(cls, [0, 0, 0])
        c[0] += 1
        c[1] += applied
        c[2] += preview
    lines = [f"  {cls}: {n} profiles, {a} binds, {pv} preview-only" for cls, (n, a, pv) in sorted(by_class.items())]
    lines.append(f"  {BINDINGS.name}: {len(keys)} keys fire action-bar buttons, plus {len(formless)} Shift and Ctrl keys for formless classes")
    return "\n".join(out) + "\n", lines


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="Exit 1 if anything is stale or a spec does not add up")
    args = ap.parse_args(argv)
    rc = 0

    # 1. YAML -> JSON
    keymaps = read_keymaps()
    generated, problems = keymap_profiles(keymaps, PALADIN_ROLES)
    shift_bar = {k for k, c in bar_keys().items() if c.startswith("ELVUIBAR2BUTTON")}
    missing = sorted(k for k in used_keys(keymaps, "shift") if f"SHIFT-{k}" not in shift_bar)
    if missing:
        problems.append(f"Shift keys the keymaps use but {BINDINGS.name} does not bind to ELVUIBAR2: {missing}")
    for msg in problems:
        print(f"ERROR {msg}", file=sys.stderr)
    if problems:
        rc = 1
    existing = {f.name for f in FOREVER_DIR.glob("*.json")} if FOREVER_DIR.exists() else set()
    if args.check:
        stale = [n for n, p in generated.items()
                 if not (FOREVER_DIR / n).exists() or (FOREVER_DIR / n).read_text(encoding="utf-8") != json_text(p)]
        extra = sorted(existing - set(generated))
        if stale or extra:
            print(f"{FOREVER_DIR.relative_to(ROOT)} is stale ({len(stale)} changed, {len(extra)} extra); "
                  "run scripts/gen-keykit-profiles.py", file=sys.stderr)
            rc = 1
        else:
            print(f"{FOREVER_DIR.relative_to(ROOT)} is up to date ({len(generated)} profiles from "
                  f"{KEYMAPS.relative_to(ROOT).as_posix()}; every spec replays to its at_60)")
    else:
        if problems:
            return rc
        FOREVER_DIR.mkdir(parents=True, exist_ok=True)
        for name in existing - set(generated):
            (FOREVER_DIR / name).unlink()
        for name, p in generated.items():
            (FOREVER_DIR / name).write_text(json_text(p), encoding="utf-8", newline="\n")
        print(f"wrote {len(generated)} profiles to {FOREVER_DIR.relative_to(ROOT)}/ "
              f"(every spec replays to its at_60)")

    # 2. JSON -> Profiles.lua
    files = sorted(PROFILE_DIR.glob("*.json")) + sorted(FOREVER_DIR.glob("*.json"))
    if not files:
        print(f"No profiles in {PROFILE_DIR}", file=sys.stderr)
        return 1
    text, report = render([(f, load(f)) for f in files], formless_keys(keymaps))
    rel = OUT.relative_to(ROOT)
    if args.check:
        current = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
        if current != text:
            print(f"{rel} is stale; run scripts/gen-keykit-profiles.py", file=sys.stderr)
            return 1
        print(f"{rel} is up to date ({len(files)} profiles)")
        return rc
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8", newline="\n")
    print(f"wrote {rel} ({len(files)} profiles)")
    print("\n".join(report))
    return rc


if __name__ == "__main__":
    sys.exit(main())
