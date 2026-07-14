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
    {"Heroic Strike",          1, 1, "startattack"},      -- L1    `   (always-ready next-swing damage; startattack engages auto-attack on first press for L1 chars before Mortal Strike trained)
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
    {"Battle Stance",          3, 5},                     -- L1    F   (default stance; right-aligned)
    {"Defensive Stance",       3, 6},                     -- L10   G   (-10% dmg taken; tank)
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
    {"Shield Bash",            5, 5},                     -- L16 Battle/Def Alt-F (interrupt; right-aligned)
    {"Shield Block",           5, 6, "self-cast"},        -- L16 Defensive Alt-G (+block)
    -- Alt-ZXCVB: defensive cooldowns + AOE shouts
    {"Shield Wall",            5, 7, "self-cast"},        -- L16 Defensive (-75% dmg CD; Alt-Z = mount)
    {"Last Stand",             5, 9, "self-cast"},        -- L40 Prot Alt-X (+30% HP CD)
    {"Spell Reflection",       5, 10, "self-cast"},       -- TBC L20 Alt-C (reflect spell)
    {"Demoralizing Shout",     5, 11},                    -- L14   Alt-V (-AP AOE)
    {"Challenging Shout",      5, 12},                    -- L20   Alt-B (AOE taunt)
}

-- Stance-specific layouts. Each stance has its own Bar 1 page (Battle = page 7,
-- Defensive = page 8, Berserker = page 9 per ElvUI TBC defaults). Run /setupbars
-- in each stance once to populate. Shared utility (Sunder Armor, Disarm, etc.)
-- lives on Bar 3 placed by main LAYOUT and stays accessible from any stance.
local BATTLE_LAYOUT = {
    {"Heroic Strike",          1, 1, "startattack"},      -- `   (queued next-swing)
    {"Mortal Strike",          1, 2, "startattack"},      -- 1   (Arms primary)
    {"Bloodthirst",            1, 3, "startattack"},      -- 2   (Fury primary - usable any stance)
    {"Charge",                 1, 4, "startattack"},      -- 3   (Battle stance opener)
    {"Overpower",              1, 5},                     -- 4   (Battle reactive after dodge)
    {"Thunder Clap",           1, 6},                     -- 5   (Battle/Def AoE)
    {"Hamstring",              1, 8},                     -- Q   (universal snare)
    {"Rend",                   1, 10},                    -- E   (Battle/Def DoT)
    {"Slam",                   1, 11},                    -- R   (universal cast)
    {"Execute",                1, 12},                    -- T   (sub-20% finisher)
}

