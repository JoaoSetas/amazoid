--[[
    Amazoid - Mysterious Mailbox Merchant
    Mailbox System
    
    This file handles mailbox detection, interaction, and management.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidUtils"

Amazoid.Mailbox = Amazoid.Mailbox or {}

-- Cache of known mailboxes in loaded cells
Amazoid.Mailbox.knownMailboxes = {}

-- Mailbox sprite names to detect
Amazoid.Mailbox.mailboxSprites = {
    -- Standard mailboxes
    "location_community_mailbox_01_0",
    "location_community_mailbox_01_1",
    "location_community_mailbox_01_2",
    "location_community_mailbox_01_3",
    "location_community_mailbox_01_4",
    "location_community_mailbox_01_5",
    "location_community_mailbox_01_6",
    "location_community_mailbox_01_7",
    "location_community_mailbox_01_8",
    "location_community_mailbox_01_9",
    "location_community_mailbox_01_10",
    "location_community_mailbox_01_11",
    "location_community_mailbox_01_12",
    "location_community_mailbox_01_13",
    "location_community_mailbox_01_14",
    "location_community_mailbox_01_15",
    -- Additional mailbox sprites
    "fixtures_counters_01_24",
    "fixtures_counters_01_25",
    "fixtures_counters_01_26",
    "fixtures_counters_01_27",
    -- Post office boxes
    "location_community_mailbox_01_16",
    "location_community_mailbox_01_17",
    "location_community_mailbox_01_18",
    "location_community_mailbox_01_19",
}

-- Custom mailbox item IDs (for crafted/placed mailboxes)
Amazoid.Mailbox.customMailboxItems = {
    "Amazoid.LargeMailbox",
    "Amazoid.DeliveryCrate",
}

--- Check if an IsoObject is a mailbox
---@param object IsoObject The object to check
---@return boolean
function Amazoid.Mailbox.isMailbox(object)
    if not object then return false end
    
    -- Check sprite name
    local sprite = object:getSprite()
    if sprite then
        local spriteName = sprite:getName()
        if spriteName then
            for _, mailboxSprite in ipairs(Amazoid.Mailbox.mailboxSprites) do
                if spriteName == mailboxSprite then
                    return true
                end
            end
        end
    end
    
    -- Check if it's a container with "mailbox" in the name
    if object:getContainer() then
        local containerType = object:getContainer():getType()
        if containerType and string.lower(containerType):find("mail") then
            return true
        end
    end
    
    -- Check object name
    local objectName = object:getName()
    if objectName and string.lower(objectName):find("mail") then
        return true
    end
    
    return false
end

--- Get the mailbox type (standard, large, crate)
---@param object IsoObject The mailbox object
---@return table Mailbox type from Amazoid.MailboxTypes
function Amazoid.Mailbox.getMailboxType(object)
    if not object then
        return Amazoid.MailboxTypes.STANDARD
    end
    
    local modData = object:getModData()
    if modData and modData.AmazoidMailboxType then
        local typeId = modData.AmazoidMailboxType
        for _, mailboxType in pairs(Amazoid.MailboxTypes) do
            if mailboxType.id == typeId then
                return mailboxType
            end
        end
    end
    
    -- Check for custom placed mailboxes
    local sprite = object:getSprite()
    if sprite then
        local spriteName = sprite:getName()
        if spriteName then
            if string.find(spriteName, "large") or string.find(spriteName, "Large") then
                return Amazoid.MailboxTypes.LARGE
            elseif string.find(spriteName, "crate") or string.find(spriteName, "Crate") then
                return Amazoid.MailboxTypes.CRATE
            end
        end
    end
    
    return Amazoid.MailboxTypes.STANDARD
end

--- Set the mailbox type (for upgraded mailboxes)
---@param object IsoObject The mailbox object
---@param mailboxType table Mailbox type from Amazoid.MailboxTypes
function Amazoid.Mailbox.setMailboxType(object, mailboxType)
    if not object then return end
    
    local modData = object:getModData()
    modData.AmazoidMailboxType = mailboxType.id
    object:transmitModData()
end

--- Check if a mailbox has an Amazoid contract
---@param object IsoObject The mailbox object
---@return boolean
function Amazoid.Mailbox.hasContract(object)
    if not object then return false end
    
    local modData = object:getModData()
    return modData and modData.AmazoidContract == true
end

--- Activate Amazoid contract on a mailbox
---@param object IsoObject The mailbox object
---@param playerIndex number The player index who owns the contract
function Amazoid.Mailbox.activateContract(object, playerIndex)
    if not object then return end
    
    local modData = object:getModData()
    modData.AmazoidContract = true
    modData.AmazoidContractOwner = playerIndex
    modData.AmazoidContractTime = getGameTime():getWorldAgeHours()
    object:transmitModData()
    
    print("[Amazoid] Contract activated on mailbox for player " .. playerIndex)
end

--- Check if mailbox has discovery letter
---@param object IsoObject The mailbox object
---@return boolean
function Amazoid.Mailbox.hasDiscoveryLetter(object)
    if not object then return false end
    
    local modData = object:getModData()
    return modData and modData.AmazoidDiscoveryLetter == true
end

--- Add discovery letter to mailbox
---@param object IsoObject The mailbox object
function Amazoid.Mailbox.addDiscoveryLetter(object)
    if not object then return end
    
    local modData = object:getModData()
    modData.AmazoidDiscoveryLetter = true
    modData.AmazoidDiscoveryLetterTime = getGameTime():getWorldAgeHours()
    object:transmitModData()
    
    -- Also add the physical letter item to the container
    local container = object:getContainer()
    if container then
        local item = InventoryItemFactory.CreateItem("Amazoid.DiscoveryLetter")
        if item then
            container:addItem(item)
        else
            print("[Amazoid] Warning: Could not create DiscoveryLetter item")
        end
    end
    
    print("[Amazoid] Discovery letter added to mailbox")
end

--- Remove discovery letter from mailbox
---@param object IsoObject The mailbox object
function Amazoid.Mailbox.removeDiscoveryLetter(object)
    if not object then return end
    
    local modData = object:getModData()
    modData.AmazoidDiscoveryLetter = false
    object:transmitModData()
end

--- Get pending orders for a mailbox
---@param object IsoObject The mailbox object
---@return table List of pending orders
function Amazoid.Mailbox.getPendingOrders(object)
    if not object then return {} end
    
    local modData = object:getModData()
    return modData.AmazoidPendingOrders or {}
end

--- Add a pending order to mailbox
---@param object IsoObject The mailbox object
---@param order table Order data
function Amazoid.Mailbox.addPendingOrder(object, order)
    if not object then return end
    
    local modData = object:getModData()
    modData.AmazoidPendingOrders = modData.AmazoidPendingOrders or {}
    table.insert(modData.AmazoidPendingOrders, order)
    object:transmitModData()
    
    print("[Amazoid] Order added to mailbox: " .. order.id)
end

--- Process pending orders (called periodically)
---@param object IsoObject The mailbox object
function Amazoid.Mailbox.processOrders(object)
    if not object then return end
    
    local modData = object:getModData()
    local orders = modData.AmazoidPendingOrders or {}
    local currentTime = getGameTime():getWorldAgeHours()
    local container = object:getContainer()
    
    if not container then return end
    
    local completedOrders = {}
    
    for i, order in ipairs(orders) do
        local orderAge = currentTime - order.orderTime
        
        if orderAge >= order.deliveryTime and order.status == "pending" then
            -- Deliver the order
            for _, itemData in ipairs(order.items) do
                for j = 1, (itemData.count or 1) do
                    local item = container:AddItem(itemData.itemType)
                    if item then
                        print("[Amazoid] Delivered item: " .. itemData.itemType)
                    end
                end
            end
            
            order.status = "delivered"
            order.deliveredAt = currentTime
            table.insert(completedOrders, i)
            
            -- Add delivery notification letter
            container:AddItem("Amazoid.DeliveryNoteLetter")
        end
    end
    
    -- Remove completed orders
    for i = #completedOrders, 1, -1 do
        table.remove(orders, completedOrders[i])
    end
    
    modData.AmazoidPendingOrders = orders
    object:transmitModData()
end

--- Get the location key for a mailbox
---@param object IsoObject The mailbox object
---@return string Location key "x_y_z"
function Amazoid.Mailbox.getLocationKey(object)
    if not object then return "0_0_0" end
    
    local x = object:getX()
    local y = object:getY()
    local z = object:getZ()
    
    return x .. "_" .. y .. "_" .. z
end

--- Find mailboxes in a cell
---@param cell IsoCell The cell to search
---@return table List of mailbox objects
function Amazoid.Mailbox.findMailboxesInCell(cell)
    local mailboxes = {}
    
    if not cell then return mailboxes end
    
    local gridWidth = cell:getWidth()
    local gridHeight = cell:getHeight()
    
    for x = 0, gridWidth - 1 do
        for y = 0, gridHeight - 1 do
            for z = 0, 7 do
                local square = cell:getGridSquare(x, y, z)
                if square then
                    local objects = square:getObjects()
                    for i = 0, objects:size() - 1 do
                        local obj = objects:get(i)
                        if Amazoid.Mailbox.isMailbox(obj) then
                            table.insert(mailboxes, obj)
                        end
                    end
                end
            end
        end
    end
    
    return mailboxes
end

--- Find mailbox at specific location
---@param x number X coordinate
---@param y number Y coordinate
---@param z number Z coordinate
---@return IsoObject|nil Mailbox object or nil
function Amazoid.Mailbox.findMailboxAt(x, y, z)
    local square = getCell():getGridSquare(x, y, z)
    if not square then return nil end
    
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if Amazoid.Mailbox.isMailbox(obj) then
            return obj
        end
    end
    
    return nil
end

--- Find nearest mailbox to player
---@param player IsoPlayer The player
---@param maxDistance number Maximum search distance
---@return IsoObject|nil Nearest mailbox or nil
function Amazoid.Mailbox.findNearestMailbox(player, maxDistance)
    if not player then return nil end
    
    maxDistance = maxDistance or 50
    local playerX = player:getX()
    local playerY = player:getY()
    local playerZ = player:getZ()
    
    local nearestMailbox = nil
    local nearestDistance = maxDistance + 1
    
    -- Search in a square around player
    for x = playerX - maxDistance, playerX + maxDistance do
        for y = playerY - maxDistance, playerY + maxDistance do
            local square = getCell():getGridSquare(x, y, playerZ)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    if Amazoid.Mailbox.isMailbox(obj) then
                        local distance = math.sqrt((x - playerX)^2 + (y - playerY)^2)
                        if distance < nearestDistance then
                            nearestDistance = distance
                            nearestMailbox = obj
                        end
                    end
                end
            end
        end
    end
    
    return nearestMailbox
end

--- Get money amount in mailbox container
---@param object IsoObject The mailbox object
---@return number Total money value
function Amazoid.Mailbox.getMoneyInMailbox(object)
    if not object then return 0 end
    
    local container = object:getContainer()
    if not container then return 0 end
    
    local total = 0
    local items = container:getItems()
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local itemType = item:getFullType()
        
        -- Check for money items
        if itemType == "Base.Money" then
            total = total + 1
        elseif itemType == "Base.MoneyStack" then
            -- Money stacks might have different values
            total = total + (item:getModData().value or 10)
        end
    end
    
    return total
end

--- Remove money from mailbox container
---@param object IsoObject The mailbox object
---@param amount number Amount to remove
---@return number Amount actually removed
function Amazoid.Mailbox.removeMoneyFromMailbox(object, amount)
    if not object then return 0 end
    
    local container = object:getContainer()
    if not container then return 0 end
    
    local removed = 0
    local items = container:getItems()
    local toRemove = {}
    
    for i = 0, items:size() - 1 do
        if removed >= amount then break end
        
        local item = items:get(i)
        local itemType = item:getFullType()
        
        if itemType == "Base.Money" then
            table.insert(toRemove, item)
            removed = removed + 1
        elseif itemType == "Base.MoneyStack" then
            local value = item:getModData().value or 10
            table.insert(toRemove, item)
            removed = removed + value
        end
    end
    
    -- Remove items
    for _, item in ipairs(toRemove) do
        container:Remove(item)
    end
    
    return removed
end

print("[Amazoid] Mailbox system loaded")
