-- WarriorSetup: Arms-leaning generalist defaults that work for Fury/Prot too.
-- Untrained spells skip silently via SetupCore (Mortal Strike/Bloodthirst/Shield
-- Slam/Devastate are talent-gated, so non-spec'd Warriors see empty slots).
--
-- BAR LAYOUT (matches Shaman/Druid/Hunter/Paladin; see bar_layout_design.md):
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, F, G, _ / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--   Bar 7 = DISABLED
--   Bar 9 = DISABLED
--   Bar 10 = CONSUMABLES (preserved across /setupbars)
--
-- Warrior-specific notes:
--   * Heroic Strike on `` ` `` — primary always-ready next-swing damage.
--   * Mortal Strike on key 1 with `startattack` — Arms opener (Fury sees empty until BT trained).
--   * 3 stances on F/G/Z — duplicated in OPie M5 ring intentionally for input flexibility.
--   * Stance-locked spells (Whirlwind, Pummel, Intercept, Berserker Rage, etc.)
--     are placed on shared bars — pressing wrong-stance errors silently.
--   * No Attack slot (per auto_attack_no_slot.md memory).
--
-- OPie rings (M4, M5):
--   M4 = Warrior Shouts (Battle/Commanding/Demoralizing/Challenging/Intimidating)
--   M5 = Warrior Stances (Battle/Defensive/Berserker — mirror of F/G/Z bar slots)

local LAYOUT = {
    -- MAIN TOP (Bar 1) — Heroic Strike + damage on numrow, gap-closer/utility on QERT
    {"Heroic Strike",          1, 1},                     -- L1    `   (always-ready next-swing damage)
    {"Mortal Strike",          1, 2, "startattack"},      -- L30 Arms 1 (opener; engages auto-attack)
    {"Bloodthirst",            1, 3, "startattack"},      -- L30 Fury 2 (Fury filler)
    {"Execute",                1, 4},                     -- L24   3   (sub-20% finisher)
    {"Cleave",                 1, 5},                     -- L20   4   (next-swing AOE)
    {"Slam",                   1, 6},                     -- L30   5   (cast-time hard hit)
    -- QERT row (Q/E/R/T): gap-closer, reactive, snare, DoT
    {"Charge",                 1, 8, "startattack"},      -- L4    Q   (Battle stance opener)
    {"Overpower",              1, 10},                    -- L14   E   (Battle reactive after dodge)
    {"Hamstring",              1, 11},                    -- L8    R   (snare; any stance)
    {"Rend",                   1, 12},                    -- L4    T   (bleed DoT; Battle/Defensive)

    -- MAIN BOTTOM (Bar 3) — F/G/Z stances, X/V/B utility
    {"Battle Stance",          3, 4},                     -- L1    F   (default stance)
    {"Defensive Stance",       3, 5},                     -- L10   G   (-10% dmg taken; tank)
    -- ZXCVB row: third stance + tactical utility
    {"Berserker Stance",       3, 8},                     -- L30   Z   (+crit; AOE/burst)
    {"Sunder Armor",           3, 9},                     -- L10   X   (threat + armor stack)
    -- C left empty — Heroic Strike + right-click cover auto-attack
    {"Disarm",                 3, 11},                    -- L24   V   (Defensive/Battle)
    {"Thunder Clap",           3, 12},                    -- L6    B   (Battle AOE)

    -- ALT TOP (Bar 4) — DPS CDs + Berserker stance specials
    -- Alt-numrow: cooldowns (spec-divergent — most untrained for any one spec)
    {"Recklessness",           4, 2, "self-cast"},        -- L50 Berserker Alt-1 (+crit CD)
    {"Death Wish",             4, 3, "self-cast"},        -- L30 Fury Alt-2 (+20% dmg CD)
    {"Sweeping Strikes",       4, 4, "self-cast"},        -- L30 Arms Alt-3 (cleave-on-hit CD)
    {"Retaliation",            4, 5, "self-cast"},        -- L30 Battle Alt-4 (reflect CD)
    {"Shield Slam",            4, 6},                     -- L40 Prot Alt-5 (Prot key ability)
    -- Alt-QERT: Berserker stance specials + Intervene
    {"Intercept",              4, 8, "startattack"},      -- L30 Berserker Alt-Q (gap-closer + stun)
    {"Pummel",                 4, 10},                    -- L38 Berserker Alt-E (interrupt)
    {"Berserker Rage",         4, 11, "self-cast"},       -- L32 Berserker Alt-R (fear break)
    {"Intervene",              4, 12, "mouseover-help"},  -- TBC L66 Alt-T (friend damage redirect)

    -- ALT BOTTOM (Bar 5) — defensives + AOE utility
    -- Alt-FG: shield interrupts/blocks (Battle/Defensive)
    {"Shield Bash",            5, 4},                     -- L16 Battle/Def Alt-F (interrupt)
    {"Shield Block",           5, 5, "self-cast"},        -- L16 Defensive Alt-G (+block)
    -- Alt-ZXCVB: defensive cooldowns + AOE shouts
    {"Shield Wall",            5, 8, "self-cast"},        -- L16 Defensive Alt-Z (-75% dmg CD)
    {"Last Stand",             5, 9, "self-cast"},        -- L40 Prot Alt-X (+30% HP CD)
    {"Spell Reflection",       5, 10, "self-cast"},       -- TBC L20 Alt-C (reflect spell)
    {"Demoralizing Shout",     5, 11},                    -- L14   Alt-V (-AP AOE)
    {"Challenging Shout",      5, 12},                    -- L20   Alt-B (AOE taunt)
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Plate Mail"]=true, ["Mail"]=true, ["Shield"]=true,
    ["Two-Handed Maces"]=true, ["Two-Handed Swords"]=true, ["Two-Handed Axes"]=true,
    ["One-Handed Maces"]=true, ["One-Handed Swords"]=true, ["One-Handed Axes"]=true,
    ["Polearms"]=true, ["Daggers"]=true, ["Fist Weapons"]=true,
    ["Bows"]=true, ["Crossbows"]=true, ["Guns"]=true, ["Thrown"]=true,
    ["Defense"]=true, ["Dual Wield"]=true,
    -- Warrior talent passives (no slot needed)
    ["Improved Heroic Strike"]=true, ["Improved Rend"]=true, ["Deflection"]=true,
    ["Improved Charge"]=true, ["Tactical Mastery"]=true, ["Iron Will"]=true,
    ["Anger Management"]=true, ["Improved Thunder Clap"]=true,
    ["Improved Overpower"]=true, ["Two-Handed Weapon Specialization"]=true,
    ["Impale"]=true, ["Sword Specialization"]=true, ["Mace Specialization"]=true,
    ["Poleaxe Specialization"]=true, ["Axe Specialization"]=true,
    ["Deep Wounds"]=true, ["Cruelty"]=true,
    ["Improved Demoralizing Shout"]=true, ["Unbridled Wrath"]=true,
    ["Enrage"]=true, ["Improved Cleave"]=true, ["Piercing Howl"]=true,
    ["Blood Craze"]=true, ["Improved Hamstring"]=true,
    ["Improved Battle Shout"]=true, ["Dual Wield Specialization"]=true,
    ["Improved Execute"]=true, ["Flurry"]=true,
    ["Improved Shield Block"]=true, ["Improved Sunder Armor"]=true,
    ["Improved Disarm"]=true, ["Improved Bloodrage"]=true,
    ["Improved Shield Wall"]=true, ["Toughness"]=true,
    ["Concussion Blow"]=true, ["Improved Revenge"]=true, ["Defiance"]=true,
    ["Improved Taunt"]=true, ["Anticipation"]=true,
    ["One-Handed Weapon Specialization"]=true, ["Shield Specialization"]=true,
    ["Improved Spell Reflection"]=true, ["Vitality"]=true, ["Focused Rage"]=true,
    -- Shouts — handled by OPie ring (M4)
    ["Battle Shout"]=true, ["Commanding Shout"]=true, ["Intimidating Shout"]=true,
    -- Stances also in OPie ring (M5) but ALSO on bars; not flagged either way
    -- Race passives (Warrior is available to all races — list catch-all)
    ["The Human Spirit"]=true, ["Diplomacy"]=true, ["Perception"]=true,
    ["Stoneform"]=true, ["Find Treasure"]=true,
    ["Gun Specialization"]=true, ["Frost Resistance"]=true,
    ["Heroic Presence"]=true, ["Inspiring Presence"]=true,
    ["Shadow Resistance"]=true, ["Magic Resistance"]=true,
    ["Quickness"]=true, ["Wisp Spirit"]=true, ["Touch of Elune"]=true,
    ["Nature Resistance"]=true,
    ["Endurance"]=true, ["Cultivation"]=true,
    ["Hardiness"]=true, ["Command"]=true,
    ["Da Voodoo Shuffle"]=true, ["Bow Specialization"]=true,
    ["Beast Slaying"]=true, ["Regeneration"]=true,
    ["Shadow Resistance"]=true, ["Will of the Forsaken"]=true,
    ["Cannibalize"]=true, ["Underwater Breathing"]=true,
    ["Escape Artist"]=true, ["Expansive Mind"]=true,
    ["Arcane Resistance"]=true, ["Engineering Specialization"]=true,
    -- Race actives the user may want manually placed
    ["War Stomp"]=true, ["Blood Fury"]=true, ["Berserking"]=true,
    ["Shadowmeld"]=true, ["Gift of the Naaru"]=true,
    ["Mana Tap"]=true, ["Arcane Torrent"]=true,
    -- Revenge — reactive, optional bar slot; user drags manually if Defensive-tank focus
    ["Revenge"]=true,
    -- Mocking Blow — niche taunt; user drags if Prot-leaning
    ["Mocking Blow"]=true,
    -- Bloodrage — instant rage gen, often macro'd into other casts; not a primary slot
    ["Bloodrage"]=true,
    -- Whirlwind — Berserker AOE; user can drag to Berserker stance page if desired
    ["Whirlwind"]=true,
    -- Devastate — TBC Prot talent; user drags to replace Sunder Armor on X if Prot-spec'd
    ["Devastate"]=true,
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Gemcutting"]=true, ["Mining"]=true, ["Smelting"]=true,
    ["Herbalism"]=true, ["Skinning"]=true, ["Fishing"]=true,
    ["Enchanting"]=true, ["Disenchant"]=true, ["Alchemy"]=true,
    ["Tailoring"]=true, ["Leatherworking"]=true, ["Engineering"]=true,
    ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true,
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE)
    SetupCore:PrintResults("WarriorSetup", placed, skipped, orphans)
    print("|cffffd700WarriorSetup tip:|r Shouts on OPie M4, Stances on M5 (also F/G/Z).")
    print("|cff999999  Arms: Mortal Strike on 1 + Sweeping Strikes on Alt-3 are your CDs.|r")
    print("|cff999999  Fury: Bloodthirst on 2 + Death Wish on Alt-2 + Recklessness on Alt-1.|r")
    print("|cff999999  Prot: Shield Slam on Alt-5 + Last Stand on Alt-X. Drag Devastate over Sunder.|r")
    print("|cff999999  Stance-locked spells (Whirlwind, etc.) error silently in wrong stance.|r")
