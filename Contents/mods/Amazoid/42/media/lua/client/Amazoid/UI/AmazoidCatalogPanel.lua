--[[
    Amazoid - Mysterious Mailbox Merchant
    Catalog UI - Minimalist Design
    
    Clean magazine-style catalog with:
    - Cover page with edition info
    - Multiple category pages with item icons
    - Page-flip navigation
    - Simple circle marks for ordering
    
    Joypad/Controller compatible.
]]

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISButton"
require "ISUI/ISLabel"

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidCatalogs"
require "Amazoid/UI/AmazoidBasePanel" -- For shared window position storage

---@class AmazoidCatalogPanel : ISCollapsableWindowJoypad
AmazoidCatalogPanel = ISCollapsableWindowJoypad:derive("AmazoidCatalogPanel")

-- Icon cache to avoid repeated lookups every frame
local iconCache = {}
local iconCacheChecked = {}  -- Track which items we've already tried to load

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

-- Layout constants
local PAGE_MARGIN = 20
local ITEM_ICON_SIZE = 32
local ITEM_ROW_HEIGHT = 48
local HEADER_HEIGHT = 120  -- Height for poster area

-- Minimalist color palette - high contrast, easy to read
local COLORS = {
    bg = {r=0.12, g=0.12, b=0.14},            -- Dark background
    bgLight = {r=0.18, g=0.18, b=0.20},       -- Slightly lighter bg
    text = {r=0.95, g=0.95, b=0.95},          -- White text
    textDim = {r=0.65, g=0.65, b=0.65},       -- Dimmed text
    accent = {r=0.85, g=0.65, b=0.30},        -- Gold/amber accent
    selected = {r=0.30, g=0.55, b=0.30},      -- Green for selected
    border = {r=0.30, g=0.30, b=0.32},        -- Subtle border
}

function AmazoidCatalogPanel:initialise()
    ISCollapsableWindowJoypad.initialise(self)
end

function AmazoidCatalogPanel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)
    
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    
    -- Load poster texture for header
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
    
    -- Initialize page state
    self.currentPage = 0  -- 0 = cover, 1+ = content pages
    self.circledItems = {}
    self:loadCircledItems()
    
    -- Calculate page count from edition
    self.totalPages = 0
    if self.edition and self.edition.pages then
        self.totalPages = #self.edition.pages
    end
    
    -- Navigation buttons at bottom
    local btnWidth = 100
    local btnHeight = FONT_HGT_SMALL + 10
    local btnY = self.height - btnHeight - 12 - rh
    
    -- Previous page button (left)
    self.prevBtn = ISButton:new(PAGE_MARGIN, btnY, btnWidth, btnHeight, "< Prev", self, AmazoidCatalogPanel.onPrevPage)
    self.prevBtn:initialise()
    self.prevBtn:instantiate()
    self.prevBtn.anchorTop = false
    self.prevBtn.anchorBottom = true
    self.prevBtn.backgroundColor = {r=COLORS.bgLight.r, g=COLORS.bgLight.g, b=COLORS.bgLight.b, a=0.9}
    self.prevBtn.borderColor = {r=COLORS.border.r, g=COLORS.border.g, b=COLORS.border.b, a=0.8}
    self:addChild(self.prevBtn)
    
    -- Page indicator (center)
    self.pageLabel = ISLabel:new(self.width / 2, btnY + btnHeight / 2 - FONT_HGT_SMALL / 2, FONT_HGT_SMALL, 
        "Cover", COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b, 1, UIFont.Small, true)
    self.pageLabel:initialise()
    self:addChild(self.pageLabel)
    
    -- Next page button (right)
    self.nextBtn = ISButton:new(self.width - PAGE_MARGIN - btnWidth, btnY, btnWidth, btnHeight, "Next >", self, AmazoidCatalogPanel.onNextPage)
    self.nextBtn:initialise()
    self.nextBtn:instantiate()
    self.nextBtn.anchorTop = false
    self.nextBtn.anchorBottom = true
    self.nextBtn.anchorRight = true
    self.nextBtn.anchorLeft = false
    self.nextBtn.backgroundColor = {r=COLORS.bgLight.r, g=COLORS.bgLight.g, b=COLORS.bgLight.b, a=0.9}
    self.nextBtn.borderColor = {r=COLORS.border.r, g=COLORS.border.g, b=COLORS.border.b, a=0.8}
    self:addChild(self.nextBtn)
    
    -- Done button (only on content pages, bottom center-right)
    self.doneBtn = ISButton:new(self.width - PAGE_MARGIN - btnWidth, btnY - btnHeight - 8, btnWidth, btnHeight, "Done", self, AmazoidCatalogPanel.onDone)
    self.doneBtn:initialise()
    self.doneBtn:instantiate()
    self.doneBtn.anchorTop = false
    self.doneBtn.anchorBottom = true
    self.doneBtn.anchorRight = true
    self.doneBtn.anchorLeft = false
    self.doneBtn.backgroundColor = {r=COLORS.selected.r, g=COLORS.selected.g, b=COLORS.selected.b, a=0.9}
    self:addChild(self.doneBtn)
    
    self:updateNavButtons()
