# wow-config — agent handoff

You are picking up work on a personal WoW Anniversary (TBC Classic 2.5.5)
configuration repo. The user is opinionated, technical, and prefers concise
direct answers. This document captures everything you need to be useful from
turn one. **Read all of it before responding.**

---

## Mission

Maintain and iterate on `rymiwe/wow-config` — a multi-machine, family-oriented
WoW configuration deployed to:
- **rymiwe (user)** — Windows 11 main rig (E:\Program Files\World of Warcraft\)
- **wife** — Intel MacBook running Arch Linux + Omarchy (Hyprland) + Proton
- **kid (son)** — Steam Deck (Game Mode), Arch SteamOS

The goal is *opinionated, idempotent, family-friendly defaults* that survive
fresh installs across all three machines. We do not try to support arbitrary
preferences; we ship one curated baseline and accept that re-running `wcu`
overwrites local tweaks.

---

## Repository

- **GitHub**: `https://github.com/rymiwe/wow-config` (private)
- **Local path**: `E:\Program Files\World of Warcraft\`
- **Branch**: `main` (no PR workflow; commits go straight)
- **Current commit philosophy**: small, focused, well-described commit messages
  with co-author trailer. User reads diffs.
- **Auto-checkpoint**: `scripts/watch.ps1` + `scripts/checkpoint.ps1` auto-
  commit-and-push WoW SavedVariable changes on Windows. So `git status` may
  reveal SV file changes you didn't make — that's fine, ignore them.

### Top-level layout

```
E:\Program Files\World of Warcraft\
├── _anniversary_\Interface\AddOns\
│   ├── SetupCore\           ← shared plumbing (the heart of everything)
│   ├── ElvUIFixes\          ← ElvUI/Anniversary runtime fixes (chat, game menu, etc.)
│   ├── ZygorSetup\          ← per-character Zygor preset injector
│   ├── ShamanSetup\ DruidSetup\ PaladinSetup\ WarriorSetup\
│   ├── HunterSetup\ MageSetup\ PriestSetup\ RogueSetup\ WarlockSetup\
│   ├── ChatPanelThemes\     ← abandoned (kept for revival; not in install)
│   ├── ElvUI\ WeakAuras\ Questie\ BadBoy\ OPie\
│       (community addons; auto-fetched by install.sh, not git-tracked)
├── _anniversary_\WTF\Account\RYMIWE\
│   └── SavedVariables\      ← per-account SVs (some tracked in git for templates)
├── templates\
│   ├── bindings-cache.wtf   ← keybinds template
│   ├── ElvUI.lua            ← ElvUI layout template
│   ├── Config.wtf           ← WoW CVars template
│   ├── SetupCore.lua        ← seeds needsSetup=true on fresh install
│   ├── tsm-groups\          ← TSM group import strings
│   ├── weakauras\           ← WeakAura import strings (.txt)
│   └── hypr-wow-submap.conf ← Hyprland keybind submap for in-game
├── scripts\
│   ├── install (.sh / .ps1 / .bat)  ← `wcu` runs install.sh from raw GitHub
│   ├── update-addons.sh     ← lighter version (community addons only)
│   ├── install-omarchy-wow.sh ← Hyprland integration (wife's box)
│   ├── hypr-wow-focus.sh    ← daemon listener for focus-based submap switch
│   ├── bump-versions.ps1/.sh ← auto-increment ## Version: on staged TOCs
│   ├── checkpoint.ps1, watch.ps1 ← auto-commit workflow
│   ├── diag.sh              ← one-line diagnostic uploader
│   └── png-to-tga.py, gen-theme-from-prompt.py (theming, abandoned but kept)
├── docs\
│   ├── class-spells\<class>.md ← canonical spell rosters (druid/hunter/paladin/shaman/warrior; mage/priest/rogue/warlock missing)
│   ├── racials.md           ← per-race active placement intent
│   ├── chat-panel-theme-prompts.md ← abandoned theme prompts
│   └── agent-handoff.md     ← THIS FILE
├── .claude\skills\wow-class-setup.md ← skill for generating class addons
├── TODO.md                  ← canonical pending-work list
├── README.md, INSTALL.txt, .gitignore
├── install.sh, install.ps1, install.bat ← top-level entry points
```

### Custom addon roles

- **SetupCore**: registers `/setupbars`, holds macro templates, applies
  bindings + CVars + class layouts. All other class addons declare via
  `SetupCore:RegisterClass(CLASS_TOKEN, runFn, layoutOrTiers)`. Has the
  level-tier resolver, form-aware `ApplyFormLayout` helper, ElvUI tooltip /
  AFK / minimap-icon initial-state pokes on `PLAYER_LOGIN`, channel-leave-on-
  first-login, Shift-paging for Druid/Warrior/Rogue.
- **ElvUIFixes**: chat dock/settings fixes + Esc-menu logout secure overlays
  (works around an ElvUI Anniversary bug — see below). Also consolidates all
  chat tabs into the left dock and hides RightChatPanel.
- **ZygorSetup**: writes opinionated Zygor settings per-character on PLAYER_LOGIN
  (windowlocked, opacity, autoselectitem, autogearauto, frame_anchor, action
  bar position).
- **`<Class>Setup` addons**: each declares a LAYOUT (or LAYOUT_TIERS), IGNORE
  set, RACIALS table, and a Run() function that calls
  `SetupCore:ApplyLayout(...)`. Some have form-specific layouts (Druid:
  BEAR_LAYOUT/CAT_LAYOUT; Warrior: BATTLE/DEFENSIVE/BERSERKER_LAYOUT; Rogue:
  STEALTH_LAYOUT) that `Run()` dispatches to via `GetShapeshiftForm()`.

---

## Family / character context

- **rymiwe**: Shaman main (Asog — Draenei, Enchanting). Pally alt (Jrti). Plays
  on Windows main rig. Considering Jewelcrafting on Asog (Draenei racial +5).
- **wife**: Mage (~L10). MacBook + Arch + Omarchy + Proton. Prefers Cmd key
  (META modifier in WoW) — but Hyprland intercepts Super+1-9 by default;
  install-omarchy-wow.sh sets up a Hyprland submap so Super+1-9 passes to WoW
  while focused. Wife's character name unknown to us; her Mage layout was
  iterated (Frost-leaning, school columns 1=Frost/2=Fire/3=Arcane, Alt-bar
  intentionally empty per her preference, level-tier-aware).
- **kid (son)**: Druid (Ocisly is currently TESTING name — needs remap to
  kid's actual character name when known). Steam Deck. Plays Feral leveling.
  Got Bear Form recently. Shift modifier is hard for him — Alt is preferred.
- **Realm**: Dreamscythe (Anniversary, US-Fresh, Alliance). All chars on same
  realm.
- **Friend group**: Druid (Feral + Balance — son), Warrior, Paladin. Friends
  list drives class addon priority.

---

## Core conventions and philosophies

These are non-negotiable unless the user explicitly says otherwise. Do not
re-litigate.

### 1. Bar layout (cross-class)

12-button bars arranged 6×2:
```
Bar 1 (MAIN TOP):    `  1  2  3  4  5  | _  Q  _  E  R  T
Bar 3 (MAIN BOTTOM): _  _  _  _  F  G  | _  Z  X  C  V  B
Bar 4 (ALT TOP):     mirror of Bar 1 with Alt modifier
Bar 5 (ALT BOTTOM):  mirror of Bar 3 with Alt modifier
Bar 7, 9: DISABLED
Bar 10: CONSUMABLES (preserved across /setupbars)
```

- ` slot = interrupt or always-ready instant (per cross-class convention)
- W gap intentional (W is forward movement)
- F/G = self-buffs / right-aligned utility
- ZXCVB = utility / form toggles / dispels
- Heals on QERT (mouseover-friendly)

### 2. Cross-class interrupt convention

The ` slot holds the class baseline interrupt:
- **Shaman**: Earth Shock
- **Mage**: Counterspell
- **Rogue**: Kick
- **Paladin**: Hammer of Justice (4s stun)
- **Druid (Bear form)**: Bash (4s stun)
- **Hunter**: Auto Shot (ranged anchor exception — no spell interrupt pre-Marks-talent)
- **Warlock, Priest**: no baseline interrupt; ` may be empty or hold always-ready

### 3. Target priority templates (in SetupCore)

Heal/harm chains. `@focus` reserved for CC.
- `mouseover-help`: `[@mouseover,help,nodead][help,nodead][@player] <spell>`
- `mouseover-harm`: `[@mouseover,harm,nodead][harm,nodead] <spell>`
- `focus-mouseover-harm`: `[@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] <spell>` (CC casts on focus when set)
- `nuke-mouseover`: same as mouseover-harm + `/startattack` prepended (for ranged casts/instant DoTs that should engage auto-attack on first press)
- `startattack`: `/startattack` + `/cast <spell>` (melee opener)
- `self-cast`: `[@player] <spell>` (channels, defensives)
- `interrupt`: `[@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] <spell>` (focus-first for stuns/silences when focus IS the CC target)
- `pally-dispel`: hard-coded Cleanse-or-Purify cascade (works any spec)
- `druid-bear-safe` / `druid-cat-safe`: form-shift safety wrappers (`[noform:N]`)

### 4. Stat-of-`/startattack`

`/startattack` is a no-op when already attacking. SAFE on:
- Damage openers (CS, MS, Bloodthirst, Sinister Strike, Frostbolt, etc.)
- Judgement (Pally — pure damage, never CC-relevant)

DANGEROUS on:
- Stuns (Hammer of Justice, Bash) — may be used to chain-CC; `/startattack`
  would break upstream sheep/sap/fear and pull aggro from CC'd mobs
- Sap, Polymorph, etc. (CC casts themselves)

### 5. Form-aware /setupbars

When a class has form/stance/stealth that pages action bars, `/setupbars`
detects current form via `GetShapeshiftForm()` and applies that form's
layout. ClearAllBars in form mode clears Bar 1 ONLY (the form-paged bar);
Bar 3-5 are shared and untouched. Form layouts therefore should ONLY contain
Bar 1 entries.

- **Druid**: form 1=Bear → BEAR_LAYOUT; form 3=Cat → CAT_LAYOUT
- **Warrior**: form 1=Battle / 2=Defensive / 3=Berserker → 3 stance layouts
- **Rogue**: form 1=Stealth → STEALTH_LAYOUT
- **Cat Prowl**: TBC ElvUI default pages `[bonusbar:1,stealth] 8` —
  separate page from non-prowl cat. PROWL_LAYOUT not yet built (user
  preference: rogue-style separate bar when kid trains cat).

### 6. Cross-form casting (Druid)

Two paths shipped:
- **Alt-bar mirror (primary, kid-friendly)**: Druid alt-numrow + alt-QERT
  mirror caster Bar 1's same slots (Wrath/Moonfire/FF on Alt-1/2/3,
  HT/Rejuv/Regrowth/Lifebloom on Alt-Q/E/R/T). WoW's `/cast` AUTO-CANCELFORMS
  when casting a caster spell from a form, so the existing `mouseover-help`
  template works without `/cancelform`. Press Alt+E in bear → auto-shifts
  out, casts Rejuv via mouseover-help.
- **Shift-paging (secondary, grown-up)**: ElvUI Bar 1 paging starts with
  `[mod:shift] 1` for Druid/Warrior/Rogue. Hold Shift in any form → bar 1
  shows caster page. Default Shift+1..= page-cycle conflicts unbound via
  `bind SHIFT-X NONE`-equivalents (actually `bind SHIFT-X ACTIONBUTTON…` to
  match plain X).

### 7. OPie ring conventions

M4/M5 mouse-button hold rings. Class-conditional registration to prevent
cross-class M4/M5 collision (account-wide override binding).

| Class | M4 (primary) | M5 (secondary) |
|---|---|---|
| Druid | **Forms** (Bear/Cat/Travel/Aquatic/Flight/Moonkin/Tree/Prowl) | Buffs (MotW/Thorns/GotW) |
| Shaman | Totems | Weapon Enchants |
| Hunter | Aspects | Pet OOC commands |
| Paladin | Blessings | Auras |
| Warrior | Shouts | Stances |
| Mage | Armors | Conjures + Portals + Teleports |
| Priest | Buffs (Fortitude/Spirit/Shadow Protection/Fear Ward) | OOC utility (Mind Vision, Inner Focus, Mana Burn) |
| Rogue | (none) | OOC utility (Pick Lock, Disarm Trap, Distract, Detect Traps) |
| Warlock | Curses | Pet summons + Stones |

Druid M4/M5 was SWAPPED 2026-05-13 (Forms moved to M4/lower button per kid's
thumb ergonomics, Buffs to M5).

### 8. Layout tiers

`SetupCore:RegisterClass(CLASS, runFn, layoutOrTiers)` accepts either a flat
LAYOUT array OR a LAYOUT_TIERS array of `{minLevel = N, layout = {...}}`. The
resolver picks the highest tier where `playerLevel >= minLevel`. PLAYER_LEVEL_UP
nudges `/setupbars` when crossing a tier threshold.

Currently only **MageSetup** uses LAYOUT_TIERS (L1, L10, L20). Other classes
use flat LAYOUT.

### 9. Install / wcu

- **`wcu` shell alias** (added by install.sh on first run): `curl -sL
  https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | bash`
- **Default mode**: `--fresh` (overwrite bindings/ElvUI/SetupCore + reseed
  needsSetup). Per opinionated baseline philosophy.
- **`--upsert` mode**: smart-merge bindings (append new lines whose KEY isn't
  already bound), preserve existing ElvUI/Config files. For users who want
  customizations preserved.
- **Version-skip**: install.sh checks each community addon's TOC `## Version`
  against upstream (Tukui JSON for ElvUI, GitHub Releases tag for WA/Questie/
  BadBoy, URL-embedded version for OPie). Skips download if equal.
- **Multi-flavor TOC handling**: `local_toc_version()` globs for `*_TBC.toc`
  first, then `*_Wrath.toc`, etc., then plain `*.toc`. ElvUI/WeakAuras ship
  multi-flavor TOCs.
- **Hyprland integration**: install.sh detects Hyprland (HYPRLAND_INSTANCE_SIGNATURE
  env or hyprctl in PATH) and auto-runs `install-omarchy-wow.sh` which sets up
  the wow submap + focus-listener daemon.
- **install.ps1 PARITY GAP**: install.ps1 doesn't have version-skip /
  multi-flavor TOC / OPie regex fix yet. TODO item.

### 10. Auto-bump TOC versions

`scripts/bump-versions.ps1` (and `.sh`) scans `git diff --cached --name-only`
for paths matching `_anniversary_/Interface/AddOns/<addon>/`, increments the
last numeric component of the addon's TOC `## Version:`, re-stages the bumped
TOC. Called from `checkpoint.ps1` before commit. Current versions are visible
in addon TOCs.

### 11. Memory system

User has persistent memory at:
`C:\Users\rymiw\.claude\projects\E--Program-Files-World-of-Warcraft--anniversary-\memory\`

Index in `MEMORY.md`. Each memory is a separate `.md` with frontmatter
(name, description, type). Types: user, feedback, project, reference.

Key memories worth knowing about (ALL files in that dir):
- `target_priority_convention.md` — the heal/harm chain rules
- `class_setup_pattern.md` — cross-class layout conventions
- `setupcore_architecture.md` — how SetupCore + class addons fit together
- `friends_classes.md` — who plays what
- `auto_checkpoint_workflow.md` — the SV auto-commit setup
- `chat_anchor_addon.md` — root cause + fix for chat panel issue
- `bind_value_principle.md` — high-value binds reserved for combat
- `wow_api_classic_safety.md` — TBC API gotchas
- `powershell_ascii_only.md` — no em-dashes / non-ASCII in .ps1 files
- `todo_pointer.md` — pointer to TODO.md at repo root
- Several others — read MEMORY.md to enumerate

Update memories when: explicit user instruction; correction worth remembering;
non-obvious validated approach.

---

## Macro template catalog (full, in `SetupCore/SetupCore.lua` `MACRO_TEMPLATES`)

| Template | Body shape |
|---|---|
| `mouseover-help` | `#showtooltip\n/cast [@mouseover,help,nodead][help,nodead][@player] <spell>` |
| `mouseover-harm` | `#showtooltip\n/cast [@mouseover,harm,nodead][harm,nodead] <spell>` |
| `focus-mouseover-harm` | `#showtooltip\n/cast [@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] <spell>` |
| `nuke-mouseover` | `#showtooltip\n/startattack\n/cast [@mouseover,harm,nodead][harm,nodead] <spell>` |
| `startattack` | `#showtooltip\n/startattack\n/cast <spell>` |
| `self-cast` | `#showtooltip\n/cast [@player] <spell>` |
| `interrupt` | `#showtooltip\n/cast [@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] <spell>` |
| `druid-bear-safe` | `#showtooltip\n/startattack\n/cast [noform:4] <spell>` |
| `druid-cat-safe` | `#showtooltip\n/startattack\n/cast [noform:1] <spell>` |
| `pally-dispel` | hard-coded Cleanse-or-Purify cascade (ignores spell-name arg) |

Adding a new template: edit `MACRO_TEMPLATES` in `SetupCore.lua`. They're
just `function(spell) -> string` map. SetupCore writes them as macros named
`SC_<spellNameNoSpaces>` (16-char limit) when ApplyLayout encounters a
LAYOUT entry with `template = "<name>"` in the 4th slot.

---

## Per-class layout summary (current state)

### Druid

LAYOUT (caster):
- ` empty
- 1 Wrath, 2 Moonfire, 3 Faerie Fire, 4 empty, 5 empty
- Q Healing Touch, E Rejuvenation, R Regrowth, T Lifebloom
- F empty, G Nature's Swiftness
- Z–B empty (forms in OPie)
- Alt-bar MIRRORS Bar 1 (Wrath/Moonfire/FF on alt-numrow + Starfire/IS in empty caster slots; HT/Rejuv/Regrowth/Lifebloom on alt-QERT for cross-form). Cross-form casting via Alt+key.
- Alt-bottom: Cure Poison/Remove Curse, Entangling Roots/Hibernate/Rebirth, Barkskin/Dash

BEAR_LAYOUT (form 1):
- ` Bash (interrupt convention)
- 1 Mangle (Bear), 2 Swipe, 3 Lacerate, 4 Demoralizing Roar, 5 Maul
- Q Growl, E Challenging Roar, R Frenzied Regeneration, T Enrage

CAT_LAYOUT (form 3):
- ` Claw, 1 Mangle (Cat), 2 Shred, 3 Rake, 4 Ferocious Bite, 5 Rip
- Q Tiger's Fury, E Pounce, R Ravage, T Maim

OPie: M4 Forms (recently swapped from M5), M5 Buffs.

### Paladin

LAYOUT (Ret-leaning movement-optimal):
- ` Hammer of Justice (interrupt convention; NO startattack — CC break risk)
- 1 Crusader Strike (startattack), 2 Hammer of Wrath, 3 Consecration, 4 Avenger's Shield, 5 Avenging Wrath
- Q Judgement (startattack — most-pressed Ret combat)
- E EMPTY (LoH demoted to Alt-E — 60-min CD didn't earn prime slot)
- R Purify (pally-dispel — Cleanse-or-Purify cascade)
- T Righteous Defense (mouseover-help — main tank taunt, plain key for reactive use)
- F Seal of Righteousness, G Seal of the Crusader
- Z BoF, X BoP, C BoS (Hand spells, mouseover-help)
- V Divine Shield, B Divine Protection
- Alt-bar: Holy Light/Flash of Light/Exorcism/Holy Wrath/Repentance (casts), Lay on Hands on Alt-E, Redemption on Alt-R, Holy Shock on Alt-T, Divine Intervention/Plea/Favor on alt-bottom, Righteous Fury on Alt-B

OPie: M4 Blessings, M5 Auras.

NOTE: There's an in-progress task to add a `pally-rd` macro template to use
`@targettarget` cascade for Righteous Defense (lets you target the runner mob
and press T → resolves to the friend the mob is attacking → taunts mobs to
you). Not yet shipped. The user asked about it; I was about to ship when they
pivoted to this handoff.

### Mage (LAYOUT_TIERS)

L1 tier: Frostbolt 1, Fireball 2, Arcane Missiles 3, Fire Blast E, Polymorph
R, Frost Armor F, Naaru on V (Draenei racial)

L10 tier: + Frost Nova Q (mirrors Fire Blast on E), Slow Fall B, Arcane
Explosion X

L20 tier: + Counterspell `, Pyroblast 4, Scorch 5, Blink T, Conjure Mana Gem
G, Cone of Cold Z, Mana Shield C

ALT BAR INTENTIONALLY EMPTY per wife's preference. L11+ skills not in earlier
tiers are IGNORE'd (Slow Fall, Arcane Explosion, Blink, Mana Shield,
Counterspell, Cone of Cold, Conjure Mana Gem).

OPie: M4 Armors, M5 Conjures+Portals+Teleports.

### Shaman, Hunter, Warrior, Priest, Rogue, Warlock

See each addon's LAYOUT for current state. They're functioning — only edit
when user asks.

Warrior has 3 stance layouts (BATTLE/DEFENSIVE/BERSERKER) for stance-aware
/setupbars.

Rogue has STEALTH_LAYOUT for stealth bar (Cheap Shot/Garrote/Ambush/Sap/etc.).

---

## Workflow

### To pick up a task

1. Read this file (you just did)
2. Read `TODO.md` at repo root (current pending work)
3. Read recent git log (`git log --oneline -20`) for what just shipped
4. If user says "work on X" — check if it's in TODO; either tick off and
   continue or address the new ask
5. Check memory dir for relevant notes (`MEMORY.md` is the index)

### To make a change

1. Edit files (use Edit/Write — DO NOT auto-create new files unless asked)
2. Stage with `git add -A`
3. Run `powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bump-versions.ps1"`
   (auto-bumps TOC Version on changed addons)
4. Re-stage `git add -A` (to capture bumped TOCs)
5. Commit with descriptive message + co-author trailer
6. Push to origin/main
7. If TODO item closed, update TODO.md (move to Settled / shipped section)
8. If novel finding worth remembering, write a memory note

### To deploy

User runs `wcu` on each machine. Done. install.sh fetches the latest from
GitHub raw, applies everything fresh.

### Useful commands

```bash
# View recent commits
git log --oneline -20

# See what's currently uncommitted
git status --short

# Check addon TOC version
grep -h '## Version:' _anniversary_/Interface/AddOns/<Addon>/<Addon>.toc

# Dump SetupCore macro templates
grep -A 3 'MACRO_TEMPLATES' _anniversary_/Interface/AddOns/SetupCore/SetupCore.lua | head -30

# Find a spell's slot in a class addon
grep -n '<Spell Name>' _anniversary_/Interface/AddOns/<Class>Setup/<Class>Setup.lua
```

---

## Novel findings worth knowing (gotchas we discovered)

These bit us; don't rediscover them.

1. **ElvUI ChatFrame1 docker race on Anniversary**: `Chat.lua:1375` guards
   `[chat.isDocked and chat == docker]` where docker may be nil at PLAYER_LOGIN.
   ChatFrame1 fails the guard, FindChatWindows returns nil, PositionChat
   silently skips the LeftChatPanel SetPoint branch. ElvUIFixes addon works
   around it by:
   1. Force-setting `_G.GeneralDockManager.primary = ChatFrame1`
   2. Calling `CH:PositionChats()`
   3. Hooking `ChatFrame1:SetPoint` as belt-and-suspenders

2. **Zygor's `actionbar_anchor_snapped = true` is broken for resizeup**:
   `Functions.lua:2233` `SetFrameAnchor` IGNORES the relativeTo field, always
   uses UIParent. `ActionBar.lua:413` SavePosition with snap=true pins to
   UIParent at viewer's CURRENT top — not following viewer dynamically.
   When viewer grows up, action bar's stale screen position ends up inside
   viewer bounds. Fix: snap=false + fixed Y high enough to never overlap.

3. **OPie regex greedy bug**: `[0-9.]+` is greedy on `.`, so matching
   `OPie-8.3.3.zip` captures `OPie-8.3.3.` (trailing dot from `.zip`). Fixed
   in install.sh by switching to bash parameter expansion. install.ps1
   still has this bug (TODO item).

4. **Multi-flavor TOC**: ElvUI/WeakAuras don't ship `<Name>.toc` — they ship
   `<Name>_TBC.toc`, `<Name>_Mainline.toc`, etc. Version-detection that reads
   `<Name>.toc` returns empty → triggers re-fetch every install. Fixed by
   globbing for `*_TBC.toc` first.

5. **Druid Prowl pages bar 1 to its own page** (page 8): TBC ElvUI default
   `[bonusbar:1,stealth] 8` separates prowl-cat from regular cat. Means we
   can have a PROWL_LAYOUT separate from CAT_LAYOUT. Not yet built.

6. **`/cast` auto-cancels form for Druid caster spells**: WoW's built-in
   behavior. No `/cancelform` needed in macros — pressing Rejuv on a button
   from bear form auto-shifts out and casts. Discovered when we considered
   building `cancelform-help` template; turned out unnecessary.

7. **WoW Shift+1..= default = ACTIONPAGE cycle**: collides with our
   shift-as-form-page-modifier idea AND triggers accidental page swaps
   mid-combat. Bound `SHIFT-X` to the matching `ACTIONBUTTON` to neutralize.

8. **CC-break risk on `/startattack` with stuns**: HoJ, Bash, Sap, Polymorph
   should NOT have startattack — would auto-melee a CC'd target and break
   sheep/sap/fear or pull aggro. Pure damage openers (CS, MS, Judgement)
   are safe.

9. **Form-paged bars only affect Bar 1**: Bars 2-9 don't page with form/
   stance/stealth. Form layouts should ONLY contain Bar 1 entries; ApplyForm
   Layout clears Bar 1 only. Putting form-spell entries on Bar 3-5 in form
   layouts would clobber caster utility on form `/setupbars`.

10. **Hyprland Super+1-9 conflicts with WoW**: install-omarchy-wow.sh sets
    up a Hyprland submap that activates when `wow.exe` is focused. Submap
    re-binds Super+1-9 to no-op (passes to WoW) but keeps Super+Tab for
    workspace cycling. Daemon (hypr-wow-focus.sh) listens to Hyprland IPC
    socket via socat for activewindow events.

11. **WoW modifier strings**: ALT, CTRL, SHIFT, META are the four. META = Cmd
    on Mac / Win/Super on Linux. In wife's setup, dual-binding ALT-X +
    META-X covers both modifiers (Cmd through Proton typically passes as
    META).

12. **Per-character Zygor SV format**: Zygor stores per-char config under
    `ZygorGuidesViewerClassicSettings.char[<key>]` where `<key>` is
    sometimes `<Name>` and sometimes `<Name> - <Realm>` depending on Zygor
    version. ZygorSetup writes to BOTH keys to be safe.

13. **PowerShell + non-ASCII**: Windows PowerShell reads .ps1 files as
    Windows-1252 unless they have a UTF-8 BOM. Em-dashes / curly quotes /
    other Unicode in .ps1 files cause silent parse errors. Stick to ASCII.

---

## Current TODO (live state)

Read `TODO.md` at repo root for the canonical, always-current list. Categories:

- **High value / actively waiting on**: install.ps1 parity, Mage L30 tier,
  MageSetup Alt-T placeholder, kid character remap (Ocisly → kid's name)
- **Discussed but never built (waiting for trigger)**: bind profile system,
  class-addon LoadOnDemand, upstream ElvUI PR
- **Class-specific spell docs missing**: mage, priest, rogue, warlock
- **Form-aware bar follow-ups**: Druid Prowl sub-bar (when kid trains it)
- **Polish / smaller items**: install.ps1 wcu function port, smart-merge for
  ElvUI.lua/Config.wtf, wcu --rollback, socat auto-install prompt, Hyprland
  multi-game support, ElvUIFixes diag for second mover, Pally tertiary OPie
  ring for OOC utility

---

## In-progress work (left mid-flight)

**Pally Righteous Defense `@targettarget` macro template.** User asked: "is it
common to use Righteous Defense with a macro that targets target or
something?" Yes — Pally tank staple. The cascade lets you target the runner
mob and press taunt; `@targettarget` resolves to the friend the mob is
attacking.

I was about to add a `pally-rd` template to SetupCore:
```lua
["pally-rd"] = function(_)
    return table.concat({
        "#showtooltip Righteous Defense",
        "/cast [@mouseover,help,nodead] Righteous Defense",
        "/cast [@target,help,nodead] Righteous Defense",
        "/cast [@targettarget,help,nodead] Righteous Defense",
    }, "\n")
end,
```

And update PaladinSetup LAYOUT line for Righteous Defense from
`mouseover-help` template to `pally-rd` template.

If continuing this task: ship that template, bump versions, commit, push.
Mention `@targettarget` in comments so future readers understand the cascade.

---

## Tips for the new agent

User behaviors that work well:
- **Concise direct answers**. No filler. State the answer, then context if
  needed.
- **Be honest about uncertainty**. "I'm guessing X based on Y" beats
  confident-but-wrong.
- **Ship small commits**. Each commit one logical change. Co-author trailer
  required.
- **Push to remote immediately**. User deploys via `wcu`; needs main current.
- **Use parallel tool calls** when independent. User notices when you don't.
- **Test paths**: don't claim something works if you can't verify. Caveat
  appropriately.

User behaviors that don't work:
- Long preambles ("I'll first..."). Just do it.
- Asking permission for every step. User trusts judgment within scope.
- Inventing facts. WoW-specific claims should match TBC reality; if unsure,
  WebSearch / WebFetch to verify.
- Suggesting third-party tools / addons without verifying canonical source.
  We have memories on this (opie_install_source, wowup_versions).

User likes when:
- You read TODO.md before answering "what's pending"
- You verify with the actual file before claiming a state
- You write memory notes for non-obvious validated approaches
- You proactively flag risks (security, CC break, etc.) when proposing changes

When in doubt:
- Check `git log --oneline -20` for recent context
- Read the relevant addon file directly
- Verify a Wago.io / Wowhead claim with WebFetch
- Ask the user clarifying questions for >2-line-impact decisions

---

## Versions (as of this handoff, pulled from TOCs)

Custom addons are auto-bumped on commit. Latest versions visible via:
```
grep -h "## Version" _anniversary_/Interface/AddOns/{SetupCore,ElvUIFixes,ZygorSetup,DruidSetup,PaladinSetup,ShamanSetup,WarriorSetup,HunterSetup,MageSetup,PriestSetup,RogueSetup,WarlockSetup}/*.toc
```

Community addons (auto-fetched, can drift):
- ElvUI v15.13
- WeakAuras 5.21.6
- Questie 11.26.1
- BadBoy v12.0.0
- OPie 8.3.3

---

End of handoff. You should now have enough context to:
- Answer "what's pending?" by reading TODO.md
- Make focused changes that respect existing conventions
- Avoid rediscovering known gotchas
- Write commits the user can read and approve

Welcome to the project.
