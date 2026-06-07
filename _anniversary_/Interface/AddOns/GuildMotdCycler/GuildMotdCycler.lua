-- GuildMotdCycler: daily elemental GMOTD for officers.
-- Format: Today's element: Fire. Today's mood: Magma Totem. (Ragnaros is restless.)
GuildMotdCyclerDB = GuildMotdCyclerDB or {}

local ADDON = "GuildMotdCycler"
local MAX_LEN = 255

local function TodayKey()
    return date("%Y-%m-%d")
end

local function DayOfYear()
    return tonumber(date("%j")) or 1
end

local function PickElement()
    local n = #GuildMotdData.ELEMENTS
    if n == 0 then return nil end
    local idx = ((DayOfYear() - 1) % n) + 1
    return GuildMotdData.ELEMENTS[idx], idx
end

local function PickMood(element, elementIndex, salt)
    salt = salt or 0
    local moods = element.moods
    if not moods or #moods == 0 then return "Elemental Mastery" end
    local idx = ((DayOfYear() + elementIndex + salt - 1) % #moods) + 1
    return moods[idx]
end

local function BuildMessage(salt)
    local element, elementIndex = PickElement()
    if not element then return nil end
    local mood = PickMood(element, elementIndex, salt)
    return string.format(
        "Today's element: %s. Today's mood: %s. (%s)",
        element.key,
        mood,
        element.lord
    )
end

local function CanSetMotd()
    if not IsInGuild() then return false end
    if type(CanEditMOTD) == "function" then
        return CanEditMOTD()
    end
    if type(CanEditGuildInfo) == "function" then
        return CanEditGuildInfo()
    end
    local _, _, rankIndex = GetGuildInfo("player")
    return rankIndex ~= nil and rankIndex <= 1
end

local function ApplyMotd(text, reason)
    if not text or text == "" then return false, "empty" end
    if #text > MAX_LEN then
        text = text:sub(1, MAX_LEN)
    end
    if type(GuildSetMOTD) ~= "function" then
        return false, "no_api"
    end
    GuildSetMOTD(text)
    GuildMotdCyclerDB.lastMotdDate = TodayKey()
    GuildMotdCyclerDB.lastMotdText = text
    print(string.format("|cff66ccff%s|r set GMOTD (%s)", ADDON, reason or "login"))
    print("|cff999999  " .. text .. "|r")
    return true
end

local function MaybeSetDaily(force)
    if not CanSetMotd() then return false end
    local today = TodayKey()
    if not force and GuildMotdCyclerDB.lastMotdDate == today then
        return false
    end
    local msg = BuildMessage(0)
    if not msg then return false end
    if not force and GuildMotdCyclerDB.lastMotdText == msg and GuildMotdCyclerDB.lastMotdDate == today then
        return false
    end
    return ApplyMotd(msg, force and "manual" or "daily")
end

local rosterHooked = false
local function TryDaily()
    if MaybeSetDaily(false) then
        rosterHooked = true
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(3, TryDaily)
        if not rosterHooked then
            self:RegisterEvent("GUILD_ROSTER_UPDATE")
        end
    elseif event == "GUILD_ROSTER_UPDATE" then
        TryDaily()
        if rosterHooked then
            self:UnregisterEvent("GUILD_ROSTER_UPDATE")
        end
    end
end)

SLASH_GUILDMOTD1 = "/gmc"
SLASH_GUILDMOTD2 = "/guildmotd"
SlashCmdList["GUILDMOTD"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(%S*)") or ""
    if msg == "" or msg == "preview" or msg == "today" then
        print("|cff66ccff" .. ADDON .. "|r " .. (BuildMessage(0) or "(no data)"))
        return
    end
    if msg == "next" then
        if not CanSetMotd() then
            print("|cffff0000" .. ADDON .. "|r you need guild MOTD edit permission")
            return
        end
        local salt = (GuildMotdCyclerDB.lastSalt or 0) + 1
        GuildMotdCyclerDB.lastSalt = salt
        local text = BuildMessage(salt)
        ApplyMotd(text, "next")
        return
    end
    if msg == "sync" or msg == "set" then
        if not CanSetMotd() then
            print("|cffff0000" .. ADDON .. "|r you need guild MOTD edit permission")
            return
        end
        MaybeSetDaily(true)
        return
    end
    print("|cff66ccff" .. ADDON .. "|r commands: /gmc preview | /gmc sync | /gmc next")
end