# wow-config

Opinionated UI setup for WoW Anniversary (TBC Classic 2.5.5). Built for casual play with family and friends — install once, log in, play. No spending an evening configuring action bars.

## What you get

- **Pre-configured ElvUI layout** — keyboard-mirrored bars near your character, no fiddling
- **Auto-class-setup** — `/setupbars` places your spells on the right keys when you first log in
- **Mouseover heals + dispels** — hover a party member, hit your heal key, no target-switching needed
- **Smart defaults** — Trade/General chat auto-left per character, enemy nameplates always on, friendly off
- **Auto-place on training** — newly-trained spells go on their reserved bar slot automatically, no `/setupbars` needed; `/restorebars` undoes any layout change
- **One-shot bulk-install** for recommended companion addons (ElvUI, WeakAuras, BadBoy, OPie, TSM, Questie)
- **Per-class layouts** — Shaman, Druid (Feral+Balance), Hunter, Paladin, Warrior ship now; new classes generated via the [`wow-class-setup` skill](.claude/skills/wow-class-setup.md)

Designed for the audience: kids, spouses, friends who want to log in and play. Optimized for "discoverability over efficiency" — every key bind is intuitive even if it costs 0.1s of theoretical optimization. PvP-grade speed is explicitly NOT the goal.

## End-to-end install

Pre-req: WoW Anniversary installed and **launched at least once** (so the directory structure exists).

### Step 1 — Run the installer

