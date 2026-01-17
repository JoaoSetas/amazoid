--[[
    Amazoid - Mysterious Mailbox Merchant
    Letter & Contract UI

    All windows have the Amazoid poster header.
    - Letters: Content area with close button
    - Contracts: Content + checkbox + sign button

    Joypad/Controller compatible.
]]

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "ISUI/ISTickBox"

require "Amazoid/AmazoidLetters"
require "Amazoid/UI/AmazoidBasePanel" -- For shared window position storage

---@class AmazoidLetterPanel : ISCollapsableWindowJoypad
AmazoidLetterPanel = ISCollapsableWindowJoypad:derive("AmazoidLetterPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 12
local HEADER_HEIGHT = 120 -- Height for poster area

-- Minimalist color palette - matches catalog design
local COLORS = {
    bg = { r = 0.12, g = 0.12, b = 0.14 },      -- Dark background
    bgLight = { r = 0.18, g = 0.18, b = 0.20 }, -- Slightly lighter bg
    text = { r = 0.95, g = 0.95, b = 0.95 },    -- White text
    textDim = { r = 0.65, g = 0.65, b = 0.65 }, -- Dimmed text
    accent = { r = 0.85, g = 0.65, b = 0.30 },  -- Gold/amber accent
    border = { r = 0.30, g = 0.30, b = 0.32 },  -- Subtle border
}

function AmazoidLetterPanel:initialise()
    ISCollapsableWindowJoypad.initialise(self)
end

function AmazoidLetterPanel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local padding = UI_BORDER_SPACING

    -- Load poster texture
    self.posterTexture = getTexture("media/textures/Amazoid/poster.png")

    -- Calculate header dimensions - use fixed aspect ratio 1024:752
    self.headerY = th
    self.headerHeight = HEADER_HEIGHT

    -- Calculate poster size based on aspect ratio 1024:752 (wider than tall)
    local aspectRatio = 1024 / 752
    self.posterHeight = self.headerHeight
    self.posterWidth = self.posterHeight * aspectRatio
    self.posterX = (self.width - self.posterWidth) / 2
    self.posterY = self.headerY

    -- Content starts after header
    local currentY = th + self.headerHeight + padding

    if self.isDiscoveryLetter then
        self:createContractContent(currentY, rh, padding)
    else
        self:createLetterContent(currentY, rh, padding)
    end
end

-- ===== LETTER CONTENT =====
function AmazoidLetterPanel:createLetterContent(startY, rh, padding)
    local currentY = startY

    -- Letter content panel
    local btnHeight = FONT_HGT_SMALL + 12
    local btnY = self.height - btnHeight - padding - rh
    local contentHeight = btnY - currentY - padding

    self.letterContent = ISRichTextPanel:new(padding, currentY, self.width - padding * 2, contentHeight)
    self.letterContent:initialise()
    self.letterContent:instantiate()
    self.letterContent.autosetheight = false
    self.letterContent.clip = true
    self.letterContent.backgroundColor = { r = COLORS.bgLight.r, g = COLORS.bgLight.g, b = COLORS.bgLight.b, a = 1 }
    self.letterContent.borderColor = { r = COLORS.border.r, g = COLORS.border.g, b = COLORS.border.b, a = 0.6 }
    self.letterContent.marginLeft = 20
    self.letterContent.marginTop = 15
    self.letterContent.marginRight = 20
    self.letterContent.marginBottom = 15
    self.letterContent:setAnchorRight(true)
    self.letterContent:setAnchorBottom(true)
    self:addChild(self.letterContent)

    self:setLetterText()

    -- Close button
    local btnWidth = 110
    self.closeBtn = ISButton:new((self.width - btnWidth) / 2, btnY, btnWidth, btnHeight, "Close", self,
        AmazoidLetterPanel.onClose)
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self.closeBtn.backgroundColor = { r = COLORS.bgLight.r, g = COLORS.bgLight.g, b = COLORS.bgLight.b, a = 0.9 }
    self.closeBtn.backgroundColorMouseOver = { r = 0.25, g = 0.25, b = 0.27, a = 1 }
    self.closeBtn.borderColor = { r = COLORS.accent.r, g = COLORS.accent.g, b = COLORS.accent.b, a = 0.7 }
    self.closeBtn.textColor = { r = COLORS.text.r, g = COLORS.text.g, b = COLORS.text.b, a = 1 }
    self.closeBtn.anchorTop = false
    self.closeBtn.anchorBottom = true
    self:addChild(self.closeBtn)
end

-- ===== CONTRACT CONTENT =====
function AmazoidLetterPanel:createContractContent(startY, rh, padding)
    local currentY = startY

    -- Contract content panel
    local btnHeight = FONT_HGT_SMALL + 14
    local checkboxHeight = 28
    local btnY = self.height - btnHeight - padding - rh
    local checkboxY = btnY - checkboxHeight - padding
    local contentHeight = checkboxY - currentY - padding

    self.letterContent = ISRichTextPanel:new(padding, currentY, self.width - padding * 2, contentHeight)
    self.letterContent:initialise()
    self.letterContent:instantiate()
    self.letterContent.autosetheight = false
    self.letterContent.clip = true
    self.letterContent.backgroundColor = { r = COLORS.bgLight.r, g = COLORS.bgLight.g, b = COLORS.bgLight.b, a = 1 }
    self.letterContent.borderColor = { r = COLORS.border.r, g = COLORS.border.g, b = COLORS.border.b, a = 0.7 }
    self.letterContent.marginLeft = 25
    self.letterContent.marginTop = 20
    self.letterContent.marginRight = 25
    self.letterContent.marginBottom = 20
    self.letterContent:setAnchorRight(true)
    self.letterContent:setAnchorBottom(true)
    self:addChild(self.letterContent)

    self:setLetterText()

    -- Checkbox
    self.contractCheckbox = ISTickBox:new(padding, checkboxY, self.width - padding * 2, checkboxHeight, "", self,
        AmazoidLetterPanel.onContractToggle)
    self.contractCheckbox:initialise()
    self.contractCheckbox:addOption("I ACCEPT THE TERMS OF SERVICE")
    self.contractCheckbox.anchorTop = false
    self.contractCheckbox.anchorBottom = true
    self:addChild(self.contractCheckbox)

    -- Sign button
    local btnWidth = 150
    self.signButton = ISButton:new((self.width - btnWidth) / 2, btnY, btnWidth, btnHeight, "Sign Contract", self,
        AmazoidLetterPanel.onSignContract)
    self.signButton:initialise()
    self.signButton:instantiate()
    self.signButton.enable = false
    self.signButton.backgroundColor = { r = 0.15, g = 0.35, b = 0.15, a = 0.9 }
    self.signButton.backgroundColorMouseOver = { r = 0.2, g = 0.5, b = 0.2, a = 1 }
    self.signButton.textColor = { r = COLORS.text.r, g = COLORS.text.g, b = COLORS.text.b, a = 1 }
    self.signButton.anchorTop = false
    self.signButton.anchorBottom = true
    self:addChild(self.signButton)
end

function AmazoidLetterPanel:setLetterText()
    if not self.letterData then return end

    local content = self.letterData.content or ""
    local text = ""

    -- Check if content is pre-formatted (contains rich text tags like <CENTRE>, <RGB>, <IMAGE>, etc.)
    local isPreformatted = content:find("<CENTRE>") or content:find("<RGB:") or content:find("<IMAGE:") or
        content:find("<SIZE:")

    if isPreformatted then
        -- Use pre-formatted content directly (mission letters, etc.)
        text = content
    else
        -- Format plain text content with styling
        if self.isDiscoveryLetter then
            -- Contract: Formal header with light colors
            text = " <CENTRE> <SIZE:large> <RGB:0.95,0.95,0.95> " .. (self.letterData.title or "Contract") .. " <LINE> "
            text = text .. " <SIZE:small> <RGB:0.65,0.65,0.65> ━━━━━━━━━━━━━━━━━━━━━━━━━ <LINE> <LINE> "
        else
            -- Letter: Simple centered title
            text = " <CENTRE> <SIZE:medium> <RGB:0.95,0.95,0.95> " ..
                (self.letterData.title or "Letter") .. " <LINE> <LINE> "
        end

        -- Body content with light text
        text = text .. " <LEFT> <SIZE:small> <RGB:0.85,0.85,0.85> "

        content = content:gsub("\n\n", " <LINE> <LINE> ")
        content = content:gsub("\n", " <LINE> ")
        text = text .. content

        if self.isDiscoveryLetter then
            text = text .. " <LINE> <LINE> <CENTRE> <SIZE:small> <RGB:0.65,0.65,0.65> ━━━━━━━━━━━━━━━━━━━━━━━━━ "
        end
    end

    self.letterContent:setText(text)
    pcall(function() self.letterContent:paginate() end)
end

function AmazoidLetterPanel:onContractToggle(index, selected)
    if self.signButton then
        self.signButton.enable = selected
    end
end

function AmazoidLetterPanel:onSignContract()
    if not self.contractCheckbox or not self.contractCheckbox:isSelected(1) then
        return
    end

    local player = self.player or getPlayer()
    if not player then return end

    print("[Amazoid] Signing contract...")

    -- Set contract data on player
    local data = player:getModData().Amazoid or {}
    data.hasContract = true
    data.reputation = data.reputation or 0
    data.contractSignedDate = getGameTime():getWorldAgeHours()
    player:getModData().Amazoid = data

    -- Activate contract on mailbox
    if self.mailbox then
        local playerIndex = player:getPlayerNum()

        if Amazoid and Amazoid.Client then
            local location = {
                x = self.mailbox:getX(),
                y = self.mailbox:getY(),
                z = self.mailbox:getZ()
            }
            Amazoid.Client.signContract(location)
        end

        if Amazoid and Amazoid.Mailbox then
            Amazoid.Mailbox.activateContract(self.mailbox, playerIndex)
            Amazoid.Mailbox.removeDiscoveryLetter(self.mailbox)
        end
    end

    -- Remove discovery letter and add signed contract
    local inv = player:getInventory()

    -- Remove from player inventory if present
    if self.letterItem then
        inv:Remove(self.letterItem)
    end

    -- Also remove ALL discovery letters from player inventory
    local invItems = inv:getItems()
    local toRemoveInv = {}
    for i = 0, invItems:size() - 1 do
        local item = invItems:get(i)
        if item and item:getFullType() == "Amazoid.DiscoveryLetter" then
            table.insert(toRemoveInv, item)
        end
    end
    for _, item in ipairs(toRemoveInv) do
        inv:Remove(item)
    end

    -- Remove ALL discovery letters from all loaded mailboxes in the world
    local removedCount = 0
    local playerX = math.floor(player:getX())
    local playerY = math.floor(player:getY())
    local playerZ = math.floor(player:getZ())
    local searchRadius = 100

    for x = playerX - searchRadius, playerX + searchRadius do
        for y = playerY - searchRadius, playerY + searchRadius do
            local square = getCell():getGridSquare(x, y, playerZ)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    if Amazoid.Mailbox and Amazoid.Mailbox.isMailbox and Amazoid.Mailbox.isMailbox(obj) then
                        local container = obj:getContainer()
                        if container then
                            local items = container:getItems()
                            local toRemove = {}
                            for j = 0, items:size() - 1 do
                                local item = items:get(j)
                                if item and item:getFullType() == "Amazoid.DiscoveryLetter" then
                                    table.insert(toRemove, item)
                                end
                            end
                            for _, item in ipairs(toRemove) do
                                container:Remove(item)
                                removedCount = removedCount + 1
                            end
                        end
                    end
                end
            end
        end
    end

    if removedCount > 0 then
        print("[Amazoid] Removed " .. removedCount .. " discovery letter(s) from world mailboxes")
    end

    -- Add signed contract to mailbox if available, otherwise player inventory
    local signedContract = instanceItem("Amazoid.SignedContract")
    local targetContainer = nil

    -- Try to add to mailbox first
    if self.mailbox then
        targetContainer = self.mailbox:getContainer()
    end

    if targetContainer and signedContract then
        targetContainer:addItem(signedContract)
        print("[Amazoid] Signed contract added to mailbox")
    elseif signedContract then
        inv:addItem(signedContract)
        print("[Amazoid] Signed contract added to player inventory")
    else
        inv:AddItem("Amazoid.SignedContract")
    end

    player:Say("Contract signed!")
    self:close()

    -- Show welcome letter
    if Amazoid and Amazoid.Letters and Amazoid.Letters.Welcome then
        AmazoidLetterPanel.showLetter(player, Amazoid.Letters.Welcome, false, nil, nil)
    end
end

function AmazoidLetterPanel:onClose()
    self:close()
end

function AmazoidLetterPanel:close()
    -- Save window position to shared storage for this player
    if self.playerNum ~= nil and Amazoid.UI and Amazoid.UI.saveWindowPosition then
        Amazoid.UI.saveWindowPosition(self.playerNum, self:getX(), self:getY())
    end

    -- Mark letter as read using PZ's built-in literature tracking
    -- Mark for ALL local players (split-screen support) so checkmark shows for everyone
    if self.letterItem then
        local modData = self.letterItem:getModData()
        if modData and modData.literatureTitle then
            -- Mark as read for ALL local players (split-screen support)
            -- PZ's ISInventoryPane checks player:isLiteratureRead() for the checkmark
            local players = IsoPlayer.getPlayers()
            for i = 0, players:size() - 1 do
                local p = players:get(i)
                if p then
                    p:addReadLiterature(modData.literatureTitle)
                end
            end
            print("[Amazoid] Marked as read for all players: " .. modData.literatureTitle)
        end
    end

    self:setVisible(false)
    self:removeFromUIManager()
    if self.joyfocus then
        setJoypadFocus(self.playerNum, nil)
    end
end

function AmazoidLetterPanel:prerender()
    local th = self:titleBarHeight()

    -- Dark background matching catalog design
    self:drawRect(0, th, self.width, self.height - th, 0.95, COLORS.bg.r, COLORS.bg.g, COLORS.bg.b)

    ISCollapsableWindowJoypad.prerender(self)

    -- Draw poster image centered (no additional header background)
    if self.posterTexture and self.posterWidth then
        self:drawTextureScaled(self.posterTexture, self.posterX, self.posterY, self.posterWidth, self.posterHeight, 1, 1,
            1, 1)
    end
end

-- ===== JOYPAD/CONTROLLER SUPPORT =====

function AmazoidLetterPanel:onGainJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData)
    self.joyfocus = true
    self.joypadData = joypadData
    self.joypadIndex = 1
