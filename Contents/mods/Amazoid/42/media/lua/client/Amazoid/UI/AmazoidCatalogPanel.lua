--[[
    Amazoid - Mysterious Mailbox Merchant
    Catalog UI
    
    This file contains the UI for browsing and ordering from catalogs.
]]

require "Amazoid/UI/AmazoidBasePanel"
require "Amazoid/AmazoidItems"
require "Amazoid/AmazoidData"

---@class AmazoidCatalogPanel : AmazoidBasePanel
AmazoidCatalogPanel = AmazoidBasePanel:derive("AmazoidCatalogPanel")

function AmazoidCatalogPanel:createChildren()
    AmazoidBasePanel.createChildren(self)
    
    local y = 35
    local padding = 10
    local leftPanelWidth = 150
    
    -- Player reputation display
    self.repLabel = ISLabel:new(padding, y, 20, "Reputation: " .. self.reputation, 1, 1, 0.5, 1, UIFont.Small, true)
    self:addChild(self.repLabel)
    
    -- Discount display
    local discount = math.floor(Amazoid.Utils.calculateDiscount(self.reputation) * 100)
    self.discountLabel = ISLabel:new(padding + 150, y, 20, "Discount: " .. discount .. "%", 0.5, 1, 0.5, 1, UIFont.Small, true)
    self:addChild(self.discountLabel)
    
    y = y + 25
    
    -- Category list (left panel)
    self.categoryList = ISScrollingListBox:new(padding, y, leftPanelWidth, self.height - y - 100)
    self.categoryList:initialise()
    self.categoryList:instantiate()
    self.categoryList.itemheight = 30
    self.categoryList.backgroundColor = {r=0.15, g=0.15, b=0.2, a=0.9}
    self.categoryList.borderColor = {r=0.4, g=0.4, b=0.5, a=1}
    self.categoryList:setOnMouseDownFunction(self, AmazoidCatalogPanel.onSelectCategory)
    self:addChild(self.categoryList)
    
    -- Populate categories
    self:populateCategories()
    
    -- Items list (center panel)
    local itemsX = padding + leftPanelWidth + 10
    local itemsWidth = self.width - itemsX - padding
    
    self.itemsList = ISScrollingListBox:new(itemsX, y, itemsWidth, self.height - y - 100)
    self.itemsList:initialise()
    self.itemsList:instantiate()
    self.itemsList.itemheight = 40
    self.itemsList.backgroundColor = {r=0.15, g=0.15, b=0.2, a=0.9}
    self.itemsList.borderColor = {r=0.4, g=0.4, b=0.5, a=1}
    self.itemsList:setOnMouseDownFunction(self, AmazoidCatalogPanel.onSelectItem)
    self.itemsList.doDrawItem = AmazoidCatalogPanel.drawItemRow
    self.itemsList.parent = self
    self:addChild(self.itemsList)
    
    -- Cart section (bottom)
    local cartY = self.height - 90
    
    self.cartLabel = ISLabel:new(padding, cartY, 20, "Cart:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.cartLabel)
    
    self.cartTotalLabel = ISLabel:new(padding + 50, cartY, 20, "Total: $0", 1, 1, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.cartTotalLabel)
    
    -- Add to cart button
    self.addToCartBtn = ISButton:new(self.width - 260, cartY - 5, 120, 30, "Add to Cart", self, AmazoidCatalogPanel.onAddToCart)
    self.addToCartBtn:initialise()
    self.addToCartBtn:instantiate()
    self.addToCartBtn.enable = false
    self:addChild(self.addToCartBtn)
    
    -- Place order button
    self.orderBtn = ISButton:new(self.width - 130, cartY - 5, 120, 30, "Place Order", self, AmazoidCatalogPanel.onPlaceOrder)
    self.orderBtn:initialise()
    self.orderBtn:instantiate()
    self.orderBtn.enable = false
    self.orderBtn.backgroundColor = {r=0.2, g=0.4, b=0.2, a=0.8}
    self.orderBtn.backgroundColorMouseOver = {r=0.3, g=0.6, b=0.3, a=1}
    self:addChild(self.orderBtn)
    
    -- Clear cart button
    self.clearCartBtn = ISButton:new(padding, cartY + 25, 80, 25, "Clear", self, AmazoidCatalogPanel.onClearCart)
    self.clearCartBtn:initialise()
    self.clearCartBtn:instantiate()
    self:addChild(self.clearCartBtn)
    
    -- Cart items label
    self.cartItemsLabel = ISLabel:new(padding + 90, cartY + 28, 20, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.cartItemsLabel)
    
    -- Initialize cart
    self.cart = {}
    self.cartTotal = 0
    self.selectedCategory = nil
    self.selectedItem = nil
end

function AmazoidCatalogPanel:populateCategories()
    self.categoryList:clear()
    
    local categories = {
        {id = Amazoid.CatalogCategories.BASIC, name = "Basic Supplies", rep = Amazoid.Reputation.CATALOG_BASIC},
        {id = Amazoid.CatalogCategories.TOOLS, name = "Tools", rep = Amazoid.Reputation.CATALOG_TOOLS},
        {id = Amazoid.CatalogCategories.WEAPONS, name = "Weapons", rep = Amazoid.Reputation.CATALOG_WEAPONS},
        {id = Amazoid.CatalogCategories.MEDICAL, name = "Medical", rep = Amazoid.Reputation.CATALOG_MEDICAL},
        {id = Amazoid.CatalogCategories.SEASONAL, name = "Seasonal", rep = Amazoid.Reputation.CATALOG_SEASONAL},
        {id = Amazoid.CatalogCategories.BLACKMARKET, name = "Black Market", rep = Amazoid.Reputation.CATALOG_BLACKMARKET},
    }
    
    for _, cat in ipairs(categories) do
        local unlocked = self.reputation >= cat.rep
        local displayName = cat.name
        if not unlocked then
            displayName = displayName .. " (Rep " .. cat.rep .. ")"
        end
        
        self.categoryList:addItem(displayName, {
            id = cat.id,
            unlocked = unlocked,
            requiredRep = cat.rep,
        })
    end
end

function AmazoidCatalogPanel:onSelectCategory(item)
    if not item then return end
    
    local data = item.item
    if not data.unlocked then
        -- Show locked message
        return
    end
    
    self.selectedCategory = data.id
    self:populateItems()
end

function AmazoidCatalogPanel:populateItems()
    self.itemsList:clear()
    self.selectedItem = nil
    self.addToCartBtn.enable = false
    
    if not self.selectedCategory then return end
    
    local items = {}
    
    if self.selectedCategory == Amazoid.CatalogCategories.BASIC then
        items = Amazoid.Items.BasicCatalog
    elseif self.selectedCategory == Amazoid.CatalogCategories.TOOLS then
        items = Amazoid.Items.ToolsCatalog
    elseif self.selectedCategory == Amazoid.CatalogCategories.WEAPONS then
        items = Amazoid.Items.WeaponsCatalog
    elseif self.selectedCategory == Amazoid.CatalogCategories.MEDICAL then
        items = Amazoid.Items.MedicalCatalog
    elseif self.selectedCategory == Amazoid.CatalogCategories.SEASONAL then
        local season = Amazoid.Utils.getCurrentSeason()
        items = Amazoid.Items.SeasonalCatalogs[season] or {}
    elseif self.selectedCategory == Amazoid.CatalogCategories.BLACKMARKET then
        items = Amazoid.Items.BlackMarketCatalog
    end
    
    for _, item in ipairs(items) do
        local finalPrice = Amazoid.Items.calculateFinalPrice(item.basePrice, self.reputation)
        local mailboxType = self:getMailboxTypeForSize(item.size)
        
        self.itemsList:addItem(item.name, {
            itemData = item,
            finalPrice = finalPrice,
            mailboxType = mailboxType,
        })
    end
end

function AmazoidCatalogPanel:getMailboxTypeForSize(size)
    if size <= 1 then
        return Amazoid.MailboxTypes.STANDARD
    elseif size <= 2 then
        return Amazoid.MailboxTypes.LARGE
    else
        return Amazoid.MailboxTypes.CRATE
    end
end

function AmazoidCatalogPanel.drawItemRow(self, y, item, alt)
    local data = item.item
    if not data then return y + self.itemheight end
    
    local panel = self.parent
    
    -- Background
    if self.selected == item.index then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.3, 0.5, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0.1, 0.1, 0.1)
    end
    
    -- Item name
    self:drawText(data.itemData.name, 10, y + 5, 1, 1, 1, 1, UIFont.Small)
    
    -- Price
    local priceText = "$" .. data.finalPrice
    self:drawText(priceText, self.width - 100, y + 5, 0.5, 1, 0.5, 1, UIFont.Small)
    
    -- Mailbox requirement
    local mbText = data.mailboxType.name
    local mbColor = {r=0.7, g=0.7, b=0.7}
    if data.mailboxType.id ~= "standard" then
        mbColor = {r=1, g=0.7, b=0.3}
    end
    self:drawText(mbText, 10, y + 22, mbColor.r, mbColor.g, mbColor.b, 1, UIFont.Small)
    
    return y + self.itemheight