local DEFENSIVE_LAYOUT = {
    {"Heroic Strike",          1, 1, "startattack"},      -- `
    {"Sunder Armor",           1, 2},                     -- 1   (threat builder)
    {"Revenge",                1, 3},                     -- 2   (Def reactive after dodge/parry/block)
    {"Shield Slam",            1, 4},                     -- 3   (Prot key ability)
    {"Shield Block",           1, 5, "self-cast"},        -- 4   (defensive CD)
    {"Disarm",                 1, 6},                     -- 5   (Def/Battle)
    {"Hamstring",              1, 8},                     -- Q
    {"Shield Bash",            1, 10},                    -- E   (interrupt - Def/Battle)
    {"Shield Wall",            1, 11, "self-cast"},       -- R   (big damage reduction CD)
    {"Intervene",              1, 12, "mouseover-help"},  -- T   (TBC L66 - friend redirect)
}

local BERSERKER_LAYOUT = {
    {"Heroic Strike",          1, 1, "startattack"},      -- `
    {"Mortal Strike",          1, 2, "startattack"},      -- 1   (Arms - any stance)
    {"Bloodthirst",            1, 3, "startattack"},      -- 2   (Fury - any stance)
    {"Whirlwind",              1, 4, "startattack"},      -- 3   (Berserker only AoE)
    {"Intercept",              1, 5, "startattack"},      -- 4   (Berserker gap-closer + stun)
    {"Berserker Rage",         1, 6, "self-cast"},        -- 5   (fear break + rage gen)
    {"Hamstring",              1, 8},                     -- Q
    {"Pummel",                 1, 10},                    -- E   (Berserker interrupt)
    {"Slam",                   1, 11},                    -- R
    {"Execute",                1, 12},                    -- T
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
    -- Race actives — combat racials auto-placed via RACIALS table per docs/racials.md.
    -- Shadowmeld (NE) / Gift of the Naaru (Draenei) IGNORE: low utility for Warrior.
    -- Stoneform (Dwarf) / WotF (Undead) / Escape Artist (Gnome) IGNORE: alt-bottom full.
    ["Shadowmeld"]=true, ["Gift of the Naaru"]=true,
    ["Mana Tap"]=true,
    ["Stoneform"]=true, ["Will of the Forsaken"]=true, ["Escape Artist"]=true,
    ["Cannibalize"]=true, ["Find Treasure"]=true, ["Perception"]=true,
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

-- Per-race racial placement (per docs/racials.md). Warrior is all-race.
-- C slot: Tauren War Stomp OR BE Arcane Torrent (mutually exclusive races).
-- Alt-` slot: Orc Blood Fury OR Troll Berserking (mutually exclusive races).
-- Other races: racial low-utility for Warrior or alt-bottom full → IGNORE.
local RACIALS = {
    Tauren = {
        {"War Stomp", 3, 10},                       -- C: combat AOE stun
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},                  -- C: combat CC + interrupt-equivalent
    },
    Orc = {
        {"Blood Fury", 4, 1, "self-cast"},          -- Alt-`: damage CD (alt-numrow CD slot)
    },
    Troll = {
        {"Berserking", 4, 1, "self-cast"},          -- Alt-`: damage CD
    },
}

local function Run()
    -- TBC Warrior stance indices: 1=Battle, 2=Defensive, 3=Berserker.
    -- Stance-aware /setupbars: in each stance, populate that stance's Bar 1
    -- page. Bar 3-5 (shared utility) come from the main LAYOUT below.
    local stance = GetShapeshiftForm()
    if stance == 1 then
        SetupCore:ApplyFormLayout("WarriorSetup", "BATTLE stance", BATTLE_LAYOUT)
        print("|cff999999  Shift to Defensive/Berserker and /setupbars to set up those stances.|r")
        return
    elseif stance == 2 then
        SetupCore:ApplyFormLayout("WarriorSetup", "DEFENSIVE stance", DEFENSIVE_LAYOUT)
        print("|cff999999  Tank kit placed. Shift to Battle/Berserker for those stances.|r")
        return
    elseif stance == 3 then
        SetupCore:ApplyFormLayout("WarriorSetup", "BERSERKER stance", BERSERKER_LAYOUT)
        print("|cff999999  DPS kit placed. Shift to Battle/Defensive for those stances.|r")
        return
    end
    -- No stance (rare): apply default LAYOUT (used as Battle-stance fallback +
    -- populates Bar 3-5 shared utility for all stances).
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("WarriorSetup", placed, skipped, orphans)
    print("|cffffd700WarriorSetup tip:|r Shouts on OPie M4, Stances on M5 (also F/G/Z).")
    print("|cff999999  Bar 3-5 holds shared utility (Sunder, Disarm, Shouts, etc.) - works any stance.|r")
    print("|cff999999  Shift to each stance and /setupbars to populate that stance's Bar 1:|r")
    print("|cff999999    Battle: Charge/Overpower/Thunder Clap/Rend|r")
    print("|cff999999    Defensive: Sunder/Revenge/Shield Slam/Shield Block/Shield Wall|r")
    print("|cff999999    Berserker: Whirlwind/Intercept/Berserker Rage/Pummel/Recklessness|r")
    print("|cff999999  Shift held = caster bar shown (page 1) in any stance.|r")
end

SetupCore:RegisterClass("WARRIOR", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- ===========================================================================
do
    -- Class-conditional: see ShamanSetup for rationale (cross-class M4/M5 collision).
    local _, class = UnitClass("player")
    if class ~= "WARRIOR" then return end
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
