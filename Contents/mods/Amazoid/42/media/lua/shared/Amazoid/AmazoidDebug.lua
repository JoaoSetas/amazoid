--[[
    Amazoid Debug Utilities
    
    Usage in debug console:
        AmazoidDebug.status()           -- Show current player status
        AmazoidDebug.giveRep(20)        -- Add reputation
        AmazoidDebug.setRep(50)         -- Set reputation to specific value
        AmazoidDebug.giveLetter()       -- Give discovery letter
        AmazoidDebug.giveAllCatalogs()  -- Give all catalog items
        AmazoidDebug.listOrders()       -- Show pending orders
        AmazoidDebug.completeOrders()   -- Complete all pending orders
        AmazoidDebug.resetPlayer()      -- Reset player Amazoid data
        AmazoidDebug.reload()           -- Reload all Amazoid Lua files
]]


Quick start with AmazoidDebug.test()
Make code changes in VS Code
Reload with AmazoidDebug.reload() in console
Check logs for [Amazoid] messages


AmazoidDebug = AmazoidDebug or {}

-- Check if we're in debug mode
function AmazoidDebug.isDebugMode()
    return isDebugEnabled and isDebugEnabled() or getDebug and getDebug()
end

-- Print helper with formatting
function AmazoidDebug.log(msg)
    print("[Amazoid Debug] " .. tostring(msg))
end

