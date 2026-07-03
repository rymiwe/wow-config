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
local registeredIgnores = {}
local registeredRacials = {}
local registeredFreedKeys = {}
local registeredPostLayout = {}
local registeredReservedSlots = {}
local macroBindingsByClass = {}

-- Z -> bar 3 slot 8; Alt/Meta-Z -> bar 5 slot 8 (mount macro). Movement classes
-- get their travel instant forced onto bar 3:8 in ApplyTravelSlots (SPELL keybinds
-- do not work on Classic/TBC Anniversary clients).
local MOVEMENT_SPELL_BY_CLASS = {
    SHAMAN = "Ghost Wolf",
    DRUID  = "Dash",
    ROGUE  = "Sprint",
    MAGE   = "Blink",
    HUNTER = "Aspect of the Cheetah",
}

local MOUNT_MACRO_NAME = "SC_Mount"
-- Retail mount journal (not available on TBC Anniversary — kept for MountUsesJournal guard).
local MOUNT_SPELL_ID = 150544
-- Known TBC mount items, checked in order. First match in bags wins.
local MOUNT_ITEM_IDS = {
    29744, 28481, -- Elekks
    29220, 29221, 29222, 29223, 29224, -- Hawkstriders
    5864, 5872, 5873, 13328, 13329, -- Rams
    5665, 5668, 5663, -- Wolves
    4608, 1132, -- Other faction wolves/rams
    8591, 8592, 8595, 8596, 13331, 13332, 13333, 13334, -- Skeletal horses
    18766, 18767, 18768, 18772, 18773, 18774, 18776, 18777, 18778, -- Epic vendor mounts
    18241, 18242, 18243, 18244, 18245, 18246, 18247, 18248, -- Epic racial mounts
    19029, 19030, 19031, -- PvP mounts
    25473, 25474, 25475, 25476, 25477, -- Swift flying (TBC)
}
-- Class/trained mount spells before generic spellbook scan.
local MOUNT_SPELL_NAMES = {
    "Summon Charger", "Summon Warhorse",
    "Summon Dreadsteed", "Summon Felsteed",
    "Summon Thalanaar",
    "Summon Hawkstrider", "Summon Black War Hawkstrider",
    "Summon Warhorse", "Summon Black War Steed",
}
local TRAVEL_BAR = { movement = {3, 8}, mount = {5, 8} }
local TOTEM_CAST_MACRO_NAME = "TT Cast"
local SHAMAN_TOTEM_DROP_BAR = {3, 5} -- F -> MULTIACTIONBAR3BUTTON5
local MOVEMENT_KEYBINDS = {
    {"Z", "MULTIACTIONBAR3BUTTON8"},
    {"SHIFT-Z", "MULTIACTIONBAR3BUTTON8"},
}
local MOUNT_KEYBINDS = {
    {"ALT-Z", "MULTIACTIONBAR2BUTTON8"},
    {"META-Z", "MULTIACTIONBAR2BUTTON8"},
}

-- Per-class M3 dispel: macro name, template key, icon spell for EnsureDecurseMacro.
local DECURSE_BY_CLASS = {
    SHAMAN  = { macroName = "SC_Decurse", template = "decurse-shaman", icon = "Cure Poison" },
    DRUID   = { macroName = "SC_Decurse", template = "decurse-druid",  icon = "Cure Poison" },
    PRIEST  = { macroName = "SC_Decurse", template = "decurse-priest", icon = "Dispel Magic" },
    MAGE    = { macroName = "SC_Decurse", template = "decurse-mage",   icon = "Remove Lesser Curse" },
    PALADIN = { macroName = "SC_Purify",  template = "pally-dispel",   icon = "Purify" },
}

-- Middle mouse: class dispel/decurse (secure button + SC_Decurse mirror). M4/M5 stay OPie.
SetupCore.DECURSE_MOUSE = "BUTTON3"
local DECURSE_BUTTON = "SetupCoreDecurseButton"
local DECURSE_HEADER = "SetupCoreDecurseHeader"
-- One spell per click — wrong-type dispels trigger GCD and block the next line.
local CLASS_DISPEL = {
    SHAMAN  = { harm = "Purge",  Disease = "Cure Disease", Poison = "Cure Poison" },
    DRUID   = { Poison = "Cure Poison", Curse = "Remove Curse" },
    PRIEST  = { Magic = "Dispel Magic", Disease = "Cure Disease" },
    MAGE    = { Curse = "Remove Lesser Curse" },
    PALADIN = { Magic = "Cleanse", Disease = "Purify", Poison = "Purify" },
}
local DISPEL_FALLBACK_SPELL = {
    SHAMAN  = "Cure Poison",
    DRUID   = "Cure Poison",
    PRIEST  = "Dispel Magic",
    MAGE    = "Remove Lesser Curse",
    PALADIN = "Purify",
}
-- Shaman: disease before poison when both present (lower rank = higher priority).
local SHAMAN_DISPEL_PRIORITY = { "Disease", "Poison" }
local SHAMAN_DISPEL_RANK = { Disease = 1, Poison = 2 }

-- Bars skipped by ClearAllBars / RestoreBars clear pass. User-curated click-only
-- slots (professions, mount, hearth, consumables) — never wiped by /setupbars.
local PROTECTED_BARS = {
    [6] = "utility",      -- click skills: travel, rez, scouting
    [7] = "consumables",  -- food, pots, bandages — user fills; never wiped
}

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
    -- Bar 1 (main top): ` 1 2 [3 4 class-freed] / Q E R T
    {"`", "ACTIONBUTTON1"},
    {"1", "ACTIONBUTTON2"}, {"2", "ACTIONBUTTON3"}, {"3", "ACTIONBUTTON4"},
    {"4", "ACTIONBUTTON5"}, {"5", "ACTIONBUTTON6"},
    {"Q", "ACTIONBUTTON8"},  {"E", "ACTIONBUTTON10"},
    {"R", "ACTIONBUTTON11"}, {"T", "ACTIONBUTTON12"},
    -- Clear default Blizzard binds for unused number keys (no Bar 1 buttons 7,9,...)
    {"6", nil}, {"7", nil}, {"8", nil}, {"9", nil}, {"0", nil}, {"-", nil}, {"=", nil},
    -- Bar 3 (main bottom): F G / Z X C V B  (Z = slot 8; movement spell in ApplyTravelSlots)
    {"F", "MULTIACTIONBAR3BUTTON5"}, {"G", "MULTIACTIONBAR3BUTTON6"},  -- right-aligned: F/G end at row's right edge
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
    -- Bar 5 (alt bottom): Alt-F Alt-G / Alt-Z Alt-X Alt-C Alt-V Alt-B (Alt-Z = slot 8 mount macro)
    {"ALT-F", "MULTIACTIONBAR2BUTTON5"}, {"ALT-G", "MULTIACTIONBAR2BUTTON6"},  -- right-aligned to mirror F/G on Bar 3
    {"ALT-Z", "MULTIACTIONBAR2BUTTON8"}, {"ALT-X", "MULTIACTIONBAR2BUTTON9"},
    {"META-Z", "MULTIACTIONBAR2BUTTON8"},
    {"ALT-C", "MULTIACTIONBAR2BUTTON10"}, {"ALT-V", "MULTIACTIONBAR2BUTTON11"},
    {"ALT-B", "MULTIACTIONBAR2BUTTON12"},
    -- Neutralize Shift+key page-cycle defaults (mirror templates/bindings-cache.wtf).
    -- ElvUI [mod:shift]1 handles form paging on bar 1; accidental Shift+wheel/page
    -- swaps mid-combat are undesirable. Exception: SHIFT-B -> OPENALLBAGS (bags),
    -- not bar-3 B.
    {"SHIFT-`", "ACTIONBUTTON1"},
    {"SHIFT-1", "ACTIONBUTTON2"}, {"SHIFT-2", "ACTIONBUTTON3"}, {"SHIFT-3", "ACTIONBUTTON4"},
    {"SHIFT-4", "ACTIONBUTTON5"}, {"SHIFT-5", "ACTIONBUTTON6"},
    {"SHIFT-Q", "ACTIONBUTTON8"},  {"SHIFT-E", "ACTIONBUTTON10"},
    {"SHIFT-R", "ACTIONBUTTON11"}, {"SHIFT-T", "ACTIONBUTTON12"},
    {"SHIFT-F", "MULTIACTIONBAR3BUTTON5"}, {"SHIFT-G", "MULTIACTIONBAR3BUTTON6"},
    {"SHIFT-Z", "MULTIACTIONBAR3BUTTON8"}, {"SHIFT-X", "MULTIACTIONBAR3BUTTON9"},
    {"SHIFT-C", "MULTIACTIONBAR3BUTTON10"}, {"SHIFT-V", "MULTIACTIONBAR3BUTTON11"},
    {"SHIFT-B", "OPENALLBAGS"},
    {"SHIFT-6", nil},
    {"SHIFT-MOUSEWHEELUP", nil}, {"SHIFT-MOUSEWHEELDOWN", nil},
    -- Mouse buttons: M3 = decurse macro (RegisterDecurseMacro). M4/M5 = OPie rings.
    -- Do not bind M4/M5 here — /setupbars would clobber /opie ring bindings.
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
    -- Target priority convention (focus reserved for CC):
    --   help: mouseover -> current target -> self
    --   harm: mouseover -> current target
    -- Focus is intentionally OUT of the help/harm chains — convention is to use
    -- focus exclusively as a CC target (sheep, sap, root, hibernate). The
    -- focus-mouseover-harm and interrupt templates put @focus first because
    -- those spells SHOULD hit the CC target.
    ["mouseover-help"] = function(spell)
        return "#showtooltip\n/cast [@mouseover,help,nodead][help,nodead][@player] " .. spell
    end,
    ["mouseover-harm"] = function(spell)
        return "#showtooltip\n/cast [@mouseover,harm,nodead][harm,nodead] " .. spell
    end,
    -- Like mouseover-harm but adds /startattack so auto-attack engages your
    -- CURRENT target while the spell lands on mouseover (or current as fallback).
    -- Use for offensive nukes/DoTs (Moonfire, Wrath, Lightning Bolt, etc.).
    -- Don't use for CC spells (Entangling Roots, Hibernate) — startattack would
    -- break the CC by triggering melee swings on the rooted/sleeping mob.
    ["nuke-mouseover"] = function(spell)
        return "#showtooltip\n/startattack\n/cast [@mouseover,harm,nodead][harm,nodead] " .. spell
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
    -- Paladin dispel cascade: Cleanse (L42 Holy talent, dispels Magic too) tried
    -- first; falls through to Purify (L8 base, Disease/Poison only) if Cleanse
    -- not known or target invalid. Targeting follows mouseover-help priority.
    -- The spell-name parameter is ignored - macro is hardcoded; pass "Purify"
    -- in LAYOUT so the macro slot is still labeled meaningfully when only
    -- Purify is trained.
    ["pally-dispel"] = function(_)
        -- Body is overwritten by UpdateDecurseButton (debuff-aware, one spell).
        return "#showtooltip Purify\n/cast [@player] Purify"
    end,
    -- M3 decurse macros (mouseover-first). Class addons call EnsureDecurseMacro().
    ["decurse-shaman"] = function()
        -- Body is overwritten by UpdateDecurseButton (debuff-aware, one spell).
        return "#showtooltip Cure Poison\n/cast [@player] Cure Poison"
    end,
    ["decurse-druid"] = function()
        return table.concat({
            "#showtooltip",
            "/cast [@mouseover,help,nodead] Cure Poison",
            "/cast [@mouseover,help,nodead] Remove Curse",
            "/cast [help,nodead] Cure Poison",
            "/cast [help,nodead] Remove Curse",
            "/cast [@player] Cure Poison",
            "/cast [@player] Remove Curse",
        }, "\n")
    end,
    ["decurse-priest"] = function()
        return table.concat({
            "#showtooltip",
            "/cast [@mouseover,help,nodead] Dispel Magic",
            "/cast [@mouseover,help,nodead] Cure Disease",
            "/cast [@mouseover,help,nodead] Abolish Disease",
            "/cast [help,nodead] Dispel Magic",
            "/cast [help,nodead] Cure Disease",
            "/cast [help,nodead] Abolish Disease",
            "/cast [@player] Dispel Magic",
            "/cast [@player] Cure Disease",
        }, "\n")
    end,
    ["decurse-mage"] = function()
        return table.concat({
            "#showtooltip",
            "/cast [@mouseover,help,nodead] Remove Lesser Curse",
            "/cast [help,nodead] Remove Lesser Curse",
            "/cast [@player] Remove Lesser Curse",
        }, "\n")
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

