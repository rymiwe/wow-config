-- HunterSetup: ranged generalist defaults (works for Marks, Survival, BM —
-- spec-divergent CDs share Alt-numrow; SetupCore silently skips untrained spells).
--
-- BAR LAYOUT (matches Shaman/Druid; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, F, G, _ / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--   Bar 7 = DISABLED
--   Bar 9 = DISABLED
--   Bar 10 = CONSUMABLES (preserved across /setupbars)
--
-- Hunter-specific notes:
--   * `` ` `` = Auto Shot (the always-on anchor — Hunter has no spammable instant
--     opener; Auto Shot fires continuously while in combat). Pre-Silencing-Shot
--     (Marks talent) Hunter has no spell interrupt, so `` ` `` stays on Auto.
--   * Numrow opener is Serpent Sting w/ `startattack` — the template issues
--     `/startattack` so the user starts auto-attacking even if the mob closes.
--   * Pet abilities (Bite, Claw, Growl, Cower, etc.) auto-populate the Blizzard
--     PetActionBar — never placed here.
--   * QERT row is dedicated to TRAPS (Hunter signature). Most other classes use
--     QERT for heals; Hunter has no heals.
--
-- OPie rings (M4, M5):
--   M4 = Hunter Aspects (all aspects — toggle via ring keeps bar uncluttered)
--   M5 = Hunter Pet OOC (Call/Dismiss/Revive/Feed) + Tame Beast
-- Tracking has no dedicated hotkey by default — register HunterTracking ring
-- and let the user bind in /opie if they want it.

local LAYOUT = {
    -- MAIN TOP (Bar 1) — INSTANTS only on numrow (Auto Shot is the ranged-anchor
    -- exception on `). Cast-time damage (Aimed Shot, Steady Shot) on Alt-numrow.
    {"Auto Shot",              1, 1},                     -- L1    `   (ranged anchor exception; always-ready)
    {"Serpent Sting",          1, 2, "startattack"},      -- L4    1   (instant DoT opener: engages auto-attack)
    {"Arcane Shot",            1, 3},                     -- L6    2   (instant filler)
    {"Concussive Shot",        1, 4},                     -- L8    3   (instant slow / kite)
    {"Multi-Shot",             1, 5},                     -- L18   4   (3-target burst — 0.5s cast, treat as instant)
    -- QERT row (Q/E/R/T): TRAPS — Hunter signature
    {"Freezing Trap",          1, 8},                     -- L20   Q   (primary CC — pre-pull or panic)
    {"Frost Trap",             1, 10},                    -- L28   E   (AOE slow)
    {"Explosive Trap",         1, 11},                    -- L34   R   (AOE damage)
    {"Immolation Trap",        1, 12},                    -- L16   T   (DoT trap)

    -- MAIN BOTTOM (Bar 3) — F/G stings, ZXCVB utility
    {"Scorpid Sting",          3, 4},                     -- L8    F   (-STR/-AGI debuff)
    {"Hunter's Mark",          3, 5},                     -- L6    G   (always-on debuff; re-applied often)
    -- ZXCVB row: utility + auto-attack toggle
    {"Flare",                  3, 8},                     -- L8    Z   (reveals stealth)
    {"Feign Death",            3, 9, "self-cast"},        -- L30   X   (drop combat — high-frequency, prime slot)
    -- C left empty — startattack template + right-click cover auto-attack
    {"Wing Clip",              3, 11},                    -- L12   V   (melee snare)
    {"Disengage",              3, 12},                    -- L8    B   (aggro reset)

    -- ALT TOP (Bar 4) — CAST-TIME ranged + spec CDs (per "casts on alt" principle).
    -- Aimed Shot moved here from Bar 1 numrow (Marks signature cast).
    {"Silencing Shot",         4, 1},                     -- TBC L60+ Marks Alt-`  (interrupt)
    {"Steady Shot",            4, 2},                     -- TBC L62+ Alt-1        (BM/MM cast filler)
    {"Aimed Shot",             4, 3},                     -- L20   Alt-2           (Marks slow hard hit — was on key 5)
    {"Volley",                 4, 4},                     -- L40   Alt-3           (channeled AOE)
    {"Kill Command",           4, 5},                     -- TBC L66+ Alt-4        (BM burst)
    {"Bestial Wrath",          4, 6},                     -- L40 BM   Alt-5        (BM CD)
    -- Readiness (Marks 41-pt cap) → IGNORE: niche talent, drag manually if specced.
    -- Alt-QERT: pet management (combat-relevant) + raid utility
    {"Mend Pet",               4, 8},                     -- L4    Alt-Q  (auto-pet-targeted; no template needed)
    {"Misdirection",           4, 10, "mouseover-help"},  -- TBC L70+ Alt-E (raid threat redirect)
    {"Tranquilizing Shot",     4, 11, "mouseover-harm"},  -- L40   Alt-R (strip enrage/magic)
    {"Scare Beast",            4, 12, "mouseover-harm"},  -- L14   Alt-T (CC fear beasts)

    -- ALT BOTTOM (Bar 5) — defensives + Survival reactives + travel utility
    -- Alt-FG: Hunter has no friend-target heals; leave for racials/utility
    -- Alt-ZXCVB: defensives + Survival reactives
    {"Deterrence",             5, 8, "self-cast"},        -- L40 Surv Alt-Z (defensive parry buff)
    {"Scatter Shot",           5, 9},                     -- L30 Surv Alt-X (4s disorient CC break)
    {"Counterattack",          5, 10},                    -- L30 Surv Alt-C (reactive after parry)
    {"Mongoose Bite",          5, 11},                    -- L16 Surv Alt-V (reactive after dodge)
    {"Raptor Strike",          5, 12},                    -- L1       Alt-B (melee on-next-swing)
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Mail Specialization"]=true, ["Bows"]=true, ["Crossbows"]=true,
    ["Guns"]=true, ["Thrown"]=true, ["Two-Handed Axes"]=true,
    ["Two-Handed Swords"]=true, ["Polearms"]=true, ["Daggers"]=true,
    ["Fist Weapons"]=true, ["One-Handed Axes"]=true, ["One-Handed Swords"]=true,
    ["Staves"]=true, ["Shoot"]=true,
    -- Hunter talent passives (no slot needed)
    ["Endurance Training"]=true, ["Improved Aspect of the Hawk"]=true,
    ["Pathfinding"]=true, ["Aspect Mastery"]=true,
    ["Improved Aspect of the Monkey"]=true, ["Lethal Shots"]=true,
    ["Mortal Shots"]=true, ["Efficiency"]=true, ["Hawk Eye"]=true,
    ["Improved Concussive Shot"]=true, ["Improved Hunter's Mark"]=true,
    ["Trap Mastery"]=true, ["Survivalist"]=true, ["Deflection"]=true,
    ["Entrapment"]=true, ["Savage Strikes"]=true, ["Improved Wing Clip"]=true,
    ["Surefooted"]=true, ["Improved Mend Pet"]=true, ["Ferocity"]=true,
    ["Spirit Bond"]=true, ["Bestial Discipline"]=true, ["Animal Handler"]=true,
    ["Frenzy"]=true, ["Beast Mastery"]=true, ["Catlike Reflexes"]=true,
    ["Improved Aspect of the Wild"]=true, ["Master Tactician"]=true,
    ["Survival Instincts"]=true, ["Improved Stings"]=true,
    ["Mortal Shots"]=true, ["Go for the Throat"]=true,
    -- Aspects — handled by OPie ring (M4)
    ["Aspect of the Hawk"]=true, ["Aspect of the Cheetah"]=true,
    ["Aspect of the Pack"]=true, ["Aspect of the Beast"]=true,
    ["Aspect of the Monkey"]=true, ["Aspect of the Wild"]=true,
    ["Aspect of the Viper"]=true,
    -- Tracking — handled by OPie ring (HunterTracking)
    ["Track Beasts"]=true, ["Track Humanoids"]=true, ["Track Undead"]=true,
    ["Track Hidden"]=true, ["Track Elementals"]=true, ["Track Demons"]=true,
    ["Track Giants"]=true, ["Track Dragonkin"]=true,
    -- Pet OOC commands — handled by OPie ring (M5)
    ["Revive Pet"]=true, ["Feed Pet"]=true, ["Dismiss Pet"]=true,
    ["Call Pet"]=true, ["Tame Beast"]=true, ["Eyes of the Beast"]=true,
    ["Beast Lore"]=true,
    -- Race passives (Dwarf / Night Elf / Draenei / Orc / Tauren / Troll / Blood Elf)
    ["Gun Specialization"]=true, ["Frost Resistance"]=true, ["Find Treasure"]=true,
    ["Quickness"]=true, ["Wisp Spirit"]=true, ["Touch of Elune"]=true,
    ["Nature Resistance"]=true, ["Heroic Presence"]=true,
    ["Inspiring Presence"]=true, ["Shadow Resistance"]=true,
    ["Hardiness"]=true, ["Command"]=true, ["Axe Specialization"]=true,
    ["Endurance"]=true, ["Cultivation"]=true,
    ["Da Voodoo Shuffle"]=true, ["Bow Specialization"]=true,
    ["Beast Slaying"]=true, ["Regeneration"]=true,
    ["Magic Resistance"]=true,
    -- Race actives — Tauren War Stomp auto-placed via RACIALS. Others IGNORE
    -- because Hunter Alt-numrow is fully booked by Steady Shot/Aimed Shot/Volley/
    -- Kill Command/Bestial Wrath — no clean slot for racial CDs. Friends drag manually.
    ["Blood Fury"]=true, ["Berserking"]=true,
    ["Stoneform"]=true, ["Shadowmeld"]=true, ["Gift of the Naaru"]=true,
    ["Mana Tap"]=true, ["Arcane Torrent"]=true,
    -- Niche talents we don't auto-place
    ["Readiness"]=true,                                   -- Marks 41-pt cap; drag manually if specced
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Gemcutting"]=true, ["Mining"]=true, ["Smelting"]=true,
    ["Herbalism"]=true, ["Skinning"]=true, ["Fishing"]=true,
    ["Enchanting"]=true, ["Disenchant"]=true, ["Alchemy"]=true,
    ["Tailoring"]=true, ["Leatherworking"]=true, ["Engineering"]=true,
    ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true,
}

-- Per-race racial placement (per docs/racials.md). Hunter Alt-numrow is full,
-- so most racial CDs are IGNORE. Only Tauren War Stomp has a clean slot.
local RACIALS = {
    Tauren = {
        {"War Stomp", 3, 10},  -- C: combat AOE stun (replaced "Attack" in earlier cleanup)
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("HunterSetup", placed, skipped, orphans)
    print("|cffffd700HunterSetup tip:|r pet abilities (Bite/Claw/Growl/etc.) live on the")
    print("|cff999999  Blizzard PetActionBar — they're not placed by /setupbars.|r")
    print("|cff999999  Aspects: hold M4 (OPie ring). Pet OOC: hold M5.|r")
end

SetupCore:RegisterClass("HUNTER", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- Uses {{spell:NNN}} macro syntax; OPie resolves to highest known rank.
-- ===========================================================================
do
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Aspects ring (M4 hold) — combat + utility aspects in one place.
    R:AddDefaultRing("HunterAspects", {
        {id="/cast {{spell:13165}}", _u="hk"}, -- Aspect of the Hawk
        {id="/cast {{spell:27045}}", _u="vp"}, -- Aspect of the Viper (TBC)
        {id="/cast {{spell:13163}}", _u="mk"}, -- Aspect of the Monkey
        {id="/cast {{spell:5118}}",  _u="ch"}, -- Aspect of the Cheetah
        {id="/cast {{spell:13159}}", _u="pk"}, -- Aspect of the Pack
        {id="/cast {{spell:20043}}", _u="wd"}, -- Aspect of the Wild
        {id="/cast {{spell:13161}}", _u="bs"}, -- Aspect of the Beast
        name = "Aspects", hotkey = "BUTTON4", _u = "HntAsp", v = 1,
    })

    -- Pet OOC ring (M5 hold) — call/dismiss/revive/feed/tame.
    R:AddDefaultRing("HunterPet", {
        {id="/cast {{spell:883}}",   _u="cp"}, -- Call Pet
        {id="/cast {{spell:2641}}",  _u="dp"}, -- Dismiss Pet
        {id="/cast {{spell:982}}",   _u="rp"}, -- Revive Pet
        {id="/cast {{spell:6991}}",  _u="fp"}, -- Feed Pet
        {id="/cast {{spell:1515}}",  _u="tb"}, -- Tame Beast
        name = "Pet", hotkey = "BUTTON5", _u = "HntPet", v = 1,
    })

    -- Tracking ring (no default hotkey — user binds in /opie if wanted).
    -- Mutually-exclusive toggles, perfect for a radial.
    R:AddDefaultRing("HunterTracking", {
        {id="/cast {{spell:1494}}",  _u="tb"}, -- Track Beasts
        {id="/cast {{spell:19883}}", _u="th"}, -- Track Humanoids
        {id="/cast {{spell:19884}}", _u="tu"}, -- Track Undead
        {id="/cast {{spell:19885}}", _u="ti"}, -- Track Hidden
        {id="/cast {{spell:19880}}", _u="te"}, -- Track Elementals
        {id="/cast {{spell:19878}}", _u="td"}, -- Track Demons
        {id="/cast {{spell:19882}}", _u="tg"}, -- Track Giants
        {id="/cast {{spell:19879}}", _u="tk"}, -- Track Dragonkin
        name = "Tracking", _u = "HntTrk", v = 1,
    })
end
