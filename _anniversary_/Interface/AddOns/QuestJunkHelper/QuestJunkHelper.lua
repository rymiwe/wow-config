-- QuestJunkHelper: flags quest leftovers safe to destroy when you open bags.
QuestJunkHelperDB = QuestJunkHelperDB or {}

local ADDON = "QuestJunkHelper"
local SCAN_DEBOUNCE = 0.35
-- Localized name of item classID 12 ("Quest"). Used as a generic fallback for
-- quest items that aren't in QuestJunkData's curated rules — those still print
-- as "safe" (vetted note); this catches everything else the client itself
-- tags as a quest item so bags aren't silently clean when they're not.
local QUEST_ITEM_TYPE = (GetItemClassInfo and GetItemClassInfo(12)) or "Quest"

if QuestJunkHelperDB.autoScan == nil then
    QuestJunkHelperDB.autoScan = true
end

local scanPending = false
local lastSignature = ""

local function Trim(s)
    return (s or ""):match("^%s*(.-)%s*$") or ""
end

local function ItemLinkID(link)
    if not link then return nil end
    return tonumber(link:match("item:(%d+)"))
end

local function IsQuestComplete(questId)
    if Questie and Questie.db and Questie.db.char and Questie.db.char.complete then
        return Questie.db.char.complete[questId] == true
    end
    return false
end

local function AllQuestsComplete(questIds)
    for _, questId in ipairs(questIds) do
        if not IsQuestComplete(questId) then
            return false
        end
    end
    return true
end

local function CollectActiveQuestKeepers()
    local byId = {}
    local byName = {}

    for i = 1, GetNumQuestLogEntries() do
        local title, _, _, isHeader, _, isComplete = GetQuestLogTitle(i)
        if title and not isHeader and not isComplete then
            SelectQuestLogEntry(i)

            local requiredLink = GetQuestLogItemLink("required", 1)
            local requiredId = ItemLinkID(requiredLink)
            if requiredId then
                byId[requiredId] = title
            end

            local numObjs = GetNumQuestLeaderBoards(i)
            for j = 1, numObjs do
                local text, objType, finished = GetQuestLogLeaderBoard(j, i)
                if objType == "item" and not finished and text then
                    local itemName = Trim(text:match("^([^:]+)"))
                    if itemName ~= "" then
                        byName[itemName:lower()] = title
                    end
                end
            end
        end
    end

    return byId, byName
end

local function IsAnyBagOpen()
    if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() then
        return true
    end
    for i = 1, 13 do
        local frame = _G["ContainerFrame" .. i]
        if frame and frame:IsShown() then
            return true
        end
    end
    return false
end

local function GetBagSlotCount(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag) or 0
    end
    return GetContainerNumSlots(bag) or 0
end

local function GetBagItemId(bag, slot)
    if C_Container and C_Container.GetContainerItemID then
        return C_Container.GetContainerItemID(bag, slot)
    end
    return GetContainerItemID(bag, slot)
end