function SetupCore:RegisterMacroBinding(key, macroName, classFile)
    classFile = classFile or select(2, UnitClass("player"))
    if not classFile then return end
    macroBindingsByClass[classFile] = macroBindingsByClass[classFile] or {}
    macroBindingsByClass[classFile][key] = macroName
end

function SetupCore:RegisterDecurseMacro(macroName, classFile)
    local spec = DECURSE_BY_CLASS[classFile]
    if spec and spec.macroName == macroName then
        self:RegisterMacroBinding(self.DECURSE_MOUSE, macroName, classFile)
    end
end

function SetupCore:BindMacro(key, macroName)
    if not key or not macroName then return false end
    local idx = GetMacroIndexByName(macroName)
    if not idx or idx == 0 then return false end
    if SetBinding(key, "MACRO " .. idx) then
        SaveBindings(2)
        return true
    end
    return false
end

function SetupCore:MountUsesJournal()
    -- TBC Anniversary has no Collections mount journal.
    return false
end

-- Bag APIs moved to C_Container on newer Classic/Anniversary clients.
function SetupCore:GetBagSlotCount(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag) or 0
    end
    return GetContainerNumSlots(bag) or 0
end

function SetupCore:GetBagItemId(bag, slot)
    if C_Container and C_Container.GetContainerItemID then
        return C_Container.GetContainerItemID(bag, slot)
    end
    return GetContainerItemID(bag, slot)
end

function SetupCore:ScanBagsForMountItem()
    local preferred = SetupCoreCharDB.mountItemId
    if preferred then
        for bag = 0, 4 do
            local slots = self:GetBagSlotCount(bag)
            for slot = 1, slots do
                if self:GetBagItemId(bag, slot) == preferred then
                    return preferred, GetItemInfo(preferred)
                end
            end
        end
    end
    for i = 1, #MOUNT_ITEM_IDS do
        local itemId = MOUNT_ITEM_IDS[i]
        for bag = 0, 4 do
            local slots = self:GetBagSlotCount(bag)
            for slot = 1, slots do
                if self:GetBagItemId(bag, slot) == itemId then
                    SetupCoreCharDB.mountItemId = itemId
                    return itemId, GetItemInfo(itemId)
                end
            end
        end
    end
    return nil
end

function SetupCore:FindMountSpellInBook()
    local preferred = SetupCoreCharDB.mountSpellName
    if preferred and GetSpellInfo(preferred) then
        return preferred
    end
    for i = 1, #MOUNT_SPELL_NAMES do
        local spellName = MOUNT_SPELL_NAMES[i]
        if GetSpellInfo(spellName) then
            SetupCoreCharDB.mountSpellName = spellName
            return spellName
        end
    end
    local numTabs = GetNumSpellTabs()
    for tab = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        for i = offset + 1, offset + numSpells do
            local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
            if spellName and spellName:find("Mount", 1, true) then
                SetupCoreCharDB.mountSpellName = spellName
                return spellName
            end
        end
    end
    return nil
end

function SetupCore:ResolveMountSource()
    local itemId, itemName = self:ScanBagsForMountItem()
    if itemId then
        return "item", itemId, itemName
    end
    local spellName = self:FindMountSpellInBook()
    if spellName then
        return "spell", spellName
    end
    return nil
end

function SetupCore:DescribeMountSource(src, a, b)
    if src == "item" then
        return b or ("item:" .. tostring(a))
    end
    if src == "spell" then
        return a
    end
    return "no mount found"
end

