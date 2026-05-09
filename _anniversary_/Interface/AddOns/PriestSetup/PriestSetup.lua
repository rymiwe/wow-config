-- PriestSetup: heal-leaning generalist (Holy/Disc primary, Shadow via untrained-skip).
-- Friend-group default since Priest is most-asked-for as a group healer.
-- Solo-leveling Shadow priests still get their kit (SW:P, Mind Blast, Mind Flay)
-- and can promote those off Alt-bar manually.
--
-- BAR LAYOUT (matches other classes; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (`, 1-5 / Q E R T)
--   Bar 3 = MAIN BOTTOM (F G / Z X C V B)
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--
-- Priest-specific notes:
--   * No baseline interrupt - ` left empty (Priest's "interrupt" is Silence which
--     is Shadow-talented; if specced, drag manually to `).
--   * QERT row dedicated to instant heals (PW:Shield, Renew, Flash Heal, Greater Heal).
--   * Shadow Word: Pain on numrow with nuke-mouseover (spread-friendly DoT).
--   * Shackle Undead with focus-mouseover-harm (focus IS the undead CC target).
--   * Buffs (Fortitude / Inner Fire / Divine Spirit / Shadow Protection / Prayers /
--     Fear Ward) on OPie M4 - lots of variants, contextual.
--
-- OPie rings:
--   M4 = Buffs (PW:Fort, Inner Fire, Divine Spirit, Shadow Protection, Prayers, Fear Ward)
--   M5 = Out-of-combat utility (Mind Vision, Mind Soothe, Levitate, Inner Focus)

local LAYOUT = {
    -- MAIN TOP (Bar 1) - INSTANTS on numrow. Mind Blast on key 1 (Shadow opener).
    {"Mind Blast",             1, 2, "nuke-mouseover"},   -- L10   1   (instant burst; Shadow opener / Holy filler)
    {"Shadow Word: Pain",      1, 3, "nuke-mouseover"},   -- L4    2   (instant DoT - spread freely)
    {"Holy Fire",              1, 4, "nuke-mouseover"},   -- L20 Holy 3 (cast DoT - on instant row by frequency)
    {"Devouring Plague",       1, 5, "nuke-mouseover"},   -- Forsaken racial 4 (instant DoT - if Undead)
    {"Psychic Scream",         1, 6, "self-cast"},        -- L14   5   (instant AoE fear; emergency)
    -- QERT row: INSTANT heals (mouseover-help)
    {"Power Word: Shield",     1, 8, "mouseover-help"},   -- L6    Q   (instant absorb shield)
    {"Renew",                  1, 10, "mouseover-help"},  -- L8    E   (instant HoT)
    {"Flash Heal",             1, 11, "mouseover-help"},  -- L20   R   (fast cast big heal)
    {"Greater Heal",           1, 12, "mouseover-help"},  -- L40   T   (slow cast heavy heal)

    -- MAIN BOTTOM (Bar 3) - F/G self-buffs, ZXCVB defensives + utility
    {"Inner Fire",             3, 5, "self-cast"},        -- L12   F   (armor + spell power buff; right-aligned)
    {"Power Word: Fortitude",  3, 6, "mouseover-help"},   -- L1    G   (HP buff; mouseover any friend)
    -- ZXCVB row: defensives + utility instants
    {"Fade",                   3, 8, "self-cast"},        -- L8    Z   (drop threat - high-frequency)
    {"Vampiric Embrace",       3, 9, "self-cast"},        -- L32 Shadow X (Shadow self-buff)
    {"Shadowfiend",            3, 10, "self-cast"},       -- TBC L66 C (mana CD)
    {"Mind Soothe",            3, 11, "mouseover-harm"},  -- L20   V   (calm humanoid - non-damaging)
    {"Levitate",               3, 12, "mouseover-help"},  -- L20   B   (slow fall buff)

    -- ALT TOP (Bar 4) - CAST-TIME damage on numrow, group heals on Alt-QERT
    {"Smite",                  4, 2, "nuke-mouseover"},   -- L1    Alt-1 (Holy cast nuke)
    {"Mind Flay",              4, 3},                     -- L20 Shadow Alt-2 (channel - mouseover doesn't help on channels)
    {"Vampiric Touch",         4, 4, "nuke-mouseover"},   -- TBC L40 Shadow Alt-3 (cast DoT)
    {"Holy Nova",              4, 5},                     -- L20 Holy Alt-4 (instant PBAoE damage + heal)
    {"Heal",                   4, 6, "mouseover-help"},   -- L4    Alt-5 (mid-tier cast heal)
    -- Alt-QERT: group heals + rez + utility
    {"Resurrection",           4, 8, "mouseover-help"},   -- L10   Alt-Q (OOC rez)
    {"Prayer of Healing",      4, 10, "mouseover-help"},  -- L30 Holy Alt-E (group cast heal)
    {"Binding Heal",           4, 11, "mouseover-help"},  -- TBC L64 Alt-R (instant + self-heal)
    {"Prayer of Mending",      4, 12, "mouseover-help"},  -- TBC L68 Alt-T (PoM bouncing heal)

    -- ALT BOTTOM (Bar 5) - dispels + defensives + niche
    {"Dispel Magic",           5, 5, "mouseover-help"},   -- L18   Alt-F (dispel from friend - mouseover-help)
    {"Cure Disease",           5, 6, "mouseover-help"},   -- L14   Alt-G (cure disease)
    -- Alt-ZXCVB: rez + cooldowns + niche CC
    {"Abolish Disease",        5, 8, "mouseover-help"},   -- L32   Alt-Z (rolling disease cure - HoT)
    {"Mass Dispel",            5, 9},                     -- TBC L60 Alt-X (channel mass dispel)
    {"Pain Suppression",       5, 10, "mouseover-help"},  -- TBC Disc Alt-C (50% damage reduction CD)
    {"Shackle Undead",         5, 11, "focus-mouseover-harm"}, -- L20 Alt-V (CC vs undead - focus-first)
    {"Mind Control",           5, 12, "mouseover-harm"},  -- L30   Alt-B (channel CC humanoid)
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Cloth"]=true, ["Daggers"]=true, ["One-Handed Maces"]=true,
    ["Staves"]=true, ["Wands"]=true, ["Shoot Wand"]=true,
    -- Priest talent passives (no slot needed)
    ["Spirit Tap"]=true, ["Improved Power Word: Fortitude"]=true,
    ["Improved Power Word: Shield"]=true, ["Mental Strength"]=true,
    ["Mental Agility"]=true, ["Improved Inner Fire"]=true, ["Wand Specialization"]=true,
    ["Meditation"]=true, ["Reflective Shield"]=true, ["Absolution"]=true,
    ["Divine Spirit"]=true,                               -- handled in OPie buffs ring
    ["Improved Healing"]=true, ["Healing Focus"]=true, ["Improved Renew"]=true,
    ["Holy Specialization"]=true, ["Improved Lay on Hands"]=true,
    ["Holy Reach"]=true, ["Searing Light"]=true, ["Healing Prayers"]=true,
    ["Improved Healing"]=true, ["Spiritual Healing"]=true, ["Inspiration"]=true,
    ["Divine Fury"]=true, ["Holy Concentration"]=true, ["Lightwell"]=true,
    ["Empowered Healing"]=true,
    ["Spiritual Guidance"]=true, ["Surge of Light"]=true,
    ["Blackout"]=true, ["Improved Shadow Word: Pain"]=true, ["Shadow Affinity"]=true,
    ["Improved Psychic Scream"]=true, ["Improved Mind Blast"]=true,
    ["Shadow Focus"]=true, ["Improved Fade"]=true, ["Shadow Reach"]=true,
    ["Shadow Weaving"]=true, ["Silent Resolve"]=true, ["Improved Vampiric Embrace"]=true,
    ["Focused Mind"]=true, ["Darkness"]=true, ["Shadow Power"]=true,
    ["Misery"]=true, ["Vampiric Touch"]=true,             -- placed in LAYOUT
    -- Buffs handled by OPie ring (M4)
    ["Prayer of Fortitude"]=true, ["Prayer of Spirit"]=true,
    ["Prayer of Shadow Protection"]=true, ["Shadow Protection"]=true,
    ["Fear Ward"]=true,
    -- OOC utility handled by OPie ring (M5)
    ["Mind Vision"]=true, ["Inner Focus"]=true,
    -- Race passives
    ["Stoneform"]=true, ["Find Treasure"]=true, ["Frost Resistance"]=true,
    ["Touch of Elune"]=true, ["Wisp Spirit"]=true, ["Quickness"]=true,
    ["Nature Resistance"]=true, ["Heroic Presence"]=true, ["Shadow Resistance"]=true,
    ["Hardiness"]=true, ["Endurance"]=true, ["Cultivation"]=true,
    ["Magic Resistance"]=true, ["Expansive Mind"]=true,
    ["Underwater Breathing"]=true, ["Da Voodoo Shuffle"]=true,
    ["Regeneration"]=true, ["The Human Spirit"]=true, ["Diplomacy"]=true,
    ["Perception"]=true, ["Mace Specialization"]=true,
    -- Race actives - placed via RACIALS or IGNORE
    ["Blood Fury"]=true, ["Berserking"]=true, ["War Stomp"]=true,
    ["Shadowmeld"]=true, ["Will of the Forsaken"]=true, ["Cannibalize"]=true,
    ["Mana Tap"]=true, ["Arcane Torrent"]=true, ["Gift of the Naaru"]=true,
    ["Touch of Weakness"]=true,                           -- Forsaken passive-ish
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Mining"]=true, ["Smelting"]=true, ["Herbalism"]=true, ["Skinning"]=true,
    ["Fishing"]=true, ["Enchanting"]=true, ["Disenchant"]=true,
    ["Alchemy"]=true, ["Tailoring"]=true, ["Leatherworking"]=true,
    ["Engineering"]=true, ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true, ["Gemcutting"]=true,
}

local RACIALS = {
    Draenei = {
        {"Gift of the Naaru", 5, 6, "mouseover-help"},  -- Alt-G heal slot (Cure Disease conflict - bumps it manually)
    },
    Dwarf = {
        {"Stoneform", 5, 12, "self-cast"},              -- Alt-B defensive
    },
    Human = {},
    NightElf = {
        {"Shadowmeld", 5, 12, "self-cast"},
    },
    Undead = {
        {"Will of the Forsaken", 5, 12, "self-cast"},
    },
    Troll = {
        {"Berserking", 5, 12, "self-cast"},
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},  -- C is taken (Shadowfiend) - conflict; user resolves
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("PriestSetup", placed, skipped, orphans)
    print("|cffffd700PriestSetup tip:|r heals on QERT (PW:Shield/Renew/Flash/Greater) all")
    print("|cff999999  use mouseover - hover party member to heal them.|r")
    print("|cff999999  SW:Pain spreads via mouseover too - DoT adds while Mind Blast hits main.|r")
    print("|cff999999  Buffs: hold M4 (OPie ring). OOC utility: hold M5.|r")
end

SetupCore:RegisterClass("PRIEST", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration
-- ===========================================================================
do
    local _, class = UnitClass("player")
    if class ~= "PRIEST" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Buffs ring (M4 hold) - all the buff variants in one place.
    R:AddDefaultRing("PriestBuffs", {
        {id="/cast {{spell:1243}}",  _u="fo"}, -- Power Word: Fortitude
        {id="/cast {{spell:21562}}", _u="pf"}, -- Prayer of Fortitude
        {id="/cast {{spell:14752}}", _u="ds"}, -- Divine Spirit
        {id="/cast {{spell:27681}}", _u="ps"}, -- Prayer of Spirit (TBC)
        {id="/cast {{spell:976}}",   _u="sp"}, -- Shadow Protection
        {id="/cast {{spell:27683}}", _u="px"}, -- Prayer of Shadow Protection
        {id="/cast {{spell:6346}}",  _u="fw"}, -- Fear Ward
        {id="/cast {{spell:588}}",   _u="if"}, -- Inner Fire
        name = "Buffs", hotkey = "BUTTON4", _u = "PrBuf", v = 1,
    })

    -- OOC utility ring (M5 hold) - low-frequency utility that doesn't earn bar slots.
    R:AddDefaultRing("PriestUtility", {
        {id="/cast {{spell:2096}}",  _u="mv"}, -- Mind Vision
        {id="/cast {{spell:14751}}", _u="ix"}, -- Inner Focus
        {id="/cast {{spell:8129}}",  _u="mb"}, -- Mana Burn (vs casters)
        name = "Utility", hotkey = "BUTTON5", _u = "PrUtl", v = 1,
    })
end
