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
-- METAMORPHOSIS (demon form): Meta is a form ([form:1]) that does NOT auto-page the
-- bars like Druid forms. We set ElvUI Bar 1 paging to "[form:1] 7;" (SetBarPaging),
-- so demon form shows page 7 - the demon PAGE (Shadow Cleave/Demon Charge/Demonic
-- Howl, see META_LAYOUT). Run() builds the caster layout in normal form and the
-- demon page when you /setupbars while transformed. Your curses/DoTs/Life Tap keep
-- working in demon form (Meta is additive, not restrictive), just on the other bars.
--
-- Warlock-specific notes:
--   * No baseline interrupt (Warlock interrupt is via Felhunter Spell Lock on pet bar).
--     The ` slot now holds the Shadowflame rune (see SoD runes below).
--   * Pet abilities (Firebolt, Sacrifice, Lash of Pain, Spell Lock, Devour Magic, etc.)
--     auto-populate the Blizzard PetActionBar - never placed here.
--   * Soulshards are inventory items, not spells - no slot.
--   * SoD RUNE abilities: known active runes get curated homes by name in LAYOUT
--     (Head->` Shadowflame, Hands->F Metamorphosis/SB Volley, Alt-` Demonic Grace,
--     Cloak->Alt-R Incinerate). Summon Felguard -> M5 ring. Passive runes are IGNORE'd.
--     ANY other active rune you engrave is auto-detected from your gear (C_Engraving)
--     and placed on a spare bound slot by SetupCore:PlaceEngravedRunes - so a new
--     rune is never lost even if it isn't listed here. Run /runes for exact names.
--     IMPORTANT: run /setupbars in NORMAL form - Metamorphosis (demon form) hides your
--     caster spellbook; Run() guards against setting up while transformed.
--   * Curses are all INSTANT, so they live on the number row (keys 1-5), castable
--     while moving. Shadow/Doom/Mark of Chaos stay off the bar (see IGNORE).
--   * Pet summons + stones + armors go in OPie M5 ring (slow OOC utility). Armors
--     (Demon Skin/Demon Armor/Fel Armor) are ring-only for consistency, not bar slots.
--
-- OPie rings:
--   M4 = (retired - curses moved to the number row; free for future use)
--   M5 = Pet summons + Soulstone/Healthstone create + Armors

local LAYOUT = {
    -- MAIN TOP (Bar 1) - INSTANTS on numrow. Curses are all instant, so they live
    -- here (keys 1-5): easy to fire while moving. DoTs/curses use mouseover so you
    -- can apply them to a mouseover add while staying engaged with your current target.
    -- ` (button 1) stays reserved for the Shadowflame head rune (see runes below).
    {"Curse of Weakness",      1, 2, "mouseover-harm"},   -- L4    1   (-mob damage; survivability)
    {"Curse of Agony",         1, 3, "nuke-mouseover"},   -- L8    2   (24s ramping DoT; spread for sustained pulls)
    {"Curse of the Elements",  1, 4, "mouseover-harm"},   -- L24   3   (+magic damage taken; boosts your fire/shadow)
    {"Curse of Recklessness",  1, 5, "mouseover-harm"},   -- L14   4   (-armor; more pet/melee damage)
    {"Curse of Tongues",       1, 6, "mouseover-harm"},   -- L38   5   (slow enemy casts; caster mobs/PvP)
    -- QERT row: utility / panic / drains
    {"Drain Life",             1, 8},                     -- L14   Q   (channel; emergency self-heal via damage)
    {"Drain Soul",             1, 10},                    -- L24   E   (channel; soulshard farming)
    {"Howl of Terror",         1, 11},                    -- L40   R   (instant AoE fear; panic)
    {"Banish",                 1, 12, "mouseover-harm"},  -- L26   T   (8s CC vs Demon/Elemental; cast)

    -- MAIN BOTTOM (Bar 3) - G=Soulshatter, ZXCVB combat utility. Armors -> M5 OPie
    -- ring (they were inconsistent: Fel Armor bound but Demon Armor untrained/empty).
    -- F (3,5) left empty. Fear lives on Alt-F (cast-time -> alt bar; F = "Fear").
    {"Soulshatter",            3, 6, "self-cast"},        -- TBC L62 G (drop threat; instant defensive)
    -- ZXCVB row: combat instants + utility
    {"Soul Fire",              3, 8},                     -- L48   Z   (6s cast nuke - heavy damage; OK on bottom row since cast)
    {"Conflagrate",            3, 9},                     -- L20 Destro X (instant burst; consumes Immolate)
    {"Shadowburn",             3, 10},                    -- L20 Destro C (instant execute-style)
    {"Shadowfury",             3, 11},                    -- TBC L60+ V (instant AoE stun)
    {"Life Tap",               3, 12, "self-cast"},       -- L6    B   (HP -> mana; high-frequency)

    -- ALT TOP (Bar 4) - CAST-TIME damage on numrow, heals/utility on Alt-QERT
    -- Cast-time damage on the alt numrow (Alt-1..5). "6" is intentionally unbound
    -- (layout skips 6/7/8/9/0), so nothing may live on bar-4 button 7.
    {"Shadow Bolt",            4, 2, "nuke-mouseover"},   -- L1    Alt-1 (primary cast nuke; mouseover lets you nuke add while DoT ticks on main)
    {"Immolate",               4, 3, "nuke-mouseover"},   -- L1    Alt-2 (cast DoT - 1.5s cast, 15s DoT; spread-friendly)
    {"Corruption",             4, 4, "nuke-mouseover"},   -- L4    Alt-3 (cast DoT until 5/5 Imp Corruption; grouped with the other DoT casts)
    {"Searing Pain",           4, 5, "nuke-mouseover"},   -- L18   Alt-4 (cast nuke + threat; tank-like for Voidwalker pulls)
    {"Hellfire",               4, 6, "self-cast"},        -- L20   Alt-5 (channel AoE; self-damage, anchor on player)
    -- Alt-QERT: utility - pet heal/buffs + AoE/scout
    {"Health Funnel",          4, 8, "self-cast"},        -- L8    Alt-Q (channel - heal active pet)
    {"Unending Breath",        4, 10, "mouseover-help"},  -- L16   Alt-E (water breathing buff)
    {"Incinerate",             4, 11, "nuke-mouseover"},  -- Alt-R  SoD Cloak RUNE (fire nuke; replaced Detect Lesser Invis, low-use)
    {"Rain of Fire",           4, 12},                    -- L20   Alt-T (ground-targeted AoE channel; moved off numrow for Corruption)

    -- ALT BOTTOM (Bar 5) - Fear + snare + panic/escapes
    {"Fear",                   5, 5, "mouseover-harm"},   -- L8    Alt-F (single-target cast fear; "F" = Fear)
    {"Curse of Exhaustion",    5, 6, "mouseover-harm"},   -- L36 Affl Alt-G (snare debuff; Affl talent)
    -- Alt-ZXCVB: panic + escapes
    {"Death Coil",             5, 9},                     -- L42   Alt-X (instant horror + self-heal; panic. Off numrow for curses)
    {"Enslave Demon",          5, 10, "mouseover-harm"},  -- L30   Alt-C (channel; control demon)
    {"Sense Demons",           5, 11, "self-cast"},       -- L20   Alt-V (tracking; low-use)
    -- B left empty (placeholder for racial)

    -- SoD RUNE ABILITIES (active, engraved). Placed by NAME - SetupCore skips any
    -- not currently engraved/known, so this is safe even if a name is slightly off
    -- (run /runes to see exact in-game names). These are the curated homes for the
    -- common ones; anything else you engrave auto-places via PlaceEngravedRunes:
    --   Shadowflame -> ` , Metamorphosis / Shadow Bolt Volley -> F , Demonic Grace ->
    --   Alt-` , Incinerate -> Alt-R (above). Summon Felguard -> M5 ring.
    {"Shadowflame",            1, 1},                     -- `      Head rune (cone AoE opener; instant slot)
    -- Chaos Bolt / Haunt (Legs runes) used to sit on "5"; that key is now Curse of
    -- Tongues. When engraved they auto-place via SetupCore:PlaceEngravedRunes.
    {"Metamorphosis",          3, 5},                     -- F      demon-form toggle (mutually excl. with Shadow Bolt Volley)
    {"Shadow Bolt Volley",     3, 5},                     -- F      AoE nuke rune (alt of Metamorphosis)
    {"Demonic Grace",          4, 1, "self-cast"},        -- Alt-`  Hands rune (defensive surge)
    -- Summon Felguard (Cloak rune) is a SUMMON -> M5 OPie ring, not a bar slot.
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
    -- Most curses now live on the number row (all instant - see LAYOUT). Only these
    -- stay off the bar: Shadow (we run Elements for fire dmg), Doom (L60 raid curse),
    -- and Mark of Chaos (Back rune; when engraved it supersedes Elements - give it the
    -- Elements slot then). Mortal Coil replaced by Death Coil on Alt-X (near-duplicate).
    ["Curse of Shadow"]=true, ["Curse of Doom"]=true,
    ["Mark of Chaos"]=true, ["Mortal Coil"]=true,
    -- Pet summons + stones - handled by OPie ring (M5)
    ["Summon Imp"]=true, ["Summon Voidwalker"]=true, ["Summon Succubus"]=true,
    ["Summon Felhunter"]=true, ["Summon Felguard"]=true,
    ["Summon Infernal"]=true, ["Summon Doomguard"]=true,
    ["Create Healthstone"]=true, ["Create Soulstone"]=true,
    ["Create Spellstone"]=true, ["Create Firestone"]=true,
    ["Soulstone"]=true,                                   -- using a soulstone is via item right-click
    -- Armors - handled by OPie ring (M5)
    ["Demon Skin"]=true, ["Demon Armor"]=true, ["Fel Armor"]=true,
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
    ["Eye of Kilrogg"]=true,                              -- niche scout; dropped from bar for Corruption (drag from book if needed)
    ["Detect Lesser Invisibility"]=true,                  -- freed Alt-R for Incinerate rune
    -- Metamorphosis demon-form abilities: placed on the demon PAGE (see META_LAYOUT),
    -- not the caster bars. Ignore in caster-form orphan checks. Names differ by form
    -- ("Metamorphosis : X" out of form, bare name in form).
    ["Shadow Cleave"]=true, ["Demon Charge"]=true, ["Demonic Howl"]=true,
    ["Metamorphosis : Demon Charge"]=true, ["Metamorphosis : Demonic Howl"]=true,
    -- Wand attack, weapon-spec passive, and generic engraving-slot placeholders that
    -- show in the spellbook (unengraved slots) - no bar slot needed.
    ["Shoot"]=true, ["Axe Specialization"]=true,
    ["Portal of Summoning"]=true, ["Soul Harvesting"]=true,
    ["Helm Rune Ability"]=true, ["Legs Rune Ability"]=true, ["Shoulder Rune Ability"]=true,
    -- SoD PASSIVE runes (no slot needed; active runes are placed via LAYOUT above).
    ["Demonic Pact"]=true, ["Everlasting Affliction"]=true, ["Lake of Fire"]=true,
    ["Master Channeler"]=true, ["Demonic Tactics"]=true, ["Grimoire of Synergy"]=true,
    ["Invocation"]=true, ["Shadow and Flame"]=true, ["Dance of the Wicked"]=true,
    ["Demonic Knowledge"]=true, ["Decimation"]=true, ["Backdraft"]=true,
    ["Unstable Affliction"]=true, ["Immolation Aura"]=true, ["Soul Siphon"]=true,
    ["Infernal Armor"]=true, ["Soul Harvest"]=true,
    ["Vengeance"]=true, ["Enslaved Soul"]=true, ["Soul Engraving"]=true,
    -- SoD rune weapon specializations (passive)
    ["Shadow Weapon Specialization"]=true, ["Fire Weapon Specialization"]=true,
    ["Defense Weapon Specialization"]=true, ["Dagger Specialization"]=true,
    ["Sword Specialization"]=true, ["Pole Weapon Specialization"]=true,
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

