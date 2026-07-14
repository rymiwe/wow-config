-- HeyDaddy: Simple preferences panel for keybind layout feedback
-- Accessed via /heydaddy

local ADDON_NAME = "HeyDaddy"

local options = {
    { key = "altDiscomfort",     label = "I don't like using Alt or Command keys" },
    { key = "rightSideReach",    label = "I find the far-right keys (like 5, T, and B) hard to reach" },
    { key = "groupThematic",     label = "I want abilities that do similar things to feel logically grouped" },
    { key = "physicalProximity", label = "I want abilities that feel related to actually sit near each other on the bars" },
    { key = "bigCooldownSafety", label = "I want my big cooldowns grouped together and safe from being pressed by accident" },
    { key = "mouseRingsUsage",   label = "I want less important abilities on mouse rings instead of my bars" },
    { key = "movementPriority",  label = "I want my most-used abilities to be easy to press without modifiers" },
}

local levelOptions = { "Low", "Medium", "High" }

local priorityOptions = {
    { value = "movement", label = "Movement ease is more important to me" },
    { value = "equal",    label = "Both are equally important to me" },
    { value = "thematic", label = "Keeping similar things together is more important to me" },
}

local panel
local controls = {}

local function GetAccountKey()
    -- Simple account-level key. For now we use a fixed name.
    -- In a real multi-account setup we could use GetCurrentAccount() or similar.
    return "DefaultAccount"
end

local function GetDB()
    HeyDaddyDB = HeyDaddyDB or {}
    local key = GetAccountKey()
    HeyDaddyDB[key] = HeyDaddyDB[key] or {}
    return HeyDaddyDB[key]
end

