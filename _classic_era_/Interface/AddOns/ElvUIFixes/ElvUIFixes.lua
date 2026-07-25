-- ElvUI Fixes — runtime patches for ElvUI + Anniversary client quirks.
--
-- Chat:
--   - Force GeneralDockManager.primary=ChatFrame1, re-snap after SetPoint drift
--   - Consolidate chat tabs into left panel; hide unused right panel
--   - Close unused chat windows 4–10 (persisted in chat-cache) so tabs stop reappearing
--   - Guard ChatConfigFrame Settings when extra chat tabs aren't initialized
--
-- Game menu:
--   - Secure /logout and /quit overlays on Esc menu (Logout()/Quit() are protected)
--
-- Guild:
--   - Secure overlays on promote/demote + rank-order arrows (ElvUI skinning taints protected clicks)
--
-- Quest watch:
--   - Guard QuestWatch_Update when QuestWatchLine frames are not ready (Anniversary login race)
--
-- UI scale:
--   - Force ElvUI's account-wide UIScale to a fixed value on login (see UI_SCALE)

local function GetDock()
    return _G.GeneralDockManager or _G.GENERAL_CHAT_DOCK
end

local function GetCH()
    local E = _G.ElvUI and _G.ElvUI[1]
    return E and E:GetModule('Chat', true)
end

local KEEP_CHAT_WINDOWS = 3 -- General, Combat Log, Voice

local function GetChatWindowName(index)
    if not _G.FCF_GetChatWindowInfo then return nil end
    local name = _G.FCF_GetChatWindowInfo(index)
    if type(name) ~= 'string' or name == '' then return nil end
    return name
end

local function IsExtraChatWindow(index)
    if type(index) ~= 'number' or index <= KEEP_CHAT_WINDOWS then return false end
    if index > (_G.NUM_CHAT_WINDOWS or 10) then return false end
    local name = GetChatWindowName(index)
    if not name then return true end
    if name:match('^Chat %d+$') then return true end
    return false
end

local function PruneExtraChatWindows()
    if not _G.FCF_Close then return end
    for i = (_G.NUM_CHAT_WINDOWS or 10), KEEP_CHAT_WINDOWS + 1, -1 do
        if IsExtraChatWindow(i) then
            local chat = _G['ChatFrame' .. i]
            if chat then
                pcall(_G.FCF_Close, chat)
            end
        end
    end
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
    if IsExtraChatWindow(index) then return false end
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
    for i = 1, KEEP_CHAT_WINDOWS do
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
    for i = 1, KEEP_CHAT_WINDOWS do
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
            local id = chat.GetID and chat:GetID()
            if id and IsExtraChatWindow(id) then
                -- skip empty slots persisted in chat-cache
            elseif chat.isDocked then
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
    PruneExtraChatWindows()
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

local function RestoreUnderlyingMouse(btn)
    if btn and btn.ElvUIFixesMouseDisabled then
        btn:EnableMouse(true)
        btn.ElvUIFixesMouseDisabled = nil
    end
end

local function ClearSecureOverlay(btn)
    if not btn or not btn.ElvUIFixesSecure then return end
    btn.ElvUIFixesSecure:Hide()
    btn.ElvUIFixesSecure:ClearAllPoints()
    btn.ElvUIFixesSecure:SetParent(nil)
    btn.ElvUIFixesSecure = nil
    RestoreUnderlyingMouse(btn)
end

