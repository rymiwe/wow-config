-- TSMSetup: Applies improved global defaults for TradeSkillMaster on every login.
-- Conservative Classic/TBC pricing aligned across crafting, disenchant, and sniper:
--   - Material / destroy / shopping pct: min(dbminbuyout, dbmarket)
--   - Expected sale price: 0.8 * dbmarket
--   - Custom minprice (sniper): max(min(dbminbuyout, dbmarket), vendorsell)
--   - Auctioning min price floor: vendorsell/0.95+1c
-- Disenchant helper custom source:
--   - deprofit_est = destroy - dbminbuyout (profit vs realm cheapest buyout; item-level)

local DESIRED_MAT_PRICE = "min(dbminbuyout, dbmarket)"
local DESIRED_CRAFT_PRICE = "0.8 * dbmarket"
local DESIRED_MINPRICE = "max(min(dbminbuyout, dbmarket), vendorsell)"
local VENDOR_MIN_FLOOR = "vendorsell/0.95+1c"

local CUSTOM_SOURCES = {
    minprice = DESIRED_MINPRICE,
    deprofit_est = "ifgt(dbminbuyout, 0, max(destroy - dbminbuyout, 0c))",
}

local CUSTOM_SOURCE_FORMATS = {
    minprice = "gold",
    deprofit_est = "gold",
}

local DEPROFIT_COLUMN_ID = "_customSource_deprofit_est"
local SHOPPING_TABLE_KEY = "g@ @auctionUIContext@shoppingAuctionScrollingTable"

local CORE_KEYS = {
    destroyValueSource = "g@ @coreOptions@destroyValueSource",
    pctSource = "g@ @shoppingOptions@pctSource",
    matCost = "g@ @craftingOptions@defaultMatCostMethod",
    craftPrice = "g@ @craftingOptions@defaultCraftPriceMethod",
}

local AUCTIONING_MIN_PRICES = {
    ["#Default"] = "check(first(crafting,dbmarket,dbregionmarketavg),max(0.25*avg(crafting,dbmarket,dbregionmarketavg),max(1.5*vendorsell," .. VENDOR_MIN_FLOOR .. ")))",
    ["Sell Gear"] = "max(45% min(DBMarket, DBRegionMarketAvg), " .. VENDOR_MIN_FLOOR .. ")",
    ["Sell Non-Stackable"] = "max(45% min(DBMarket, DBRegionMarketAvg), " .. VENDOR_MIN_FLOOR .. ")",
    ["Sell Stackable (1)"] = "max(min(45% DBMarket, DBRegionMarketAvg), " .. VENDOR_MIN_FLOOR .. ")",
    ["Sell Stackable (5)"] = "max(min(45% DBMarket, DBRegionMarketAvg), " .. VENDOR_MIN_FLOOR .. ")",
    ["Sell Stackable (10)"] = "max(min(45% DBMarket, DBRegionMarketAvg), " .. VENDOR_MIN_FLOOR .. ")",
    ["Sell Stackable (20)"] = "max(min(45% DBMarket, DBRegionMarketAvg), " .. VENDOR_MIN_FLOOR .. ")",
}

local function GetTSMDB()
    return _G.TradeSkillMasterDB
end

local function GetProfileName(db)
    if db._currentProfile then
        local charKey = UnitName("player") .. " - " .. GetRealmName()
        local profile = db._currentProfile[charKey]
        if profile and profile ~= "" then
            return profile
        end
    end
    return "Default"
end

local function GetOperationsRoot(db)
    if db["g@ @coreOptions@globalOperations"] then
        return db["g@ @userData@sharedOperations"]
    end
    local profile = GetProfileName(db)
    return db["p@" .. profile .. "@userData@operations"]
end

local function RecordBackup(setting, oldValue)
    TSMSetupDB = TSMSetupDB or {}
    TSMSetupDB.backups = TSMSetupDB.backups or {}
    table.insert(TSMSetupDB.backups, {
        time = date("%Y-%m-%d %H:%M:%S"),
        setting = setting,
        oldValue = oldValue or "nil",
    })
    while #TSMSetupDB.backups > 15 do
        table.remove(TSMSetupDB.backups, 1)
    end
end

local function SetStringSetting(db, key, desired, label)
    if db[key] == desired then
        return false
    end
    RecordBackup(label or key, db[key])
    db[key] = desired
    return true
end

local function HasVendorFloor(minPrice)
    if not minPrice or minPrice == "" then
        return false
    end
    if minPrice:find("vendorsell%s*/%s*0%.95", 1, false) then
        return true
    end
    if minPrice:find("1%.5%s*%(vendorsell|VendorSell)", 1, false) then
        return true
    end
    if minPrice:find("max%(.-1%.5%s*%(vendorsell|VendorSell)", 1, false) then
        return true
    end
    return false
end

local function DesiredAuctioningMinPrice(operationName, currentMinPrice)
    if AUCTIONING_MIN_PRICES[operationName] then
        return AUCTIONING_MIN_PRICES[operationName]
    end
    if HasVendorFloor(currentMinPrice) then
        return nil
    end
    if not currentMinPrice or currentMinPrice == "" then
        return VENDOR_MIN_FLOOR
    end
    return string.format("max(%s, %s)", currentMinPrice, VENDOR_MIN_FLOOR)
end

