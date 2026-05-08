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

-- Keyboard + mouse bindings asserted on every /setupbars run.
-- KEEP IN SYNC with templates/bindings-cache.wtf — this Lua table is the runtime
-- source of truth; the .wtf file is the install-time seed (in case SetupCore isn't
-- loaded yet on first login). When you change one, mirror the other.
-- Format: {key, action} where action=nil unbinds (clears Blizzard defaults).
local BINDINGS = {
    -- Movement
    {"W", "TOGGLEAUTORUN"},
    {"A", "STRAFELEFT"},
    {"D", "STRAFERIGHT"},
    -- Bar 1 (main top): ` 1 2 3 4 5 / Q E R T
    {"`", "ACTIONBUTTON1"},
    {"1", "ACTIONBUTTON2"}, {"2", "ACTIONBUTTON3"}, {"3", "ACTIONBUTTON4"},
    {"4", "ACTIONBUTTON5"}, {"5", "ACTIONBUTTON6"},
    {"Q", "ACTIONBUTTON8"},  {"E", "ACTIONBUTTON10"},
    {"R", "ACTIONBUTTON11"}, {"T", "ACTIONBUTTON12"},
    -- Clear default Blizzard binds for unused number keys (no Bar 1 buttons 7,9,...)
    {"6", nil}, {"7", nil}, {"8", nil}, {"9", nil}, {"0", nil}, {"-", nil}, {"=", nil},
    -- Bar 3 (main bottom): F G / Z X C V B
    {"F", "MULTIACTIONBAR3BUTTON4"}, {"G", "MULTIACTIONBAR3BUTTON5"},
    {"Z", "MULTIACTIONBAR3BUTTON8"}, {"X", "MULTIACTIONBAR3BUTTON9"},
    {"C", "MULTIACTIONBAR3BUTTON10"}, {"V", "MULTIACTIONBAR3BUTTON11"},
    {"B", "MULTIACTIONBAR3BUTTON12"},
    -- Bar 4 (alt top): Alt-` Alt-1..5 / Alt-Q Alt-E Alt-R Alt-T
    {"ALT-`", "MULTIACTIONBAR4BUTTON1"},
    {"ALT-1", "MULTIACTIONBAR4BUTTON2"}, {"ALT-2", "MULTIACTIONBAR4BUTTON3"},
    {"ALT-3", "MULTIACTIONBAR4BUTTON4"}, {"ALT-4", "MULTIACTIONBAR4BUTTON5"},
    {"ALT-5", "MULTIACTIONBAR4BUTTON6"},
    {"ALT-Q", "MULTIACTIONBAR4BUTTON8"},  {"ALT-E", "MULTIACTIONBAR4BUTTON10"},
    {"ALT-R", "MULTIACTIONBAR4BUTTON11"}, {"ALT-T", "MULTIACTIONBAR4BUTTON12"},
    -- Bar 5 (alt bottom): Alt-F Alt-G / Alt-Z Alt-X Alt-C Alt-V Alt-B
    {"ALT-F", "MULTIACTIONBAR2BUTTON4"}, {"ALT-G", "MULTIACTIONBAR2BUTTON5"},
    {"ALT-Z", "MULTIACTIONBAR2BUTTON8"}, {"ALT-X", "MULTIACTIONBAR2BUTTON9"},
    {"ALT-C", "MULTIACTIONBAR2BUTTON10"}, {"ALT-V", "MULTIACTIONBAR2BUTTON11"},
    {"ALT-B", "MULTIACTIONBAR2BUTTON12"},
    -- Mouse buttons reserved for OPie rings (unbind WoW defaults)
    {"BUTTON3", nil}, {"BUTTON4", nil}, {"BUTTON5", nil},
    -- NumLock can interfere with movement on some keyboards
    {"NUMLOCK", nil},
    -- Questie convenience
    {";", "QUESTIE_TOGGLE_JOURNEY"},
}

