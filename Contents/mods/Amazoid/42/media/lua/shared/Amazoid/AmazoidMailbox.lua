--[[
    Amazoid - Mysterious Mailbox Merchant
    Mailbox System

    This file handles mailbox detection, interaction, and management.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidUtils"
require "Amazoid/AmazoidMissions"
require "Amazoid/AmazoidEvents"

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
-- Note: These are items that can act as mailboxes when placed
Amazoid.Mailbox.customMailboxItems = {
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
            -- Also check for street_decoration mailboxes
            if spriteName:find("street_decoration") then
                -- Check if it has a postbox container to confirm it's a mailbox
                if object:getContainer() then
                    local containerType = object:getContainer():getType()
                    if containerType and string.lower(containerType):find("postbox") then
                        return true
                    end
                end
            end
        end
    end

    -- Check if it's a container with "mailbox" or "postbox" in the name
    if object:getContainer() then
        local containerType = string.lower(object:getContainer():getType() or "")
        if containerType:find("mail") or containerType:find("postbox") then
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

--- Check for signed contract in mailbox and activate if found
--- This allows players to activate a mailbox by placing a signed contract in it
---@param object IsoObject The mailbox object
---@return boolean Whether a contract was found and activated
function Amazoid.Mailbox.checkForSignedContract(object)
    if not object then return false end

    -- Already has contract? Skip
    if Amazoid.Mailbox.hasContract(object) then return false end

    local container = object:getContainer()
    if not container then return false end

    local items = container:getItems()

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getFullType() == "Amazoid.SignedContract" then
            -- Found a signed contract - activate this mailbox
            -- In split-screen, use first available local player
            local players = IsoPlayer.getPlayers()
            local player = players and players:size() > 0 and players:get(0) or nil
            local playerIndex = player and player:getPlayerNum() or 0

            -- Activate contract on mailbox
            Amazoid.Mailbox.activateContract(object, playerIndex)

            -- Update player data with this mailbox location
            local location = {
                x = object:getX(),
                y = object:getY(),
                z = object:getZ()
            }

            -- Update modData for all local players (split-screen support)
            if players then
                for pi = 0, players:size() - 1 do
                    local p = players:get(pi)
                    if p then
                        local data = p:getModData().Amazoid or {}
                        data.hasContract = true
                        data.contractMailbox = location
                        p:getModData().Amazoid = data
                    end
                end
            end

            -- Also update Amazoid.Client cache
            if Amazoid.Client and Amazoid.Client.playerData then
                Amazoid.Client.playerData.hasContract = true
                Amazoid.Client.playerData.contractMailbox = location
                Amazoid.Client.playerData.contractStatus = Amazoid.ContractStatus.ACTIVE
                Amazoid.Client.savePlayerData()
            end

            print("[Amazoid] Contract activated from signed contract item at " ..
                location.x .. "," .. location.y .. "," .. location.z)
            return true
        end
    end

    return false
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
        -- Use instanceItem (Build 42 method)
        local item = instanceItem("Amazoid.DiscoveryLetter")
        if item then
            -- Set literatureTitle for "already read" tracking
            local itemModData = item:getModData()
            itemModData.literatureTitle = "Amazoid_DiscoveryLetter"
            container:addItem(item)
        else
            -- Fallback to container:AddItem
            container:AddItem("Amazoid.DiscoveryLetter")
        end

        -- Also add a starter catalog (basic_vol1)
        local catalog = instanceItem("Amazoid.Catalog")
        if catalog then
            local catalogModData = catalog:getModData()
            catalogModData.AmazoidEdition = "basic_vol1"
            catalogModData.AmazoidCatalogType = "basic"
            catalogModData.AmazoidCircled = {}
            catalog:setName("Amazoid Essentials - Vol. I")
            container:addItem(catalog)
        else
            container:AddItem("Amazoid.Catalog")
        end

        -- Add the first mission letter
        Amazoid.Mailbox.addFirstMission(object)
    end

    print("[Amazoid] Discovery letter, starter catalog, and first mission added to mailbox")
end

--- Add first mission letter to mailbox
---@param object IsoObject The mailbox object
function Amazoid.Mailbox.addFirstMission(object)
    if not object then return end

    local container = object:getContainer()
    if not container then return end

    -- Generate the first mission
    local mission = Amazoid.Missions.generateFirstMission()

    -- Store mission in mailbox modData for tracking
    local modData = object:getModData()
    modData.AmazoidPendingMission = mission
    object:transmitModData()

    -- Get next mission number
    local globalData = ModData.getOrCreate("Amazoid")
    globalData.missionLetterCount = (globalData.missionLetterCount or 0) + 1
    local missionNumber = globalData.missionLetterCount

    -- Set missionNumber on mission BEFORE serializing
    mission.missionNumber = missionNumber

    -- Create mission letter
    local letter = instanceItem("Amazoid.MerchantLetter")
    if letter then
        local letterModData = letter:getModData()
        letterModData.AmazoidLetterType = "mission"
        -- Serialize mission data to flatten nested tables for reliable modData storage
        letterModData.AmazoidMission = Amazoid.Missions.serializeForModData(mission)
        letterModData.literatureTitle = "Amazoid_Mission_" .. mission.id
        letterModData.AmazoidMissionNumber = missionNumber
        letter:setName("Mission #" .. missionNumber .. " - First Task")
        container:addItem(letter)
        print("[Amazoid] First mission letter added: " .. mission.title)
    end
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
--- Creates delivery packages with ordered items inside
--- Places package in mailbox or next to it if too large
---@param object IsoObject The mailbox object
---@return number Number of orders delivered
function Amazoid.Mailbox.processOrders(object)
    if not object then return 0 end

    local modData = object:getModData()
    local orders = modData.AmazoidPendingOrders or {}
    local currentTime = getGameTime():getWorldAgeHours()
    local container = object:getContainer()

    if not container then return 0 end

    local completedOrders = {}

    for i, order in ipairs(orders) do
        local orderAge = currentTime - order.orderTime

        if orderAge >= order.deliveryTime and order.status == "pending" then
            -- Calculate total weight and determine package size
            local totalWeight = 0
            for _, itemData in ipairs(order.items) do
                local count = itemData.count or 1
                local itemWeight = itemData.weight or 1
                totalWeight = totalWeight + (itemWeight * count)
            end

            -- Choose package type based on total weight
            local packageType
            if totalWeight <= 5 then
                packageType = "Amazoid.DeliveryPackageSmall"
            elseif totalWeight <= 15 then
                packageType = "Amazoid.DeliveryPackageMedium"
            elseif totalWeight <= 30 then
                packageType = "Amazoid.DeliveryPackageLarge"
            else
                packageType = "Amazoid.DeliveryCrate"
            end

            -- Create the package
            local package = instanceItem(packageType)
            if package then
                local packageContainer = package:getItemContainer()

                if packageContainer then
                    -- Add all ordered items to the package
                    for _, itemData in ipairs(order.items) do
                        for j = 1, (itemData.count or 1) do
                            local item = instanceItem(itemData.itemType)
                            if item then
                                packageContainer:addItem(item)
                                print("[Amazoid] Added to package: " .. itemData.itemType)
                            end
                        end
                    end

                    -- Try to add package to mailbox first - check capacity
                    local mailboxContainer = object:getContainer()

                    -- Get package weight (including contents)
                    -- Use getContentsWeight on package container + package base weight
                    local packageBaseWeight = package:getWeight() or 0.5
                    local packageContentsWeight = packageContainer:getCapacityWeight() or 0
                    local packageTotalWeight = packageBaseWeight + packageContentsWeight

                    -- Get mailbox capacity using both methods for safety
                    local mailboxCapacity = mailboxContainer:getCapacity()
                    local mailboxMaxWeight = mailboxContainer:getMaxWeight()
                    -- Use the smaller of the two as the actual limit
                    local actualCapacity = math.min(mailboxCapacity or 999, mailboxMaxWeight or 999)
                    local mailboxContentsWeight = mailboxContainer:getCapacityWeight()

                    print("[Amazoid] Package weight: " ..
                        packageTotalWeight ..
                        " (base=" .. packageBaseWeight .. ", contents=" .. packageContentsWeight .. ")")
                    print("[Amazoid] Mailbox capacity: " ..
                        actualCapacity ..
                        " (getCapacity=" ..
                        tostring(mailboxCapacity) ..
                        ", getMaxWeight=" ..
                        tostring(mailboxMaxWeight) .. "), Current contents: " .. mailboxContentsWeight)

                    if (mailboxContentsWeight + packageTotalWeight) <= actualCapacity then
                        -- Package fits in mailbox
                        mailboxContainer:addItem(package)
                        print("[Amazoid] Package delivered to mailbox")
                    else
                        -- Package doesn't fit - place on ground near mailbox
                        -- Try adjacent squares first, then fallback to mailbox square
                        local mailboxSquare = object:getSquare()
                        local placed = false

                        if mailboxSquare then
                            -- Try random adjacent squares
                            local adjacentOffsets = {
                                { x = 1, y = 0 }, { x = -1, y = 0 }, { x = 0, y = 1 }, { x = 0, y = -1 },
                                { x = 1, y = 1 }, { x = 1, y = -1 }, { x = -1, y = 1 }, { x = -1, y = -1 }
                            }
                            -- Shuffle the offsets for randomness
                            for i = #adjacentOffsets, 2, -1 do
                                local j = ZombRand(i) + 1
                                adjacentOffsets[i], adjacentOffsets[j] = adjacentOffsets[j], adjacentOffsets[i]
                            end

                            local mx, my, mz = mailboxSquare:getX(), mailboxSquare:getY(), mailboxSquare:getZ()
                            for _, offset in ipairs(adjacentOffsets) do
                                local adjacentSquare = getCell():getGridSquare(mx + offset.x, my + offset.y, mz)
                                if adjacentSquare and not adjacentSquare:isBlockedTo(mailboxSquare) then
                                    -- Random position within the square
                                    local rx = ZombRand(20, 80) / 100
                                    local ry = ZombRand(20, 80) / 100
                                    adjacentSquare:AddWorldInventoryItem(package, rx, ry, 0)
                                    print("[Amazoid] Package placed on ground near mailbox at " ..
                                        (mx + offset.x) .. "," .. (my + offset.y))
                                    placed = true
                                    break
                                end
                            end

                            -- Fallback to mailbox square with random position
                            if not placed then
                                local rx = ZombRand(20, 80) / 100
                                local ry = ZombRand(20, 80) / 100
                                mailboxSquare:AddWorldInventoryItem(package, rx, ry, 0)
                                print("[Amazoid] Package placed on mailbox square at " .. mx .. "," .. my)
                                placed = true
                            end
                        end

                        if not placed then
                            -- Fallback: force add to mailbox (shouldn't happen)
                            mailboxContainer:addItem(package)
                            print("[Amazoid] WARNING: No square found, forced package into mailbox")
                        end
                    end
                else
                    -- Fallback if package has no container - add directly to mailbox
                    container:addItem(package)
                    print("[Amazoid] Package delivered (no internal container)")
                end
            else
                print("[Amazoid] ERROR: Failed to create package: " .. packageType)
            end

            order.status = "delivered"
            order.deliveredAt = currentTime
            table.insert(completedOrders, i)

            -- Increase reputation based on order amount
            if Amazoid.Client and Amazoid.Client.modifyReputation then
                local orderPrice = order.totalPrice or order.moneyPaid or 0
                local baseRep = Amazoid.Reputation.ORDER_DELIVERED_BASE or 1
                local perTenRep = Amazoid.Reputation.ORDER_DELIVERED_PER_10 or 1
                local repGain = baseRep + math.floor(orderPrice / 10) * perTenRep
                Amazoid.Client.modifyReputation(repGain, "order_delivered")
                print("[Amazoid] Order #" ..
                    order.id .. " delivered - Reputation +" .. repGain .. " (order was $" .. orderPrice .. ")")
            else
                print("[Amazoid] Order #" .. order.id .. " delivered")
            end

            -- Fire OrderDelivered event
            if Amazoid.Events and Amazoid.Events.fire then
                Amazoid.Events.fire(Amazoid.Events.Names.ORDER_DELIVERED, {
                    order = order,
                    mailbox = object,
                })
            end
        end
    end

    -- Remove completed orders
    for i = #completedOrders, 1, -1 do
        table.remove(orders, completedOrders[i])
    end

    modData.AmazoidPendingOrders = orders
    object:transmitModData()

    return #completedOrders
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

--- Find nearest mailbox to player (or any local player in split-screen)
---@param player IsoPlayer The primary player (or nil to check all local players)
---@param maxDistance number Maximum search distance
---@return IsoObject|nil Nearest mailbox or nil
function Amazoid.Mailbox.findNearestMailbox(player, maxDistance)
    maxDistance = maxDistance or 100

    -- Get all local players for split-screen support
    local searchPlayers = {}
    local allPlayers = IsoPlayer.getPlayers()
    if allPlayers then
        for i = 0, allPlayers:size() - 1 do
            local p = allPlayers:get(i)
            if p and not p:isDead() then
                table.insert(searchPlayers, p)
            end
        end
    end

    if #searchPlayers == 0 then
        return nil
    end

    -- In split-screen, we need to search around ALL players, not just one
    -- Calculate bounding box that covers all players
    local minX, maxX, minY, maxY, playerZ
    for i, p in ipairs(searchPlayers) do
        local px, py, pz = p:getX(), p:getY(), p:getZ()
        if i == 1 then
            minX, maxX = px, px
            minY, maxY = py, py
            playerZ = pz
        else
            if px < minX then minX = px end
            if px > maxX then maxX = px end
            if py < minY then minY = py end
            if py > maxY then maxY = py end
        end
    end

    -- Expand the search area by maxDistance around all players
    local searchMinX = minX - maxDistance
    local searchMaxX = maxX + maxDistance
    local searchMinY = minY - maxDistance
    local searchMaxY = maxY + maxDistance

    local nearestMailbox = nil
    local nearestDistance = maxDistance + 1

    -- Search in the combined area covering all players
    for x = searchMinX, searchMaxX do
        for y = searchMinY, searchMaxY do
            local square = getCell():getGridSquare(x, y, playerZ)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    if Amazoid.Mailbox.isMailbox(obj) then
                        -- Find distance to the nearest local player
                        local minDistToAnyPlayer = maxDistance + 1
                        for _, p in ipairs(searchPlayers) do
                            local px, py = p:getX(), p:getY()
                            local dist = math.sqrt((x - px) ^ 2 + (y - py) ^ 2)
                            if dist < minDistToAnyPlayer then
                                minDistToAnyPlayer = dist
                            end
                        end

                        -- Only consider mailboxes within maxDistance of ANY player
                        if minDistToAnyPlayer <= maxDistance and minDistToAnyPlayer < nearestDistance then
                            nearestDistance = minDistToAnyPlayer
                            nearestMailbox = obj
                        end
                    end
                end
            end
        end
    end

    return nearestMailbox
end

--- Get mailbox at specific coordinates
---@param x number X coordinate
---@param y number Y coordinate
---@param z number Z coordinate
---@return IsoObject|nil Mailbox at location or nil
function Amazoid.Mailbox.getMailboxAt(x, y, z)
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
        elseif itemType == "Base.MoneyBundle" then
            -- Money bundle = 100 bills
            total = total + 100
        elseif itemType == "Base.MoneyStack" then
            -- Money stacks might have different values
            total = total + (item:getModData().value or 10)
        end
    end

    return total
end

--- Remove money from mailbox container
--- Handles individual bills and money bundles, gives change if needed
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
    local changeToGive = 0

    -- First pass: collect individual bills
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

    -- Second pass: if we still need more, use money bundles
    if removed < amount then
        for i = 0, items:size() - 1 do
            if removed >= amount then break end

            local item = items:get(i)
            local itemType = item:getFullType()

            if itemType == "Base.MoneyBundle" then
                table.insert(toRemove, item)
                removed = removed + 100
            end
        end
    end

    -- Remove items
    for _, item in ipairs(toRemove) do
        container:Remove(item)
    end

    -- Give change if we removed more than needed (from bundles)
    if removed > amount then
        changeToGive = removed - amount
        print("[Amazoid] Giving change: $" .. changeToGive)
        for c = 1, changeToGive do
            local change = instanceItem("Base.Money")
            if change then
                container:addItem(change)
            end
        end
    end

    return amount
end

--- Get the next incremental order ID
---@return number The next order ID
function Amazoid.Mailbox.getNextOrderId()
    local globalData = ModData.getOrCreate("Amazoid")
    globalData.nextOrderId = (globalData.nextOrderId or 0) + 1
    return globalData.nextOrderId
end

--- Get the next incremental letter number
---@return number The next letter number
function Amazoid.Mailbox.getNextLetterNumber()
    local globalData = ModData.getOrCreate("Amazoid")
    globalData.nextLetterNumber = (globalData.nextLetterNumber or 0) + 1
    return globalData.nextLetterNumber
end

--- Format order items into a readable list
---@param orderItems table List of order items
---@return string Formatted items list
function Amazoid.Mailbox.formatOrderItems(orderItems)
    local lines = {}
    for _, item in ipairs(orderItems) do
        local line = "  - " .. item.name .. " x" .. item.count .. " ($" .. (item.priceEach * item.count) .. ")"
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end

--- Process catalogs with circled items in mailbox
--- Called when merchant checks the mailbox
---@param object IsoObject The mailbox object
---@return table|nil Result with status: "success", "no_money", "stolen", or nil if no catalogs
function Amazoid.Mailbox.processCatalogs(object)
    if not object then return nil end

    local container = object:getContainer()
    if not container then return nil end

    local items = container:getItems()
    local catalogs = {}

    -- Find all catalogs with circled items
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local itemType = item:getFullType()

        -- Check if it's an Amazoid catalog
        if itemType:find("Amazoid%.") and itemType:find("Catalog") then
            local modData = item:getModData()
            if modData and modData.AmazoidCircled then
                local hasCircledItems = false
                for _, count in pairs(modData.AmazoidCircled) do
                    if count > 0 then
                        hasCircledItems = true
                        break
                    end
                end

                if hasCircledItems then
                    -- Get catalog category from modData
                    local catalogType = modData.AmazoidCatalogType or "basic"

                    table.insert(catalogs, {
                        item = item,
                        circledItems = modData.AmazoidCircled,
                        catalogType = catalogType,
                    })
                end
            end
        end
    end

    if #catalogs == 0 then return nil end

    -- Calculate total cost of all circled items
    local totalCost = 0
    local orderItems = {}
    local reputation = 0
    local orderHash = "" -- Hash to track if we've already notified about this order

    -- Try to get player reputation (for discount calculation)
    if Amazoid.Client and Amazoid.Client.getReputation then
        reputation = Amazoid.Client.getReputation()
    end

    for _, catalogData in ipairs(catalogs) do
        for itemType, count in pairs(catalogData.circledItems) do
            if count > 0 then
                -- Build order hash to detect if order changed
                orderHash = orderHash .. itemType .. ":" .. count .. ";"

                -- Find item info to get price
                local itemInfo = Amazoid.Mailbox.findItemInfo(itemType)
                if itemInfo then
                    local finalPrice = itemInfo.basePrice
                    if Amazoid.Items and Amazoid.Items.calculateFinalPrice then
                        finalPrice = Amazoid.Items.calculateFinalPrice(itemInfo.basePrice, reputation)
                    end

                    totalCost = totalCost + (finalPrice * count)
                    table.insert(orderItems, {
                        itemType = itemType,
                        name = itemInfo.name,
                        count = count,
                        priceEach = finalPrice,
                    })
                end
            end
        end
    end

    if #orderItems == 0 then return nil end

    -- Check if there's enough money in the mailbox
    local moneyAvailable = Amazoid.Mailbox.getMoneyInMailbox(object)

    -- Build items list for letters
    local itemsList = Amazoid.Mailbox.formatOrderItems(orderItems)

    -- Check if this is the player's first order (free!)
    local isFirstOrder = false
    if Amazoid.Client and Amazoid.Client.playerData then
        isFirstOrder = not Amazoid.Client.playerData.hasPlacedFirstOrder
    end

    -- First order is free!
    if isFirstOrder then
        totalCost = 0
        print("[Amazoid] First order is on the merchants!")
    end

    -- Not enough money - check reputation for what happens
    if moneyAvailable < totalCost then
        -- Low reputation threshold for stealing
        local stealThreshold = Amazoid.Reputation and Amazoid.Reputation.STEAL_THRESHOLD or 10

        if reputation < stealThreshold and moneyAvailable > 0 then
            -- Merchant steals any money left and leaves an angry letter
            local stolenAmount = Amazoid.Mailbox.removeMoneyFromMailbox(object, moneyAvailable)
            local letterNumber = Amazoid.Mailbox.getNextLetterNumber()

            -- Leave a letter about the theft
            Amazoid.Mailbox.addLetterToMailbox(object, {
                type = "theft",
                title = "Letter #" .. letterNumber .. " - A Message",
                content = "You thought you could cheat us?\n\nWe found your catalog with $" ..
                    stolenAmount ..
                    " - not nearly enough for what you ordered.\n\nItems you tried to order:\n" ..
                    itemsList ..
                    "\n\nTotal cost: $" .. totalCost ..
                    "\n\nConsider this a lesson. The money is ours now.\n\nDon't waste our time again.\n\n- The Merchants",
            })

            -- Don't clear the catalog - they can try again
            print("[Amazoid] Merchant stole $" .. stolenAmount .. " due to low reputation (" .. reputation .. ")")

            return {
                status = "stolen",
                amountStolen = stolenAmount,
                totalRequired = totalCost,
            }
        else
            -- Check if we already sent a payment letter for this exact order
            local modData = object:getModData()
            local lastPaymentLetterHash = modData.AmazoidLastPaymentLetterHash or ""

            -- Only send a new letter if the order changed or money in mailbox changed
            local currentStateHash = orderHash .. "money:" .. moneyAvailable

            if currentStateHash ~= lastPaymentLetterHash then
                -- Leave a polite letter asking for more money
                local shortfall = totalCost - moneyAvailable
                local letterNumber = Amazoid.Mailbox.getNextLetterNumber()

                Amazoid.Mailbox.addLetterToMailbox(object, {
                    type = "payment_needed",
                    title = "Letter #" .. letterNumber .. " - Payment Required",
                    content = "We received your catalog order.\n\nItems ordered:\n" ..
                        itemsList ..
                        "\n\nTotal cost: $" ..
                        totalCost ..
                        "\nMoney found: $" ..
                        moneyAvailable ..
                        "\nAmount still needed: $" ..
                        shortfall ..
                        "\n\nPlease leave the remaining payment in the mailbox. Your order will be processed once full payment is received.\n\n- The Merchants",
                })

                -- Remember we sent a letter for this state
                modData.AmazoidLastPaymentLetterHash = currentStateHash
                object:transmitModData()

                print("[Amazoid] Payment letter sent. Need $" .. totalCost .. ", found $" .. moneyAvailable)

                -- Don't clear the catalog or take any money - wait for full payment
                return {
                    status = "no_money",
                    moneyFound = moneyAvailable,
                    totalRequired = totalCost,
                    shortfall = totalCost - moneyAvailable,
                    letterAdded = true, -- New letter was added
                }
            else
                print("[Amazoid] Skipping duplicate payment letter for same order state")
            end

            -- Don't clear the catalog or take any money - wait for full payment
            return {
                status = "no_money",
                moneyFound = moneyAvailable,
                totalRequired = totalCost,
                shortfall = totalCost - moneyAvailable,
                letterAdded = false, -- No new letter added (duplicate)
            }
        end
    end

    -- Collect catalog types for this order (for volume tracking)
    local orderCatalogTypes = {}
    for _, catalogData in ipairs(catalogs) do
        local catType = catalogData.catalogType or "basic"
        orderCatalogTypes[catType] = true
    end

    -- Count total items in order
    local totalItemCount = 0
    for _, item in ipairs(orderItems) do
        totalItemCount = totalItemCount + (item.count or 1)
    end

    -- Calculate estimated delivery time (shown to player) based on reputation and item count
    local estimatedDeliveryTime = 12 -- Default
    if Amazoid.Utils and Amazoid.Utils.calculateDeliveryTime then
        estimatedDeliveryTime = Amazoid.Utils.calculateDeliveryTime(reputation, false, totalItemCount)
    end

    -- Calculate actual delivery time (with variance from estimate)
    local actualDeliveryTime = estimatedDeliveryTime
    if Amazoid.Utils and Amazoid.Utils.calculateActualDeliveryTime then
        actualDeliveryTime = Amazoid.Utils.calculateActualDeliveryTime(estimatedDeliveryTime)
    end

    -- Enough money - process the order
    local order = {
        id = Amazoid.Mailbox.getNextOrderId(),
        items = orderItems,
        itemCount = totalItemCount,
        totalPrice = totalCost,
        moneyPaid = totalCost,
        orderTime = getGameTime():getWorldAgeHours(),
        deliveryTime = actualDeliveryTime,     -- Actual time (may differ from estimate)
        estimatedTime = estimatedDeliveryTime, -- What we told the player
        status = "pending",
        catalogTypes = orderCatalogTypes,      -- Track which catalog types were ordered from
    }

    -- Remove exact amount from mailbox
    Amazoid.Mailbox.removeMoneyFromMailbox(object, totalCost)

    -- Track spending and orders
    if Amazoid.Client and Amazoid.Client.playerData then
        -- Update aggregate order stats
        Amazoid.Client.playerData.totalOrders = (Amazoid.Client.playerData.totalOrders or 0) + 1
        Amazoid.Client.playerData.totalSpent = (Amazoid.Client.playerData.totalSpent or 0) + totalCost
        print("[Amazoid] Total orders: " ..
            Amazoid.Client.playerData.totalOrders .. ", Total spent: $" .. Amazoid.Client.playerData.totalSpent)

        -- Track spending per catalog category (for volume unlock) - only count if not first order (free)
        if not isFirstOrder then
            Amazoid.Client.playerData.totalSpentByCategory = Amazoid.Client.playerData.totalSpentByCategory or {}
            for catType, _ in pairs(orderCatalogTypes) do
                Amazoid.Client.playerData.totalSpentByCategory[catType] =
                    (Amazoid.Client.playerData.totalSpentByCategory[catType] or 0) + totalCost
                print("[Amazoid] Total spent on " ..
                    catType .. ": $" .. Amazoid.Client.playerData.totalSpentByCategory[catType])
            end
        end

        -- Fire MoneySpent event
        if Amazoid.Events and Amazoid.Events.fire then
            Amazoid.Events.fire(Amazoid.Events.Names.MONEY_SPENT, {
                amount = totalCost,
                categories = orderCatalogTypes,
                totalSpent = Amazoid.Client.playerData.totalSpent,
                totalSpentByCategory = Amazoid.Client.playerData.totalSpentByCategory,
                isFirstOrder = isFirstOrder,
            })
        end

        Amazoid.Client.savePlayerData()
    end

    -- Clear circled items from catalogs (merchant takes note of order)
    for _, catalogData in ipairs(catalogs) do
        local modData = catalogData.item:getModData()
        modData.AmazoidCircled = {}
    end

    -- Clear payment letter hash since order is now processed
    local mailboxModData = object:getModData()
    mailboxModData.AmazoidLastPaymentLetterHash = nil
    object:transmitModData()

    -- Add the order to the mailbox
    Amazoid.Mailbox.addPendingOrder(object, order)

    -- Build items list for letter
    local itemsList = Amazoid.Mailbox.formatOrderItems(orderItems)
    local letterNumber = Amazoid.Mailbox.getNextLetterNumber()

    -- Leave a confirmation letter with different message for first order
    local paymentNote = "Total paid: $" .. totalCost
    if isFirstOrder then
        paymentNote = "Total: FREE (Your first order is on us!)"
    end

    Amazoid.Mailbox.addLetterToMailbox(object, {
        type = "order_confirmed",
        title = "Letter #" .. letterNumber .. " - Order Confirmed",
        content = "Your order #" ..
            order.id ..
            " has been received.\n\nItems ordered:\n" ..
            itemsList ..
            "\n\n" .. paymentNote ..
            "\nEstimated delivery: ~" ..
            order.estimatedTime .. " hours\n\nThank you for your business.\n\n- The Merchants",
    })

    -- Mark first order as placed
    if isFirstOrder and Amazoid.Client and Amazoid.Client.playerData then
        Amazoid.Client.playerData.hasPlacedFirstOrder = true
        Amazoid.Client.savePlayerData()
        print("[Amazoid] First order marked as placed")
    end

    print("[Amazoid] Processed catalog order #" .. order.id .. " - Total: $" .. totalCost)

    return {
        status = "success",
        order = order,
    }
end

--- Add a letter item to the mailbox
---@param object IsoObject The mailbox
---@param letterData table Letter data with type, title, content
function Amazoid.Mailbox.addLetterToMailbox(object, letterData)
    local container = object:getContainer()
    if not container then return end

    -- Choose item type based on letter type
    local letterType = "Amazoid.MerchantLetter"
    local baseName = "Merchant Letter"
    local counterKey = "merchantLetterCount"

    if letterData.type == "order_confirmed" then
        letterType = "Amazoid.OrderReceipt"
        baseName = "Order Receipt"
        counterKey = "orderReceiptCount"
    end

    local letter = instanceItem(letterType)

    if letter then
        -- Store the letter data in modData
        local modData = letter:getModData()
        modData.AmazoidLetterData = letterData
        modData.AmazoidLetterType = letterData.type

        -- Get and increment the counter from global mod data
        local globalData = ModData.getOrCreate("Amazoid")
        globalData[counterKey] = (globalData[counterKey] or 0) + 1
        local count = globalData[counterKey]

        -- Set unique name with number
        letter:setName(baseName .. " #" .. count)
        modData.AmazoidLetterNumber = count

        -- Set literatureTitle for "already read" tracking (unique per letter instance)
        modData.literatureTitle = "Amazoid_" .. (letterData.type or "letter") .. "_" .. count

        container:addItem(letter)
        print("[Amazoid] Added " .. letterType .. " #" .. count .. " to mailbox: " .. letterData.title)
    else
        print("[Amazoid] Warning: Could not create letter item")
    end
end

--- Find item info from all catalogs (new edition-based system)
---@param itemType string The item type to find
---@return table|nil Item info or nil if not found
function Amazoid.Mailbox.findItemInfo(itemType)
    -- First check new edition-based catalogs
    if Amazoid.Catalogs and Amazoid.Catalogs.Editions then
        for _, edition in pairs(Amazoid.Catalogs.Editions) do
            if edition.pages then
                for _, page in ipairs(edition.pages) do
                    if page.items then
                        for _, item in ipairs(page.items) do
                            if item.itemType == itemType then
                                return item
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback to legacy catalogs
    local allCatalogs = {
        Amazoid.Items.BasicCatalog,
        Amazoid.Items.ToolsCatalog,
        Amazoid.Items.WeaponsCatalog,
        Amazoid.Items.MedicalCatalog,
        Amazoid.Items.BlackMarketCatalog,
    }

    -- Add seasonal catalogs
    if Amazoid.Items.SeasonalCatalogs then
        for _, seasonCatalog in pairs(Amazoid.Items.SeasonalCatalogs) do
            table.insert(allCatalogs, seasonCatalog)
        end
    end

    for _, catalog in ipairs(allCatalogs) do
        if catalog then
            for _, item in ipairs(catalog) do
                if item.itemType == itemType then
                    return item
                end
            end
        end
    end

    return nil
end

-- ============================================================
-- DAILY CATALOG SPAWNING SYSTEM
-- ============================================================

--- Get list of catalog edition IDs already in the mailbox
---@param object IsoObject The mailbox object
---@return table List of edition IDs
function Amazoid.Mailbox.getCatalogEditionsInMailbox(object)
    if not object then return {} end

    local container = object:getContainer()
    if not container then return {} end

    local editions = {}
    local items = container:getItems()

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local itemType = item:getFullType()

        -- Check if it's an Amazoid catalog
        if itemType:find("Amazoid%.") and itemType:find("Catalog") then
            local modData = item:getModData()
            if modData and modData.AmazoidEdition then
                table.insert(editions, modData.AmazoidEdition)
            end
        end
    end

    return editions
end

--- Get the last catalog spawn day for a mailbox
---@param object IsoObject The mailbox object
---@return number Day number when last catalog was spawned
function Amazoid.Mailbox.getLastCatalogSpawnDay(object)
    if not object then return 0 end

    local modData = object:getModData()
    return modData.AmazoidLastCatalogDay or 0
end

--- Set the last catalog spawn day for a mailbox
---@param object IsoObject The mailbox object
---@param day number Day number
function Amazoid.Mailbox.setLastCatalogSpawnDay(object, day)
    if not object then return end

    local modData = object:getModData()
    modData.AmazoidLastCatalogDay = day
    object:transmitModData()
end

--- Get the current unlocked volume for a catalog category
---@param category string The catalog category (basic, tools, etc.)
---@return number The highest unlocked volume number (1 = first volume)
function Amazoid.Mailbox.getUnlockedVolume(category)
    if not Amazoid.Client or not Amazoid.Client.playerData then return 1 end

    local unlockedVolumes = Amazoid.Client.playerData.unlockedVolumes or {}
    return unlockedVolumes[category] or 1
end

--- Set the unlocked volume for a category
---@param category string The catalog category
---@param volume number The volume number to unlock
function Amazoid.Mailbox.setUnlockedVolume(category, volume)
    if not Amazoid.Client or not Amazoid.Client.playerData then return end

    Amazoid.Client.playerData.unlockedVolumes = Amazoid.Client.playerData.unlockedVolumes or {}
    Amazoid.Client.playerData.unlockedVolumes[category] = volume
    Amazoid.Client.savePlayerData()
end

--- Check if a catalog category is unlocked based on reputation
---@param category string The catalog category
---@param reputation number Current reputation
---@return boolean Whether the category is unlocked
function Amazoid.Mailbox.isCategoryUnlocked(category, reputation)
    local thresholds = {
        basic = Amazoid.Reputation.CATALOG_BASIC or 0,
        tools = Amazoid.Reputation.CATALOG_TOOLS or 10,
        weapons = Amazoid.Reputation.CATALOG_WEAPONS or 25,
        medical = Amazoid.Reputation.CATALOG_MEDICAL or 25,
        seasonal = Amazoid.Reputation.CATALOG_SEASONAL or 35,
        blackmarket = Amazoid.Reputation.CATALOG_BLACKMARKET or 50,
    }

    local required = thresholds[category] or 0
    return reputation >= required
end

--- Get the specific catalog edition ID for a category and volume
---@param category string The catalog category
---@param volume number The volume number
---@return string|nil The edition ID or nil if not found
function Amazoid.Mailbox.getCatalogEditionId(category, volume)
    -- Edition IDs follow pattern: category_vol1, category_vol2, etc.
    local editionId = category .. "_vol" .. volume

    if Amazoid.Catalogs and Amazoid.Catalogs.getEdition then
        local edition = Amazoid.Catalogs.getEdition(editionId)
        if edition then
            return editionId
        end
    end

    return nil
end

--- Spawn a specific catalog volume in the mailbox
---@param object IsoObject The mailbox
---@param editionId string The edition ID to spawn
---@param withLetter boolean Whether to include a letter
---@return boolean Success
function Amazoid.Mailbox.spawnCatalogEdition(object, editionId, withLetter)
    if not object then return false end

    local edition = Amazoid.Catalogs and Amazoid.Catalogs.getEdition and Amazoid.Catalogs.getEdition(editionId)
    if not edition then
        print("[Amazoid] Unknown edition: " .. tostring(editionId))
        return false
    end

    local container = object:getContainer()
    if not container then return false end

    -- Check if this edition is already in the mailbox
    local existingEditions = Amazoid.Mailbox.getCatalogEditionsInMailbox(object)
    for _, existing in ipairs(existingEditions) do
        if existing == editionId then
            print("[Amazoid] Edition already in mailbox: " .. editionId)
            return false
        end
    end

    local catalogItem = instanceItem("Amazoid.Catalog")
    if not catalogItem then
        print("[Amazoid] Warning: Could not create catalog item")
        return false
    end

    local modData = catalogItem:getModData()
    modData.AmazoidEdition = editionId
    modData.AmazoidCatalogType = edition.catalogType or "basic"
    modData.AmazoidCircled = {}
    modData.AmazoidSpawnDay = getGameTime():getDay()

    if catalogItem.setName then
        catalogItem:setName(edition.title .. " - " .. edition.subtitle)
    end

    container:addItem(catalogItem)
    print("[Amazoid] Spawned catalog: " .. edition.title .. " (" .. editionId .. ")")

    -- Add letter if requested
    if withLetter then
        local letterNumber = Amazoid.Mailbox.getNextLetterNumber()
        Amazoid.Mailbox.addLetterToMailbox(object, {
            type = "catalog_delivery",
            title = "Letter #" .. letterNumber .. " - New Catalog",
            content = "A new catalog volume has arrived!\n\n" ..
                edition.title .. " - " .. edition.subtitle ..
                "\n\nBrowse at your leisure.\n\n- The Merchants",
        })
    end

    return true
end

--- Check for seasonal catalog spawn based on season change
--- Seasonal catalogs Vol. I are given automatically when a new season starts
--- No reputation required - just need to have a contract
---@param object IsoObject The mailbox
---@return boolean Whether a seasonal catalog was spawned
function Amazoid.Mailbox.checkSeasonalCatalog(object)
    if not object then return false end
    if not Amazoid.Client or not Amazoid.Client.playerData then return false end
    if not Amazoid.Utils or not Amazoid.Utils.getCurrentSeason then return false end

    -- Get current season
    local currentSeason = Amazoid.Utils.getCurrentSeason()
    local lastSeasonCatalog = Amazoid.Client.playerData.lastSeasonCatalog or ""

    -- Check if we already gave a catalog for this season
    if currentSeason == lastSeasonCatalog then
        return false
    end

    -- Spawn the seasonal Vol. I catalog for this season
    local editionId = "seasonal_vol1"

    -- Check if this edition exists
    if Amazoid.Catalogs and Amazoid.Catalogs.getEdition then
        local edition = Amazoid.Catalogs.getEdition(editionId)
        if edition then
            local spawned = Amazoid.Mailbox.spawnCatalogEdition(object, editionId, true)
            if spawned then
                -- Mark that we gave a catalog for this season
                Amazoid.Client.playerData.lastSeasonCatalog = currentSeason

                -- Also mark seasonal category as unlocked for volume progression
                local unlockedCategories = Amazoid.Client.playerData.unlockedCategories or {}
                unlockedCategories["seasonal"] = true
                Amazoid.Client.playerData.unlockedCategories = unlockedCategories

                print("[Amazoid] Seasonal catalog spawned for " .. currentSeason)
                return true
            end
        end
    end

    return false
end

--- Remove a mission letter from the mailbox by mission ID
--- Called when mission is completed to remove the original request letter
---@param object IsoObject The mailbox
---@param missionId string The mission ID to find and remove
function Amazoid.Mailbox.removeMissionLetter(object, missionId)
    if not object or not missionId then return end

    local container = object:getContainer()
    if not container then return end

    -- Find and remove letters with matching mission ID
    local itemsToRemove = {}
    for i = 0, container:getItems():size() - 1 do
        local item = container:getItems():get(i)
        if item then
            local modData = item:getModData()
            if modData and modData.AmazoidMission then
                -- Check if this is the original mission letter (not completion letter)
                local letterType = modData.AmazoidLetterType or ""
                if letterType == "mission" then
                    -- Check mission ID
                    local letterMissionId = modData.AmazoidMission.id
                    if letterMissionId == missionId then
                        table.insert(itemsToRemove, item)
                    end
                end
            end
        end
    end

    -- Remove the found letters
    for _, item in ipairs(itemsToRemove) do
        container:Remove(item)
        print("[Amazoid] Removed original mission letter for mission: " .. missionId)
    end
end

--- Check for newly unlocked catalog categories based on reputation
--- Spawns the first volume of any newly unlocked categories
---@param object IsoObject The mailbox
---@param reputation number Current reputation
---@return boolean Whether any new catalogs were spawned
function Amazoid.Mailbox.checkReputationUnlocks(object, reputation)
    if not object then return false end
    if not Amazoid.Client or not Amazoid.Client.playerData then return false end

    local unlockedCategories = Amazoid.Client.playerData.unlockedCategories or {}

    -- Note: seasonal is NOT in this list - it's handled separately by checkSeasonalCatalog
    local categories = { "basic", "tools", "weapons", "medical", "blackmarket" }

    for _, category in ipairs(categories) do
        -- Check if category is now unlocked by reputation but wasn't before
        if Amazoid.Mailbox.isCategoryUnlocked(category, reputation) and not unlockedCategories[category] then
            -- Mark as unlocked
            unlockedCategories[category] = true
            Amazoid.Client.playerData.unlockedCategories = unlockedCategories

            -- Spawn the first volume of this category
            local editionId = Amazoid.Mailbox.getCatalogEditionId(category, 1)
            if editionId then
                local spawned = Amazoid.Mailbox.spawnCatalogEdition(object, editionId, true)
                if spawned then
                    print("[Amazoid] Unlocked new category: " .. category)
                    -- Only spawn one catalog per call (limit to one per day)
                    return true
                end
            end
        end
    end

    return false
end

--- Check for volume unlocks based on spending
--- Called when an order is delivered
--- Only spawns one catalog per call (limit one per day)
---@param object IsoObject The mailbox
---@return boolean Whether a new volume was spawned
function Amazoid.Mailbox.checkVolumeUnlocks(object)
    if not object then return false end
    if not Amazoid.Client or not Amazoid.Client.playerData then return false end

    local totalSpent = Amazoid.Client.playerData.totalSpentByCategory or {}
    local unlockedVolumes = Amazoid.Client.playerData.unlockedVolumes or {}

    -- Special case: Basic Volume 2 unlocks after ANY order (including the free first order)
    -- This is because Volume 1 can be fully purchased with the free first order
    local basicVolume = unlockedVolumes["basic"] or 1
    if basicVolume == 1 and Amazoid.Client.playerData.hasPlacedFirstOrder then
        local editionId = Amazoid.Mailbox.getCatalogEditionId("basic", 2)
        if editionId then
            local spawned = Amazoid.Mailbox.spawnCatalogEdition(object, editionId, true)
            if spawned then
                unlockedVolumes["basic"] = 2
                Amazoid.Client.playerData.unlockedVolumes = unlockedVolumes
                print("[Amazoid] Unlocked Basic Volume 2 (first order placed)")
                return true
            end
        end
    end

    for category, spent in pairs(totalSpent) do
        local currentVolume = unlockedVolumes[category] or 1

        -- Check if we should unlock the next volume
        -- Threshold is the total value of all items in the previous volume(s)
        local nextVolume = currentVolume + 1
        local threshold = 100 -- Default fallback

        if Amazoid.Catalogs and Amazoid.Catalogs.getVolumeUnlockThreshold then
            threshold = Amazoid.Catalogs.getVolumeUnlockThreshold(category, nextVolume)
        else
            -- Fallback: use fixed threshold times volume number
            threshold = (Amazoid.CatalogVolumeThreshold or 100) * currentVolume
        end

        print("[Amazoid] Volume unlock check for " ..
            category .. ": spent $" .. spent .. ", need $" .. threshold .. " for vol " .. nextVolume)

        if spent >= threshold then
            -- Unlock the next volume
            local editionId = Amazoid.Mailbox.getCatalogEditionId(category, nextVolume)

            if editionId then
                local spawned = Amazoid.Mailbox.spawnCatalogEdition(object, editionId, true)
                if spawned then
                    unlockedVolumes[category] = nextVolume
                    Amazoid.Client.playerData.unlockedVolumes = unlockedVolumes
                    print("[Amazoid] Unlocked volume " ..
                        nextVolume .. " for " .. category .. " (threshold: $" .. threshold .. ")")
                    -- Only spawn one catalog per call (limit to one per day)
                    return true
                end
            else
                -- No more volumes for this category - mark as maxed out to prevent further checks
                unlockedVolumes[category] = 999
                Amazoid.Client.playerData.unlockedVolumes = unlockedVolumes
                print("[Amazoid] No more volumes for " .. category)
            end
        end
    end

    return false
end

--- Main function called on merchant visit to spawn new catalogs
--- Checks for reputation unlocks and volume unlocks
--- Limited to one new catalog per day
---@param object IsoObject The mailbox object
---@param reputation number Player reputation
---@return boolean Whether any catalogs were spawned
function Amazoid.Mailbox.spawnCatalogs(object, reputation)
    if not object then return false end
    if not Amazoid.Mailbox.hasContract(object) then return false end
    if not Amazoid.Client or not Amazoid.Client.playerData then return false end

    -- Check if we already received a catalog today
    local currentDay = math.floor(getGameTime():getWorldAgeHours() / 24)
    local lastCatalogDay = Amazoid.Client.playerData.lastCatalogDay or 0

    if currentDay <= lastCatalogDay then
        -- Already received a catalog today
        return false
    end

    local spawnedAny = false

    -- Check for seasonal catalog (given at start of each season, no rep required)
    if not spawnedAny and Amazoid.Mailbox.checkSeasonalCatalog(object) then
        spawnedAny = true
    end

    -- Check for reputation-based category unlocks (prioritize these)
    if not spawnedAny and Amazoid.Mailbox.checkReputationUnlocks(object, reputation) then
        spawnedAny = true
    end

    -- Check for spending-based volume unlocks (only if no reputation unlock)
    if not spawnedAny and Amazoid.Mailbox.checkVolumeUnlocks(object) then
        spawnedAny = true
    end

    -- Update last catalog day if we spawned any
    if spawnedAny then
        Amazoid.Client.playerData.lastCatalogDay = currentDay
        Amazoid.Client.savePlayerData()
    end

    return spawnedAny
end

--- Check and spawn catalogs for contracted mailbox
---@param reputation number Default reputation to use
function Amazoid.Mailbox.checkCatalogs(reputation)
    reputation = reputation or 0

    -- This would be called from a server tick or event
    -- In split-screen, check any local player's data for contracted mailbox
    local players = IsoPlayer.getPlayers()
    if not players or players:size() == 0 then return end

    -- Get contracted mailbox from first player with valid data
    local player = players:get(0)
    if not player then return end

    -- Get player's contracted mailbox
    local data = player:getModData().Amazoid
    if not data or not data.contractMailbox then return end

    local loc = data.contractMailbox
    local mailbox = Amazoid.Mailbox.getMailboxAt(loc.x, loc.y, loc.z)

    if mailbox then
        local playerRep = data.reputation or 0
        Amazoid.Mailbox.spawnCatalogs(mailbox, playerRep)
    end
end

--- Process missions in mailbox - check for completed collection missions
--- Called during merchant visit
---@param object IsoObject The mailbox object
---@return table|nil Result with completed missions and rewards
function Amazoid.Mailbox.processMissions(object)
    if not object then return nil end
    if not Amazoid.Client or not Amazoid.Client.playerData then return nil end

    local activeMissions = Amazoid.Client.playerData.activeMissions or {}
    if #activeMissions == 0 then return nil end

    local completedMissions = {}
    local totalMoneyReward = 0
    local totalReputationReward = 0

    -- Check each active mission
    for i = #activeMissions, 1, -1 do
        local mission = activeMissions[i]

        -- Ensure mission has proper structure (deserialize if needed after save/load)
        mission = Amazoid.Missions.deserializeFromModData(mission)
        if not mission then
            print("[Amazoid] Skipping invalid mission at index " .. i)
        elseif mission.type == Amazoid.MissionTypes.COLLECTION then
            -- Check if mailbox has the required items
            local isComplete, foundCount = Amazoid.Missions.checkMissionItems(object, mission)

            if isComplete then
                -- Collect the items
                local collected = Amazoid.Missions.collectMissionItems(object, mission)

                if collected then
                    -- Mark mission as complete
                    table.remove(activeMissions, i)

                    -- Add to completed missions
                    table.insert(Amazoid.Client.playerData.completedMissions, {
                        mission = mission,
                        success = true,
                        completedAt = getGameTime():getWorldAgeHours(),
                    })

                    -- Track rewards (with nil safety)
                    local reward = mission.reward or {}
                    totalMoneyReward = totalMoneyReward + (reward.money or 0)
                    totalReputationReward = totalReputationReward + (reward.reputation or 0)

                    -- Add to completed list for result
                    table.insert(completedMissions, mission)

                    -- Update stats
                    Amazoid.Client.playerData.totalMissionsCompleted =
                        (Amazoid.Client.playerData.totalMissionsCompleted or 0) + 1

                    -- Mark the mission letter as read for all local players (shows checkmark now that mission is complete)
                    local literatureId = "Amazoid_Mission_" .. mission.id
                    local players = IsoPlayer.getPlayers()
                    for i = 0, players:size() - 1 do
                        local p = players:get(i)
                        if p then
                            p:addReadLiterature(literatureId)
                        end
                    end
                    print("[Amazoid] Mission letter marked as read for all players: " .. literatureId)

                    -- Remove original mission letter from mailbox if present
                    Amazoid.Mailbox.removeMissionLetter(object, mission.id)

                    print("[Amazoid] Collection mission completed: " .. mission.title)
                end
            end
        elseif mission.type == Amazoid.MissionTypes.ELIMINATION then
            -- Check if elimination mission is completed (all kills done)
            local reqKillCount = mission.requirements and mission.requirements.killCount or 10
            local progress = mission.progress or 0

            if progress >= reqKillCount or mission.status == "completed" then
                -- Mark mission as complete
                table.remove(activeMissions, i)

                -- Add to completed missions
                table.insert(Amazoid.Client.playerData.completedMissions, {
                    mission = mission,
                    success = true,
                    completedAt = getGameTime():getWorldAgeHours(),
                })

                -- Track rewards (with nil safety)
                local reward = mission.reward or {}
                totalMoneyReward = totalMoneyReward + (reward.money or 0)
                totalReputationReward = totalReputationReward + (reward.reputation or 0)

                -- Add to completed list for result
                table.insert(completedMissions, mission)

                -- Update stats
                Amazoid.Client.playerData.totalMissionsCompleted =
                    (Amazoid.Client.playerData.totalMissionsCompleted or 0) + 1

                -- Mark the mission letter as read for all local players (shows checkmark now that mission is complete)
                local literatureId = "Amazoid_Mission_" .. mission.id
                local players = IsoPlayer.getPlayers()
                for i = 0, players:size() - 1 do
                    local p = players:get(i)
                    if p then
                        p:addReadLiterature(literatureId)
                    end
                end
                print("[Amazoid] Mission letter marked as read for all players: " .. literatureId)

                -- Remove original mission letter from mailbox if present
                Amazoid.Mailbox.removeMissionLetter(object, mission.id)

                print("[Amazoid] Elimination mission completed: " ..
                    mission.title .. " (" .. progress .. "/" .. reqKillCount .. " kills)")
            end
        end
    end

    if #completedMissions == 0 then return nil end

    -- Add rewards to mailbox
    local container = object:getContainer()
    if container then
        -- Add money reward
        if totalMoneyReward > 0 then
            -- Add as money bundles ($100) and individual money
            local bundles = math.floor(totalMoneyReward / 100)
            local remainder = totalMoneyReward % 100

            for b = 1, bundles do
                local bundle = instanceItem("Base.MoneyBundle")
                if bundle then
                    container:addItem(bundle)
                end
            end

            for m = 1, remainder do
                local money = instanceItem("Base.Money")
                if money then
                    container:addItem(money)
                end
            end
        end

        -- Add completion letter for each mission
        for _, mission in ipairs(completedMissions) do
            Amazoid.Mailbox.addMissionCompletionLetter(object, mission, mission.missionNumber)
        end
    end

    -- Give reputation
    if totalReputationReward > 0 then
        Amazoid.Client.modifyReputation(totalReputationReward, "mission_reward")
    end

    -- Save player data
    Amazoid.Client.savePlayerData()

    return {
        completedMissions = completedMissions,
        moneyReward = totalMoneyReward,
        reputationReward = totalReputationReward,
    }
end

--- Add a mission completion letter to mailbox
---@param object IsoObject The mailbox
---@param mission table The completed mission
---@param missionNumber number|nil The mission number (optional, extracted from completed mission data)
function Amazoid.Mailbox.addMissionCompletionLetter(object, mission, missionNumber)
    local container = object:getContainer()
    if not container then return end

    local letter = instanceItem("Amazoid.MerchantLetter")
    if letter then
        local modData = letter:getModData()
        modData.AmazoidLetterType = "mission_complete"
        -- Serialize mission data to flatten nested tables for reliable modData storage
        modData.AmazoidMission = Amazoid.Missions.serializeForModData(mission)
        modData.literatureTitle = "Amazoid_MissionComplete_" .. mission.id
        modData.AmazoidMissionNumber = missionNumber

        local namePrefix = missionNumber and ("Mission #" .. missionNumber .. " Complete") or "Mission Complete"
        letter:setName(namePrefix .. " - " .. (mission.title or "Task"))
        container:addItem(letter)
        print("[Amazoid] Mission completion letter added for: " .. mission.title)
    end
end

--- Spawn a specific mission and add letter to mailbox
--- Reusable function for both daily spawn and debug
---@param object IsoObject The mailbox object
---@param missionType string "collection" or "elimination"
---@param skipDayCheck boolean If true, skip the daily limit check
---@param notify boolean If true, play sound and notify players
---@return table|nil The spawned mission or nil if failed
function Amazoid.Mailbox.spawnMission(object, missionType, skipDayCheck, notify)
    if not object then return nil end
    if not Amazoid.Client or not Amazoid.Client.playerData then return nil end
    if not Amazoid.Mailbox.hasContract(object) then return nil end

    missionType = missionType or "collection"

    -- Ensure activeMissions table exists
    Amazoid.Client.playerData.activeMissions = Amazoid.Client.playerData.activeMissions or {}

    -- Generate mission based on reputation
    local reputation = Amazoid.Client.getReputation()
    local mission

    if missionType == "elimination" then
        mission = Amazoid.Missions.generateEliminationMission(reputation)
    else
        mission = Amazoid.Missions.generateCollectionMission(reputation)
    end

    if not mission then
        print("[Amazoid] Failed to generate " .. missionType .. " mission")
        return nil
    end

    -- Get next mission number
    local globalData = ModData.getOrCreate("Amazoid")
    globalData.missionLetterCount = (globalData.missionLetterCount or 0) + 1
    local missionNumber = globalData.missionLetterCount

    -- Store mission number in mission object
    mission.missionNumber = missionNumber

    -- Add mission to player's active missions
    table.insert(Amazoid.Client.playerData.activeMissions, mission)
    Amazoid.Client.savePlayerData()

    -- Add mission letter to mailbox
    local container = object:getContainer()
    if container then
        local letter = instanceItem("Amazoid.MerchantLetter")
        if letter then
            local modData = letter:getModData()
            modData.AmazoidLetterType = "mission"
            modData.AmazoidMission = Amazoid.Missions.serializeForModData(mission)
            modData.literatureTitle = "Amazoid_Mission_" .. mission.id
            modData.AmazoidMissionNumber = missionNumber
            letter:setName("Mission #" .. missionNumber .. " - " .. (mission.title or "New Task"))
            container:addItem(letter)
            print("[Amazoid] Mission letter added: " .. mission.title)
        end
    end

    -- Notify players if requested
    if notify and Amazoid.Client and Amazoid.Client.notifyMerchantVisit then
        Amazoid.Client.notifyMerchantVisit(object)
    end

    print("[Amazoid] Mission spawned: " .. mission.title)
    return mission
end

--- Force first contact at a mailbox
--- Reusable function for both normal first contact and debug
---@param mailbox IsoObject|nil The mailbox (if nil, finds nearest)
---@param forceReset boolean If true, reset first contact state first
---@return boolean Whether first contact was successful
function Amazoid.Mailbox.forceFirstContact(mailbox, forceReset)
    if not Amazoid.Client or not Amazoid.Client.playerData then return false end

    -- Reset state if requested
    if forceReset then
        Amazoid.Client.playerData.firstContactMade = false
        Amazoid.Client.playerData.firstContactDay = nil
    end

    -- Find mailbox if not provided
    if not mailbox then
        mailbox = Amazoid.Mailbox.findNearestMailbox(nil, 100)
    end

    if not mailbox then
        print("[Amazoid] No mailbox found for first contact")
        return false
    end

    -- Clear any existing discovery letter and add new one
    local mailboxData = mailbox:getModData()
    mailboxData.AmazoidDiscoveryLetter = nil
    Amazoid.Mailbox.addDiscoveryLetter(mailbox)

    -- Play sound and notify players
    if Amazoid.Client and Amazoid.Client.playMailboxSound then
        Amazoid.Client.playMailboxSound(mailbox)
    end

    -- Make all local players say something
    local allPlayers = IsoPlayer.getPlayers()
    if allPlayers then
        for i = 0, allPlayers:size() - 1 do
            local p = allPlayers:get(i)
            if p then
                p:Say("I think I heard someone at the mailbox...")
            end
        end
    end

    -- Mark first contact as made
    Amazoid.Client.playerData.firstContactMade = true
    Amazoid.Client.savePlayerData()

    print("[Amazoid] First contact triggered at mailbox (" .. mailbox:getX() .. ", " .. mailbox:getY() .. ")")
    return true
end

--- Spawn a new daily mission if eligible
--- Called during merchant visit
---@param object IsoObject The mailbox object
---@return boolean Whether a mission was spawned
function Amazoid.Mailbox.spawnDailyMission(object)
    if not object then return false end
    if not Amazoid.Client or not Amazoid.Client.playerData then return false end
    if not Amazoid.Mailbox.hasContract(object) then return false end

    -- Get current game day
    local currentDay = math.floor(getGameTime():getWorldAgeHours() / 24)
    local lastMissionDay = Amazoid.Client.playerData.lastMissionDay or 0

    -- Only spawn one mission per day
    if currentDay <= lastMissionDay then
        return false
    end

    -- Check if player already has an active mission
    local activeMissions = Amazoid.Client.playerData.activeMissions or {}
    local hasActiveCollection = false
    local hasActiveElimination = false
    for _, mission in ipairs(activeMissions) do
        if mission.type == Amazoid.MissionTypes.COLLECTION then
            hasActiveCollection = true
        elseif mission.type == Amazoid.MissionTypes.ELIMINATION then
            hasActiveElimination = true
        end
    end

    -- Don't spawn if player already has an active mission of any type
    if hasActiveCollection or hasActiveElimination then
        print("[Amazoid] Player already has an active mission, skipping daily spawn")
        return false
    end

    -- Random chance to spawn (not every day)
    -- 70% chance per day after the first mission
    if ZombRand(100) > 70 then
        print("[Amazoid] Daily mission spawn chance failed")
        return false
    end

    -- Randomly choose mission type: 60% collection, 40% elimination
    local missionType = (ZombRand(100) < 60) and "collection" or "elimination"

    -- Use the core spawnMission function
    local mission = Amazoid.Mailbox.spawnMission(object, missionType, true, false)
    if mission then
        -- Update last mission day after successful spawn
        Amazoid.Client.playerData.lastMissionDay = currentDay
        Amazoid.Client.savePlayerData()
        print("[Amazoid] Daily mission spawned: " .. mission.title)
        return true
    end

    return false
end

print("[Amazoid] Mailbox system loaded")