-- DEMON PAGE (Metamorphosis). Bar 1 pages to action page 7 in demon form (see
-- SetBarPaging "[form:1] 7;" below), so these land on the demon page and don't
-- touch the caster page. Only the demon-ONLY abilities go here - your curses,
-- Corruption, Immolate, Life Tap all still work in demon form on the other bars.
local META_LAYOUT = {
    {"Shadow Cleave",     1, 2},                     -- 1  builder/nuke (Shadow Bolt becomes this in-form; spam for threat)
    {"Demon Charge",      1, 3},                     -- 2  gap closer / initiate
    {"Demonic Howl",      1, 4},                     -- 3  AoE fear / threat
    -- Tank-relevant curses on the demon page too (curses are instant and work in
    -- demon form). Weakness = mitigation, Agony = threat DoT. Recklessness is
    -- deliberately omitted here - it raises the mob's damage, bad while tanking.
    {"Curse of Weakness", 1, 5, "mouseover-harm"},   -- 4  -mob damage (reapply while tanking)
    {"Curse of Agony",    1, 6, "nuke-mouseover"},   -- 5  ramping threat DoT
}

local function Run()
    -- Metamorphosis is a form ([form:1]) but, unlike Druid forms, does NOT auto-page
    -- the bars (bonusOffset stays 0). So we drive ElvUI's Bar 1 paging ourselves:
    -- demon form -> page 7 (demon page), caster form -> page 1. Idempotent; re-asserted
    -- every run so it self-heals if the ElvUI profile is re-imported.
    SetupCore:SetBarPaging("bar1", "[form:1] 7;")

    if (GetShapeshiftForm and GetShapeshiftForm()) == 1 then
        -- Safety: only build the demon page if Bar 1 has ACTUALLY paged off the
        -- caster page (button 1 action slot > 12). If paging was just set this run
        -- and the state driver hasn't swapped yet, bail rather than overwrite the
        -- caster curses on page 1.
        local b1 = _G["ElvUI_Bar1Button1"]
        local slot = b1 and b1:GetAttribute("action")
        if not slot or slot <= 12 then
            print("|cffff8800WarlockSetup:|r Bar 1 hasn't paged to the demon page yet.")
            print("|cff999999  Run /setupbars once in NORMAL form first, then shift to demon form and /setupbars again.|r")
            return
        end
        -- In demon form with Bar 1 on page 7: build the demon page there. The caster
        -- page (page 1) and the other bars are left untouched.
        SetupCore:ApplyFormLayout("WarlockSetup", "Metamorphosis (demon) form", META_LAYOUT)
        print("|cff999999  Caster bars untouched. Shift out of demon form and /setupbars for the caster layout.|r")
        return
    end

    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("WarlockSetup", placed, skipped, orphans)
    print("|cffffd700WarlockSetup tip:|r Curses on keys 1-5 (all instant, cast on the move).")
    print("|cff999999  Demon form pages Bar 1 to your demon kit - shift in and /setupbars to build it.|r")
    print("|cff999999  Pet summons + stones + armors: hold M5. Pet abilities live on the PetActionBar.|r")
