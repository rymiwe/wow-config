-- ChatPanelThemes: stack a class-themed texture on top of LeftChatPanel.
-- Uses an overlay texture (frame:CreateTexture) instead of mucking with
-- ElvUI's backdrop, which can silently no-op depending on how ElvUI created
-- the backdrop frame. Texture sits on the panel's BACKGROUND layer above
-- ElvUI's backdrop but below ChatFrame1's children (which render on top via
-- normal parent/child stacking), so chat text always wins.

local TEXTURE_PATH = "Interface\\AddOns\\ChatPanelThemes\\Media\\"

local CLASS_TEXTURE = {
    DRUID = "druid",
}

-- 0 = invisible, 1 = fully opaque on top of ElvUI's backdrop.
local OVERLAY_ALPHA = 0.85

local function ApplyTheme()
    local _, class = UnitClass("player")
    local name = CLASS_TEXTURE[class]
    if not name then return end

    local panel = _G.LeftChatPanel
    if not panel then return end

    local tex = panel._chatPanelTheme
    if not tex then
        tex = panel:CreateTexture(nil, "BACKGROUND", nil, 1)
        tex:SetAllPoints(panel)
        panel._chatPanelTheme = tex
    end
    tex:SetTexture(TEXTURE_PATH .. name .. ".tga")
    tex:SetAlpha(OVERLAY_ALPHA)
    tex:Show()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    C_Timer.After(0.6, ApplyTheme)
end)

-- Slash command to test/reapply manually.
SLASH_CHATPANELTHEME1 = "/chatpaneltheme"
SlashCmdList.CHATPANELTHEME = function()
    ApplyTheme()
    local _, class = UnitClass("player")
    print("|cff66ff66ChatPanelThemes:|r class="..tostring(class)..", texture="..tostring(CLASS_TEXTURE[class] or "<none mapped>"))
end
