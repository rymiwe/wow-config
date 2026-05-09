-- PaladinSetup: Ret-leaning generalist defaults that work for Holy/Prot too.
-- Untrained spells skip silently via SetupCore, so spec-specific spells just
-- don't appear if untrained.
--
-- BAR LAYOUT (matches Shaman/Druid/Hunter; see bar_layout_design.md memory):
--   Bar 1 = MAIN TOP (12 buttons, 6×2) — `, 1, 2, 3, 4, 5 / _, Q, _, E, R, T
--   Bar 3 = MAIN BOTTOM (12 buttons, 6×2) — _, _, _, F, G, _ / _, Z, X, C, V, B
--   Bar 4 = ALT TOP (mirror of Bar 1)
--   Bar 5 = ALT BOTTOM (mirror of Bar 3)
--   Bar 7 = DISABLED
--   Bar 9 = DISABLED
--   Bar 10 = CONSUMABLES (preserved across /setupbars)
--
-- Paladin-specific notes:
--   * Judgement on `` ` `` — single spell that judges the active seal; always-ready.
--   * Crusader Strike on key 1 with `startattack` — Ret melee filler that engages auto-attack.
--   * Seals on F/G — Righteousness primary, Crusader/Wisdom situational.
--   * Hands (BoF/BoP/BoS/Cleanse/DI) on Alt-cluster — tactical in-combat use.
--   * No Attack slot (per auto_attack_no_slot.md memory).
--
-- OPie rings (M4, M5):
--   M4 = Paladin Blessings (Might/Wisdom/Kings/Sanctuary/Salvation/Light + greater variants)
--   M5 = Paladin Auras (Devotion/Retribution/Concentration/Crusader/Resistance/Sanctity)

local LAYOUT = {
    -- MAIN TOP (Bar 1) — INSTANTS only on numrow; cast-time damage (Exorcism, Holy
    -- Wrath) moved to Alt-numrow per class_setup_pattern.md "casts on alt".
    -- Judgement on ` is the "always-ready combat-modifier" exception (instant, no CD
    -- gate, defines the always-pressable Pally combat slot).
    {"Judgement",              1, 1},                     -- L4    `   (always-ready; judges active seal)
    {"Crusader Strike",        1, 2, "startattack"},      -- L20   1   (Ret melee filler + engages auto-attack)
    {"Hammer of Wrath",        1, 3},                     -- L44   2   (instant execute sub-20% HP)
    {"Consecration",           1, 4},                     -- L20   3   (instant ground AOE)
    -- QERT row (Q/E/R/T): heals (mouseover-friendly)
    {"Holy Light",             1, 8, "mouseover-help"},   -- L1    Q
    {"Flash of Light",         1, 10, "mouseover-help"},  -- L20   E
    {"Holy Shock",             1, 11, "mouseover-help"},  -- L40 Holy R (talent — empty if untrained)
    {"Lay on Hands",           1, 12, "mouseover-help"},  -- L10   T   (60min CD full-HP)

    -- MAIN BOTTOM (Bar 3) — F/G seals; ZXCVB defensives + CC
    -- F/G row: primary + secondary seal toggles
    {"Seal of Righteousness",  3, 5},                     -- L1    F   (default melee damage proc; right-aligned)
    {"Seal of the Crusader",   3, 6},                     -- L12   G   (judge for armor debuff opener)
    -- ZXCVB row: stuns, defensives, utility
    {"Hammer of Justice",      3, 8},                     -- L8    Z   (6s stun)
    {"Divine Shield",          3, 9, "self-cast"},        -- L18   X   (8s full immunity)
    -- C left empty — startattack template + right-click cover auto-attack
    {"Divine Protection",      3, 11, "self-cast"},       -- L6    V   (50% damage reduction)
    {"Repentance",             3, 12, "mouseover-harm"},  -- L40 Ret B (6s incapacitate; talent)

    -- ALT TOP (Bar 4) — CAST-TIME damage + CDs + heals/Hand spells
    -- Cast-time damage (Exorcism, Holy Wrath) lives here per "casts on alt" rule.
    {"Exorcism",               4, 2},                     -- L20   Alt-1 (cast vs Undead/Demon)
    {"Holy Wrath",             4, 3},                     -- L30   Alt-2 (TBC cast AOE vs Undead/Demon)
    {"Avenging Wrath",         4, 4, "self-cast"},        -- L40 Ret Alt-3 (+30% dmg/heal CD)
    {"Avenger's Shield",       4, 5},                     -- L40 Prot Alt-4 (ranged taunt)
    -- Alt-QERT: dispel + friendly Hand spells (mouseover-friendly)
    {"Purify",                 4, 8, "mouseover-help"},   -- L8    Alt-Q (disease/poison; Holy spec swaps to Cleanse manually after L42 talent)
    {"Blessing of Freedom",    4, 10, "mouseover-help"},  -- L18   Alt-E (snare break)
    {"Blessing of Protection", 4, 11, "mouseover-help"},  -- L10   Alt-R (BoP physical immunity)
    {"Blessing of Sacrifice",  4, 12, "mouseover-help"},  -- L30 Prot/Holy Alt-T (damage redirect)

    -- ALT BOTTOM (Bar 5) — utility heals + emergency + rez
    -- Alt-FG: hands continued
    {"Divine Intervention",    5, 5, "mouseover-help"},   -- L30   Alt-F (sacrifice for friend invuln; right-aligned)
    {"Redemption",             5, 6, "mouseover-help"},   -- L12   Alt-G (out-of-combat rez)
    -- Alt-ZXCVB: leave open for player customization (resistance auras, situational seals)
}

