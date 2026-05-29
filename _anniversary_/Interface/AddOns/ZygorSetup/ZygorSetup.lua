-- ZygorSetup: applies the opinionated Zygor Guides Viewer config to each
-- character on PLAYER_LOGIN. Source-of-truth values were extracted from
-- user's working setup on Ocisly. Idempotent - safe to fire every login;
-- Zygor saves the config back to SavedVariables on logout.
--
-- Settings applied:
--   * Viewer LOCKED (windowlocked)
--   * Transparency ON (opacitytoggle), minimum opacity 0.5
--   * Grow upwards (resizeup) - viewer expands above its anchor
--   * Frame size: fontsize 7 / fontsecsize 6.3 (one tier below Zygor default)
--   * Auto-select quest rewards (autoselectitem)
--   * Auto-equip suggested gear upgrades (autogearauto)
--   * Frame anchored above the minimap area (BOTTOMRIGHT screen anchor with
--     user's offsets - re-position via /zygor menu if your screen differs)
--   * Arrow: smallest scale (arrowscale=0.625), text with OUTLINE, arrow locked
--     and reset to centered screen position (text size left at Zygor default)
--
-- Note: Zygor doesn't load until after PLAYER_LOGIN, so we wait for its
-- SavedVariable global to appear. If Zygor isn't installed, this is a no-op.
--
-- SIS fix: QuestDB:FindStartingPoint (Zygor 8.1) calls condition_suggested_race()
-- on past guides without checking for nil. Some Anniversary guide chains only
-- define condition_suggested_exclusive. We wrap FindStartingPoint and backfill
-- a permissive race check before Zygor walks the guide chain.

local ZYGOR_ADDON_NAMES = {
    "ZygorGuidesViewerClassicTBCAnniv",
    "ZygorGuidesViewerClassic",
}

local function EnsureGuideRaceConditions()
    if not ZGV or not ZGV.registeredguides then return end
    for _, guide in pairs(ZGV.registeredguides) do
        if not guide.condition_suggested_race then
            guide.condition_suggested_race = function() return true end
        end
    end
end

local function PatchZygorSISRaceGuard()
    if not ZGV or not ZGV.QuestDB then return false end
    if ZGV.QuestDB._ZygorSetupSISPatched then return true end
    local orig = ZGV.QuestDB.FindStartingPoint
    if type(orig) ~= "function" then return false end

    ZGV.QuestDB.FindStartingPoint = function(self, ...)
        EnsureGuideRaceConditions()
        return orig(self, ...)
    end
    ZGV.QuestDB._ZygorSetupSISPatched = true
    return true
end

local function TryPatchZygor()
    EnsureGuideRaceConditions()
    return PatchZygorSISRaceGuard()
end

local PRESET = {
    windowlocked    = true,
    opacitytoggle   = true,
    opacity         = 0.5,
    resizeup        = true,
    fontsize        = 7,
    fontsecsize     = 6.3,
    autoselectitem  = true,
    autogearauto    = true,
    frame_anchor    = {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", -282.22, 278.01},
    -- Action bar (the strip of clickable quest items + targeting buttons):
    -- Zygor's snap=true is BROKEN for the resizeup viewer case (verified by
    -- reading Functions.lua + ActionBar.lua source):
    --   - SetFrameAnchor ignores the relativeTo field, always uses UIParent
    --   - SavePosition with snap=true pins action bar to UIParent at the
    --     CURRENT viewer top position; doesn't follow viewer on growth
    --   - When viewer grows up, viewer's top extends above action bar's
    --     stale saved position -> overlap
    -- So: snap=false + fixed screen position high enough to never overlap.
    -- Y=700 sits well above viewer's max growth on a default UIScale.
    -- User can drag via Zygor Frame Manager for fine-tuning; revert by /rl.
    actionbar_anchor_snapped = false,
    actionbar_anchor = {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", -282.22, 700},

    -- Arrow settings
    arrowscale = 0.625,     -- smallest arrow size
    arrowoutline = true,    -- outline on arrow text
    arrow_locked = true,    -- lock arrow position (text size left at default)
    arrowanchor = {"CENTER", nil, "CENTER", 0, 150},  -- reset to centered position
}

local function ApplyConfig()
    local sv = _G.ZygorGuidesViewerClassicSettings
    if not sv or type(sv) ~= "table" then
        return false  -- Zygor not loaded yet
    end
    sv.char = sv.char or {}

    -- Zygor uses inconsistent char-key formats across versions:
    -- some entries are "Name - Realm", some just "Name". Write to BOTH so the
    -- preset lands regardless of which variant Zygor uses for this character.
    local name = UnitName("player")
    local realm = GetRealmName()
    local keys = { name }
    if realm and realm ~= "" then
        table.insert(keys, name .. " - " .. realm)
    end

    for _, key in ipairs(keys) do
        sv.char[key] = sv.char[key] or {}
        for k, v in pairs(PRESET) do
            sv.char[key][k] = v
        end
    end
    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" then
        for _, name in ipairs(ZYGOR_ADDON_NAMES) do
            if addon == name then
                TryPatchZygor()
                return
            end
        end
        return
    end

    -- Zygor's SV table may not be populated yet at PLAYER_LOGIN. Try
    -- immediately; if it fails, retry a few times with backoff.
    TryPatchZygor()
    if ApplyConfig() then return end
    local attempts = 0
    local function retry()
        attempts = attempts + 1
        TryPatchZygor()
        if ApplyConfig() then return end
        if attempts < 5 then
            C_Timer.After(1, retry)
        end
    end
    C_Timer.After(1, retry)
end)
