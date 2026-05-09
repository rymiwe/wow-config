-- ElvUI on Anniversary fails to anchor ChatFrame1 to LeftChatPanel reliably.
-- See ElvUI/Game/Shared/Modules/Chat/Chat.lua CH:FindChatWindows + CH:PositionChat.
-- Two-layer fix:
--   1. On login, force GeneralDockManager.primary=ChatFrame1 then call ElvUI's
--      PositionChats so size/edit-box/tab plumbing runs through ElvUI.
--   2. Hook ChatFrame1:SetPoint to re-snap to LeftChatPanel if anything
--      (Blizzard FCF restore, ElvUI internal events) repositions it later.

local function GetCH()
    local E = _G.ElvUI and _G.ElvUI[1]
    return E and E:GetModule('Chat', true)
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