end

function AmazoidCatalogPanel:updateNavButtons()
    if self.prevBtn then
        self.prevBtn.enable = self.currentPage > 0
    end
    if self.nextBtn then
        self.nextBtn.enable = self.currentPage < self.totalPages
    end
    if self.pageLabel then
        if self.currentPage ~= 0 then
            self.pageLabel:setName("Page " .. self.currentPage .. " of " .. self.totalPages)
        end
        -- Recenter
        local textW = getTextManager():MeasureStringX(UIFont.Small, self.pageLabel:getName())
        self.pageLabel:setX((self.width - textW) / 2)
    end
    if self.doneBtn then
        self.doneBtn:setVisible(self.currentPage > 0)
    end
end

function AmazoidCatalogPanel:onPrevPage()
    if self.currentPage > 0 then
        self.currentPage = self.currentPage - 1
        self:updateNavButtons()
    end
end

function AmazoidCatalogPanel:onNextPage()
    if self.currentPage < self.totalPages then
        self.currentPage = self.currentPage + 1
        self:updateNavButtons()
    end
end

function AmazoidCatalogPanel:onDone()
    self:saveCircledItems()
    
    local count = 0
    for _, c in pairs(self.circledItems) do
        if c > 0 then count = count + c end
    end
    
    if count > 0 and self.player then
        self.player:Say("Marked " .. count .. " item" .. (count > 1 and "s" or "") .. ".")
    end
    
    self:close()
end

function AmazoidCatalogPanel:close()
    self:saveCircledItems()
    
    -- Save window position to shared storage for this player
    if self.playerNum ~= nil and Amazoid.UI and Amazoid.UI.saveWindowPosition then
        Amazoid.UI.saveWindowPosition(self.playerNum, self:getX(), self:getY())
    end
    
    self:setVisible(false)
    self:removeFromUIManager()
    if self.joyfocus then
        setJoypadFocus(self.playerNum, nil)
    end
end

function AmazoidCatalogPanel:loadCircledItems()
    self.circledItems = {}
    if self.catalogItem then
        local modData = self.catalogItem:getModData()
        if modData and modData.AmazoidCircled then
            for itemType, count in pairs(modData.AmazoidCircled) do
                self.circledItems[itemType] = count
            end
        end
    end
end

function AmazoidCatalogPanel:saveCircledItems()
    if self.catalogItem then
        local modData = self.catalogItem:getModData()
        modData.AmazoidCircled = {}
        for itemType, count in pairs(self.circledItems) do
            if count > 0 then
                modData.AmazoidCircled[itemType] = count
            end
        end
        -- Also store edition ID
        if self.edition then
            modData.AmazoidEdition = self.edition.id
        end
    end
end

function AmazoidCatalogPanel:prerender()
    local th = self:titleBarHeight()
    
    -- Draw dark background
    self:drawRect(0, th, self.width, self.height - th, 1, COLORS.bg.r, COLORS.bg.g, COLORS.bg.b)
    
    ISCollapsableWindowJoypad.prerender(self)
    
    -- Draw poster image centered (no additional header background)
    if self.posterTexture and self.posterWidth then
        self:drawTextureScaled(self.posterTexture, self.posterX, self.posterY, self.posterWidth, self.posterHeight, 1, 1, 1, 1)
    end
    
    if self.currentPage == 0 then
        self:drawCoverPage(th)
    else
        self:drawContentPage(th, self.currentPage)
    end