-- Parent on UIParent: secure children of ElvUI-skinned buttons inherit taint and cannot
-- call protected guild APIs even through macro attributes.
local function EnsureSecureMacroOverlay(btn, macrotext, opts)
    if not btn or not macrotext or InCombatLockdown() then return end
    opts = opts or {}
    if opts.requireEnabled and btn.IsEnabled and not btn:IsEnabled() then
        ClearSecureOverlay(btn)
        return
    end
    if opts.requireShown and btn.IsShown and not btn:IsShown() then
        ClearSecureOverlay(btn)
        return
    end
    local overlay = btn.ElvUIFixesSecure
    if not overlay then
        overlay = CreateFrame('Button', nil, _G.UIParent, 'SecureActionButtonTemplate')
        overlay:RegisterForClicks('AnyUp', 'AnyDown')
        overlay:EnableMouse(true)
        btn.ElvUIFixesSecure = overlay
    end
    local strata = btn.GetFrameStrata and btn:GetFrameStrata() or 'DIALOG'
    overlay:SetFrameStrata(strata)
    overlay:SetFrameLevel((btn.GetFrameLevel and btn:GetFrameLevel() or 1) + 20)
    overlay:ClearAllPoints()
    overlay:SetPoint('TOPLEFT', btn, 'TOPLEFT', -2, 2)
    overlay:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMRIGHT', 2, -2)
    if overlay:GetAttribute('macrotext') ~= macrotext then
        overlay:SetAttribute('type', 'macro')
        overlay:SetAttribute('macrotext', macrotext)
    end
    if opts.disableUnderlyingMouse and btn.EnableMouse then
        btn:EnableMouse(false)
        btn.ElvUIFixesMouseDisabled = true
    end
    overlay:Show()
end

local GUILD_MEMBER_NAME_MACRO =
    'local n if GuildFrame and GuildFrame.selectedName then n=GuildFrame.selectedName else local i=GetGuildRosterSelection and GetGuildRosterSelection() if i and i>0 and GetGuildRosterInfo then n=GetGuildRosterInfo(i) end end '

local PROMOTE_MACRO = GUILD_MEMBER_NAME_MACRO .. 'if n and C_GuildInfo and C_GuildInfo.Promote then C_GuildInfo.Promote(n) end'
local DEMOTE_MACRO = GUILD_MEMBER_NAME_MACRO .. 'if n and C_GuildInfo and C_GuildInfo.Demote then C_GuildInfo.Demote(n) end'

local function FixGuildMemberRankButtons()
    EnsureSecureMacroOverlay(_G.GuildFramePromoteButton, PROMOTE_MACRO, {
        requireEnabled = true,
        requireShown = true,
        disableUnderlyingMouse = true,
    })
    EnsureSecureMacroOverlay(_G.GuildFrameDemoteButton, DEMOTE_MACRO, {
        requireEnabled = true,
        requireShown = true,
        disableUnderlyingMouse = true,
    })
end

local GUILD_CONTROL_CLEAR_FOCUS =
    'local f=GuildControlUI and GuildControlUI.activeEditBox if f then f:ClearFocus() end '

local function FixGuildControlRankButtons()
    if not _G.GuildControlGetNumRanks then return end
    for i = 1, GuildControlGetNumRanks() do
        local rankFrame = _G['GuildControlUIRankOrderFrameRank' .. i]
        if rankFrame then
            if rankFrame.upButton then
                EnsureSecureMacroOverlay(rankFrame.upButton,
                    GUILD_CONTROL_CLEAR_FOCUS .. 'GuildControlUI_DisableRankButtons() GuildControlShiftRankUp(' .. i .. ')',
                    { requireEnabled = true, requireShown = true, disableUnderlyingMouse = true })
            end
            if rankFrame.downButton then
                EnsureSecureMacroOverlay(rankFrame.downButton,
                    GUILD_CONTROL_CLEAR_FOCUS .. 'GuildControlUI_DisableRankButtons() GuildControlShiftRankDown(' .. i .. ')',
                    { requireEnabled = true, requireShown = true, disableUnderlyingMouse = true })
            end
        end
    end
end

