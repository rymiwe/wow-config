-- ElvUI on Anniversary fails to anchor ChatFrame1 to LeftChatPanel reliably.
-- See ElvUI/Game/Shared/Modules/Chat/Chat.lua CH:FindChatWindows + CH:PositionChat.
-- Two-layer fix:
--   1. On login, force GeneralDockManager.primary=ChatFrame1 then call ElvUI's
--      PositionChats so size/edit-box/tab plumbing runs through ElvUI.
--   2. Hook ChatFrame1:SetPoint to re-snap to LeftChatPanel if anything
--      (Blizzard FCF restore, ElvUI internal events) repositions it later.
-- Also: consolidate all chat frames into ChatFrame1's dock and hide the right
-- chat panel - one panel, all tabs, less screen clutter.

local function GetCH()
    local E = _G.ElvUI and _G.ElvUI[1]
    return E and E:GetModule('Chat', true)
end

local function ConsolidateChats()
    -- Dock every chat frame into ChatFrame1's dock so they all show as tabs in
    -- the left panel. Frames that are deliberately undocked (rare for default
    -- users) get re-docked - revert via right-click-tab -> Undock if wanted.
    for _, frameName in ipairs(_G.CHAT_FRAMES or {}) do
        local chat = _G[frameName]
        if chat and chat ~= _G.ChatFrame1 then
            if chat.isDocked then
                local _, relativeTo = chat:GetPoint()
                if relativeTo ~= _G.GeneralDockManager then
                    FCF_DockFrame(chat)
                end
            else
                FCF_DockFrame(chat)
            end
        end
    end
    -- Hide the right chat panel completely. Alpha 0 + no mouse means ElvUI's
    -- internal show/hide logic still runs (no errors) but it's invisible and
    -- non-interactive. Revert via /ec -> Chat -> Panels -> Right Chat Panel.
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
    local dock = _G.GeneralDockManager
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
local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:SetScript('OnEvent', function()
    C_Timer.After(0.3, function()
        ApplyInitFix()
        SnapToPanel()
        if not hooked then
            hooksecurefunc(_G.ChatFrame1, 'SetPoint', SnapToPanel)
            hooked = true
        end
    end)
end)