local IGNORE = {
    -- Combat passives + universal stuff
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true, ["Parry"]=true,
    ["Plate Mail"]=true, ["Mail"]=true, ["Shield"]=true,
    ["Two-Handed Maces"]=true, ["Two-Handed Swords"]=true, ["Two-Handed Axes"]=true,
    ["One-Handed Maces"]=true, ["One-Handed Swords"]=true, ["One-Handed Axes"]=true,
    ["Polearms"]=true, ["Daggers"]=true,
    -- Paladin talent passives (no slot needed)
    ["Divine Strength"]=true, ["Divine Intellect"]=true, ["Healing Light"]=true,
    ["Improved Lay on Hands"]=true, ["Improved Blessing of Wisdom"]=true,
    ["Spell Warding"]=true, ["Anticipation"]=true,
    ["Improved Righteous Fury"]=true, ["Toughness"]=true,
    ["Reckoning"]=true, ["Improved Hammer of Justice"]=true,
    ["Pursuit of Justice"]=true, ["Vindication"]=true,
    ["Improved Seal of the Crusader"]=true, ["Conviction"]=true,
    ["Two-Handed Weapon Specialization"]=true, ["Vengeance"]=true,
    ["Sanctified Judgement"]=true, ["Crusade"]=true, ["Precision"]=true,
    ["Holy Shield"]=true, ["Improved Devotion Aura"]=true,
    ["Improved Concentration Aura"]=true, ["Improved Retribution Aura"]=true,
    ["Sanctity Aura"]=true, ["Improved Sanctity Aura"]=true,
    ["Righteous Fury"]=true,
    -- Blessings — handled by OPie ring (M4)
    ["Blessing of Might"]=true, ["Blessing of Wisdom"]=true,
    ["Blessing of Kings"]=true, ["Blessing of Sanctuary"]=true,
    ["Blessing of Salvation"]=true, ["Blessing of Light"]=true,
    ["Greater Blessing of Might"]=true, ["Greater Blessing of Wisdom"]=true,
    ["Greater Blessing of Kings"]=true, ["Greater Blessing of Sanctuary"]=true,
    ["Greater Blessing of Salvation"]=true, ["Greater Blessing of Light"]=true,
    -- Auras — handled by OPie ring (M5)
    ["Devotion Aura"]=true, ["Retribution Aura"]=true,
    ["Concentration Aura"]=true, ["Shadow Resistance Aura"]=true,
    ["Frost Resistance Aura"]=true, ["Crusader Aura"]=true,
    ["Fire Resistance Aura"]=true,
    -- Other seals (only Righteousness + Crusader on bar; rest left for /castsequence)
    ["Seal of Command"]=true, ["Seal of Light"]=true, ["Seal of Wisdom"]=true,
    ["Seal of Justice"]=true, ["Seal of Blood"]=true, ["Seal of Vengeance"]=true,
    -- Race passives (Human / Dwarf / Draenei / Blood Elf — TBC Paladin races)
    ["The Human Spirit"]=true, ["Sword Specialization"]=true,
    ["Mace Specialization"]=true, ["Diplomacy"]=true,
    ["Stoneform"]=true, ["Find Treasure"]=true,
    ["Gun Specialization"]=true, ["Frost Resistance"]=true,
    ["Heroic Presence"]=true, ["Inspiring Presence"]=true,
    ["Shadow Resistance"]=true, ["Magic Resistance"]=true,
    -- Race actives — Stoneform/Arcane Torrent auto-placed via RACIALS table.
    -- Gift of the Naaru: Pally Alt-QERT row is full of Hand spells; Draenei drag manually.
    ["Perception"]=true, ["Gift of the Naaru"]=true,
    ["Mana Tap"]=true,
    -- Cleanse upgrades Purify (Holy talent L42) — Holy spec drags it to Alt-Q manually
    ["Cleanse"]=true,
    -- Professions / non-combat
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Gemcutting"]=true, ["Mining"]=true, ["Smelting"]=true,
    ["Herbalism"]=true, ["Skinning"]=true, ["Fishing"]=true,
    ["Enchanting"]=true, ["Disenchant"]=true, ["Alchemy"]=true,
    ["Tailoring"]=true, ["Leatherworking"]=true, ["Engineering"]=true,
    ["Blacksmithing"]=true, ["Jewelcrafting"]=true,
    ["Inscription"]=true, ["Milling"]=true,
}

