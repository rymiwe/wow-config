-- Root cause: ElvUI Chat:FindChatWindows guards on GeneralDockManager.primary
-- which is sometimes nil at PLAYER_LOGIN on Anniversary. ChatFrame1 then fails
-- the (chat.isDocked and chat == docker) check, FindChatWindows returns nil,
-- PositionChat skips the LeftChatPanel SetPoint branch, and chat sits wherever
-- Blizzard's FCF restore left it (up-and-right of LeftChatPanel).

local function ApplyFix()
    local dock = _G.GeneralDockManager
    if not dock or not _G.ChatFrame1 then return end
    if dock.primary ~= _G.ChatFrame1 then
        dock.primary = _G.ChatFrame1
    end
    local E = _G.ElvUI and _G.ElvUI[1]
    local CH = E and E:GetModule('Chat', true)
    if CH and CH.PositionChats then
        CH:PositionChats()
    end
end

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:SetScript('OnEvent', function()
    C_Timer.After(0.3, ApplyFix)
end)
