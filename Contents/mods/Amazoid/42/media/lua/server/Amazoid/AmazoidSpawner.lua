--[[
    Amazoid - Mysterious Mailbox Merchant
    Spawner System (Legacy - mostly disabled)

    First contact is now handled by AmazoidClient.lua via merchant visits.
    This file is kept for save/load state compatibility.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidMailbox"

Amazoid.Spawner = Amazoid.Spawner or {}

-- Track which cells have been processed (legacy, kept for compatibility)
Amazoid.Spawner.processedCells = {}

--- Load spawner state from mod data
function Amazoid.Spawner.loadState()
    local modData = ModData.get("Amazoid")
    if modData then
        Amazoid.Spawner.processedCells = modData.processedCells or {}
    end
end

--- Save spawner state to mod data
function Amazoid.Spawner.saveState()
    local modData = ModData.getOrCreate("Amazoid")
    modData.processedCells = Amazoid.Spawner.processedCells
    ModData.transmit("Amazoid")
end

-- Event handlers

local function onGameStart()
    Amazoid.Spawner.loadState()
end

local function onSave()
    Amazoid.Spawner.saveState()
end

Events.OnGameStart.Add(onGameStart)
Events.OnSave.Add(onSave)

print("[Amazoid] Spawner system loaded (first contact handled by client)")