-- Per-race racial placement (per docs/racials.md). Pally races: Human, Dwarf,
-- Draenei (Alliance); Blood Elf (Horde, TBC). No combat racial for Human.
local RACIALS = {
    Dwarf = {
        {"Stoneform", 5, 8, "self-cast"},     -- Alt-Z: defensive break (joins alt-bottom defensives)
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},            -- C: combat CC + mana burst
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:PrintResults("PaladinSetup", placed, skipped, orphans)
    print("|cffffd700PaladinSetup tip:|r Blessings live on OPie M4, Auras on M5.")
    print("|cff999999  Seals: Righteousness on F (default), Crusader on G (open with judge for armor debuff).|r")
    print("|cff999999  Holy spec: Holy Shock auto-fills Alt-R when trained.|r")
    print("|cff999999  Holy talent: Cleanse upgrades Purify on Alt-Q — drag manually after L42.|r")
    print("|cff999999  Prot spec: Avenger's Shield auto-fills Alt-2 when trained.|r")
end

SetupCore:RegisterClass("PALADIN", Run, LAYOUT)

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- Uses {{spell:NNN}} macro syntax; OPie resolves to highest known rank.
-- Blessings are friend-targeted — OPie casts on cursor target by default.
-- ===========================================================================
do
    local R = OPie and OPie.CustomRings
    if not (R and R.AddDefaultRing) then return end

    -- Blessings ring (M4 hold) — single + greater (greater preferred when known).
    R:AddDefaultRing("PaladinBlessings", {
        {id="/cast {{spell:19740}}", _u="bm"}, -- Blessing of Might
        {id="/cast {{spell:19742}}", _u="bw"}, -- Blessing of Wisdom
        {id="/cast {{spell:20217}}", _u="bk"}, -- Blessing of Kings
        {id="/cast {{spell:20911}}", _u="bs"}, -- Blessing of Sanctuary
        {id="/cast {{spell:1038}}",  _u="bv"}, -- Blessing of Salvation
        {id="/cast {{spell:19977}}", _u="bl"}, -- Blessing of Light
        -- Greater variants (TBC L60+ raid blessings)
        {id="/cast {{spell:25898}}", _u="gk"}, -- Greater Blessing of Kings
        {id="/cast {{spell:25894}}", _u="gm"}, -- Greater Blessing of Might
        {id="/cast {{spell:25918}}", _u="gw"}, -- Greater Blessing of Wisdom
        {id="/cast {{spell:25895}}", _u="gv"}, -- Greater Blessing of Salvation
        name = "Blessings", hotkey = "BUTTON4", _u = "PldBls", v = 1,
    })

    -- Auras ring (M5 hold) — mutually-exclusive aura toggles.
    R:AddDefaultRing("PaladinAuras", {
        {id="/cast {{spell:465}}",   _u="dv"}, -- Devotion Aura
        {id="/cast {{spell:7294}}",  _u="rt"}, -- Retribution Aura
        {id="/cast {{spell:19746}}", _u="cn"}, -- Concentration Aura
        {id="/cast {{spell:19899}}", _u="cr"}, -- Crusader Aura (mount speed)
        {id="/cast {{spell:19891}}", _u="sr"}, -- Shadow Resistance Aura
        {id="/cast {{spell:19888}}", _u="fr"}, -- Frost Resistance Aura
        {id="/cast {{spell:19876}}", _u="ir"}, -- Fire Resistance Aura
        {id="/cast {{spell:20218}}", _u="sa"}, -- Sanctity Aura (Ret talent)
        name = "Auras", hotkey = "BUTTON5", _u = "PldAur", v = 1,
    })
end
