-- Edit LAYOUT below as you train new spells, then /reload + /setupbars in-game.
-- Format: {spellName, bar, button[, macroTemplate]}
--   See SetupCore.lua for the list of available macroTemplate names.
--
-- BAR LAYOUT:
--   Bar 1 = MAIN TOP — ` 1 2 3 4 / Q E R T  (3/4 = bound placeholders, no spells)
--   Bar 3 = MAIN BOTTOM — F G / Z X C V B  (F = TT Cast totem drop via TotemTimers)
--   Bar 4 = ALT — numrow heals (Alt-1/2/3), home row casts (Alt-Q/E/R)
--   Bar 5 = ALT BOTTOM — Alt-F/G racials; Alt-Z/X placeholders; Alt-C/V/B placeholders (M3 decurse)
--   Bar 6 = UTILITY (click): water travel, far sight, recall, rez — seeded, never wiped
--   Bar 7 = CONSUMABLES (click): food/pots/bandages — user fills, never wiped
--
-- Totems: TotemTimers + OPie M4 individual casts. Weapon enchants: OPie M5.

local LAYOUT = {
    -- MAIN TOP (Bar 1) ============================================
    {"Earth Shock",            1, 1},                     -- L4    `   interrupt
    {"Flame Shock",            1, 2, "nuke-mouseover"},   -- L10   1
    {"Frost Shock",            1, 3},                     -- L12   2
    -- 3/4 = keybound placeholders only (travel spells on utility bar 6)
    {"Stormstrike",            1, 8, "startattack"},     -- Q   Enh nuke (skipped until trained)
    {"Lightning Shield",       1, 10},                    -- E   instant self-buff refresh
    {"Shamanistic Rage",       1, 12},                    -- T   Enh CD (skipped until talented)

    -- MAIN BOTTOM (Bar 3) ==========================================
    -- F = TT Cast (post-layout); G = racial on Draenei
    {"Ghost Wolf",             3, 8},                     -- Z (also forced by SetupCore travel slots)
    {"Totemic Call",           3, 9},                     -- X

    -- ALT TOP (Bar 4) — heals on numrow, damage on Q/E/R home row ========
    {"Healing Wave",           4, 2, "mouseover-help"},   -- Alt-1
    {"Lesser Healing Wave",    4, 3, "mouseover-help"},   -- Alt-2
    {"Chain Heal",             4, 4, "mouseover-help"},   -- Alt-3
    -- Alt-4 = racial CD (Orc/Troll via RACIALS); Alt-5 = placeholder
    {"Lightning Bolt",         4, 8, "nuke-mouseover"},   -- Alt-Q
    {"Chain Lightning",        4, 10},                     -- Alt-E
    {"Water Shield",           4, 11},                     -- Alt-R
    -- Alt-T = placeholder
}

