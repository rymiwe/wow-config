-- ChatPanelThemes: paints LeftChatPanel.backdrop with a subtle class-themed
-- texture. Designed for readability - the texture is low-contrast so chat text
-- always wins. Druid is the only one shipped initially; others land as we
-- generate them via scripts/gen-class-textures.py.

local TEXTURE_PATH = "Interface\\AddOns\\ChatPanelThemes\\Media\\"

-- Class -> texture filename (without extension). Add entries as we generate.
local CLASS_TEXTURE = {
    DRUID = "druid",
}

-- Backdrop alpha when a theme is applied. Lower = more texture visible, higher
-- = more solid panel. 0.6 keeps the dark base obvious while letting the leaf
-- pattern peek through.
local BACKDROP_ALPHA = 0.6

local function ApplyTheme()
    local _, class = UnitClass("player")
    local name = CLASS_TEXTURE[class]
    if not name then return end

    local panel = _G.LeftChatPanel
    local bd = panel and panel.backdrop
    if not bd then return end

    local backdrop = bd:GetBackdrop()
    if not backdrop then return end

    backdrop.bgFile = TEXTURE_PATH .. name .. ".tga"
    bd:SetBackdrop(backdrop)

    -- ElvUI's Panel_ColorUpdate sets backdropColor from db.panelColor; we keep
    -- the color but lower its alpha so our texture shows through.
    local E = _G.ElvUI and _G.ElvUI[1]
    local pc = E and E.db and E.db.chat and E.db.chat.panelColor
    if pc then
        bd:SetBackdropColor(pc.r or 0.06, pc.g or 0.06, pc.b or 0.06, BACKDROP_ALPHA)
    else
        bd:SetBackdropColor(0.06, 0.06, 0.06, BACKDROP_ALPHA)
    end
end

-- Re-apply after any ElvUI panel color update (would otherwise restore alpha=1
-- and hide our texture).
local function HookElvUI()
    local E = _G.ElvUI and _G.ElvUI[1]
    local CH = E and E:GetModule('Chat', true)
    if not CH or CH._chatPanelThemesHooked then return end
    if CH.Panels_ColorUpdate then
        hooksecurefunc(CH, 'Panels_ColorUpdate', ApplyTheme)
    end
    if CH.Panel_ColorUpdate then
        hooksecurefunc(CH, 'Panel_ColorUpdate', ApplyTheme)
    end
    CH._chatPanelThemesHooked = true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    -- 0.5s delay - after ChatAnchor (0.3s) and after ElvUI is fully loaded.
    C_Timer.After(0.5, function()
        HookElvUI()
        ApplyTheme()
    end)
end)