local function ApplyAuctioningMinPrices(db)
    local operations = GetOperationsRoot(db)
    local auctioning = operations and operations.Auctioning
    if not auctioning then
        return false
    end

    local changed = false
    for operationName, settings in pairs(auctioning) do
        if type(settings) == "table" and settings.minPrice then
            local desired = DesiredAuctioningMinPrice(operationName, settings.minPrice)
            if desired and settings.minPrice ~= desired then
                RecordBackup("Auctioning." .. operationName .. ".minPrice", settings.minPrice)
                settings.minPrice = desired
                changed = true
            end
        end
    end
    return changed
end

local function ApplyCraftingDefaults(db)
    local matChanged = SetStringSetting(db, CORE_KEYS.matCost, DESIRED_MAT_PRICE, "crafting.defaultMatCostMethod")
    local priceChanged = SetStringSetting(db, CORE_KEYS.craftPrice, DESIRED_CRAFT_PRICE, "crafting.defaultCraftPriceMethod")
    return matChanged, priceChanged
end

local function ApplyPricingSources(db)
    local destroyChanged = SetStringSetting(db, CORE_KEYS.destroyValueSource, DESIRED_MAT_PRICE, "core.destroyValueSource")
    local pctChanged = SetStringSetting(db, CORE_KEYS.pctSource, DESIRED_MAT_PRICE, "shopping.pctSource")
    return destroyChanged, pctChanged
end

local function ApplyCustomPriceSources(db)
    local sourcesKey = "g@ @userData@customPriceSources"
    local formatsKey = "g@ @userData@customPriceSourceFormat"
    local sources = db[sourcesKey]
    if type(sources) ~= "table" then
        sources = {}
        db[sourcesKey] = sources
    end
    local formats = db[formatsKey]
    if type(formats) ~= "table" then
        formats = {}
        db[formatsKey] = formats
    end

    local changed = false
    for name, desired in pairs(CUSTOM_SOURCES) do
        if sources[name] ~= desired then
            RecordBackup("customPriceSources." .. name, sources[name])
            sources[name] = desired
            changed = true
        end
        local desiredFormat = CUSTOM_SOURCE_FORMATS[name] or "gold"
        if formats[name] ~= desiredFormat then
            RecordBackup("customPriceSourceFormat." .. name, formats[name])
            formats[name] = desiredFormat
            changed = true
        end
    end
    return changed
end

local function TableHasColumn(cols, columnId)
    for _, col in ipairs(cols) do
        if col.id == columnId then
            return true
        end
    end
    return false
end

local function ApplyShoppingDeProfitColumn(db)
    local tableSettings = db[SHOPPING_TABLE_KEY]
    if type(tableSettings) ~= "table" or type(tableSettings.cols) ~= "table" then
        return false
    end
    if TableHasColumn(tableSettings.cols, DEPROFIT_COLUMN_ID) then
        return false
    end

    RecordBackup("shoppingAuctionScrollingTable.cols", "added " .. DEPROFIT_COLUMN_ID)
    table.insert(tableSettings.cols, { id = DEPROFIT_COLUMN_ID, width = 95 })
    return true
end

local function ApplyDefaults()
    local db = GetTSMDB()
    if not db then
        return false
    end

    local matChanged, priceChanged = ApplyCraftingDefaults(db)
    local destroyChanged, pctChanged = ApplyPricingSources(db)
    local customChanged = ApplyCustomPriceSources(db)
    local columnChanged = ApplyShoppingDeProfitColumn(db)
    local auctionChanged = ApplyAuctioningMinPrices(db)

    if matChanged then
        print("|cff00ff00TSMSetup|r: Set material cost method -> " .. DESIRED_MAT_PRICE)
    end
    if priceChanged then
        print("|cff00ff00TSMSetup|r: Set craft price method -> " .. DESIRED_CRAFT_PRICE)
    end
    if destroyChanged then
        print("|cff00ff00TSMSetup|r: Set destroy value source -> " .. DESIRED_MAT_PRICE)
    end
    if pctChanged then
        print("|cff00ff00TSMSetup|r: Set shopping pct source -> " .. DESIRED_MAT_PRICE)
    end
    if customChanged then
        print("|cff00ff00TSMSetup|r: Updated custom sources (minprice, deprofit_est).")
    end
    if columnChanged then
        print("|cff00ff00TSMSetup|r: Added |cffffd200deprofit_est|r column to Shopping (destroy - dbminbuyout).")
    end
    if auctionChanged then
        print("|cff00ff00TSMSetup|r: Added vendor-sell floor to Auctioning min prices (" .. VENDOR_MIN_FLOOR .. ").")
    end

    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if ApplyDefaults() then
        return
    end

    local attempts = 0
    local function retry()
        attempts = attempts + 1
        if ApplyDefaults() then
            return
        end
        if attempts < 12 then
            C_Timer.After(1.5, retry)
        else
            print("|cffffaa00TSMSetup|r: Could not apply settings (TSM may not be loaded).")
        end
    end
    C_Timer.After(3, retry)
end)

SLASH_TSMSETUP1 = "/tsmsetup"
SlashCmdList["TSMSETUP"] = function()
    if ApplyDefaults() then
        print("|cff00ff00TSMSetup|r: Settings checked/applied. /reload if TSM still shows old prices.")
    else
        print("|cffffaa00TSMSetup|r: TradeSkillMasterDB not available.")
    end
end