end

SetupCore:RegisterClass("WARLOCK", Run, LAYOUT)

-- No dedicated rune-overflow slots: the number row is full of curses now, and the
-- known active runes (Metamorphosis->F, Shadowflame->`, Demonic Grace->Alt-`) keep
-- curated LAYOUT homes. Any OTHER active rune you engrave (e.g. a Legs Chaos Bolt/
-- Haunt) is auto-placed by SetupCore:PlaceEngravedRunes onto the first empty bound
-- slot, and it prints which key it used so you can re-home it if you like.

-- ===========================================================================
-- OPie ring registration
-- ===========================================================================
do
    local _, class = UnitClass("player")
    if class ~= "WARLOCK" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Curse ring RETIRED: all instant curses moved to the number row (keys 1-5).
    -- M4 is now free for future use (e.g. demon-form abilities). Only M5 remains.

    -- Pet summons + stones ring (M5 hold) - slow OOC utility.
    R:AddDefaultRing("WarlockPet", {
        {id="/cast {{spell:688}}",   _u="im"}, -- Summon Imp
        {id="/cast {{spell:697}}",   _u="vw"}, -- Summon Voidwalker
        {id="/cast {{spell:712}}",   _u="sc"}, -- Summon Succubus
        {id="/cast {{spell:691}}",   _u="fh"}, -- Summon Felhunter
        {id="/cast {{spell:427733/30146}}", _u="fg"}, -- Summon Felguard (SoD 427733 / TBC 30146)
        {id="/cast {{spell:6201}}",  _u="hs"}, -- Create Healthstone
        {id="/cast {{spell:693}}",   _u="ss"}, -- Create Soulstone
        {id="/cast {{spell:1122}}",  _u="if"}, -- Summon Infernal
        {id="/cast {{spell:18540}}", _u="dg"}, -- Summon Doomguard
        {id="/cast {{spell:687}}",   _u="dsk"},-- Demon Skin (L1 armor)
        {id="/cast {{spell:706}}",   _u="dar"},-- Demon Armor
        {id="/cast {{spell:403619/28189}}", _u="far"},-- Fel Armor (SoD 403619 / TBC 28189)
        name = "Pet, Stones & Armor", hotkey = "BUTTON5", _u = "WlkPet", v = 4,
    })
end