local function GetBagItemCount(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        return info and info.stackCount
    end
    local _, count = GetContainerItemInfo(bag, slot)
    return count
end

local function ScanBagSlots()
    local found = {}
    for bag = 0, 4 do
        local slots = GetBagSlotCount(bag)
        for slot = 1, slots do
            local itemId = GetBagItemId(bag, slot)
            if itemId and not found[itemId] then
                found[itemId] = GetBagItemCount(bag, slot) or 1
            end
        end
    end
    return found
end

local function ClassifyItem(itemId, itemName, itemType, itemSellPrice, activeById, activeByName)
    if QuestJunkData.never[itemId] then
        return "keep", QuestJunkData.never[itemId]
    end

    if activeById[itemId] then
        return "active", "Active quest: " .. activeById[itemId]
    end

    if itemName and activeByName[itemName:lower()] then
        return "active", "Active quest: " .. activeByName[itemName:lower()]
    end

    local optional = QuestJunkData.optional[itemId]
    if optional then
        return "optional", optional.note
    end

    -- Curated/Zygor-sourced quest leftovers are usually unsellable, but a few
    -- (e.g. Un'Goro Soil) do have vendor value. Anything with a sell price
    -- routes to "sellable" instead of "safe"/"likely" so /qj destroy never
    -- touches it — destroying a sellable item just throws away the gold.
    local hasSellValue = (itemSellPrice or 0) > 0

    local rule = QuestJunkData.rules[itemId]
    if rule then
        if AllQuestsComplete(rule.quests) then
            if hasSellValue then
                return "sellable", rule.note .. " — vendor-sellable, don't destroy"
            end
            return "safe", rule.note
        end
        return "keep", "Quest chain not complete"
    end

    local zygorNote = QuestJunkData.zygorTrash[itemId]
    if zygorNote then
        if hasSellValue then
            return "sellable", "Zygor guide cleanup item (" .. zygorNote .. ") — vendor-sellable, don't destroy"
        end
        return "safe", "Zygor guide cleanup item (" .. zygorNote .. ")"
    end

    -- Not in the curated list at all. If the client itself tags this as a
    -- Quest-type item and it isn't tied to anything in your active log,
    -- it's very likely a leftover — but unvetted, so it's a separate
    -- "likely" bucket rather than the confirmed "safe" one.
    if itemType == QUEST_ITEM_TYPE then
        if hasSellValue then
            return "sellable", "Quest item, not referenced by any active quest — vendor-sellable, don't destroy"
        end
        return "likely", "Quest item, not referenced by any active quest — not in the curated list, use judgement"
    end

    return nil
end

local function BuildReport()
    local activeById, activeByName = CollectActiveQuestKeepers()
    local bagItems = ScanBagSlots()

    local safe, likely, sellable, optional, active = {}, {}, {}, {}, {}
    for itemId, count in pairs(bagItems) do
        local itemName, _, _, _, _, itemType, _, _, _, _, itemSellPrice = GetItemInfo(itemId)
        local kind, reason = ClassifyItem(itemId, itemName, itemType, itemSellPrice, activeById, activeByName)
        local entry = {
            itemId = itemId,
            name = itemName or ("item:" .. itemId),
            count = count,
            reason = reason,
        }
        if kind == "safe" then
            safe[#safe + 1] = entry
        elseif kind == "likely" then
            likely[#likely + 1] = entry
        elseif kind == "sellable" then
            sellable[#sellable + 1] = entry
        elseif kind == "optional" then
            optional[#optional + 1] = entry
        elseif kind == "active" then
            active[#active + 1] = entry
        end
    end

    table.sort(safe, function(a, b) return a.name < b.name end)
    table.sort(likely, function(a, b) return a.name < b.name end)
    table.sort(sellable, function(a, b) return a.name < b.name end)
    table.sort(optional, function(a, b) return a.name < b.name end)
    table.sort(active, function(a, b) return a.name < b.name end)

    local signature = ""
    for _, bucket in ipairs({ safe, likely, sellable, optional, active }) do
        for _, entry in ipairs(bucket) do
            signature = signature .. entry.itemId .. ":" .. entry.count .. ";"
        end
    end

    return safe, likely, sellable, optional, active, signature
end

-- Destroys every stack in bags matching an itemId in idSet. Mirrors Zygor's
-- own Inventory:DestroyItem (PickupContainerItem + DeleteCursorItem) — the
-- same mechanism its trash-button macro uses, just batched across all slots.
local function DestroyItemsMatching(idSet)
    local destroyedStacks = 0
    for bag = 0, 4 do
        local slots = GetBagSlotCount(bag)
        for slot = 1, slots do
            local itemId = GetBagItemId(bag, slot)
            if itemId and idSet[itemId] then
                if C_Container and C_Container.PickupContainerItem then
                    C_Container.PickupContainerItem(bag, slot)
                else
                    PickupContainerItem(bag, slot)
                end
                DeleteCursorItem()
                if not GetBagItemId(bag, slot) then
                    destroyedStacks = destroyedStacks + 1
                end
            end
        end
    end
    return destroyedStacks
end

-- Vetted matches only by default (curated rules + Zygor-sourced list).
-- includeLikely opts into the unvetted heuristic bucket too.
local function CollectDestroyTargets(includeLikely)
    local safe, likely, _, _, _ = BuildReport()
    local idSet, names = {}, {}
    for _, entry in ipairs(safe) do
        idSet[entry.itemId] = true
        names[#names + 1] = entry.name
    end
    if includeLikely then
        for _, entry in ipairs(likely) do
            idSet[entry.itemId] = true
            names[#names + 1] = entry.name
        end
    end
    return idSet, names
end

local function PrintBucket(label, color, entries)
    if #entries == 0 then return end
    print(string.format("%s%s|r (%d)", color, label, #entries))
    for _, entry in ipairs(entries) do
        local countText = entry.count > 1 and (" x" .. entry.count) or ""
        print(string.format("  |cffffffff%s%s|r - %s", entry.name, countText, entry.reason or ""))
    end
end

function QuestJunkHelper_PrintReport(force)
    local safe, likely, sellable, optional, active, signature = BuildReport()

    if not force and signature == lastSignature then
        return false
    end
    lastSignature = signature

    if #safe == 0 and #likely == 0 and #sellable == 0 and #optional == 0 and #active == 0 then
        if force then
            print("|cff66ccff" .. ADDON .. "|r nothing flagged in your bags.")
        end
        return false
    end

    print("|cff66ccff" .. ADDON .. "|r bag scan")
    PrintBucket("Safe to destroy", "|cff00ff00", safe)
    PrintBucket("Likely junk (unvetted)", "|cff33aaff", likely)
    PrintBucket("Vendor-sellable (sell, don't destroy)", "|cffff9933", sellable)
    PrintBucket("Optional (skipped content)", "|cffffd700", optional)
    PrintBucket("Keep (active quests)", "|cffff6666", active)
    return true
end

local function ScheduleScan(force)
    if scanPending then return end
    scanPending = true
    C_Timer.After(SCAN_DEBOUNCE, function()
        scanPending = false
        if not force and (not QuestJunkHelperDB.autoScan or not IsAnyBagOpen()) then
            return
        end
        QuestJunkHelper_PrintReport(force)
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("BAG_UPDATE")
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        lastSignature = ""
        return
    end
    if event == "BAG_UPDATE" and IsAnyBagOpen() then
        ScheduleScan(false)
    end
end)

SLASH_QUESTJUNK1 = "/questjunk"
SLASH_QUESTJUNK2 = "/qj"
SlashCmdList["QUESTJUNK"] = function(msg)
    msg = Trim((msg or ""):lower())

    if msg == "" or msg == "scan" then
        ScheduleScan(true)
        return
    end

    if msg == "auto on" or msg == "on" then
        QuestJunkHelperDB.autoScan = true
        print("|cff66ccff" .. ADDON .. "|r auto-scan on (opens with bags)")
        return
    end

    if msg == "auto off" or msg == "off" then
        QuestJunkHelperDB.autoScan = false
        print("|cff66ccff" .. ADDON .. "|r auto-scan off")
        return
    end

    if msg:match("^destroy") then
        if InCombatLockdown() then
            print("|cff66ccff" .. ADDON .. "|r can't destroy items in combat.")
            return
        end

        local rest = msg:gsub("^destroy%s*", "")
        local includeLikely = rest:find("likely") ~= nil
        local confirmed = rest:find("confirm") ~= nil

        local idSet, names = CollectDestroyTargets(includeLikely)
        if #names == 0 then
            print("|cff66ccff" .. ADDON .. "|r nothing to destroy" .. (includeLikely and "" or " in the safe bucket") .. ".")
            return
        end

        if not confirmed then
            print(string.format("|cff66ccff%s|r would destroy %d item(s)%s:", ADDON, #names,
                includeLikely and " (including unvetted 'likely' matches)" or ""))
            print("  " .. table.concat(names, ", "))
            print(string.format("|cff999999  Type /qj destroy%s confirm to proceed. (Gray vendor trash isn't tracked here at all — ElvUI auto-sells that.)|r",
                includeLikely and " likely" or ""))
            return
        end

        local destroyedStacks = DestroyItemsMatching(idSet)
        print(string.format("|cff66ccff%s|r destroyed %d stack(s): %s", ADDON, destroyedStacks, table.concat(names, ", ")))
        lastSignature = ""
        return
    end

    print("|cff66ccff" .. ADDON .. "|r commands:")
    print("  /qj                  scan now")
    print("  /qj auto on          scan when bags open (default)")
    print("  /qj auto off         manual scans only")
    print("  /qj destroy          preview safe-bucket items to destroy")
    print("  /qj destroy confirm  actually destroy them")
    print("  /qj destroy likely [confirm]  same, but also include the unvetted 'likely' bucket")
end