-- CVars asserted on every /setupbars run. Per-character CVars (autoLootDefault)
-- are reset for new characters by Blizzard, so we re-assert on every run.
-- KEEP IN SYNC with templates/Config.wtf for first-login seeding.
local CVARS = {
    autoLootDefault = "1",     -- one-key looting (per-character)
    autoSelfCast = "1",        -- self-cast friendly spells when no friendly target
    nameplateShowEnemies = "1",
    nameplateShowFriends = "0",
    cameraSmoothStyle = "0",   -- no camera lag
    showTutorials = "0",
    takeScreenshotOnLevelUp = "1",
}

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

-- Place any LAYOUT spells that are trained but not yet on bars. NON-DESTRUCTIVE:
-- only fills EMPTY slots, never overwrites existing actions or clears bars. Used
-- by the SPELLS_CHANGED handler to auto-place newly-trained spells without the
-- user typing /setupbars. Returns the list of placed spell names.
function SetupCore:AutoPlaceUnplaced()
    local _, class = UnitClass("player")
    local layout = registeredLayouts[class]
    if not layout then return {} end
    local placed, seen = {}, {}
    for _, item in ipairs(layout) do
        local name, bar, btn, template = item[1], item[2], item[3], item[4]
        if not seen[name] and self:FindHighestRank(name) then
            local b = _G["ElvUI_Bar"..bar.."Button"..btn]
            if b then
                local slot = b:GetAttribute("action")
                if slot and not GetActionInfo(slot) then
                    if self:PlaceSpell(name, bar, btn, template) then
                        table.insert(placed, name)
                        seen[name] = true
                    end
                end
            end
        end
    end
    return placed
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

-- Evict any "Attack" auto-toggle placement from ALL bars (including Bar 10
-- which ClearAllBars preserves for consumables). Blizzard auto-places Attack
-- on new characters; per auto_attack_no_slot.md it never belongs on a bar.
function SetupCore:EvictAttack()
    local count = 0
    for bar = 1, 10 do
        for btn = 1, 12 do
            local b = _G["ElvUI_Bar"..bar.."Button"..btn]
            if b then
                local slot = b:GetAttribute("action")
                if slot then
                    local actionType, id = GetActionInfo(slot)
                    if actionType == "spell" and id then
                        local name = GetSpellInfo(id)
                        if name == "Attack" then
                            PickupAction(slot)
                            ClearCursor()
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    if count > 0 then
        print(string.format("|cff999999SetupCore|r evicted %d Attack placements", count))
    end
end

-- Apply keyboard + mouse bindings from the BINDINGS table. Persists per-character
-- (SaveBindings(2)) so it works regardless of the user's account/character toggle.
-- Idempotent: safe to call repeatedly.
function SetupCore:ApplyBindings()
    local applied, cleared = 0, 0
    for _, b in ipairs(BINDINGS) do
        local key, action = b[1], b[2]
        if action then
            if SetBinding(key, action) then applied = applied + 1 end
        else
            -- Unbind: only act if currently bound (avoid spurious "no change" calls).
            -- GetBindingAction is the Classic+Retail-safe API (GetBindingByKey is retail-only).
            local cur = GetBindingAction(key)
            if cur and cur ~= "" then
                SetBinding(key)
                cleared = cleared + 1
            end
        end
    end
    SaveBindings(2)  -- 2 = per-character; safer than account-wide for friend installs
    if applied > 0 or cleared > 0 then
        print(string.format("|cff999999SetupCore|r asserted %d bindings (cleared %d defaults)", applied, cleared))
    end
end

-- Apply CVars from the CVARS table. Per-character CVars (autoLootDefault) reset
-- on character creation, so we re-assert on every /setupbars run.
function SetupCore:ApplyCVars()
    local count = 0
    for cvar, value in pairs(CVARS) do
        local cur = GetCVar(cvar)
        if cur ~= value then
            SetCVar(cvar, value)
            count = count + 1
        end
    end
    if count > 0 then
        print(string.format("|cff999999SetupCore|r set %d CVars", count))
    end
end