end

SetupCore:RegisterClass("WARRIOR", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- ===========================================================================
do
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Shouts ring (M4 hold) — party buffs + AOE shouts.
    R:AddDefaultRing("WarriorShouts", {
        {id="/cast {{spell:6673}}", _u="bs"}, -- Battle Shout
        {id="/cast {{spell:469}}",  _u="cs"}, -- Commanding Shout (TBC L60+)
        {id="/cast {{spell:1160}}", _u="ds"}, -- Demoralizing Shout
        {id="/cast {{spell:1161}}", _u="ch"}, -- Challenging Shout (AOE taunt)
        {id="/cast {{spell:5246}}", _u="is"}, -- Intimidating Shout (AOE fear)
        name = "Shouts", hotkey = "BUTTON4", _u = "WarSht", v = 1,
    })

    -- Stances ring (M5 hold) — duplicated with bar F/G/Z slots intentionally.
    R:AddDefaultRing("WarriorStances", {
        {id="/cast {{spell:2457}}", _u="bt"}, -- Battle Stance
        {id="/cast {{spell:71}}",   _u="df"}, -- Defensive Stance
        {id="/cast {{spell:2458}}", _u="be"}, -- Berserker Stance
        name = "Stances", hotkey = "BUTTON5", _u = "WarStn", v = 1,
    })
end