end

function AmazoidCatalogPanel:onSelectItem(item)
    if not item then return end
    
    self.selectedItem = item.item
    self.addToCartBtn.enable = true
end

function AmazoidCatalogPanel:onAddToCart()
    if not self.selectedItem then return end
    
    table.insert(self.cart, {
        itemType = self.selectedItem.itemData.itemType,
        name = self.selectedItem.itemData.name,
        price = self.selectedItem.finalPrice,
        size = self.selectedItem.itemData.size,
        count = 1,
    })
    
    self:updateCart()
end

function AmazoidCatalogPanel:onClearCart()
    self.cart = {}
    self:updateCart()
end

function AmazoidCatalogPanel:updateCart()
    self.cartTotal = 0
    local itemNames = {}
    
    for _, item in ipairs(self.cart) do
        self.cartTotal = self.cartTotal + item.price
        table.insert(itemNames, item.name)
    end
    
    self.cartTotalLabel:setName("Total: $" .. self.cartTotal)
    self.cartItemsLabel:setName(table.concat(itemNames, ", "))
    
    self.orderBtn.enable = #self.cart > 0
end

function AmazoidCatalogPanel:onPlaceOrder()
    if #self.cart == 0 then return end
    
    -- Check if player has enough money in mailbox
    local moneyInMailbox = 0
    if self.mailbox then
        moneyInMailbox = Amazoid.Mailbox.getMoneyInMailbox(self.mailbox)
    end
    
    -- For now, just place the order (payment validation can be added later)
    local order = {
        id = ZombRand(100000, 999999),
        items = {},
        totalPrice = self.cartTotal,
        orderTime = getGameTime():getWorldAgeHours(),
        deliveryTime = Amazoid.Utils.calculateDeliveryTime(self.reputation, false),
        status = "pending",
    }
    
    for _, item in ipairs(self.cart) do
        table.insert(order.items, {
            itemType = item.itemType,
            name = item.name,
            count = item.count,
        })
    end
    
    -- Add order to mailbox
    if self.mailbox then
        Amazoid.Mailbox.addPendingOrder(self.mailbox, order)
        
        -- Try to take money from mailbox
        local removed = Amazoid.Mailbox.removeMoneyFromMailbox(self.mailbox, self.cartTotal)
        local difference = removed - self.cartTotal
        
        -- Calculate reputation change
        if Amazoid.Client then
            local repChange = Amazoid.Utils.calculatePaymentReputation(self.cartTotal, removed)
            Amazoid.Client.modifyReputation(repChange)
        end
    end
    
    -- Clear cart
    self.cart = {}
    self:updateCart()
    
    -- Show confirmation
    local hours = order.deliveryTime
    print("[Amazoid] Order placed! Delivery in approximately " .. hours .. " hours.")
    
    self:onClose()
end

function AmazoidCatalogPanel:new(x, y, width, height, player, mailbox, reputation)
    local o = AmazoidBasePanel:new(x, y, width, height, "Amazoid Catalog")
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.mailbox = mailbox
    o.reputation = reputation or 0
    return o
end

--- Static function to show the catalog
---@param player IsoPlayer The player
---@param mailbox IsoObject The mailbox object
function AmazoidCatalogPanel.showCatalog(player, mailbox)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = 600
    local height = 500
    local x = (screenW - width) / 2
    local y = (screenH - height) / 2
    
    local reputation = 0
    if Amazoid.Client then
        reputation = Amazoid.Client.getReputation()
    end
    
    local panel = AmazoidCatalogPanel:new(x, y, width, height, player, mailbox, reputation)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    
    return panel
end

print("[Amazoid] Catalog UI loaded")
