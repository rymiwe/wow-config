# Druid spell roster — TBC Classic / Anniversary (Interface 20505)

Canonical spell reference for the `wow-class-setup` skill. Same schema as `shaman.md`.

**Schema per entry:** `<spell_id> | <name> | <level_learned> | <category> | <targeting> | <notes>`

Categories: `damage`, `heal`, `buff`, `utility`, `dispel`, `cc`, `form`, `form-locked`, `racial-active`, `passive`, `profession`

Targeting: `self`, `friend`, `enemy`, `instant`, `cast-time`, `channeled`

---

## DAMAGE — caster-form, Bar 1 number row

- 5176 | Wrath | 1 | damage | enemy-cast | Main caster filler; opener gets `startattack` template
- 8921 | Moonfire | 4 | damage | enemy-instant | DoT 12s; instant
- 2912 | Starfire | 20 | damage | enemy-cast | Slower, harder hit (Balance focus)
- 5570 | Insect Swarm | 20 | damage | enemy-cast | DoT (Balance talent)
- 16914 | Hurricane | 40 | damage | enemy-channeled | AOE (Balance talent)

## CC / DEBUFFS — friend or enemy

- 339 | Entangling Roots | 8 | cc | enemy-cast | Root; mouseover-harm
- 770 | Faerie Fire | 18 | utility | enemy-instant | Armor debuff (caster form); mouseover-harm
- 16979 | Faerie Fire (Feral) | 18 | utility | enemy-instant | Form-locked Bear/Cat version (no slot — form-page)
- 2637 | Hibernate | 18 | cc | enemy-cast | Beast/Dragonkin sleep; mouseover-harm
- 2908 | Soothe Animal | 8 | cc | enemy-cast | Calm enraged beast; mouseover-harm
- 16689 | Nature's Grasp | 8 | utility | self-instant | Root-on-attack proc; self-cast template

## HEALS — friend-targeted, mouseover-friendly

All heals get `mouseover-help` template. Live on alt-cluster QERT row.

- 5185 | Healing Touch | 1 | heal | friend-cast | Big slow heal
- 774 | Rejuvenation | 4 | heal | friend-instant | HoT 12s; mana-efficient
- 8936 | Regrowth | 12 | heal | friend-cast | Direct + HoT hybrid
- 33763 | Lifebloom | 64 | heal | friend-instant | TBC L64+; stacking HoT (Resto)
- 18562 | Swiftmend | 40 | heal | friend-instant | Consumes Rejuv/Regrowth for instant heal (Resto talent)
- 740 | Tranquility | 30 | heal | self-channeled | AOE party heal; channeled; `self-cast` template

## BUFFS — pre-pull or sustained

- 1126 | Mark of the Wild | 1 | buff | friend-cast | All-stat buff; mouseover-help OR OPie ring
- 21849 | Gift of the Wild | 50 | buff | raid-cast | Group MotW; OPie ring
- 467 | Thorns | 6 | buff | friend-cast | Reflective damage; mouseover-help OR OPie ring
- 22812 | Barkskin | 44 | utility | self-instant | Damage reduction; `self-cast`
- 16864 | Omen of Clarity | 30 | passive | self | Talent passive; IGNORE
- 17116 | Nature's Swiftness | 30 | utility | self-instant | Talent; instant cast next nature spell

## FORMS — keyboard-row toggles, with Druid safety templates

