--[[
    Amazoid - Mysterious Mailbox Merchant
    Client Entry Point
    
    This file loads all client-side Amazoid modules.
]]

-- Load client modules
require "Amazoid/AmazoidClient"
require "Amazoid/AmazoidMissionTracker"
require "Amazoid/AmazoidProtectionDevice"
require "Amazoid/AmazoidGifts"
require "Amazoid/AmazoidContextMenu"

-- Load UI modules
require "Amazoid/UI/AmazoidBasePanel"
require "Amazoid/UI/AmazoidLetterPanel"
require "Amazoid/UI/AmazoidCatalogPanel"
require "Amazoid/UI/AmazoidMissionsPanel"

print("[Amazoid] Client modules loaded")
