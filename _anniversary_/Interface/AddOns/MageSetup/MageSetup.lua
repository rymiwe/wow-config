-- MageSetup: tier-based leveling layout (per user 2026-05-10).
-- LAYOUT_TIERS replaces single LAYOUT - SetupCore picks the highest tier where
-- player level >= minLevel. Tier crossings prompt /setupbars on level-up.
--
-- Layout principle (per user):
--   * Cast-time "bolt" spells on numrow 1-5 (top bar)
--   * Q = Frost Nova, E = Fire Blast (mirror instants)
--   * R = Polymorph (CC, focus-first)
--   * Alt-bar intentionally empty per wife's preference (no auto-placed skills)
--
-- Tiers:
--   L1   - L1 base kit (Frostbolt/Fireball/Arcane Missiles + Frost Armor)
--   L10  - + Frost Nova (Q), Slow Fall (B L12), Arcane Explosion (X L14)
--   L20  - + Pyroblast/Scorch (4/5), Counterspell (`), Blink (T), Mana Shield (C),
--          Cone of Cold (Z L26), Conjure Mana Gem (G L28)
--
-- Higher tiers (L30, L40+) added when wife levels into them - keeps the layout
-- file lean and avoids speculating on her future preferences.
--
-- Draenei: Gift of the Naaru auto-places on V (plain) via RACIALS at all tiers.

local L1_TIER = {
    -- BAR 1 numrow: cast-time bolts (only Arcane Missiles available at L1)
    {"Frostbolt",              1, 2, "nuke-mouseover"},   -- L1    1
    {"Fireball",               1, 3, "nuke-mouseover"},   -- L1    2
    {"Arcane Missiles",        1, 4, "nuke-mouseover"},   -- L1    3
    -- 4, 5 empty (Pyroblast L20, Scorch L22 arrive in L20 tier)
    -- BAR 1 QERT: instants (Fire Blast L6, Polymorph L8 fill in mid-tier)
    {"Fire Blast",             1, 10, "nuke-mouseover"},  -- L6    E
    {"Polymorph",              1, 11, "focus-mouseover-harm"}, -- L8 R
    -- V reserved for Draenei Naaru via RACIALS
}

local L10_TIER = {
    {"Frostbolt",              1, 2, "nuke-mouseover"},
    {"Fireball",               1, 3, "nuke-mouseover"},
    {"Arcane Missiles",        1, 4, "nuke-mouseover"},
    {"Frost Nova",             1, 8},                     -- L10   Q   (mirrors Fire Blast on E)
    {"Fire Blast",             1, 10, "nuke-mouseover"},  -- L6    E
    {"Polymorph",              1, 11, "focus-mouseover-harm"},
    {"Arcane Explosion",       3, 9},                     -- L14   X
    {"Slow Fall",              3, 12, "mouseover-help"},  -- L12   B
}

local L20_TIER = {
    -- BAR 1 numrow: all five cast bolts now placed
    {"Counterspell",           1, 1},                     -- L24   `
    {"Frostbolt",              1, 2, "nuke-mouseover"},   -- 1
    {"Fireball",               1, 3, "nuke-mouseover"},   -- 2
    {"Arcane Missiles",        1, 4, "nuke-mouseover"},   -- 3
    {"Pyroblast",              1, 5, "nuke-mouseover"},   -- L20   4   (Fire heavy bolt)
    {"Scorch",                 1, 6, "nuke-mouseover"},   -- L22   5   (Fire short bolt)
    -- QERT: instants + control
    {"Frost Nova",             1, 8},                     -- Q
    {"Fire Blast",             1, 10, "nuke-mouseover"},  -- E
    {"Polymorph",              1, 11, "focus-mouseover-harm"}, -- R
    {"Blink",                  1, 12, "self-cast"},       -- L20   T
    -- F/G + ZXCVB: utility
    {"Conjure Mana Gem",       3, 6, "self-cast"},        -- L28   G
    {"Cone of Cold",           3, 8},                     -- L26   Z
    {"Arcane Explosion",       3, 9},                     -- X
    {"Mana Shield",            3, 10, "self-cast"},       -- L20   C
    {"Slow Fall",              3, 12, "mouseover-help"},  -- B
}

