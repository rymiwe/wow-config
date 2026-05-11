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
--
-- Note: Zygor doesn't load until after PLAYER_LOGIN, so we wait for its
-- SavedVariable global to appear. If Zygor isn't installed, this is a no-op.

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
f:SetScript("OnEvent", function()
    -- Zygor's SV table may not be populated yet at PLAYER_LOGIN. Try
    -- immediately; if it fails, retry a few times with backoff.
    if ApplyConfig() then return end
    local attempts = 0
    local function retry()
        attempts = attempts + 1
        if ApplyConfig() then return end
        if attempts < 5 then
            C_Timer.After(1, retry)
        end
    end
    C_Timer.After(1, retry)
end)
