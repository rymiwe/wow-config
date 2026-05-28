-- Edit LAYOUT below as you train new spells, then /reload + /setupbars in-game.
-- Format: {spellName, bar, button[, macroTemplate]}
--   See SetupCore.lua for the list of available macroTemplate names.
--
-- BAR LAYOUT (post-OPie-migration):
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, F, G, _ / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1) — Alt-`, Alt-1..5 / _, Alt-Q, _, Alt-E, Alt-R, Alt-T
--   Bar 5 = ALT BOTTOM (mirror of Bar 3) — _, _, _, Alt-F, Alt-G, _ / _, Alt-Z, Alt-X, Alt-C, Alt-V, Alt-B
--   Bar 6 = UTILITY (12 buttons, click only, NOT cleared by /setupbars; drag your professions/mounts/hearth/etc here)
--   Bar 7 = DISABLED (was special bar; M3 unbound)
--   Bar 9 = DISABLED (was totem-swap; OPie totem ring replaces it)
--
-- Totems and weapon enchants live in OPie rings (M4 = Totems, M5 = Weapon Enchants).
-- See bottom of file for ring registration.

local LAYOUT = {
    -- MAIN TOP (Bar 1) ============================================
    -- Number row: shocks + utility
    {"Earth Shock",            1, 1},                     -- L4    `   (also primary interrupt)
    {"Flame Shock",            1, 2, "nuke-mouseover"},   -- L10   1   (instant DoT — mouseover spreads to adds while staying engaged with main target)
    {"Frost Shock",            1, 3},                     -- L12   2
    {"Far Sight",              1, 4},                     -- L18   3
    {"Astral Recall",          1, 5},                     -- L30   4
    -- QERT row (Q/E/R/T): Q + E populated by totem-set /castsequence macros in Run()
    --   Q = melee party set (SoE → Searing → Mana Spring → Windfury)
    --   E = caster party set (Stoneskin → Flametongue → Mana Spring → Wrath of Air)
    {"Stormstrike",            1, 11},                     -- R   Enhancement nuke (skipped until trained)
    {"Shamanistic Rage",       1, 12},                     -- T   Enhancement CD (skipped until talented)
    -- OPie M4 holds individual totems

    -- MAIN BOTTOM (Bar 3) ==========================================
    -- FG row: buffs (G empty after Gift of the Naaru moved to Alt-G)
    {"Lightning Shield",       3, 5},                     -- L8    F   (right-aligned)
    -- ZXCVB row: weapon enchants moved to OPie (M5); Ghost Wolf promoted from Alt-F (now instant via talent)
    {"Ghost Wolf",             3, 8},                     -- L16   Z   (instant via Improved Ghost Wolf talent)
    {"Totemic Call",           3, 9},                     -- X     recall all totems
    -- C/V/B left empty — startattack template + right-click cover auto-attack

    -- ALT TOP (Bar 4) ==============================================
    -- Alt-numrow: damage casts
    {"Lightning Bolt",         4, 2, "nuke-mouseover"},   -- L1    Alt-1 (cast nuke — mouseover supports kiting / target-swap playstyle)
    {"Chain Lightning",        4, 3},                     -- L32   Alt-2
    {"Water Shield",           4, 4},                     -- L20   Alt-3  (self-buff; raw spell)
    -- Alt-4 left empty
    {"Ancestral Spirit",       4, 6, "mouseover-help"},   -- L12   Alt-5 (OOC rez - demoted off heal cluster, low-frequency)
    -- Alt-QERT: combat heals (mouseover-friendly), promoted by frequency
    {"Healing Wave",           4, 8, "mouseover-help"},   -- L6    Alt-Q (main slow heal)
    {"Lesser Healing Wave",    4, 10, "mouseover-help"},  -- L20   Alt-E (promoted from Alt-R - fast emergency heal next to main heal)
    {"Chain Heal",             4, 11, "mouseover-help"},  -- L40   Alt-R (promoted from Alt-T - group heal)
    -- Alt-T left empty

    -- ALT BOTTOM (Bar 5) ===========================================
    -- Alt-FG: utility (Alt-F empty after Tremor → OPie + Ghost Wolf → Z;
    -- Alt-G now claimed by Draenei racial Gift of the Naaru via RACIALS table below)
    -- Alt-ZXCVB: travel + dispels (mouseover-friendly)
    {"Water Breathing",        5, 8},                     -- L24   Alt-Z
    {"Water Walking",          5, 9},                     -- L28   Alt-X
    {"Cure Disease",           5, 10, "mouseover-help"},  -- L18   Alt-C
    {"Cure Poison",            5, 11, "mouseover-help"},  -- L14   Alt-V
    {"Purge",                  5, 12, "mouseover-harm"},  -- L10   Alt-B
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
}

