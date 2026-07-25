-- ZygorSetup (Classic Era / SoD): applies an opinionated Zygor guide-window
-- config on every login. Idempotent - safe to fire each login; Zygor persists
-- its profile back to SavedVariables on logout.
--
-- IMPORTANT: this Era Zygor build (ZygorGuidesViewerClassic) stores window
-- settings in its AceDB *profile* (ZGV.db.profile.<key>), NOT in the per-char
-- SavedVariables table. So we set ZGV.db.profile directly and call Zygor's own
-- apply helpers. (The _anniversary_ ZygorSetup pokes sv.char[...] instead; do
-- not copy that approach here.)
--
-- Settings applied:
--   * Guide window LOCKED (windowlocked)
--   * Transparency ON (opacitytoggle), opacity 0.5
--   * Grow upwards (resizeup) - window expands above its bottom anchor
--   * Anchored to the lower-right of the screen (frame_anchor). Since the window
--     is locked, tweak GUIDE_ANCHOR below to reposition (then /reload).
--   * Auto-select quest rewards (autoselectitem; questitemselector on)
--   * Auto-equip suggested gear upgrades (autogearauto; autogear/nc_gear on)
--
-- Plus one WoW CVar (not a Zygor setting):
--   * Auto-loot always on (autoLootDefault)

-- Lower-right screen anchor. {point, relativeTo(nil=UIParent), relativePoint, x, y}.
-- x is offset in from the right edge; y is offset up from the bottom (the window
-- grows upward from here). Nudge these if the placement needs adjusting.
local GUIDE_ANCHOR = {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", -282.22, 120}

-- Action bar (the row of clickable quest-item / targeting buttons). We must NOT
-- leave it "snapped": Zygor's snap pins the bar to UIParent at the viewer's top
-- AT THAT INSTANT (ActionBar.lua SavePosition), so when the viewer grows upward
-- (resizeup) its top rises above the stale bar and the viewer frame covers the
-- buttons -> clicks do nothing. So snapped=false + a fixed screen position just
-- BELOW the guide's bottom anchor, where the upward-growing viewer never reaches.
local ACTIONBAR_ANCHOR = {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", -282.22, 40}

-- Zygor profile settings (ZGV.db.profile.<key>).
local PRESET = {
    windowlocked      = true,
    opacitytoggle     = true,
    opacity           = 0.5,
    resizeup          = true,
    frame_anchor      = GUIDE_ANCHOR,

    -- Action bar: fixed (unsnapped) so it can't be overlapped by the grown viewer.
    actionbar_anchor_snapped = false,
    actionbar_anchor         = ACTIONBAR_ANCHOR,

    -- Auto-select quest rewards. autoselectitem is gated behind questitemselector
    -- (default true) both in the options UI and at runtime, so assert both.
    questitemselector = true,
    autoselectitem    = true,

    -- Auto-equip gear upgrades. autogearauto is gated behind the gear advisor
    -- (autogear) and upgrade checking (nc_gear), both default true; assert them
    -- so auto-equip works even if a profile had them toggled off.
    autogear          = true,
    nc_gear           = true,
    autogearauto      = true,
}

-- WoW console variables (not Zygor settings).
local CVARS = {
    autoLootDefault = "1",   -- auto-loot always on
}

local function ApplyCVars()
    for cvar, value in pairs(CVARS) do
        if GetCVar(cvar) ~= value then
            pcall(SetCVar, cvar, value)
        end
    end
end

local function ApplyZygor()
    if not ZGV or not ZGV.db or not ZGV.db.profile then
        return false  -- Zygor not fully loaded yet
    end
    local p = ZGV.db.profile
    for k, v in pairs(PRESET) do
        p[k] = v
    end

    -- Apply the window changes live (best effort). If any of these aren't ready
    -- yet, the settings still persist and take full effect on the next /reload.
    if ZGV.F and ZGV.F.SetFrameAnchor and ZGV.Frame and ZGV.Frame.GetParent then
        pcall(ZGV.F.SetFrameAnchor, ZGV.Frame:GetParent(), p.frame_anchor)
    end
    if ZGV.UpdateLocking then pcall(ZGV.UpdateLocking, ZGV) end
    if ZGV.UpdateFrame then pcall(ZGV.UpdateFrame, ZGV, true) end

    -- Unsnap + reposition the action bar live (else it applies on next /reload).
    if ZGV.ActionBar and ZGV.ActionBar.Frame and ZGV.F and ZGV.F.SetFrameAnchor then
        ZGV.ActionBar.Frame.snapped = false
        pcall(ZGV.F.SetFrameAnchor, ZGV.ActionBar.Frame, p.actionbar_anchor)
    end
    return true
end

local function Apply()
    ApplyCVars()          -- CVars need no addon; apply immediately
    return ApplyZygor()   -- returns false until Zygor's DB exists
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if Apply() then return end
    -- Zygor's DB may not exist yet at PLAYER_LOGIN; retry a few times.
    local attempts = 0
    local function retry()
        attempts = attempts + 1
        if ApplyZygor() then return end
        if attempts < 8 then
            C_Timer.After(1, retry)
        end
    end
    C_Timer.After(1, retry)
end)

-- Manual re-apply / testing.
SLASH_ZYGORSETUP1 = "/zygorsetup"
SlashCmdList["ZYGORSETUP"] = function()
    if Apply() then
        print("|cff00ff00ZygorSetup|r: applied guide-window preset + auto-loot.")
    else
        print("|cffff0000ZygorSetup|r: Zygor not loaded; nothing applied (CVars set).")
    end
end
