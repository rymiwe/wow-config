-- WeakAurasSetup: Ensures key WeakAuras are present automatically.
-- Follows the same pattern as TSMSetup, ZygorSetup, etc.

local AURAS = {}

-- Currently no auras are being auto-managed.
-- The framework is kept in case we want to automatically inject
-- other WeakAuras in the future (e.g. for other classes or utilities).

local function EnsureWeakAuras()
    if not WeakAuras or not WeakAurasSaved then
        return false
    end

    WeakAurasSaved.displays = WeakAurasSaved.displays or {}

    local addedThisSession = false

    for id, auraData in pairs(AURAS) do
        if not WeakAurasSaved.displays[id] then
            WeakAurasSaved.displays[id] = auraData
            if not addedThisSession then
                print("|cff00ff00WeakAurasSetup|r: Added \"" .. id .. "\"")
                addedThisSession = true
            end
        end
    end

    return true
end

-- Retry logic in case WeakAuras loads after us
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if EnsureWeakAuras() then return end

    local attempts = 0
    local function retry()
        attempts = attempts + 1
        if EnsureWeakAuras() then return end
        if attempts < 8 then
            C_Timer.After(2, retry)
        end
    end
    C_Timer.After(3, retry)
end)