local applying = false
local function ApplyAnchor()
    if applying or not LeftChatPanel or not ChatFrame1 then return end
    applying = true
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", 4, 4)
    ChatFrame1:SetPoint("TOPRIGHT", LeftChatPanel, "TOPRIGHT", -4, -28)
    applying = false
end

local hooked = false
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    C_Timer.After(0.5, function()
        ApplyAnchor()
        if not hooked then
            hooksecurefunc(ChatFrame1, "SetPoint", ApplyAnchor)
            hooked = true
        end
    end)
end)
