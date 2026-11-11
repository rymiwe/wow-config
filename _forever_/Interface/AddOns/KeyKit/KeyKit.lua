-- KeyKit: pick a keybind profile, preview it on a keyboard, apply it on click.
-- Bindings only change when the player presses Apply or Undo. Nothing runs on
-- its own (Blizzard ToS: no automation).
local ADDON, ns = ...

local ACCOUNT, CHARACTER = 1, 2
local UNIT, KEY_H, GAP = 50, 46, 4
local NEUTRAL = { 0.45, 0.47, 0.52 }

local db                         -- KeyKitDB (SavedVariables, account-wide)
local frame, importFrame
local selected, layer = nil, "none"
local keyFrames = {}             -- base key -> key widget
local listButtons = {}

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffd4af5aKeyKit:|r " .. msg)
end

local function AllProfiles()
  local all = {}
  for _, p in ipairs(ns.PROFILES or {}) do all[#all + 1] = p end
  for _, p in ipairs(db.personal) do all[#all + 1] = p end
  return all
end

---------------------------------------------------------------------------
-- Binding work
---------------------------------------------------------------------------
local function SetOne(key, kind, value)
  if kind == "spell" then return SetBindingSpell and SetBindingSpell(key, value) end
  if kind == "item" then return SetBindingItem and SetBindingItem(key, value) end
  if kind == "macro" then return SetBindingMacro(key, value) end
  if kind == "click" then
    local button, mouse = value:match("^([^:]+):?(.*)$")
    return SetBindingClick(key, button, mouse ~= "" and mouse or nil)
  end
  return SetBinding(key, value)
end

local function SetStatus(msg)
  if frame then frame.status:SetText(msg) end
end

-- WoW: Forever uses the modern API: the old globals (GetSpellInfo, PickupSpell,
-- PickupItem) are gone, and looking a spell up by name is unreliable. So find
-- spells in the spellbook by name, and pick things up through C_Spell/C_Item.
local PickupSpellFn = (C_Spell and C_Spell.PickupSpell) or PickupSpell
local PickupItemFn = (C_Item and C_Item.PickupItem) or PickupItem
local PickupMacroFn = PickupMacro

-- Spell ID of the highest rank the character knows, else nil.
local function KnownSpell(name)
  local want = name:lower()
  if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
    local found
    for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
      local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
      if info then
        for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
          local item = C_SpellBook.GetSpellBookItemInfo(i, bank)
          if item and item.name and item.name:lower() == want and item.spellID
             and not item.isPassive and not item.isOffSpec then
            found = item.spellID   -- later entries are higher ranks
          end
        end
      end
    end
    if found then return found end
  end
  if C_Spell and C_Spell.GetSpellInfo then
    local info = C_Spell.GetSpellInfo(name)
    if info and info.spellID and (not IsPlayerSpell or IsPlayerSpell(info.spellID)) then
      return info.spellID
    end
    return nil
  end
  if GetSpellInfo then return select(7, GetSpellInfo(name)) end
  return nil
end

local function PickupThing(kind, id)
  if kind == "spell" and PickupSpellFn then PickupSpellFn(id)
  elseif kind == "item" and PickupItemFn then PickupItemFn(id)
  elseif kind == "macro" and PickupMacroFn then PickupMacroFn(id) end
end

-- Put a spell/item/macro on the cursor. Returns true if something landed there.
local function PickUp(kind, value)
  ClearCursor()
  if kind == "spell" then
    local id = KnownSpell(value)
    if not id then return false end
    PickupThing("spell", id)
  elseif kind == "item" or kind == "macro" then
    PickupThing(kind, value)
  else
    return false
  end
  local onCursor = GetCursorInfo()
  return onCursor == kind
end

-- Empty a slot, or put back what GetActionInfo reported for it.
local function RestoreSlot(slot, kind, id)
  ClearCursor()
  PickupThing(kind, id)
  if GetCursorInfo() then
    PlaceAction(slot)
  else
    PickupAction(slot)       -- nothing to put back: lift the slot's contents off
  end
  ClearCursor()
end

-- The bar button a key fires: its current binding if that is a bar button,
-- else the wow-config bindings template (ns.BAR_KEYS, generated).
local function BarCommandFor(key)
  local current = GetBindingAction(key)
  if ns.SlotForCommand(current) then return current end
  local cmd = ns.BAR_KEYS and ns.BAR_KEYS[key]
  if ns.SlotForCommand(cmd) then return cmd end
  return nil
end

local function Apply()
  if not selected then return end
  if InCombatLockdown() then
    SetStatus("|cffff6060You're in combat. Apply again once the fight is over.|r")
    return
  end
  -- Snapshot every key and bar slot this profile touches, so Undo can put them back.
  local snap = { set = GetCurrentBindingSet(), keys = {}, slots = {}, profile = selected.title }
  local placed, bound, skipped = 0, 0, {}
  for _, b in ipairs(selected.binds) do
    if b.kind then
      if snap.keys[b.key] == nil then snap.keys[b.key] = GetBindingAction(b.key) or "" end
      local placeable = b.kind == "spell" or b.kind == "item" or b.kind == "macro"
      local cmd = placeable and BarCommandFor(b.key)
      if cmd then
        -- Key keeps (or gets back) its bar button; the spell goes on that button.
        local slot = ns.SlotForCommand(cmd)
        if PickUp(b.kind, b.value) then
          if not snap.slots[slot] then
            local t, id = GetActionInfo(slot)
            snap.slots[slot] = { kind = t or "", id = id }
          end
          PlaceAction(slot)
          ClearCursor()
          if GetBindingAction(b.key) ~= cmd then SetBinding(b.key, cmd) end
          placed = placed + 1
        else
          ClearCursor()
          skipped[#skipped + 1] = b.key .. " " .. b.value
        end
      elseif SetOne(b.key, b.kind, b.value) then
        bound = bound + 1
      else
        skipped[#skipped + 1] = b.key .. " " .. b.value
      end
    end
  end
  local which = frame.charOnly:GetChecked() and CHARACTER or ACCOUNT
  SaveBindings(which)
  db.undo = snap
  frame.undo:Enable()
  local msg = ("Applied %s: %d on bars, %d keys bound, saved for %s."):format(
    selected.title, placed, bound, which == CHARACTER and "this character" or "all characters")
  if #skipped > 0 then
    msg = msg .. (" Skipped %d (not learned yet?)."):format(#skipped)
    Print("Skipped: " .. table.concat(skipped, ", "))
  end
  SetStatus(msg)
  Print(msg)
end

local function Undo()
  local snap = db.undo
  if not snap then return end
  if InCombatLockdown() then
    SetStatus("|cffff6060You're in combat. Undo once the fight is over.|r")
    return
  end
  for slot, old in pairs(snap.slots or {}) do
    RestoreSlot(slot, old.kind, old.id)
  end
  for key, action in pairs(snap.keys) do
    if action == "" then
      SetBinding(key)
    else
      SetOne(key, ns.ActionToEntry(action))
    end
  end
  SaveBindings(snap.set or GetCurrentBindingSet())
  db.undo = nil
  frame.undo:Disable()
  local msg = "Put back the keys and bar buttons from before " .. (snap.profile or "the last Apply") .. "."
  SetStatus(msg)
  Print(msg)
end

local function ExportCurrent()
  local p = { name = "My bindings " .. date("%Y-%m-%d"), class = "any", levels = "any", binds = {} }
  for _, key in ipairs(ns.AllKeys()) do
    local kind, value = ns.ActionToEntry(GetBindingAction(key))
    if kind then p.binds[#p.binds + 1] = { key = key, kind = kind, value = value } end
  end
  return ns.Format(p)
end

---------------------------------------------------------------------------
-- Preview
---------------------------------------------------------------------------
local function Paint(w, color, text)
  local c = color or NEUTRAL
  local a = color and 0.55 or 0.18
  w.fill:SetColorTexture(c[1] * a, c[2] * a, c[3] * a, 0.95)
  w.edge:SetColorTexture(c[1] * 0.7, c[2] * 0.7, c[3] * 0.7, color and 1 or 0.4)
  w.action:SetText(text or "")
end

local function RefreshPreview()
  if not frame then return end
  for _, w in pairs(keyFrames) do Paint(w, nil, nil) end
  for _, b in ipairs(frame.layerButtons) do
    if b.layer == layer then b:LockHighlight() else b:UnlockHighlight() end
  end
  if not selected then
    frame.title:SetText("Pick a profile on the left")
    frame.info:SetText("")
    frame.note:SetText("")
    frame.url:SetText("")
    frame.apply:Disable()
    frame.delete:Hide()
    return
  end
  for _, b in ipairs(selected.binds) do
    local w = keyFrames[b.base]
    if w and b.layer == layer then
      local color = ns.ROLE_COLORS[b.role or ""] or (b.kind and NEUTRAL)
      Paint(w, color, b.label or b.value)
      if not b.kind then w.action:SetText((b.label or "") .. "\n|cff999999(look only)|r") end
    end
  end
  frame.title:SetText(selected.title)
  frame.info:SetText(("Class: %s   Levels: %s%s"):format(selected.class or "any", selected.levels or "any",
    selected.credit and selected.credit ~= "" and ("   By: " .. selected.credit) or ""))
  frame.note:SetText(selected.note or "")
  frame.url:SetText(selected.url or "")
  frame.url:SetCursorPosition(0)
  frame.apply:Enable()
  if selected.personal then frame.delete:Show() else frame.delete:Hide() end
end

local function RefreshList()
  local profiles = AllProfiles()
  local child = frame.listChild
  for i, p in ipairs(profiles) do
    local b = listButtons[i]
    if not b then
      b = CreateFrame("Button", nil, child)
      b:SetSize(210, 38)
      b:SetPoint("TOPLEFT", 0, -(i - 1) * 40)
      b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
      b.top = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      b.top:SetPoint("TOPLEFT", 6, -4)
      b.top:SetWidth(200)
      b.top:SetJustifyH("LEFT")
      b.sub = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      b.sub:SetPoint("TOPLEFT", b.top, "BOTTOMLEFT", 0, -2)
      b.sub:SetWidth(200)
      b.sub:SetJustifyH("LEFT")
      b:SetScript("OnClick", function(self)
        selected = self.profile
        RefreshPreview()
        for _, o in ipairs(listButtons) do o:UnlockHighlight() end
        self:LockHighlight()
      end)
      listButtons[i] = b
    end
    b.profile = p
    b.top:SetText(p.title)
    b.sub:SetText((p.class or "any") .. ", levels " .. (p.levels or "any") .. (p.personal and ", yours" or ""))
    b:Show()
  end
  for i = #profiles + 1, #listButtons do listButtons[i]:Hide() end
  child:SetHeight(math.max(1, #profiles * 40))
end

---------------------------------------------------------------------------
-- Import / export window
---------------------------------------------------------------------------
local function ShowTextWindow(mode)
  if not importFrame then
    local f = CreateFrame("Frame", "KeyKitImportFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetSize(520, 380)
    f:SetPoint("CENTER", 0, 40)
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 24,
      insets = { left = 6, right = 6, top = 6, bottom = 6 } })
    f:EnableMouse(true)
    tinsert(UISpecialFrames, "KeyKitImportFrame")
    f.head = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.head:SetPoint("TOP", 0, -16)
    f.help = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.help:SetPoint("TOPLEFT", 20, -42)
    f.help:SetWidth(480)
    f.help:SetJustifyH("LEFT")
    local scroll = CreateFrame("ScrollFrame", "KeyKitImportScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 20, -80)
    scroll:SetPoint("BOTTOMRIGHT", -40, 50)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(450)
    edit:SetAutoFocus(false)
    edit:SetScript("OnEscapePressed", edit.ClearFocus)
    scroll:SetScrollChild(edit)
    f.edit = edit
    f.save = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.save:SetSize(140, 24)
    f.save:SetPoint("BOTTOMLEFT", 20, 16)
    f.save:SetText("Add as my profile")
    f.save:SetScript("OnClick", function()
      local p, err = ns.Parse(edit:GetText())
      if not p then
        f.help:SetText("|cffff6060Could not read that: " .. err .. "|r")
        return
      end
      p.personal = true
      for i = #db.personal, 1, -1 do
        if db.personal[i].id == p.id then table.remove(db.personal, i) end
      end
      db.personal[#db.personal + 1] = p
      RefreshList()
      selected = p
      RefreshPreview()
      f:Hide()
      Print("Added " .. p.title .. ". Check the preview, then press Apply.")
    end)
    local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    close:SetSize(90, 24)
    close:SetPoint("BOTTOMRIGHT", -20, 16)
    close:SetText("Close")
    close:SetScript("OnClick", function() f:Hide() end)
    importFrame = f
  end
  local f = importFrame
  if mode == "export" then
    f.head:SetText("Export current bindings")
    f.help:SetText("Ctrl-A then Ctrl-C to copy. Paste it into Import on another character or computer.")
    f.edit:SetText(ExportCurrent())
    f.edit:HighlightText()
    f.edit:SetFocus()
  else
    f.head:SetText("Import a profile")
    f.help:SetText("Paste a KeyKit profile (Ctrl-V). One line each: 'name = ...', then 'KEY = spell Name', "
      .. "'KEY = cmd BINDING', 'KEY = macro Name'. It is saved on this computer only.")
    f.edit:SetText("")
    f.edit:SetFocus()
  end
  f:Show()
end

---------------------------------------------------------------------------
-- Main window
---------------------------------------------------------------------------
local function MakeKey(parent, base, cap, x, y, w)
  local k = CreateFrame("Frame", nil, parent)
  k:SetSize(w, KEY_H)
  k:SetPoint("TOPLEFT", x, -y)
  k.edge = k:CreateTexture(nil, "BACKGROUND")
  k.edge:SetAllPoints()
  k.fill = k:CreateTexture(nil, "BORDER")
  k.fill:SetPoint("TOPLEFT", 1, -1)
  k.fill:SetPoint("BOTTOMRIGHT", -1, 1)
  k.cap = k:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  k.cap:SetPoint("TOPLEFT", 4, -3)
  k.cap:SetText(cap)
  k.action = k:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  k.action:SetPoint("TOPLEFT", 3, -15)
  k.action:SetPoint("BOTTOMRIGHT", -3, 2)
  k.action:SetJustifyH("CENTER")
  k.action:SetJustifyV("MIDDLE")
  keyFrames[base] = k
  return k
end

-- Run a click handler; if it fails, say so in the window and chat.
local function Safe(what, fn)
  local ok, err = xpcall(fn, function(e) return tostring(e) .. "\n" .. (debugstack and debugstack(2, 3, 0) or "") end)
  if not ok then
    ClearCursor()
    SetStatus("|cffff6060" .. what .. " failed. The error is in chat; please send it to Ryan's addon helper.|r")
    Print(what .. " failed: " .. err)
  end
end

local function Button(parent, text, w, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(w, 24)
  b:SetText(text)
  b:SetScript("OnClick", onClick)
  return b
end

local function BuildFrame()
  local f = CreateFrame("Frame", "KeyKitFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  f:SetSize(860, 520)
  f:SetPoint("CENTER")
  f:SetFrameStrata("HIGH")
  f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 } })
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()
  tinsert(UISpecialFrames, "KeyKitFrame")
  frame = f

  local head = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  head:SetPoint("TOPLEFT", 20, -16)
  head:SetText("KeyKit - keybind profiles")
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -4, -4)

  -- Profile list
  local scroll = CreateFrame("ScrollFrame", "KeyKitListScroll", f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 16, -44)
  scroll:SetSize(214, 400)
  local child = CreateFrame("Frame", nil, scroll)
  child:SetSize(214, 1)
  scroll:SetScrollChild(child)
  f.listChild = child

  -- Profile details
  local px = 262
  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  f.title:SetPoint("TOPLEFT", px, -44)
  f.info = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  f.info:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -4)
  f.note = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  f.note:SetPoint("TOPLEFT", f.info, "BOTTOMLEFT", 0, -4)
  f.note:SetWidth(570)
  f.note:SetJustifyH("LEFT")
  local srcLabel = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  srcLabel:SetPoint("TOPLEFT", px, -118)
  srcLabel:SetText("Source (copy with Ctrl-C):")
  f.url = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  f.url:SetSize(400, 18)
  f.url:SetPoint("LEFT", srcLabel, "RIGHT", 10, 0)
  f.url:SetAutoFocus(false)
  f.url:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
  f.url:SetScript("OnEscapePressed", f.url.ClearFocus)
  f.url:SetScript("OnChar", function(self) self:SetText(selected and selected.url or "") end)

  -- Layer tabs
  f.layerButtons = {}
  local names = { none = "Plain keys", shift = "Shift", alt = "Alt", ctrl = "Ctrl" }
  for i, l in ipairs(ns.LAYERS) do
    local b = Button(f, names[l], 90, function()
      layer = l
      RefreshPreview()
    end)
    b:SetPoint("TOPLEFT", px + (i - 1) * 94, -140)
    b.layer = l
    f.layerButtons[i] = b
  end

  -- Keyboard
  local top = 172
  for r, row in ipairs(ns.ROWS) do
    local x = px
    for _, k in ipairs(row) do
      local w = math.floor(k[3] * UNIT + 0.5)
      MakeKey(f, k[1], k[2], x, top + (r - 1) * (KEY_H + GAP), w)
      x = x + w + GAP
    end
  end
  local mouseLabel = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  mouseLabel:SetPoint("TOPLEFT", px + 8 * (UNIT + GAP) + 20, -(top - 14))
  mouseLabel:SetText("Mouse")
  for i, m in ipairs(ns.MOUSE) do
    MakeKey(f, m[1], m[2], px + 8 * (UNIT + GAP) + 20, top + (i - 1) * (KEY_H + GAP), 120)
  end

  -- Actions
  f.apply = Button(f, "Apply", 100, function() Safe("Apply", Apply) end)
  f.apply:SetPoint("BOTTOMLEFT", px, 44)
  f.undo = Button(f, "Undo", 80, function() Safe("Undo", Undo) end)
  f.undo:SetPoint("LEFT", f.apply, "RIGHT", 6, 0)
  f.charOnly = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
  f.charOnly:SetPoint("LEFT", f.undo, "RIGHT", 10, 0)
  local cl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  cl:SetPoint("LEFT", f.charOnly, "RIGHT", 2, 0)
  cl:SetText("Only this character")
  f.import = Button(f, "Import...", 90, function() ShowTextWindow("import") end)
  f.import:SetPoint("BOTTOMRIGHT", -112, 44)
  f.export = Button(f, "Export", 90, function() ShowTextWindow("export") end)
  f.export:SetPoint("LEFT", f.import, "RIGHT", 6, 0)
  f.delete = Button(f, "Delete", 80, function()
    for i = #db.personal, 1, -1 do
      if db.personal[i] == selected then table.remove(db.personal, i) end
    end
    selected = nil
    RefreshList()
    RefreshPreview()
  end)
  f.delete:SetPoint("BOTTOMLEFT", 20, 44)
  f.status = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  f.status:SetPoint("BOTTOMLEFT", 20, 20)
  f.status:SetWidth(820)
  f.status:SetJustifyH("LEFT")

  f:SetScript("OnShow", function()
    f.charOnly:SetChecked(GetCurrentBindingSet() == CHARACTER)
    if db.undo then f.undo:Enable() else f.undo:Disable() end
    RefreshList()
    RefreshPreview()
  end)
end

---------------------------------------------------------------------------
-- Startup
---------------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
  if name ~= ADDON then return end
  KeyKitDB = KeyKitDB or {}
  KeyKitDB.personal = KeyKitDB.personal or {}
  db = KeyKitDB
  self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_KEYKIT1 = "/keykit"
SlashCmdList.KEYKIT = function()
  if not frame then BuildFrame() end
  if frame:IsShown() then frame:Hide() else frame:Show() end
end