local function CreatePanel()
    if panel then return panel end

    panel = CreateFrame("Frame", "HeyDaddyPanel", UIParent, "BackdropTemplate")
    panel:SetSize(560, 520)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("Hey Daddy")

    -- Subtitle
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("TOP", 0, -32)
    subtitle:SetText("Tell me what feels bad. I'll try to make your bars better.")

    local y = -55

    -- === Smart Defaults Section ===
    local smartLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    smartLabel:SetPoint("TOPLEFT", 20, y)
    smartLabel:SetText("Smart Defaults (Recommended)")

    y = y - 22

    local smartDesc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    smartDesc:SetPoint("TOPLEFT", 24, y)
    smartDesc:SetText("These good habits are turned on automatically:")

    y = y - 18

    local smartItems = {
        "Mouseover on heals, dispels, and helpful abilities",
        "Focus + mouseover for CC and interrupts",
        "/startattack only on safe damage abilities"
    }

    for _, item in ipairs(smartItems) do
        local txt = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        txt:SetPoint("TOPLEFT", 32, y)
        txt:SetText("• " .. item)
        y = y - 16
    end

    -- Master checkbox
    local masterCB = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    masterCB:SetPoint("TOPLEFT", 24, y - 4)
    masterCB:SetSize(20, 20)
    masterCB.text = masterCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    masterCB.text:SetPoint("LEFT", masterCB, "RIGHT", 4, 0)
    masterCB.text:SetText("Turn all of the above off")

    masterCB:SetScript("OnClick", function(self)
        local db = GetDB()
        db.smartDefaultsOff = self:GetChecked()
    end)

    controls.smartDefaultsOff = masterCB

    y = y - 32

    -- Separator line
    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    line:SetSize(510, 1)
    line:SetPoint("TOP", 0, y)
    y = y - 16

    -- Column header for the three choices
    local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPRIGHT", -20, y)
    header:SetText("Importance")
    header:SetTextColor(0.65, 0.65, 0.65)
    y = y - 16

    -- === Structured Preferences ===
    for _, opt in ipairs(options) do
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 20, y)
        label:SetText(opt.label)
        label:SetWidth(360)
        label:SetJustifyH("LEFT")

        -- Importance selector (ElvUI-ish style)
        local group = CreateFrame("Frame", nil, panel)
        group:SetPoint("TOPRIGHT", -20, y)
        local choiceWidth = 46
        group:SetSize(choiceWidth * 3 + 8, 18)
        group.buttons = {}

        for i, lvl in ipairs(levelOptions) do
            local choice = CreateFrame("Frame", nil, group, "BackdropTemplate")
            choice:SetSize(choiceWidth, 16)
            choice:SetPoint("LEFT", (i-1) * (choiceWidth + 4), 0)

            choice:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = false,
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            choice:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
            choice:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

            local text = choice:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            text:SetPoint("CENTER")
            text:SetText(lvl)
            text:SetTextColor(0.7, 0.7, 0.7)

            choice.optionKey = opt.key
            choice.level = lvl
            choice.text = text

            choice:SetScript("OnMouseDown", function(self)
                local db = GetDB()
                db[self.optionKey] = self.level

                for _, btn in ipairs(group.buttons) do
                    if btn == self then
                        btn.text:SetTextColor(1, 0.82, 0)           -- yellow
                        btn:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
                    else
                        btn.text:SetTextColor(0.65, 0.65, 0.65)
                        btn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
                    end
                end
            end)

            choice:SetScript("OnEnter", function(self)
                if self.text:GetTextColor() ~= 1 then
                    self.text:SetTextColor(0.85, 0.85, 0.85)
                end
            end)
            choice:SetScript("OnLeave", function(self)
                if self.text:GetTextColor() ~= 1 then
                    self.text:SetTextColor(0.65, 0.65, 0.65)
                end
            end)

            table.insert(group.buttons, choice)
        end

        controls[opt.key] = group
        y = y - 22
    end

    -- Free form
    local freeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    freeLabel:SetPoint("TOPLEFT", 20, y - 8)
    freeLabel:SetText("Anything else that feels bad or that you want? (optional)")

    local edit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    edit:SetPoint("TOPLEFT", 20, y - 30)
    edit:SetSize(510, 50)
    edit:SetMultiLine(true)
    edit:SetMaxLetters(600)
    edit:SetAutoFocus(false)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnTextChanged", function(self)
        GetDB().freeform = self:GetText()
    end)

    controls.freeform = edit

    -- Buttons
    local save = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    save:SetSize(80, 22)
    save:SetPoint("BOTTOMRIGHT", -14, 12)
    save:SetText("Save")
    save:SetScript("OnClick", function()
        print("|cff00ff00HeyDaddy|r preferences saved. Run |cff66ff66wcu|r when you're ready to apply them.")
        panel:Hide()
    end)

    local close = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    close:SetSize(80, 22)
    close:SetPoint("RIGHT", save, "LEFT", -8, 0)
    close:SetText("Close")
    close:SetScript("OnClick", function() panel:Hide() end)

    -- Load saved values when shown
    panel:SetScript("OnShow", function()
        local db = GetDB()

        -- Smart defaults master checkbox
        if controls.smartDefaultsOff then
            controls.smartDefaultsOff:SetChecked(db.smartDefaultsOff)
        end

        -- Level choices (restore selection with yellow text + border)
        for _, opt in ipairs(options) do
            local val = db[opt.key] or "Medium"
            local group = controls[opt.key]
            if group and group.buttons then
                for _, btn in ipairs(group.buttons) do
                    if btn.level == val then
                        btn.text:SetTextColor(1, 0.82, 0)
                        btn:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
                    else
                        btn.text:SetTextColor(0.65, 0.65, 0.65)
                        btn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
                    end
                end
            end
        end

        -- Free form
        if controls.freeform then
            controls.freeform:SetText(db.freeform or "")
        end
    end)

    return panel
end

-- Slash command
SLASH_HEYDADDY1 = "/heydaddy"
SLASH_HEYDADDY2 = "/hd"
SlashCmdList["HEYDADDY"] = function()
    local p = CreatePanel()
    p:Show()
end

-- Optional: simple welcome tip on first load (can be removed later)
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not HeyDaddyDB then
        print("|cff00ff00HeyDaddy|r loaded. Type |cff66ff66/heydaddy|r or |cff66ff66/hd|r to open the preferences panel.")
    end
end)