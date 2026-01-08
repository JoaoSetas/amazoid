--[[
    Amazoid - Mysterious Mailbox Merchant
    Mission Tracker
    
    This file handles tracking mission progress and completion.
]]

require "Amazoid/AmazoidData"

Amazoid.MissionTracker = Amazoid.MissionTracker or {}

-- Active tracking data
Amazoid.MissionTracker.killCounts = {}       -- Track kills per weapon type
Amazoid.MissionTracker.scavengerTargets = {} -- Track marked zombies
Amazoid.MissionTracker.protectionDevices = {} -- Track active protection devices

--- Initialize mission tracker
function Amazoid.MissionTracker.init()
    print("[Amazoid] Mission tracker initializing...")
    Amazoid.MissionTracker.loadState()
end

--- Save tracker state
function Amazoid.MissionTracker.saveState()
    local player = getPlayer()
    if not player then return end
    
    local modData = player:getModData()
    modData.AmazoidMissionTracker = {
        killCounts = Amazoid.MissionTracker.killCounts,
    }
end

--- Load tracker state
function Amazoid.MissionTracker.loadState()
    local player = getPlayer()
    if not player then return end
    
    local modData = player:getModData()
    if modData.AmazoidMissionTracker then
        Amazoid.MissionTracker.killCounts = modData.AmazoidMissionTracker.killCounts or {}
    end
end

--- Track a zombie kill
---@param player IsoPlayer The player who killed the zombie
---@param zombie IsoZombie The killed zombie
---@param weapon InventoryItem The weapon used
function Amazoid.MissionTracker.onZombieKill(player, zombie, weapon)
    if not player or not zombie then return end
    
    local weaponType = "any"
    if weapon then
        weaponType = weapon:getFullType()
    end
    
    -- Initialize counters if needed
    Amazoid.MissionTracker.killCounts[weaponType] = (Amazoid.MissionTracker.killCounts[weaponType] or 0) + 1
    Amazoid.MissionTracker.killCounts["any"] = (Amazoid.MissionTracker.killCounts["any"] or 0) + 1
    
    -- Check active elimination missions
    if Amazoid.Client then
        local activeMissions = Amazoid.Client.playerData.activeMissions or {}
        
        for i, mission in ipairs(activeMissions) do
            if mission.type == Amazoid.MissionTypes.ELIMINATION then
                local reqWeapon = mission.requirements.weaponType
                
                -- Check if this kill counts
                if reqWeapon == "any" or reqWeapon == weaponType then
                    mission.progress = (mission.progress or 0) + 1
                    
                    -- Check if mission complete
                    if mission.progress >= mission.requirements.killCount then
                        Amazoid.MissionTracker.completeMission(mission, true)
                    end
                end
            end
        end
    end
    
    -- Check if zombie is a scavenger target
    local zombieId = zombie:getOnlineID()
    if Amazoid.MissionTracker.scavengerTargets[zombieId] then
        local targetData = Amazoid.MissionTracker.scavengerTargets[zombieId]
        Amazoid.MissionTracker.onScavengerTargetKilled(player, zombie, targetData)
    end
    
    Amazoid.MissionTracker.saveState()
end

--- Handle scavenger target killed
---@param player IsoPlayer The player
---@param zombie IsoZombie The killed zombie
---@param targetData table Target data
function Amazoid.MissionTracker.onScavengerTargetKilled(player, zombie, targetData)
    print("[Amazoid] Scavenger target killed!")
    
    -- Spawn the loot item on zombie's corpse or nearby
    if targetData.lootItem then
        local x = zombie:getX()
        local y = zombie:getY()
        local z = zombie:getZ()
        local square = getCell():getGridSquare(x, y, z)
        
        if square then
            -- Add item to ground
            local item = square:AddWorldInventoryItem(targetData.lootItem, x, y, z)
            if item then
                print("[Amazoid] Spawned scavenger loot: " .. targetData.lootItem)
            end
        end
    end
    
    -- Update mission - player can now choose to return or keep
    if Amazoid.Client then
        local activeMissions = Amazoid.Client.playerData.activeMissions or {}
        
        for i, mission in ipairs(activeMissions) do
            if mission.type == Amazoid.MissionTypes.SCAVENGER and mission.id == targetData.missionId then
                mission.targetKilled = true
                mission.lootSpawned = true
                print("[Amazoid] Scavenger mission updated - target killed")
                break
            end
        end
    end
    
    -- Remove from tracking
    local zombieId = zombie:getOnlineID()
    Amazoid.MissionTracker.scavengerTargets[zombieId] = nil
end

