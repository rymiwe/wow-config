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
--   * Hammer of Justice on `` ` `` for cross-class interrupt convention (stun-interrupt).
--   * Judgement on Q — most-pressed Ret/tank button, judges the active seal.
--   * Consecration on E — signature AoE-threat tool; moved off numrow "3" for
--     the easier WASD-adjacent reach. Still not a true spam-key (mana cost),
--     but it's the most decision-critical per-pull button, so fast/reliable
--     access matters even at moderate frequency.
--   * Crusader Strike on key 1 with `startattack` — Ret melee filler that engages auto-attack.
--   * Seals on F/G/V — Righteousness primary, Crusader opener, Wisdom mana-sustain (L38+).
--   * Hands (BoF/BoP/BoS/Cleanse/DI) on Alt-cluster — tactical in-combat use.
--   * Divine Shield/Divine Protection moved behind Alt (Alt-R/Alt-B) — both
--     are long-CD "oh crap" buttons that were too easy to fat-finger on the
--     open ZXCVB row; a modifier press is a deliberate decision, same logic
--     already used for Lay on Hands.
--   * Righteous Fury and Redemption are NOT in LAYOUT - user manually placed
--     both on Bar 10 (the protected utility bar, never touched by
--     /setupbars) to keep the keybound Bar 1/3/4/5 grid at its standard
--     shape. Both are IGNORE'd so /setupbars doesn't nag about them.
--   * Righteous Defense uses the "redirect-taunt" template (mouseovertarget-
--     first) so you point at the MOB, not the ally it's attacking - closer
--     to how a normal taunt feels. Also bound to Ctrl+M3 (M3 alone = dispel,
--     Shift+M3 = ElvUI raid-marker radial).
--   * No Attack slot (per auto_attack_no_slot.md memory).
--
-- OPie rings (M4, M5):
--   M4 = Paladin Blessings (Might/Wisdom/Kings/Sanctuary/Salvation/Light + greater variants)
--   M5 = Paladin Auras (Devotion/Retribution/Concentration/Crusader/Resistance/Sanctity)

-- MOVEMENT-OPTIMAL profile: ALL instants on main (un-modified) bar so the
-- player can fire them while moving. ALL cast-time spells on Alt bar (you're
-- standing still to cast anyway, modifier hold is free). Hand spells (BoF/
-- BoP/BoS) are instants -> they move from Alt-QERT (old layout) to Bar 3
-- ZXCVB. Heals split: instant heals (Holy Shock, LoH) on QERT main; cast
-- heals (Holy Light, Flash of Light) on Alt-numrow.
local LAYOUT = {
    -- MAIN TOP (Bar 1) - DAMAGE INSTANTS on numrow
    -- ` holds Hammer of Justice for cross-class interrupt convention (Shaman:
    -- Earth Shock, Mage: Counterspell, Rogue: Kick all on `). HoJ is a 6s
    -- stun = effective interrupt for casters. Judgement moves to Q (most-
    -- pressed Ret button, ergonomic finger reach).
    {"Hammer of Justice",      1, 1},                     -- L8    `   (interrupt-by-stun; NO startattack - HoJ may be used on a CC'd target to chain-stun, /startattack would break the upstream CC)
    {"Crusader Strike",        1, 2, "startattack"},      -- L20   1   (Ret melee + engages auto-attack)
    {"Hammer of Wrath",        1, 3},                     -- L44   2   (instant execute sub-20%)
    {"Holy Shield",            1, 4, "self-cast"},        -- L40 Prot 3 (block chance + Holy block damage - core tank cooldown; slot freed by moving Consecration to E)
    {"Avenger's Shield",       1, 5},                     -- L40 Prot 4 (instant ranged taunt - moved from alt)
    {"Avenging Wrath",         1, 6, "self-cast"},        -- L40 Ret 5 (instant CD)
    -- QERT row: rotation builder + AOE threat + dispel + heal-CD
    {"Judgement",              1, 8, "startattack"},      -- L4    Q   (most-pressed Ret combat - judges active seal)
    {"Consecration",           1, 10},                    -- L20   E   (signature AoE-threat tool - moved off numrow "3"; see header notes on the mana-cost tradeoff)
    {"Purify",                 1, 11, "pally-dispel"},    -- L8    R   (Cleanse-or-Purify cascade, works any spec)
    {"Righteous Defense",      1, 12, "redirect-taunt"},  -- TBC L66 T (point at the mob, not the ally - see redirect-taunt template)

    -- MAIN BOTTOM (Bar 3) - F/G/V seals; ZXC hand spells; keyless click slot
    {"Seal of Righteousness",  3, 5},                     -- L1    F   (default melee proc)
    {"Seal of the Crusader",   3, 6},                     -- L12   G   (judge for armor debuff opener)
    -- ZXC: Hand spells (mouseover-help instants) that keep fast access
    {"Blessing of Freedom",    3, 8, "mouseover-help"},   -- L18   Z   (instant snare break)
    {"Blessing of Protection", 3, 9, "mouseover-help"},   -- L10   X   (instant physical immunity)
    {"Blessing of Sacrifice",  3, 10, "mouseover-help"},  -- L30   C   (instant damage redirect)
    {"Seal of Wisdom",         3, 11},                    -- L38   V   (mana-return seal; slot freed by moving Divine Shield to Alt-R)
    -- B left empty (was Divine Protection - moved to Alt-B, see ALT BOTTOM below)

    -- ALT TOP (Bar 4) - CAST-TIME spells + demoted instants
    {"Holy Light",             4, 2, "mouseover-help"},   -- L1    Alt-1 (primary cast heal)
    {"Flash of Light",         4, 3, "mouseover-help"},   -- L20   Alt-2 (fast cast heal)
    {"Exorcism",               4, 4},                     -- L20   Alt-3 (cast vs Undead/Demon)
    {"Holy Wrath",             4, 5},                     -- L30   Alt-4 (TBC cast AOE vs Undead/Demon)
    {"Repentance",             4, 6, "focus-mouseover-harm"}, -- L40 Ret Alt-5 (cast CC; focus-first)
    -- Alt-QERT: rez + niche cast utility + tank taunt
    {"Lay on Hands",           4, 10, "mouseover-help"},  -- L10   Alt-E (60-min CD emergency 100% heal - decision-time button, modifier OK)
    {"Divine Shield",          4, 11, "self-cast"},       -- L18   Alt-R (full immunity - demoted behind modifier so it can't be bumped mid-combat; slot freed by moving Redemption to the utility bar)
    {"Holy Shock",             4, 12, "mouseover-help"},  -- L40 Holy Alt-T (instant heal CD - Holy talent only, demoted from main T to free that for Righteous Defense)

    -- ALT BOTTOM (Bar 5) - rare instants that don't fit on main + niche
    -- These violate "casts only on alt" by necessity (low-pri instants exceed main bar capacity).
    {"Divine Intervention",    5, 5, "mouseover-help"},   -- L30   Alt-F (rare friend invuln rez setup - instant)
    -- Alt-G: Draenei Gift of the Naaru (cast heal racial) via RACIALS - matches
    -- the Alt-G convention already used on Asog (Shaman) and PriestSetup.
    {"Divine Favor",           5, 7, "self-cast"},        -- L20 Holy (instant crit-heal CD - Holy talent; NOTE: no key is bound to this slot in SetupCore's BINDINGS - click-only)
    -- Alt-X reserved via RACIALS for Draenei (was previous Naaru slot - now Naaru moved to Alt-Q)
    {"Divine Plea",            5, 10, "self-cast"},       -- Alt-C (instant mana CD - VERIFY this trains in TBC; may be Wrath-only, double check via trainer given this ruleset's non-standard spell levels)
    -- Alt-V left empty (placeholder for racial)
    {"Divine Protection",      5, 12, "self-cast"},       -- L6    Alt-B (50% damage reduction - demoted behind modifier so it can't be bumped mid-combat; slot freed by moving Righteous Fury to the utility bar)
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
    ["Improved Righteous Fury"]=true, ["Toughness"]=true,  -- "Improved" is the talent passive
    -- Righteous Fury and Redemption: user manually placed both on the
    -- protected utility bar (outside /setupbars management) to keep the
    -- keybound Bar 1/3/4/5 grid at its standard shape. Not in LAYOUT anymore -
    -- ignored here so /setupbars doesn't nag about them being unmapped.
    ["Righteous Fury"]=true, ["Redemption"]=true,
    ["Reckoning"]=true, ["Improved Hammer of Justice"]=true,
    ["Pursuit of Justice"]=true, ["Vindication"]=true,
    ["Improved Seal of the Crusader"]=true, ["Conviction"]=true,
    ["Two-Handed Weapon Specialization"]=true, ["Vengeance"]=true,
    ["Sanctified Judgement"]=true, ["Crusade"]=true, ["Precision"]=true,
    ["Improved Devotion Aura"]=true,
    ["Improved Concentration Aura"]=true, ["Improved Retribution Aura"]=true,
    ["Sanctity Aura"]=true, ["Improved Sanctity Aura"]=true,
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
    -- Other seals (Righteousness + Crusader + Wisdom on bar; rest left for /castsequence)
    ["Seal of Command"]=true, ["Seal of Light"]=true,
    ["Seal of Justice"]=true, ["Seal of Blood"]=true, ["Seal of Vengeance"]=true,
    -- Race passives (Human / Dwarf / Draenei / Blood Elf — TBC Paladin races)
    ["The Human Spirit"]=true, ["Sword Specialization"]=true,
    ["Mace Specialization"]=true, ["Diplomacy"]=true,
    ["Stoneform"]=true, ["Find Treasure"]=true,
    ["Gun Specialization"]=true, ["Frost Resistance"]=true,
    ["Heroic Presence"]=true, ["Inspiring Presence"]=true,
    ["Shadow Resistance"]=true, ["Magic Resistance"]=true,
    -- Race actives — Stoneform/Arcane Torrent auto-placed via RACIALS table.
    -- Gift of the Naaru handled via RACIALS table (Draenei -> Alt-G, matching
    -- the Shaman/Priest convention). NOT in IGNORE.
    ["Perception"]=true,
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
        {"Stoneform", 5, 7, "self-cast"},     -- defensive break (Alt-Z = mount)
    },
    Draenei = {
        {"Gift of the Naaru", 5, 6, "mouseover-help"},  -- Alt-G: matches the convention already used on Asog (Shaman) and PriestSetup
    },
    BloodElf = {
        {"Arcane Torrent", 3, 10},            -- C: combat CC + mana burst
    },
}

local function Run()
    local placed, skipped, orphans = SetupCore:ApplyLayout(LAYOUT, IGNORE, RACIALS)
    SetupCore:RefreshDecurseBinding()
    SetupCore:PrintResults("PaladinSetup", placed, skipped, orphans)
    print("|cffffd700PaladinSetup tip:|r Movement-optimal - instants on main, casts on Alt-bar.")
    print("|cff999999  Middle-click (M3) = dispel mouseover. Ctrl+M3 = taunt-redirect (point at the mob).|r")
    print("|cff999999  ` = Hammer of Justice (interrupt). Q = Judgement. E = Consecration (AoE threat).|r")
    print("|cff999999  T = Righteous Defense (taunt-redirect). Alt-T = Holy Shock (Holy heal CD).|r")
    print("|cff999999  Hand spells (BoF/BoP/BoS) on Z/X/C - mouseover any party member.|r")
    print("|cff999999  Divine Shield/Protection moved to Alt-R/Alt-B (too easy to bump on the open row).|r")
    print("|cff999999  Righteous Fury and Redemption live on Bar 10 (utility) - not managed by /setupbars.|r")
    print("|cff999999  Blessings: hold M4 (OPie ring). Auras: hold M5. Raid markers: hold Shift+M3 (ElvUI).|r")
end

SetupCore:RegisterClass("PALADIN", Run, LAYOUT)
SetupCore:RegisterDecurseMacro("SC_Purify", "PALADIN")
-- Ctrl+M3 = taunt-redirect (Righteous Defense's existing mouseover macro,
-- also bound to T). M3 alone is dispel, Shift+M3 is ElvUI's raid-marker
-- radial - Ctrl is the next free modifier on that button.
-- Macro name is SetupCore's truncated-to-16-char "SC_"+spellname convention
-- (confirmed via this character's own macros-cache.txt: "SC_RighteousDefe").
SetupCore:RegisterMacroBinding("CTRL-BUTTON3", "SC_RighteousDefe", "PALADIN")

-- ===========================================================================
-- OPie ring registration — only fires if OPie is installed (graceful no-op).
-- Uses {{spell:NNN}} macro syntax; OPie resolves to highest known rank.
-- Blessings are friend-targeted — OPie casts on cursor target by default.
-- ===========================================================================
do
    -- Class-conditional: see ShamanSetup for rationale (cross-class M4/M5 collision).
    local _, class = UnitClass("player")
    if class ~= "PALADIN" then return end
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
