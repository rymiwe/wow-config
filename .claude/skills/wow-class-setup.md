---
name: wow-class-setup
description: Generate a class setup addon (e.g., HunterSetup, MageSetup, PaladinSetup) for the wow-config repo. Reads the class's spell roster from docs/class-spells/<class>.md, applies UI design principles from memory, and outputs a complete <Class>Setup.lua + .toc mirroring the existing Shaman/Druid pattern. Use when user says "generate setup for <class>", "scaffold a new class addon", "make a HunterSetup", or similar.
---

# wow-class-setup

You're generating a `<Class>Setup.lua` for the wow-config repo. **The output MUST mirror the structure of existing `ShamanSetup.lua` and `DruidSetup.lua`** so all class addons stay maintainable. Cross-class consistency is non-negotiable — the pattern is captured in `class_setup_pattern.md` memory.

## Step 1 — Gather inputs

Ask the user (or accept from args):
1. **Class** — `hunter`, `mage`, `warrior`, `rogue`, `priest`, `warlock`, `paladin` (Shaman and Druid are already done)
2. **Spec hint (optional)** — `Marksman`, `Frost`, `Arms`, etc. Affects which spells get prime real estate but layout shape stays the same.
3. **Level (optional)** — defaults to "all spells" since untrained spells are skipped silently by SetupCore.

## Step 2 — Required reads (in this order)

1. `MEMORY.md` for the principle index
2. `bar_layout_design.md` — bar slot conventions, what's enabled/disabled
3. `class_setup_pattern.md` — the cross-class template (CRITICAL — defines slot conventions including racial placement)
4. `bind_value_principle.md` — what gets high-value binds
5. `auto_attack_no_slot.md` — never put `Attack` in LAYOUT
6. `ui_design_principles.md` — the 7 guiding principles
7. `setupcore_architecture.md` — macro template names + LAYOUT 4-tuple format + RACIALS table format
8. `E:\Program Files\World of Warcraft\docs\class-spells\<class>.md` — class spell roster + class-specific layout overrides
9. `E:\Program Files\World of Warcraft\docs\racials.md` — per-racial placement intent (auto-placed via RACIALS table per race)
10. Existing `ShamanSetup.lua` and `DruidSetup.lua` as reference shape

If `docs/class-spells/<class>.md` doesn't exist: STOP and tell the user to create it first (or have them provide the spell list inline so you can author the doc + setup in one pass).

## Step 3 — Apply decision rules

The layout shape is universal across classes (per `class_setup_pattern.md`). The class spell roster doc defines class-specific overrides for which spells go where. Apply rules in this order:

1. **OPie rings first** — identify class-specific categories that suit OPie hold-rings (slow utility, lots of similar choices, low combat priority). Don't put these spells on bars.
2. **Cast-time damage → Bar 4 numrow (Alt-1..5).** Caster filler nukes (Lightning Bolt, Wrath, Starfire), hard-cast spells (Aimed Shot, Steady Shot, Exorcism, Holy Wrath). NOT on Bar 1 numrow. The most-spammed cast goes on Alt-1.
3. **Instant damage / DoTs / debuffs / instant CC → Bar 1 numrow (1-5).** Primary opener (instant DoT or first-pressed combat spell) on key 1 with `startattack` template.
4. **Bar 1 `` ` `` slot — interrupt or "always-ready" instant only.** Reserve for: (a) class baseline interrupt (Shaman: Earth Shock; Mage: Counterspell; Rogue: Kick); (b) ranged anchor with no better home (Hunter: Auto Shot); (c) always-ready combat-modifier (Pally: Judgement; Warr: Heroic Strike). Otherwise leave empty — `` ` `` is a pinky-stretch and NEVER hosts the most-spammed action.
5. **Heals on Alt-QERT** (Bar 4 buttons 8/10/11/12). All `mouseover-help`.
6. **Cooldowns on Alt-numrow remainder** (Bar 4 buttons 4-6 if not used by cast-damage). Tiger's Fury, Berserk, Avenging Wrath, Recklessness, etc.
7. **Buffs F/G** (Bar 3 buttons 4/5). Class self-buffs, spec-defining toggles (Moonkin Form, Seals), and mouseover friend-buffs.
8. **ZXCVB row** (Bar 3 buttons 8-12). Form/stance toggles, weapon enchants (or OPie), travel utility, class spells. Never `Attack` (see `auto_attack_no_slot.md`).
9. **Alt-FG / Alt-ZXCVB** (Bar 5 buttons 4/5/8-12). Dispels (mouseover-help/harm), defensives (`self-cast`), travel utility, panic abilities.
10. **Form-locked combat (Druid Bear/Cat, Rogue stealth)** → IGNORE list, drag manually onto Bar 1 form pages.
11. **Passives, racials, professions, all OPie-handled spells** → IGNORE.

