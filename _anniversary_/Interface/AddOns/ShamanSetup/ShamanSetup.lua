-- Edit LAYOUT below as you train new spells, then /reload + /setupbars in-game.
-- Format: {spell name, ElvUI bar number, button index within bar}
-- Bar/slot reference (current keyboard-mirror layout):
--   Bar 1 = ` 1 2 3 4 5  (button 1=`, 2=1, ..., 6=5)
--   Bar 2 = Q _ E R T    (button 1=Q, 2=W gap, 3=E, 4=R, 5=T)
--   Bar 3 = F G          (button 1=F, 2=G)
--   Bar 4 = Z X C V B    (button 1=Z, ..., 5=B)
--   Bar 5 = Alt-` Alt-1..Alt-5  (button 1=Alt-`, ..., 6=Alt-5)
--   Bar 6 = Alt-Q _ Alt-E Alt-R Alt-T
--   Bar 7 = Alt-F Alt-G
--   Bar 8 = Alt-Z Alt-X Alt-C Alt-V Alt-B
--   Bar 9 = Shift-Q _ Shift-E Shift-R Shift-T  (fire totems)

-- Pre-loaded with the full TBC Shaman roster (level 1-60+).
-- Untrained spells are skipped silently; running /setupbars after every ding
-- will auto-place newly-trained spells in their reserved slot.

local LAYOUT = {
    -- Number row (Bar 1): shocks + utility
    {"Earth Shock",            1, 1},  -- L4    `
    {"Flame Shock",            1, 2},  -- L10   1
    {"Frost Shock",            1, 3},  -- L12   2
    {"Far Sight",              1, 4},  -- L18   3
    {"Astral Recall",          1, 5},  -- L30   4

    -- QERT row (Bar 2): earth totems
    {"Stoneclaw Totem",        2, 1},  -- L8    Q
    {"Earthbind Totem",        2, 3},  -- L10   E
    {"Strength of Earth Totem",2, 4},  -- L4    R
    {"Stoneskin Totem",        2, 5},  -- L4    T

    -- FG row (Bar 3): buffs/racial
    {"Lightning Shield",       3, 1},  -- L8    F
    {"Gift of the Naaru",      3, 2},  -- racial G

    -- ZXCVB row (Bar 4): weapon enchants + auto-attack
    {"Rockbiter Weapon",       4, 1},  -- L1    Z
    {"Flametongue Weapon",     4, 2},  -- L10   X
    {"Attack",                 4, 3},  -- L1    C
    {"Frostbrand Weapon",      4, 4},  -- L20   V
    {"Windfury Weapon",        4, 5},  -- L30   B

    -- Alt-12345 (Bar 5): damage/buff casts
    {"Lightning Bolt",         5, 2},  -- L1    Alt-1
    {"Chain Lightning",        5, 3},  -- L32   Alt-2
    {"Water Shield",           5, 4},  -- L20   Alt-3 (alt to Lightning Shield)

    -- Alt-QERT (Bar 6): heals + rez
    {"Healing Wave",           6, 1},  -- L6    Alt-Q
    {"Ancestral Spirit",       6, 3},  -- L12   Alt-E
    {"Lesser Healing Wave",    6, 4},  -- L20   Alt-R
    {"Chain Heal",             6, 5},  -- L40   Alt-T

    -- Alt-FG (Bar 7): utility
    {"Tremor Totem",           7, 1},  -- L18   Alt-F (panic fear-break)
    {"Ghost Wolf",             7, 2},  -- L16   Alt-G

    -- Alt-ZXCVB (Bar 8): travel/water utility
    {"Water Breathing",        8, 1},  -- L24   Alt-Z
    {"Water Walking",          8, 2},  -- L28   Alt-X

    -- Shift-QERT (Bar 9): fire totems
    {"Searing Totem",          9, 1},  -- L10   Shift-Q
    {"Fire Nova Totem",        9, 3},  -- L14   Shift-E
    {"Magma Totem",            9, 4},  -- L40   Shift-R
    {"Flametongue Totem",      9, 5},  -- L30   Shift-T

    -- Future: Bar 10 + Ctrl modifier for water totems (Healing Stream L20,
    -- Mana Spring L26, Disease/Poison Cleansing L38/40). Not yet wired up.
}

local function FindHighestRank(name)
    local last
    for j = 1, 200 do
        local sname = GetSpellBookItemName(j, "spell")
        if not sname then break end
        if sname == name then last = j end
    end
    return last
end

local function ClearAllBars()
    for b = 1, 10 do
        for i = 1, 12 do
            local btn = _G["ElvUI_Bar"..b.."Button"..i]
            if btn then
                local slot = btn:GetAttribute("action")
                if slot then
                    PickupAction(slot)
                    ClearCursor()
                end
            end
        end
    end
end

local function PlaceSpell(name, bar, btn)
    local idx = FindHighestRank(name)
    if not idx then return false end
    local b = _G["ElvUI_Bar"..bar.."Button"..btn]
    if not b then return false end
    local slot = b:GetAttribute("action")
    if not slot then return false end
    PickupSpellBookItem(idx, "spell")
    if GetCursorInfo() == "spell" then
        PlaceAction(slot)
    end
    ClearCursor()
    return true
end

local IGNORE = {
    -- spells I don't want flagged as orphans (passives, racials, profs)
    ["Attack"]=true, ["Block"]=true, ["Dodge"]=true,
    ["Inspiring Presence"]=true, ["Shadow Resistance"]=true,
    ["First Aid"]=true, ["Cooking"]=true, ["Basic Campfire"]=true,
    ["Gemcutting"]=true, ["Mining"]=true, ["Smelting"]=true,
    ["Herbalism"]=true, ["Skinning"]=true, ["Fishing"]=true,
    ["Reincarnation"]=true,  -- automatic on death, no slot needed
}

SLASH_SETUPBARS1 = "/setupbars"
SlashCmdList["SETUPBARS"] = function()
    ClearAllBars()

    -- Place known layout
    local placed, skipped = 0, {}
    for _, item in ipairs(LAYOUT) do
        if PlaceSpell(item[1], item[2], item[3]) then
            placed = placed + 1
        else
            table.insert(skipped, item[1])
        end
    end

    -- Detect spells in spellbook that aren't in LAYOUT (orphans)
    local mapped = {}
    for _, item in ipairs(LAYOUT) do mapped[item[1]] = true end
    local orphans, seen = {}, {}
    for j = 1, 200 do
        local sname = GetSpellBookItemName(j, "spell")
        if not sname then break end
        if not mapped[sname] and not IGNORE[sname] and not seen[sname] then
            table.insert(orphans, sname)
            seen[sname] = true
        end
    end

    print("|cff00ff00ShamanSetup|r placed "..placed.." spells")
    if #skipped > 0 then
        print("|cff999999Skipped (not yet trained):|r "..table.concat(skipped, ", "))
    end
    if #orphans > 0 then
        print("|cffffaa00Orphans (trained but unmapped):|r "..table.concat(orphans, ", "))
    end
end