-- Click-only bar 6: travel, scouting, recall, rez. Only fills empty slots.
local UTILITY_LAYOUT = {
    {"Water Breathing",        6, 1},
    {"Water Walking",          6, 2},
    {"Far Sight",              6, 3},
    {"Astral Recall",          6, 4},
    {"Ancestral Spirit",       6, 5, "mouseover-help"},
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Mail Specialization"]=true, ["Two-Handed Axes"]=true,
    ["Two-Handed Maces"]=true, ["One-Handed Axes"]=true,
    ["One-Handed Maces"]=true, ["Staves"]=true, ["Daggers"]=true,
    ["Fist Weapons"]=true, ["Shield Block"]=true,
    -- Shaman talent passives (no slot needed)
    ["Convection"]=true, ["Concussion"]=true, ["Reverberation"]=true,
    ["Improved Lightning Bolt"]=true, ["Improved Earth Shock"]=true,
    ["Improved Fire Totems"]=true, ["Shamanistic Focus"]=true,
    ["Mental Quickness"]=true, ["Spirit Weapons"]=true,
    ["Improved Healing Wave"]=true, ["Tidal Mastery"]=true,
    ["Healing Focus"]=true, ["Tidal Focus"]=true,
    ["Improved Reincarnation"]=true,
    ["Dual Wield"]=true, ["Flurry"]=true, ["Elemental Devastation"]=true,
    ["Elemental Weapons"]=true, ["Unleashed Rage"]=true, ["Weapon Mastery"]=true,
    ["Ancestral Knowledge"]=true, ["Enhancing Totems"]=true,
    ["Improved Ghost Wolf"]=true, ["Ghost Wolf Speed"]=true,
    -- Totems / weapon enchants — handled by OPie rings, not bar slots
    ["Stoneskin Totem"]=true, ["Strength of Earth Totem"]=true,
    ["Stoneclaw Totem"]=true, ["Earthbind Totem"]=true,
    ["Searing Totem"]=true, ["Magma Totem"]=true,
    ["Fire Nova Totem"]=true, ["Flametongue Totem"]=true,
    ["Healing Stream Totem"]=true, ["Mana Spring Totem"]=true,
    ["Mana Tide Totem"]=true, ["Disease Cleansing Totem"]=true,
    ["Poison Cleansing Totem"]=true, ["Tremor Totem"]=true,
    ["Grounding Totem"]=true, ["Grace of Air Totem"]=true,
    ["Windfury Totem"]=true, ["Wrath of Air Totem"]=true,
    ["Frost Resistance Totem"]=true, ["Fire Resistance Totem"]=true,
    ["Nature Resistance Totem"]=true, ["Sentry Totem"]=true,
    ["Tranquil Air Totem"]=true, ["Windwall Totem"]=true,
    ["Earth Elemental Totem"]=true, ["Fire Elemental Totem"]=true,
    ["Rockbiter Weapon"]=true, ["Flametongue Weapon"]=true,
    ["Frostbrand Weapon"]=true, ["Windfury Weapon"]=true,
    -- Race passives (Draenei / Tauren / Orc / Troll)
    ["Inspiring Presence"]=true, ["Shadow Resistance"]=true,
    ["Heroic Presence"]=true,
    ["Endurance"]=true, ["Cultivation"]=true, ["Nature Resistance"]=true,
    ["Hardiness"]=true, ["Command"]=true, ["Axe Specialization"]=true,
    ["Da Voodoo Shuffle"]=true, ["Throwing Specialization"]=true,
    ["Bow Specialization"]=true, ["Beast Slaying"]=true,
    ["Regeneration"]=true,
    -- Race actives — auto-placed via RACIALS table per docs/racials.md.
    -- Stoneform left in IGNORE (no Dwarf Shaman in TBC, but harmless).
    ["Stoneform"]=true,
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Gemcutting"]=true, ["Mining"]=true, ["Smelting"]=true,
    ["Herbalism"]=true, ["Skinning"]=true, ["Fishing"]=true,
    ["Enchanting"]=true, ["Disenchant"]=true, ["Alchemy"]=true,
    ["Tailoring"]=true, ["Leatherworking"]=true, ["Engineering"]=true,
    ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    -- Auto-handled
    ["Reincarnation"]=true,
    -- M3 SC_Decurse macro (mouseover poison/disease + Purge)
    ["Cure Disease"]=true, ["Cure Poison"]=true, ["Purge"]=true,
    -- Bar 6 utility clickables (SeedProtectedBar)
    ["Water Breathing"]=true, ["Water Walking"]=true,
    ["Far Sight"]=true, ["Astral Recall"]=true, ["Ancestral Spirit"]=true,
}

-- Legacy totem-profile macro names (removed; TotemTimers handles profiles now).
local OBSOLETE_MACROS = {
    "SC_TotemAoE",
    "SC_TotemMeleeGro",
    "SC_TotemMeleeSol",
    "SC_TotemCasterGr",
    "SC_TotemCasterSo",
    "SC_TotemMelee",
    "SC_TotemCaster",
    "SC_TotemMeleeGroup",
    "SC_TotemMeleeSolo",
    "SC_TotemCasterGroup",
    "SC_TotemCasterSolo",
    "SC_TP_MeleeGrp",
    "SC_TP_MeleeSol",
    "SC_TP_CastGrp",
    "SC_TP_CastSol",
    "SC_TP_AoENova",
    "SC_TP_AoEMagma",
}

