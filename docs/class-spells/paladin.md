# Paladin spell roster — TBC Classic / Anniversary (Interface 20505)

Canonical spell reference for the `wow-class-setup` skill. Same schema as `shaman.md`.

**Schema per entry:** `<spell_id> | <name> | <level_learned> | <category> | <targeting> | <notes>`

Categories: `damage`, `heal`, `seal`, `judgment`, `blessing`, `aura`, `hand`, `defensive`, `utility`, `cc`, `dispel`, `racial-active`, `passive`, `profession`

Targeting: `self`, `friend`, `enemy`, `instant`, `cast-time`, `channeled`

---

## DAMAGE — combat-active

- 35395 | Crusader Strike | 20 | damage | enemy-instant | Ret melee filler (TBC core)
- 879 | Exorcism | 20 | damage | enemy-cast | vs Undead/Demon only
- 2812 | Holy Wrath | 30 | damage | enemy-cast | TBC AOE vs Undead/Demon
- 24275 | Hammer of Wrath | 44 | damage | enemy-cast | Ret execute (sub-20% HP)
- 26573 | Consecration | 20 | damage | ground-instant | AOE damage at feet
- 31935 | Avenger's Shield | 40 Prot | damage | enemy-instant | Throws shield (Prot only)

## SEALS — combat-active toggles (mutually exclusive on self)

Seals are 30s self-buffs; one active at a time. Bar slots beat OPie since players cycle in combat.

- 21084 | Seal of Righteousness | 1 | seal | self-instant | Default melee damage proc
- 20154 | Seal of Crusader | 12 | seal | self-instant | -armor on judge; pre-burst opener
- 20375 | Seal of Command | 20 | seal | self-instant | Ret-leaning hard-hitter
- 20165 | Seal of Light | 30 | seal | self-instant | Heal proc on swing
- 20166 | Seal of Wisdom | 38 | seal | self-instant | Mana proc on swing
- 20164 | Seal of Justice | 22 | seal | self-instant | Snare/stun proc; PvP / runner CC
- 31892 | Seal of Blood | TBC L66 BE/Horde | seal | self-instant | Horde-only Paladin seal
- 31801 | Seal of Vengeance | TBC L66 Alliance | seal | self-instant | Alliance-only counterpart

## JUDGMENT — single spell that judges active seal

- 20271 | Judgement | 4 | judgment | enemy-instant | One spell, judges active seal — bar prime slot

## HEALS — friend-targeted, mouseover-friendly

All heals get `mouseover-help`. Live on Alt-cluster QERT row.

- 635 | Holy Light | 1 | heal | friend-cast | Big slow heal
- 19750 | Flash of Light | 20 | heal | friend-cast | Small fast heal
- 33076 | Prayer of Mending | TBC | heal | friend-instant | NOT Paladin (Priest)
- 20473 | Holy Shock | 40 Holy | heal | friend-instant | Holy talent (also damage vs enemy)

## BLESSINGS — friend-targeted; OPie "PaladinBlessings" ring on M4

Blessings are 5min/15min sustained buffs; pre-pull or on-revive. Ring is ideal — too many for bar slots.

- 19740 | Blessing of Might | 4 | blessing | friend-cast | Attack power
- 19742 | Blessing of Wisdom | 14 | blessing | friend-cast | Mana regen
- 19838 | Blessing of Kings | 20 (TBC baseline) | blessing | friend-cast | +10% all stats
- 20217 | Blessing of Kings (TBC) | 20 | blessing | friend-cast | Same — TBC moved baseline
- 20911 | Blessing of Sanctuary | 30 Prot | blessing | friend-cast | Damage reduction; Prot
- 1038 | Blessing of Salvation | 26 | blessing | friend-cast | -threat
- 19977 | Blessing of Light | 40 Holy | blessing | friend-cast | Holy: +heal received
- 25898 | Greater Blessing of Kings | TBC L60+ | blessing | raid-cast | Group blessings
- 25890 | Greater Blessing of Light | TBC | blessing | raid-cast
- 25894 | Greater Blessing of Might | TBC | blessing | raid-cast
- 25918 | Greater Blessing of Sanctuary | TBC | blessing | raid-cast
- 25895 | Greater Blessing of Salvation | TBC | blessing | raid-cast
- 25918 | Greater Blessing of Wisdom | TBC | blessing | raid-cast

## AURAS — self-only mutually-exclusive toggles; OPie "PaladinAuras" ring on M5

