# Hunter spell roster — TBC Classic / Anniversary (Interface 20505)

Canonical spell reference for the `wow-class-setup` skill. Format mirrors shaman.md / druid.md.

**Schema per entry:** `<spell_id> | <name> | <level_learned> | <category> | <targeting> | <notes>`

Categories: `damage`, `shot`, `sting`, `trap`, `aspect`, `pet-cmd`, `pet-active`, `tracking`, `cc`, `utility`, `buff`, `racial-active`, `passive`, `profession`

Targeting: `self`, `enemy`, `pet`, `ground` (trap placement), `instant`, `cast-time`

---

## SHOTS / DAMAGE — combat-active, current-target

These go on Bar 1 number row. Auto Shot anchors `` ` `` so the user can fire even with no other bar press. Primary opener gets `startattack` (which also issues `/startattack` for melee weapons in case mob closes).

- 75 | Auto Shot | 1 | shot | enemy-instant | Anchor on `` ` ``; toggleable
- 2973 | Raptor Strike | 1 | damage | enemy-instant | Melee on-next-swing; usually IGNORE (replaced by other actions in ranged play)
- 3044 | Arcane Shot | 6 | shot | enemy-instant | Filler; always-ready damage
- 3043 | Scorpid Sting | 8 | sting | enemy-instant | -STR/-AGI debuff
- 1978 | Serpent Sting | 4 | sting | enemy-instant | DoT 15s; ideal opener (use `startattack` template)
- 19434 | Aimed Shot | 20 | shot | enemy-cast | 3s cast big hit; Marks signature opener (alternative to Serpent Sting)
- 2643 | Multi-Shot | 18 | shot | enemy-instant | 3-target burst
- 5116 | Concussive Shot | 8 | shot | enemy-instant | Slow; kiting
- 1499 | Freezing Trap | 20 | trap | ground | CC trap; drop pre-pull
- 14269 | Frost Trap | 28 | trap | ground | AOE slow
- 13813 | Explosive Trap | 34 | trap | ground | AOE damage trap
- 13795 | Immolation Trap | 16 | trap | ground | DoT trap
- 34600 | Snake Trap | TBC L60+ | trap | ground | Summons snakes; misc utility
- 19386 | Wyvern Sting | 40 | sting | enemy-instant | Survival CC sleep
- 14260 | Raptor Strike (rank up) | various | damage | enemy-instant | Use highest known
- 1495 | Mongoose Bite | 16 | damage | enemy-instant | Survival; reactive after dodge
- 19184 | Wing Clip | 12 | utility | enemy-instant | Snare; melee range
- 19306 | Counterattack | 30 | damage | enemy-instant | Survival reactive
- 49001 | Steady Shot | TBC L62+ | shot | enemy-cast | TBC core ranged filler; weave with Auto
- 34026 | Kill Command | TBC L66+ | utility | enemy-instant | BM burst; fires after pet crit
- 19503 | Scatter Shot | 30 | cc | enemy-instant | 4s disorient; survival break
- 19801 | Tranquilizing Shot | 40 | dispel | enemy-instant | Strips frenzy/magic from enemy (`mouseover-harm`)
- 20736 | Distracting Shot | 8 | utility | enemy-instant | Threat pull; rare in solo
- 14327 | Scare Beast | 14 | cc | enemy-cast | Fear beasts; situational
- 1513 | Scare Beast (rank 1) | same | cc | enemy-cast | Fear beasts
- 1543 | Flare | 8 | utility | ground | Reveals stealth in area
- 982 | Revive Pet | 10 | pet-cmd | self-cast | Out-of-combat pet rez
- 136 | Mend Pet | 4 | pet-cmd | self-cast | Channeled pet HoT
- 6991 | Feed Pet | 10 | pet-cmd | self-cast | Pet happiness
- 2641 | Dismiss Pet | 1 | pet-cmd | self-cast | Send pet away
- 883 | Call Pet | 10 | pet-cmd | self-cast | Summon active pet
- 1002 | Eyes of the Beast | 10 | pet-cmd | self-cast | Control pet POV; rare
- 1462 | Beast Lore | 18 | utility | enemy-cast | Inspect beast
- 19263 | Deterrence | 40 | utility | self-instant | Survival defensive (parry/dodge buff)
- 781 | Disengage | 8 | utility | enemy-instant | Aggro reset (TBC version is jump-back at higher levels via talent)
- 19386 | Wyvern Sting | 40 | sting | enemy-instant | Survival sleep
- 19577 | Intimidation | 30 | cc | enemy-instant | BM 3s stun via pet
- 34490 | Silencing Shot | TBC L60+ | shot | enemy-instant | Marks; 3s silence; primary interrupt → `` ` `` slot
- 23989 | Readiness | 40 | utility | self-instant | Marks CD reset

## ASPECTS — all in OPie "HunterAspects" ring on M4 (NOT bar slots)

Aspects are toggled often but the choice is contextual; ring is ideal.

- 13165 | Aspect of the Hawk | 10 | aspect | self-instant | RAP buff; default combat
- 5118 | Aspect of the Cheetah | 20 | aspect | self-instant | +30% speed OOC; daze on hit
- 13159 | Aspect of the Pack | 30 | aspect | self-instant | Party speed; daze on hit
- 13161 | Aspect of the Beast | 40 | aspect | self-instant | Untrackable + pet bonus
- 13163 | Aspect of the Monkey | 14 | aspect | self-instant | +Dodge defensive
- 20043 | Aspect of the Wild | 36 | aspect | self-instant | +nature resist party
- 27045 | Aspect of the Viper | TBC L66+ | aspect | self-instant | Mana regen aspect

## STINGS — typically all on bar (rotation-active)

Stings are contextual and switched in combat — bar slots beat OPie for rotation pieces.

- See SHOTS / DAMAGE section above (Serpent, Scorpid, Viper, Wyvern)
- 3034 | Viper Sting | 22 | sting | enemy-instant | Mana drain; PvP/casters

## TRAPS — bar slots (combat-active reactive)

Traps need fast access in combat, especially Freezing Trap for adds. Keep on bar; consider an OPie "HunterTraps" ring as alternative for non-MM.

## TRACKING — OPie "HunterTracking" ring (sub-ring within M5)

All tracking modes are mutually exclusive toggles, slow to swap, OOC utility — perfect for OPie.

- 1494 | Track Beasts | 10 | tracking | self-instant
- 19883 | Track Humanoids | 20 | tracking | self-instant
- 19884 | Track Undead | 24 | tracking | self-instant
- 19885 | Track Hidden | 30 | tracking | self-instant
- 19880 | Track Elementals | 36 | tracking | self-instant
- 19878 | Track Demons | 40 | tracking | self-instant
- 19882 | Track Giants | 44 | tracking | self-instant
- 19879 | Track Dragonkin | 50 | tracking | self-instant

## PET MANAGEMENT — OPie "HunterPet" ring on M5

Pet OOC commands are all slow utility, OPie-suited.

- 136 | Mend Pet | 4 | pet-cmd | self-cast
- 982 | Revive Pet | 10 | pet-cmd | self-cast
- 6991 | Feed Pet | 10 | pet-cmd | self-cast
- 2641 | Dismiss Pet | 1 | pet-cmd | self-cast
- 883 | Call Pet | 10 | pet-cmd | self-cast
- 1515 | Tame Beast | 10 | utility | enemy-cast | OOC tame; rare ring slot

Mend Pet is borderline — combat use too (BM keeps pet alive). Could double-place: bar (Alt-G self-cast) + ring.

## BUFFS

- 1130 | Hunter's Mark | 6 | buff | enemy-instant | Always-on tracking debuff; bar slot (key 5 or similar)
- 34477 | Misdirection | TBC L70+ | utility | friend-instant | Threat redirect; mouseover-help; raid-only really
- 34074 | Aspect of the Viper | TBC | aspect | self-instant | (also in aspect ring)

## RACIALS

### Dwarf (Alliance)
- 20594 | Stoneform | racial | utility | self-instant | -bleed/poison/disease + armor; defensive
- 2481 | Find Treasure | racial | tracking | self-instant | Tracking; could go in tracking ring
- 20595 | Gun Specialization | passive | passive | self
- 20596 | Frost Resistance | passive | passive | self

### Night Elf (Alliance)
- 20580 | Shadowmeld | racial | utility | self-instant | Drop combat; prep ambush
- 20583 | Quickness | passive | passive | self
- 20582 | Wisp Spirit | passive | passive | self
- 20585 | Touch of Elune | passive | passive | self
- 20581 | Nature Resistance | passive | passive | self

### Draenei (Alliance, TBC)
- 28880 | Gift of the Naaru | racial | heal | friend-cast | 15s HoT mouseover-friendly
- 6562 | Heroic Presence | passive | passive | self
- 20583 | Shadow Resistance | passive | passive | self
- 28875 | Gemcutting | passive | profession | self

### Orc (Horde)
- 20572 | Blood Fury | racial | buff | self-instant | AP burst
- 20573 | Hardiness | passive | passive | self
- 20574 | Axe Specialization | passive | passive | self
- 20575 | Command | passive | passive | self | +5% pet damage (Hunter-relevant!)

### Tauren (Horde)
- 20549 | War Stomp | racial | cc | enemy-instant | 2s AOE stun
- 20550 | Endurance | passive | passive | self
- 20552 | Cultivation | passive | profession | self
- 20551 | Nature Resistance | passive | passive | self

### Troll (Horde)
- 26297 | Berserking | racial | buff | self-instant | Haste burst
- 20557 | Da Voodoo Shuffle | passive | passive | self
- 20558 | Bow Specialization | passive | passive | self | +1% crit w/ bows (Hunter-relevant!)
- 20557 | Beast Slaying | passive | passive | self | +5% damage vs beasts (Hunter-relevant!)
- 20555 | Regeneration | passive | passive | self

### Blood Elf (Horde, TBC)
- 28734 | Mana Tap | racial | utility | enemy-instant | Charge stack; pre-Arcane Torrent
- 28730 | Arcane Torrent | racial | utility | self-instant | AOE silence + mana
- 28877 | Magic Resistance | passive | passive | self
- 28735 | Enchanting | passive | profession | self

## TALENT PASSIVES — IGNORE

Endurance Training, Improved Aspect of the Hawk, Endurance Training, Pathfinding, Aspect Mastery, Improved Aspect of the Monkey, Lethal Shots, Mortal Shots, Efficiency, Hawk Eye, Improved Concussive Shot, Improved Hunter's Mark, Trap Mastery, Survivalist, Deflection, Entrapment, Savage Strikes, Improved Wing Clip, Surefooted, Improved Mend Pet, Ferocity, Spirit Bond, Bestial Discipline, Animal Handler, Frenzy, Beast Mastery, Catlike Reflexes, Improved Aspect of the Wild, Master Tactician, Survival Instincts

## PROFESSIONS — IGNORE

First Aid, Cooking, Basic Campfire, Mining, Smelting, Herbalism, Skinning, Fishing, Enchanting, Disenchant, Alchemy, Tailoring, Leatherworking, Engineering, Blacksmithing, Jewelcrafting

---

## Layout decision rules (for the skill)

When generating HunterSetup.lua's LAYOUT, apply these in order:

1. **All aspects → OPie "HunterAspects" ring on M4 (NOT bar slots).** Even Aspect of the Hawk — toggling via ring keeps the bar uncluttered. (`AddDefaultRing("HunterAspects", { ...slices..., name="Aspects", hotkey="BUTTON4", ... })`)
2. **All tracking modes → OPie "HunterTracking" ring** (could nest under M5 or share a "HunterUtility" ring with pet commands).
3. **OOC pet commands → OPie "HunterPet" ring on M5** (Call/Dismiss/Revive/Feed). Mend Pet stays both ring + bar (combat use too).
4. **Auto Shot → `` ` `` (Bar 1 button 1)** as the always-on anchor, no macro template.
5. **Primary interrupt → if Marks/talented, Silencing Shot replaces `` ` ``** (move Auto Shot to button 2). Otherwise no interrupt slot — Hunter has no baseline interrupt pre-talent.
6. **Primary opener (Serpent Sting) → Bar 1 button 2 with `startattack` template.** This issues `/startattack` so auto-attack starts immediately.
7. **Filler shots → Bar 1 buttons 3-6** (Arcane, Concussive, Aimed if Marks, Multi-Shot, Steady Shot if TBC).
8. **Hunter's Mark → bar slot or OPie?** Always-on debuff applied pre-pull → OPie pre-pull ring is fine; or bar key 5.
9. **Heals → Hunter has no heals.** Alt-QERT row mostly empty for Hunter; could reuse for utility (Disengage, Deterrence).
10. **Stings → bar slots (rotation-active).** Serpent/Scorpid/Viper on numrow or Alt-numrow.
11. **Traps → bar slots (combat-reactive).** Freezing Trap deserves a prime slot (ZXCVB row probably). Group all 4 traps together for muscle memory.
12. **Pet attack/follow/stay → ElvUI's PetActionBar (built-in).** Don't duplicate on main bars. Pet ability bar (PetBar1-10) auto-managed.
13. **Bestial Wrath / Intimidation / Readiness / Kill Command → Alt-numrow CDs** (Bar 4 buttons 4-6).
14. **Defensives (Deterrence, Disengage, Feign Death) → Alt-ZXCVB row.** `self-cast` template for Deterrence/Feign.
15. **Mongoose Bite / Counterattack / Wing Clip / Raptor Strike → Bar 1 if Survival melee, otherwise IGNORE** (rare in ranged play).
16. **Aspect of the Viper (mana) → OPie ring + maybe Alt-bar if frequent toggle.**
17. **IGNORE all passives, race actives, professions, aspects-in-OPie, tracking-in-OPie, pet-OOC-in-OPie.**
18. **STOP and ask user about spec** — Marks vs Survival vs BM significantly changes which spells get prime slots (Aimed Shot vs Mongoose Bite vs Bestial Wrath).

## Hunter-specific gotchas for the skill

- **Pet bar**: Hunter has Blizzard's PetActionBar separate from main bars. Don't try to place pet abilities (Bite, Claw, Growl, Cower, etc.) — they auto-populate the pet bar.
- **Auto Shot anchoring**: Unlike caster classes, Hunter's `` ` `` slot is Auto Shot itself, not a damage instant. The `startattack` template on Serpent Sting handles the melee fallback.
- **Spec divergence is bigger than other classes**: Marks (Aimed Shot, Silencing Shot, Readiness) vs Survival (Mongoose, Counterattack, Wyvern, Deterrence, melee weave) vs BM (Bestial Wrath, Intimidation, Kill Command, pet-focused). The skill should ask the user which spec before generating.
- **No baseline interrupt**: Pre-Silencing Shot (Marks talent) Hunter has no spell interrupt. Don't auto-fill `` ` `` with anything but Auto Shot.
- **Misdirection (TBC L70)**: Raid utility, not solo-relevant. Goes in IGNORE for leveling builds, bar slot for raid builds.
