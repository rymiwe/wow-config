-- GuildMotdCycler: daily elemental GMOTD for officers.
-- Format: Today's element: Fire. Today's mood: Magma Totem. (Ragnaros is restless.)
GuildMotdCyclerDB = GuildMotdCyclerDB or {}

local ADDON = "GuildMotdCycler"
local MAX_LEN = 255

local function Calendar()
    local t = date("*t")
    if type(t) == "table" then
        return t
    end
    return nil
end

local function TodayKey()
    local t = Calendar()
    if t then
        return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
    end
    return date("%Y-%m-%d")
end

local function DayOfYear()
    local t = Calendar()
    if t and t.yday then
        return t.yday
    end
    return tonumber(date("%j")) or 1
end

local function PickElement()
    local n = #GuildMotdData.ELEMENTS
    if n == 0 then return nil end
    local idx = ((DayOfYear() - 1) % n) + 1
    return GuildMotdData.ELEMENTS[idx], idx
end

local function ResetSaltForToday()
    local today = TodayKey()
    if GuildMotdCyclerDB.saltDate ~= today then
        GuildMotdCyclerDB.lastSalt = 0
        GuildMotdCyclerDB.saltDate = today
    end
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

local function ElementKeyFromMessage(msg)
    if not msg or msg == "" then return nil end
    return msg:match("Today's element: ([%w']+)")
end

local function CurrentGuildMotd()
    if type(GetGuildRosterMOTD) == "function" then
        return GetGuildRosterMOTD() or ""
    end
    return ""
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

local function NeedsDailyUpdate(force)
    if force then return true end

    local today = TodayKey()
    local element = PickElement()
    if not element then return false end

    ResetSaltForToday()

    if GuildMotdCyclerDB.lastMotdDate ~= today then
        return true
    end

    local savedElement = ElementKeyFromMessage(GuildMotdCyclerDB.lastMotdText)
    if savedElement ~= element.key then
        return true
    end

    local guildElement = ElementKeyFromMessage(CurrentGuildMotd())
    if guildElement and guildElement ~= element.key then
        return true
    end

    local msg = BuildMessage(0)
    if msg and GuildMotdCyclerDB.lastMotdText ~= msg then
        return true
    end

    return false
end

local function MaybeSetDaily(force)
    if not CanSetMotd() then return false end
    if not NeedsDailyUpdate(force) then return false end
    local msg = BuildMessage(0)
    if not msg then return false end
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
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(3, TryDaily)
        if not rosterHooked then
            self:RegisterEvent("GUILD_ROSTER_UPDATE")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, TryDaily)
    elseif event == "GUILD_ROSTER_UPDATE" then
        TryDaily()
        if rosterHooked then
            self:UnregisterEvent("GUILD_ROSTER_UPDATE")
        end
    end
end)

local function PrintPreview()
    local element, idx = PickElement()
    if not element then
        print("|cff66ccff" .. ADDON .. "|r (no data)")
        return
    end
    local guildElement = ElementKeyFromMessage(CurrentGuildMotd())
    print(string.format(
        "|cff66ccff%s|r [%s doy=%d %d/%d] %s",
        ADDON,
        TodayKey(),
        DayOfYear(),
        idx,
        #GuildMotdData.ELEMENTS,
        BuildMessage(0) or "(no data)"
    ))
    if guildElement and guildElement ~= element.key then
        print(string.format(
            "|cffffcc00%s|r guild MOTD still shows %s (today is %s) — /gmc sync",
            ADDON,
            guildElement,
            element.key
        ))
    end
end

local function PrintSchedule()
    local n = #GuildMotdData.ELEMENTS
    local doy = DayOfYear()
    print("|cff66ccff" .. ADDON .. "|r next elements:")
    for offset = 0, 6 do
        local idx = ((doy + offset - 1) % n) + 1
        local el = GuildMotdData.ELEMENTS[idx]
        local label = offset == 0 and "today" or ("+%d"):format(offset)
        print(string.format("  %s: %s", label, el.key))
    end
end

SLASH_GUILDMOTD1 = "/gmc"
SLASH_GUILDMOTD2 = "/guildmotd"
SlashCmdList["GUILDMOTD"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(%S*)") or ""
    if msg == "" or msg == "preview" or msg == "today" then
        PrintPreview()
        return
    end
    if msg == "schedule" or msg == "debug" then
        PrintSchedule()
        PrintPreview()
        return
    end
    if msg == "next" then
        if not CanSetMotd() then
            print("|cffff0000" .. ADDON .. "|r you need guild MOTD edit permission")
            return
        end
        ResetSaltForToday()
        local salt = (GuildMotdCyclerDB.lastSalt or 0) + 1
        GuildMotdCyclerDB.lastSalt = salt
        local text = BuildMessage(salt)
        ApplyMotd(text, "next")
        print("|cff999999  (/gmc next rotates mood only; element changes daily)|r")
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
    print("|cff66ccff" .. ADDON .. "|r commands: /gmc preview | /gmc schedule | /gmc sync | /gmc next")
end