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

local LAYOUT = {
    -- Number row: shocks
    {"Earth Shock",            1, 1},  -- `
    {"Flame Shock",            1, 2},  -- 1
    {"Frost Shock",            1, 3},  -- 2 (skips silently if not trained)

    -- QERT row: earth totems
    {"Stoneclaw Totem",        2, 1},  -- Q
    {"Earthbind Totem",        2, 3},  -- E
    {"Strength of Earth Totem",2, 4},  -- R
    {"Stoneskin Totem",        2, 5},  -- T

    -- FG row: buffs/utility
    {"Lightning Shield",       3, 1},  -- F
    {"Gift of the Naaru",      3, 2},  -- G

    -- ZXCVB row: weapon enchants + auto-attack
    {"Rockbiter Weapon",       4, 1},  -- Z
    {"Flametongue Weapon",     4, 2},  -- X
    {"Attack",                 4, 3},  -- C

    -- Alt rows: cast-time spells
    {"Lightning Bolt",         5, 2},  -- Alt-1
    {"Healing Wave",           6, 1},  -- Alt-Q
    {"Ancestral Spirit",       6, 3},  -- Alt-E

    -- Shift row: fire totems
    {"Searing Totem",          9, 1},  -- Shift-Q
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

SLASH_SETUPBARS1 = "/setupbars"
SlashCmdList["SETUPBARS"] = function()
    ClearAllBars()
    local placed, skipped = 0, {}
    for _, item in ipairs(LAYOUT) do
        if PlaceSpell(item[1], item[2], item[3]) then
            placed = placed + 1
        else
            table.insert(skipped, item[1])
        end
    end
    print("|cff00ff00ShamanSetup|r placed "..placed.." spells")
    if #skipped > 0 then
        print("|cff999999Skipped (not trained):|r "..table.concat(skipped, ", "))
    end
end
