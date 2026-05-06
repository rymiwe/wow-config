# wow-config

Opinionated UI setup for WoW Anniversary (TBC Classic 2.5.5). Built for casual play with family and friends — install once, log in, play. No spending an evening configuring action bars.

## What you get

- **Pre-configured ElvUI layout** — keyboard-mirrored bars near your character, no fiddling
- **Auto-class-setup** — `/setupbars` places your spells on the right keys when you first log in
- **Mouseover heals + dispels** — hover a party member, hit your heal key, no target-switching needed
- **Smart defaults** — Trade/General chat auto-left per character, enemy nameplates always on, friendly off
- **Reminders** — chat nudge when you train a new spell that needs placement; `/restorebars` undoes any layout change
- **One-shot bulk-install** for recommended companion addons (ElvUI, WeakAuras, BadBoy, OPie, TSM, Questie)
- **Per-class layouts** — Shaman, Druid (Feral+Balance), Hunter, Paladin, Warrior ship now; new classes generated via the [`wow-class-setup` skill](.claude/skills/wow-class-setup.md)

Designed for the audience: kids, spouses, friends who want to log in and play. Optimized for "discoverability over efficiency" — every key bind is intuitive even if it costs 0.1s of theoretical optimization. PvP-grade speed is explicitly NOT the goal.

## Install (for friends and second machines)