end

function AmazoidCatalogPanel:drawCoverPage(th)
    local centerX = self.width / 2
    -- Start content after the poster header
    local y = th + self.headerHeight + 15
    
    -- Title bar with accent color
    self:drawRect(0, y, self.width, 80, 0.9, COLORS.bgLight.r, COLORS.bgLight.g, COLORS.bgLight.b)
    self:drawRect(0, y + 78, self.width, 2, 1, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b)
    
    -- Title
    local title = self.edition and self.edition.title or "Amazoid Catalog"
    local titleW = getTextManager():MeasureStringX(UIFont.Large, title)
    self:drawText(title, centerX - titleW / 2, y + 15, COLORS.text.r, COLORS.text.g, COLORS.text.b, 1, UIFont.Large)
    
    -- Subtitle
    local subtitle = self.edition and self.edition.subtitle or ""
    local subtitleW = getTextManager():MeasureStringX(UIFont.Medium, subtitle)
    self:drawText(subtitle, centerX - subtitleW / 2, y + 45, COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b, 1, UIFont.Medium)
    
    y = y + 100
    
    -- Volume number (Roman numerals like skill books)
    local issue = self.edition and self.edition.issue or 1
    local romanNumerals = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"}
    local issueText = "Vol. " .. (romanNumerals[issue] or tostring(issue))
    local issueW = getTextManager():MeasureStringX(UIFont.Small, issueText)
    self:drawText(issueText, centerX - issueW / 2, y, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b, 1, UIFont.Small)
    
    y = y + 30
    
    -- Table of contents header
    local tocTitle = "CONTENTS"
    local tocW = getTextManager():MeasureStringX(UIFont.Medium, tocTitle)
    self:drawText(tocTitle, centerX - tocW / 2, y, COLORS.text.r, COLORS.text.g, COLORS.text.b, 1, UIFont.Medium)
    y = y + FONT_HGT_MEDIUM + 12
    
    -- Separator line
    self:drawRect(PAGE_MARGIN + 40, y, self.width - PAGE_MARGIN * 2 - 80, 1, 0.5, COLORS.border.r, COLORS.border.g, COLORS.border.b)
    y = y + 15
    
    if self.edition and self.edition.pages then
        for i, page in ipairs(self.edition.pages) do
            local pageText = i .. ".  " .. page.title
            self:drawText(pageText, PAGE_MARGIN + 40, y, COLORS.text.r, COLORS.text.g, COLORS.text.b, 1, UIFont.Small)
            
            -- Item count (right side)
            local itemCount = page.items and #page.items or 0
            local countText = itemCount .. " items"
            local countW = getTextManager():MeasureStringX(UIFont.Small, countText)
            self:drawText(countText, self.width - PAGE_MARGIN - 40 - countW, y, COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b, 1, UIFont.Small)
            
            y = y + FONT_HGT_SMALL + 10
        end
    end
    
    y = y + 20
    
    -- Separator line
    self:drawRect(PAGE_MARGIN + 40, y, self.width - PAGE_MARGIN * 2 - 80, 1, 0.3, COLORS.border.r, COLORS.border.g, COLORS.border.b)
    y = y + 16
    
    -- Instructions
    local instructions = {
        "Click items to mark for order",
        "Leave catalog + money in mailbox",
    }
    for _, text in ipairs(instructions) do
        local textW = getTextManager():MeasureStringX(UIFont.Small, text)
        self:drawText(text, centerX - textW / 2, y, COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL + 6
    end
    
    -- Next volume unlock info
    if self.edition and self.edition.catalogType then
        local category = self.edition.catalogType
        local currentVolume = self.edition.issue or 1
        local nextVolume = currentVolume + 1
        
        -- Get spending info
        local spentOnCategory = 0
        local threshold = 100
        if Amazoid.Client and Amazoid.Client.playerData then
            spentOnCategory = (Amazoid.Client.playerData.totalSpentByCategory or {})[category] or 0
        end
        if Amazoid.Catalogs and Amazoid.Catalogs.getVolumeUnlockThreshold then
            threshold = Amazoid.Catalogs.getVolumeUnlockThreshold(category, nextVolume)
        end
        
        local remaining = threshold - spentOnCategory
        if remaining > 0 then
            y = y + 6
            local unlockText = "Spend $" .. remaining .. " more to unlock next volume"
            local unlockW = getTextManager():MeasureStringX(UIFont.Small, unlockText)
            self:drawText(unlockText, centerX - unlockW / 2, y, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b, 0.8, UIFont.Small)
            y = y + FONT_HGT_SMALL + 4
        end
    end
    
    -- Season badge if seasonal
    if self.edition and self.edition.season then
        y = y + 15
        local seasonBadge = string.upper(self.edition.season) .. " EDITION"
        local badgeW = getTextManager():MeasureStringX(UIFont.Small, seasonBadge)
        self:drawRect(centerX - badgeW / 2 - 12, y - 2, badgeW + 24, FONT_HGT_SMALL + 8, 0.9, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b)
        self:drawText(seasonBadge, centerX - badgeW / 2, y + 2, COLORS.bg.r, COLORS.bg.g, COLORS.bg.b, 1, UIFont.Small)
    end
end

function AmazoidCatalogPanel:drawContentPage(th, pageNum)
    if not self.edition or not self.edition.pages then return end
    
    local pageData = self.edition.pages[pageNum]
    if not pageData then return end
    
    -- Start content after the poster header
    local y = th + self.headerHeight + 15
    local centerX = self.width / 2
    
    -- Page header
    local headerH = 40
    self:drawRect(0, y, self.width, headerH, 1, COLORS.bgLight.r, COLORS.bgLight.g, COLORS.bgLight.b)
    self:drawRect(0, y + headerH - 2, self.width, 2, 1, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b)
    
    -- Category title
    local title = pageData.title or "Items"
    local titleW = getTextManager():MeasureStringX(UIFont.Medium, title)
    self:drawText(title, centerX - titleW / 2, y + 10, COLORS.text.r, COLORS.text.g, COLORS.text.b, 1, UIFont.Medium)
    
    y = y + headerH + 12
    
    -- Items list
    if pageData.items then
        for i, item in ipairs(pageData.items) do
            self:drawItemEntry(y, item, i)
            y = y + ITEM_ROW_HEIGHT + 4
        end
    end
    
    -- Page number at bottom
    local pageNumText = pageNum .. " / " .. self.totalPages
    local pageNumW = getTextManager():MeasureStringX(UIFont.Small, pageNumText)
    local btnY = self.height - FONT_HGT_SMALL - 60
    self:drawText(pageNumText, centerX - pageNumW / 2, btnY, COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b, 0.7, UIFont.Small)
end

function AmazoidCatalogPanel:drawItemEntry(y, item, index)
    local x = PAGE_MARGIN
    local rowW = self.width - PAGE_MARGIN * 2
    
    local isCircled = self.circledItems[item.itemType] and self.circledItems[item.itemType] > 0
    
    -- Alternating row background (no highlight for selected)
    if index % 2 == 0 then
        self:drawRect(x, y, rowW, ITEM_ROW_HEIGHT, 0.5, COLORS.bgLight.r, COLORS.bgLight.g, COLORS.bgLight.b)
    end
    
    -- Checkbox area
    local checkX = x + 20
    local checkY = y + ITEM_ROW_HEIGHT / 2
    local checkSize = 8
    
    -- Always draw checkbox border
    self:drawRectBorder(checkX - checkSize, checkY - checkSize, checkSize * 2, checkSize * 2, 0.8, COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b)
    
    if isCircled then
        -- Draw X mark inside checkbox
        local count = self.circledItems[item.itemType]
        if count > 1 then
            -- Show count if multiple
            local countText = tostring(count)
            local countW = getTextManager():MeasureStringX(UIFont.Small, countText)
            self:drawText(countText, checkX - countW / 2, checkY - FONT_HGT_SMALL / 2, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b, 1, UIFont.Small)
        else
            -- Draw X
            self:drawText("X", checkX - 4, checkY - FONT_HGT_SMALL / 2, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b, 1, UIFont.Small)
        end
    end
    
    -- Item icon
    local iconX = x + 45
    local iconY = y + (ITEM_ROW_HEIGHT - ITEM_ICON_SIZE) / 2
    local iconTex = self:getItemIcon(item.itemType)
    if iconTex then
        self:drawTexture(iconTex, iconX, iconY, 1, 1, 1, 1)
    else
        -- Placeholder box
        self:drawRect(iconX, iconY, ITEM_ICON_SIZE, ITEM_ICON_SIZE, 0.3, COLORS.border.r, COLORS.border.g, COLORS.border.b)
    end
    
    -- Item name
    local nameX = iconX + ITEM_ICON_SIZE + 12
    self:drawText(item.name, nameX, y + 8, COLORS.text.r, COLORS.text.g, COLORS.text.b, 1, UIFont.Medium)
    
    -- Item code/type (smaller, dimmed)
    local typeShort = item.itemType:gsub("Base%.", "")
    self:drawText(typeShort, nameX, y + 8 + FONT_HGT_MEDIUM, COLORS.textDim.r, COLORS.textDim.g, COLORS.textDim.b, 0.8, UIFont.Small)
    
    -- Price (right aligned)
    local price = item.basePrice
    if Amazoid.Items and Amazoid.Items.calculateFinalPrice then
        price = Amazoid.Items.calculateFinalPrice(item.basePrice, self.reputation)
    end
    local priceText = "$" .. price
    local priceW = getTextManager():MeasureStringX(UIFont.Medium, priceText)
    local priceX = x + rowW - priceW - 15
    self:drawText(priceText, priceX, y + 12, COLORS.accent.r, COLORS.accent.g, COLORS.accent.b, 1, UIFont.Medium)
end

function AmazoidCatalogPanel:drawEllipse(cx, cy, rx, ry, r, g, b, a)
    -- Approximate ellipse with line segments
    local segments = 16
    for i = 0, segments - 1 do
        local angle1 = (i / segments) * 2 * math.pi
        local angle2 = ((i + 1) / segments) * 2 * math.pi
        local x1 = cx + rx * math.cos(angle1)
        local y1 = cy + ry * math.sin(angle1)
        local x2 = cx + rx * math.cos(angle2)
        local y2 = cy + ry * math.sin(angle2)
        self:drawLine(x1, y1, x2, y2, a, r, g, b)
    end
end

function AmazoidCatalogPanel:drawLine(x1, y1, x2, y2, a, r, g, b)
    -- Simple line approximation with small rects
    local dx = x2 - x1
    local dy = y2 - y1
    local dist = math.sqrt(dx * dx + dy * dy)
    local steps = math.max(1, math.floor(dist / 2))
    for i = 0, steps do
        local t = i / steps
        local x = x1 + dx * t
        local y = y1 + dy * t
        self:drawRect(x, y, 2, 2, a, r, g, b)
    end
end

function AmazoidCatalogPanel:getItemIcon(itemType)
    if not itemType then return nil end
    
    -- Check cache first to avoid repeated lookups every frame
    if iconCache[itemType] then
        return iconCache[itemType]
    end
    
    -- If we already tried and failed, don't try again
    if iconCacheChecked[itemType] then
        return nil
    end
    
    -- Mark as checked so we don't spam logs
    iconCacheChecked[itemType] = true
    
    -- Wrap in pcall to catch any unexpected errors
    local success, result = pcall(function()
        -- Try to get icon from script item
        local scriptItem = nil
        if ScriptManager and ScriptManager.instance and ScriptManager.instance.getItem then
            scriptItem = ScriptManager.instance:getItem(itemType)
        end
        
        if scriptItem then
            -- Try getIcon method
            if scriptItem.getIcon then
                local iconName = scriptItem:getIcon()
                if iconName then
                    -- Standard format: Item_IconName
                    local tex = getTexture("Item_" .. iconName)
                    if tex then return tex end
                    
                    -- Try without Item_ prefix (some mods use this)
                    tex = getTexture(iconName)
                    if tex then return tex end
                end
            end
            
            -- Try using the item's type name as icon (e.g., TinnedBeans)
            local typeName = itemType:gsub("Base%.", "")
            local tex = getTexture("Item_" .. typeName)
            if tex then return tex end
            
            -- For clothing items, try Clothes_ prefix
            if scriptItem.getClothingItemName and scriptItem:getClothingItemName() then
                tex = getTexture("Clothes_" .. typeName)
                if tex then return tex end
            end
        end
        
        -- Fallback: try direct type name without Base.
        local typeName = itemType:gsub("Base%.", "")
        local tex = getTexture("Item_" .. typeName)
        if tex then return tex end
        
        -- Try removing _TINT suffix for bags
        local baseTypeName = typeName:gsub("TINT$", "")
        if baseTypeName ~= typeName then
            tex = getTexture("Item_" .. baseTypeName)
            if tex then return tex end
        end
        
        -- Last resort: try creating a temporary item to get its texture
        local tempItem = instanceItem(itemType)
        if tempItem and tempItem.getTex then
            local tex = tempItem:getTex()
            if tex then return tex end
        end
        
        -- Try getTexture method as alternative
        if tempItem and tempItem.getTexture then
            local tex = tempItem:getTexture()
            if tex then return tex end
        end
        
        return nil
    end)
    
    if not success then
        print("[Amazoid] Error getting icon for: " .. tostring(itemType) .. " - " .. tostring(result))
        return nil
    end
    
    -- Cache the result (even if nil, we won't log again)
    if result then
        iconCache[itemType] = result
    end
    
    return result
end

function AmazoidCatalogPanel:onMouseDown(x, y)
    -- Check if clicking on an item row
    if self.currentPage > 0 and self.edition and self.edition.pages then
        local pageData = self.edition.pages[self.currentPage]
        if pageData and pageData.items then
            local th = self:titleBarHeight()
            -- Account for poster header + page header (40) + spacing
            local itemStartY = th + self.headerHeight + 15 + 40 + 12
            
            for i, item in ipairs(pageData.items) do
                local itemY = itemStartY + (i - 1) * (ITEM_ROW_HEIGHT + 4)
                if y >= itemY and y <= itemY + ITEM_ROW_HEIGHT then
                    self:toggleItem(item)
                    return true
                end
            end
        end
    end
    
    return ISCollapsableWindowJoypad.onMouseDown(self, x, y)
end

function AmazoidCatalogPanel:toggleItem(item)
    local currentCount = self.circledItems[item.itemType] or 0
    
    if isShiftKeyDown() then
        -- Add more
        self.circledItems[item.itemType] = currentCount + 1
    else
        -- Toggle on/off
        self.circledItems[item.itemType] = currentCount > 0 and 0 or 1
    end
    
    self:saveCircledItems()
end

-- ===== JOYPAD/CONTROLLER SUPPORT =====

function AmazoidCatalogPanel:onGainJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData)
    self.joyfocus = true
    self.joypadData = joypadData
    self.joypadItemIndex = 1
end

function AmazoidCatalogPanel:onLoseJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
    self.joyfocus = false
end

function AmazoidCatalogPanel:onJoypadDown(button, joypadData)
    if button == Joypad.BButton then
        self:close()
        return
    end
    
    if button == Joypad.LBumper then
        self:onPrevPage()
        return
    end
    
    if button == Joypad.RBumper then
        self:onNextPage()
        return
    end
    
    if self.currentPage > 0 then
        -- On content page
        if button == Joypad.AButton then
            -- Toggle item
            local pageData = self.edition and self.edition.pages and self.edition.pages[self.currentPage]
            if pageData and pageData.items and pageData.items[self.joypadItemIndex] then
                self:toggleItem(pageData.items[self.joypadItemIndex])
            end
            return
        end
        
        if button == Joypad.XButton then
            -- Add more of selected item
            local pageData = self.edition and self.edition.pages and self.edition.pages[self.currentPage]
            if pageData and pageData.items and pageData.items[self.joypadItemIndex] then
                local item = pageData.items[self.joypadItemIndex]
                self.circledItems[item.itemType] = (self.circledItems[item.itemType] or 0) + 1
                self:saveCircledItems()
            end
            return
        end
        
        if button == Joypad.YButton then
            self:onDone()
            return
        end
    else
        -- On cover page
        if button == Joypad.AButton then
            self:onNextPage()
            return
        end
    end
end

function AmazoidCatalogPanel:onJoypadDirUp(joypadData)
    if self.currentPage > 0 then
        local pageData = self.edition and self.edition.pages and self.edition.pages[self.currentPage]
        if pageData and pageData.items then
            self.joypadItemIndex = math.max(1, self.joypadItemIndex - 1)
        end
    end
end

function AmazoidCatalogPanel:onJoypadDirDown(joypadData)
    if self.currentPage > 0 then
        local pageData = self.edition and self.edition.pages and self.edition.pages[self.currentPage]
        if pageData and pageData.items then
            self.joypadItemIndex = math.min(#pageData.items, self.joypadItemIndex + 1)
        end
    end
end

function AmazoidCatalogPanel:onJoypadDirLeft(joypadData)
    self:onPrevPage()
end

function AmazoidCatalogPanel:onJoypadDirRight(joypadData)
    self:onNextPage()
end

function AmazoidCatalogPanel:getAPrompt()
    if self.currentPage == 0 then
        return "Open"
    end
    return "Circle Item"
end

function AmazoidCatalogPanel:getBPrompt()
    return getText("UI_Close") or "Close"
end

function AmazoidCatalogPanel:getXPrompt()
    if self.currentPage > 0 then
        return "Add More"
    end
    return nil
end

function AmazoidCatalogPanel:getYPrompt()
    if self.currentPage > 0 then
        return "Done"
    end
    return nil
end

function AmazoidCatalogPanel:getLBPrompt()
    return "Prev Page"
end

function AmazoidCatalogPanel:getRBPrompt()
    return "Next Page"
end

function AmazoidCatalogPanel:new(x, y, width, height, player, catalogItem, edition, reputation)
    local o = ISCollapsableWindowJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    
    o.player = player
    o.playerNum = player and player:getPlayerNum() or 0
    o.catalogItem = catalogItem
    o.edition = edition
    o.reputation = reputation or 0
    o.circledItems = {}
    o.currentPage = 0
    o.joypadItemIndex = 1
    
    o.title = edition and edition.title or "Catalog"
    o.resizable = false
    o.drawFrame = true
    
    return o
end

-- Per-player window position storage (legacy - now uses shared Amazoid.UI.sharedWindowPositions)
AmazoidCatalogPanel.savedPositions = {}

--- Static function to show the catalog
---@param player IsoPlayer The player
---@param catalogItem InventoryItem The catalog item
---@param editionId string Edition ID from AmazoidCatalogs
function AmazoidCatalogPanel.showCatalog(player, catalogItem, editionId)
    -- Get edition data
    local edition = Amazoid.Catalogs.getEdition(editionId)
    if not edition then
        print("[Amazoid] Unknown edition: " .. tostring(editionId))
        -- Fallback to basic_vol1
        edition = Amazoid.Catalogs.getEdition("basic_vol1")
    end
    
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local playerNum = player and player:getPlayerNum() or 0
    
    -- Magazine-sized window
    local width = math.min(450, screenW - 60)
    local height = math.min(600, screenH - 60)
    
    -- Use shared position storage, fall back to centered
    local x, y
    if Amazoid.UI and Amazoid.UI.getWindowPositionOrCenter then
        x, y = Amazoid.UI.getWindowPositionOrCenter(playerNum, width, height)
    else
        x = (screenW - width) / 2
        y = (screenH - height) / 2
    end
    
    local reputation = 0
    if Amazoid and Amazoid.Client and Amazoid.Client.getReputation then
        reputation = Amazoid.Client.getReputation()
    end
    
    local panel = AmazoidCatalogPanel:new(x, y, width, height, player, catalogItem, edition, reputation)
    panel.playerNum = playerNum  -- Store for saving position later
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    
    -- Set up joypad focus if using controller
    if JoypadState and JoypadState.players and JoypadState.players[playerNum + 1] then
        setJoypadFocus(playerNum, panel)
    end
    
    print("[Amazoid] Opened catalog: " .. (edition.title or "Unknown") .. " - " .. (edition.subtitle or ""))
    return panel
end

print("[Amazoid] Vintage Magazine Catalog UI loaded")
