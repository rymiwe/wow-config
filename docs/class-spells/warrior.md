# Warrior spell roster — TBC Classic / Anniversary (Interface 20505)

Canonical spell reference for the `wow-class-setup` skill. Same schema as `shaman.md`.

**Schema per entry:** `<spell_id> | <name> | <level_learned> | <category> | <targeting> | <notes>`

Categories: `damage`, `stance`, `shout`, `defensive`, `utility`, `cc`, `racial-active`, `passive`, `profession`

Targeting: `self`, `enemy`, `friend`, `instant`, `cast-time`

---

## DAMAGE — combat-active

- 78 | Heroic Strike | 1 | damage | enemy-instant | Next-melee-swing damage; always-ready primary spam
- 845 | Cleave | 20 | damage | enemy-instant | Next-swing AOE
- 1715 | Hamstring | 8 | damage | enemy-instant | Snare; any stance
- 7405 | Sunder Armor | 10 | damage | enemy-instant | Threat + armor debuff stack; any stance
- 772 | Rend | 4 | damage | enemy-instant | Bleed DoT; Battle/Defensive
- 6552 | Pummel | 38 | damage | enemy-instant | Berserker stance interrupt
- 5308 | Execute | 24 | damage | enemy-instant | Sub-20% finisher; any stance
- 1464 | Slam | 30 | damage | enemy-cast | Cast-time hard hit
- 1680 | Whirlwind | 36 | damage | enemy-instant | Berserker stance AOE
- 6343 | Thunder Clap | 6 | damage | enemy-instant | Battle stance AOE (any stance with talent)
- 12294 | Mortal Strike | 30 Arms | damage | enemy-instant | Arms talent; any stance
- 23881 | Bloodthirst | 30 Fury | damage | enemy-instant | Fury talent; any stance
- 23922 | Shield Slam | 40 Prot | damage | enemy-instant | Prot talent; requires shield
- 20243 | Devastate | TBC L66 Prot | damage | enemy-instant | Prot talent; replaces Sunder pattern
- 100 | Charge | 4 | utility | enemy-instant | Battle stance gap-closer; generates rage
- 20252 | Intercept | 30 | utility | enemy-instant | Berserker stance gap-closer + stun

## STANCES — toggleable; both bar slots AND OPie M5 ring

- 2457 | Battle Stance | 1 | stance | self-instant | Default; +rage gen, Charge/Overpower/Retaliation
- 71 | Defensive Stance | 10 | stance | self-instant | -10% dmg taken; +threat; Shield Wall/Last Stand
- 2458 | Berserker Stance | 30 | stance | self-instant | +crit, +damage taken; Whirlwind/Intercept/Pummel/Berserker Rage

## SHOUTS — party buffs / AOE; OPie "WarriorShouts" ring on M4

- 6673 | Battle Shout | 1 | shout | self-instant | +AP party buff (2min)
- 469 | Commanding Shout | 60 (TBC) | shout | self-instant | +HP party buff (TBC)
- 1160 | Demoralizing Shout | 14 | shout | self-instant | -AP enemy debuff AOE
- 1161 | Challenging Shout | 20 | shout | self-instant | AOE taunt; Defensive/Battle
- 5246 | Intimidating Shout | 22 | shout | self-instant | AOE fear (1 nearby fears, others stunned)

## STANCE-LOCKED COMBAT

### Battle Stance
- 7384 | Overpower | 14 | damage | enemy-instant | Reactive after enemy dodge
- 6572 | Revenge | 14 | damage | enemy-instant | Defensive stance reactive (after dodge/parry/block) — actually Defensive
- 5246 | Intimidating Shout | 22 | utility | self-instant | (cross-stance per TBC)
- 20230 | Retaliation | 30 | defensive | self-instant | Battle CD; reflects melee
- 1604 | Dazed | passive | passive | self
- 6554 | Mocking Blow | 26 | utility | enemy-instant | Battle taunt + damage

### Defensive Stance
- 6572 | Revenge | 14 | damage | enemy-instant | Reactive
- 871 | Shield Wall | 16 | defensive | self-instant | -75% dmg 10s; Defensive only
- 12975 | Last Stand | 40 Prot | defensive | self-instant | +30% HP 20s; Prot talent
- 676 | Disarm | 24 | utility | enemy-instant | -10s weapon disarm; Defensive
- 2565 | Shield Block | 16 | defensive | self-instant | +75 block 5s; Defensive
- 72 | Shield Bash | 16 | utility | enemy-instant | Interrupt + minor dmg; Battle/Defensive
- 23920 | Spell Reflection | TBC L20 | defensive | self-instant | Reflects next spell

### Berserker Stance
- 18499 | Berserker Rage | 32 | utility | self-instant | Fear/incapacitate immune; +rage on hit
- 1719 | Recklessness | 50 | defensive | self-instant | +crit, +damage taken; Berserker CD

## OOC / TRAVEL