local guildMemberDetailHooked = false
local guildStatusHooked = false
local guildControlShowHooked = false
local guildControlUpdateHooked = false
local function SetupGuildRankArrowFix()
    if not guildMemberDetailHooked and _G.GuildMemberDetailFrame then
        _G.GuildMemberDetailFrame:HookScript('OnShow', function()
            FixGuildMemberRankButtons()
            C_Timer.After(0, FixGuildMemberRankButtons)
        end)
        guildMemberDetailHooked = true
    end
    if not guildStatusHooked and _G.GuildStatus_Update then
        hooksecurefunc('GuildStatus_Update', FixGuildMemberRankButtons)
        guildStatusHooked = true
    end

    if not guildControlShowHooked and _G.GuildControlUI then
        _G.GuildControlUI:HookScript('OnShow', FixGuildControlRankButtons)
        guildControlShowHooked = true
    end
    if not guildControlUpdateHooked and _G.GuildControlUI_RankOrder_Update then
        hooksecurefunc('GuildControlUI_RankOrder_Update', function()
            C_Timer.After(0, FixGuildControlRankButtons)
        end)
        guildControlUpdateHooked = true
    end

    FixGuildMemberRankButtons()
    FixGuildControlRankButtons()
end

local function EnsureGameMenuSecureMacroOverlay(btn, macrotext)
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
        EnsureGameMenuSecureMacroOverlay(btn, "/logout")
    elseif IsQuitLabel(text) then
        EnsureGameMenuSecureMacroOverlay(btn, "/quit")
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

local function QuestieTrackerActive()
    if not _G.Questie then
        return false
    end
    if _G.Questie.db and _G.Questie.db.profile then
        return _G.Questie.db.profile.trackerEnabled ~= false
    end
    -- Questie loads db after PLAYER_LOGIN; assume tracker until profile is ready.
    return true
end

local function DisableQuestWatchMouseCapture()
    if _G.QuestWatchFrame then
        _G.QuestWatchFrame:Hide()
        _G.QuestWatchFrame:EnableMouse(false)
    end
    if _G.QuestTimerFrame then
        _G.QuestTimerFrame:Hide()
        _G.QuestTimerFrame:EnableMouse(false)
    end

    local E = _G.ElvUI and _G.ElvUI[1]
    local BL = E and E:GetModule('Blizzard', true)
    if BL and BL.QuestWatch_ClickFrames then
        for _, clickFrame in pairs(BL.QuestWatch_ClickFrames) do
            clickFrame:SetScript('OnMouseUp', nil)
            clickFrame:EnableMouse(false)
            clickFrame:Hide()
        end
    end
end

local function SafeQuestLogOnEvent(event, ...)
    if event == 'QUEST_LOG_UPDATE' or event == 'UPDATE_FACTION'
        or (event == 'UNIT_QUEST_LOG_CHANGED' and select(1, ...) == 'player') then
        if _G.QuestLog_Update then
            _G.QuestLog_Update()
        end
        if _G.QuestLogFrame and _G.QuestLogFrame:IsVisible() and _G.QuestLog_UpdateQuestDetails then
            _G.QuestLog_UpdateQuestDetails(1)
        end
        if _G.AUTO_QUEST_WATCH == '1' and _G.AutoQuestWatch_CheckDeleted then
            _G.AutoQuestWatch_CheckDeleted()
        end
    elseif event == 'QUEST_WATCH_UPDATE' then
        if _G.AUTO_QUEST_WATCH == '1' and _G.AutoQuestWatch_Update then
            _G.AutoQuestWatch_Update(...)
        end
    else
        if _G.QuestLog_Update then
            _G.QuestLog_Update()
        end
        if event == 'PARTY_MEMBERS_CHANGED' and _G.QuestFramePushQuestButton then
            if _G.GetQuestLogPushable and _G.GetQuestLogPushable()
                and _G.GetNumPartyMembers and _G.GetNumPartyMembers() > 0 then
                _G.QuestFramePushQuestButton:Enable()
            else
                _G.QuestFramePushQuestButton:Disable()
            end
        end
    end
    DisableQuestWatchMouseCapture()
end

local elvQuestWatchHooked = false
local function SuppressElvUIQuestWatchClicks()
    if elvQuestWatchHooked then return end
    local E = _G.ElvUI and _G.ElvUI[1]
    local BL = E and E:GetModule('Blizzard', true)
    if not BL or type(BL.QuestWatch_AddQuestClick) ~= 'function' then
        return
    end

    local orig = BL.QuestWatch_AddQuestClick
    BL.QuestWatch_AddQuestClick = function(...)
        if QuestieTrackerActive() then
            DisableQuestWatchMouseCapture()
            return
        end
        orig(...)
        DisableQuestWatchMouseCapture()
    end
    elvQuestWatchHooked = true
