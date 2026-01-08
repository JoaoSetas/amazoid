--[[
    Amazoid - Mysterious Mailbox Merchant
    Context Menu Integration
    
    This file adds Amazoid options to mailbox context menus.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidMailbox"
require "Amazoid/AmazoidLetters"
require "Amazoid/UI/AmazoidLetterPanel"
require "Amazoid/UI/AmazoidCatalogPanel"
require "Amazoid/UI/AmazoidMissionsPanel"

Amazoid.ContextMenu = Amazoid.ContextMenu or {}

--- Add Amazoid options to world object context menu
---@param player number Player index
---@param context ISContextMenu The context menu
---@param worldObjects table List of world objects
---@param test boolean Test mode
local function onFillWorldObjectContextMenu(player, context, worldObjects, test)
    if test then return end
    
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end
    
    -- Find mailbox in clicked objects
    local mailbox = nil
    for _, obj in ipairs(worldObjects) do
        if Amazoid.Mailbox.isMailbox(obj) then
            mailbox = obj
            break
        end
    end
    
    if not mailbox then return end
    
    -- Check distance
    local distance = playerObj:DistToSquared(mailbox:getX(), mailbox:getY())
    if distance > 4 then return end -- Must be close enough
    
    -- Create Amazoid submenu
    local amazoidOption = context:addOption("Amazoid Services", worldObjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(amazoidOption, subMenu)
    
    -- Check if mailbox has discovery letter
    if Amazoid.Mailbox.hasDiscoveryLetter(mailbox) then
        subMenu:addOption("Read Discovery Letter", mailbox, Amazoid.ContextMenu.onReadDiscoveryLetter, playerObj)
    end
    
    -- Check if mailbox has active contract
    if Amazoid.Mailbox.hasContract(mailbox) then
        -- Full service menu
        subMenu:addOption("View Catalog", mailbox, Amazoid.ContextMenu.onViewCatalog, playerObj)
        subMenu:addOption("View Missions", mailbox, Amazoid.ContextMenu.onViewMissions, playerObj)
        subMenu:addOption("Check Order Status", mailbox, Amazoid.ContextMenu.onCheckOrderStatus, playerObj)
        subMenu:addOption("Check for Mail", mailbox, Amazoid.ContextMenu.onCheckMail, playerObj)
        
        -- Show reputation
        local reputation = 0
        if Amazoid.Client then
            reputation = Amazoid.Client.getReputation()
        end
        local repOption = subMenu:addOption("Reputation: " .. reputation, nil, nil)
        repOption.notAvailable = true
    else
        if not Amazoid.Mailbox.hasDiscoveryLetter(mailbox) then
            local noServiceOption = subMenu:addOption("No service available here", nil, nil)
            noServiceOption.notAvailable = true
        end
    end
end

--- Read discovery letter action
---@param mailbox IsoObject The mailbox
---@param player IsoPlayer The player
function Amazoid.ContextMenu.onReadDiscoveryLetter(mailbox, player)
    local letterData = Amazoid.Letters.getDiscoveryLetter()
    
    -- Check if player has the letter item in inventory or mailbox
    local container = mailbox:getContainer()
    local letterItem = nil
    
    if container then
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item:getFullType() == "Amazoid.DiscoveryLetter" then
                letterItem = item
                break
            end
        end
    end
    
    AmazoidLetterPanel.showLetter(player, letterData, true, mailbox, letterItem)
end

--- View catalog action
---@param mailbox IsoObject The mailbox
---@param player IsoPlayer The player
function Amazoid.ContextMenu.onViewCatalog(mailbox, player)
    AmazoidCatalogPanel.showCatalog(player, mailbox)
end

--- View missions action
---@param mailbox IsoObject The mailbox
---@param player IsoPlayer The player
function Amazoid.ContextMenu.onViewMissions(mailbox, player)
    AmazoidMissionsPanel.showMissions(player)
end

--- Check order status action
---@param mailbox IsoObject The mailbox
---@param player IsoPlayer The player
function Amazoid.ContextMenu.onCheckOrderStatus(mailbox, player)
    local orders = Amazoid.Mailbox.getPendingOrders(mailbox)
    
    if #orders == 0 then
        player:Say("No pending orders.")
        return
    end
    
    local currentTime = getGameTime():getWorldAgeHours()
    
    for _, order in ipairs(orders) do
        local timeRemaining = order.deliveryTime - (currentTime - order.orderTime)
        if timeRemaining > 0 then
            player:Say("Order #" .. order.id .. ": " .. math.ceil(timeRemaining) .. " hours remaining")
        else
            player:Say("Order #" .. order.id .. ": Ready for pickup!")
        end
    end
end

--- Check for mail action
---@param mailbox IsoObject The mailbox
---@param player IsoPlayer The player
function Amazoid.ContextMenu.onCheckMail(mailbox, player)
    -- Process any pending orders that should be delivered
    Amazoid.Mailbox.processOrders(mailbox)
    
    local container = mailbox:getContainer()
    if not container then
        player:Say("Mailbox is empty.")
        return
    end
    
    local itemCount = container:getItems():size()
    if itemCount > 0 then
        player:Say("Found " .. itemCount .. " item(s) in the mailbox.")
    else
        player:Say("Mailbox is empty.")
    end
end

-- Register event
Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)

--- Add Amazoid read option to letter items in inventory
---@param player number Player index
---@param context ISContextMenu The context menu
---@param items table List of inventory items
local function onFillInventoryObjectContextMenu(player, context, items)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end
    
    -- Find Amazoid letter items
    for _, itemStack in ipairs(items) do
        local item = itemStack
        if type(itemStack) == "table" then
            item = itemStack.items[1]
        end
        
        if item and item:getFullType() then
            local itemType = item:getFullType()
            
            -- Letters
            if itemType == "Amazoid.DiscoveryLetter" then
                context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj, "discovery")
            elseif itemType == "Amazoid.SignedContract" then
                context:addOption("Read Contract", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj, "contract")
            elseif itemType == "Amazoid.MissionLetter" then
                context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj, "mission")
            elseif itemType == "Amazoid.LoreLetter" then
                context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj, "lore")
            elseif itemType == "Amazoid.DeliveryNoteLetter" then
                context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj, "delivery")
            elseif itemType == "Amazoid.GiftLetter" then
                context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj, "gift")
            -- Catalogs
            elseif itemType == "Amazoid.BasicCatalog" then
                context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj, "basic")
            elseif itemType == "Amazoid.ToolsCatalog" then
                context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj, "tools")
            elseif itemType == "Amazoid.WeaponsCatalog" then
                context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj, "weapons")
            elseif itemType == "Amazoid.MedicalCatalog" then
                context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj, "medical")
            elseif itemType == "Amazoid.SeasonalCatalog" then
                context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj, "seasonal")
            elseif itemType == "Amazoid.BlackMarketCatalog" then
                context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj, "blackmarket")
            end
        end
    end
