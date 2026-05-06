-- SetupCore: shared plumbing for class setup addons.
-- Class addons (ShamanSetup, DruidSetup, etc.) call SetupCore:ApplyLayout(LAYOUT, IGNORE)
-- and register themselves via SetupCore:RegisterClass(class, applyFn) for first-login auto-run.
--
-- LAYOUT entry format:
--   {spellName, bar, button}                    -- raw spell, no macro
--   {spellName, bar, button, "templateName"}    -- generated macro (mouseover etc.)
--
-- Available macro templates:
--   "mouseover-help"        : cast on mouseover>target>self if friendly+alive
--   "mouseover-harm"        : cast on mouseover>target if hostile+alive
--   "focus-mouseover-harm"  : cast on focus>mouseover>target if hostile (CC pattern)
--   "startattack"           : add /startattack before /cast (melee combat)
--   "self-cast"             : always @player (raw self-cast)

SetupCoreDB = SetupCoreDB or {}
SetupCoreCharDB = SetupCoreCharDB or {}
SetupCore = SetupCore or {}

local registered = {}
local registeredLayouts = {}

-- Channels auto-left on first login of each new character.
local CHANNELS_TO_LEAVE = {"General", "Trade", "LocalDefense", "LookingForGroup"}

-- Macro templates: function(spellName) -> macro body string.
-- Generated macros are named "SC_<spellNameNoSpaces>" so they're idempotent
-- across re-runs of /setupbars.
local MACRO_TEMPLATES = {
    -- Heal/buff target priority (community standard for healers):
    -- focus -> mouseover -> current target -> self
    -- Why: focus is "I deliberately set this person as priority" (often the tank);
    -- mouseover wins over current target because the cursor is an explicit gesture
    -- and your current target is usually an enemy you're attacking.
    ["mouseover-help"] = function(spell)
        return "#showtooltip\n/cast [@focus,help,nodead][@mouseover,help,nodead][help,nodead][@player] " .. spell
    end,
    ["mouseover-harm"] = function(spell)
        return "#showtooltip\n/cast [@mouseover,harm,nodead][harm,nodead] " .. spell
    end,
    ["focus-mouseover-harm"] = function(spell)
        return "#showtooltip\n/cast [@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] " .. spell
    end,
    ["startattack"] = function(spell)
        return "#showtooltip\n/startattack\n/cast " .. spell
    end,
    ["self-cast"] = function(spell)
        return "#showtooltip\n/cast [@player] " .. spell
    end,
    -- Druid form-shift safety wrappers — prevent accidental Cat↔Bear shifts
    -- mid-combat (which destroys energy/rage). Bear macro won't fire if in Cat
    -- (form 4); Cat macro won't fire if in Bear (form 1). Travel/Aquatic don't
    -- need protection (low-risk shifts). Includes /startattack so engaging the
    -- form at a target also begins auto-attack.
    ["druid-bear-safe"] = function(spell)
        return "#showtooltip\n/startattack\n/cast [noform:4] " .. spell
    end,
    ["druid-cat-safe"] = function(spell)
        return "#showtooltip\n/startattack\n/cast [noform:1] " .. spell
    end,
    -- Smart interrupt: focus first, then mouseover, then current target.
    -- Spell name is class-specific (Earth Shock for Shaman, Counterspell for
    -- Mage, Kick for Rogue, etc.). Class addons pass the right spell name.
    ["interrupt"] = function(spell)
        return "#showtooltip\n/cast [@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] " .. spell
    end,
}