Auras are passive party buffs from active Paladin. Switched contextually (resistances). Ring perfect.

- 465 | Devotion Aura | 1 | aura | self-instant | +armor
- 7294 | Retribution Aura | 16 | aura | self-instant | Damage on melee hit (Ret default)
- 19746 | Concentration Aura | 22 | aura | self-instant | -pushback for casters
- 19891 | Shadow Resistance Aura | 30 | aura | self-instant
- 19888 | Frost Resistance Aura | 36 | aura | self-instant
- 19899 | Crusader Aura | 32 | aura | self-instant | +mount speed
- 19876 | Fire Resistance Aura | 42 | aura | self-instant
- 20218 | Sanctity Aura | 30 Ret | aura | self-instant | +holy damage (Ret talent — TBC reworked to passive)

## HANDS — friend-targeted utility; mouseover-help

In TBC these are still called "Blessings" mechanically (same buff slot) — `Blessing of Freedom`, `Blessing of Protection`, `Blessing of Sacrifice`. They're tactical, in-combat, NOT pre-pull. Bar slots over OPie.

- 1044 | Blessing of Freedom | 18 | hand | friend-instant | Snare break; mouseover-help
- 1022 | Blessing of Protection | 10 | hand | friend-instant | Physical immunity (BoP); mouseover-help
- 6940 | Blessing of Sacrifice | 30 Prot/Holy | hand | friend-instant | Damage redirect to caster
- 64205 | Divine Sacrifice | NOT TBC | — | — | WotLK addition; do NOT include

## DISPELS / CLEANSES

- 4987 | Cleanse | 42 | dispel | friend-instant | Disease + Poison + Magic (Holy talent extends magic); mouseover-help
- 1152 | Purify | 8 | dispel | friend-instant | Disease + Poison only; mouseover-help (precursor to Cleanse)

## DEFENSIVES / EMERGENCY

- 642 | Divine Shield | 18 | defensive | self-instant | 8s full immunity; self-cast
- 498 | Divine Protection | 6 | defensive | self-instant | 50% damage reduction (TBC); self-cast
- 633 | Lay on Hands | 10 | heal | friend-instant | Full HP, 60min CD; mouseover-help (cast on tank or self)
- 19752 | Divine Intervention | 30 | utility | friend-instant | Sacrifice self for friend invuln + combat-drop; mouseover-help

## CC / UTILITY

- 853 | Hammer of Justice | 8 | cc | enemy-instant | Stun 6s; mouseover-harm acceptable but usually current target
- 20066 | Repentance | 40 Ret | cc | enemy-cast | 6s incapacitate; mouseover-harm (or focus-mouseover-harm if marked)
- 7328 | Redemption | 12 | utility | friend-cast | Out-of-combat resurrection; mouseover-help
- 31884 | Avenging Wrath | 40 Ret | utility | self-instant | +30% damage/heal CD; self-cast
- 31821 | Aura Mastery | 40 Holy | utility | self-instant | Holy talent; aura buff
- 31842 | Divine Illumination | 40 Holy | utility | self-instant | -50% mana on heals CD

## RACIALS

### Human (Alliance)
- 20598 | The Human Spirit | passive | passive | self
- 20597 | Sword Specialization | passive | passive | self
- 20864 | Mace Specialization | passive | passive | self
- 20599 | Diplomacy | passive | passive | self
- 20600 | Perception | racial-active | utility | self-instant | Old vanilla; little use TBC

### Dwarf (Alliance)
- 20594 | Stoneform | racial-active | defensive | self-instant | -bleed/poison/disease
- 2481 | Find Treasure | racial-active | tracking | self-instant
- 20595 | Gun Specialization | passive | passive | self
- 20596 | Frost Resistance | passive | passive | self

### Draenei (Alliance, TBC)
- 28880 | Gift of the Naaru | racial-active | heal | friend-cast | 15s HoT mouseover-friendly
- 6562 | Heroic Presence | passive | passive | self
- 20583 | Shadow Resistance | passive | passive | self
- 28875 | Gemcutting | passive | profession | self

### Blood Elf (Horde, TBC) — ONLY Horde Paladin race
- 28734 | Mana Tap | racial-active | utility | enemy-instant
- 28730 | Arcane Torrent | racial-active | utility | self-instant | AOE silence + mana
- 28877 | Magic Resistance | passive | passive | self
- 28735 | Enchanting | passive | profession | self

## TALENT PASSIVES — IGNORE