-- Obsolete totem profile macros (truncated-name duplicates + pre-ring-rename leftovers).
-- Deleted automatically at the start of /setupbars to stay within the 18 char macro cap.
local OBSOLETE_MACROS = {
    "SC_TotemAoE",
    "SC_TotemMeleeGro",
    "SC_TotemMeleeSol",
    "SC_TotemCasterGr",
    "SC_TotemCasterSo",
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

-- Default totem sets — placed AFTER ApplyLayout so they survive the bar clear.
-- /castsequence drops one totem per press, advancing through the list.
-- Resets out of combat or after 15s of inactivity (whichever first).
-- #showtooltip with no arg dynamically shows the next-to-cast totem icon.
--
-- Q/E keep two primary profiles for fast spam. Alt+M4 ring uses inline OPie macro
-- bodies (no extra named macros — saves precious macro slots).
-- Basic melee: Strength of Earth + Searing + Healing Stream + Windfury (group survival focused)
-- Basic caster: Stoneskin + Flametongue + Healing Stream + Wrath of Air
-- AoE — Nova (L14+, works while leveling): Stoneclaw → Searing → Fire Nova → HS
-- AoE — Magma (L40+ sustained cleave): Stoneclaw → Magma → HS → Windfury
local TOTEM_AOE_NOVA_BODY = "#showtooltip\n/castsequence reset=combat/15 Stoneclaw Totem, Searing Totem, Fire Nova Totem, Healing Stream Totem"
local TOTEM_AOE_MAGMA_BODY = "#showtooltip\n/castsequence reset=combat/15 Stoneclaw Totem, Magma Totem, Healing Stream Totem, Windfury Totem"

local TOTEM_MELEE_BODY = "#showtooltip\n/castsequence reset=combat/15 Strength of Earth Totem, Searing Totem, Healing Stream Totem, Windfury Totem"
local TOTEM_CASTER_BODY = "#showtooltip\n/castsequence reset=combat/15 Stoneskin Totem, Flametongue Totem, Healing Stream Totem, Wrath of Air Totem"
local TOTEM_MELEE_GROUP_BODY = TOTEM_MELEE_BODY
local TOTEM_CASTER_GROUP_BODY = TOTEM_CASTER_BODY

-- Solo versions: use weapon imbue instead of Windfury Totem (stronger when alone, doesn't stack)
local TOTEM_MELEE_SOLO_BODY = "#showtooltip\n/castsequence reset=combat/15 Strength of Earth Totem, Searing Totem, Healing Stream Totem, Windfury Weapon"
local TOTEM_CASTER_SOLO_BODY = "#showtooltip\n/castsequence reset=combat/15 Stoneskin Totem, Flametongue Totem, Healing Stream Totem"  -- no strong solo equivalent for last slot

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

    -- Totem-set macros on Q/E (temporary until ring workflow replaces them).
    local _, _, meleeIcon = GetSpellInfo("Strength of Earth Totem")
    SetupCore:EnsureRawMacro("SC_TotemMelee", TOTEM_MELEE_BODY, meleeIcon)
    if SetupCore:PlaceMacro("SC_TotemMelee", 1, 8) then placed = placed + 1 end

    local _, _, casterIcon = GetSpellInfo("Stoneskin Totem")
    SetupCore:EnsureRawMacro("SC_TotemCaster", TOTEM_CASTER_BODY, casterIcon)
    if SetupCore:PlaceMacro("SC_TotemCaster", 1, 10) then placed = placed + 1 end

    -- M3 decurse: mouseover poison/disease on friends, Purge on enemies.
    SetupCore:EnsureDecurseMacro("decurse-shaman", "Cure Poison")
    SetupCore:ApplyMacroBindings()

    SetupCore:PrintResults("ShamanSetup", placed, skipped, orphans)
    print("|cffffd700ShamanSetup tip:|r Q = Melee Group, E = Caster Group (both use Windfury Totem).")
    print("|cff999999  Middle-click (M3) = decurse mouseover (Cure Poison/Disease or Purge).|r")
    print("|cff999999  Alt + M4: Totem Profiles ring — pick a set, then spam Alt + M4 to drop all four totems.|r")
    print("|cff999999  M4 / M5: individual totems / weapon enchants.|r")
end

SetupCore:RegisterClass("SHAMAN", Run, LAYOUT, {ignore = IGNORE, racials = RACIALS})
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

    -- Totem Profile ring (Alt+M4). Inline macro bodies = zero extra named macros.
    R:AddDefaultRing("ShamanTotemProfiles", {
        {id = TOTEM_MELEE_GROUP_BODY,  label = "Melee - Group",  icon = "Interface/Icons/INV_Axe_09",              _u = "mg"},
        {id = TOTEM_MELEE_SOLO_BODY,   label = "Melee - Solo",   icon = "Interface/Icons/INV_Sword_27",            _u = "ms"},
        {id = TOTEM_CASTER_GROUP_BODY, label = "Caster - Group", icon = "Interface/Icons/Spell_Nature_StarFall",   _u = "cg"},
        {id = TOTEM_CASTER_SOLO_BODY,  label = "Caster - Solo",  icon = "Interface/Icons/Spell_Fire_Fireball02",   _u = "cs"},
        {id = TOTEM_AOE_NOVA_BODY,     label = "AoE - Nova",     icon = "Interface/Icons/Spell_Fire_SealOfFire",   _u = "an"},
        {id = TOTEM_AOE_MAGMA_BODY,    label = "AoE - Magma",    icon = "Interface/Icons/Spell_Fire_SelfDestruct", _u = "am"},
        name = "Totem Profiles", hotkey = "ALT-BUTTON4", _u = "ShmTtmProf", v = 4,
    })

    -- Quick action at ring center: select a profile once, then spam Alt+M4 for the
    -- full 4-totem castsequence without reopening the radial menu.
    -- Also seed ring bindings so M4/M5/Alt+M4 work with zero manual /opie config.
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
        if binds["ShamanTotemProfiles"] == nil then
            binds["ShamanTotemProfiles"] = "ALT-BUTTON4"
        end
        profile.RingOptions = profile.RingOptions or {}
        local ringOpts = profile.RingOptions
        local prefix = "ShamanTotemProfiles#"
        if ringOpts[prefix .. "CenterAction"] == nil then
            ringOpts[prefix .. "CenterAction"] = true
        end
        if ringOpts[prefix .. "QuickActionOnRelease"] == nil then
            ringOpts[prefix .. "QuickActionOnRelease"] = true
        end
    end

    print("|cff00ff00ShamanSetup|r: Registered ShamanTotemProfiles ring on ALT-BUTTON4")

end
