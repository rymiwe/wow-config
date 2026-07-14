-- WarlockSetup: Affliction-leaning generalist (works for Demonology + Destruction
-- via untrained-skip). Showcase class for the nuke-mouseover convention - every
-- DoT gets mouseover-priority so you can spread Corruption/CoA/Immolate across
-- a pull while keeping Shadow Bolt cast on your main target.
--
-- BAR LAYOUT (matches other classes; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (`, 1-5 / Q E R T)
--   Bar 3 = MAIN BOTTOM (F G / Z X C V B)
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--
-- Warlock-specific notes:
--   * No baseline interrupt - ` slot left empty (Warlock interrupt is via Felhunter Spell Lock on pet bar)
--   * Pet abilities (Firebolt, Sacrifice, Lash of Pain, Spell Lock, Devour Magic, etc.)
--     auto-populate the Blizzard PetActionBar - never placed here.
--   * Soulshards are inventory items, not spells - no slot.
--   * Curses go in OPie M4 ring (5 curses: Weakness/Recklessness/Tongues/Elements/Shadow)
--     - frequent-toggle but contextual choice, ring is cleaner than 5 bar slots.
--   * Pet summons + stones go in OPie M5 ring (slow OOC utility).
--
-- OPie rings:
--   M4 = Curses
--   M5 = Pet summons + Soulstone/Healthstone create

local LAYOUT = {
    -- MAIN TOP (Bar 1) - INSTANTS only on numrow. DoTs get nuke-mouseover so
    -- you can apply them to mouseover targets while staying engaged with current.
    {"Corruption",             1, 2, "nuke-mouseover"},   -- L4    1   (instant DoT 18s; spread freely)
    {"Curse of Agony",         1, 3, "nuke-mouseover"},   -- L8    2   (24s ramping DoT; spread for sustained pulls)
    {"Curse of Doom",          1, 4, "nuke-mouseover"},   -- L60+  3   (1min CD heavy DoT; boss/elite)
    {"Death Coil",             1, 5},                     -- TBC L42 4 (instant; 3s horror + self-heal)
    -- 5 left empty (placeholder)
    -- QERT row: utility / panic / drains
    {"Drain Life",             1, 8},                     -- L14   Q   (channel; emergency self-heal via damage)
    {"Drain Soul",             1, 10},                    -- L24   E   (channel; soulshard farming)
    {"Howl of Terror",         1, 11},                    -- L40   R   (instant AoE fear; panic)
    {"Banish",                 1, 12, "mouseover-harm"},  -- L26   T   (8s CC vs Demon/Elemental; cast)

    -- MAIN BOTTOM (Bar 3) - F/G armor toggle, ZXCVB combat utility
    {"Demon Armor",            3, 5},                     -- L28   F   (default armor; right-aligned)
    {"Fel Armor",              3, 6},                     -- TBC L62 G (Demonology variant; spell power)
    -- ZXCVB row: combat instants + utility
    {"Soul Fire",              3, 8},                     -- L48   Z   (6s cast nuke - heavy damage; OK on bottom row since cast)
    {"Conflagrate",            3, 9},                     -- L20 Destro X (instant burst; consumes Immolate)
    {"Shadowburn",             3, 10},                    -- L20 Destro C (instant execute-style)
    {"Shadowfury",             3, 11},                    -- TBC L60+ V (instant AoE stun)
    {"Life Tap",               3, 12, "self-cast"},       -- L6    B   (HP -> mana; high-frequency)

    -- ALT TOP (Bar 4) - CAST-TIME damage on numrow, heals/utility on Alt-QERT
    {"Shadow Bolt",            4, 2, "nuke-mouseover"},   -- L1    Alt-1 (primary cast nuke; mouseover lets you nuke add while DoT ticks on main)
    {"Immolate",               4, 3, "nuke-mouseover"},   -- L1    Alt-2 (cast DoT - 1.5s cast, 15s DoT; spread-friendly)
    {"Searing Pain",           4, 4, "nuke-mouseover"},   -- L18   Alt-3 (cast nuke + threat; tank-like for Voidwalker pulls)
    {"Hellfire",               4, 5, "self-cast"},        -- L20   Alt-4 (channel AoE; self-damage, anchor on player)
    {"Rain of Fire",           4, 6},                     -- L20   Alt-5 (ground-targeted AoE channel)
    -- Alt-QERT: utility - rez/buffs/dispels (Warlock has no friend heals)
    {"Health Funnel",          4, 8, "self-cast"},        -- L8    Alt-Q (channel - heal active pet)
    {"Unending Breath",        4, 10, "mouseover-help"},  -- L16   Alt-E (water breathing buff)
    {"Detect Lesser Invisibility", 4, 11, "self-cast"},   -- L26   Alt-R (low-use; could move)
    {"Eye of Kilrogg",         4, 12, "self-cast"},       -- L22   Alt-T (scout familiar)

    -- ALT BOTTOM (Bar 5) - defensives + stone usage
    {"Soulshatter",            5, 5, "self-cast"},        -- TBC L62 Alt-F (drop threat - high-value defensive)
    {"Curse of Exhaustion",    5, 6, "mouseover-harm"},   -- L36 Affl Alt-G (snare debuff; Affl talent)
    -- Alt-ZXCVB: panic + escapes
    {"Fear",                   5, 7, "mouseover-harm"},   -- L8    (single-target fear; Alt-Z = mount)
    {"Mortal Coil",            5, 9, "self-cast"},        -- (Soul Link talent? skip if absent)
    {"Enslave Demon",          5, 10, "mouseover-harm"},  -- L30   Alt-C (channel; control demon)
    {"Sense Demons",           5, 11, "self-cast"},       -- L20   Alt-V (tracking; low-use)
    -- B left empty (placeholder for racial)
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Cloth"]=true, ["Daggers"]=true, ["One-Handed Swords"]=true,
    ["Staves"]=true, ["Wands"]=true, ["Shoot Wand"]=true,
    -- Warlock talent passives (no slot needed)
    ["Suppression"]=true, ["Improved Corruption"]=true, ["Improved Curse of Agony"]=true,
    ["Improved Drain Soul"]=true, ["Improved Life Tap"]=true, ["Soul Siphon"]=true,
    ["Shadow Mastery"]=true, ["Contagion"]=true, ["Eradication"]=true,
    ["Nightfall"]=true, ["Pandemic"]=true, ["Death's Embrace"]=true,
    ["Improved Imp"]=true, ["Demonic Embrace"]=true, ["Improved Health Funnel"]=true,
    ["Demonic Brutality"]=true, ["Fel Vitality"]=true, ["Improved Voidwalker"]=true,
    ["Master Summoner"]=true, ["Mana Feed"]=true, ["Master Demonologist"]=true,
    ["Demonic Tactics"]=true, ["Demonic Resilience"]=true, ["Soul Link"]=true,
    ["Improved Shadow Bolt"]=true, ["Cataclysm"]=true, ["Bane"]=true,
    ["Aftermath"]=true, ["Improved Firestone"]=true, ["Improved Searing Pain"]=true,
    ["Improved Immolate"]=true, ["Devastation"]=true, ["Pyroclasm"]=true,
    ["Emberstorm"]=true, ["Backlash"]=true, ["Improved Fire Bolt"]=true,
    ["Empowered Imp"]=true,
    -- Curses - handled by OPie ring (M4)
    ["Curse of Weakness"]=true, ["Curse of Recklessness"]=true,
    ["Curse of Tongues"]=true, ["Curse of the Elements"]=true,
    ["Curse of Shadow"]=true,
    -- Pet summons + stones - handled by OPie ring (M5)
    ["Summon Imp"]=true, ["Summon Voidwalker"]=true, ["Summon Succubus"]=true,
    ["Summon Felhunter"]=true, ["Summon Felguard"]=true,
    ["Summon Infernal"]=true, ["Summon Doomguard"]=true,
    ["Create Healthstone"]=true, ["Create Soulstone"]=true,
    ["Create Spellstone"]=true, ["Create Firestone"]=true,
    ["Soulstone"]=true,                                   -- using a soulstone is via item right-click
    -- Race passives
    ["Stoneform"]=true, ["Find Treasure"]=true, ["Frost Resistance"]=true,
    ["Touch of Elune"]=true, ["Wisp Spirit"]=true, ["Quickness"]=true,
    ["Nature Resistance"]=true, ["Heroic Presence"]=true, ["Shadow Resistance"]=true,
    ["Hardiness"]=true, ["Command"]=true, ["Endurance"]=true,
    ["Da Voodoo Shuffle"]=true, ["Regeneration"]=true,
    ["Underwater Breathing"]=true, ["Cannibalize"]=true,
    ["Magic Resistance"]=true, ["Touch of Weakness"]=true, ["Devouring Plague"]=true,
    -- Race actives auto-placed via RACIALS table; rest IGNORE since alt-row is full
    ["Blood Fury"]=true, ["Berserking"]=true,
    ["Shadowmeld"]=true, ["Escape Artist"]=true, ["Will of the Forsaken"]=true,
    ["Gift of the Naaru"]=true, ["Mana Tap"]=true, ["Arcane Torrent"]=true,
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Mining"]=true, ["Smelting"]=true, ["Herbalism"]=true, ["Skinning"]=true,
    ["Fishing"]=true, ["Enchanting"]=true, ["Disenchant"]=true,
    ["Alchemy"]=true, ["Tailoring"]=true, ["Leatherworking"]=true,
    ["Engineering"]=true, ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true, ["Gemcutting"]=true,
    -- Misc
    ["Ritual of Summoning"]=true, ["Ritual of Souls"]=true,
}

-- Per-race racial placement (per docs/racials.md)
local RACIALS = {
    Orc = {
        {"Blood Fury", 5, 12, "self-cast"},  -- Alt-B: damage CD slot
    },
    Troll = {
        {"Berserking", 5, 12, "self-cast"},  -- Alt-B: damage CD slot
    },
    Undead = {
        {"Will of the Forsaken", 5, 12, "self-cast"},  -- Alt-B: defensive break
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},            -- C is taken (Shadowburn) - skip if conflict
    },
    Gnome = {
        {"Escape Artist", 5, 12, "self-cast"},  -- Alt-B: defensive
    },
    Human = {},  -- no combat racial
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("WarlockSetup", placed, skipped, orphans)
    print("|cffffd700WarlockSetup tip:|r DoTs (Corruption/CoA/Immolate) all use mouseover -")
    print("|cff999999  hover an add and press 1/2/Alt-2 to spread without losing main target.|r")
    print("|cff999999  Curses: hold M4 (OPie ring). Pet summons + stones: hold M5.|r")
    print("|cff999999  Pet abilities (Firebolt, Spell Lock, etc.) live on Blizzard PetActionBar.|r")
end

SetupCore:RegisterClass("WARLOCK", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration
-- ===========================================================================
do
    local _, class = UnitClass("player")
    if class ~= "WARLOCK" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Curses ring (M4 hold) - 5 mutually-contextual curses.
    R:AddDefaultRing("WarlockCurses", {
        {id="/cast {{spell:980}}",   _u="ag"}, -- Curse of Agony
        {id="/cast {{spell:702}}",   _u="wk"}, -- Curse of Weakness
        {id="/cast {{spell:1490}}",  _u="el"}, -- Curse of the Elements
        {id="/cast {{spell:17862}}", _u="sh"}, -- Curse of Shadow
        {id="/cast {{spell:704}}",   _u="rk"}, -- Curse of Recklessness
        {id="/cast {{spell:1714}}",  _u="tg"}, -- Curse of Tongues
        {id="/cast {{spell:603}}",   _u="dm"}, -- Curse of Doom
        name = "Curses", hotkey = "BUTTON4", _u = "WlkCrs", v = 1,
    })

    -- Pet summons + stones ring (M5 hold) - slow OOC utility.
    R:AddDefaultRing("WarlockPet", {
        {id="/cast {{spell:688}}",   _u="im"}, -- Summon Imp
        {id="/cast {{spell:697}}",   _u="vw"}, -- Summon Voidwalker
        {id="/cast {{spell:712}}",   _u="sc"}, -- Summon Succubus
        {id="/cast {{spell:691}}",   _u="fh"}, -- Summon Felhunter
        {id="/cast {{spell:30146}}", _u="fg"}, -- Summon Felguard (TBC Demonology)
        {id="/cast {{spell:6201}}",  _u="hs"}, -- Create Healthstone
        {id="/cast {{spell:693}}",   _u="ss"}, -- Create Soulstone
        {id="/cast {{spell:1122}}",  _u="if"}, -- Summon Infernal
        {id="/cast {{spell:18540}}", _u="dg"}, -- Summon Doomguard
        name = "Pet & Stones", hotkey = "BUTTON5", _u = "WlkPet", v = 1,
    })
end
