--[[
    Amazoid - Mysterious Mailbox Merchant
    UI Base Module
    
    This file contains the base UI panel class for Amazoid windows.
]]

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISScrollingListBox"

Amazoid.UI = Amazoid.UI or {}

---@class AmazoidBasePanel : ISPanel
AmazoidBasePanel = ISPanel:derive("AmazoidBasePanel")

function AmazoidBasePanel:initialise()
    ISPanel.initialise(self)
end

function AmazoidBasePanel:createChildren()
    ISPanel.createChildren(self)
    
    -- Title bar
    self.titleBar = ISPanel:new(0, 0, self.width, 25)
    self.titleBar:initialise()
    self.titleBar.backgroundColor = {r=0.2, g=0.2, b=0.3, a=0.9}
    self:addChild(self.titleBar)
    
    -- Title label
    self.titleLabel = ISLabel:new(10, 4, 20, self.title or "Amazoid", 1, 1, 1, 1, UIFont.Medium, true)
    self.titleBar:addChild(self.titleLabel)
    
    -- Close button
    self.closeButton = ISButton:new(self.width - 25, 2, 20, 20, "X", self, AmazoidBasePanel.onClose)
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self.closeButton.backgroundColor = {r=0.6, g=0.2, b=0.2, a=0.8}
    self.closeButton.backgroundColorMouseOver = {r=0.8, g=0.2, b=0.2, a=1}
    self.titleBar:addChild(self.closeButton)
end

function AmazoidBasePanel:onClose()
    self:setVisible(false)
    self:removeFromUIManager()
end

function AmazoidBasePanel:prerender()
    ISPanel.prerender(self)
    self:drawRect(0, 0, self.width, self.height, 0.9, 0.1, 0.1, 0.15)
    self:drawRectBorder(0, 0, self.width, self.height, 1, 0.4, 0.4, 0.5)
end

function AmazoidBasePanel:new(x, y, width, height, title)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = title or "Amazoid"
    o.backgroundColor = {r=0.1, g=0.1, b=0.15, a=0.95}
    o.borderColor = {r=0.4, g=0.4, b=0.5, a=1}
    o.moveWithMouse = true
    return o
end

print("[Amazoid] UI Base module loaded")
