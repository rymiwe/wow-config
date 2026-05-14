-- DruidSetup: Feral + Balance generalist defaults, frequency-weighted for
-- leveling. Most-spammed spells on plain bar (no modifier) regardless of
-- cast/instant — kid-friendly. Less-frequent casts/CC on Alt-modifier.
-- Forms all live in OPie M5 ring (one ring for Bear/Cat/Travel/Aquatic/etc.).
--
-- BAR LAYOUT:
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, _, F, G / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--   Bar 7 = DISABLED
--   Bar 9 = DISABLED
--   Bar 10 = CONSUMABLES (preserved across /setupbars)
--
-- Form-locked combat abilities (Bear: Maul/Swipe/etc.; Cat: Claw/Rake/Tiger's
-- Fury/etc.) live on Bar 1's per-form pages via Blizzard's [bonusbar:N] system.
-- Drag them onto Bar 1 manually after shifting form; ElvUI saves form-page
-- placements automatically.
--
-- OPie rings (M4, M5):
--   M4 = Druid Buffs (MotW, Thorns, GotW) — pre-pull, low frequency
--   M5 = Druid Forms (Bear, Cat, Travel, Aquatic, Flight, Moonkin, Tree, Prowl)
-- See bottom of file for ring registration.

local LAYOUT = {
    -- MAIN TOP (Bar 1) — frequency-weighted: most-spammed spells on plain keys
    -- (regardless of cast/instant), less-frequent on Alt-modifier per Asog/kid
    -- ergonomics principle. ` left empty: Druid has no baseline interrupt.
    {"Wrath",                  1, 2, "nuke-mouseover"},   -- L1    1   (cast — most-spammed L1-30)
    {"Moonfire",               1, 3, "nuke-mouseover"},   -- L4    2   (instant DoT — applied per-pull)
    {"Faerie Fire",            1, 4, "mouseover-harm"},   -- L18   3   (instant armor debuff)
    -- 4, 5 left empty (placeholders fill the keyboard shape)
    -- QERT row (Q/E/R/T): heals (mouseover-friendly) — most-frequent for any spec
    {"Healing Touch",          1, 8, "mouseover-help"},   -- L1    Q   (primary heal)
    {"Rejuvenation",           1, 10, "mouseover-help"},  -- L4    E   (instant HoT)
    {"Regrowth",               1, 11, "mouseover-help"},  -- L12   R   (cast hybrid HoT+direct)
    {"Lifebloom",              1, 12, "mouseover-help"},  -- TBC L64+ T (instant stacking HoT, Resto)

    -- MAIN BOTTOM (Bar 3) — F/G utility; ZXCVB intentionally empty (forms in OPie).
    -- Right-aligned per class_setup_pattern.md.
    {"Nature's Swiftness",     3, 6, "self-cast"},        -- L30 talent G (instant cast next nature spell)
    -- F (3, 5) and ZXCVB left empty — forms moved to OPie M5 ring.

    -- ALT TOP (Bar 4) — MIRRORS caster Bar 1 numrow + QERT so Alt+key always
    -- casts the caster version from any form. WoW's /cast auto-cancelforms
    -- when needed, so mouseover-help template works as-is. Alt is thumb-
    -- reachable (no Shift hand contortion for kid). Empty caster slots (4, 5)
    -- backfill with Balance spec primaries.
    {"Wrath",                  4, 2, "nuke-mouseover"},   -- L1    Alt-1 (cross-form: cast Wrath in any form)
    {"Moonfire",               4, 3, "nuke-mouseover"},   -- L4    Alt-2 (cross-form: instant DoT)
    {"Faerie Fire",            4, 4, "mouseover-harm"},   -- L18   Alt-3 (cross-form: armor debuff)
    {"Starfire",               4, 5, "nuke-mouseover"},   -- L20   Alt-4 (Balance spec - caster slot 4 empty)
    {"Insect Swarm",           4, 6, "nuke-mouseover"},   -- L20   Alt-5 (Balance spec - caster slot 5 empty)
    -- Alt-QERT mirrors caster heals
    {"Healing Touch",          4, 8, "mouseover-help"},   -- L1    Alt-Q (cross-form main heal)
    {"Rejuvenation",           4, 10, "mouseover-help"},  -- L4    Alt-E (cross-form instant HoT)
    {"Regrowth",               4, 11, "mouseover-help"},  -- L12   Alt-R (cross-form hybrid HoT+direct)
    {"Lifebloom",              4, 12, "mouseover-help"},  -- TBC L64+ Alt-T (Resto stacking HoT - mirrors caster T)

    -- ALT BOTTOM (Bar 5) — dispels + CCs + Rebirth + defensives + travel
    {"Cure Poison",            5, 5, "mouseover-help"},   -- L14   Alt-F
    {"Remove Curse",           5, 6, "mouseover-help"},   -- L24   Alt-G
    -- Alt-ZXCVB: CC + emergency rez + defensives
    {"Entangling Roots",       5, 8, "mouseover-harm"},   -- L8    Alt-Z (CC root - moved from alt-numrow when alt-bar became caster mirror)
    {"Hibernate",              5, 9, "mouseover-harm"},   -- L18   Alt-X (CC sleep beast/dragonkin)
    {"Rebirth",                5, 10, "mouseover-help"},  -- L20   Alt-C (combat rez)
    {"Barkskin",               5, 11, "self-cast"},       -- L44   Alt-V (defensive)
    {"Dash",                   5, 12},                    -- L26   Alt-B (Cat sprint)
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
    -- Buffs in OPie M4 ring (don't flag as orphans)
    ["Mark of the Wild"]=true, ["Thorns"]=true, ["Gift of the Wild"]=true,
    -- Forms in OPie M5 ring (NOT placed on bars; user uses OPie to shift)
    ["Bear Form"]=true, ["Cat Form"]=true, ["Travel Form"]=true,
    ["Aquatic Form"]=true, ["Flight Form"]=true, ["Swift Flight Form"]=true,
    ["Moonkin Form"]=true, ["Tree of Life"]=true, ["Prowl"]=true,
    -- Form-locked combat abilities — placed manually on Bar 1 form pages
    ["Claw"]=true, ["Maul"]=true, ["Rake"]=true, ["Rip"]=true,
    ["Shred"]=true, ["Pounce"]=true, ["Ferocious Bite"]=true,
    ["Mangle (Bear)"]=true, ["Mangle (Cat)"]=true, ["Cower"]=true,
    ["Swipe"]=true, ["Bash"]=true, ["Demoralizing Roar"]=true,
    ["Growl"]=true, ["Challenging Roar"]=true,
    ["Faerie Fire (Feral)"]=true, ["Lacerate"]=true,
    ["Maim"]=true, ["Ravage"]=true, ["Savage Bite"]=true,
    ["Berserk"]=true,
    -- Form-locked CDs: drag manually onto matching form page
    ["Frenzied Regeneration"]=true, ["Enrage"]=true,  -- Bear
    ["Tiger's Fury"]=true,                            -- Cat
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
    -- Displaced from alt-bar to make room for caster-mirror approach. Drag
    -- manually if/when needed, or we add back via tier system at higher level.
    ["Innervate"]=true,         -- L40 friend mana CD
    ["Tranquility"]=true,       -- L30 channeled raid heal
    ["Hurricane"]=true,         -- L40 Balance channeled AoE
    ["Soothe Animal"]=true,     -- L8 niche CC (calm enraged beast)
    ["Track Humanoids"]=true,   -- L10 Cat-only tracking (low pri)
    ["Nature's Grasp"]=true,    -- L8 root-on-attack proc (debatable value)
}

-- Form-specific bar layouts. When /setupbars runs while the Druid is in Bear or
-- Cat form, we apply that form's layout (not the caster LAYOUT above). Each
-- form has its own action-bar page in Blizzard's bonus-bar system, so placing
-- to "bar 1 slot 1" while in bear form lands on the bear page; the caster
-- placements (made in caster form) are untouched. Same form-key shape as the
-- caster layout so muscle memory carries: numrow = primary attacks, QERT =
-- control + defensives, F/G = utility, ZXCVB = situational.
--
-- Untrained abilities silently skip (kid in L10 bear has only Maul; the rest
-- fill in as he levels and re-runs /setupbars in form).
-- Form layouts ONLY place Bar 1 entries (the form-paged bar). Bar 3-5 are
-- shared across forms; placing form-specific abilities there would clobber
-- caster utility on form /setupbars. Faerie Fire (Feral) and Cower don't have
-- a Bar 1 slot in our default; drag manually if wanted on a form page.
local BEAR_LAYOUT = {
    -- ` holds Bash for cross-class interrupt convention (Shaman: Earth Shock,
    -- Mage: Counterspell, Rogue: Kick, Pally: Hammer of Justice). Bash is the
    -- bear-form interrupt-by-stun (4s stun). Maul moves to key 5.
    {"Bash",                   1, 1},                     -- L24   `   (4s stun - interrupt-by-stun convention)
    {"Mangle (Bear)",          1, 2},                     -- L50+  1   (primary builder, replaces Maul-spam)
    {"Swipe",                  1, 3},                     -- L16   2   (frontal AoE)
    {"Lacerate",               1, 4},                     -- TBC L66 3 (bleed DoT - talent/recipe)
    {"Demoralizing Roar",      1, 5},                     -- L20   4   (AoE -AP debuff)
    {"Maul",                   1, 6},                     -- L10   5   (next-swing rage dump - always-ready)
    {"Growl",                  1, 8},                     -- L14   Q   (taunt - tank essential)
    {"Challenging Roar",       1, 10},                    -- L40   E   (AoE taunt)
    {"Frenzied Regeneration",  1, 11, "self-cast"},       -- L40   R   (emergency heal CD)
    {"Enrage",                 1, 12, "self-cast"},       -- L26   T   (rage generation)
}

local CAT_LAYOUT = {
    {"Claw",                   1, 1},                     -- L10   `   (basic builder)
    {"Mangle (Cat)",           1, 2},                     -- L50+  1   (primary builder)
    {"Shred",                  1, 3},                     -- L22   2   (positional builder behind target)
    {"Rake",                   1, 4},                     -- L24   3   (bleed builder)
    {"Ferocious Bite",         1, 5},                     -- L32   4   (finisher)
    {"Rip",                    1, 6},                     -- L20   5   (bleed finisher)
    {"Tiger's Fury",           1, 8, "self-cast"},        -- L30   Q   (damage CD)
    {"Pounce",                 1, 10},                    -- L24   E   (stealth stun opener)
    {"Ravage",                 1, 11},                    -- L36   R   (stealth burst opener)
    {"Maim",                   1, 12},                    -- TBC L62 T (knockback finisher)
}

