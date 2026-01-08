--[[
    Amazoid - Mysterious Mailbox Merchant
    Letter Reader UI
    
    This file contains the UI for reading Amazoid letters.
]]

require "Amazoid/UI/AmazoidBasePanel"
require "Amazoid/AmazoidLetters"

---@class AmazoidLetterPanel : AmazoidBasePanel
AmazoidLetterPanel = AmazoidBasePanel:derive("AmazoidLetterPanel")

function AmazoidLetterPanel:createChildren()
    AmazoidBasePanel.createChildren(self)
    
    local y = 35
    local padding = 15
    
    -- Letter content panel (scrollable rich text)
    self.letterContent = ISRichTextPanel:new(padding, y, self.width - (padding * 2), self.height - y - 60)
    self.letterContent:initialise()
    self.letterContent.backgroundColor = {r=0.95, g=0.9, b=0.8, a=1} -- Parchment color
    self.letterContent.borderColor = {r=0.4, g=0.3, b=0.2, a=1}
    self.letterContent.marginLeft = 15
    self.letterContent.marginTop = 10
    self.letterContent.marginRight = 15
    self.letterContent.marginBottom = 10
    self.letterContent:setAnchorLeft(true)
    self.letterContent:setAnchorRight(true)
    self.letterContent:setAnchorTop(true)
    self.letterContent:setAnchorBottom(true)
    self:addChild(self.letterContent)
    
    -- Contract checkbox (only shown for discovery letter)
    if self.isDiscoveryLetter then
        self.contractCheckbox = ISTickBox:new(padding, self.height - 50, 200, 20, "", self, AmazoidLetterPanel.onContractToggle)
        self.contractCheckbox:initialise()
        self.contractCheckbox:addOption("I ACCEPT THE TERMS OF SERVICE")
        self:addChild(self.contractCheckbox)
        
        -- Sign contract button
        self.signButton = ISButton:new(self.width - 150 - padding, self.height - 50, 150, 30, "Sign Contract", self, AmazoidLetterPanel.onSignContract)
        self.signButton:initialise()
        self.signButton:instantiate()
        self.signButton.enable = false
        self.signButton.backgroundColor = {r=0.2, g=0.4, b=0.2, a=0.8}
        self.signButton.backgroundColorMouseOver = {r=0.3, g=0.6, b=0.3, a=1}
        self:addChild(self.signButton)
    else
        -- Just a close button for regular letters
        self.closeBtn = ISButton:new((self.width - 100) / 2, self.height - 45, 100, 30, "Close", self, AmazoidLetterPanel.onClose)
        self.closeBtn:initialise()
        self.closeBtn:instantiate()
        self:addChild(self.closeBtn)
    end
    
    -- Set the letter text
    self:setLetterContent()
end

function AmazoidLetterPanel:setLetterContent()
    if not self.letterData then return end
    
    local text = " <H1> " .. (self.letterData.title or "Letter") .. " <LINE> <LINE> "
    text = text .. " <SIZE:medium> <RGB:0.1,0.1,0.1> "
    
    -- Replace newlines with <LINE> tags
    local content = self.letterData.content or ""
    content = content:gsub("\n\n", " <LINE> <LINE> ")
    content = content:gsub("\n", " <LINE> ")
    
    text = text .. content
    
    self.letterContent:setText(text)
    self.letterContent:paginate()
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
    
    -- Sign the contract
    if self.mailbox and self.player then
        local playerIndex = self.player:getPlayerNum()
        
        -- Activate contract on client
        if Amazoid.Client then
            local location = {
                x = self.mailbox:getX(),
                y = self.mailbox:getY(),
                z = self.mailbox:getZ()
            }
            Amazoid.Client.signContract(location)
        end
        
        -- Activate contract on mailbox
        if Amazoid.Mailbox then
            Amazoid.Mailbox.activateContract(self.mailbox, playerIndex)
            Amazoid.Mailbox.removeDiscoveryLetter(self.mailbox)
        end
        
        -- Remove the letter item from inventory
        if self.letterItem then
            self.player:getInventory():Remove(self.letterItem)
        end
        
        -- Show welcome letter
        local welcomeLetter = Amazoid.Letters.Welcome
        AmazoidLetterPanel.showLetter(self.player, welcomeLetter, false, nil, nil)
    end
    
    self:onClose()
end

function AmazoidLetterPanel:prerender()
    AmazoidBasePanel.prerender(self)
end

function AmazoidLetterPanel:new(x, y, width, height, letterData, isDiscoveryLetter, player, mailbox, letterItem)
    local o = AmazoidBasePanel:new(x, y, width, height, letterData.title or "Letter")
    setmetatable(o, self)
    self.__index = self
    o.letterData = letterData
    o.isDiscoveryLetter = isDiscoveryLetter or false
    o.player = player
    o.mailbox = mailbox
    o.letterItem = letterItem
    return o
end

--- Static function to show a letter
---@param player IsoPlayer The player
---@param letterData table The letter data
---@param isDiscoveryLetter boolean Whether this is a discovery letter
---@param mailbox IsoObject The mailbox (for discovery letters)
---@param letterItem InventoryItem The letter item
function AmazoidLetterPanel.showLetter(player, letterData, isDiscoveryLetter, mailbox, letterItem)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = 500
    local height = 600
    local x = (screenW - width) / 2
    local y = (screenH - height) / 2
    
    local panel = AmazoidLetterPanel:new(x, y, width, height, letterData, isDiscoveryLetter, player, mailbox, letterItem)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    
    return panel
end

print("[Amazoid] Letter Reader UI loaded")
