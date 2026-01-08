--[[
    Amazoid - Mysterious Mailbox Merchant
    Client Module
    
    This file handles client-side logic including UI and player interactions.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidUtils"

Amazoid.Client = Amazoid.Client or {}

-- Player data cache
Amazoid.Client.playerData = {
    reputation = Amazoid.Reputation.STARTING,
    contractStatus = Amazoid.ContractStatus.NONE,
    contractMailbox = nil,  -- The mailbox where contract was signed
    activeMissions = {},
    completedMissions = {},
    pendingOrders = {},
    unlockedCatalogs = {},
    discoveredLore = {},
    giftHistory = {},
}

--- Initialize client module
function Amazoid.Client.init()
    print("[Amazoid] Client module initializing...")
    
    -- Load saved data if exists
    Amazoid.Client.loadPlayerData()
    
    print("[Amazoid] Client module initialized")
end

--- Save player data to mod data
function Amazoid.Client.savePlayerData()
    local player = getPlayer()
    if not player then return end
    
    local modData = player:getModData()
    modData.Amazoid = Amazoid.Client.playerData
    
    print("[Amazoid] Player data saved")
end

--- Load player data from mod data
function Amazoid.Client.loadPlayerData()
    local player = getPlayer()
    if not player then return end
    
    local modData = player:getModData()
    if modData.Amazoid then
        Amazoid.Client.playerData = modData.Amazoid
        print("[Amazoid] Player data loaded - Reputation: " .. Amazoid.Client.playerData.reputation)
    else
        print("[Amazoid] No saved data found, using defaults")
    end
end

--- Get current player reputation
---@return number
function Amazoid.Client.getReputation()
    return Amazoid.Client.playerData.reputation
end

--- Modify player reputation
---@param amount number Amount to add (can be negative)
function Amazoid.Client.modifyReputation(amount)
    local oldRep = Amazoid.Client.playerData.reputation
    Amazoid.Client.playerData.reputation = Amazoid.Utils.clampReputation(oldRep + amount)
    
    local newRep = Amazoid.Client.playerData.reputation
    print("[Amazoid] Reputation changed: " .. oldRep .. " -> " .. newRep)
    
    -- Check for unlock notifications
    Amazoid.Client.checkUnlocks(oldRep, newRep)
    
    -- Save data
    Amazoid.Client.savePlayerData()
end

--- Check if new catalogs/features were unlocked
---@param oldRep number Old reputation
---@param newRep number New reputation
function Amazoid.Client.checkUnlocks(oldRep, newRep)
    -- TODO: Implement unlock notifications
end

--- Check if player has signed contract
---@return boolean
function Amazoid.Client.hasContract()
    return Amazoid.Client.playerData.contractStatus == Amazoid.ContractStatus.ACTIVE
end

--- Sign the merchant contract
---@param mailboxLocation table Location of the mailbox {x, y, z}
function Amazoid.Client.signContract(mailboxLocation)
    Amazoid.Client.playerData.contractStatus = Amazoid.ContractStatus.ACTIVE
    Amazoid.Client.playerData.contractMailbox = mailboxLocation
    
    -- Unlock basic catalog
    Amazoid.Client.playerData.unlockedCatalogs[Amazoid.CatalogCategories.BASIC] = true
    
    print("[Amazoid] Contract signed! Welcome to Amazoid services.")
    Amazoid.Client.savePlayerData()
end

--- Place an order
---@param items table List of items to order
---@param totalPrice number Total price
---@param isRush boolean Rush order
function Amazoid.Client.placeOrder(items, totalPrice, isRush)
    if not Amazoid.Client.hasContract() then
        print("[Amazoid] Error: No active contract")
        return false
    end
    
    local deliveryTime = Amazoid.Utils.calculateDeliveryTime(
        Amazoid.Client.getReputation(),
        isRush
    )
    
    local order = {
        id = ZombRand(100000, 999999),
        items = items,
        totalPrice = totalPrice,
        isRush = isRush,
        deliveryTime = deliveryTime,
        orderTime = getGameTime():getWorldAgeHours(),
        status = "pending",
    }
    
    table.insert(Amazoid.Client.playerData.pendingOrders, order)
    Amazoid.Client.savePlayerData()
    
    print("[Amazoid] Order placed! Delivery in approximately " .. deliveryTime .. " hours.")
    return true
end

--- Accept a mission
---@param mission table Mission data
function Amazoid.Client.acceptMission(mission)
    table.insert(Amazoid.Client.playerData.activeMissions, mission)
    Amazoid.Client.savePlayerData()
    print("[Amazoid] Mission accepted: " .. mission.title)
end

--- Complete a mission
---@param missionId number Mission ID
---@param success boolean Whether mission was successful
function Amazoid.Client.completeMission(missionId, success)
    for i, mission in ipairs(Amazoid.Client.playerData.activeMissions) do
        if mission.id == missionId then
            table.remove(Amazoid.Client.playerData.activeMissions, i)
            table.insert(Amazoid.Client.playerData.completedMissions, {
                mission = mission,
                success = success,
                completedAt = getGameTime():getWorldAgeHours(),
            })
            
            if success then
                Amazoid.Client.modifyReputation(Amazoid.Reputation.MISSION_COMPLETE)
                print("[Amazoid] Mission completed successfully!")
            else
                Amazoid.Client.modifyReputation(Amazoid.Reputation.MISSION_FAIL)
                print("[Amazoid] Mission failed.")
            end
            
            break
        end
    end
end

-- Event Hooks

--- Called when game starts
local function onGameStart()
    Amazoid.Client.init()
end

--- Called when player dies
local function onPlayerDeath(player)
    -- Optionally handle death - maybe reputation penalty?
end

--- Called periodically to check for updates
local function onEveryHours()
    -- Check for order deliveries
    -- Check for mission timeouts
    -- Check for gift triggers
end

-- Register events
Events.OnGameStart.Add(onGameStart)
Events.OnPlayerDeath.Add(onPlayerDeath)
Events.EveryHours.Add(onEveryHours)

print("[Amazoid] Client module loaded")