-- Used by print() in caster-form Run() to advertise form layouts.
local BEAR_NAMES = {}
local CAT_NAMES = {}
for _, e in ipairs(BEAR_LAYOUT) do table.insert(BEAR_NAMES, e[1]) end
for _, e in ipairs(CAT_LAYOUT)  do table.insert(CAT_NAMES,  e[1]) end

-- Per-race racial placement (per docs/racials.md). Druid is Tauren/Night Elf only
-- in TBC. NE Shadowmeld → IGNORE (alt-bottom full, low-pri OOC).
local RACIALS = {
    Tauren = {
        {"War Stomp", 3, 10},  -- C: combat AOE stun
    },
}

local function Run()
    local form = GetShapeshiftForm()
    -- TBC Druid form indices: 1=Bear, 2=Aquatic, 3=Cat, 4=Travel, 5=Moonkin/Tree.
    if form == 1 then
        SetupCore:ApplyFormLayout("DruidSetup", "BEAR form", BEAR_LAYOUT)
        print("|cff999999  Caster + Cat bars untouched. Shift to Cat and /setupbars to set up that bar.|r")
        return
    elseif form == 3 then
        SetupCore:ApplyFormLayout("DruidSetup", "CAT form", CAT_LAYOUT)
        print("|cff999999  Caster + Bear bars untouched. Shift to Bear and /setupbars to set up that bar.|r")
        return
    end
    -- Caster form (or no form): apply the main caster LAYOUT.
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("DruidSetup", placed, skipped, orphans)
    print("|cffffd700DruidSetup tip:|r Wrath on key 1, Moonfire on 2, heals on Q/E/R/T.")
    print("|cff999999  Alt-bar MIRRORS Bar 1: Alt+1=Wrath, Alt+E=Rejuv, etc. Auto-cancels form when cast in bear/cat.|r")
    print("|cff999999  Alt+Z/X = Entangling Roots/Hibernate (CC). Alt+C = Rebirth (combat rez).|r")
    print("|cff999999  Form toggles live in OPie M4 ring (Bear, Cat, Travel, Moonkin, Prowl).|r")
    print("|cff999999  Buffs (MotW, Thorns, GotW) on OPie M5 ring.|r")
    print("|cff999999  Bear/Cat bars: shift to that form, run /setupbars - bar 1 fills with form abilities.|r")
    print("|cff999999    BEAR layout (when in bear):|r " .. table.concat(BEAR_NAMES, ", "))
    print("|cff999999    CAT layout (when in cat):|r " .. table.concat(CAT_NAMES, ", "))
    print("|cff999999  Buffs (MotW, Thorns) live in OPie M4 ring.|r")
