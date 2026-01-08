--[[
    Amazoid - Mysterious Mailbox Merchant
    Protection Device System
    
    This file handles the noisy protection device for protection missions.
]]

require "Amazoid/AmazoidData"

Amazoid.ProtectionDevice = Amazoid.ProtectionDevice or {}

-- Active devices
Amazoid.ProtectionDevice.activeDevices = {}

-- Device constants
Amazoid.ProtectionDevice.CONFIG = {
    HEALTH_MAX = 100,
    NOISE_RADIUS = 30,
    NOISE_INTERVAL = 5000,      -- ms between noise bursts
    DAMAGE_PER_HIT = 10,
    DURATION = 30 * 60 * 1000,  -- 30 minutes in ms
}

---@class ProtectionDeviceData
---@field id number Unique device ID
---@field missionId number Associated mission ID
---@field x number X position
---@field y number Y position
---@field z number Z level
---@field health number Current health
---@field startTime number Start time (game time)
---@field duration number Duration in ms
---@field lastNoiseTime number Last noise emission time

--- Create and place a protection device
---@param mailbox IsoObject The mailbox to place device in
---@param missionId number The mission ID
---@return table|nil Device data or nil on failure
function Amazoid.ProtectionDevice.create(mailbox, missionId)
    if not mailbox then return nil end
    
    local deviceId = ZombRand(100000, 999999)
    
    local device = {
        id = deviceId,
        missionId = missionId,
        x = mailbox:getX(),
        y = mailbox:getY(),
        z = mailbox:getZ(),
        health = Amazoid.ProtectionDevice.CONFIG.HEALTH_MAX,
        startTime = getTimestampMs(),
        duration = Amazoid.ProtectionDevice.CONFIG.DURATION,
        lastNoiseTime = 0,
        mailbox = mailbox,
        active = true,
    }
    
    -- Store in active devices
    Amazoid.ProtectionDevice.activeDevices[deviceId] = device
    
    -- Mark mailbox as having device
    local modData = mailbox:getModData()
    modData.AmazoidProtectionDevice = deviceId
    mailbox:transmitModData()
    
    print("[Amazoid] Protection device created: " .. deviceId)
    
    return device
end

--- Remove a protection device
---@param deviceId number The device ID
---@param success boolean Whether protection was successful
function Amazoid.ProtectionDevice.remove(deviceId, success)
    local device = Amazoid.ProtectionDevice.activeDevices[deviceId]
    if not device then return end
    
    -- Clear mailbox mod data
    if device.mailbox then
        local modData = device.mailbox:getModData()
        modData.AmazoidProtectionDevice = nil
        device.mailbox:transmitModData()
    end
    
    -- Complete the mission
    if Amazoid.Client then
        local activeMissions = Amazoid.Client.playerData.activeMissions or {}
        for _, mission in ipairs(activeMissions) do
            if mission.id == device.missionId then
                Amazoid.Client.completeMission(mission.id, success)
                break
            end
        end
    end
    
    -- Remove from tracking
    Amazoid.ProtectionDevice.activeDevices[deviceId] = nil
    
    print("[Amazoid] Protection device removed: " .. deviceId .. " Success: " .. tostring(success))
end

--- Damage a protection device
---@param deviceId number The device ID
---@param damage number Damage amount
function Amazoid.ProtectionDevice.damage(deviceId, damage)
    local device = Amazoid.ProtectionDevice.activeDevices[deviceId]
    if not device or not device.active then return end
    
    device.health = device.health - (damage or Amazoid.ProtectionDevice.CONFIG.DAMAGE_PER_HIT)
    
    print("[Amazoid] Protection device damaged: " .. deviceId .. " Health: " .. device.health)
    
    if device.health <= 0 then
        -- Device destroyed - mission failed
        Amazoid.ProtectionDevice.remove(deviceId, false)
    end
end

--- Emit noise from device (attract zombies)
---@param device table Device data
function Amazoid.ProtectionDevice.emitNoise(device)
    if not device or not device.active then return end
    
    local square = getCell():getGridSquare(device.x, device.y, device.z)
    if not square then return end
    
    -- Create noise to attract zombies
    local radius = Amazoid.ProtectionDevice.CONFIG.NOISE_RADIUS
    addSound(nil, device.x, device.y, device.z, radius, radius)
    
    -- Visual feedback (optional - could add world marker)
    print("[Amazoid] Protection device emitting noise at " .. device.x .. ", " .. device.y)
end

--- Update all active devices
function Amazoid.ProtectionDevice.update()
    local currentTime = getTimestampMs()
    
    for deviceId, device in pairs(Amazoid.ProtectionDevice.activeDevices) do
        if device.active then
            -- Check if duration expired (success!)
            local elapsed = currentTime - device.startTime
            if elapsed >= device.duration then
                Amazoid.ProtectionDevice.remove(deviceId, true)
            else
                -- Emit noise periodically
                local timeSinceNoise = currentTime - device.lastNoiseTime
                if timeSinceNoise >= Amazoid.ProtectionDevice.CONFIG.NOISE_INTERVAL then
                    Amazoid.ProtectionDevice.emitNoise(device)
                    device.lastNoiseTime = currentTime
                end
                
                -- Check for nearby zombies attacking mailbox
                Amazoid.ProtectionDevice.checkZombieAttacks(device)
            end
        end
    end