Divine Strength, Divine Intellect, Healing Light, Improved Lay on Hands, Improved Blessing of Wisdom, Aura Mastery (active actually), Spell Warding, Anticipation, Improved Righteous Fury, Toughness, Blessing of Kings (talent in vanilla, baseline TBC), Reckoning, Improved Hammer of Justice, Pursuit of Justice, Vindication, Improved Seal of the Crusader, Conviction, Two-Handed Weapon Specialization, Sanctity Aura (Ret talent — toggle in TBC), Vengeance, Sanctified Judgement, Crusade, Precision

## PROFESSIONS — IGNORE

First Aid, Cooking, Basic Campfire, Mining, Smelting, Herbalism, Skinning, Fishing, Enchanting, Disenchant, Alchemy, Tailoring, Leatherworking, Engineering, Blacksmithing, Jewelcrafting

---

## Layout decision rules (Paladin-specific overrides on top of `class_setup_pattern.md`)

Paladin has 3 specs (Holy/Prot/Ret) but a generalist Ret-leaning leveling layout works for all. SetupCore silently skips untrained spells, so Holy-only spells (Holy Shock, Aura Mastery) stay in LAYOUT and just don't appear if untrained.

When generating PaladinSetup.lua's LAYOUT, apply these rules in order:

1. **All Blessings (lesser + greater) → OPie "PaladinBlessings" ring on M4.** NOT bar slots — too many; ring suits the per-target re-application workflow. Mouseover-friendly within ring.
2. **All Auras → OPie "PaladinAuras" ring on M5.** Mutually exclusive toggles; perfect for ring.
3. **Hands (BoF, BoP, BoS) → bar slots on Alt-cluster** with `mouseover-help`. These are tactical in-combat, not pre-pull.
4. **Judgement → key `` ` `` (Bar 1 button 1)** raw — primary always-ready combat button (judges active seal).
5. **Crusader Strike → key 1 (Bar 1 button 2) with `startattack` template.** Ret melee filler that engages auto-attack.
6. **Other damage → numrow 2-5**: Hammer of Wrath (execute), Exorcism (vs U/D), Holy Wrath (TBC AOE vs U/D), Consecration.
7. **Heals → Alt-QERT row** with `mouseover-help`: Holy Light (Alt-Q), Flash of Light (Alt-E), Holy Shock (Alt-R, Holy talent), Lay on Hands (Alt-T).
8. **Seals on F/G** — primary seal (Righteousness) on F, secondary (Crusader for openers, or Wisdom/Light in solo) on G. Other seals: leave for /castsequence or future OPie ring.
9. **ZXCVB row**: Hammer of Justice (Z, stun), Divine Shield (X, self-cast), [empty] (C — never `Attack`), Divine Protection (V, self-cast), Repentance (B, mouseover-harm, Ret talent).
10. **Alt-numrow**: Avenging Wrath (Alt-1, Ret CD, self-cast), Avenger's Shield (Alt-2, Prot ranged), then defensives/utilities.
11. **Alt-Hands cluster**: Cleanse (Alt-F, mouseover-help), Blessing of Freedom (Alt-G, mouseover-help). Continue: Blessing of Protection (Alt-Z), Blessing of Sacrifice (Alt-X), Divine Intervention (Alt-C, mouseover-help).
12. **Redemption (rez) → Alt-V or Alt-B with mouseover-help** — out-of-combat utility, lower-priority Alt slot.
13. **No Attack slot** — Judgement always available, plus right-click. Per `auto_attack_no_slot.md`.
14. **IGNORE**: all passives, all blessings (in OPie), all auras (in OPie), race actives (manual), professions, WotLK-only spells (Divine Sacrifice, Beacon of Light, etc.).

## Spec notes for the skill

- **Ret**: Crusader Strike spam, Judgement on CD, Hammer of Wrath sub-20%, Exorcism vs U/D. Avenging Wrath CD. Sanctity Aura. Repentance CC.
- **Prot**: Avenger's Shield (TBC L40 talent), Consecration on CD, Holy Shield (passive in TBC? talent), Blessing of Sanctuary self-cast, threat-leaning rotation.
- **Holy**: Flash of Light spam, Holy Light for big heals, Holy Shock instant burst, Cleanse, Holy Light + Beacon of Light is WotLK only — NOT for TBC.

For the generalist layout, lean Ret since it's the most popular leveling spec. Holy-spec overlaps because heals are universal. Prot's Avenger's Shield gets a slot in case the friend goes Prot. Keep it broad.
