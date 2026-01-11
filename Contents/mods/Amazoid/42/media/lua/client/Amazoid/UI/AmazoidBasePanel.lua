--[[
    Amazoid - Mysterious Mailbox Merchant
    UI Base Module

    This file contains the base UI panel class for Amazoid windows.
    All windows have consistent dark styling with poster header.
]]

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISScrollingListBox"

-- Ensure Amazoid global exists
Amazoid = Amazoid or {}
Amazoid.UI = Amazoid.UI or {}

---@class AmazoidBasePanel : ISPanel
AmazoidBasePanel = ISPanel:derive("AmazoidBasePanel")

-- Minimalist color palette - consistent across all panels
local COLORS = {
    bg = { r = 0.12, g = 0.12, b = 0.14 }, -- Dark background
    bgLight = { r = 0.18, g = 0.18, b = 0.20 }, -- Slightly lighter bg
    text = { r = 0.95, g = 0.95, b = 0.95 }, -- White text
    textDim = { r = 0.65, g = 0.65, b = 0.65 }, -- Dimmed text
    accent = { r = 0.85, g = 0.65, b = 0.30 }, -- Gold/amber accent
    border = { r = 0.30, g = 0.30, b = 0.32 }, -- Subtle border
}

local HEADER_HEIGHT = 70 -- Height for poster area

function AmazoidBasePanel:initialise()
    ISPanel.initialise(self)
end

function AmazoidBasePanel:createChildren()
    ISPanel.createChildren(self)

    -- Load poster texture
    self.posterTexture = getTexture("media/textures/Amazoid/poster.png")

    -- Calculate header dimensions
    self.headerY = 25 -- After title bar
    self.headerHeight = HEADER_HEIGHT

    if self.posterTexture then
        local imgW = self.posterTexture:getWidth()
        local imgH = self.posterTexture:getHeight()
        self.posterScale = self.headerHeight / imgH
        self.posterWidth = imgW * self.posterScale
        self.posterHeight = self.headerHeight
        self.posterX = (self.width - self.posterWidth) / 2
        self.posterY = self.headerY
    end

    -- Title bar with dark styling
    self.titleBar = ISPanel:new(0, 0, self.width, 25)
    self.titleBar:initialise()
    self.titleBar.backgroundColor = { r = COLORS.bgLight.r, g = COLORS.bgLight.g, b = COLORS.bgLight.b, a = 1 }
    self:addChild(self.titleBar)

    -- Title label with light text
    self.titleLabel = ISLabel:new(10, 4, 20, self.title or "Amazoid", COLORS.text.r, COLORS.text.g, COLORS.text.b, 1,
        UIFont.Medium, true)
    self.titleBar:addChild(self.titleLabel)

    -- Close button
    self.closeButton = ISButton:new(self.width - 25, 2, 20, 20, "X", self, AmazoidBasePanel.onClose)
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self.closeButton.backgroundColor = { r = 0.5, g = 0.2, b = 0.2, a = 0.8 }
    self.closeButton.backgroundColorMouseOver = { r = 0.7, g = 0.2, b = 0.2, a = 1 }
    self.closeButton.textColor = { r = COLORS.text.r, g = COLORS.text.g, b = COLORS.text.b, a = 1 }
    self.titleBar:addChild(self.closeButton)
end

function AmazoidBasePanel:onClose()
    self:setVisible(false)
    self:removeFromUIManager()
end

function AmazoidBasePanel:prerender()
    ISPanel.prerender(self)

    -- Dark background
    self:drawRect(0, 0, self.width, self.height, 0.95, COLORS.bg.r, COLORS.bg.g, COLORS.bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, 1, COLORS.border.r, COLORS.border.g, COLORS.border.b)

    -- Header background
    self:drawRect(0, self.headerY, self.width, self.headerHeight, 0.9, COLORS.bgLight.r, COLORS.bgLight.g,
        COLORS.bgLight.b)

    -- Draw poster image centered
    if self.posterTexture and self.posterWidth then
        self:drawTextureScaled(self.posterTexture, self.posterX, self.posterY, self.posterWidth, self.posterHeight, 1, 1,
            1, 1)
    end

    -- Accent line under header
    self:drawRect(0, self.headerY + self.headerHeight - 2, self.width, 2, 1, COLORS.accent.r, COLORS.accent.g,
        COLORS.accent.b)
end

function AmazoidBasePanel:new(x, y, width, height, title)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = title or "Amazoid"
    o.backgroundColor = { r = COLORS.bg.r, g = COLORS.bg.g, b = COLORS.bg.b, a = 0.95 }
    o.borderColor = { r = COLORS.border.r, g = COLORS.border.g, b = COLORS.border.b, a = 1 }
    o.moveWithMouse = true
    return o
end

-- ============================================
-- SHARED WINDOW POSITION STORAGE
-- All Amazoid panels share the same position per player
-- ============================================

--- Per-player shared window position storage
--- Key: playerNum, Value: {x, y}
Amazoid.UI.sharedWindowPositions = Amazoid.UI.sharedWindowPositions or {}

--- Get the saved window position for a player
---@param playerNum number The player number (0-based)
---@return table|nil Position {x, y} or nil if not set
function Amazoid.UI.getWindowPosition(playerNum)
    return Amazoid.UI.sharedWindowPositions[playerNum]
end

--- Save the window position for a player
---@param playerNum number The player number (0-based)
---@param x number The x position
---@param y number The y position
function Amazoid.UI.saveWindowPosition(playerNum, x, y)
    Amazoid.UI.sharedWindowPositions[playerNum] = { x = x, y = y }
end

--- Get the position to use for a new window (saved position or centered)
---@param playerNum number The player number (0-based)
---@param width number The window width
---@param height number The window height
---@return number, number x and y position
function Amazoid.UI.getWindowPositionOrCenter(playerNum, width, height)
    local savedPos = Amazoid.UI.getWindowPosition(playerNum)
    if savedPos then
        return savedPos.x, savedPos.y
    else
        local screenW = getCore():getScreenWidth()
        local screenH = getCore():getScreenHeight()
        return (screenW - width) / 2, (screenH - height) / 2
    end
end

print("[Amazoid] UI Base module loaded")