end

--- Read inventory letter action
---@param item InventoryItem The letter item
---@param player IsoPlayer The player
---@param letterType string Type of letter
function Amazoid.ContextMenu.onReadInventoryLetter(item, player, letterType)
    local letterData = nil
    local isDiscovery = false
    
    if letterType == "discovery" then
        letterData = Amazoid.Letters.getDiscoveryLetter()
        isDiscovery = true
    elseif letterType == "contract" then
        letterData = {
            title = "Signed Contract",
            content = "This contract binds you to the Amazoid service.\n\nYou have agreed to the Terms of Service and may now access all merchant services through designated mailboxes.\n\nYour reputation will determine your discount rates and access to premium catalogs.\n\nRemember: We always deliver.\n\n- The Merchants"
        }
    elseif letterType == "delivery" then
        letterData = {
            title = "Delivery Confirmation",
            content = "Your order has been delivered.\n\nThank you for your business.\n\n- The Merchants"
        }
    elseif letterType == "gift" then
        letterData = Amazoid.Letters.Gifts.SurviveDays -- Default gift letter
    else
        -- Get from item mod data if available
        local modData = item:getModData()
        if modData.AmazoidLetterData then
            letterData = modData.AmazoidLetterData
        else
            letterData = {
                title = "Letter",
                content = "A letter from the merchants."
            }
        end
    end
    
    if letterData then
        -- For discovery letter, need to find nearby mailbox
        local mailbox = nil
        if isDiscovery then
            mailbox = Amazoid.Mailbox.findNearestMailbox(player, 5)
        end
        
        AmazoidLetterPanel.showLetter(player, letterData, isDiscovery, mailbox, item)
    end
end

--- Browse catalog action
---@param item InventoryItem The catalog item
---@param player IsoPlayer The player
---@param catalogType string Type of catalog
function Amazoid.ContextMenu.onBrowseCatalog(item, player, catalogType)
    -- For now, just show a message - full catalog UI coming later
    player:Say("Browsing " .. catalogType .. " catalog...")
    
    -- TODO: Open full catalog UI with the appropriate category
    -- AmazoidCatalogPanel.showCatalog(player, nil, catalogType)
end

-- Register inventory context menu event
Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)

print("[Amazoid] Context menu integration loaded")