Bear/Cat use `druid-bear-safe` / `druid-cat-safe` (won't shift out of the OTHER combat form, which would destroy energy/rage). Travel/Aquatic/Flight don't need safety.

- 5487 | Bear Form | 10 | form | self-instant | `druid-bear-safe` template (Bar 3 button 8 = Z)
- 768 | Cat Form | 20 | form | self-instant | `druid-cat-safe` template (Bar 3 button 9 = X)
- 783 | Travel Form | 30 | form | self-instant | Bar 3 button 10 = C; also OPie Travel ring
- 1066 | Aquatic Form | 16 | form | self-instant | Bar 3 button 11 = V; also OPie Travel ring
- 33943 | Flight Form | 68 | form | self-instant | TBC L68+; OPie Travel ring
- 40120 | Swift Flight Form | 70 | form | self-instant | TBC epic; OPie Travel ring
- 24858 | Moonkin Form | 40 | form | self-instant | Balance talent
- 33891 | Tree of Life | 40 | form | self-instant | Resto talent
- 5215 | Prowl | 20 | utility | self-instant | Cat stealth toggle (Bar 3 button 12 = B)

## FORM-LOCKED COMBAT — IGNORE for skill, drag manually onto Bar 1 form pages

These cast only while in their form. Blizzard's `[bonusbar:N]` paging on Bar 1 swaps them in automatically. The skill must NOT place them via /setupbars.

### Bear (Bar 1 page when in Bear)
- 6807 | Maul | 10 | form-locked | enemy-instant | Next-melee-swing damage
- 779 | Swipe | 16 | form-locked | enemy-instant | AOE
- 5211 | Bash | 12 | form-locked | enemy-instant | Stun
- 99 | Demoralizing Roar | 10 | form-locked | enemy-instant | AOE attack-power debuff
- 6795 | Growl | 10 | form-locked | enemy-instant | Taunt
- 5209 | Challenging Roar | 20 | form-locked | enemy-instant | AOE taunt
- 22842 | Frenzied Regeneration | 36 | form-locked | self-instant | Bear self-heal
- 5229 | Enrage | 14 | form-locked | self-instant | Rage gen; self-cast template
- 33878 | Mangle (Bear) | 50 | form-locked | enemy-instant | Feral talent
- 33745 | Lacerate | 50 | form-locked | enemy-instant | Feral talent (TBC bleed)

### Cat (Bar 1 page when in Cat)
- 1082 | Claw | 1 | form-locked | enemy-instant | Basic combo builder
- 1822 | Rake | 24 | form-locked | enemy-instant | Bleed combo builder
- 5221 | Shred | 22 | form-locked | enemy-instant | High-damage from-stealth/back
- 9005 | Pounce | 36 | form-locked | enemy-instant | Stealth opener stun
- 1079 | Rip | 20 | form-locked | enemy-instant | Bleed finisher
- 22568 | Ferocious Bite | 32 | form-locked | enemy-instant | Damage finisher
- 5217 | Tiger's Fury | 20 | form-locked | self-instant | Energy boost
- 8998 | Cower | 20 | form-locked | self-instant | Threat drop
- 33876 | Mangle (Cat) | 50 | form-locked | enemy-instant | Feral talent
- 22570 | Maim | 60 | form-locked | enemy-instant | Feral talent finisher stun
- 6785 | Ravage | 32 | form-locked | enemy-instant | Stealth ambush

## DISPELS — friend-instant, mouseover-help

- 2782 | Remove Curse | 24 | dispel | friend-instant | Single curse removal
- 8946 | Cure Poison | 14 | dispel | friend-instant | Single poison removal

## UTILITY / RECOVERY

- 29166 | Innervate | 40 | utility | friend-instant | Mana donate; mouseover-help
- 20484 | Rebirth | 20 | utility | friend-cast | COMBAT rez; mouseover-help; 30min CD
- 18960 | Teleport: Moonglade | 30 | utility | self-cast | Moonglade portal; out-of-combat travel
- 5215 | Prowl | 20 | utility | self-instant | Cat-only stealth toggle (already listed in FORMS)

**NOTE:** TBC Druids do NOT have an out-of-combat resurrection. The "Revive" spell is a WotLK addition. Do NOT include Revive in TBC DruidSetup LAYOUT.

## RACIALS

### Tauren (Horde)
- 20549 | War Stomp | racial-active | cc | enemy-instant | 2s AOE stun
- 20550 | Endurance | passive | passive | self | +5% base HP
- 20552 | Cultivation | passive | profession | self | Herbalism bonus
- 20551 | Nature Resistance | passive | passive | self | +nature resist

### Night Elf (Alliance)
- 20580 | Shadowmeld | racial-active | utility | self-instant | Stealth (out-of-combat only)
- 20577 | Quickness | passive | passive | self | +2% dodge
- 20585 | Wisp Spirit | passive | passive | self | Faster ghost
- 28734 | Touch of Elune | passive | passive | self | Old vanilla; obsolete in TBC
- 20583 | Elune's Grace | racial-active | utility | self-instant | -20% physical hit chance vs you (defensive)

## TALENT PASSIVES — IGNORE (no slot)

- Furor, Heart of the Wild, Leader of the Pack, Naturalist, Natural Shapeshifter, Improved Mark of the Wild, Improved Healing Touch, Improved Wrath, Subtlety, Vengeance, Predatory Strikes, Sharpened Claws, Omen of Clarity, Nature's Reach, Improved Moonfire, Insect Swarm Improved (varies)

## PROFESSIONS — IGNORE

First Aid, Cooking, Basic Campfire, Mining, Smelting, Herbalism, Skinning, Fishing, Enchanting, Disenchant, Alchemy, Tailoring, Leatherworking, Engineering, Blacksmithing, Jewelcrafting

---

## Layout decision rules (Druid-specific overrides on top of `class_setup_pattern.md`)

When generating DruidSetup.lua's LAYOUT:

1. **MotW + Thorns + Gift of the Wild → OPie "DruidBuffs" ring on M4** (NOT bar slots).
2. **Travel forms → OPie "DruidTravel" ring on M5.** (Travel/Aquatic/Flight Form.) Bar 3 ZXCVB row also has Travel/Aquatic for fast-keypress access — duplication intentional.
3. **Form-locked combat abilities (Bear: Maul/Swipe/Bash/etc.; Cat: Claw/Rake/Shred/etc.) → IGNORE list, NOT placed.** User drags to Bar 1 form pages manually; ElvUI saves to `[bonusbar:N]` automatically.
4. **Wrath → key `` ` `` with `startattack` template.** Caster opener that engages auto-attack.
5. **Bear Form → Z with `druid-bear-safe`.** Cat Form → X with `druid-cat-safe`. Travel/Aquatic/Prowl on C/V/B raw.
6. **Heals on Alt-QERT row** with `mouseover-help`: Healing Touch (Alt-Q), Rejuvenation (Alt-E), Regrowth (Alt-R), Lifebloom (Alt-T).
7. **Rebirth on Alt-Q? No, conflicts with HT.** Place rez/utility heals on Alt-cluster: Rebirth (Alt-Q maybe relocated?), Tranquility (Alt-R), Innervate (Alt-T). Hmm conflict — see iteration 4 note below.
8. **Dispels on Alt-bottom row**: Cure Poison (Alt-F), Remove Curse (Alt-G).
9. **Defensives on Alt-ZXCVB**: Soothe Animal (Alt-Z, mouseover-harm), Track Humanoids (Alt-X), Nature's Grasp (Alt-C, self-cast), Barkskin (Alt-V, self-cast), Dash (Alt-B).
10. **Bar 9-style cooldowns folded into Alt-numrow** (since Bar 9 is disabled): Tiger's Fury (Alt-3), Frenzied Regeneration (Alt-4), Enrage (Alt-5).
11. **Revive — DO NOT INCLUDE.** TBC Druids can't OOC rez.
12. **IGNORE**: all passives, race actives (manual placement), professions, all 21+ form-locked combat spells, OPie-handled buffs (MotW/Thorns/GotW).

## Known DruidSetup gaps to fix in next iteration

- Current DruidSetup.lua includes "Revive" — this is WotLK-only, REMOVE
- Current DruidSetup.lua puts Rebirth on Alt-Q which conflicts with Healing Touch — NEED to resolve; HT is more frequent so HT keeps Alt-Q, Rebirth moves to Alt-3 or Alt-numrow
- Current DruidSetup.lua puts Tiger's Fury / Frenzied Regen / Enrage on Alt-3/4/5 — that's correct per rule 10
- Faerie Fire is on Bar 1 button 4 — should it have `mouseover-harm`? Yes, it's debuff cast on enemy

## Spec notes for the skill

- **Feral**: Bear/Cat focus. Form-locked spells dominate. Caster spells (Wrath, Moonfire) used as ranged supplements. Heals important for solo survival.
- **Balance**: Caster-only. Wrath + Moonfire + Starfire + Insect Swarm + Hurricane primary rotation. Moonkin Form L40+.
- **Resto**: Heal-focus. HT, Rejuv, Regrowth, Lifebloom (TBC), Swiftmend (talent), Tranquility, Innervate, Rebirth. Tree of Life L40+.

For "Feral leveling defaults" the ShamanSetup-equivalent baseline, the LAYOUT covers all caster spells (since Druid spends time in caster form too) + all forms + heals + dispels. Form-locked spells are deliberately excluded for manual placement.