- 12292 | Death Wish | 30 Fury | defensive | self-instant | +20% damage, -fear immune; Fury CD
- 12328 | Sweeping Strikes | 30 Arms | utility | self-instant | Next 5 attacks hit add target; Arms CD
- 3411 | Intervene | TBC L66 | utility | friend-instant | Damage redirect; Prot baseline TBC; mouseover-help
- 18499 | Berserker Rage | 32 | utility | self-instant | Listed in Berserker section

## RACIALS

Warrior is available to ALL races. See `paladin.md` / `druid.md` for race-specific lists. All race actives go in IGNORE for manual placement (War Stomp, Blood Fury, Berserking, Stoneform, Shadowmeld, Gift of the Naaru, Will of the Forsaken, Cannibalize, Escape Artist, Mana Tap, Arcane Torrent).

## TALENT PASSIVES — IGNORE

Improved Heroic Strike, Improved Rend, Deflection, Improved Charge, Tactical Mastery, Iron Will, Anger Management, Improved Thunder Clap, Improved Overpower, Two-Handed Weapon Specialization, Impale, Sword/Mace/Pole/Axe Specialization, Deep Wounds, Mortal Strike (active), Cruelty, Improved Demoralizing Shout, Unbridled Wrath, Enrage, Improved Cleave, Piercing Howl, Blood Craze, Sweeping Strikes (active), Improved Hamstring, Improved Battle Shout, Dual Wield Specialization, Improved Execute, Flurry, Bloodthirst (active), Improved Shield Block, Improved Sunder Armor, Improved Disarm, Improved Bloodrage, Improved Shield Wall, Toughness, Iron Will, Last Stand (active), Concussion Blow, Improved Revenge, Defiance, Improved Taunt, Anticipation, One-Handed Weapon Specialization, Shield Specialization, Improved Spell Reflection, Vitality, Devastate (active), Focused Rage

## PROFESSIONS — IGNORE

First Aid, Cooking, Basic Campfire, Mining, Smelting, Herbalism, Skinning, Fishing, Enchanting, Disenchant, Alchemy, Tailoring, Leatherworking, Engineering, Blacksmithing, Jewelcrafting

---

## Layout decision rules (Warrior-specific overrides on top of `class_setup_pattern.md`)

Warrior has 3 stances (like Druid forms, but most abilities work cross-stance). Spec is Arms/Fury/Prot — generalist Arms-leaning layout works for all. Untrained spells silently skip via SetupCore.

When generating WarriorSetup.lua's LAYOUT:

1. **All Shouts → OPie "WarriorShouts" ring on M4** — pre-pull party buffs + AOE shouts.
2. **All Stances → OPie "WarriorStances" ring on M5** — duplicated with bar F/G/Z slots intentionally for player input flexibility.
3. **Heroic Strike → key `` ` ``** — primary always-ready next-swing damage; raw, no template.
4. **Mortal Strike → key 1 with `startattack`** — Arms opener (Bloodthirst takes the slot for Fury via untrained-skip).
5. **Bloodthirst → key 2** — Fury filler; both untrained until L30 talent.
6. **Other damage → numrow 3-5**: Execute (3), Cleave (4), Slam (5).
7. **Charge → Q with `startattack`** — Battle stance gap-closer + auto-attack engage.
8. **Overpower → E** — Battle stance reactive.
9. **Hamstring → R, Rend → T** — utility row.
10. **Stances on F/G/Z**: Battle (F), Defensive (G), Berserker (Z) — adjacency for muscle memory.
11. **Sunder Armor → X, Disarm → V, Thunder Clap → B** — Bar 3 utility row.
12. **Alt-numrow CDs**: Recklessness (Alt-1), Death Wish (Alt-2 Fury), Sweeping Strikes (Alt-3 Arms), Retaliation (Alt-4 Battle), Shield Slam (Alt-5 Prot).
13. **Alt-Q/E/R/T = Berserker stance specials + utility**: Intercept (Alt-Q gap-closer), Pummel (Alt-E interrupt), Berserker Rage (Alt-R fear-break), Intervene (Alt-T friend redirect, mouseover-help).
14. **Alt-bottom = defensives**: Shield Bash (Alt-F interrupt), Shield Block (Alt-G), Shield Wall (Alt-Z, self-cast), Last Stand (Alt-X Prot, self-cast), Spell Reflection (Alt-C, self-cast), Demoralizing Shout (Alt-V), Challenging Shout (Alt-B).
15. **No Attack slot** — Heroic Strike + right-click cover.
16. **Stance-locked spells** — placed on shared bars (not stance pages). Pressing wrong-stance ability errors silently; that's acceptable training feedback for players.

## Spec notes for the skill

- **Arms**: Mortal Strike spam, Slam, Sweeping Strikes CD. 2H weapon. Battle stance default.
- **Fury**: Bloodthirst, dual-wield fast attacks, Death Wish CD, Recklessness. Often Berserker stance.
- **Prot**: Shield + 1H. Shield Slam, Devastate (TBC L66), Last Stand, Shield Wall, Spell Reflection. Defensive stance default.

For generalist leveling, Arms is most popular — favor Mortal Strike on key 1. Fury/Prot specifics (Bloodthirst, Shield Slam, Devastate) silently skip if untrained.
