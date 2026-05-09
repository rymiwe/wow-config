-- RogueSetup: Combat-leaning leveling generalist (works for Assassination + Subtlety
-- via untrained-skip). Combat is the default leveling spec because Sinister Strike
-- + Slice and Dice + Eviscerate is the simplest energy-efficient rotation.
--
-- BAR LAYOUT (matches other classes; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (`, 1-5 / Q E R T)
--   Bar 3 = MAIN BOTTOM (F G / Z X C V B)
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--
-- Rogue-specific notes:
--   * Kick on ` (baseline interrupt at L24)
--   * All damage is melee - no nuke-mouseover usage (mouse cursor on a mob you're
--     not next to wastes the press; same reasoning as Warrior).
--   * Stealth-only abilities (Cheap Shot, Garrote, Ambush, Premeditation) are in
--     IGNORE - they appear on the stealth BonusActionBar automatically when stealthed.
--   * Sap with focus-mouseover-harm (focus IS the CC target).
--   * Pick Lock + Disarm Trap + Distract + Detect Traps go in OPie M5 (slow OOC).
--   * Poisons are item-applied (right-click vial), not spell-cast - no slots.
--
-- OPie rings:
--   M4 = Stances (Stealth toggle is the only one - so smaller ring): Vanish, Sprint, Stealth
--   M5 = OOC utility (Pick Lock, Disarm Trap, Distract, Safe Fall, Detect Traps)

local LAYOUT = {
    -- MAIN TOP (Bar 1) - ` = Kick (interrupt). Numrow = builders + finishers.
    {"Kick",                   1, 1},                     -- L24   `   (interrupt + 5s lockout)
    {"Sinister Strike",        1, 2, "startattack"},      -- L1    1   (Combat builder; opener = startattack)
    {"Eviscerate",             1, 3},                     -- L1    2   (primary finisher)
    {"Slice and Dice",         1, 4},                     -- L10   3   (haste finisher)
    {"Rupture",                1, 5},                     -- L20   4   (DoT finisher; for sustained fights)
    {"Expose Armor",           1, 6},                     -- L14   5   (-armor finisher; group utility)
    -- QERT row: utility / panic
    {"Gouge",                  1, 8},                     -- L6    Q   (4s incapacitate front; emergency CC)
    {"Sprint",                 1, 10, "self-cast"},       -- L1    E   (movement CD)
    {"Vanish",                 1, 11, "self-cast"},       -- L22   R   (stealth CD - threat reset)
    {"Evasion",                1, 12, "self-cast"},       -- L8    T   (defensive CD)

    -- MAIN BOTTOM (Bar 3) - F/G defensive, ZXCVB stances + utility
    {"Stealth",                3, 5, "self-cast"},        -- L1    F   (open combat from stealth; right-aligned)
    {"Feint",                  3, 6, "self-cast"},        -- L16   G   (drop threat finisher)
    -- ZXCVB row: utility + reactives
    {"Blind",                  3, 8, "mouseover-harm"},   -- L26   Z   (10s disorient; emergency CC)
    {"Kidney Shot",            3, 9},                     -- L30   X   (stun finisher)
    {"Riposte",                3, 10},                    -- L20 Combat C (reactive after parry)
    {"Distract",               3, 11},                    -- L20   V   (turn enemies; pull/pickpocket utility)
    {"Pick Pocket",            3, 12},                    -- L4    B   (out-of-combat / stealth gold)

    -- ALT TOP (Bar 4) - spec CDs + situational; Rogue has no cast-time damage
    -- ` left empty (or for Shadowstep TBC Subtlety)
    {"Adrenaline Rush",        4, 2, "self-cast"},        -- L40 Combat Alt-1 (energy CD)
    {"Blade Flurry",           4, 3, "self-cast"},        -- L40 Combat Alt-2 (cleave CD)
    {"Cold Blood",             4, 4, "self-cast"},        -- L20 Assn Alt-3 (next finisher = crit)
    {"Premeditation",          4, 5},                     -- L20 Subt Alt-4 (stealth combo points - skip if absent)
    {"Preparation",            4, 6, "self-cast"},        -- L20 41-pt talent Alt-5 (reset CDs)
    -- Alt-QERT: openers (mostly stealth-locked; user drags to BonusActionBar)
    -- Cheap Shot / Garrote / Ambush IGNORED here - placed on stealth bar by user
    {"Hemorrhage",             4, 8},                     -- L20 Subt Alt-Q (debuff builder)
    {"Backstab",               4, 10},                    -- L4    Alt-E (positional builder; behind target)
    {"Mutilate",               4, 11},                    -- TBC L60 Assn Alt-R (positional dual-wield builder)
    {"Ghostly Strike",         4, 12, "self-cast"},       -- L20 Combat Alt-T (instant builder + parry buff)

    -- ALT BOTTOM (Bar 5) - defensives + dispels + niche
    {"Cloak of Shadows",       5, 5, "self-cast"},        -- TBC L66 Alt-F (magic immunity + remove magic effects)
    {"Sap",                    5, 6, "focus-mouseover-harm"}, -- L10 Alt-G (CC humanoid - focus-first)
    -- Alt-ZXCVB: situational + travel
    {"Shadowstep",             5, 8},                     -- TBC L60 Subt Alt-Z (gap-closer + dmg buff)
    {"Detect Traps",           5, 9, "self-cast"},        -- L18   Alt-X (toggle - low-use; could go in OPie)
    {"Safe Fall",              5, 10, "self-cast"},       -- L20   Alt-C (survival utility)
    -- Alt-V/B left empty (placeholders for racial)
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Leather"]=true, ["Daggers"]=true, ["One-Handed Swords"]=true,
    ["One-Handed Maces"]=true, ["One-Handed Axes"]=true, ["Fist Weapons"]=true,
    ["Bows"]=true, ["Crossbows"]=true, ["Guns"]=true, ["Thrown"]=true,
    ["Shoot"]=true, ["Pick Lock"]=true,                   -- handled in OPie M5
    -- Stealth-only openers (appear on stealth BonusActionBar - user drags manually)
    ["Cheap Shot"]=true, ["Garrote"]=true, ["Ambush"]=true,
    -- Rogue talent passives (no slot needed)
    ["Improved Eviscerate"]=true, ["Remorseless Attacks"]=true, ["Malice"]=true,
    ["Ruthlessness"]=true, ["Improved Slice and Dice"]=true, ["Relentless Strikes"]=true,
    ["Improved Expose Armor"]=true, ["Lethality"]=true, ["Vile Poisons"]=true,
    ["Improved Poisons"]=true, ["Fleet Footed"]=true, ["Cold Blood"]=true,    -- placed in LAYOUT
    ["Improved Kidney Shot"]=true, ["Quick Recovery"]=true, ["Seal Fate"]=true,
    ["Murder"]=true, ["Deadened Nerves"]=true, ["Cheat Death"]=true,
    ["Master Poisoner"]=true, ["Mutilate"]=true,                              -- placed in LAYOUT
    ["Improved Sinister Strike"]=true, ["Improved Backstab"]=true,
    ["Improved Gouge"]=true, ["Lightning Reflexes"]=true, ["Improved Sprint"]=true,
    ["Endurance"]=true, ["Riposte"]=true,                                     -- placed in LAYOUT
    ["Improved Kick"]=true, ["Dagger Specialization"]=true,
    ["Dual Wield Specialization"]=true, ["Mace Specialization"]=true,
    ["Blade Flurry"]=true,                                                    -- placed in LAYOUT
    ["Sword Specialization"]=true, ["Weapon Expertise"]=true, ["Aggression"]=true,
    ["Adrenaline Rush"]=true,                                                  -- placed in LAYOUT
    ["Combat Potency"]=true, ["Surprise Attacks"]=true,
    ["Master of Deception"]=true, ["Opportunity"]=true, ["Sleight of Hand"]=true,
    ["Elusiveness"]=true, ["Camouflage"]=true, ["Initiative"]=true,
    ["Improved Ambush"]=true, ["Setup"]=true, ["Improved Sap"]=true,
    ["Serrated Blades"]=true, ["Heightened Senses"]=true, ["Preparation"]=true, -- placed in LAYOUT
    ["Dirty Deeds"]=true, ["Hemorrhage"]=true,                                 -- placed in LAYOUT
    ["Premeditation"]=true,                                                    -- placed in LAYOUT
    ["Deadliness"]=true, ["Enveloping Shadows"]=true, ["Master of Subtlety"]=true,
    ["Shadowstep"]=true,                                                       -- placed in LAYOUT
    ["Honor Among Thieves"]=true,
    -- OOC utility - handled by OPie ring (M5)
    ["Disarm Trap"]=true,
    -- Race passives
    ["Stoneform"]=true, ["Find Treasure"]=true, ["Frost Resistance"]=true,
    ["Touch of Elune"]=true, ["Wisp Spirit"]=true, ["Quickness"]=true,
    ["Nature Resistance"]=true, ["Heroic Presence"]=true, ["Shadow Resistance"]=true,
    ["Hardiness"]=true, ["Endurance"]=true, ["Cultivation"]=true,
    ["Magic Resistance"]=true, ["Expansive Mind"]=true,
    ["Underwater Breathing"]=true, ["Da Voodoo Shuffle"]=true,
    ["Regeneration"]=true, ["The Human Spirit"]=true, ["Diplomacy"]=true,
    ["Perception"]=true,
    ["Sword Specialization"]=true,                                             -- Human passive (also Rogue talent name conflict)
    ["Mace Specialization"]=true, ["Axe Specialization"]=true,
    ["Bow Specialization"]=true, ["Beast Slaying"]=true,
    ["Gun Specialization"]=true, ["Engineering Specialization"]=true,
    ["Arcane Resistance"]=true, ["Command"]=true,
    -- Race actives - placed via RACIALS or IGNORE
    ["Blood Fury"]=true, ["Berserking"]=true, ["War Stomp"]=true,
    ["Shadowmeld"]=true, ["Will of the Forsaken"]=true, ["Cannibalize"]=true,
    ["Mana Tap"]=true, ["Arcane Torrent"]=true, ["Gift of the Naaru"]=true,
    ["Escape Artist"]=true, ["Stoneform"]=true,
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Mining"]=true, ["Smelting"]=true, ["Herbalism"]=true, ["Skinning"]=true,
    ["Fishing"]=true, ["Enchanting"]=true, ["Disenchant"]=true,
    ["Alchemy"]=true, ["Tailoring"]=true, ["Leatherworking"]=true,
    ["Engineering"]=true, ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true, ["Gemcutting"]=true,
    -- Poisons (item-applied via right-click; no spell to place)
    ["Crippling Poison"]=true, ["Mind-numbing Poison"]=true,
    ["Wound Poison"]=true, ["Instant Poison"]=true, ["Deadly Poison"]=true,
    ["Anesthetic Poison"]=true,
}

local RACIALS = {
    Human = {},
    Dwarf = {
        {"Stoneform", 5, 11, "self-cast"},
    },
    NightElf = {
        {"Shadowmeld", 5, 12, "self-cast"},
    },
    Gnome = {
        {"Escape Artist", 5, 11, "self-cast"},
    },
    Orc = {
        {"Blood Fury", 4, 1, "self-cast"},               -- Alt-` damage CD slot
    },
    Troll = {
        {"Berserking", 4, 1, "self-cast"},
    },
    Undead = {
        {"Will of the Forsaken", 5, 11, "self-cast"},
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},                       -- C: cross-class racial-CC slot (Riposte conflict)
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("RogueSetup", placed, skipped, orphans)
    print("|cffffd700RogueSetup tip:|r stealth-only openers (Cheap Shot / Garrote / Ambush)")
    print("|cff999999  appear on the stealth BonusActionBar - drag them onto Bar 1 manually|r")
    print("|cff999999  while stealthed (Blizzard remembers per-stealth-state slots).|r")
    print("|cff999999  Sap on Alt-G uses focus-first - /focus a mob, Alt-G saps it.|r")
end

SetupCore:RegisterClass("ROGUE", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration
-- ===========================================================================
do
    local _, class = UnitClass("player")
    if class ~= "ROGUE" then return end
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- OOC utility ring (M5 hold) - low-frequency rogue tools.
    R:AddDefaultRing("RogueUtility", {
        {id="/cast {{spell:1804}}",  _u="pl"}, -- Pick Lock
        {id="/cast {{spell:1842}}",  _u="dt"}, -- Disarm Trap
        {id="/cast {{spell:1725}}",  _u="ds"}, -- Distract
        {id="/cast {{spell:2836}}",  _u="td"}, -- Detect Traps (toggle)
        {id="/cast {{spell:1860}}",  _u="sf"}, -- Safe Fall (talent? actually passive Survival in TBC)
        name = "Rogue Utility", hotkey = "BUTTON5", _u = "RgUtl", v = 1,
    })
end
