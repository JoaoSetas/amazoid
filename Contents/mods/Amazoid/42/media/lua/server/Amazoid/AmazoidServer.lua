--[[
    Amazoid - Mysterious Mailbox Merchant
    Server Module
    
    This file handles server-side logic including mailbox spawning and deliveries.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidUtils"

Amazoid.Server = Amazoid.Server or {}

-- Global data for the world
Amazoid.Server.worldData = {
    discoveryMailboxes = {},    -- Mailboxes that have discovery letters
    activeOrders = {},          -- All active orders in the world
    markedZombies = {},         -- Zombies marked for scavenger missions
    protectionDevices = {},     -- Active protection mission devices
}

--- Initialize server module
function Amazoid.Server.init()
    print("[Amazoid] Server module initializing...")
    
    -- Load world data
    Amazoid.Server.loadWorldData()
    
    print("[Amazoid] Server module initialized")
end

--- Save world data
function Amazoid.Server.saveWorldData()
    local modData = ModData.getOrCreate("Amazoid")
    modData.worldData = Amazoid.Server.worldData
    ModData.transmit("Amazoid")
    
    print("[Amazoid] World data saved")
end

--- Load world data
function Amazoid.Server.loadWorldData()
    local modData = ModData.get("Amazoid")
    if modData and modData.worldData then
        Amazoid.Server.worldData = modData.worldData
        print("[Amazoid] World data loaded")
    else
        print("[Amazoid] No world data found, using defaults")
    end
end

--- Spawn discovery letter in a random mailbox
---@param cell IsoCell The cell to check for mailboxes
function Amazoid.Server.trySpawnDiscoveryLetter(cell)
    -- TODO: Implement mailbox detection and letter spawning
    -- This will scan for mailbox objects and randomly add discovery letters
end

--- Process a pending order (check if it should be delivered)
---@param order table Order data
---@return boolean Whether order was delivered
function Amazoid.Server.processOrder(order)
    local currentTime = getGameTime():getWorldAgeHours()
    local orderAge = currentTime - order.orderTime
    
    if orderAge >= order.deliveryTime then
        -- Time to deliver!
        Amazoid.Server.deliverOrder(order)
        return true
    end
    
    return false
end

--- Deliver an order to the player's mailbox
---@param order table Order data
function Amazoid.Server.deliverOrder(order)
    -- TODO: Implement actual item spawning in mailbox
    -- For now, just log it
    print("[Amazoid] Delivering order #" .. order.id)
    
    order.status = "delivered"
    order.deliveredAt = getGameTime():getWorldAgeHours()
end

--- Generate missions based on player reputation
---@param playerReputation number Player's current reputation
---@return table List of available missions
function Amazoid.Server.generateAvailableMissions(playerReputation)
    local missions = {}
    
    -- Collection missions (always available)
    table.insert(missions, Amazoid.Server.generateCollectionMission(playerReputation))
    
    -- Elimination missions (reputation >= 10)
    if playerReputation >= 10 then
        table.insert(missions, Amazoid.Server.generateEliminationMission(playerReputation))
    end
    
    -- Scavenger missions (reputation >= 20)
    if playerReputation >= 20 then
        table.insert(missions, Amazoid.Server.generateScavengerMission(playerReputation))
    end
    
    -- Timed delivery (reputation >= 30)
    if playerReputation >= 30 then
        table.insert(missions, Amazoid.Server.generateTimedDeliveryMission(playerReputation))
    end
    
    -- Protection missions (reputation >= 40)
    if playerReputation >= 40 then
        table.insert(missions, Amazoid.Server.generateProtectionMission(playerReputation))
    end
    
    return missions
end

--- Generate a collection mission
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Server.generateCollectionMission(reputation)
    local collectionItems = {
        {item = "Base.TinnedBeans", count = 5, name = "Canned Beans"},
        {item = "Base.TinnedSoup", count = 3, name = "Canned Soup"},
        {item = "Base.Bandage", count = 2, name = "Bandages"},
        {item = "Base.Nails", count = 20, name = "Nails"},
        {item = "Base.Plank", count = 5, name = "Wooden Planks"},
    }
    
    local selected = collectionItems[ZombRand(1, #collectionItems + 1)]
    local reward = math.floor(selected.count * 10 * (1 + reputation / 100))
    
    return {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.COLLECTION,
        title = "Collection: " .. selected.name,
        description = "Leave " .. selected.count .. " " .. selected.name .. " in the mailbox.",
        requirements = {
            itemType = selected.item,
            count = selected.count,
        },
        reward = {
            money = reward,
            reputation = Amazoid.Reputation.MISSION_COMPLETE,
        },
        timeLimit = nil, -- No time limit for collection
    }
end

--- Generate an elimination mission
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Server.generateEliminationMission(reputation)
    local weapons = {
        {type = "any", name = "any weapon"},
        {type = "Base.Axe", name = "an Axe"},
        {type = "Base.BaseballBat", name = "a Baseball Bat"},
        {type = "Base.Crowbar", name = "a Crowbar"},
        {type = "Base.Pistol", name = "a Pistol"},
    }
    
    local selectedWeapon = weapons[ZombRand(1, #weapons + 1)]
    local killCount = 5 + ZombRand(0, math.floor(reputation / 10))
    local reward = killCount * 15
    
    return {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.ELIMINATION,
        title = "Elimination: " .. killCount .. " Zombies",
        description = "Kill " .. killCount .. " zombies using " .. selectedWeapon.name .. ".",
        requirements = {
            weaponType = selectedWeapon.type,
            killCount = killCount,
        },
        reward = {
            money = reward,
            reputation = Amazoid.Reputation.MISSION_COMPLETE,
        },
        timeLimit = 48, -- 48 game hours
        progress = 0,
    }
end

--- Generate a scavenger hunt mission
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Server.generateScavengerMission(reputation)
    local outfits = {
        {name = "red jacket", description = "Look for a zombie wearing a red jacket."},
        {name = "blue backpack", description = "Find the zombie with a blue backpack."},
        {name = "police uniform", description = "Track down a zombified police officer."},
        {name = "construction vest", description = "Find a zombie in a construction vest."},
    }
    
    local selected = outfits[ZombRand(1, #outfits + 1)]
    local reward = 100 + math.floor(reputation * 2)
    
    return {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.SCAVENGER,
        title = "Scavenger Hunt: " .. selected.name,
        description = selected.description .. " They have something that belongs to me. Return it to the mailbox... or keep it and lose my trust.",
        requirements = {
            targetOutfit = selected.name,
        },
        reward = {
            money = reward,
            reputation = Amazoid.Reputation.MISSION_COMPLETE,
            -- Bonus items found on zombie
        },
        keepPenalty = Amazoid.Reputation.SCAVENGER_KEEP_ITEMS,
        timeLimit = 72, -- 72 game hours
    }
end

--- Generate a timed delivery mission
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Server.generateTimedDeliveryMission(reputation)
    local reward = 150 + math.floor(reputation * 3)
    
    return {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.TIMED_DELIVERY,
        title = "Urgent Delivery",
        description = "Deliver this package to the marked mailbox before sunset. Time is of the essence!",
        requirements = {
            -- Target mailbox location will be set when mission is accepted
            targetMailbox = nil,
        },
        reward = {
            money = reward,
            reputation = Amazoid.Reputation.MISSION_COMPLETE + 2,
        },
        timeLimit = 12, -- Must complete before sunset (roughly 12 hours)
    }
end

--- Generate a protection mission
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Server.generateProtectionMission(reputation)
    local reward = 200 + math.floor(reputation * 4)
    
    return {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.PROTECTION,
        title = "Protection Duty",
        description = "We've placed a... special device in the mailbox. It makes noise. Keep the zombies from destroying it. We'll be watching. This should be entertaining.",
        requirements = {
            survivalTime = 30, -- 30 minutes real-time? Or game hours?
            deviceHealth = 100,
        },
        reward = {
            money = reward,
            reputation = Amazoid.Reputation.MISSION_COMPLETE + 3,
        },
        timeLimit = nil, -- Must protect until device turns off
    }
end

--- Check if gift should be triggered based on player action
---@param player IsoPlayer The player
---@param triggerType string Type of trigger from Amazoid.GiftTriggers
function Amazoid.Server.checkGiftTrigger(player, triggerType)
    -- TODO: Implement gift logic based on player actions and reputation
end

-- Event Hooks

local function onGameStart()
    Amazoid.Server.init()
end

local function onEveryHours()
    -- Process pending orders
    for i = #Amazoid.Server.worldData.activeOrders, 1, -1 do
        local order = Amazoid.Server.worldData.activeOrders[i]
        if Amazoid.Server.processOrder(order) then
            table.remove(Amazoid.Server.worldData.activeOrders, i)
        end
    end
    
    -- Save periodically
    Amazoid.Server.saveWorldData()
end

-- Register events
Events.OnGameStart.Add(onGameStart)
Events.EveryHours.Add(onEveryHours)

print("[Amazoid] Server module loaded")