-- racials: optional table {RaceName = {{spell, bar, btn, [template]}, ...}, ...}
-- Per docs/racials.md: class addons declare per-race racial entries; SetupCore
-- merges into LAYOUT based on the player's race. RaceName is the file token
-- from select(2, UnitRace("player")) — "Tauren", "Orc", "NightElf", etc.
function SetupCore:ApplyLayout(layout, ignore, racials)
    -- Assert bindings + CVars first; these are per-character and reset on new chars.
    self:ApplyBindings()
    self:ApplyCVars()
    self:EvictAttack()

    -- Optionally append per-race racial entries.
    if racials then
        local _, race = UnitRace("player")
        local extras = race and racials[race]
        if extras and #extras > 0 then
            local merged = {}
            for _, e in ipairs(layout) do table.insert(merged, e) end
            for _, e in ipairs(extras) do table.insert(merged, e) end
            layout = merged
        end
    end

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

-- Standalone bindings/CVars asserters (also auto-run as part of /setupbars)
SLASH_APPLYBINDINGS1 = "/applybindings"
SlashCmdList["APPLYBINDINGS"] = function() SetupCore:ApplyBindings() end

SLASH_APPLYCVARS1 = "/applycvars"
SlashCmdList["APPLYCVARS"] = function() SetupCore:ApplyCVars() end

-- Watch for newly-trained spells that have an unfilled LAYOUT slot. AUTO-PLACE
-- them so kids/casual players don't have to type /setupbars after every trainer
-- visit. Non-destructive: only fills EMPTY slots, never overwrites existing
-- actions. Uses SPELLS_CHANGED (the Classic/TBC-era event for spellbook updates;
-- LEARNED_SPELL_IN_TAB doesn't exist pre-Wrath). Throttled to once per 3s to
-- handle multi-spell training bursts (trainers sometimes fire SPELLS_CHANGED
-- multiple times within a frame).
local trainerWatch = CreateFrame("Frame")
trainerWatch:RegisterEvent("SPELLS_CHANGED")
local lastTick = 0
trainerWatch:SetScript("OnEvent", function()
    -- Skip during initial-setup window — the auto-/setupbars handler will
    -- place everything and an auto-place during setup is redundant.
    if SetupCoreDB.needsSetup then return end
    local now = GetTime()
    if now - lastTick < 3 then return end
    lastTick = now
    C_Timer.After(1.5, function()
        local placed = SetupCore:AutoPlaceUnplaced()
        if #placed > 0 then
            print("|cffffd700SetupCore|r auto-placed new spell"..(#placed > 1 and "s" or "")..
                ": |cffffffff"..table.concat(placed, ", ").."|r")
        end
    end)
end)

-- ElvUI install wizard suppression. ElvUI checks `not E.private.install_complete`
-- on PLAYER_LOGIN and shows its install wizard if missing — clicking through it
-- WIPES the active profile (the bug that cost us a layout earlier this session).
-- We set install_complete to a truthy value via three hooks for reliability:
--   1) When ElvUI's SavedVariables load (ADDON_LOADED for ElvUI), set on all
--      existing profiles in ElvPrivateDB.
--   2) On PLAYER_LOGIN, set on any profiles created since (e.g., new chars).
--   3) Hook E:Install via hooksecurefunc — if the wizard fires anyway, our hook
--      sets install_complete after, so it doesn't fire again on next reload.
local function suppressElvUIProfiles()
    if not (ElvPrivateDB and ElvPrivateDB.profiles) then return 0 end
    local n = 0
    for _, p in pairs(ElvPrivateDB.profiles) do
        if type(p) == "table" and not p.install_complete then
            p.install_complete = "1"
            n = n + 1
        end
    end
    return n
end

local elvWatch = CreateFrame("Frame")
elvWatch:RegisterEvent("ADDON_LOADED")
elvWatch:RegisterEvent("PLAYER_LOGIN")
elvWatch:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" then
        if addon == "ElvUI" then suppressElvUIProfiles() end
    elseif event == "PLAYER_LOGIN" then
        local n = suppressElvUIProfiles()
        if n > 0 then
            print(string.format("|cff999999SetupCore|r suppressed ElvUI wizard on %d profile(s)", n))
        end
        -- Belt-and-suspenders: hook E:Install to set install_complete after.
        local E = _G.ElvUI and _G.ElvUI[1]
        if E and E.Install and not E._SetupCore_InstallHooked then
            hooksecurefunc(E, "Install", function(self)
                if self.private then self.private.install_complete = self.version or "1" end
            end)
            E._SetupCore_InstallHooked = true
        end
    end
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
