# Shaman spell roster — TBC Classic / Anniversary (Interface 20505)

Canonical spell reference for the `wow-class-setup` skill. Format is human-readable but structured enough that Claude can scan and apply principles for layout decisions.

**Schema per entry:** `<spell_id> | <name> | <level_learned> | <category> | <targeting> | <notes>`

Categories: `damage`, `heal`, `buff`, `utility`, `dispel`, `cc`, `totem`, `weapon-enchant`, `racial-active`, `passive`, `profession`

Targeting: `self`, `friend`, `enemy`, `ground` (totem placement), `party`, `raid`, `instant`, `cast-time`

---

## DAMAGE — combat-active, current-target

These typically go on Bar 1 number row (` 1 2 3 4 5). Primary opener gets `startattack` template. Interrupt-purpose spells go on `` ` ``.

- 8042 | Earth Shock | 4 | damage | enemy-instant | Primary interrupt; 6s shared CD with all shocks
- 8050 | Flame Shock | 10 | damage | enemy-instant | DoT 12s; ideal opener (use `startattack` template)
- 8056 | Frost Shock | 12 | damage | enemy-instant | Slows; kiting utility; shock CD
- 403 | Lightning Bolt | 1 | damage | enemy-cast | Main caster nuke; 3s cast (faster ranks); ALT cluster (Alt-1)
- 421 | Chain Lightning | 32 | damage | enemy-cast | AOE jumping; Elemental focus; ALT cluster (Alt-2)

## HEALS — friend-targeted, mouseover-friendly

All heals get `mouseover-help` template. Live on alt-cluster QERT row (Alt-Q/E/R/T) so they're always visible without breaking enemy target.

- 331 | Healing Wave | 6 | heal | friend-cast | Big heal; primary go-to
- 8004 | Lesser Healing Wave | 20 | heal | friend-cast | Faster, smaller; mana-efficient burst
- 1064 | Chain Heal | 40 | heal | friend-cast | AOE jumping heal (Resto)
- 2008 | Ancestral Spirit | 12 | heal | friend-cast | Out-of-combat resurrection

## BUFFS / SHIELDS — pre-pull or sustained

- 974 | Earth Shield | 60 | buff | friend-cast | TBC L60+; Resto signature; lasts 10min
- 324 | Lightning Shield | 8 | buff | self-instant | 3 charges; refresh after they expire
- 33736 | Water Shield | 20 | buff | self-instant | Resto-leaning; mana on hit
- 8232 | Windfury Weapon | 30 | weapon-enchant | self-instant | OPie ring (Weapon Enchants on M5)
- 8024 | Flametongue Weapon | 10 | weapon-enchant | self-instant | OPie ring
- 8033 | Frostbrand Weapon | 20 | weapon-enchant | self-instant | OPie ring
- 8017 | Rockbiter Weapon | 1 | weapon-enchant | self-instant | OPie ring
- 36936 | Totemic Call | TBC | utility | self-instant | Recall all totems

## TOTEMS — all handled by OPie "Totems" ring on M4 (NOT action bar)

The ring registration in ShamanSetup.lua handles these. They never appear on action bars under the OPie-first design.

### Earth totems
- 8071 | Stoneskin Totem | 4 | totem | ground | Armor buff; pre-pull
- 8075 | Strength of Earth Totem | 4 | totem | ground | STR/AGI buff; pre-pull
- 5730 | Stoneclaw Totem | 8 | totem | ground | Single taunt-pull
- 2484 | Earthbind Totem | 10 | totem | ground | AOE root; reactive

### Fire totems
- 3599 | Searing Totem | 10 | totem | ground | Auto-attacks nearest enemy
- 1535 | Fire Nova Totem | 14 | totem | ground | AOE damage explosion
- 8190 | Magma Totem | 40 | totem | ground | Persistent AOE
- 8227 | Flametongue Totem | 30 | totem | ground | Spell power buff (Resto/Ele)

### Water totems
- 5394 | Healing Stream Totem | 20 | totem | ground | Passive heal-over-time aura
- 5675 | Mana Spring Totem | 26 | totem | ground | Passive mana regen aura
- 16190 | Mana Tide Totem | 40 | totem | ground | Resto burst mana CD
- 8170 | Disease Cleansing Totem | 40 | totem | ground | Periodic disease removal
- 8166 | Poison Cleansing Totem | 20 | totem | ground | Periodic poison removal

### Air totems
- 8143 | Tremor Totem | 18 | totem | ground | Anti-fear/charm; reactive
- 8177 | Grounding Totem | 28 | totem | ground | Reflects 1 spell; reactive
- 8512 | Windfury Totem | 32 | totem | ground | Melee proc buff
- 8835 | Grace of Air Totem | 42 | totem | ground | AGI buff; stacks with SoE
- 3738 | Wrath of Air Totem | 64 | totem | ground | TBC Resto+; spell power buff
- 25908 | Tranquil Air Totem | TBC | totem | ground | Threat reduction

## DISPELS — friend or enemy

All get `mouseover-help` (friend-targeting) or `mouseover-harm` (enemy-targeting). Live on Alt-bottom row (Alt-Z/X/C/V/B).

- 2870 | Cure Disease | 18 | dispel | friend-instant | Single-target disease
- 526 | Cure Poison | 14 | dispel | friend-instant | Single-target poison
- 370 | Purge | 10 | dispel | enemy-instant | Removes 2 enemy magic buffs (`mouseover-harm`)

## UTILITY

- 2645 | Ghost Wolf | 16 | utility | self-instant | Travel form; 2/2 talent makes instant; goes on Z when instant
- 5394 | Reincarnation | 30 | utility | self-passive | Auto-rez on death; ignore (no slot needed)
- 556 | Astral Recall | 30 | utility | self-cast | 15min CD teleport home
- 6196 | Far Sight | 18 | utility | self-cast | Camera utility; rarely-used; bar 1 button 4

## RACIALS

### Draenei (Alliance)
- 28880 | Gift of the Naaru | racial | heal | friend-cast | 15s HoT; mouseover-friendly
- 6562 | Heroic Presence | passive | passive | self | +hit aura for party
- 28878 | Inspiring Presence | passive | passive | self | Old name; same as Heroic
- 20583 | Shadow Resistance | passive | passive | self | +shadow resist
- 28875 | Gemcutting | passive | profession | self | JC bonus

### Tauren (Horde)
- 20549 | War Stomp | racial | cc | enemy-instant | 2s AOE stun
- 20550 | Endurance | passive | passive | self | +5% base HP
- 20552 | Cultivation | passive | profession | self | Herbalism bonus
- 20551 | Nature Resistance | passive | passive | self | +nature resist

### Orc (Horde)
- 20572 | Blood Fury | racial | buff | self-instant | Attack power burst
- 20573 | Hardiness | passive | passive | self | +stun resist
- 20574 | Axe Specialization | passive | passive | self | +5 expertise w/ axes
- 20575 | Command | passive | passive | self | +5% pet damage

### Troll (Horde)
- 26297 | Berserking | racial | buff | self-instant | Haste burst
- 20557 | Da Voodoo Shuffle | passive | passive | self | -snare duration
- 20558 | Throwing Specialization | passive | passive | self | +1% crit w/ throwing
- 20557 | Bow Specialization | passive | passive | self | +1% crit w/ bows
- 20557 | Beast Slaying | passive | passive | self | +5% vs beasts
- 20555 | Regeneration | passive | passive | self | +HP regen

## TALENT PASSIVES — IGNORE (no slot)

- Convection, Concussion, Reverberation, Improved Lightning Bolt, Improved Earth Shock, Improved Fire Totems, Shamanistic Focus, Mental Quickness, Spirit Weapons, Improved Healing Wave, Tidal Mastery, Healing Focus, Tidal Focus, Improved Reincarnation, Mail Specialization, all weapon proficiencies (Two-Handed Axes, Maces, Daggers, Staves, Fist Weapons, Shield Block)

## PROFESSIONS — IGNORE

First Aid, Cooking, Basic Campfire, Mining, Smelting, Herbalism, Skinning, Fishing, Enchanting, Disenchant, Alchemy, Tailoring, Leatherworking, Engineering, Blacksmithing, Jewelcrafting, Inscription, Milling

---

## Layout decision rules (for the skill)

When generating ShamanSetup.lua's LAYOUT, apply these rules in order:

1. **All totems → OPie "ShamanTotems" ring on M4 (NOT bar slots).** Ring registration goes in `do ... end` block at file bottom.
2. **All weapon enchants → OPie "ShamanWeaponEnchants" ring on M5.** Same.
3. **Primary opener with DoT/instant → key 1 (Bar 1 button 2) with `startattack` template.** For Shaman, that's Flame Shock.
4. **Primary interrupt → `` ` `` (Bar 1 button 1) raw, no macro.** For Shaman, Earth Shock.
5. **Other shocks → numrow 2-5.** Frost Shock (2), Far Sight (3), Astral Recall (4 if trained).
6. **Heals (mouseover-help) → Alt-cluster QERT row (Bar 4 buttons 8/10/11/12).** Order by frequency: Healing Wave, Ancestral Spirit, Lesser Healing Wave, Chain Heal.
7. **Damage casts → Alt-numrow (Bar 4 buttons 2-6).** Lightning Bolt, Chain Lightning, Water Shield (toggleable).
8. **Buffs F/G → Bar 3 row 1 buttons 4/5.** Lightning Shield (F). G empty for Shaman after Gift of the Naaru → Alt-G.
9. **Bar 3 ZXCVB row** → Ghost Wolf (Z if instant via talent), Attack (C). Z/X/C/V/B mostly empty without weapon enchants.
10. **Alt-FG → utility (Ghost Wolf moved to Z, Gift of the Naaru on Alt-G with mouseover-help).**
11. **Alt-ZXCVB → travel + dispels.** Water Breathing (Alt-Z), Water Walking (Alt-X), Cure Disease (Alt-C, mouseover-help), Cure Poison (Alt-V, mouseover-help), Purge (Alt-B, mouseover-harm).
12. **Form/stance toggles** N/A for Shaman.
13. **IGNORE all passives, race actives, professions, totems-in-OPie, weapon-enchants-in-OPie.**