end

function AmazoidLetterPanel:onLoseJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
    self.joyfocus = false
end

function AmazoidLetterPanel:onJoypadDown(button, joypadData)
    if button == Joypad.BButton then
        self:close()
        return
    end

    if self.isDiscoveryLetter then
        if button == Joypad.AButton then
            if self.contractCheckbox then
                local selected = self.contractCheckbox:isSelected(1)
                self.contractCheckbox:setSelected(1, not selected)
                self:onContractToggle(1, not selected)
            end
            return
        end
        if button == Joypad.XButton then
            if self.signButton and self.signButton.enable then
                self:onSignContract()
            end
            return
        end
    else
        if button == Joypad.AButton then
            self:close()
            return
        end
    end
end

function AmazoidLetterPanel:onJoypadDirUp(joypadData)
    if self.letterContent then
        self.letterContent:setYScroll(self.letterContent:getYScroll() - 30)
    end
end

function AmazoidLetterPanel:onJoypadDirDown(joypadData)
    if self.letterContent then
        self.letterContent:setYScroll(self.letterContent:getYScroll() + 30)
    end
end

function AmazoidLetterPanel:getAPrompt()
    if self.isDiscoveryLetter then
        return "Accept Terms"
    end
    return "Close"
end

function AmazoidLetterPanel:getBPrompt()
    return getText("UI_Close") or "Close"