--- Mark a zombie as scavenger target
---@param zombie IsoZombie The zombie to mark
---@param missionId number The mission ID
---@param lootItem string The item type to spawn
function Amazoid.MissionTracker.markScavengerTarget(zombie, missionId, lootItem)
    if not zombie then return end
    
    local zombieId = zombie:getOnlineID()
    
    Amazoid.MissionTracker.scavengerTargets[zombieId] = {
        missionId = missionId,
        lootItem = lootItem,
        markedTime = getGameTime():getWorldAgeHours(),
    }
    
    -- Visual indicator (change zombie appearance if possible)
    -- This is complex in PZ - for now just track it
    
    print("[Amazoid] Marked zombie as scavenger target: " .. zombieId)
end

--- Find and mark a random zombie for scavenger mission
---@param player IsoPlayer The player
---@param mission table The mission data
---@return boolean Success
function Amazoid.MissionTracker.setupScavengerMission(player, mission)
    if not player then return false end
    
    -- Find zombies near player
    local cell = getCell()
    local playerX = player:getX()
    local playerY = player:getY()
    local playerZ = player:getZ()
    
    local zombies = {}
    local searchRadius = 100
    
    -- Search for zombies
    for x = playerX - searchRadius, playerX + searchRadius do
        for y = playerY - searchRadius, playerY + searchRadius do
            local square = cell:getGridSquare(x, y, playerZ)
            if square then
                local movingObjects = square:getMovingObjects()
                for i = 0, movingObjects:size() - 1 do
                    local obj = movingObjects:get(i)
                    if instanceof(obj, "IsoZombie") then
                        table.insert(zombies, obj)
                    end
                end
            end
        end
    end
    
    if #zombies == 0 then
        print("[Amazoid] No zombies found for scavenger mission")
        return false
    end
    
    -- Pick a random zombie
    local targetZombie = zombies[ZombRand(1, #zombies + 1)]
    
    -- Determine loot item
    local lootItems = {
        "Base.Wallet",
        "Base.Purse",
        "Base.Bag_Satchel",
        "Base.Bag_Schoolbag",
        "Base.Wallet2",
    }
    local lootItem = lootItems[ZombRand(1, #lootItems + 1)]
    
    -- Mark the zombie
    Amazoid.MissionTracker.markScavengerTarget(targetZombie, mission.id, lootItem)
    
    return true
end

--- Complete a mission
---@param mission table The mission data
---@param success boolean Whether successful
function Amazoid.MissionTracker.completeMission(mission, success)
    if not mission then return end
    
    if Amazoid.Client then
        Amazoid.Client.completeMission(mission.id, success)
        
        -- Add rewards
        if success and mission.reward then
            -- Money reward would be added to mailbox
            print("[Amazoid] Mission reward: $" .. (mission.reward.money or 0))
        end
    end
end

--- Check mission time limits
function Amazoid.MissionTracker.checkMissionTimers()
    if not Amazoid.Client then return end
    
    local currentTime = getGameTime():getWorldAgeHours()
    local activeMissions = Amazoid.Client.playerData.activeMissions or {}
    
    for i = #activeMissions, 1, -1 do
        local mission = activeMissions[i]
        
        if mission.timeLimit and mission.acceptedTime then
            local elapsed = currentTime - mission.acceptedTime
            
            if elapsed >= mission.timeLimit then
                -- Mission timed out
                print("[Amazoid] Mission timed out: " .. mission.title)
                Amazoid.MissionTracker.completeMission(mission, false)
            end
        end
    end
end

--- Reset kill counters (called when starting new elimination mission)
function Amazoid.MissionTracker.resetKillCounters()
    Amazoid.MissionTracker.killCounts = {}
    Amazoid.MissionTracker.saveState()
end

--- Get current kill count for weapon type
---@param weaponType string Weapon type or "any"
---@return number Kill count
function Amazoid.MissionTracker.getKillCount(weaponType)
    return Amazoid.MissionTracker.killCounts[weaponType] or 0
end

-- Event handlers

local function onZombieDead(zombie)
    local player = getPlayer()
    if not player then return end
    
    -- Get the weapon player is holding
    local weapon = player:getPrimaryHandItem()
    
    Amazoid.MissionTracker.onZombieKill(player, zombie, weapon)
end

local function onGameStart()
    Amazoid.MissionTracker.init()
end

local function onEveryHours()
    Amazoid.MissionTracker.checkMissionTimers()
end

local function onSave()
    Amazoid.MissionTracker.saveState()
end

-- Register events
Events.OnZombieDead.Add(onZombieDead)
Events.OnGameStart.Add(onGameStart)
Events.EveryHours.Add(onEveryHours)
Events.OnSave.Add(onSave)

print("[Amazoid] Mission tracker loaded")
