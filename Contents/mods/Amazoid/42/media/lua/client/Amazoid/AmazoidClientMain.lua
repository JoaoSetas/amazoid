--[[
    Amazoid - Mysterious Mailbox Merchant
    Client Entry Point

    This file loads all client-side Amazoid modules.
]]

-- Load UI modules first (context menu depends on these)
require "Amazoid/UI/AmazoidBasePanel"
require "Amazoid/UI/AmazoidLetterPanel"
require "Amazoid/UI/AmazoidCatalogPanel"
require "Amazoid/UI/AmazoidMissionsPanel"

-- Load client modules
require "Amazoid/AmazoidClient"
require "Amazoid/AmazoidMissionTracker"
require "Amazoid/AmazoidProtectionDevice"
require "Amazoid/AmazoidGifts"
require "Amazoid/AmazoidReputationTriggers"
require "Amazoid/AmazoidContextMenu"

print("[Amazoid] Client modules loaded")