local LAYOUT_TIERS = {
    {minLevel = 1,  layout = L1_TIER},
    {minLevel = 10, layout = L10_TIER},
    {minLevel = 20, layout = L20_TIER},
    -- L30+ tiers added when wife dings into them.
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Cloth"]=true, ["Daggers"]=true, ["One-Handed Swords"]=true,
    ["Staves"]=true, ["Wands"]=true, ["Shoot Wand"]=true,
    -- Mage talent passives (no slot needed)
    ["Arcane Subtlety"]=true, ["Arcane Focus"]=true, ["Improved Arcane Missiles"]=true,
    ["Wand Specialization"]=true, ["Magic Absorption"]=true, ["Arcane Concentration"]=true,
    ["Magic Attunement"]=true, ["Improved Mana Shield"]=true, ["Improved Counterspell"]=true,
    ["Arcane Meditation"]=true, ["Improved Blink"]=true, ["Mind Mastery"]=true,
    ["Arcane Mind"]=true, ["Improved Arcane Explosion"]=true, ["Arcane Instability"]=true,
    ["Improved Fireball"]=true, ["Impact"]=true, ["Ignite"]=true,
    ["Improved Fire Blast"]=true, ["Incinerate"]=true, ["Improved Flamestrike"]=true,
    ["Burning Soul"]=true, ["Improved Scorch"]=true,
    ["Master of Elements"]=true, ["Critical Mass"]=true, ["Blazing Speed"]=true,
    ["Improved Hot Streak"]=true,
    ["Frost Warding"]=true, ["Improved Frostbolt"]=true, ["Elemental Precision"]=true,
    ["Ice Shards"]=true, ["Frostbite"]=true, ["Improved Frost Nova"]=true,
    ["Permafrost"]=true, ["Piercing Ice"]=true,
    ["Improved Blizzard"]=true, ["Arctic Reach"]=true, ["Frost Channeling"]=true,
    ["Shatter"]=true, ["Winter's Chill"]=true,
    -- Armors handled exclusively by OPie ring (M4)
    ["Frost Armor"]=true, ["Ice Armor"]=true, ["Molten Armor"]=true,
    -- Conjures + Portals + Teleports handled by OPie ring (M5)
    ["Conjure Water"]=true, ["Conjure Food"]=true, ["Conjure Refreshment"]=true,
    ["Portal: Stormwind"]=true, ["Portal: Ironforge"]=true, ["Portal: Darnassus"]=true,
    ["Portal: Exodar"]=true, ["Portal: Shattrath"]=true,
    ["Portal: Orgrimmar"]=true, ["Portal: Undercity"]=true, ["Portal: Thunder Bluff"]=true,
    ["Portal: Silvermoon"]=true,
    ["Teleport: Stormwind"]=true, ["Teleport: Ironforge"]=true, ["Teleport: Darnassus"]=true,
    ["Teleport: Exodar"]=true, ["Teleport: Shattrath"]=true,
    ["Teleport: Orgrimmar"]=true, ["Teleport: Undercity"]=true, ["Teleport: Thunder Bluff"]=true,
    ["Teleport: Silvermoon"]=true,
    -- Race passives
    ["Stoneform"]=true, ["Find Treasure"]=true, ["Frost Resistance"]=true,
    ["Touch of Elune"]=true, ["Wisp Spirit"]=true, ["Quickness"]=true,
    ["Nature Resistance"]=true, ["Heroic Presence"]=true, ["Shadow Resistance"]=true,
    ["Hardiness"]=true, ["Endurance"]=true, ["Cultivation"]=true,
    ["Magic Resistance"]=true, ["Expansive Mind"]=true, ["Arcane Resistance"]=true,
    ["Engineering Specialization"]=true, ["The Human Spirit"]=true,
    ["Sword Specialization"]=true, ["Mace Specialization"]=true, ["Diplomacy"]=true,
    ["Perception"]=true,
    -- Race actives - placed via RACIALS or skipped
    ["Blood Fury"]=true, ["Berserking"]=true, ["War Stomp"]=true,
    ["Shadowmeld"]=true, ["Will of the Forsaken"]=true, ["Cannibalize"]=true,
    ["Mana Tap"]=true, ["Arcane Torrent"]=true,
    ["Underwater Breathing"]=true,
    -- Detect Magic moved to IGNORE - low-use OOC inspect, drag manually if wanted.
    ["Detect Magic"]=true,
    -- Spec CDs / advanced spells / niche utility kept off bars per wife's "no alt bar"
    -- preference. Will be re-added to LAYOUT_TIERS when she's ready (L30+ tier).
    ["Combustion"]=true, ["Presence of Mind"]=true, ["Arcane Power"]=true,
    ["Ice Barrier"]=true, ["Cold Snap"]=true,
    ["Blizzard"]=true, ["Dragon's Breath"]=true, ["Blast Wave"]=true,
    ["Mass Dispel"]=true, ["Evocation"]=true, ["Spellsteal"]=true,
    ["Slow"]=true, ["Ice Lance"]=true, ["Remove Lesser Curse"]=true,
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Mining"]=true, ["Smelting"]=true, ["Herbalism"]=true, ["Skinning"]=true,
    ["Fishing"]=true, ["Enchanting"]=true, ["Disenchant"]=true,
    ["Alchemy"]=true, ["Tailoring"]=true, ["Leatherworking"]=true,
    ["Engineering"]=true, ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true, ["Gemcutting"]=true,
    -- Misc
    ["Ritual of Refreshment"]=true,
}