end

SetupCore:RegisterClass("DRUID", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- See ShamanSetup.lua for pattern reference.
-- ===========================================================================
do
    -- Class-conditional: see ShamanSetup for rationale (cross-class M4/M5 collision).
    local _, class = UnitClass("player")
    if class ~= "DRUID" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Forms ring (M4 hold) — primary class action for Druid. Per user
    -- preference, forms live on the lower (closer-to-thumb) button since
    -- shape-shifting is the most-pressed Druid utility. All forms in one
    -- ring; Bear/Cat use [noform:N] safety so accidental shift from the
    -- OTHER combat form doesn't waste rage/energy (form 1 = Bear, form 4 = Cat).
    R:AddDefaultRing("DruidForms", {
        {id="/cast [noform:4] {{spell:5487}}",  _u="be"}, -- Bear Form (won't shift from Cat)
        {id="/cast [noform:1] {{spell:768}}",   _u="ca"}, -- Cat Form (won't shift from Bear)
        {id="/cast {{spell:783}}",              _u="tf"}, -- Travel Form
        {id="/cast {{spell:1066}}",             _u="af"}, -- Aquatic Form
        {id="/cast {{spell:33943}}",            _u="ff"}, -- Flight Form (TBC L68+)
        {id="/cast {{spell:40120}}",            _u="sf"}, -- Swift Flight Form (TBC epic, L70)
        {id="/cast [noform:1/4] {{spell:24858}}", _u="mk"}, -- Moonkin Form (Balance L40, won't break Bear/Cat)
        {id="/cast [noform:1/4] {{spell:33891}}", _u="to"}, -- Tree of Life (Resto L40, won't break Bear/Cat)
        {id="/cast {{spell:5215}}",             _u="pr"}, -- Prowl (Cat-only stealth)
        name = "Forms", hotkey = "BUTTON4", _u = "DrdFrm", v = 2,
    })

    -- Buffs ring (M5 hold) — pre-pull friendly buffs. Less frequently
    -- needed than forms; lives on the upper side button.
    R:AddDefaultRing("DruidBuffs", {
        {id="/cast {{spell:1126}}",  _u="mw"}, -- Mark of the Wild
        {id="/cast {{spell:467}}",   _u="th"}, -- Thorns
        {id="/cast {{spell:21849}}", _u="gw"}, -- Gift of the Wild (L50+, group MotW)
        name = "Buffs", hotkey = "BUTTON5", _u = "DrdBuf", v = 3,
    })
end