| Platform | Command |
|---|---|
| **Windows (easy)** | Download [`install.bat`](https://github.com/rymiwe/wow-config/raw/main/install.bat), close WoW, double-click |
| **Windows (PowerShell)** | `iex (iwr "https://raw.githubusercontent.com/rymiwe/wow-config/main/install.ps1").Content` |
| **Linux / Mac / Steam Deck** | `curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh \| bash` |

If the script can't auto-detect your WoW install:
```bash
# Linux/Mac:
curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | WOWDIR="/path/to/World of Warcraft" bash
# Or pass via flag:
curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | bash -s -- --wow-dir "/path/to/World of Warcraft"
```

The installer:
1. Copies our custom addons (`SetupCore`, `ChatAnchor`, `ShamanSetup`, `DruidSetup`, `HunterSetup`, `PaladinSetup`, `WarriorSetup`)
2. Seeds bindings + ElvUI layout + Config.wtf CVar defaults
3. Flips an auto-setup flag so `/setupbars` runs on first login
4. **Direct-downloads companion addons** from canonical sources (no addon manager required):
   - **ElvUI** from Tukui's JSON API
   - **WeakAuras / Questie / BadBoy** from GitHub Releases
   - **OPie** from townlong-yak (Foxlit's official site)

To refresh addon versions later: re-run `install.sh` / `install.ps1` (full reinstall), or use the lighter `scripts/update-addons.sh` / `scripts/update-addons.ps1` which only re-fetches the 5 community addons.

> **TSM caveat**: TradeSkillMaster isn't on a free public source we can script-fetch (distributed via their own desktop app + CurseForge auth-walled API). Install [TSM manually from CurseForge](https://www.curseforge.com/wow/addons/trade-skill-master) if you want it; otherwise skip.

### Step 2 — Launch WoW and log in

SetupCore runs your class's setup automatically on first login. Watch chat for:
```
SetupCore suppressed ElvUI wizard on N profile(s)
SetupCore first-time setup running for <CLASS>...
SetupCore asserted N bindings (cleared M defaults)
SetupCore set N CVars
<Class>Setup placed N spells
== wow-config welcome ==
```

If the **ElvUI install wizard** sneaks past the auto-suppression: **close it with the X**. Don't click "Install" / "Apply Layout" — it would wipe the layout we just deployed.

### Step 3 — Bind OPie rings (one-time)

For each class addon's OPie rings: `/opie` → Ring Bindings → find the ring → click binding → press M4 (primary class utility) or M5 (secondary).

OPie 8.x doesn't auto-bind mouse buttons via the `hotkey` field. One-time chore per character, after which they persist.

### Step 4 — (Optional) Install TSM + import TSM groups

If you use TSM: open `/tsm` → Groups → Import / Export → paste each `.txt` file from <https://github.com/rymiwe/wow-config/tree/main/templates/tsm-groups>. See that folder's README for click-by-click steps.

### Day-to-day after install

- **Train new spells** → they appear on bars automatically (no `/setupbars` typing). The reserved slot fills the moment SPELLS_CHANGED fires.
- **`/setupbars`** → re-run if you want to re-assert the full layout (rare; useful after a respec).
- **`/restorebars`** → every `/setupbars` snapshots your previous bars first. Roll back anytime.
- **`/applybindings`**, **`/applycvars`** → standalone re-apply commands if you need them.

### Modes
| flag | behavior |
|---|---|
| `--upsert` (default) | Install/update addons. Skip existing bindings, SavedVariables, and ElvUI layout. Merge new CVars into Config.wtf without overwriting existing graphics settings. |
| `--fresh` | Overwrite bindings, reseed auto-setup flag, install full ElvUI layout, replace Config.wtf entirely. Use this for a brand-new install. |

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

The installer auto-installs these via [CurseBreaker](https://github.com/AcidWeb/CurseBreaker) — **you don't have to do anything**, just run `install.ps1`/`install.sh`. Listed here for context:

**Core stack** (auto-installed):
- **ElvUI** — UI framework. Required; our config is built around it. (Tukui)
- **WeakAuras** — cooldown / aura tracker. (GitHub releases)
- **BadBoy** — kills 80% of in-game spam (gold sellers, RMT, boost spam). Single biggest signal-to-noise win. (WoWInterface)
- **OPie** — radial menu addon. We use it for class-specific utility rings (totems, blessings, aspects, shouts, etc.). (WoWInterface)
- **Questie** — quest tracker on minimap and world map. (GitHub releases)

**Manual install** (CurseBreaker doesn't support free):
- **TradeSkillMaster** — auction house replacement. Install from [CurseForge](https://www.curseforge.com/wow/addons/trade-skill-master) if you use the AH. Then import groups via [`templates/tsm-groups/`](templates/tsm-groups/).

**Optional alternative — WoWUp-CF (GUI manager)**: if you prefer a GUI for browsing/managing addons over CurseBreaker's CLI, install [WoWUp-CF](https://github.com/WowUp/WowUp.CF/releases) and bulk-import [`templates/wowup-addons.txt`](templates/wowup-addons.txt). The two managers can coexist but watching for double-updates is annoying — pick one.

**Optional individual addons (skip unless you hit the specific pain)**:
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

### Auto-checkpoint workflow (chezmoi-style)

Two patterns depending on how you launch WoW. **Pick one.**

#### Battle.net users → `scripts/watch.ps1` (recommended)

A background watcher that polls for `WowClassic.exe`, attaches when it appears, and runs `checkpoint.ps1` every time it exits. Truly invisible — you launch via Battle.net normally and the repo stays in sync.

**Install as a hidden Scheduled Task** (recommended — no terminal, no taskbar entry):

```powershell
.\scripts\install-watch-task.ps1
```

This registers a `wow-config-watch` task that runs at every logon under your user (so git credentials work), with `-WindowStyle Hidden` so there's nothing to alt-tab past. Idempotent — re-run anytime to refresh.

Uninstall with `.\scripts\install-watch-task.ps1 -Uninstall`.

To run manually instead (visible terminal window): `.\scripts\watch.ps1`.

#### Direct-launch users → `scripts/play.ps1`

Wraps `WowClassic.exe` with pre-launch fetch + post-exit checkpoint. Pin to taskbar instead of WoW. Use this if you bypass Battle.net.

```powershell
.\scripts\play.ps1
```

#### What checkpoint.ps1 does (called by both)

1. Stages `_anniversary_/WTF`, `Interface/AddOns`, and `templates`
2. Commits with auto-generated message (timestamp + diff shortstat)
3. Pushes to `origin/main`

Idempotent (no-op on no changes), non-fatal on push failure (commit is the local safety net even if you're offline).

Flags (apply to all three scripts where relevant):
- `-NoSync` — skip pre-launch fetch (`play.ps1` only)
- `-NoCheckpoint` — launch WoW without auto-commit (`play.ps1` only)
- `-NoPush` — commit locally only, don't push
- `-PollSeconds <n>` — watcher polling interval, default 30 (`watch.ps1` only)

This is the prevention story for "we lost a layout because nothing was committed" — every session ends with a commit. **Friends installing via `install.ps1` should NOT use these scripts** (they're consuming the repo, not maintaining it). They're maintainer tools.
