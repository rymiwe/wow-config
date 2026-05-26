-- ElvUI Fixes — runtime patches for ElvUI + Anniversary client quirks.
--
-- Chat:
--   - Force GeneralDockManager.primary=ChatFrame1, re-snap after SetPoint drift
--   - Consolidate chat tabs into left panel; hide unused right panel
--   - Guard ChatConfigFrame Settings when extra chat tabs aren't initialized
--
-- Game menu:
--   - Secure /logout and /quit overlays on Esc menu (Logout()/Quit() are protected)

local function GetDock()
    return _G.GeneralDockManager or _G.GENERAL_CHAT_DOCK
end

local function GetCH()
    local E = _G.ElvUI and _G.ElvUI[1]
    return E and E:GetModule('Chat', true)
end

local function GetChatTab(chatFrame)
    if not chatFrame then return nil end
    return _G[chatFrame:GetName() .. 'Tab']
end

local function ChatIndexHasTab(index)
    if type(index) ~= 'number' or index < 1 then return false end
    if index > (_G.NUM_CHAT_WINDOWS or 10) then return false end
    local chatFrame = _G['ChatFrame' .. index]
    return chatFrame and GetChatTab(chatFrame) ~= nil
end

local function InitChatFrame(index)
    local chatFrame = _G['ChatFrame' .. index]
    if not chatFrame then return false end
    if _G.FloatingChatFrame_Update then
        _G.FloatingChatFrame_Update(index, 1)
        chatFrame.isInitialized = 1
    end
    if ChatIndexHasTab(index) then return true end
    if _G.CreateFrame and not _G['ChatFrame' .. index .. 'Tab'] then
        _G.CreateFrame('Button', 'ChatFrame' .. index .. 'Tab', UIParent, 'ChatTabTemplate', index)
        if _G.FloatingChatFrame_Update then
            _G.FloatingChatFrame_Update(index, 1)
        end
    end
    return ChatIndexHasTab(index)
end

local function ResolveChatConfigIndex(index)
    if type(index) == 'number' and InitChatFrame(index) then return index end
    if _G.FCF_GetCurrentChatFrameID then
        local cur = _G.FCF_GetCurrentChatFrameID()
        if type(cur) == 'number' and InitChatFrame(cur) then return cur end
    end
    for i = 1, (_G.NUM_CHAT_WINDOWS or 10) do
        if InitChatFrame(i) then return i end
    end
    return 1
end

local function PrepareChatConfigOpen()
    local raw = (_G.FCF_GetCurrentChatFrameID and _G.FCF_GetCurrentChatFrameID())
        or _G.CURRENT_CHAT_FRAME_ID
        or 1
    local safe = ResolveChatConfigIndex(raw)
    if safe ~= raw then
        print(string.format(
            '|cffffd700ElvUIFixes|r: Chat %d is not ready for Settings — using Chat %d (General). /reload if tabs look wrong.',
            raw, safe))
    end
    _G.CURRENT_CHAT_FRAME_ID = safe
    return safe
end

local function EnsureChatTabs()
    for i = 1, (_G.NUM_CHAT_WINDOWS or 10) do
        local chat = _G['ChatFrame' .. i]
        if chat and chat:IsShown() then
            InitChatFrame(i)
            local tab = GetChatTab(chat)
            if tab and chat.isDocked and not tab:IsShown() then
                tab:Show()
            end
        end
    end
end

local function WrapShowUIPanel()
    if _G.ShowUIPanel_ElvUIFixesWrapped then return end
    local orig = _G.ShowUIPanel
    if type(orig) ~= 'function' then return end
    _G.ShowUIPanel = function(frame, ...)
        if frame == _G.ChatConfigFrame then
            PrepareChatConfigOpen()
        end
        return orig(frame, ...)
    end
    _G.ShowUIPanel_ElvUIFixesWrapped = true
end

local function ConsolidateChats()
    local dock = GetDock()
    for _, frameName in ipairs(_G.CHAT_FRAMES or {}) do
        local chat = _G[frameName]
        if chat and chat ~= _G.ChatFrame1 then
            if chat.isDocked then
                local _, relativeTo = chat:GetPoint()
                if dock and relativeTo ~= dock then
                    _G.FCF_DockFrame(chat)
                end
            else
                _G.FCF_DockFrame(chat)
            end
        end
    end
    if _G.FCF_DockUpdate then
        _G.FCF_DockUpdate()
    end
    EnsureChatTabs()
    if _G.RightChatPanel then
        _G.RightChatPanel:SetAlpha(0)
        _G.RightChatPanel:EnableMouse(false)
    end
    if _G.RightChatToggleButton then
        _G.RightChatToggleButton:SetAlpha(0)
        _G.RightChatToggleButton:EnableMouse(false)
    end
    if _G.RightChatDataPanel then
        _G.RightChatDataPanel:SetAlpha(0)
        _G.RightChatDataPanel:EnableMouse(false)
    end
end

local function ApplyInitFix()
    local dock = GetDock()
    if dock and _G.ChatFrame1 and dock.primary ~= _G.ChatFrame1 then
        dock.primary = _G.ChatFrame1
    end
    local CH = GetCH()
    if CH and CH.PositionChats then
        CH:PositionChats()
    end
    ConsolidateChats()
end