-- Per-race racial placement (per docs/racials.md). Untrained racials silently
-- skip. Asog (Draenei) keeps Gift of the Naaru on Alt-G — established convention.
local RACIALS = {
    Draenei = {
        {"Gift of the Naaru", 5, 6, "mouseover-help"},  -- Alt-G: heal slot fallback (Alt-Q heals row full; right-aligned)
    },
    Tauren = {
        {"War Stomp", 3, 10},                           -- C: combat AOE stun
    },
    Orc = {
        {"Blood Fury", 4, 5, "self-cast"},              -- Alt-4: damage CD (joins Alt-numrow with Water Shield/etc.)
    },
    Troll = {
        {"Berserking", 4, 5, "self-cast"},              -- Alt-4: damage CD
    },
}

local function Run()
    local removed = SetupCore:DeleteMacros(OBSOLETE_MACROS)
    if removed > 0 then
        print(string.format("|cff999999ShamanSetup|r removed %d obsolete macro(s) to free slots", removed))
    end

    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)

    SetupCore:SeedProtectedBar(UTILITY_LAYOUT)

    -- M3 decurse: mouseover poison/disease on friends, Purge on enemies.
    SetupCore:RefreshDecurseBinding()

    SetupCore:PrintResults("ShamanSetup", placed, skipped, orphans)
    print("|cffffd700ShamanSetup tip:|r Alt-1/2/3 = heals. Alt-Q/E/R = LB / Chain Lightning / Water Shield.")
    print("|cff999999  F totem drop | M3 decurse | M4 totems (OPie) | M5 enchants. Bar 6=travel/rez, bar 7=consumables.|r")
end

SetupCore:RegisterReservedSlots("SHAMAN", {{3, 5}})
SetupCore:RegisterPostLayout("SHAMAN", function()
    SetupCore:ApplyTotemCastSlot(6)
end)