end

local questWatchHooked = false
local function SetupQuestWatchGuard()
    if questWatchHooked then return end

    -- Blizzard QuestLog_OnEvent calls a file-local QuestWatch_Update; wrap the handler.
    local origEvent = _G.QuestLog_OnEvent
    if type(origEvent) == 'function' then
        _G.QuestLog_OnEvent = function(event, ...)
            if QuestieTrackerActive() then
                SafeQuestLogOnEvent(event, ...)
                return
            end
            local ok = pcall(origEvent, event, ...)
            if not ok then
                DisableQuestWatchMouseCapture()
            end
        end
    end

    local origUpdate = _G.QuestWatch_Update
    if type(origUpdate) == 'function' then
        _G.QuestWatch_Update = function(...)
            if QuestieTrackerActive() then
                DisableQuestWatchMouseCapture()
                return
            end
            pcall(origUpdate, ...)
            DisableQuestWatchMouseCapture()
        end
    end

    SuppressElvUIQuestWatchClicks()
    DisableQuestWatchMouseCapture()
    questWatchHooked = true
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

-- ElvUI global UI scale: force a fixed value on login. This is account-wide
-- (E.global.general.UIScale) and overrides ElvUI's auto-scale. Edit UI_SCALE to
-- taste: higher = bigger UI, lower = smaller/crisper (pixel-perfect on this 4K
-- rig is ~0.4). E:UIScale() self-defers if called in combat.
local UI_SCALE = 0.69
local function ApplyUIScale()
    local E = _G.ElvUI and _G.ElvUI[1]
    if not E or not E.global or not E.global.general then return end
    if E.global.general.autoScale == false and E.global.general.UIScale == UI_SCALE then
        return
    end
    E.global.general.autoScale = false
    E.global.general.UIScale = UI_SCALE
    if E.UIMult then pcall(E.UIMult, E) end
    if E.UIScale then pcall(E.UIScale, E) end
end

local questWatchGuardFrame = CreateFrame('Frame')
questWatchGuardFrame:RegisterEvent('QUEST_LOG_UPDATE')
questWatchGuardFrame:RegisterEvent('QUEST_WATCH_UPDATE')
questWatchGuardFrame:SetScript('OnEvent', function()
    if QuestieTrackerActive() then
        DisableQuestWatchMouseCapture()
    end
end)

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ADDON_LOADED')
f:SetScript('OnEvent', function(_, event, addon)
    if event == 'ADDON_LOADED' then
        if addon == 'Blizzard_UIParentPanelManager' or addon == 'Blizzard_ChatFrame'
            or addon == 'Blizzard_ChatFrameBase' then
            WrapShowUIPanel()
        end
        if addon == 'Blizzard_UIPanels_Game' or addon == 'Questie' then
            SetupQuestWatchGuard()
        end
        if addon == 'ElvUI' or addon == 'Blizzard_GlueXML' then
            SetupGameMenuFix()
            SetupGuildRankArrowFix()
            SetupQuestWatchGuard()
        end
        if addon == 'Blizzard_GuildControlUI' or addon == 'Blizzard_Communities' then
            SetupGuildRankArrowFix()
        end
        return
    end
    WrapShowUIPanel()
    SetupGameMenuFix()
    SetupGuildRankArrowFix()
    SetupQuestWatchGuard()
    DisableQuestWatchMouseCapture()
    ApplyUIScale()
    C_Timer.After(0.3, function()
        ApplyInitFix()
        ApplyUIScale()
        DisableQuestWatchMouseCapture()
        SnapToPanel()
        if not hooked and _G.ChatFrame1 then
            hooksecurefunc(_G.ChatFrame1, 'SetPoint', SnapToPanel)
            hooked = true
        end
    end)
end)

WrapShowUIPanel()
SetupGameMenuFix()
SetupGuildRankArrowFix()
SetupQuestWatchGuard()
