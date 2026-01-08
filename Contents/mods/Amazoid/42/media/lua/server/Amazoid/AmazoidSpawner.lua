--[[
    Amazoid - Mysterious Mailbox Merchant
    Letter Spawning System
    
    This file handles spawning discovery letters in mailboxes.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidMailbox"

Amazoid.Spawner = Amazoid.Spawner or {}

-- Track which cells have been processed
Amazoid.Spawner.processedCells = {}

-- Track if starting house has been processed
Amazoid.Spawner.startingHouseProcessed = false

--- Get sandbox options for letter spawning
---@return table Spawn options
function Amazoid.Spawner.getSpawnOptions()
    local options = {
        spawnChance = 0.1,          -- 10% chance per mailbox
        spawnInStartingHouse = true,
        spawnInAllMailboxes = false,
        maxLettersPerCell = 1,
    }
    
    -- Try to get sandbox options
    if SandboxVars and SandboxVars.Amazoid then
        options.spawnChance = SandboxVars.Amazoid.LetterSpawnChance or 0.1
        options.spawnInStartingHouse = SandboxVars.Amazoid.SpawnInStartingHouse or true
        options.spawnInAllMailboxes = SandboxVars.Amazoid.SpawnInAllMailboxes or false
        options.maxLettersPerCell = SandboxVars.Amazoid.MaxLettersPerCell or 1
    end
    
    return options
end

--- Check if a cell has already been processed
---@param cellX number Cell X coordinate
---@param cellY number Cell Y coordinate
---@return boolean
function Amazoid.Spawner.isCellProcessed(cellX, cellY)
    local key = cellX .. "_" .. cellY
    return Amazoid.Spawner.processedCells[key] == true
end

--- Mark a cell as processed
---@param cellX number Cell X coordinate
---@param cellY number Cell Y coordinate
function Amazoid.Spawner.markCellProcessed(cellX, cellY)
    local key = cellX .. "_" .. cellY
    Amazoid.Spawner.processedCells[key] = true
end

--- Process a cell for letter spawning
---@param cell IsoCell The cell to process
function Amazoid.Spawner.processCell(cell)
    if not cell then return end
    
    local cellX = cell:getChunkMap():getWorldX()
    local cellY = cell:getChunkMap():getWorldY()
    
    if Amazoid.Spawner.isCellProcessed(cellX, cellY) then
        return
    end
    
    local options = Amazoid.Spawner.getSpawnOptions()
    local mailboxes = Amazoid.Mailbox.findMailboxesInCell(cell)
    local lettersSpawned = 0
    
    for _, mailbox in ipairs(mailboxes) do
        if lettersSpawned >= options.maxLettersPerCell then
            break
        end
        
        -- Skip if mailbox already has letter or contract
        if Amazoid.Mailbox.hasDiscoveryLetter(mailbox) or Amazoid.Mailbox.hasContract(mailbox) then
            goto continue
        end
        
        local shouldSpawn = false
        
        if options.spawnInAllMailboxes then
            shouldSpawn = true
        else
            -- Random chance
            local roll = ZombRand(100) / 100.0
            if roll < options.spawnChance then
                shouldSpawn = true
            end
        end
        
        if shouldSpawn then
            Amazoid.Mailbox.addDiscoveryLetter(mailbox)
            lettersSpawned = lettersSpawned + 1
            print("[Amazoid] Spawned discovery letter at " .. Amazoid.Mailbox.getLocationKey(mailbox))
        end
        
        ::continue::
    end
    
    Amazoid.Spawner.markCellProcessed(cellX, cellY)
end

--- Try to spawn letter in starting house mailbox
---@param player IsoPlayer The player
function Amazoid.Spawner.trySpawnStartingHouseLetter(player)
    if Amazoid.Spawner.startingHouseProcessed then
        return
    end
    
    local options = Amazoid.Spawner.getSpawnOptions()
    if not options.spawnInStartingHouse then
        Amazoid.Spawner.startingHouseProcessed = true
        return
    end
    
    -- Find nearest mailbox to player's starting position
    local mailbox = Amazoid.Mailbox.findNearestMailbox(player, 30)
    
    if mailbox then
        if not Amazoid.Mailbox.hasDiscoveryLetter(mailbox) and not Amazoid.Mailbox.hasContract(mailbox) then
            Amazoid.Mailbox.addDiscoveryLetter(mailbox)
            print("[Amazoid] Spawned starting house discovery letter")
        end
    end
    
    Amazoid.Spawner.startingHouseProcessed = true
end

--- Load spawner state from mod data
function Amazoid.Spawner.loadState()
    local modData = ModData.get("Amazoid")
    if modData then
        Amazoid.Spawner.processedCells = modData.processedCells or {}
        Amazoid.Spawner.startingHouseProcessed = modData.startingHouseProcessed or false
    end
end

--- Save spawner state to mod data
function Amazoid.Spawner.saveState()
    local modData = ModData.getOrCreate("Amazoid")
    modData.processedCells = Amazoid.Spawner.processedCells
    modData.startingHouseProcessed = Amazoid.Spawner.startingHouseProcessed
    ModData.transmit("Amazoid")
end

-- Event handlers

local function onLoadCell(cell)
    Amazoid.Spawner.processCell(cell)
end

local function onGameStart()
    Amazoid.Spawner.loadState()
end

local function onPlayerCreated(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if player then
        -- Delay to allow world to load
        Amazoid.Spawner.trySpawnStartingHouseLetter(player)
    end
end

local function onSave()
    Amazoid.Spawner.saveState()
end

-- Register events
Events.LoadGridsquare.Add(function(square)
    if square then
        local cell = square:getCell()
        if cell then
            Amazoid.Spawner.processCell(cell)
        end
    end
end)

Events.OnGameStart.Add(onGameStart)
Events.OnCreatePlayer.Add(onPlayerCreated)
Events.OnSave.Add(onSave)

print("[Amazoid] Spawner system loaded")
