-- MageSetup: Frost-leaning generalist (works for Fire + Arcane via untrained-skip).
-- Frost is the default leveling spec because Frost Nova + Ice Barrier + Cold Snap
-- + Frostbolt is the most self-sufficient and survival-friendly leveling kit.
--
-- BAR LAYOUT (matches other classes; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (`, 1-5 / Q E R T)
--   Bar 3 = MAIN BOTTOM (F G / Z X C V B)
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--
-- Mage-specific notes:
--   * Counterspell on ` (baseline interrupt at L24 - the iconic mage interrupt)
--   * Polymorph on Q with focus-mouseover-harm (the iconic mage CC; focus-first
--     because focus IS the CC target on a mage)
--   * Cast nukes (Frostbolt/Fireball/Pyroblast) on Alt-numrow per cast/instant
--     separation principle. Frostbolt = Alt-1 (most-spammed Frost cast).
--   * Armor toggles on OPie M4 (4 mutually-exclusive armors, contextual choice).
--   * Conjures + Portals + Teleports on OPie M5 (slow OOC utility).
--
-- OPie rings:
--   M4 = Mage Armors (Frost, Mage, Ice, Molten)
--   M5 = Conjures + Portals + Teleports

local LAYOUT = {
    -- MAIN TOP (Bar 1) - ` = Counterspell (baseline interrupt). Numrow = instants.
    {"Counterspell",           1, 1},                     -- L24   `   (interrupt + 8s lockout school)
    {"Frost Nova",             1, 2},                     -- L10   1   (instant root + AoE damage)
    {"Fire Blast",             1, 3, "nuke-mouseover"},   -- L6    2   (instant nuke; mouseover for spread)
    {"Cone of Cold",           1, 4},                     -- L26   3   (instant frontal AoE + slow)
    {"Ice Lance",              1, 5, "nuke-mouseover"},   -- TBC L66 4 (instant; triple damage on frozen)
    {"Arcane Explosion",       1, 6},                     -- L14   5   (instant PBAoE)
    -- QERT row: CC + control + utility
    {"Polymorph",              1, 8, "focus-mouseover-harm"}, -- L8 Q  (iconic CC; focus-first - focus IS the sheep target)
    {"Blink",                  1, 10, "self-cast"},       -- L20   E   (self-anchored escape)
    {"Spellsteal",             1, 11, "mouseover-harm"},  -- TBC L60 R (steal buff from enemy)
    {"Slow",                   1, 12, "nuke-mouseover"},  -- TBC L66 T (Arcane snare; spread-friendly)

    -- MAIN BOTTOM (Bar 3) - F/G utility, ZXCVB defensives
    {"Mage Armor",             3, 5},                     -- L34   F   (default armor; right-aligned. Real toggle in OPie M4)
    {"Conjure Mana Gem",       3, 6, "self-cast"},        -- L28   G   (frequent OOC create)
    -- ZXCVB row: defensives + utility
    {"Ice Barrier",            3, 8, "self-cast"},        -- L40 Frost Z (absorb shield - high-frequency defensive)
    {"Mana Shield",            3, 9, "self-cast"},        -- L20   X   (HP for mana absorb)
    {"Cold Snap",              3, 10, "self-cast"},       -- L30 Frost C (reset Frost CDs)
    {"Evocation",              3, 11, "self-cast"},       -- L20   V   (8s mana channel)
    {"Slow Fall",              3, 12, "mouseover-help"},  -- L12   B   (cast on friend or self)

    -- ALT TOP (Bar 4) - CAST-TIME damage on numrow, utility on Alt-QERT
    -- ` left empty (or for racial)
    {"Frostbolt",              4, 2, "nuke-mouseover"},   -- L1    Alt-1 (Frost spam cast - primary nuke)
    {"Fireball",               4, 3, "nuke-mouseover"},   -- L1    Alt-2 (Fire spam cast)
    {"Pyroblast",              4, 4, "nuke-mouseover"},   -- L20 Fire Alt-3 (heavy cast nuke)
    {"Scorch",                 4, 5, "nuke-mouseover"},   -- L22 Fire Alt-4 (Fire short cast)
    {"Arcane Missiles",        4, 6, "nuke-mouseover"},   -- L1    Alt-5 (channel nuke)
    -- Alt-QERT: spec CDs + AoE
    {"Combustion",             4, 8, "self-cast"},        -- L30 Fire Alt-Q (crit CD)
    {"Presence of Mind",       4, 10, "self-cast"},       -- L30 Arcane Alt-E (instant cast next spell)
    {"Arcane Power",           4, 11, "self-cast"},       -- L30 Arcane Alt-R (damage CD)
    {"Blizzard",               4, 12},                    -- L20 Frost Alt-T (channel ground AoE)

    -- ALT BOTTOM (Bar 5) - dispels + utility
    {"Remove Lesser Curse",    5, 5, "mouseover-help"},   -- L18   Alt-F (dispel curse from friend)
    -- Alt-G reserved for Draenei Gift of the Naaru via RACIALS (heal beats inspect).
    -- Detect Magic moved to IGNORE - low-use OOC inspect, drag manually if wanted.
    -- Alt-ZXCVB: situational + niche
    {"Dragon's Breath",        5, 8},                     -- TBC L60 Fire Alt-Z (instant frontal disorient + damage)
    {"Blast Wave",             5, 9},                     -- L30 Fire Alt-X (instant PBAoE + slow)
    {"Mass Dispel",            5, 10},                    -- TBC L60 Alt-C (channel - dispel buffs/debuffs en masse)
    {"Frostbite",              5, 11},                    -- (Frost talent passive - skip if absent)
    {"Mage Ward",              5, 12, "self-cast"},       -- (placeholder - swap if not in TBC)
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
    ["Frost Armor"]=true, ["Ice Armor"]=true, ["Molten Armor"]=true,
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
    print("|cffffd700MageSetup tip:|r Polymorph on Q uses focus-first targeting -")
    print("|cff999999  /focus a mob, then Q sheeps your focus regardless of current target.|r")
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
