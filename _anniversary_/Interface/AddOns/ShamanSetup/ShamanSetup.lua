-- Edit LAYOUT below as you train new spells, then /reload + /setupbars in-game.
-- Format: {spellName, bar, button[, macroTemplate]}
--   See SetupCore.lua for the list of available macroTemplate names.
--
-- BAR LAYOUT (post-OPie-migration):
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, F, G, _ / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1) — Alt-`, Alt-1..5 / _, Alt-Q, _, Alt-E, Alt-R, Alt-T
--   Bar 5 = ALT BOTTOM (mirror of Bar 3) — _, _, _, Alt-F, Alt-G, _ / _, Alt-Z, Alt-X, Alt-C, Alt-V, Alt-B
--   Bar 7 = DISABLED (was special bar; M3 unbound)
--   Bar 9 = DISABLED (was totem-swap; OPie totem ring replaces it)
--   Bar 10 = CONSUMABLES (click only, NOT cleared by /setupbars)
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
    --   Q = melee party set (SoE → Searing → Healing Stream → Windfury)   [Mana Spring trainable at 26]
    --   E = caster party set (Stoneskin → Flametongue → Mana Spring → Wrath of Air)
    --   R/T left empty for player customization; OPie M4 holds individual totems

    -- MAIN BOTTOM (Bar 3) ==========================================
    -- FG row: buffs (G empty after Gift of the Naaru moved to Alt-G)
    {"Lightning Shield",       3, 5},                     -- L8    F   (right-aligned)
    -- ZXCVB row: weapon enchants moved to OPie (M5); Ghost Wolf promoted from Alt-F (now instant via talent)
    {"Ghost Wolf",             3, 8},                     -- L16   Z   (instant via Improved Ghost Wolf talent)
    -- C/V/B left empty — startattack template + right-click cover auto-attack

    -- ALT TOP (Bar 4) ==============================================
    -- Alt-numrow: damage casts
    {"Lightning Bolt",         4, 2, "nuke-mouseover"},   -- L1    Alt-1 (cast nuke — mouseover supports kiting / target-swap playstyle)
    {"Chain Lightning",        4, 3},                     -- L32   Alt-2
    {"Water Shield",           4, 4},                     -- L20   Alt-3
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

-- Default totem sets — placed AFTER ApplyLayout so they survive the bar clear.
-- /castsequence drops one totem per press, advancing through the list.
-- Resets out of combat or after 15s of inactivity (whichever first).
-- #showtooltip with no arg dynamically shows the next-to-cast totem icon.
--
-- Melee party set: Strength of Earth + Searing + Healing Stream + Windfury
--   Levels 20-25 (pre-Mana Spring @26): uses Healing Stream (strong for dungeons).
--   At 26+ you can manually change Healing Stream → Mana Spring in this macro if preferred.
--   Fully usable around L32+ (Windfury = L32). Pre-L32 the Windfury slot
--   silently fails to advance; player can press again or drop manually.
-- Caster party set: Stoneskin + Flametongue + Mana Spring + Wrath of Air
--   Fully usable around L64+ (Wrath of Air = TBC L64). Pre-30 falls back
--   to Stoneskin only — at low level just use the melee set on Q.
local TOTEM_MELEE_BODY = "#showtooltip\n/castsequence reset=combat/15 Strength of Earth Totem, Searing Totem, Healing Stream Totem, Windfury Totem"
local TOTEM_CASTER_BODY = "#showtooltip\n/castsequence reset=combat/15 Stoneskin Totem, Flametongue Totem, Mana Spring Totem, Wrath of Air Totem"

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
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)

    -- Totem-set macros placed on Q (1,8) and E (1,10) — empty after OPie migration.
    local _, _, meleeIcon = GetSpellInfo("Strength of Earth Totem")
    SetupCore:EnsureRawMacro("SC_TotemMelee", TOTEM_MELEE_BODY, meleeIcon)
    if SetupCore:PlaceMacro("SC_TotemMelee", 1, 8) then placed = placed + 1 end

    local _, _, casterIcon = GetSpellInfo("Stoneskin Totem")
    SetupCore:EnsureRawMacro("SC_TotemCaster", TOTEM_CASTER_BODY, casterIcon)
    if SetupCore:PlaceMacro("SC_TotemCaster", 1, 10) then placed = placed + 1 end

    SetupCore:PrintResults("ShamanSetup", placed, skipped, orphans)
    print("|cffffd700ShamanSetup tip:|r Q = melee totem set, E = caster totem set.")
    print("|cff999999  /castsequence drops one per press; resets in 15s OOC.|r")
    print("|cff999999  Hold M4 (totems ring) for individual placements; element-color-coded.|r")
end

SetupCore:RegisterClass("SHAMAN", Run, LAYOUT)

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
end