-- Per-race racial placement (per docs/racials.md)
local RACIALS = {
    Gnome = {
        {"Escape Artist", 5, 12, "self-cast"},  -- Alt-B: defensive break
    },
    Human = {},
    Draenei = {
        {"Gift of the Naaru", 3, 11, "mouseover-help"},  -- V (plain): combat heal
    },
    Troll = {
        {"Berserking", 5, 12, "self-cast"},     -- Alt-B
    },
    Undead = {
        {"Will of the Forsaken", 5, 12, "self-cast"},
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT_TIERS, IGNORE, RACIALS)
    SetupCore:PrintResults("MageSetup", placed, skipped, orphans)
    print("|cffffd700MageSetup tip:|r Cast bolts on top numrow 1-5. Q=Frost Nova, E=Fire Blast (instant mirror).")
    print("|cff999999  R=Polymorph (focus-first CC). Draenei: V=Gift of the Naaru.|r")
    print("|cff999999  Layout grows in tiers: L1, L10, L20 currently defined.|r")
    print("|cff999999  Armors: hold M4 (OPie ring). Conjures/Portals/Teleports: hold M5.|r")
end

SetupCore:RegisterClass("MAGE", Run, LAYOUT_TIERS)

-- ===========================================================================
-- OPie ring registration
-- ===========================================================================
do
    local _, class = UnitClass("player")
    if class ~= "MAGE" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Armors ring (M4 hold) - 4 mutually-exclusive armors, contextual choice.
    R:AddDefaultRing("MageArmors", {
        {id="/cast {{spell:6117}}",  _u="ma"}, -- Mage Armor
        {id="/cast {{spell:7302}}",  _u="ic"}, -- Ice Armor (Frost - replaces Frost Armor)
        {id="/cast {{spell:30482}}", _u="mo"}, -- Molten Armor (TBC Fire)
        {id="/cast {{spell:168}}",   _u="fa"}, -- Frost Armor (rank 1)
        name = "Armors", hotkey = "BUTTON4", _u = "MgArm", v = 1,
    })

    -- Conjures + Portals + Teleports ring (M5 hold) - slow OOC utility.
    R:AddDefaultRing("MageUtility", {
        {id="/cast {{spell:5504}}",  _u="cw"}, -- Conjure Water
        {id="/cast {{spell:587}}",   _u="cf"}, -- Conjure Food
        {id="/cast {{spell:759}}",   _u="cm"}, -- Conjure Mana Gem
        {id="/cast {{spell:3565}}",  _u="ts"}, -- Teleport: Stormwind
        {id="/cast {{spell:3562}}",  _u="ti"}, -- Teleport: Ironforge
        {id="/cast {{spell:3561}}",  _u="td"}, -- Teleport: Darnassus
        {id="/cast {{spell:32271}}", _u="te"}, -- Teleport: Exodar (TBC)
        {id="/cast {{spell:33690}}", _u="tt"}, -- Teleport: Shattrath
        {id="/cast {{spell:10059}}", _u="ps"}, -- Portal: Stormwind
        {id="/cast {{spell:11416}}", _u="pi"}, -- Portal: Ironforge
        {id="/cast {{spell:11419}}", _u="pd"}, -- Portal: Darnassus
        {id="/cast {{spell:32266}}", _u="pe"}, -- Portal: Exodar (TBC)
        {id="/cast {{spell:33691}}", _u="pt"}, -- Portal: Shattrath
        name = "Utility", hotkey = "BUTTON5", _u = "MgUtl", v = 1,
    })
end
