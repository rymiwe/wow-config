-- DruidSetup: Feral + Balance generalist defaults (mirrors Shaman pattern:
-- OPie-first for slow utility, bar slots for combat-active and form toggles).
-- Resto-friendly too — heal slots are universal.
--
-- BAR LAYOUT (matches ShamanSetup; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, F, G, _ / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--   Bar 7 = DISABLED
--   Bar 9 = DISABLED
--   Bar 10 = CONSUMABLES (preserved across /setupbars)
--
-- Form-locked abilities (Bear: Maul/Swipe/Bash/etc.; Cat: Claw/Rake/Shred/etc.)
-- aren't placed by /setupbars — they live on Bar 1 form pages via Blizzard's
-- bonusbar system. Drag them onto Bar 1 manually after shifting form; ElvUI
-- saves form-page placements automatically.
--
-- OPie rings (M4, M5):
--   M4 = Druid Buffs (MotW, Thorns) — pre-pull, low frequency, OPie suits
--   M5 = Druid Travel (Travel Form, Aquatic Form, mount slot) — OOC utility
-- See bottom of file for ring registration.

local LAYOUT = {
    -- MAIN TOP (Bar 1) — INSTANTS only: DoT/debuff/CC; opener on key 1 with startattack
    -- ` left empty: Druid has no baseline interrupt; pinky-stretch slot reserved per
    -- class_setup_pattern.md ("interrupt slot OR empty"). Casts (Wrath) go on Alt-1.
    {"Moonfire",               1, 2, "startattack"},      -- L4    1   (instant DoT opener: engages auto-attack)
    {"Faerie Fire",            1, 3, "mouseover-harm"},   -- L18   2   (instant armor debuff)
    {"Entangling Roots",       1, 4, "mouseover-harm"},   -- L8    3   (CC root — cast, but kept here as "decision tool")
    {"Hibernate",              1, 5, "mouseover-harm"},   -- L18   4   (CC sleep)
    -- QERT row (Q/E/R/T): heals (mouseover-friendly)
    {"Healing Touch",          1, 8, "mouseover-help"},   -- L1    Q
    {"Rejuvenation",           1, 10, "mouseover-help"},  -- L4    E
    {"Regrowth",               1, 11, "mouseover-help"},  -- L12   R
    {"Lifebloom",              1, 12, "mouseover-help"},  -- TBC L64+ T

    -- MAIN BOTTOM (Bar 3) — F/G = Balance form + utility; ZXCVB = Bear/Cat forms + travel + stealth
    -- F/G row: Balance Moonkin Form + Nature's Swiftness (instant-cast next nature spell)
    {"Moonkin Form",           3, 4},                     -- L40 Bal F (Balance signature; untrained = empty for Feral/Resto)
    {"Nature's Swiftness",     3, 5, "self-cast"},        -- L30 Bal/Resto G (instant cast next nature spell; talent-gated)
    -- ZXCVB row: form toggles (Bear/Cat with [noform:N] safety; Travel/Aquatic raw)
    {"Bear Form",              3, 8, "druid-bear-safe"},  -- L10   Z   (won't shift out of Cat)
    {"Cat Form",               3, 9, "druid-cat-safe"},   -- L20   X   (won't shift out of Bear)
    {"Travel Form",            3, 10},                    -- L30   C
    {"Aquatic Form",           3, 11},                    -- L16   V
    {"Prowl",                  3, 12},                    -- L20   B   (Cat-only; harmless out of cat)

    -- ALT TOP (Bar 4) — CAST-TIME damage (caster filler nukes) + Balance AOE + heals/rez
    -- Per class_setup_pattern.md "ranged casts on top, heals on bottom".
    {"Wrath",                  4, 2},                     -- L1    Alt-1 (caster filler — most-spammed cast; was on ` previously)
    {"Starfire",               4, 3},                     -- L20   Alt-2 (slow Balance nuke)
    {"Insect Swarm",           4, 4},                     -- L20   Alt-3 (Balance talent DoT)
    {"Hurricane",              4, 5, "self-cast"},        -- L40   Alt-4 (channeled AOE — Balance signature; was on Alt-E)
    {"Tiger's Fury",           4, 6, "startattack"},      -- L20   Alt-5 (Cat energy boost — frequent CD)
    -- Alt-QERT: rez + utility heals (mouseover-friendly)
    -- NOTE: TBC Druids don't have an out-of-combat rez (Revive is WotLK+).
    {"Rebirth",                4, 8, "mouseover-help"},   -- L20   Alt-Q (combat rez)
    {"Tranquility",            4, 11, "self-cast"},       -- L30   Alt-R (channeled AOE heal)
    {"Innervate",              4, 12, "mouseover-help"},  -- L40   Alt-T (mana donate)

    -- ALT BOTTOM (Bar 5) — dispels + defensives + utility
    {"Cure Poison",            5, 4, "mouseover-help"},   -- L14   Alt-F
    {"Remove Curse",           5, 5, "mouseover-help"},   -- L24   Alt-G
    -- Alt-ZXCVB: combat utility + defensives
    {"Soothe Animal",          5, 8, "mouseover-harm"},   -- L8    Alt-Z (CC enraged beast)
    {"Track Humanoids",        5, 9},                     -- L10   Alt-X (Cat-only tracking)
    {"Nature's Grasp",         5, 10, "self-cast"},       -- L8    Alt-C (root-on-attack)
    {"Barkskin",               5, 11, "self-cast"},       -- L44   Alt-V (defensive)
    {"Dash",                   5, 12},                    -- L26   Alt-B (Cat sprint)
    -- Frenzied Regen + Enrage moved to IGNORE → manual placement on Bear form page
    -- (consistent with Maul/Swipe/etc.; Tiger's Fury kept on Alt-5 since it's
    --  high-frequency Cat-only and benefits from quick alt-modifier access).
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    -- Druid talent passives (no slot needed)
    ["Furor"]=true, ["Heart of the Wild"]=true, ["Leader of the Pack"]=true,
    ["Naturalist"]=true, ["Natural Shapeshifter"]=true,
    ["Improved Mark of the Wild"]=true, ["Improved Healing Touch"]=true,
    ["Improved Ghost Wolf"]=true, ["Subtlety"]=true, ["Improved Wrath"]=true,
    ["Vengeance"]=true, ["Predatory Strikes"]=true, ["Sharpened Claws"]=true,
    -- Race passives (Tauren / Night Elf — Druid races in TBC)
    ["Endurance"]=true, ["Cultivation"]=true, ["Nature Resistance"]=true,
    ["Quickness"]=true, ["Wisp Spirit"]=true, ["Touch of Elune"]=true,
    -- Race actives — Tauren War Stomp auto-placed via RACIALS table per docs/racials.md.
    -- Shadowmeld kept in IGNORE: Druid alt-bottom is full of utility, no clean slot.
    ["Shadowmeld"]=true, ["Elune's Grace"]=true,
    -- Buffs in OPie ring (don't flag as orphans)
    ["Mark of the Wild"]=true, ["Thorns"]=true, ["Gift of the Wild"]=true,
    -- Travel toggles in OPie ring (also bar-bound, but OPie has them too)
    -- Form-locked abilities — placed manually on Bar 1 form pages
    ["Claw"]=true, ["Maul"]=true, ["Rake"]=true, ["Rip"]=true,
    ["Shred"]=true, ["Pounce"]=true, ["Ferocious Bite"]=true,
    ["Mangle (Bear)"]=true, ["Mangle (Cat)"]=true, ["Cower"]=true,
    ["Swipe"]=true, ["Bash"]=true, ["Demoralizing Roar"]=true,
    ["Growl"]=true, ["Challenging Roar"]=true,
    ["Faerie Fire (Feral)"]=true, ["Lacerate"]=true,
    ["Maim"]=true, ["Ravage"]=true, ["Savage Bite"]=true,
    ["Berserk"]=true,
    -- Bear-form CDs: drag manually onto Bear form page (joins Maul/Swipe/etc.)
    ["Frenzied Regeneration"]=true, ["Enrage"]=true,
    -- Hurricane removed from IGNORE — now placed on Alt-4 for Balance druids
    -- (untrained for Feral/Resto = silently skipped by SetupCore)
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Gemcutting"]=true, ["Mining"]=true, ["Smelting"]=true,
    ["Herbalism"]=true, ["Skinning"]=true, ["Fishing"]=true,
    ["Enchanting"]=true, ["Disenchant"]=true,
    ["Inscription"]=true, ["Milling"]=true,
    ["Tailoring"]=true, ["Leatherworking"]=true, ["Alchemy"]=true,
    ["Engineering"]=true, ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    -- Death-handling
    ["Reincarnation"]=true,
}

-- Form-specific abilities the user should manually place on Bar 1 after
-- shifting form. Listed here so the print() can guide them concretely.
local BEAR_ABILITIES = {"Maul", "Swipe", "Bash", "Demoralizing Roar", "Growl", "Challenging Roar", "Faerie Fire (Feral)", "Mangle (Bear)", "Lacerate", "Frenzied Regeneration", "Enrage"}
local CAT_ABILITIES = {"Claw", "Rake", "Shred", "Pounce", "Rip", "Ferocious Bite", "Cower", "Mangle (Cat)", "Maim", "Ravage"}

-- Per-race racial placement (per docs/racials.md). Druid is Tauren/Night Elf only
-- in TBC. NE Shadowmeld → IGNORE (alt-bottom full, low-pri OOC).
local RACIALS = {
    Tauren = {
        {"War Stomp", 3, 10},  -- C: combat AOE stun
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("DruidSetup", placed, skipped, orphans)
    print("|cffffd700DruidSetup tip:|r form-locked abilities aren't auto-placed.")
    print("|cff999999  Shift to BEAR, drag onto Bar 1:|r " .. table.concat(BEAR_ABILITIES, ", "))
    print("|cff999999  Shift to CAT, drag onto Bar 1:|r " .. table.concat(CAT_ABILITIES, ", "))
    print("|cff999999  ElvUI saves form-page placements automatically.|r")
    print("|cff999999  Buffs (MotW, Thorns) live in OPie ring on M4.|r")
    print("|cff999999  Balance druids: Moonkin Form on F, Hurricane on Alt-4, NS on G.|r")
    print("|cff999999  Wrath is on Alt-1 (cast filler); Moonfire on key 1 (instant opener).|r")
end

SetupCore:RegisterClass("DRUID", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- See ShamanSetup.lua for pattern reference.
-- ===========================================================================
do
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Buffs ring (M4 hold) — pre-pull friendly buffs.
    R:AddDefaultRing("DruidBuffs", {
        {id="/cast {{spell:1126}}",  _u="mw"}, -- Mark of the Wild
        {id="/cast {{spell:467}}",   _u="th"}, -- Thorns
        {id="/cast {{spell:21849}}", _u="gw"}, -- Gift of the Wild (L50+, group MotW)
        name = "Buffs", hotkey = "BUTTON4", _u = "DrdBuf", v = 1,
    })

    -- Travel ring (M5 hold) — OOC movement + future mount/hearth.
    -- Includes form toggles for travel — duplicated with bar slots intentionally
    -- so player can use either input pattern.
    R:AddDefaultRing("DruidTravel", {
        {id="/cast {{spell:783}}",   _u="tf"}, -- Travel Form
        {id="/cast {{spell:1066}}",  _u="af"}, -- Aquatic Form
        {id="/cast {{spell:40120}}", _u="ff"}, -- Flight Form (TBC L68+)
        name = "Travel", hotkey = "BUTTON5", _u = "DrdTrv", v = 1,
    })
end