end

function AmazoidLetterPanel:getXPrompt()
    if self.isDiscoveryLetter then
        return "Sign Contract"
    end
    return nil
end

function AmazoidLetterPanel:new(x, y, width, height, letterData, isDiscoveryLetter, player, mailbox, letterItem)
    local title = letterData and letterData.title or "Letter"
    if isDiscoveryLetter then
        title = "Contract"
    end

    local o = ISCollapsableWindowJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.title = title
    o.letterData = letterData
    o.isDiscoveryLetter = isDiscoveryLetter or false
    o.player = player
    o.playerNum = player and player:getPlayerNum() or 0
    o.mailbox = mailbox
    o.letterItem = letterItem
    o.resizable = false
    o.drawFrame = true

    return o
end

-- Per-player window position storage (legacy - now uses shared Amazoid.UI.sharedWindowPositions)
AmazoidLetterPanel.savedPositions = {}

--- Static function to show a letter
function AmazoidLetterPanel.showLetter(player, letterData, isDiscoveryLetter, mailbox, letterItem)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local playerNum = player and player:getPlayerNum() or 0

    -- Window size (tall for better readability)
    local width = math.min(550, screenW - 60)
    local height = math.min(800, screenH - 60)

    -- Use shared position storage, fall back to centered
    local x, y
    if Amazoid.UI and Amazoid.UI.getWindowPositionOrCenter then
        x, y = Amazoid.UI.getWindowPositionOrCenter(playerNum, width, height)
    else
        x = (screenW - width) / 2
        y = (screenH - height) / 2
    end

    local panel = AmazoidLetterPanel:new(x, y, width, height, letterData, isDiscoveryLetter, player, mailbox, letterItem)
    panel.playerNum = playerNum -- Store for saving position later
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)

    -- Joypad focus
    if JoypadState and JoypadState.players and JoypadState.players[playerNum + 1] then
        setJoypadFocus(playerNum, panel)
    end

    local docType = isDiscoveryLetter and "contract" or "letter"
    print("[Amazoid] Opened " .. docType .. ": " .. (letterData.title or "Unknown"))

    return panel
end

print("[Amazoid] Letter & Contract UI loaded")
