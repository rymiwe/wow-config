-- MageSetup: school-grouped beginner layout (per user direction 2026-05-10
-- for L5 mage learning the class). Numrow is school columns on 1-3 -
-- intuitive muscle memory for "1=Frost, 2=Fire, 3=Arcane" - then instants
-- 4-5 fill in as she trains. ALL three primary nukes available at L1, so the
-- layout is useful from her first login regardless of which school she favors.
--
-- Less modifier reliance: high-frequency stuff lives on plain keys. Alt-bar
-- holds spec-CDs + L60+ TBC spells + situational stuff she'll grow into.
--
-- BAR LAYOUT (matches other classes; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (`, 1-5 / Q E R T)
--   Bar 3 = MAIN BOTTOM (F G / Z X C V B)
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--
-- OPie rings:
--   M4 = Mage Armors (Frost, Mage, Ice, Molten - mutually exclusive)
--   M5 = Conjures + Portals + Teleports (slow OOC utility)

local LAYOUT = {
    -- MAIN TOP (Bar 1) - SCHOOL COLUMNS on numrow: 1=Frost, 2=Fire, 3=Arcane.
    -- Then instant follow-ups on 4-5. All three primary nukes are L1 trains.
    {"Counterspell",           1, 1},                     -- L24   `   (interrupt + 8s lockout)
    {"Frostbolt",              1, 2, "nuke-mouseover"},   -- L1    1   (Frost school cast)
    {"Fireball",               1, 3, "nuke-mouseover"},   -- L1    2   (Fire school cast)
    {"Arcane Missiles",        1, 4, "nuke-mouseover"},   -- L1    3   (Arcane school channel)
    {"Fire Blast",             1, 5, "nuke-mouseover"},   -- L6    4   (instant burst - off-CD filler)
    {"Frost Nova",             1, 6},                     -- L10   5   (instant root + AoE - iconic combo)
    -- QERT row: CC + escape + defensives (high-value control)
    {"Polymorph",              1, 8, "focus-mouseover-harm"}, -- L8 Q   (iconic CC; focus-first)
    {"Blink",                  1, 10, "self-cast"},       -- L20   E   (escape)
    {"Ice Barrier",            1, 11, "self-cast"},       -- L40 Frost R (absorb shield)
    {"Cold Snap",              1, 12, "self-cast"},       -- L30 Frost T (reset Frost CDs)

    -- MAIN BOTTOM (Bar 3) - F/G self-buffs, ZXCVB AoE + situational
    {"Frost Armor",            3, 5, "self-cast"},        -- L1    F   (starter armor; OPie M4 has all variants)
    {"Conjure Mana Gem",       3, 6, "self-cast"},        -- L28   G   (frequent OOC create)
    -- ZXCVB row: AoE + situational + travel
    {"Cone of Cold",           3, 8},                     -- L26   Z   (instant frontal AoE + slow)
    {"Arcane Explosion",       3, 9},                     -- L14   X   (instant PBAoE)
    {"Mana Shield",            3, 10, "self-cast"},       -- L20   C   (HP-for-mana defensive)
    {"Evocation",              3, 11, "self-cast"},       -- L20   V   (mana channel)
    {"Slow Fall",              3, 12, "mouseover-help"},  -- L12   B   (cast on friend or self)

    -- ALT TOP (Bar 4) - higher-level spec spells + cooldowns (rare in early leveling)
    {"Pyroblast",              4, 2, "nuke-mouseover"},   -- L20 Fire Alt-1 (Fire heavy nuke)
    {"Scorch",                 4, 3, "nuke-mouseover"},   -- L22 Fire Alt-2 (Fire short cast)
    {"Ice Lance",              4, 4, "nuke-mouseover"},   -- TBC L66 Alt-3 (Frost instant on frozen)
    {"Slow",                   4, 5, "nuke-mouseover"},   -- TBC L66 Alt-4 (Arcane snare)
    {"Blizzard",               4, 6},                     -- L20 Frost Alt-5 (channel ground AoE)
    -- Alt-QERT: spec cooldowns + niche utility
    {"Combustion",             4, 8, "self-cast"},        -- L30 Fire Alt-Q (crit CD)
    {"Presence of Mind",       4, 10, "self-cast"},       -- L30 Arcane Alt-E (instant cast next spell)
    {"Arcane Power",           4, 11, "self-cast"},       -- L30 Arcane Alt-R (damage CD)
    {"Spellsteal",             4, 12, "mouseover-harm"},  -- TBC L60 Alt-T (steal buff)

    -- ALT BOTTOM (Bar 5) - dispels + niche AOE
    {"Remove Lesser Curse",    5, 5, "mouseover-help"},   -- L18   Alt-F (dispel curse from friend)
    -- Alt-G reserved for Draenei Gift of the Naaru via RACIALS (heal beats inspect).
    {"Dragon's Breath",        5, 8},                     -- TBC L60 Fire Alt-Z (instant disorient)
    {"Blast Wave",             5, 9},                     -- L30 Fire Alt-X (PBAoE)
    {"Mass Dispel",            5, 10},                    -- TBC L60 Alt-C (mass dispel)
    -- Alt-V/B left empty (placeholders for racial)
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
    ["Pyroblast"]=true, ["Burning Soul"]=true, ["Improved Scorch"]=true,
    ["Master of Elements"]=true, ["Critical Mass"]=true, ["Blazing Speed"]=true,
    ["Improved Hot Streak"]=true, ["Combustion"]=true,                  -- skip (placed in LAYOUT - Lua dedup handles)
    ["Frost Warding"]=true, ["Improved Frostbolt"]=true, ["Elemental Precision"]=true,
    ["Ice Shards"]=true, ["Frostbite"]=true, ["Improved Frost Nova"]=true,
    ["Permafrost"]=true, ["Piercing Ice"]=true, ["Cold Snap"]=true,
    ["Improved Blizzard"]=true, ["Arctic Reach"]=true, ["Frost Channeling"]=true,
    ["Shatter"]=true, ["Ice Barrier"]=true, ["Winter's Chill"]=true,
    -- Armors - handled by OPie ring (M4)
    -- Frost Armor placed in LAYOUT on F (L1 starter armor); upgrades via OPie M4 ring.
    ["Ice Armor"]=true, ["Molten Armor"]=true,
    -- Conjures - handled by OPie ring (M5)
    ["Conjure Water"]=true, ["Conjure Food"]=true, ["Conjure Refreshment"]=true,
    -- Portals + Teleports - handled by OPie ring (M5)
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
    -- Race actives - placed via RACIALS or IGNORE
    ["Blood Fury"]=true, ["Berserking"]=true, ["War Stomp"]=true,
    ["Shadowmeld"]=true, ["Will of the Forsaken"]=true, ["Cannibalize"]=true,
    ["Mana Tap"]=true, ["Arcane Torrent"]=true,
    -- Gift of the Naaru handled via RACIALS table (Draenei -> Alt-G). NOT in IGNORE.
    -- Detect Magic moved to IGNORE so Alt-G is free for the racial heal.
    ["Detect Magic"]=true,
    ["Underwater Breathing"]=true,
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
        {"Gift of the Naaru", 5, 6, "mouseover-help"},  -- Alt-G: heal slot (replaces Detect Magic)
    },
    Troll = {
        {"Berserking", 5, 12, "self-cast"},     -- Alt-B: damage CD
    },
    Undead = {
        {"Will of the Forsaken", 5, 12, "self-cast"},
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},               -- C: cross-class racial-CC slot (Cold Snap is on C - conflict)
        -- NOTE: Cold Snap is at 3,10 in LAYOUT - skip Arcane Torrent or document conflict
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("MageSetup", placed, skipped, orphans)
    print("|cffffd700MageSetup tip:|r School columns on numrow: 1=Frost, 2=Fire, 3=Arcane.")
    print("|cff999999  4=Fire Blast (L6), 5=Frost Nova (L10) auto-fill when trained.|r")
    print("|cff999999  Q=Polymorph (focus-first CC), E=Blink, R=Ice Barrier, T=Cold Snap.|r")
    print("|cff999999  Armors: hold M4 (OPie ring). Conjures/Portals/Teleports: hold M5.|r")
end

SetupCore:RegisterClass("MAGE", Run, LAYOUT)

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