function SetupCore:GetMountMacroBody(src, a)
    if not src then
        src, a = self:ResolveMountSource()
    end
    local lines = {"#showtooltip"}
    local _, class = UnitClass("player")
    if class == "SHAMAN" then
        lines[#lines + 1] = '/run if not IsMounted() and GetShapeshiftForm()>0 then CastSpellByName("Ghost Wolf") end'
    elseif class == "DRUID" then
        lines[#lines + 1] = "/cancelform [noform:0]"
    else
        lines[#lines + 1] = "/dismount [mounted]"
    end
    if src == "item" then
        lines[#lines + 1] = "/use item:" .. a
    elseif src == "spell" then
        lines[#lines + 1] = "/cast " .. a
    else
        lines[#lines + 1] = '/run print("|cffff0000SetupCore|r: no mount in bags — keep a mount item or train a mount spell")'
    end
    return table.concat(lines, "\n")
end

function SetupCore:EnsureMountMacro()
    local src, a, b = self:ResolveMountSource()
    local icon = 132261
    if src == "item" then
        icon = GetItemIcon(a) or icon
    elseif src == "spell" then
        local _, _, spellIcon = GetSpellInfo(a)
        icon = spellIcon or icon
    end
    local body = self:GetMountMacroBody(src, a)
    local idx = self:EnsureRawMacro(MOUNT_MACRO_NAME, body, icon)
    return idx, self:DescribeMountSource(src, a, b)
end

function SetupCore:EnsureMountJournalLoaded()
    if _G.MountJournal then return true end
    if C_AddOns and C_AddOns.LoadAddOn then
        local ok = C_AddOns.LoadAddOn("Blizzard_Collections")
        if ok and _G.MountJournal then return true end
    elseif LoadAddOn then
        local ok = LoadAddOn("Blizzard_Collections")
        if ok and _G.MountJournal then return true end
    end
    return _G.MountJournal ~= nil
end

function SetupCore:PickupMountSpell()
    if not GetSpellInfo(MOUNT_SPELL_ID) then return false end
    if C_Spell and C_Spell.PickupSpell then
        C_Spell.PickupSpell(MOUNT_SPELL_ID)
    else
        PickupSpell(MOUNT_SPELL_ID)
    end
    return GetCursorInfo() == "spell"
end

-- Place journal favorite-mount spell on a bar (same as dragging from Collections).
function SetupCore:PlaceFavoriteMountSpell(bar, btn)
    local slot = self:ResolveActionSlot(bar, btn)
    if not slot then return false end
    self:PrepareSlotForPlace(slot)
    if not self:PickupMountSpell() then
        ClearCursor()
        return false
    end
    PlaceAction(slot)
    ClearCursor()
    return HasAction(slot)
end

function SetupCore:MountBarCoords()
    return TRAVEL_BAR.mount[1], TRAVEL_BAR.mount[2]
end

-- True when bar 5:8 holds the journal favorite-mount spell or SC_Mount.
function SetupCore:VerifyMountOnBar()
    local bar, btn = self:MountBarCoords()
    local slot = self:ResolveActionSlot(bar, btn)
    if not slot or not HasAction(slot) then return false end
    local actionType, id = GetActionInfo(slot)
    if actionType == "spell" and id == MOUNT_SPELL_ID then
        return true, "spell"
    end
    if actionType == "macro" and GetMacroInfo(id) == MOUNT_MACRO_NAME then
        return true, "macro"
    end
    return false
end

function SetupCore:PlaceMountOnBar()
    local bar, btn = self:MountBarCoords()
    local slot = self:ResolveActionSlot(bar, btn)
    if not slot then
        return false, "no_slot"
    end

    -- Always create SC_Mount before placement so macro fallback cannot silently skip.
    local _, mountDesc = self:EnsureMountMacro()
    if not GetMacroIndexByName(MOUNT_MACRO_NAME) then
        local numGlobal, numChar = GetNumMacros()
        print(string.format(
            "|cffff0000SetupCore|r %s missing (%d/%d char + %d/%d global macros in use)",
            MOUNT_MACRO_NAME, numChar, 18, numGlobal, 18
        ))
    end

    if self:MountUsesJournal() then
        self:EnsureMountJournalLoaded()
        if self:PlaceFavoriteMountSpell(bar, btn) and self:VerifyMountOnBar() then
            return true, "spell"
        end
        if slot and HasAction(slot) then
            self:ClearSlot(slot)
        end
    elseif slot and HasAction(slot) then
        self:ClearSlot(slot)
    end

    if self:PlaceMacro(MOUNT_MACRO_NAME, bar, btn, true) and self:VerifyMountOnBar() then
        return true, "macro", mountDesc
    end
    if self:PlacePlaceholder(bar, btn) then
        return false, "placeholder"
    end
    return false, "empty"
end

function SetupCore:ApplyMountBarSlot()
    self:EnsureMountMacro()
    local function attempt(n)
        local ok, how, mountDesc = self:PlaceMountOnBar()
        if ok then
            self:ApplyMountKeybinds()
            if how == "macro" and mountDesc and mountDesc ~= "no mount found" then
                print("|cff999999SetupCore|r mount macro: " .. mountDesc)
            end
            return true, how
        end
        if how == "placeholder" then
            self:ApplyMountKeybinds()
            print("|cffffaa00SetupCore|r mount fallback: placeholder on bar 5:8 — keep a mount item in bags or train a mount spell")
            return false, how
        end
        if how == "no_slot" and n > 0 then
            C_Timer.After(0.25, function() attempt(n - 1) end)
            return nil, "retry"
        end
        if n > 0 then
            C_Timer.After(0.25, function() attempt(n - 1) end)
            return nil, "retry"
        end
        self:ApplyMountKeybinds()
        print("|cffff0000SetupCore|r could not place mount on bar 5:8 — /reload then /mountfix")
        return false, how or "empty"
    end
    return attempt(4)
end

function SetupCore:ApplyMountSlot(attempts)
    return self:ApplyMountBarSlot()
end

function SetupCore:ApplyMovementKeybinds()
    local n = 0
    for _, pair in ipairs(MOVEMENT_KEYBINDS) do
        if SetBinding(pair[1], pair[2]) then
            n = n + 1
        end
    end
    if n > 0 then SaveBindings(2) end
    return n > 0
end

-- Alt-Z -> bar 5 slot 8 (same pattern as Z -> bar 3 slot 8). Repairs stale MACRO N binds.
function SetupCore:ApplyMountKeybinds()
    local n = 0
    for _, pair in ipairs(MOUNT_KEYBINDS) do
        if SetBinding(pair[1], pair[2]) then
            n = n + 1
        end
    end
    SaveBindings(2)
    return n > 0
end

-- Place movement (bar 3:8) and mount macro (bar 5:8). Keys use MULTIACTIONBAR binds.
function SetupCore:ApplyTravelSlots()
    local _, class = UnitClass("player")
    local movement = class and MOVEMENT_SPELL_BY_CLASS[class]
    local parts = {}

    if movement then
        local zBar, zBtn = TRAVEL_BAR.movement[1], TRAVEL_BAR.movement[2]
        if self:PlaceSpell(movement, zBar, zBtn, nil, true) then
            parts[#parts + 1] = "Z -> " .. movement
        end
    end

    if #parts > 0 then
        print("|cff999999SetupCore|r travel: " .. table.concat(parts, ", "))
    end
    return #parts > 0
end

function SetupCore:EnsureTotemTimersMacro()
    if TotemTimers and TotemTimers.UpdateMacro then
        TotemTimers.UpdateMacro()
    end
    return GetMacroIndexByName(TOTEM_CAST_MACRO_NAME)
end

function SetupCore:TotemDropBarCoords()
    return SHAMAN_TOTEM_DROP_BAR[1], SHAMAN_TOTEM_DROP_BAR[2]
end

function SetupCore:VerifyTotemCastOnBar()
    local bar, btn = self:TotemDropBarCoords()
    local slot = self:ResolveActionSlot(bar, btn)
    if not slot or not HasAction(slot) then return false end
    local actionType, id = GetActionInfo(slot)
    return actionType == "macro" and GetMacroInfo(id) == TOTEM_CAST_MACRO_NAME
end

function SetupCore:PlaceTotemCastOnBar()
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return false, "not_shaman" end
    local bar, btn = self:TotemDropBarCoords()
    if not self:ResolveActionSlot(bar, btn) then
        return false, "no_slot"
    end
    if not self:EnsureTotemTimersMacro() then
        return false, "no_macro"
    end
    if self:PlaceMacro(TOTEM_CAST_MACRO_NAME, bar, btn, true) and self:VerifyTotemCastOnBar() then
        return true, "placed"
    end
    return false, "place_failed"
end

function SetupCore:ApplyTotemCastSlot(attempts)
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return false end
    local function attempt(n)
        local ok, how = self:PlaceTotemCastOnBar()
        if ok then
            print("|cff999999SetupCore|r F -> " .. TOTEM_CAST_MACRO_NAME .. " (totem set drop)")
            return true
        end
        if how == "no_slot" and n > 0 then
            C_Timer.After(0.25, function() attempt(n - 1) end)
            return nil
        end
        if n > 0 then
            C_Timer.After(0.5, function() attempt(n - 1) end)
            return nil
        end
        if how == "no_macro" then
            print("|cffffaa00SetupCore|r TotemTimers has not created " .. TOTEM_CAST_MACRO_NAME .. " yet — /reload or /totemfix")
        end
        return false, how
    end
    return attempt(attempts or 6)
end

function SetupCore:GetDecurseSpec()
    local _, class = UnitClass("player")
    return class and DECURSE_BY_CLASS[class]
end

function SetupCore:IsSpellKnown(spellName)
    if GetSpellInfo(spellName) then return true end
    if C_Spell and C_Spell.GetSpellInfo then
        return C_Spell.GetSpellInfo(spellName) ~= nil
    end
    return false
end

local DISPEL_TYPE_BY_ID = {
    [1] = "Magic",
    [2] = "Curse",
    [3] = "Disease",
    [4] = "Poison",
}

function SetupCore:NormalizeDispelType(auraType)
    if auraType == nil or auraType == "" then return nil end
    if type(auraType) == "number" then
        return DISPEL_TYPE_BY_ID[auraType]
    end
    if type(auraType) ~= "string" then return nil end
    local lower = auraType:lower()
    if lower == "poison" then return "Poison"
    elseif lower == "disease" then return "Disease"
    elseif lower == "magic" then return "Magic"
    elseif lower == "curse" then return "Curse"
    end
    return auraType
end

-- Anniversary UnitDebuff uses modern returns: name, icon, count, dispelType (4th).
function SetupCore:GetAuraDispelType(unit, index, filter)
    filter = filter or "HARMFUL"
    if filter == "HARMFUL" then
        local name, _, _, dispelType = UnitDebuff(unit, index)
        if name then
            return name, self:NormalizeDispelType(dispelType)
        end
        return nil
    end
    if filter == "HELPFUL" then
        local name, _, _, dispelType = UnitBuff(unit, index)
        if not name then return nil end
        return name, self:NormalizeDispelType(dispelType)
    end
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local data = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
        if not data or not data.name then return nil end
        local dtype = data.dispelName or data.dispelType
        return data.name, self:NormalizeDispelType(dtype)
    end
    if UnitAura then
        local name, _, countOrType, maybeType, debuffType = UnitAura(unit, index, filter)
        if not name then return nil end
        local dispelName = maybeType
        if type(countOrType) == "string" and countOrType ~= "" then
            dispelName = countOrType
        elseif type(debuffType) == "string" and debuffType ~= "" then
            dispelName = debuffType
        end
        return name, self:NormalizeDispelType(dispelName)
    end
    return nil
end

function SetupCore:ResolveDispelUnit()
    if UnitExists("mouseover") then
        return "mouseover"
    end
    if UnitExists("target") and not UnitCanAttack("player", "target") then
        return "target"
    end
    return "player"
end

-- Party/raid tokens for dispel scans when mouseover is unset (common in combat).
function SetupCore:AppendGroupDispelUnits(order)
    local seen = {}
    for i = 1, #order do seen[order[i]] = true end
    local function add(unit)
        if not seen[unit] and UnitExists(unit) and not UnitCanAttack("player", unit) then
            seen[unit] = true
            order[#order + 1] = unit
        end
    end
    if IsInRaid and IsInRaid() then
        for i = 1, 40 do add("raid" .. i) end
    elseif IsInGroup and IsInGroup() then
        for i = 1, 4 do add("party" .. i) end
    end
end

function SetupCore:ResolvePlayerDispelSpell()
    local _, class = UnitClass("player")
    if not class then return nil end
    local spell = self:PickDispelSpell("player")
    if spell then return spell end
    if self:UnitHasAnyDebuff("player") then
        spell = DISPEL_FALLBACK_SPELL[class]
        if spell and self:IsSpellKnown(spell) then
            return spell
        end
    end
    return nil
end

-- Friendly dispels first (mouseover -> target -> player -> group), then hostile purge.
function SetupCore:ResolveDispelTarget()
    local _, class = UnitClass("player")
    local map = class and CLASS_DISPEL[class]
    local harmSpell = map and map.harm

    -- Self-poison/disease must never wait on target/mouseover state: cure self first,
    -- in or out of combat. (Previously this only ran in combat, so out of combat the
    -- mouseover/target scan below ran first and self-cure was unreliable unless you
    -- had yourself targeted.)
    local selfSpell = self:ResolvePlayerDispelSpell()
    if selfSpell then
        return "player", selfSpell
    end

    local friendlyOrder = {}
    if UnitExists("mouseover") and not UnitCanAttack("player", "mouseover") then
        friendlyOrder[#friendlyOrder + 1] = "mouseover"
    end
    if UnitExists("target") and not UnitCanAttack("player", "target") then
        friendlyOrder[#friendlyOrder + 1] = "target"
    end
    friendlyOrder[#friendlyOrder + 1] = "player"
    self:AppendGroupDispelUnits(friendlyOrder)
    for i = 1, #friendlyOrder do
        local unit = friendlyOrder[i]
        -- Empty friendly mouseover should not block curing self.
        if unit == "mouseover" and self:UnitHasAnyDebuff("player")
            and not self:UnitHasAnyDebuff("mouseover") then
        else
            local spell = self:PickDispelSpell(unit)
            if spell then
                return unit, spell
            end
        end
    end

    if harmSpell and self:IsSpellKnown(harmSpell) and not self:UnitHasAnyDebuff("player") then
        if UnitExists("mouseover") and UnitCanAttack("player", "mouseover") then
            return "mouseover", harmSpell
        end
        if UnitExists("target") and UnitCanAttack("player", "target") then
            return "target", harmSpell
        end
    end

    return friendlyOrder[1] or "player", nil
end

function SetupCore:ResolveDispelSpellForDebuff(debuffType, class, map)
    if not debuffType or not map then return nil end
    if class == "PALADIN" then
        if GetSpellInfo("Cleanse") then
            if debuffType == "Magic" or debuffType == "Disease" or debuffType == "Poison" then
                return "Cleanse"
            end
        elseif (debuffType == "Disease" or debuffType == "Poison") and GetSpellInfo("Purify") then
            return "Purify"
        end
        return nil
    end
    local spell = map[debuffType]
    if spell and self:IsSpellKnown(spell) then
        return spell
    end
    return nil
end

function SetupCore:PickDispelSpell(unit)
    local _, class = UnitClass("player")
    local map = class and CLASS_DISPEL[class]
    if not map then return nil end
    if UnitCanAttack("player", unit) then
        return nil
    end
    local bestSpell, bestRank = nil, 999
    local sawDebuff, sawUnknownType = false, false
    for i = 1, 40 do
        local name, debuffType = self:GetAuraDispelType(unit, i)
        if not name then break end
        sawDebuff = true
        local spell = self:ResolveDispelSpellForDebuff(debuffType, class, map)
        if spell then
            local rank = i
            if class == "SHAMAN" then
                rank = SHAMAN_DISPEL_RANK[debuffType] or 999
            end
            if rank < bestRank then
                bestRank = rank
                bestSpell = spell
            end
        elseif not debuffType then
            sawUnknownType = true
        end
    end
    if bestSpell then return bestSpell end
    -- Type missing on a visible debuff (Anniversary API gap) — guess; do not guess when
    -- the debuff type is known but undispellable (e.g. Curse on a Shaman).
    if sawDebuff and sawUnknownType then
        if class == "SHAMAN" then
            for _, dtype in ipairs(SHAMAN_DISPEL_PRIORITY) do
                local spell = map[dtype]
                if spell and self:IsSpellKnown(spell) then
                    return spell
                end
            end
        end
        local fallback = DISPEL_FALLBACK_SPELL[class]
        if fallback and self:IsSpellKnown(fallback) then
            return fallback
        end
    end
    return nil
end

function SetupCore:UnitHasDispellableDebuff(unit)
    for i = 1, 40 do
        local name, debuffType = self:GetAuraDispelType(unit, i)
        if not name then break end
        if debuffType then return true end
    end
    return false
end

function SetupCore:UnitHasAnyDebuff(unit)
    if not UnitExists(unit) then return false end
    for i = 1, 40 do
        local name = UnitDebuff(unit, i)
        if not name then break end
        return true
    end
    return false
end

-- Cast on the unit ResolveDispelTarget already picked first, then heal fallbacks.
function SetupCore:BuildDispelCastLine(spell, primaryUnit)
    local _, class = UnitClass("player")
    local map = class and CLASS_DISPEL[class]
    if map and map.harm and spell == map.harm then
        return string.format("/cast [@mouseover,harm,nodead][harm,nodead] %s", spell)
    end
    if primaryUnit == "player" then
        return string.format("/cast [@player] %s", spell)
    elseif primaryUnit == "target" then
        return string.format(
            "/cast [@target,help,nodead][@mouseover,help,nodead][@player] %s", spell)
    elseif primaryUnit == "mouseover" then
        return string.format(
            "/cast [@mouseover,help,nodead][@player] %s", spell)
    elseif primaryUnit:match("^party%d+$") or primaryUnit:match("^raid%d+$") then
        return string.format(
            "/cast [@%s,help,nodead][@mouseover,help,nodead][@player] %s", primaryUnit, spell)
    end
    return string.format(
        "/cast [@mouseover,help,nodead][help,nodead][@player] %s", spell)
end

function SetupCore:BuildDecurseMacroBody(unit, spell, iconSpell)
    local _, class = UnitClass("player")
    local fallback = (class and DISPEL_FALLBACK_SPELL[class]) or iconSpell or "Cure Poison"
    local show = spell or iconSpell or fallback
    local castUnit = unit or "player"
    if not spell then
        return table.concat({
            "#showtooltip " .. show,
            self:BuildDispelCastLine(fallback, castUnit),
        }, "\n")
    end
    return string.format("#showtooltip %s\n%s", spell, self:BuildDispelCastLine(spell, castUnit))
end

function SetupCore:EnsureDecurseSecureHeader(btn)
    local header = self.decurseHeader
    if header then return header end
    if not btn then return nil end

    header = CreateFrame("Frame", DECURSE_HEADER, btn, "SecureHandlerBaseTemplate")
    if SecureHandlerSetFrameRef then
        SecureHandlerSetFrameRef(header, "dispelBtn", btn)
    else
        header:SetFrameRef("dispelBtn", btn)
    end
    self.decurseHeader = header
    return header
end

-- Push macrotext through SecureHandler:Execute so combat lockdown does not block or taint M3.
function SetupCore:ApplyDecurseMacroToButton(body)
    local btn = self.decurseBtn
    if not btn or not body then return false end
    local header = self:EnsureDecurseSecureHeader(btn)
    if header and header.Execute then
        local cmd = "local b=self:GetFrameRef('dispelBtn');b:SetAttribute('type','macro');b:SetAttribute('spell',nil);b:SetAttribute('unit',nil);b:SetAttribute('macrotext',"
            .. string.format("%q", body) .. ")"
        header:Execute(cmd)
        return true
    end
    if not InCombatLockdown() then
        btn:SetAttribute("type", "macro")
        btn:SetAttribute("spell", nil)
        btn:SetAttribute("unit", nil)
        btn:SetAttribute("macrotext", body)
        return true
    end
    return false
end

function SetupCore:EnsureDecurseCombatTicker()
    if self.decurseCombatTicker then return end
    local ticker = CreateFrame("Frame")
    ticker:Hide()
    ticker:SetScript("OnUpdate", function(self, elapsed)
        if not InCombatLockdown() then
            self:Hide()
            return
        end
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 0.12 then return end
        self.elapsed = 0
        if SetupCore:GetDecurseSpec() then
            SetupCore:PushDecurseMacro(true)
        end
    end)
    self.decurseCombatTicker = ticker
end

function SetupCore:EnsureDecurseButton()
    if self.decurseBtn then return self.decurseBtn end

    local btn = CreateFrame("Button", DECURSE_BUTTON, UIParent, "SecureActionButtonTemplate")
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:SetAttribute("type", "macro")
    self.decurseBtn = btn
    self:EnsureDecurseSecureHeader(btn)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UNIT_AURA")
    frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", function(_, event, unit)
        if event == "UNIT_AURA" then
            if unit ~= "player" and unit ~= "target" and unit ~= "mouseover"
                and not unit:find("^party") and not unit:find("^raid") then
                return
            end
        end
        if event == "PLAYER_REGEN_DISABLED" then
            SetupCore:EnsureDecurseCombatTicker()
            SetupCore.decurseCombatTicker:Show()
            SetupCore:PushDecurseMacro(true)
            return
        end
        if event == "PLAYER_REGEN_ENABLED" then
            if SetupCore.decurseCombatTicker then
                SetupCore.decurseCombatTicker:Hide()
            end
        end
        SetupCore:PushDecurseMacro()
    end)
    self.decurseEventFrame = frame
    return btn
end

function SetupCore:PushDecurseMacro(force)
    local spec = self:GetDecurseSpec()
    if not spec then return nil end
    if not self.decurseBtn and InCombatLockdown() then return nil end
    self:EnsureDecurseButton()

    local unit, spell = self:ResolveDispelTarget()
    local body = self:BuildDecurseMacroBody(unit, spell, spec.icon)
    if not force and body == self.lastDispelBody then
        return unit, spell, body
    end
    self.lastDispelBody = body

    self:ApplyDecurseMacroToButton(body)
    if not InCombatLockdown() then
        local _, _, icon = GetSpellInfo(spell or spec.icon)
        self:EnsureRawMacro(spec.macroName, body, icon or "INV_Misc_QuestionMark")
    end
    return unit, spell, body
end

function SetupCore:ApplyDecurseClickAttributes()
    return self:PushDecurseMacro(true)
end

function SetupCore:ApplyDecurseMacroText()
    return self:PushDecurseMacro(true)
end

function SetupCore:UpdateDecurseButton()
    local spec = self:GetDecurseSpec()
    if not spec then return false end
    local unit, spell = self:PushDecurseMacro(true)
    if not unit and not spell then return false end
    return true, spell, unit
end

-- Ensure dispel macro exists and M3 clicks the secure debuff-aware button (fixes
-- stale bindings-cache MACRO N entries and wrong-type GCD blocking).
function SetupCore:RefreshDecurseBinding()
    local spec = self:GetDecurseSpec()
    if not spec then return false end
    self:UpdateDecurseButton()
    local want = "CLICK " .. DECURSE_BUTTON .. ":LeftButton"
    local cur = GetBindingAction(self.DECURSE_MOUSE)
    if cur == want then return true end
    if SetBinding(self.DECURSE_MOUSE, want) then
        SaveBindings(2)
        print(string.format(
            "|cff999999SetupCore|r M3 -> smart dispel (%s%s)",
            spec.macroName,
            (cur and cur ~= "" and (", was " .. cur) or "")
        ))
        return true
    end
    return false
end

function SetupCore:ApplyMacroBindings()
    if self:RefreshDecurseBinding() then
        print("|cff999999SetupCore|r bound M3 -> dispel macro (mouseover decurse/purge)")
    end
    local _, class = UnitClass("player")
    local bindings = class and macroBindingsByClass[class]
    if not bindings then return end
    local applied = 0
    for key, name in pairs(bindings) do
        if key ~= self.DECURSE_MOUSE and self:BindMacro(key, name) then
            applied = applied + 1
        end
    end
    if applied > 0 then
        print(string.format("|cff999999SetupCore|r bound %d other macro key(s)", applied))
    end
end

-- Build/update a dispel macro from a MACRO_TEMPLATES decurse-* / pally-dispel entry.
function SetupCore:EnsureDecurseMacro(templateName, iconSpell, macroName)
    macroName = macroName or "SC_Decurse"
    local tmpl = MACRO_TEMPLATES[templateName]
    if not tmpl then
        print("|cffff0000SetupCore|r unknown decurse template: " .. tostring(templateName))
        return nil
    end
    local _, _, icon = GetSpellInfo(iconSpell or "Cure Poison")
    return self:EnsureRawMacro(macroName, tmpl(), icon)
end

function SetupCore:RegisterClass(class, applyFn, layout, meta)
    registered[class] = applyFn
    if layout then
        -- `layout` can be either a flat LAYOUT array or a LAYOUT_TIERS array
        -- of {minLevel=N, layout={...}} entries. ResolveLayout handles both.
        registeredLayouts[class] = layout
    end
    if type(meta) == "table" then
        registeredIgnores[class] = meta.ignore
        registeredRacials[class] = meta.racials
        registeredFreedKeys[class] = meta.freedKeys
    end
end

-- Optional hook after ApplyLayout (placeholders filled). Class addons use this
-- for macros on bound slots that are not LAYOUT spells (e.g. shaman F totem drop).
function SetupCore:RegisterPostLayout(class, fn)
    registeredPostLayout[class] = fn
end

function SetupCore:RunPostLayout()
    local _, class = UnitClass("player")
    local fn = class and registeredPostLayout[class]
    if fn then return fn() end
end

-- Bound bar slots owned by class post-layout (skip placeholder fill). e.g. shaman F.
function SetupCore:RegisterReservedSlots(class, slots)
    registeredReservedSlots[class] = slots
end

function SetupCore:IsReservedSlot(bar, btn)
    -- Alt-Z mount slot (all classes)
    if bar == TRAVEL_BAR.mount[1] and btn == TRAVEL_BAR.mount[2] then return true end
    local _, class = UnitClass("player")
    local slots = class and registeredReservedSlots[class]
    if not slots then return false end
    for _, s in ipairs(slots) do
        if s[1] == bar and s[2] == btn then return true end
    end
    return false
end

function SetupCore:PlacePlaceholder(bar, btn)
    return self:PlaceMacro(" ", bar, btn, false)
end

function SetupCore:GetFreedKeySet()
    local _, class = UnitClass("player")
    local freed = registeredFreedKeys[class]
    if not freed or #freed == 0 then return {} end
    local set = {}
    for _, key in ipairs(freed) do set[key] = true end
    return set
end

function SetupCore:MergeRacials(layout)
    if not layout then return nil end
    local _, class = UnitClass("player")
    local racials = registeredRacials[class]
    if not racials then return layout end
    local _, race = UnitRace("player")
    local extras = race and racials[race]
    if not extras or #extras == 0 then return layout end
    local merged = {}
    for _, e in ipairs(layout) do table.insert(merged, e) end
    for _, e in ipairs(extras) do table.insert(merged, e) end
    return merged
end

function SetupCore:GetActiveLayout()
    local _, class = UnitClass("player")
    local layout = self:ResolveLayout(registeredLayouts[class])
    return self:MergeRacials(layout)
end

-- ResolveLayout: return the active layout array, given either a flat LAYOUT
-- table or a LAYOUT_TIERS table of {minLevel, layout} entries. For tiers,
-- picks the highest tier where the player's level meets minLevel.
-- Returns: layout array, activeTierMinLevel (or nil if flat layout)
function SetupCore:ResolveLayout(layoutOrTiers)
    if not layoutOrTiers or #layoutOrTiers == 0 then return nil, nil end
    local first = layoutOrTiers[1]
    -- Tier format detection: first entry has minLevel + layout fields.
    if type(first) == "table" and first.minLevel and first.layout then
        local level = UnitLevel("player") or 1
        local active, activeMin = first.layout, first.minLevel
        for _, tier in ipairs(layoutOrTiers) do
            if level >= tier.minLevel and tier.minLevel >= activeMin then
                active, activeMin = tier.layout, tier.minLevel
            end
        end
        return active, activeMin
    end
    -- Flat layout (existing format).
    return layoutOrTiers, nil
end

-- TierBoundaries: extract sorted minLevel values from a LAYOUT_TIERS table.
-- Returns nil if not a tier structure (flat LAYOUT). Used by level-up handler
-- to detect when the player has crossed into a new tier.
function SetupCore:TierBoundaries(layoutOrTiers)
    if not layoutOrTiers or #layoutOrTiers == 0 then return nil end
    local first = layoutOrTiers[1]
    if not (type(first) == "table" and first.minLevel and first.layout) then
        return nil
    end
    local boundaries = {}
    for _, tier in ipairs(layoutOrTiers) do
        table.insert(boundaries, tier.minLevel)
    end
    table.sort(boundaries)
    return boundaries
end

-- Returns a list of LAYOUT spell names that:
--   1. Exist in the player's spellbook (trained), AND
--   2. Are NOT currently placed at their LAYOUT-specified bar slot
-- Used to nudge the user to /setupbars after training new spells.
function SetupCore:UnplacedLayoutSpells()
    local layout = self:GetActiveLayout()
    if not layout then return {} end
    local unplaced, seen = {}, {}
    for _, item in ipairs(layout) do
        local name, bar, btn = item[1], item[2], item[3]
        if not seen[name] and self:FindHighestRank(name) then
            local b = _G["ElvUI_Bar"..bar.."Button"..btn]
            if b then
                local slot = b:GetAttribute("action")
                if slot and self:IsSlotEmpty(slot) then
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
    local layout = self:GetActiveLayout()
    if not layout then return {} end
    local placed, seen = {}, {}
    for _, item in ipairs(layout) do
        local name, bar, btn, template = item[1], item[2], item[3], item[4]
        if not seen[name] and self:FindHighestRank(name) then
            local b = _G["ElvUI_Bar"..bar.."Button"..btn]
            if b then
                local slot = b:GetAttribute("action")
                if slot and self:IsSlotEmpty(slot) then
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

function SetupCore:NormalizeSpellName(sname)
    if not sname then return nil end
    local base = sname:match("^(.-)%s*%(") or sname
    return base:match("^%s*(.-)%s*$")
end

function SetupCore:FindHighestRank(name)
    local last
    for j = 1, 500 do
        local sname = GetSpellBookItemName(j, "spell")
        if not sname then break end
        if self:NormalizeSpellName(sname) == name then
            last = j
        end
    end
    return last
end

function SetupCore:IsSlotEmpty(slot)
    if not slot then return true end
    local actionType, id = GetActionInfo(slot)
    if not actionType then return true end
    if actionType == "macro" then
        local mname = GetMacroInfo(id)
        return mname == " " or mname == ""
    end
    return false
end

function SetupCore:IsProtectedBar(bar)
    return PROTECTED_BARS[bar] ~= nil
end

-- ElvUI button attribute is the only source of truth for which Blizzard action
-- slot a bar button displays. Arithmetic slot guessing can clear/write the
-- wrong slot and leave stale duplicates visible on the bar.
function SetupCore:ResolveActionSlot(bar, btn)
    local frame = _G["ElvUI_Bar"..bar.."Button"..btn]
    if not frame then return nil end
    return frame:GetAttribute("action")
end

function SetupCore:ClearSlot(slot)
    if not slot then return end
    for _ = 1, 3 do
        if not HasAction(slot) then return end
        PickupAction(slot)
        ClearCursor()
    end
end

-- True if this action slot holds the given layout spell (raw spell or SC_ macro).
function SetupCore:ActionRepresentsSpell(slot, spellName, template)
    if not slot or not HasAction(slot) then return false end
    local want = self:NormalizeSpellName(spellName)
    local actionType, id = GetActionInfo(slot)
    if actionType == "spell" then
        return self:NormalizeSpellName(GetSpellInfo(id)) == want
    end
    if actionType == "macro" then
        local mname = GetMacroInfo(id) or ""
        local expected = "SC_" .. want:gsub("%s", "")
        if #expected > 16 then expected = expected:sub(1, 16) end
        -- Match macro identity only — never substring-scan bodies (e.g.
        -- "Healing Wave" must not match SC_LesserHealingWave).
        return mname == expected or (#expected > 0 and mname:sub(1, #expected) == expected)
    end
    return false
end

-- After a layout migration, remove stale copies (e.g. Lightning Shield on F when
-- it now lives on E). Keeps only the canonical bar/button from LAYOUT.
function SetupCore:EvictLayoutDuplicates(layout, maxBar)
    maxBar = maxBar or 5
    local evicted = 0
    for _, item in ipairs(layout) do
        local name, wantBar, wantBtn, template = item[1], item[2], item[3], item[4]
        for b = 1, maxBar do
            if not PROTECTED_BARS[b] then
                for i = 1, 12 do
                    if b ~= wantBar or i ~= wantBtn then
                        local slot = self:ResolveActionSlot(b, i)
                        if self:ActionRepresentsSpell(slot, name, template) then
                            self:ClearSlot(slot)
                            evicted = evicted + 1
                        end
                    end
                end
            end
        end
    end
    if evicted > 0 then
        print(string.format("|cff999999SetupCore|r evicted %d stale duplicate action(s)", evicted))
    end
    return evicted
end

-- Clears action slots on bars 1..maxBar but skips PROTECTED_BARS (see table above).
-- Pass `maxBar` = number of HIGHEST bar to clear (default 9).
function SetupCore:ClearAllBars(maxBar)
    maxBar = maxBar or 9
    for b = 1, maxBar do
        if not PROTECTED_BARS[b] then
            for i = 1, 12 do
                local slot = self:ResolveActionSlot(b, i)
                if slot then self:ClearSlot(slot) end
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
            local slot = self:ResolveActionSlot(b, i)
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

function SetupCore:DeleteMacro(name)
    if not name or name == "" then return false end
    local idx = GetMacroIndexByName(name)
    if idx and idx > 0 then
        DeleteMacro(idx)
        return true
    end
    return false
end

function SetupCore:DeleteMacros(names)
    local removed = 0
    for i = 1, #names do
        if self:DeleteMacro(names[i]) then
            removed = removed + 1
        end
    end
    return removed
end

-- Place an existing macro by name on a bar slot. Companion to EnsureRawMacro.
function SetupCore:PlaceMacro(macroName, bar, btn, forceClear)
    local slot = self:ResolveActionSlot(bar, btn)
    if not slot then return false end

    local idx = GetMacroIndexByName(macroName)
    if not idx or idx == 0 then return false end

    if forceClear then
        self:ClearSlot(slot)
    else
        self:PrepareSlotForPlace(slot)
    end

    PickupMacro(idx)
    if GetCursorInfo() ~= "macro" then
        ClearCursor()
        return false
    end
    PlaceAction(slot)
    ClearCursor()
    return HasAction(slot)
end

-- Remove visual placeholder macros so real spells/macros can land on bound keys.
function SetupCore:PrepareSlotForPlace(slot)
    if not slot or not HasAction(slot) then return end
    local actionType, id = GetActionInfo(slot)
    if actionType == "macro" then
        local mname = GetMacroInfo(id)
        if mname == " " or mname == "" then
            self:ClearSlot(slot)
        end
    end
end

-- Place spells on protected bars (6 utility, 7 consumables) only in empty slots.
-- Never overwrites mount, hearth, food, etc. the user already placed.
function SetupCore:SeedProtectedBar(layout)
    if not layout then return 0 end
    local placed = 0
    for _, item in ipairs(layout) do
        local name, bar, btn, template = item[1], item[2], item[3], item[4]
        if PROTECTED_BARS[bar] then
            local b = _G["ElvUI_Bar"..bar.."Button"..btn]
            if b then
                local slot = b:GetAttribute("action")
                if slot and self:IsSlotEmpty(slot) then
                    if self:PlaceSpell(name, bar, btn, template) then
                        placed = placed + 1
                    end
                end
            end
        end
    end
    if placed > 0 then
        print(string.format("|cff999999SetupCore|r seeded %d spell(s) on protected click bar(s)", placed))
    end
    return placed
end

function SetupCore:PlaceSpell(name, bar, btn, template, forceClear)
    local slot = self:ResolveActionSlot(bar, btn)
    if not slot then return false end
    if forceClear then
        self:ClearSlot(slot)
    else
        self:PrepareSlotForPlace(slot)
    end

    if template then
        -- Skip if the underlying spell isn't trained yet — no point creating a
        -- macro for a spell the player can't cast.
        if not self:FindHighestRank(name) then return false end
        local macroIdx = self:EnsureMacro(name, template)
        if not macroIdx then return false end
        PickupMacro(macroIdx)
        if GetCursorInfo() == "macro" then
            PlaceAction(slot)
            ClearCursor()
            return true
        end
        ClearCursor()
        return false
    end

    local idx = self:FindHighestRank(name)
    if not idx then return false end
    PickupSpellBookItem(idx, "spell")
    if GetCursorInfo() == "spell" then
        PlaceAction(slot)
        ClearCursor()
        return true
    end
    ClearCursor()
    return false
end

-- Fill empty slots that have an active keybind (respects class freedKeys).
-- freedKeys = key released entirely (no bind, no placeholder). All other
-- bound-but-empty slots get a placeholder so the keyboard shape stays visible.
function SetupCore:FillEmptyBoundSlots()
    local placeholderName = " "
    -- Subtle placeholder icon (file ID, user-chosen). WoW accepts numeric file
    -- IDs directly via CreateMacro/EditMacro — more reliable than name strings
    -- which silently fail if the texture isn't in the current client.
    -- 135864 = the icon rymiwe picked manually in WoW's macro UI as the
    -- low-contrast placeholder. To change: pick a new icon in-game on the " "
    -- macro, /reload (or graceful exit), then read the new file ID from
    -- WTF/Account/<acct>/macros-cache.txt and update this constant.
    local placeholderIcon = 135864
    local idx = self:EnsureRawMacro(placeholderName, "", placeholderIcon)
    if not idx then
        return 0  -- macro slots full; EnsureRawMacro already printed warning
    end

    -- Map MULTIACTIONBARn (Blizzard naming) to ElvUI bar number.
    local barMap = {["3"]=3, ["4"]=4, ["2"]=5}
    local freedSet = self:GetFreedKeySet()
    local slots = {}
    for _, b in ipairs(BINDINGS) do
        local key, action = b[1], b[2]
        if action and not freedSet[key] then
            local n = action:match("^ACTIONBUTTON(%d+)$")
            if n then
                slots[#slots+1] = {1, tonumber(n)}
            else
                local mb, btn = action:match("^MULTIACTIONBAR(%d+)BUTTON(%d+)$")
                if mb and barMap[mb] then
                    slots[#slots+1] = {barMap[mb], tonumber(btn)}
                end
            end
        end
    end

    local placed = 0
    local function maybePlaceholder(bar, btn)
        if self:IsReservedSlot(bar, btn) then return end
        local slotIdx = self:ResolveActionSlot(bar, btn)
        if slotIdx and self:IsSlotEmpty(slotIdx) then
            if self:PlaceMacro(placeholderName, bar, btn, false) then
                placed = placed + 1
            end
        end
    end

    for _, s in ipairs(slots) do
        maybePlaceholder(s[1], s[2])
    end

    if placed > 0 then
        print(string.format("|cff999999SetupCore|r placed %d visual placeholders on empty bound slots", placed))
    end
    return placed
end

-- Strip actions from bar slots whose keys are class-freed (e.g. Shaman 3/4).
-- Handles leftovers from older setups that still placed placeholders there.
function SetupCore:ClearFreedKeySlots()
    local freedSet = self:GetFreedKeySet()
    if not next(freedSet) then return 0 end

    local barMap = {["3"]=3, ["4"]=4, ["2"]=5}
    local cleared = 0
    for _, b in ipairs(BINDINGS) do
        local key, action = b[1], b[2]
        if action and freedSet[key] then
            local bar, btn
            local n = action:match("^ACTIONBUTTON(%d+)$")
            if n then
                bar, btn = 1, tonumber(n)
            else
                local mb, button = action:match("^MULTIACTIONBAR(%d+)BUTTON(%d+)$")
                if mb and barMap[mb] then
                    bar, btn = barMap[mb], tonumber(button)
                end
            end
            if bar and btn then
                local slot = self:ResolveActionSlot(bar, btn)
                if slot and HasAction(slot) then
                    self:ClearSlot(slot)
                    cleared = cleared + 1
                end
            end
        end
    end
    return cleared
end

-- Evict any "Attack" auto-toggle placement from ALL bars (including protected
-- utility bar 6). Blizzard auto-places Attack
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
    local freedSet = self:GetFreedKeySet()
    for _, b in ipairs(BINDINGS) do
        local key, action = b[1], b[2]
        if action then
            if not freedSet[key] and SetBinding(key, action) then applied = applied + 1 end
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
    for key in pairs(freedSet) do
        local cur = GetBindingAction(key)
        if cur and cur ~= "" then
            SetBinding(key)
            cleared = cleared + 1
        end
    end
    SaveBindings(2)  -- 2 = per-character; safer than account-wide for friend installs
    if applied > 0 or cleared > 0 then
        print(string.format("|cff999999SetupCore|r asserted %d bindings (cleared %d defaults)", applied, cleared))
    end
    self:ApplyMovementKeybinds()
    self:ApplyMacroBindings()
    self:ApplyMountKeybinds()
    -- Last: M3 must not stay a stale MACRO N from bindings-cache (e.g. MACRO 125).
    self:RefreshDecurseBinding()
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
-- ApplyFormLayout: configure a specific form/stance/stealth bar (Druid bear/cat,
-- Warrior stances, Rogue stealth). Caller verifies form; we just place the
-- given abilities onto whichever action slots the current ElvUI buttons map to.
-- Because ElvUI buttons' `action` attribute points to the current form's bonus
-- bar page, ClearAllBars + PlaceSpell here only affects the form-specific
-- slots - the caster/other-form placements are untouched.
function SetupCore:ApplyFormLayout(addonName, formName, formLayout)
    self:ApplyBindings()
    self:ApplyCVars()
    self:BackupBars()
    -- Only clear Bar 1 - it's the only bar that pages with form/stance/stealth.
    -- Bar 3-5 are shared across forms; clearing them on a form /setupbars would
    -- wipe the caster's utility/dispel placements made in caster form.
    for i = 1, 12 do
        local btn = _G["ElvUI_Bar1Button"..i]
        if btn then
            local slot = btn:GetAttribute("action")
            if slot and HasAction(slot) then
                PickupAction(slot)
                ClearCursor()
            end
        end
    end
    local placed, skipped = 0, {}
    for _, item in ipairs(formLayout) do
        local name, bar, btn, template = item[1], item[2], item[3], item[4]
        if self:PlaceSpell(name, bar, btn, template) then
            placed = placed + 1
        else
            table.insert(skipped, name)
        end
    end
    self:FillEmptyBoundSlots()
    print(string.format("|cff00ff00%s|r %s placed %d abilities", addonName, formName, placed))
    if #skipped > 0 then
        print("|cff999999Skipped (not yet trained):|r "..table.concat(skipped, ", "))
    end
end

function SetupCore:ApplyLayout(layoutOrTiers, ignore, racials)
    -- Assert bindings + CVars first; these are per-character and reset on new chars.
    self:ApplyBindings()
    self:ApplyCVars()
    self:EvictAttack()

    -- Resolve LAYOUT_TIERS to the active flat layout for the player's current level.
    -- Backward-compat: a flat LAYOUT array passes through unchanged.
    local layout, activeTier = self:ResolveLayout(layoutOrTiers)
    if not layout then
        print("|cffff4040SetupCore|r ApplyLayout: no layout to apply")
        return 0, {}, {}
    end
    if activeTier then
        -- Remember the tier we just applied so PLAYER_LEVEL_UP can detect crossings.
        SetupCoreCharDB.lastAppliedTier = activeTier
        SetupCoreCharDB.tierCrossingPending = nil  -- clear pending flag
        print(string.format("|cff999999SetupCore|r layout tier active: L%d+", activeTier))
    end

    -- Optionally append per-race racial entries (also stored via RegisterClass meta).
    if racials then
        local _, class = UnitClass("player")
        registeredRacials[class] = racials
        layout = self:MergeRacials(layout)
    end
    if ignore then
        local _, class = UnitClass("player")
        registeredIgnores[class] = ignore
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
        if self:PlaceSpell(name, bar, btn, template, true) then
            placed = placed + 1
        else
            table.insert(skipped, name)
        end
    end
    self:EvictLayoutDuplicates(layout)
    local mapped = {}
    for _, item in ipairs(layout) do mapped[item[1]] = true end
    ignore = ignore or {}

    -- Fill any remaining empty bound slots with the visual placeholder.
    self:FillEmptyBoundSlots()
    self:ClearFreedKeySlots()
    self:ApplyTravelSlots()
    self:RunPostLayout()
    self:ApplyMountBarSlot()
    self:ApplyMountKeybinds()

    return placed, skipped, self:FindOrphans(mapped, ignore)
end

function SetupCore:FindOrphans(mappedOverride, ignoreOverride)
    local layout = self:GetActiveLayout()
    local mapped = mappedOverride
    if not mapped then
        mapped = {}
        if layout then
            for _, item in ipairs(layout) do mapped[item[1]] = true end
        end
    end
    local _, class = UnitClass("player")
    local ignore = ignoreOverride or registeredIgnores[class] or {}
    local orphans, seen = {}, {}
    for j = 1, 500 do
        local sname = GetSpellBookItemName(j, "spell")
        if not sname then break end
        local norm = self:NormalizeSpellName(sname)
        if norm and not mapped[norm] and not ignore[norm] and not ignore[sname] and not seen[norm] then
            table.insert(orphans, sname)
            seen[norm] = true
        end
    end
    return orphans
end

function SetupCore:ReportOrphans()
    local orphans = self:FindOrphans()
    if #orphans > 0 then
        print("|cffff5500SetupCore unmapped skills|r (need a key, clickable bar, or OPie ring):")
        print("|cffffffff"..table.concat(orphans, ", ").."|r")
        print("|cff999999Add to LAYOUT, an OPie ring, or IGNORE — includes racials if not placed.|r")
    end
    return orphans
end

function SetupCore:PrintResults(addonName, placed, skipped, orphans)
    print("|cff00ff00"..addonName.."|r placed "..placed.." spells")
    if #skipped > 0 then
        print("|cff999999Skipped (not yet trained):|r "..table.concat(skipped, ", "))
    end
    if #orphans > 0 then
        print("|cffff5500Unmapped skills|r (need a key, clickable bar, or OPie ring):")
        print("|cffffffff"..table.concat(orphans, ", ").."|r")
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

SLASH_SETUPTOTEM1 = "/totemfix"
SlashCmdList["SETUPTOTEM"] = function()
    SetupCore:ApplyTotemCastSlot(6)
    SetupCore:ApplyBindings()
    local f = GetBindingAction("F") or "(unbound)"
    local bar, btn = SetupCore:TotemDropBarCoords()
    local slot = SetupCore:ResolveActionSlot(bar, btn)
    local barDesc = "empty"
    if not slot then
        barDesc = "ElvUI button not ready"
    elseif HasAction(slot) then
        local actionType, id = GetActionInfo(slot)
        if actionType == "macro" then
            barDesc = "macro " .. (GetMacroInfo(id) or tostring(id))
        else
            barDesc = tostring(actionType)
        end
    end
    print(string.format("|cff999999SetupCore|r F -> %s | bar 3:5 = %s", f, barDesc))
end

SLASH_SETUPDECURSE1 = "/decursefix"
SlashCmdList["SETUPDECURSE"] = function()
    local inCombat = InCombatLockdown()
    SetupCore:EnsureDecurseButton()
    local unit, spell, body = SetupCore:ApplyDecurseClickAttributes()
    if not inCombat then
        SetupCore:UpdateDecurseButton()
    end
    SetupCore:RefreshDecurseBinding()
    local m3 = GetBindingAction(SetupCore.DECURSE_MOUSE) or "(unbound)"
    if spell then
        print(string.format("|cff999999SetupCore|r M3 dispel ready: %s on [@%s] | %s", spell, unit or "?", m3))
    else
        print(string.format("|cff999999SetupCore|r M3 dispel: no debuff now (fallback armed) | %s", m3))
    end
    if body then
        print("|cff999999  macro:|r " .. (body:gsub("\n", " / ")))
    end
    if inCombat then
        print("|cff999999SetupCore|r in combat: macro pushed via secure handler (refreshes on UNIT_AURA)")
    end
end

SLASH_SETUPMOUNT1 = "/mountfix"
SlashCmdList["SETUPMOUNT"] = function()
    local _, mountDesc = SetupCore:EnsureMountMacro()
    SetupCore:ApplyMountBarSlot()
    SetupCore:ApplyBindings()
    local ok, how = SetupCore:VerifyMountOnBar()
    if ok and how == "spell" then
        print("|cff999999SetupCore|r bar 5:8 = favorite mount spell")
    elseif ok and how == "macro" then
        print("|cff999999SetupCore|r bar 5:8 = SC_Mount (" .. (mountDesc or "?") .. ")")
    elseif mountDesc == "no mount found" then
        print("|cffff0000SetupCore|r no mount in bags or spellbook — buy/learn a mount, then /mountfix")
    end
    local altz = GetBindingAction("ALT-Z") or "(unbound)"
    local bar, btn = SetupCore:MountBarCoords()
    local slot = SetupCore:ResolveActionSlot(bar, btn)
    local barDesc = "empty"
    if not slot then
        barDesc = "ElvUI button not ready"
    elseif HasAction(slot) then
        local actionType, id = GetActionInfo(slot)
        if actionType == "spell" then
            barDesc = (GetSpellInfo(id) or ("spell:" .. tostring(id)))
        elseif actionType == "macro" then
            barDesc = "macro " .. (GetMacroInfo(id) or tostring(id))
        else
            barDesc = tostring(actionType)
        end
    end
    print(string.format("|cff999999SetupCore|r Alt-Z -> %s | bar 5:8 = %s", altz, barDesc))
end

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
        SetupCore:ReportOrphans()
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
        -- Disable ElvUI's AFK overlay (the screen that pops up over a TSM scan
        -- when WoW marks you AFK). Set on every profile in ElvDB so the choice
        -- persists across profile switches. Idempotent - safe to re-set.
        -- Also enable ElvUI's tooltip cursor anchor (tooltips follow cursor
        -- instead of living in the bottom-right of the screen).
        if _G.ElvDB and _G.ElvDB.profiles then
            for _, profile in pairs(_G.ElvDB.profiles) do
                if type(profile) == "table" then
                    profile.general = profile.general or {}
                    profile.general.afk = false
                    profile.tooltip = profile.tooltip or {}
                    profile.tooltip.cursorAnchor = true
                end
            end
        end
        if E and E.db then
            if E.db.general then E.db.general.afk = false end
            if E.db.tooltip then E.db.tooltip.cursorAnchor = true end
        end
        -- Shift-modifier paging: hold Shift in any form/stance/stealth -> bar 1
        -- shows the caster (page 1) bar. Pressing a caster spell while in form
        -- auto-cancelforms via WoW's built-in spell-casting behavior - no macro
        -- needed. Set on every profile + active so it persists across switches.
        local SHIFT_PAGING = {
            DRUID   = "[mod:shift] 1; [possessbar] 16; [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10;",
            ROGUE   = "[mod:shift] 1; [possessbar] 16; [bonusbar:1] 7;",
            WARRIOR = "[mod:shift] 1; [possessbar] 16; [bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
        }
        if _G.ElvDB and _G.ElvDB.profiles then
            for _, profile in pairs(_G.ElvDB.profiles) do
                if type(profile) == "table" then
                    profile.actionbar = profile.actionbar or {}
                    profile.actionbar.bar1 = profile.actionbar.bar1 or {}
                    profile.actionbar.bar1.paging = profile.actionbar.bar1.paging or {}
                    for class, str in pairs(SHIFT_PAGING) do
                        profile.actionbar.bar1.paging[class] = str
                    end
                end
            end
        end
        if E and E.db and E.db.actionbar and E.db.actionbar.bar1 then
            E.db.actionbar.bar1.paging = E.db.actionbar.bar1.paging or {}
            for class, str in pairs(SHIFT_PAGING) do
                E.db.actionbar.bar1.paging[class] = str
            end
            -- Trigger ElvUI to re-evaluate paging from the new string.
            local AB = E:GetModule("ActionBars", true)
            if AB and AB.PositionAndSizeBar then
                pcall(AB.PositionAndSizeBar, AB, "bar1")
            end
        end
        -- Minimap icon positions (LibDBIcon-style angle in degrees). Defer to
        -- give addon SVs time to load. Idempotent - safe to re-set each login.
        C_Timer.After(2, function()
            local positions = {
                QuestieConfig         = {path = {"profiles", "Default", "minimap"}, value = 175.33},
                WeakAurasSaved        = {path = {"minimap"},                        value = 185.77},
                TradeSkillMasterDB    = {path = {"g@ @coreOptions@minimapIcon"},    value = 195.00},
            }
            for sv, spec in pairs(positions) do
                local t = _G[sv]
                if type(t) == "table" then
                    for _, k in ipairs(spec.path) do
                        t[k] = t[k] or {}
                        t = t[k]
                    end
                    if type(t) == "table" then t.minimapPos = spec.value end
                end
            end
        end)
    end
end)

-- Tier crossing detection: when player levels up, check if the new level
-- crosses a LAYOUT_TIERS boundary. If so, prompt + set needsSetup so the
-- next /setupbars (or login) applies the new tier.
local function CheckTierCrossing(newLevel)
    local _, class = UnitClass("player")
    local stored = registeredLayouts[class]
    if not stored then return end
    local boundaries = SetupCore:TierBoundaries(stored)
    if not boundaries then return end  -- not a tier structure, no-op
    for _, boundary in ipairs(boundaries) do
        if boundary == newLevel then
            print(string.format("|cffffd700SetupCore:|r You've crossed into the L%d layout tier — type |cff66ff66/setupbars|r to apply the new layout.", newLevel))
            SetupCoreCharDB.tierCrossingPending = newLevel
            return
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        if newLevel then CheckTierCrossing(newLevel) end
        return
    end
    -- PLAYER_LOGIN below
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

    -- If a tier crossing was pending from the prior session (player leveled
    -- up but didn't /setupbars yet), remind on login.
    if SetupCoreCharDB.tierCrossingPending then
        local pending = SetupCoreCharDB.tierCrossingPending
        local current = UnitLevel("player") or 1
        if current >= pending then
            print(string.format("|cffffd700SetupCore:|r L%d layout tier still pending — type |cff66ff66/setupbars|r to apply.", pending))
        else
            -- Should not happen, but guard against stale flag
            SetupCoreCharDB.tierCrossingPending = nil
        end
    end

    -- Restore Z bar bind + mount macro keybind (after ElvUI buttons exist).
    C_Timer.After(1, function()
        if SetupCore:GetDecurseSpec() then
            SetupCore:EnsureDecurseButton()
            SetupCore:UpdateDecurseButton()
        end
        SetupCore:ApplyBindings()
        SetupCore:RefreshDecurseBinding()
    end)
    C_Timer.After(3, function()
        SetupCore:ApplyTravelSlots()
        SetupCore:ApplyMountBarSlot()
        SetupCore:ApplyTotemCastSlot(6)
    end)
    C_Timer.After(5, function()
        SetupCore:ApplyMountBarSlot()
        SetupCore:ApplyMountKeybinds()
        SetupCore:ApplyTotemCastSlot(4)
    end)

    -- Fill layout gaps (e.g. Water Shield on a placeholder slot) and warn about
    -- anything still unmapped — racials included if not on bars.
    C_Timer.After(4, function()
        if SetupCoreDB.needsSetup then return end
        local placed = SetupCore:AutoPlaceUnplaced()
        if #placed > 0 then
            print("|cff00ff00SetupCore|r auto-placed on login: |cffffffff"..table.concat(placed, ", ").."|r")
        end
        SetupCore:ReportOrphans()
    end)

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

local totemAddonWatch = CreateFrame("Frame")
totemAddonWatch:RegisterEvent("ADDON_LOADED")
totemAddonWatch:SetScript("OnEvent", function(_, _, name)
    if name == "TotemTimers" then
        C_Timer.After(0.5, function() SetupCore:ApplyTotemCastSlot(4) end)
    end
end)