### Windows — Easy mode (recommended for non-technical users)
1. Download [`install.bat`](https://github.com/rymiwe/wow-config/raw/main/install.bat)
2. Make sure WoW is closed
3. Double-click `install.bat`
4. Follow the prompts

See [`INSTALL.txt`](INSTALL.txt) for click-by-click walkthrough including WoWUp-CF for companion addons.

### Windows — PowerShell one-liner
```powershell
iex (iwr "https://raw.githubusercontent.com/rymiwe/wow-config/main/install.ps1").Content
```

### Linux / Mac / Steam Deck
```bash
curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | bash
```

The installer:
1. Detects your WoW install (override with `WOWDIR=...` env var or `--wow-dir` flag)
2. Finds your Battle.net account folder under `WTF/Account/` (or prompts if multiple)
3. Copies custom addons (`SetupCore`, `ChatAnchor`, `ShamanSetup`, `DruidSetup`, `HunterSetup`, `PaladinSetup`, `WarriorSetup`)
4. Installs bindings + flips an auto-setup flag so `/setupbars` runs on your first login
5. Merges recommended CVar defaults into `Config.wtf` (nameplates, camera zoom)

### Modes
| flag | behavior |
|---|---|
| `--upsert` (default) | Install/update addons. Skip existing bindings, SavedVariables, and ElvUI layout. Merge new CVars into Config.wtf without overwriting existing graphics settings. |
| `--fresh` | Overwrite bindings, reseed auto-setup flag, install full ElvUI layout, replace Config.wtf entirely. Use this for a brand-new install. |

### After install
1. Launch WoW and log in any character.
2. `SetupCore` runs your class's setup automatically (the first time only — `needsSetup` flag self-clears).
3. Spells land on bars per the class layout.
4. Re-run `/setupbars` manually after you train new spells.
5. **`/restorebars`** — every `/setupbars` snapshots your existing bars first. If the new layout isn't what you wanted, this restores your previous setup (preserves only the most recent backup).
6. **Auto-nudge after training**: when you learn a spell at a trainer that has a LAYOUT slot reserved for it but isn't on a bar yet, SetupCore prints a chat reminder to run `/setupbars`. Rank-ups don't trigger the nudge; only brand-new spells do.

## Custom addons

| addon | purpose |
|---|---|
| **SetupCore** | Shared plumbing: `ApplyLayout`, `EnsureMacro` (mouseover/startattack/etc. templates), `/setupbars` slash command, auto-leave noisy channels on first login per character. Class addons depend on it. |
| **ChatAnchor** | Re-anchors `ChatFrame1` to ElvUI's left chat panel — fixes a chat-text drift bug at 4K. |
| **ShamanSetup** | `/setupbars` Shaman layout. Pre-loaded with full TBC roster. Heals/dispels use mouseover macros automatically. Totems on OPie M4, Weapon Enchants on M5. |
| **DruidSetup** | `/setupbars` Druid layout. Feral + Balance generalist defaults; Resto-friendly heals. Form-toggle keys on the ZXCVB row; Moonkin Form on F. Bear/Cat form-specific abilities placed manually on Bar 1 form pages. Buffs (MotW/Thorns/GotW) on OPie M4, Travel forms on M5. |
| **HunterSetup** | `/setupbars` Hunter layout. Ranged generalist; Marks/Survival/BM-friendly. Auto Shot on `` ` ``, traps on QERT row. Pet bar is Blizzard's PetActionBar (not managed here). Aspects on OPie M4, Pet OOC commands on M5. |
| **PaladinSetup** | `/setupbars` Paladin layout. Ret-leaning generalist; Holy/Prot covered via untrained-skip. Judgement on `` ` ``, Crusader Strike opener, Hands on Alt-cluster. Blessings on OPie M4, Auras on M5. |
| **WarriorSetup** | `/setupbars` Warrior layout. Arms-leaning generalist; Fury/Prot covered via untrained-skip. Heroic Strike on `` ` ``, stances on F/G/Z. Stance-locked spells placed on shared bars (error silently in wrong stance). Shouts on OPie M4, Stances on M5. |

### Macro templates (in SetupCore)

When a `LAYOUT` entry has a 4th field, SetupCore generates the appropriate macro and places it on the bar slot. Templates:

| template | macro behavior |
|---|---|
| `mouseover-help` | `[@mouseover,help,nodead][help,nodead][@player]` — heal/buff that prefers cursor target, falls back to current target, then self |
| `mouseover-harm` | `[@mouseover,harm,nodead][harm,nodead]` — Purge/dispel that prefers cursor target |
| `focus-mouseover-harm` | `[@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead]` — CC pattern (sheep/banish) |
| `startattack` | adds `/startattack` before `/cast` — for melee abilities |
| `self-cast` | always `[@player]` — defensives, channeled self-cast spells |

Generated macros are named `SC_<spellname>` and re-edited (not duplicated) on subsequent `/setupbars` runs.

## Recommended companion addons

Install **WoWUp-CF** (the CurseForge-flavored fork) — has CurseForge enabled out of the box, no API key required, includes addons not on Wago: <https://github.com/WowUp/WowUp.CF/releases>

> **Note:** the Wago-only WoWUp from `wowup.io` does NOT include CurseForge access. Use the `-CF` build above to install the full recommended stack including OPie.

**Core stack:**
- **ElvUI** — UI framework. Required; our config is built around it.
- **WeakAuras** — cooldown / aura tracker.
- **BadBoy** — kills 80% of in-game spam (gold sellers, RMT, boost spam). Single biggest signal-to-noise win.
- **OPie** — radial menu addon. Recommended for putting non-time-sensitive abilities (mounts, buff totems, hearthstones, consumables) into hold-to-open rings instead of consuming bar slots. Free real estate.
- **TradeSkillMaster** — auction house replacement. Blizzard's default AH UI is essentially unusable; TSM is the standard tool even for casual players who occasionally buy/sell.

**Optional (skip unless you hit the specific pain):**
- **Prat-3.0** — chat tab management; ElvUI handles most of this so usually skip
- **BadBoy_Levels / _Guilded / _CCleaner** — only if BadBoy alone leaks spam through
- **Leave Spam Channels** — `SetupCore` already does this per-character on first login, so usually skip

### Bulk-install via WoWUp-CF
Open WoWUp-CF → **Options** → **Import Addons** → paste the contents of [`templates/wowup-addons.txt`](templates/wowup-addons.txt). This installs ElvUI + WeakAuras + BadBoy + OPie + TSM + Questie in one shot.

## WeakAuras templates

Import strings for useful WAs live in [`templates/weakauras/`](templates/weakauras/). Currently shipping:
- `lightning-shield.wa.txt` — Shev's Lightning/Water Shield reminder (Shaman)

See [`templates/weakauras/README.md`](templates/weakauras/README.md) for install instructions and a "build-your-own WA" walkthrough.

## TSM groups (TradeSkillMaster)

Pre-categorized auction-house groups for TBC Anniversary live in [`templates/tsm-groups/`](templates/tsm-groups/). Mirrored from MonChiSub's community-published TBC TSM4 setup (also used by streamer StudenAlbatroz). Six import strings covering Consumables, Gems, Materials, Patterns & Plans, Miscellaneous, and Gear (looted + crafted).

These give you sensible categorization for shopping scans, posting, and crafting workflows without authoring groups by hand. There's no automated install — TSM's SavedVariables format is too complex to safely write to from outside the addon, so you import each file via TSM's in-game UI. See [`templates/tsm-groups/README.md`](templates/tsm-groups/README.md) for the click-by-click steps.

## Maintainer scripts

`scripts/sanitize-elvui.ps1` — refresh `templates/ElvUI.lua` from your live ElvUI.lua. Strips character-specific data (profileKeys, class, gold, faction, serverID, ElvPrivateDB) while keeping the actual layout. One-liner re-export:

```powershell
.\scripts\sanitize-elvui.ps1
```

Override `-AccountName` if your Battle.net folder isn't `RYMIWE`. Run after any meaningful in-game UI change you want friends to inherit.

`scripts/apply-cvars.ps1` — apply the recommended CVar defaults from `templates/Config.wtf` into your live `_anniversary_/WTF/Config.wtf`. Smart-merge: only adds CVars not already present, never overwrites. Refuses to run while WoW is open. Use this when CVar defaults change (we add new opinionated settings) and you want them locally without manual `/console` commands:

```powershell
.\scripts\apply-cvars.ps1
```

## Customizing

Spell placement lives in each class addon's `LAYOUT` table (e.g. `_anniversary_/Interface/AddOns/ShamanSetup/ShamanSetup.lua`). After editing, in-game: `/reload` and `/setupbars`.

To force the auto-setup to re-run (e.g. after wiping bars), edit `WTF/Account/<acct>/SavedVariables/SetupCore.lua` and set `needsSetup = true`. Or just run `/setupbars` manually any time.

## Generating a new class addon

Adding support for a new class (Mage/Rogue/Priest/Warlock) is a one-shot job via the `wow-class-setup` Claude Code skill:

1. **Author the spell roster** — create `docs/class-spells/<class>.md` listing all spells with IDs, levels, categories, and class-specific layout rules. Use existing files (`shaman.md`, `druid.md`, `hunter.md`, `paladin.md`, `warrior.md`) as templates.
2. **Invoke the skill** — in Claude Code, say "generate setup for `<class>`" or "scaffold `<Class>Setup`". The skill reads the class roster + cross-class memory principles (`class_setup_pattern.md`, `bar_layout_design.md`, `bind_value_principle.md`, `auto_attack_no_slot.md`) and writes:
   - `_anniversary_/Interface/AddOns/<Class>Setup/<Class>Setup.lua` + `.toc`
   - Wires the addon into `install.ps1`, `install.sh`, `.gitignore`
   - Updates `class_setup_pattern.md` "Currently shipped" list
3. **Reload + verify** — `/reload` in WoW, then `/setupbars`. Untrained spells skip silently.

The skill enforces cross-class invariants: Bars 7/9/10 off-limits in LAYOUT, heals always `mouseover-help`, no `Attack` slot (covered by `startattack` template + right-click), OPie M4 = primary class utility ring, M5 = secondary/OOC ring. See [`.claude/skills/wow-class-setup.md`](.claude/skills/wow-class-setup.md) for the full workflow.

## Personal backup (this repo's other purpose)

The repo also tracks the maintainer's full WoW config across flavors via `.gitignore` whitelisting (`_*/WTF/...` for SavedVariables, bindings, macros). Friends installing via the script above only get the addons + bindings template — none of the personal SavedVariables come along.