-- Show current player Amazoid status
function AmazoidDebug.status()
    local player = getPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end
    
    local data = player:getModData().Amazoid or {}
    
    AmazoidDebug.log("=== Player Amazoid Status ===")
    AmazoidDebug.log("Contract Signed: " .. tostring(data.hasContract or false))
    AmazoidDebug.log("Reputation: " .. tostring(data.reputation or 0))
    AmazoidDebug.log("Total Orders: " .. tostring(data.totalOrders or 0))
    AmazoidDebug.log("Total Spent: $" .. tostring(data.totalSpent or 0))
    AmazoidDebug.log("Missions Completed: " .. tostring(data.missionsCompleted or 0))
    AmazoidDebug.log("Active Missions: " .. tostring(data.activeMissions and #data.activeMissions or 0))
    AmazoidDebug.log("Pending Orders: " .. tostring(data.pendingOrders and #data.pendingOrders or 0))
    
    -- Calculate discount
    local discount = 0
    if Amazoid and Amazoid.Utils then
        discount = Amazoid.Utils.calculateDiscount(data.reputation or 0)
    end
    AmazoidDebug.log("Current Discount: " .. tostring(discount * 100) .. "%")
    
    return data
end

-- Add reputation
function AmazoidDebug.giveRep(amount)
    local player = getPlayer()
    if not player then return end
    
    local data = player:getModData().Amazoid or {}
    data.reputation = (data.reputation or 0) + (amount or 10)
    if data.reputation > 100 then data.reputation = 100 end
    if data.reputation < 0 then data.reputation = 0 end
    player:getModData().Amazoid = data
    
    AmazoidDebug.log("Reputation set to: " .. data.reputation)
end

-- Set reputation to specific value
function AmazoidDebug.setRep(value)
    local player = getPlayer()
    if not player then return end
    
    local data = player:getModData().Amazoid or {}
    data.reputation = math.max(0, math.min(100, value or 0))
    player:getModData().Amazoid = data
    
    AmazoidDebug.log("Reputation set to: " .. data.reputation)
end

-- Safe function to add item with error checking
function AmazoidDebug.safeAddItem(inv, itemType)
    local item = InventoryItemFactory.CreateItem(itemType)
    if item then
        inv:addItem(item)
        return true
    else
        AmazoidDebug.log("WARNING: Could not create item: " .. itemType)
        return false
    end
end

-- Give discovery letter
function AmazoidDebug.giveLetter()
    local player = getPlayer()
    if not player then return end
    
    local inv = player:getInventory()
    if AmazoidDebug.safeAddItem(inv, "Amazoid.DiscoveryLetter") then
        AmazoidDebug.log("Discovery letter added to inventory")
    end
end

-- Give all catalogs
function AmazoidDebug.giveAllCatalogs()
    local player = getPlayer()
    if not player then return end
    
    local inv = player:getInventory()
    local count = 0
    if AmazoidDebug.safeAddItem(inv, "Amazoid.BasicCatalog") then count = count + 1 end
    if AmazoidDebug.safeAddItem(inv, "Amazoid.ToolsCatalog") then count = count + 1 end
    if AmazoidDebug.safeAddItem(inv, "Amazoid.WeaponsCatalog") then count = count + 1 end
    if AmazoidDebug.safeAddItem(inv, "Amazoid.MedicalCatalog") then count = count + 1 end
    if AmazoidDebug.safeAddItem(inv, "Amazoid.SeasonalCatalog") then count = count + 1 end
    if AmazoidDebug.safeAddItem(inv, "Amazoid.BlackMarketCatalog") then count = count + 1 end
    AmazoidDebug.log("Added " .. count .. "/6 catalogs to inventory")
end

-- Give signed contract
function AmazoidDebug.giveContract()
    local player = getPlayer()
    if not player then return end
    
    local data = player:getModData().Amazoid or {}
    data.hasContract = true
    data.reputation = data.reputation or 0
    player:getModData().Amazoid = data
    
    local inv = player:getInventory()
    if AmazoidDebug.safeAddItem(inv, "Amazoid.SignedContract") then
        AmazoidDebug.log("Contract signed and added to inventory")
    else
        AmazoidDebug.log("Contract signed (item creation failed)")
    end
end

-- List pending orders
function AmazoidDebug.listOrders()
    local player = getPlayer()
    if not player then return end
    
    local data = player:getModData().Amazoid or {}
    local orders = data.pendingOrders or {}
    
    if #orders == 0 then
        AmazoidDebug.log("No pending orders")
        return
    end
    
    AmazoidDebug.log("=== Pending Orders ===")
    for i, order in ipairs(orders) do
        AmazoidDebug.log(string.format("%d. %d items - Delivery: %s", 
            i, order.itemCount or 0, tostring(order.deliveryTime)))
    end
end

-- Complete all pending orders instantly
function AmazoidDebug.completeOrders()
    local player = getPlayer()
    if not player then return end
    
    local data = player:getModData().Amazoid or {}
    local orders = data.pendingOrders or {}
    
    -- Set all delivery times to now
    local gameTime = getGameTime()
    local currentHour = gameTime:getWorldAgeHours()
    
    for _, order in ipairs(orders) do
        order.deliveryTime = currentHour
    end
    
    player:getModData().Amazoid = data
    AmazoidDebug.log("All orders set for immediate delivery")
end

-- Reset player Amazoid data
function AmazoidDebug.resetPlayer()
    local player = getPlayer()
    if not player then return end
    
    player:getModData().Amazoid = nil
    AmazoidDebug.log("Player Amazoid data reset")
end

-- Reload all Amazoid Lua files
function AmazoidDebug.reload()
    local files = {
        -- Shared
        "shared/Amazoid/AmazoidData.lua",
        "shared/Amazoid/AmazoidSandbox.lua",
        "shared/Amazoid/AmazoidUtils.lua",
        "shared/Amazoid/AmazoidMailbox.lua",
        "shared/Amazoid/AmazoidLetters.lua",
        "shared/Amazoid/AmazoidItems.lua",
        "shared/Amazoid/AmazoidDebug.lua",
        -- Client
        "client/Amazoid/AmazoidClient.lua",
        "client/Amazoid/AmazoidContextMenu.lua",
        "client/Amazoid/AmazoidMissionTracker.lua",
        "client/Amazoid/AmazoidProtectionDevice.lua",
        "client/Amazoid/AmazoidGifts.lua",
        "client/Amazoid/UI/AmazoidBasePanel.lua",
        "client/Amazoid/UI/AmazoidLetterPanel.lua",
        "client/Amazoid/UI/AmazoidCatalogPanel.lua",
        "client/Amazoid/UI/AmazoidMissionsPanel.lua",
        -- Server
        "server/Amazoid/AmazoidServer.lua",
        "server/Amazoid/AmazoidSpawner.lua",
    }
    
    AmazoidDebug.log("Reloading Amazoid files...")
    local success = 0
    local failed = 0
    
    for _, file in ipairs(files) do
        local ok, err = pcall(function()
            reloadLuaFile(file)
        end)
        if ok then
            success = success + 1
        else
            failed = failed + 1
            AmazoidDebug.log("Failed to reload: " .. file)
        end
    end
    
    AmazoidDebug.log(string.format("Reload complete: %d success, %d failed", success, failed))
end

-- Spawn protection device for testing
function AmazoidDebug.spawnDevice()
    local player = getPlayer()
    if not player then return end
    
    local inv = player:getInventory()
    if AmazoidDebug.safeAddItem(inv, "Amazoid.ProtectionDevice") then
        AmazoidDebug.log("Protection device added to inventory")
    end
end

-- Dump a table for inspection
function AmazoidDebug.dump(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        print(indent .. tostring(t))
        return
    end
    
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. " = {")
            AmazoidDebug.dump(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

-- Quick test function
function AmazoidDebug.test()
    AmazoidDebug.log("Running quick test...")
    AmazoidDebug.giveContract()
    AmazoidDebug.setRep(25)
    AmazoidDebug.giveAllCatalogs()
    AmazoidDebug.giveLetter()
    AmazoidDebug.status()
    AmazoidDebug.log("Test complete! Check your inventory.")
end

print("[Amazoid] Debug utilities loaded - use AmazoidDebug.test() in console")