end

--- Check if zombies are attacking the device
---@param device table Device data
function Amazoid.ProtectionDevice.checkZombieAttacks(device)
    if not device or not device.mailbox then return end
    
    local square = getCell():getGridSquare(device.x, device.y, device.z)
    if not square then return end
    
    -- Check adjacent squares for zombies
    local directions = {
        {0, 0}, {1, 0}, {-1, 0}, {0, 1}, {0, -1},
        {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
    }
    
    for _, dir in ipairs(directions) do
        local checkSquare = getCell():getGridSquare(device.x + dir[1], device.y + dir[2], device.z)
        if checkSquare then
            local movingObjects = checkSquare:getMovingObjects()
            for i = 0, movingObjects:size() - 1 do
                local obj = movingObjects:get(i)
                if instanceof(obj, "IsoZombie") then
                    -- Check if zombie is attacking (simple distance check)
                    local zombieX = obj:getX()
                    local zombieY = obj:getY()
                    local dist = math.sqrt((zombieX - device.x)^2 + (zombieY - device.y)^2)
                    
                    if dist < 1.5 then
                        -- Zombie is at the mailbox - check if attacking
                        -- This is simplified - in reality would need to hook into attack events
                        -- For now, we'll use a probability each update
                        if ZombRand(100) < 5 then -- 5% chance per check
                            Amazoid.ProtectionDevice.damage(device.id, Amazoid.ProtectionDevice.CONFIG.DAMAGE_PER_HIT)
                        end
                    end
                end
            end
        end
    end
end

--- Get device health percentage
---@param deviceId number Device ID
---@return number Health percentage 0-100
function Amazoid.ProtectionDevice.getHealthPercent(deviceId)
    local device = Amazoid.ProtectionDevice.activeDevices[deviceId]
    if not device then return 0 end
    
    return (device.health / Amazoid.ProtectionDevice.CONFIG.HEALTH_MAX) * 100
end

--- Get device time remaining
---@param deviceId number Device ID
---@return number Time remaining in seconds
function Amazoid.ProtectionDevice.getTimeRemaining(deviceId)
    local device = Amazoid.ProtectionDevice.activeDevices[deviceId]
    if not device then return 0 end
    
    local elapsed = getTimestampMs() - device.startTime
    local remaining = device.duration - elapsed
    
    return math.max(0, remaining / 1000) -- Convert to seconds
end

--- Check if device is active at location
---@param x number X position
---@param y number Y position
---@param z number Z level
---@return number|nil Device ID or nil
function Amazoid.ProtectionDevice.getDeviceAtLocation(x, y, z)
    for deviceId, device in pairs(Amazoid.ProtectionDevice.activeDevices) do
        if device.x == x and device.y == y and device.z == z then
            return deviceId
        end
    end
    return nil
end

--- Save device state
function Amazoid.ProtectionDevice.saveState()
    local saveData = {}
    
    for deviceId, device in pairs(Amazoid.ProtectionDevice.activeDevices) do
        saveData[deviceId] = {
            id = device.id,
            missionId = device.missionId,
            x = device.x,
            y = device.y,
            z = device.z,
            health = device.health,
            startTime = device.startTime,
            duration = device.duration,
            lastNoiseTime = device.lastNoiseTime,
            active = device.active,
        }
    end
    
    local modData = ModData.getOrCreate("Amazoid")
    modData.protectionDevices = saveData
    ModData.transmit("Amazoid")
end

--- Load device state
function Amazoid.ProtectionDevice.loadState()
    local modData = ModData.get("Amazoid")
    if not modData or not modData.protectionDevices then return end
    
    for deviceId, data in pairs(modData.protectionDevices) do
        local mailbox = Amazoid.Mailbox.findMailboxAt(data.x, data.y, data.z)
        
        Amazoid.ProtectionDevice.activeDevices[deviceId] = {
            id = data.id,
            missionId = data.missionId,
            x = data.x,
            y = data.y,
            z = data.z,
            health = data.health,
            startTime = data.startTime,
            duration = data.duration,
            lastNoiseTime = data.lastNoiseTime,
            mailbox = mailbox,
            active = data.active,
        }
    end
    
    print("[Amazoid] Loaded " .. #Amazoid.ProtectionDevice.activeDevices .. " protection devices")
end

-- Event handlers

local function onGameStart()
    Amazoid.ProtectionDevice.loadState()
end

local function onTick()
    -- Update devices every few ticks
    if getTimestampMs() % 500 < 20 then
        Amazoid.ProtectionDevice.update()
    end
end

local function onSave()
    Amazoid.ProtectionDevice.saveState()
end

-- Register events
Events.OnGameStart.Add(onGameStart)
Events.OnTick.Add(onTick)
Events.OnSave.Add(onSave)

print("[Amazoid] Protection device system loaded")