-- Class addons can build a smart-interrupt macro by passing the class's
-- best interrupt spell name to SetupCore:EnsureMacro(name, "interrupt").
-- This generates a macro that the user can drag onto any bar slot they like
-- (e.g. ` on the special bar). NOT auto-placed by /setupbars — class addons
-- declare it via EnsureInterruptMacro and the user binds at their discretion.
function SetupCore:EnsureInterruptMacro(spellName)
    return self:EnsureMacro(spellName, "interrupt")
end

function SetupCore:RegisterClass(class, applyFn, layout)
    registered[class] = applyFn
    if layout then
        registeredLayouts[class] = layout
    end
end

-- Returns a list of LAYOUT spell names that:
--   1. Exist in the player's spellbook (trained), AND
--   2. Are NOT currently placed at their LAYOUT-specified bar slot
-- Used to nudge the user to /setupbars after training new spells.
function SetupCore:UnplacedLayoutSpells()
    local _, class = UnitClass("player")
    local layout = registeredLayouts[class]
    if not layout then return {} end
    local unplaced, seen = {}, {}
    for _, item in ipairs(layout) do
        local name, bar, btn = item[1], item[2], item[3]
        if not seen[name] and self:FindHighestRank(name) then
            local b = _G["ElvUI_Bar"..bar.."Button"..btn]
            if b then
                local slot = b:GetAttribute("action")
                if slot and not GetActionInfo(slot) then
                    table.insert(unplaced, name)
                    seen[name] = true
                end
            end
        end
    end
    return unplaced
end

function SetupCore:FindHighestRank(name)
    local last
    for j = 1, 200 do
        local sname = GetSpellBookItemName(j, "spell")
        if not sname then break end
        if sname == name then last = j end
    end
    return last
end

-- Clears action slots on bars 1..maxBar but ALWAYS skips Bar 10 (consumables).
-- Consumables are user-curated click-only items; clearing them every /setupbars
-- would force the user to re-drag food/water/scrolls on every layout refresh.
-- Pass `maxBar` = number of HIGHEST bar to clear (default 9).
function SetupCore:ClearAllBars(maxBar)
    maxBar = maxBar or 9
    for b = 1, maxBar do
        if b ~= 10 then
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
end

-- Snapshot all action-bar slots to SetupCoreCharDB.lastBackup. Saves enough
-- info to restore via /restorebars. Macros are stored by NAME (not index)
-- since macro indices shift if the user adds/removes macros.
function SetupCore:BackupBars(maxBar)
    maxBar = maxBar or 10
    local snapshot = {
        timestamp = date("%Y-%m-%d %H:%M:%S"),
        slots = {},
    }
    local count = 0
    for b = 1, maxBar do
        for i = 1, 12 do
            local btn = _G["ElvUI_Bar"..b.."Button"..i]
            if btn then
                local slot = btn:GetAttribute("action")
                if slot then
                    local actionType, id = GetActionInfo(slot)
                    if actionType == "spell" then
                        local name = GetSpellInfo(id)
                        snapshot.slots[slot] = {type = "spell", id = id, name = name}
                        count = count + 1
                    elseif actionType == "macro" then
                        local mname = GetMacroInfo(id)
                        snapshot.slots[slot] = {type = "macro", name = mname}
                        count = count + 1
                    elseif actionType == "item" then
                        snapshot.slots[slot] = {type = "item", id = id}
                        count = count + 1
                    end
                end
            end
        end
    end
    SetupCoreCharDB.lastBackup = snapshot
    return count, snapshot
end

-- Restore bars from SetupCoreCharDB.lastBackup. Clears current bars first.
function SetupCore:RestoreBars()
    local backup = SetupCoreCharDB.lastBackup
    if not backup or not backup.slots then
        print("|cffff0000SetupCore|r no backup found")
        return
    end
    self:ClearAllBars()
    local restored, missing = 0, 0
    for slot, info in pairs(backup.slots) do
        if info.type == "spell" then
            -- Re-pick by name to handle rank-up situations gracefully
            local idx = info.name and self:FindHighestRank(info.name)
            if idx then
                PickupSpellBookItem(idx, "spell")
            else
                PickupSpell(info.id)
            end
            if GetCursorInfo() == "spell" then
                PlaceAction(slot); restored = restored + 1
            else
                missing = missing + 1
            end
            ClearCursor()
        elseif info.type == "macro" then
            local idx = info.name and GetMacroIndexByName(info.name) or 0
            if idx > 0 then
                PickupMacro(idx)
                if GetCursorInfo() == "macro" then
                    PlaceAction(slot); restored = restored + 1
                end
                ClearCursor()
            else
                missing = missing + 1
            end
        elseif info.type == "item" then
            PickupItem(info.id)
            if GetCursorInfo() == "item" then
                PlaceAction(slot); restored = restored + 1
            else
                missing = missing + 1
            end
            ClearCursor()
        end
    end
    print(string.format("|cff00ff00SetupCore|r restored %d slots from backup taken %s%s",
        restored, backup.timestamp or "?",
        missing > 0 and string.format(" (%d couldn't be restored — spells unlearned, macros deleted, or items not in bag)", missing) or ""))
end

-- Generate a macro body using the named template. Creates a new macro or
-- updates an existing one with name "SC_<spellNameNoSpaces>". Returns the
-- macro's slot index, or nil if templates/slots/spell are missing.
function SetupCore:EnsureMacro(spellName, templateName)
    local tmpl = MACRO_TEMPLATES[templateName]
    if not tmpl then
        print("|cffff0000SetupCore|r unknown macro template: " .. tostring(templateName))
        return nil
    end
    local body = tmpl(spellName)
    local macroName = "SC_" .. (spellName:gsub("%s", ""):gsub("[^%w_]", ""))
    -- Truncate to WoW's 16-char macro name limit
    if #macroName > 16 then macroName = macroName:sub(1, 16) end

    -- Use the spell's icon if we can find it
    local _, _, icon = GetSpellInfo(spellName)
    icon = icon or "INV_Misc_QuestionMark"

    local idx = GetMacroIndexByName(macroName)
    if idx and idx > 0 then
        EditMacro(idx, macroName, icon, body)
        return idx
    end

    local numGlobal, numChar = GetNumMacros()
    if numChar < 18 then
        -- per-character slot available
        return CreateMacro(macroName, icon, body, true)
    elseif numGlobal < 18 then
        return CreateMacro(macroName, icon, body, false)
    else
        print("|cffff0000SetupCore|r macro slots full, can't create " .. macroName)
        return nil
    end
end

-- Create or update a macro with arbitrary body (for /castsequence and other
-- multi-spell macros that don't fit the spell-name template system).
-- Returns macro index or nil.
function SetupCore:EnsureRawMacro(macroName, body, icon)
    icon = icon or "INV_Misc_QuestionMark"
    if #macroName > 16 then macroName = macroName:sub(1, 16) end

    local idx = GetMacroIndexByName(macroName)
    if idx and idx > 0 then
        EditMacro(idx, macroName, icon, body)
        return idx
    end

    local numGlobal, numChar = GetNumMacros()
    if numChar < 18 then
        return CreateMacro(macroName, icon, body, true)
    elseif numGlobal < 18 then
        return CreateMacro(macroName, icon, body, false)
    else
        print("|cffff0000SetupCore|r macro slots full, can't create " .. macroName)
        return nil
    end
end

-- Place an existing macro by name on a bar slot. Companion to EnsureRawMacro.
function SetupCore:PlaceMacro(macroName, bar, btn)
    local b = _G["ElvUI_Bar"..bar.."Button"..btn]
    if not b then return false end
    local slot = b:GetAttribute("action")
    if not slot then return false end

    local idx = GetMacroIndexByName(macroName)
    if not idx or idx == 0 then return false end

    PickupMacro(idx)
    if GetCursorInfo() == "macro" then
        PlaceAction(slot)
    end
    ClearCursor()
    return true
end

function SetupCore:PlaceSpell(name, bar, btn, template)
    local b = _G["ElvUI_Bar"..bar.."Button"..btn]
    if not b then return false end
    local slot = b:GetAttribute("action")
    if not slot then return false end

    if template then
        -- Skip if the underlying spell isn't trained yet — no point creating a
        -- macro for a spell the player can't cast.
        if not self:FindHighestRank(name) then return false end
        local macroIdx = self:EnsureMacro(name, template)
        if not macroIdx then return false end
        PickupMacro(macroIdx)
        if GetCursorInfo() == "macro" then
            PlaceAction(slot)
        end
        ClearCursor()
        return true
    end

    local idx = self:FindHighestRank(name)
    if not idx then return false end
    PickupSpellBookItem(idx, "spell")
    if GetCursorInfo() == "spell" then
        PlaceAction(slot)
    end
    ClearCursor()
    return true
end

function SetupCore:ApplyLayout(layout, ignore)
    -- Snapshot existing bars before clearing, in case user wants to revert.
    local backedUp = self:BackupBars()
    if backedUp > 0 then
        print(string.format("|cff999999SetupCore|r backed up %d existing actions (use /restorebars to revert)", backedUp))
    end
    self:ClearAllBars()
    local placed, skipped = 0, {}
    for _, item in ipairs(layout) do
        local name, bar, btn, template = item[1], item[2], item[3], item[4]
        if self:PlaceSpell(name, bar, btn, template) then
            placed = placed + 1
        else
            table.insert(skipped, name)
        end
    end
    local mapped = {}
    for _, item in ipairs(layout) do mapped[item[1]] = true end
    ignore = ignore or {}
    local orphans, seen = {}, {}
    for j = 1, 200 do
        local sname = GetSpellBookItemName(j, "spell")
        if not sname then break end
        if not mapped[sname] and not ignore[sname] and not seen[sname] then
            table.insert(orphans, sname)
            seen[sname] = true
        end
    end
    return placed, skipped, orphans
end

function SetupCore:PrintResults(addonName, placed, skipped, orphans)
    print("|cff00ff00"..addonName.."|r placed "..placed.." spells")
    if #skipped > 0 then
        print("|cff999999Skipped (not yet trained):|r "..table.concat(skipped, ", "))
    end
    if #orphans > 0 then
        print("|cffffaa00Orphans (trained but unmapped):|r "..table.concat(orphans, ", "))
    end
end

-- One-shot welcome message after first auto-setup. Skipped on subsequent
-- logins. Helps new players (kids/spouses/friends) discover the key commands
-- without reading docs. Class-specific tips can be appended by class addons
-- via SetupCoreCharDB.welcomeExtras (a class addon writes a string there).
function SetupCore:PrintWelcome()
    if SetupCoreCharDB.welcomedShown then return end
    print("|cffffd700== wow-config welcome ==|r")
    print("|cffffffffYour bars are configured.|r Quick reference:")
    print("|cff999999  /setupbars|r — re-place spells (run after training new ones)")
    print("|cff999999  /restorebars|r — roll back to your previous bar setup")
    print("|cff999999  Hover a party member + press an Alt-row heal|r — heals them via mouseover")
    if SetupCoreCharDB.welcomeExtras then
        print("|cff999999  "..SetupCoreCharDB.welcomeExtras.."|r")
    end
    SetupCoreCharDB.welcomedShown = true
end

-- /setupbars dispatches to the class-registered Run function. Class addons
-- only need to RegisterClass themselves; they don't define their own slash.
SLASH_SETUPBARS1 = "/setupbars"
SlashCmdList["SETUPBARS"] = function()
    local _, class = UnitClass("player")
    local fn = registered[class]
    if fn then
        fn()
    else
        print("|cffffaa00SetupCore|r no setup registered for class " .. (class or "?"))
    end
end

SLASH_RESTOREBARS1 = "/restorebars"
SlashCmdList["RESTOREBARS"] = function() SetupCore:RestoreBars() end

-- Watch for newly-trained spells that have an unfilled LAYOUT slot. Nudge the
-- user to /setupbars. Uses SPELLS_CHANGED (the Classic/TBC-era event for
-- spellbook updates; LEARNED_SPELL_IN_TAB doesn't exist pre-Wrath).
-- Throttled to one nudge per 3 seconds to handle multi-spell training bursts.
local trainerWatch = CreateFrame("Frame")
trainerWatch:RegisterEvent("SPELLS_CHANGED")
local lastNudge = 0
trainerWatch:SetScript("OnEvent", function()
    -- Skip during initial-setup window — the auto-/setupbars handler will
    -- place everything and a nudge mid-setup is just noise.
    if SetupCoreDB.needsSetup then return end
    local now = GetTime()
    if now - lastNudge < 3 then return end
    lastNudge = now
    C_Timer.After(1.5, function()
        local unplaced = SetupCore:UnplacedLayoutSpells()
        if #unplaced > 0 then
            print("|cffffd700SetupCore|r new spell"..(#unplaced > 1 and "s" or "")..
                " not on bars: |cffffffff"..table.concat(unplaced, ", ").."|r")
            print("|cffffd700SetupCore|r run |cffffffff/setupbars|r to place "..(#unplaced > 1 and "them" or "it"))
        end
    end)
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if SetupCoreDB.needsSetup then
        local _, class = UnitClass("player")
        local fn = registered[class]
        if fn then
            print("|cff00ff00SetupCore|r first-time setup running for "..class.."...")
            fn()
            SetupCoreDB.needsSetup = false
            -- Brief delay before welcome so it lands after the layout results.
            C_Timer.After(0.5, function() SetupCore:PrintWelcome() end)
        else
            print("|cffffaa00SetupCore|r needsSetup is set but no setup registered for class "..(class or "?"))
        end
    end

    -- Auto-leave noisy channels — once per character.
    if not SetupCoreCharDB.channelsLeft then
        C_Timer.After(3, function()
            local left = {}
            for _, name in ipairs(CHANNELS_TO_LEAVE) do
                LeaveChannelByName(name)
                table.insert(left, name)
            end
            SetupCoreCharDB.channelsLeft = true
            print("|cff00ff00SetupCore|r left channels: "..table.concat(left, ", "))
        end)
    end
end)
