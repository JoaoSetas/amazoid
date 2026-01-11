--[[
    Amazoid - Mysterious Mailbox Merchant
    Context Menu Integration

    This file adds Amazoid options to mailbox context menus.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidMailbox"
require "Amazoid/AmazoidLetters"
require "Amazoid/AmazoidCatalogs"
require "Amazoid/AmazoidMissions"
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

--- View catalog action (from mailbox menu)
--- Tries to find a catalog in the mailbox or player's inventory
---@param mailbox IsoObject The mailbox
---@param player IsoPlayer The player
function Amazoid.ContextMenu.onViewCatalog(mailbox, player)
    -- Look for a catalog in the player's inventory first
    local inventory = player:getInventory()

    local catalog = inventory:getFirstTypeRecurse("Amazoid.Catalog")
    if catalog then
        local edition = catalog:getModData().AmazoidEdition or "basic_vol1"
        AmazoidCatalogPanel.showCatalog(player, catalog, edition)
        return
    end

    -- Check the mailbox for catalogs
    local container = mailbox:getContainer()
    if container then
        catalog = container:getFirstTypeRecurse("Amazoid.Catalog")
        if catalog then
            local edition = catalog:getModData().AmazoidEdition or "basic_vol1"
            AmazoidCatalogPanel.showCatalog(player, catalog, edition)
            return
        end
    end

    player:Say("I need a catalog to browse items.")
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
        -- Use estimated time for display, actual delivery may vary
        local estimatedTime = order.estimatedTime or order.deliveryTime
        local timeRemaining = estimatedTime - (currentTime - order.orderTime)
        if timeRemaining > 0 then
            player:Say("Order #" .. order.id .. ": ~" .. math.ceil(timeRemaining) .. " hours remaining")
        else
            player:Say("Order #" .. order.id .. ": Should arrive soon...")
        end
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
    -- Note: PZ automatically shows checkmark icon for items with literatureTitle when read
    for _, itemStack in ipairs(items) do
        local item = itemStack
        if type(itemStack) == "table" then
            item = itemStack.items[1]
        end

        if item and item:getFullType() then
            local itemType = item:getFullType()
            local option = nil
            local iconTexture = item:getTex()

            -- Letters
            if itemType == "Amazoid.DiscoveryLetter" then
                option = context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "discovery")
            elseif itemType == "Amazoid.SignedContract" then
                option = context:addOption("Read Contract", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "contract")
            elseif itemType == "Amazoid.MissionLetter" then
                option = context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "mission")
            elseif itemType == "Amazoid.LoreLetter" then
                option = context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "lore")
            elseif itemType == "Amazoid.DeliveryNoteLetter" then
                option = context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "delivery")
            elseif itemType == "Amazoid.GiftLetter" then
                option = context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "gift")
            elseif itemType == "Amazoid.MerchantLetter" then
                option = context:addOption("Read Letter", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "merchant")
            elseif itemType == "Amazoid.OrderReceipt" then
                option = context:addOption("Read Receipt", item, Amazoid.ContextMenu.onReadInventoryLetter, playerObj,
                    "receipt")
                -- Unified Catalog (edition stored in modData)
            elseif itemType == "Amazoid.Catalog" then
                local edition = item:getModData().AmazoidEdition or "basic_vol1"
                option = context:addOption("Browse Catalog", item, Amazoid.ContextMenu.onBrowseCatalog, playerObj,
                    edition)
            end

            -- Add icon to the option
            if option and iconTexture then
                option.iconTexture = iconTexture
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
        -- Build dynamic contract stats
        local data = player:getModData().Amazoid or {}
        local reputation = data.reputation or 0
        local discount = 0
        if Amazoid and Amazoid.Utils and Amazoid.Utils.calculateDiscount then
            discount = Amazoid.Utils.calculateDiscount(reputation)
        end
        local discountPct = math.floor(discount * 100)
        local totalOrders = data.totalOrders or 0
        local totalSpent = data.totalSpent or 0
        local missionsCompleted = data.missionsCompleted or 0

        local content = "This contract binds you to the Amazoid service.\n\n"
        content = content ..
            "You have agreed to the Terms of Service and may now access all merchant services through designated mailboxes.\n\n"
        content = content .. "━━━━━━━━━━━━━━━━━━━━\n"
        content = content .. "YOUR ACCOUNT STATUS:\n"
        content = content .. "━━━━━━━━━━━━━━━━━━━━\n\n"
        content = content .. "Reputation: " .. reputation .. "/100\n"
        content = content .. "Current Discount: " .. discountPct .. "%\n"
        content = content .. "Orders Placed: " .. totalOrders .. "\n"
        content = content .. "Total Spent: $" .. totalSpent .. "\n"
        content = content .. "Missions Completed: " .. missionsCompleted .. "\n\n"
        content = content .. "━━━━━━━━━━━━━━━━━━━━\n\n"
        content = content .. "Remember: We always deliver.\n\n- The Merchants"

        letterData = {
            title = "Signed Contract",
            content = content
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
        elseif modData.AmazoidMission then
            -- Mission letter - deserialize mission data from flattened modData
            local mission = Amazoid.Missions.deserializeFromModData(modData.AmazoidMission)
            local letterType = modData.AmazoidLetterType or "mission"

            if letterType == "mission_complete" then
                -- Mission completion letter
                letterData = {
                    title = "Mission Complete!",
                    content = Amazoid.Missions.createCompletionLetterContent(mission)
                }
            else
                -- Mission request letter
                letterData = {
                    title = mission.title or "New Mission",
                    content = Amazoid.Missions.createMissionLetterContent(mission),
                    mission = mission,
                }

                -- Auto-accept mission when reading the letter (if not already active)
                if Amazoid.Client and Amazoid.Client.playerData then
                    local isAlreadyActive = false
                    for _, m in ipairs(Amazoid.Client.playerData.activeMissions or {}) do
                        if m.id == mission.id then
                            isAlreadyActive = true
                            break
                        end
                    end

                    if not isAlreadyActive then
                        Amazoid.Client.acceptMission(mission)
                    end
                end
            end
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
    -- Check if catalog has a stored edition ID
    local modData = item:getModData()
    local editionId = modData.AmazoidEdition

    if not editionId then
        -- Legacy catalog or no edition set - determine from catalog type
        if Amazoid.Catalogs and Amazoid.Catalogs.getEditionFromType then
            editionId = Amazoid.Catalogs.getEditionFromType(catalogType)
        else
            editionId = "basic_vol1" -- Fallback
        end
        -- Store it for next time
        modData.AmazoidEdition = editionId
    end

    -- Open the catalog UI with the edition
    if AmazoidCatalogPanel and AmazoidCatalogPanel.showCatalog then
        AmazoidCatalogPanel.showCatalog(player, item, editionId)
    else
        print("[Amazoid] ERROR: CatalogPanel not loaded")
    end
end

-- Register inventory context menu event
Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)

print("[Amazoid] Context menu integration loaded")
