--[[
    Amazoid - Mysterious Mailbox Merchant
    Main Entry Point

    This file loads all Amazoid modules in the correct order.
]]

-- Version info
local AMAZOID_VERSION = "0.1.0"

print("=========================================")
print("  Amazoid - Mysterious Mailbox Merchant")
print("  Version: " .. AMAZOID_VERSION)
print("=========================================")

-- Initialize global namespace
Amazoid = Amazoid or {}
Amazoid.VERSION = AMAZOID_VERSION

-- Load order matters - dependencies first
require "Amazoid/AmazoidData"
require "Amazoid/AmazoidSandbox"
require "Amazoid/AmazoidEvents"
require "Amazoid/AmazoidUtils"
require "Amazoid/AmazoidMailbox"
require "Amazoid/AmazoidLetters"
require "Amazoid/AmazoidItems"
require "Amazoid/AmazoidCatalogs"
require "Amazoid/AmazoidDebug"

print("[Amazoid] Core modules loaded")
print("[Amazoid] Initialization complete!")