SetupCore:RegisterClass("SHAMAN", Run, LAYOUT, {
    ignore = IGNORE,
    racials = RACIALS,
})
SetupCore:RegisterDecurseMacro("SC_Decurse", "SHAMAN")

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed.
-- Uses OPie's public API (R:AddDefaultRing). Macro syntax {{spell:ID}} casts
-- the highest known rank, so untrained spells are gracefully skipped/grayed.
-- ===========================================================================
do
    -- Only register rings for actual Shamans. OPie bindings are account-wide,
    -- so registering for non-Shamans creates cross-class M4/M5 collisions
    -- (e.g., WarriorStances would override ShamanWeaponEnchants on M5).
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Element colors (RGB 0-1 floats) — visually groups slices on the radial.
    -- Earth = warm tan, Fire = red-orange, Water = blue, Air = pale cyan.
    local EARTH_R, EARTH_G, EARTH_B = 0.65, 0.45, 0.20
    local FIRE_R,  FIRE_G,  FIRE_B  = 0.95, 0.30, 0.10
    local WATER_R, WATER_G, WATER_B = 0.20, 0.55, 0.95
    local AIR_R,   AIR_G,   AIR_B   = 0.55, 0.85, 1.00

    -- Element-clustered totem ring. Order: Earth → Fire → Water → Air.
    R:AddDefaultRing("ShamanTotems", {
        -- Earth
        {id="/cast {{spell:8071}}",  _u="ss", _r=EARTH_R, _g=EARTH_G, _b=EARTH_B}, -- Stoneskin Totem
        {id="/cast {{spell:8075}}",  _u="se", _r=EARTH_R, _g=EARTH_G, _b=EARTH_B}, -- Strength of Earth Totem
        {id="/cast {{spell:5730}}",  _u="sc", _r=EARTH_R, _g=EARTH_G, _b=EARTH_B}, -- Stoneclaw Totem
        {id="/cast {{spell:2484}}",  _u="eb", _r=EARTH_R, _g=EARTH_G, _b=EARTH_B}, -- Earthbind Totem
        {id="/cast {{spell:8143}}",  _u="tr", _r=EARTH_R, _g=EARTH_G, _b=EARTH_B}, -- Tremor Totem
        -- Fire
        {id="/cast {{spell:3599}}",  _u="sr", _r=FIRE_R,  _g=FIRE_G,  _b=FIRE_B},  -- Searing Totem
        {id="/cast {{spell:8190}}",  _u="mt", _r=FIRE_R,  _g=FIRE_G,  _b=FIRE_B},  -- Magma Totem
        {id="/cast {{spell:1535}}",  _u="fn", _r=FIRE_R,  _g=FIRE_G,  _b=FIRE_B},  -- Fire Nova Totem
        {id="/cast {{spell:8227}}",  _u="ft", _r=FIRE_R,  _g=FIRE_G,  _b=FIRE_B},  -- Flametongue Totem
        -- Water
        {id="/cast {{spell:5394}}",  _u="hs", _r=WATER_R, _g=WATER_G, _b=WATER_B}, -- Healing Stream Totem
        {id="/cast {{spell:5675}}",  _u="ms", _r=WATER_R, _g=WATER_G, _b=WATER_B}, -- Mana Spring Totem
        {id="/cast {{spell:16190}}", _u="mn", _r=WATER_R, _g=WATER_G, _b=WATER_B}, -- Mana Tide Totem (Resto L40)
        {id="/cast {{spell:8170}}",  _u="dc", _r=WATER_R, _g=WATER_G, _b=WATER_B}, -- Disease Cleansing Totem
        {id="/cast {{spell:8166}}",  _u="pc", _r=WATER_R, _g=WATER_G, _b=WATER_B}, -- Poison Cleansing Totem
        -- Air
        {id="/cast {{spell:8177}}",  _u="gr", _r=AIR_R,   _g=AIR_G,   _b=AIR_B},   -- Grounding Totem
        {id="/cast {{spell:8835}}",  _u="ga", _r=AIR_R,   _g=AIR_G,   _b=AIR_B},   -- Grace of Air Totem
        {id="/cast {{spell:8512}}",  _u="wf", _r=AIR_R,   _g=AIR_G,   _b=AIR_B},   -- Windfury Totem
        {id="/cast {{spell:3738}}",  _u="wa", _r=AIR_R,   _g=AIR_G,   _b=AIR_B},   -- Wrath of Air Totem
        name = "Totems", hotkey = "BUTTON4", _u = "ShmTtm", v = 1,
    })

    -- Weapon enhancements ring. 4 slices, simple.
    R:AddDefaultRing("ShamanWeaponEnchants", {
        {id="/cast {{spell:8017}}",  _u="rb"}, -- Rockbiter Weapon
        {id="/cast {{spell:8024}}",  _u="ft"}, -- Flametongue Weapon
        {id="/cast {{spell:8033}}",  _u="fb"}, -- Frostbrand Weapon
        {id="/cast {{spell:8232}}",  _u="wf"}, -- Windfury Weapon
        name = "Weapon Enchants", hotkey = "BUTTON5", _u = "ShmWep", v = 1,
    })

    -- Seed ring bindings so M4/M5 work with zero manual /opie config.
    if OPie_SavedData then
        OPie_SavedData.ProfileStorage = OPie_SavedData.ProfileStorage or {}
        local profile = OPie_SavedData.ProfileStorage.default
        if type(profile) ~= "table" then
            profile = {Bindings = {}, RingOptions = {}}
            OPie_SavedData.ProfileStorage.default = profile
        end
        profile.Bindings = profile.Bindings or {}
        local binds = profile.Bindings
        if binds["ShamanTotems"] == nil then
            binds["ShamanTotems"] = "BUTTON4"
        end
        if binds["ShamanWeaponEnchants"] == nil then
            binds["ShamanWeaponEnchants"] = "BUTTON5"
        end
        binds["ShamanTotemProfiles"] = nil
        if profile.RingOptions then
            profile.RingOptions["ShamanTotemProfiles#CenterAction"] = nil
            profile.RingOptions["ShamanTotemProfiles#QuickActionOnRelease"] = nil
        end
    end

end