local applying = false
local function SnapToPanel()
    if applying or not _G.LeftChatPanel or not _G.ChatFrame1 then return end
    applying = true
    _G.ChatFrame1:ClearAllPoints()
    _G.ChatFrame1:SetPoint('BOTTOMLEFT', _G.LeftChatPanel, 'BOTTOMLEFT', 4, 4)
    _G.ChatFrame1:SetPoint('TOPRIGHT', _G.LeftChatPanel, 'TOPRIGHT', -4, -28)
    applying = false
end

local hooked = false

local function IsLogoutLabel(text)
    if not text or text == "" then return false end
    if _G.LOGOUT and text == _G.LOGOUT then return true end
    if _G.GAMEMENU_LOGOUT and text == _G.GAMEMENU_LOGOUT then return true end
    return text == "Log Out"
end

local function IsQuitLabel(text)
    if not text or text == "" then return false end
    if _G.QUIT_GAME and text == _G.QUIT_GAME then return true end
    if _G.QUIT and text == _G.QUIT then return true end
    return text == "Exit Game"
end

local function IsGameMenuActionButton(btn)
    if not btn or btn == _G.GameMenuFrame then return false end
    if not btn.IsObjectType or not btn:IsObjectType("Button") then return false end
    local w, h = btn:GetSize()
    if not w or not h or w < 40 or h < 10 then return false end
    -- Real menu rows are ~144x21; reject frames that span the whole panel.
    if w > 320 or h > 48 then return false end
    return true
end

local function ClearSecureOverlay(btn)
    if not btn or not btn.ElvUIFixesSecure then return end
    btn.ElvUIFixesSecure:Hide()
    btn.ElvUIFixesSecure:ClearAllPoints()
    btn.ElvUIFixesSecure:SetParent(nil)
    btn.ElvUIFixesSecure = nil
end

local function EnsureSecureMacroOverlay(btn, macrotext)
    if not IsGameMenuActionButton(btn) or not macrotext or InCombatLockdown() then return end
    local overlay = btn.ElvUIFixesSecure
    if not overlay then
        overlay = CreateFrame("Button", nil, btn, "SecureActionButtonTemplate")
        overlay:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        overlay:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
        overlay:SetFrameStrata(btn:GetFrameStrata())
        overlay:RegisterForClicks("AnyUp", "AnyDown")
        overlay:EnableMouse(true)
        btn.ElvUIFixesSecure = overlay
    end
    overlay:SetFrameLevel(btn:GetFrameLevel() + 2)
    if overlay:GetAttribute("macrotext") ~= macrotext then
        overlay:SetAttribute("type", "macro")
        overlay:SetAttribute("macrotext", macrotext)
    end
    overlay:Show()
end

local function ConsiderGameMenuButton(btn)
    if not IsGameMenuActionButton(btn) then return end
    local text = btn.GetText and btn:GetText()
    if IsLogoutLabel(text) then
        EnsureSecureMacroOverlay(btn, "/logout")
    elseif IsQuitLabel(text) then
        EnsureSecureMacroOverlay(btn, "/quit")
    else
        ClearSecureOverlay(btn)
    end
end

local function FixGameMenuLogoutButtons()
    local menu = _G.GameMenuFrame
    if not menu then return end

    if menu.buttonPool and menu.buttonPool.EnumerateActive then
        for button in menu.buttonPool:EnumerateActive() do
            ConsiderGameMenuButton(button)
        end
    end

    if menu.MenuButtons then
        for _, button in pairs(menu.MenuButtons) do
            ConsiderGameMenuButton(button)
        end
    end

    -- Legacy named buttons (pre-buttonPool). Only bind when label matches — the global
    -- can point at the wrong frame on TBC/Anniversary and cover the whole menu.
    ConsiderGameMenuButton(_G.GameMenuButtonLogout)
    ConsiderGameMenuButton(_G.GameMenuButtonQuit)
end

local gameMenuHooked = false
local function SetupGameMenuFix()
    if gameMenuHooked then return end
    local menu = _G.GameMenuFrame
    if not menu then return end

    menu:HookScript("OnShow", FixGameMenuLogoutButtons)
    if menu.InitButtons then
        hooksecurefunc(menu, "InitButtons", FixGameMenuLogoutButtons)
    end
    if menu.Layout then
        hooksecurefunc(menu, "Layout", function()
            C_Timer.After(0, FixGameMenuLogoutButtons)
        end)
    end
    if _G.GameMenuFrame_UpdateVisibleButtons then
        hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", FixGameMenuLogoutButtons)
    end

    gameMenuHooked = true
    FixGameMenuLogoutButtons()
end

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ADDON_LOADED')
f:SetScript('OnEvent', function(_, event, addon)
    if event == 'ADDON_LOADED' then
        if addon == 'Blizzard_UIParentPanelManager' or addon == 'Blizzard_ChatFrame'
            or addon == 'Blizzard_ChatFrameBase' then
            WrapShowUIPanel()
        end
        if addon == 'ElvUI' or addon == 'Blizzard_GlueXML' then
            SetupGameMenuFix()
        end
        return
    end
    WrapShowUIPanel()
    SetupGameMenuFix()
    C_Timer.After(0.3, function()
        ApplyInitFix()
        SnapToPanel()
        if not hooked and _G.ChatFrame1 then
            hooksecurefunc(_G.ChatFrame1, 'SetPoint', SnapToPanel)
            hooked = true
        end
    end)
end)

WrapShowUIPanel()
SetupGameMenuFix()