**Cast-vs-instant principle (rules 2 & 3):** instants are "decision points" you weave tactically; casts are the spam-filler between them. Putting them on different modifier rows separates muscle memory and matches caster gameplay flow. A class with no cast-time damage (pure-melee Warrior/Rogue) leaves Alt-numrow free for cooldowns + utility instead.

## Step 4 — Macro template choice

Use templates from `setupcore_architecture.md`:
- `mouseover-help` — heals, friend-buffs, friend-target dispels
- `mouseover-harm` — enemy debuffs, dispels-from-enemy (Purge), CC like Polymorph/Roots/Hibernate
- `focus-mouseover-harm` — marked CC for tank-led parties (Polymorph)
- `startattack` — combat openers
- `self-cast` — channeled AOE heals (Tranquility), defensives (Barkskin), self-only buffs that should never miscast
- `interrupt` — class interrupt with smart targeting (focus → mouseover → target)
- `druid-bear-safe`, `druid-cat-safe` — Druid-only form safety

Apply per-spell based on its targeting + role. Don't over-template; if a spell needs no priority logic (e.g. self-target Lightning Shield), no macro template.

## Step 5 — OPie ring conventions

**M4 = primary class utility ring** (the class's signature category). Examples:
- Shaman: Totems
- Druid: Buffs (MotW/Thorns/GotW)
- Hunter: Aspects
- Mage: Portals + Teleports
- Warlock: Curses
- Paladin: Blessings
- Warrior: Shouts (Battle/Commanding/Berserker Rage as toggle?)
- Rogue: Poisons
- Priest: ??? (Discipline cooldowns? Holy auras don't really exist in TBC)

**M5 = secondary / OOC ring** (slow utility, mounts, conjures, etc.). Examples:
- Shaman: Weapon Enchants
- Druid: Travel forms
- Hunter: Pet management (Mend Pet, Revive Pet, Feed Pet, Dismiss Pet, Call Pet)
- Mage: Conjure Food/Water/Mana Gem
- Warlock: Soulstone, Healthstone, Summon variants
- Paladin: Auras (Devotion/Retribution/Concentration/etc.)

Ring slice format: `{id="/cast {{spell:NNN}}", _u="xx"}` — the `{{spell:N}}` macro syntax casts highest known rank automatically. Use 2-letter `_u` IDs for slice uniqueness within the ring.

Ring registration goes in a `do ... end` block at file bottom, AFTER `RegisterClass`. Wrap with TWO guards:
1. **Class check**: `local _, class = UnitClass("player"); if class ~= "<CLASS>" then return end` — OPie bindings are account-wide; registering rings for non-matching classes causes cross-class M4/M5 collisions.
2. **OPie check**: `if not (R and R.AddDefaultRing) then return end` — gracefully no-ops if OPie isn't installed.

Ring `hotkey` field: `"BUTTON4"` or `"BUTTON5"`. Note the OPie binding currently doesn't auto-apply for mouse buttons (known gap) — friends manually re-bind in `/opie` UI on first run. Until that's fixed, the `hotkey` field still acts as a default suggestion in OPie's binding panel.

## Step 6 — Output

Write two files:

**`E:\Program Files\World of Warcraft\_anniversary_\Interface\AddOns\<Class>Setup\<Class>Setup.toc`**
```
## Interface: 11508, 20505, 50503, 120005
## Title: <Class> Setup
## Notes: /setupbars - populate ElvUI action bars from a hardcoded layout
## Version: 1.0
## Dependencies: SetupCore
## OptionalDeps: OPie

<Class>Setup.lua
```

**Why multi-version Interface:** WoW silently refuses to load addons whose Interface doesn't match the running client (unless "Load out of date addons" is checked). Multi-version comma-separated declares the addon works on Classic Era (11508), TBC Anniversary (20505), MoP Classic (50503), and Retail (120005). Add new flavor numbers as Blizzard releases them. This was a real bug that hit ChatAnchor on the wife's Anniversary install — single-version 11508 meant the addon never loaded.

**Why `OptionalDeps: OPie`:** WoW loads addons alphabetically by default. Without this directive, every class addon (DruidSetup, HunterSetup, PaladinSetup, ShamanSetup, WarriorSetup — all D/H/P/S/W < O) loads BEFORE OPie. The `OPie and OPie.CustomRings` check in the ring registration block then silently fails because OPie isn't loaded yet → no rings registered → user opens `/opie` and sees no class rings to bind. `OptionalDeps: OPie` forces load order so OPie loads first when present (and addon still works without OPie installed).

**`E:\Program Files\World of Warcraft\_anniversary_\Interface\AddOns\<Class>Setup\<Class>Setup.lua`** — full file mirroring DruidSetup/ShamanSetup, including:
1. Header comment (1-2 paragraphs explaining class + leveling defaults + OPie ring summary)
2. `local LAYOUT = { ... }` with grouped sections (MAIN TOP / MAIN BOTTOM / ALT TOP / ALT BOTTOM, with comment headers)
3. `local IGNORE = { ... }` with grouped sections (combat passives, class talents, race passives, OPie-handled, form-locked if applicable, professions, death-handling). Most race actives are NOT in IGNORE — they're auto-placed via RACIALS table.
4. Class-specific helper tables if applicable (e.g. `BEAR_ABILITIES` for Druid)
5. `local RACIALS = { ... }` — per-race racial placements. Consult `docs/racials.md` for placement intent per race; pick slot per the class's available layout. Pass to `SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)`.
6. `local function Run() ... end`
7. `SetupCore:RegisterClass("<CLASS_TOKEN>", Run, LAYOUT)` — CLASS_TOKEN is uppercase ("HUNTER", "MAGE", etc.)
8. `do ... end` OPie ring block at bottom

## Step 7 — Update related files

After generating the addon:
1. Add `<Class>Setup` to the `addons = @(...)` list in `install.ps1` (around line 89)
2. Add `<Class>Setup` to the `ADDONS=(...)` list in `install.sh` (around line 98)
3. Add the gitignore whitelist line `!_*/Interface/AddOns/<Class>Setup/` and `!_*/Interface/AddOns/<Class>Setup/**`
4. Update `class_setup_pattern.md` memory's "Currently shipped" list

## Step 8 — Validation

Before declaring done, verify:
- All LAYOUT spell names match entries in `docs/class-spells/<class>.md`
- No spell appears in both LAYOUT and IGNORE
- All form-locked / passive / OPie-handled spells are in IGNORE
- LAYOUT bar/button coordinates are valid: Bar 1 (1-12), Bar 3 (1-12), Bar 4 (1-12), Bar 5 (1-12). Bars 2, 6, 7, 8, 9, 10 must NOT appear.
- Spell IDs in OPie rings are TBC-correct (cross-check against the docs file)
- Macro templates referenced in LAYOUT entries exist in `setupcore_architecture.md`'s template list
- Race actives are in IGNORE (not auto-placed; user drags manually)
- For form/stance classes: form abilities listed in `IGNORE` AND in helper tables for the print() guidance

## Cross-class invariants (DO NOT BREAK)

- Bars 7, 9, 10 are off-limits in LAYOUT
- Heals always use `mouseover-help` (cast-on-cursor pattern is universal for healers)
- Damage spells without combat-opener intent never need a macro template
- **Never place `Attack` (melee auto-attack toggle) in LAYOUT** — `startattack` template + right-click cover it. Always keep `["Attack"]=true` in IGNORE. Hunter `Auto Shot` is the only exception (ranged auto, distinct from melee). See `auto_attack_no_slot.md` memory.
- ShamanSetup and DruidSetup must keep working — verify they still load after any SetupCore changes
- Don't break the `Run()` signature; SetupCore expects `Run()` returning nothing, calling ApplyLayout itself

## When to STOP and ask the user

- Class spell roster doc doesn't exist
- Spec significantly changes layout (Holy vs Ret Paladin, Frost vs Fire Mage, etc.) — confirm spec
- Class has unusual mechanics not covered by current macro templates (Hunter pet bar, Warlock soul shards, Paladin seals/judgments) — discuss before generating
- User wants level-gated subset (only spells trained at level X) — confirm subset behavior
