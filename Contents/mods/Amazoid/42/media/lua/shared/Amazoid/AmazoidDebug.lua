--[[
    Amazoid Debug Utilities

    Usage in debug console:

    === STATUS & INFO ===
        AmazoidDebug.status()             -- Show current player status (rep, contract, missions)
        AmazoidDebug.mailboxStatus()      -- Show contracted mailbox status and contents
        AmazoidDebug.diagnoseMissions()   -- Detailed mission diagnostics (progress, requirements)
        AmazoidDebug.listOrders()         -- Show pending orders
        AmazoidDebug.listEditions()       -- List all available catalog editions
        AmazoidDebug.showSeason()         -- Show current game season
        AmazoidDebug.scanMailboxes()      -- Scan for nearby mailboxes

    === REPUTATION ===
        AmazoidDebug.giveRep(20)          -- Add reputation
        AmazoidDebug.setRep(50)           -- Set reputation to specific value

    === ITEMS ===
        AmazoidDebug.giveLetter()         -- Give discovery letter
        AmazoidDebug.giveContract()       -- Give signed contract
        AmazoidDebug.giveCatalog()        -- Give a basic catalog (Vol. I)
        AmazoidDebug.giveCatalogEdition("tools_vol2") -- Give specific catalog edition
        AmazoidDebug.giveAllCatalogs()    -- Give ALL catalog editions (all types, all volumes)
        AmazoidDebug.giveAllEditions("weapons") -- Give all editions of a catalog type
        AmazoidDebug.spawnDevice()        -- Spawn protection device item

    === MISSIONS ===
        AmazoidDebug.giveMission()        -- Give a random collection mission
        AmazoidDebug.giveEliminationMission() -- Give an elimination mission
        AmazoidDebug.simulateKills(5)     -- Simulate 5 zombie kills for elimination missions
        AmazoidDebug.simulateKills(10, "Base.Axe") -- Simulate kills with specific weapon
        AmazoidDebug.clearMissions()      -- Clear all active missions
        AmazoidDebug.processMissionsNow() -- Process missions at mailbox immediately
        AmazoidDebug.testWeapon()         -- Test if equipped weapon counts as melee/firearm
        AmazoidDebug.testWeapon("Base.Sword") -- Test specific weapon type detection

    === ORDERS ===
        AmazoidDebug.completeOrders()     -- Complete all pending orders

    === MERCHANT & MAILBOX ===
        AmazoidDebug.merchantVisit()      -- Trigger merchant visit now
        AmazoidDebug.firstContact()       -- Force first contact (gives discovery letter)
        AmazoidDebug.setContractMailbox() -- Set nearest mailbox as contract mailbox
        AmazoidDebug.teleportToMailbox()  -- Teleport to discovery/contract mailbox (or nearest)

    === RESET ===
        AmazoidDebug.reset()              -- Reset ALL Amazoid data (player, mailboxes, world)
        AmazoidDebug.killPlayer()         -- Kill the player (testing death scenarios)
        AmazoidDebug.dump(table)          -- Pretty-print a Lua table

    === DEVELOPMENT ===
        AmazoidDebug.reload()             -- Reload all Amazoid Lua files
        AmazoidDebug.testCatalogSpawning() -- Test catalog spawning logic

    === QUICK START ===
        AmazoidDebug.test()               -- Give ALL items and set up for testing

    Workflow:
        1. Add -debug to Steam launch options
        2. Load save with Amazoid mod
        3. Open Lua console
        4. Run AmazoidDebug.test() to set up
        5. Make code changes in VS Code
        6. Reload with AmazoidDebug.reload()
        7. Check console for [Amazoid] messages
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidCatalogs"
require "Amazoid/AmazoidMissions"

AmazoidDebug = AmazoidDebug or {}

--- Get the local player (split-screen aware)
--- In split-screen, getPlayer() returns player 2 for both instances.
--- This function properly gets the first available local player.
---@return IsoPlayer|nil The first local player or nil
function AmazoidDebug.getLocalPlayer()
    -- First try Amazoid.Client.getAllLocalPlayers if available (client-side)
    if Amazoid and Amazoid.Client and Amazoid.Client.getAllLocalPlayers then
        local players = Amazoid.Client.getAllLocalPlayers()
        if players and #players > 0 then
            return players[1]
        end
    end

    -- Fallback: Use IsoPlayer.getPlayers() directly
    local allPlayers = IsoPlayer.getPlayers()
    if allPlayers and allPlayers:size() > 0 then
        -- Return the first non-dead player
        for i = 0, allPlayers:size() - 1 do
            local p = allPlayers:get(i)
            if p and not p:isDead() then
                return p
            end
        end
    end

    -- Last resort: try getPlayer() (may be wrong in split-screen)
    return getPlayer()
end

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
    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    local data = player:getModData().Amazoid or {}

    AmazoidDebug.log("=== Player Amazoid Status ===")
    AmazoidDebug.log("Contract Signed: " .. tostring(data.hasContract or false))
    AmazoidDebug.log("Contract Status: " .. tostring(data.contractStatus or "NONE"))
    AmazoidDebug.log("Reputation: " .. tostring(data.reputation or 0))

    -- Show contract mailbox location
    if data.contractMailbox then
        AmazoidDebug.log("Contract Mailbox: " ..
            data.contractMailbox.x .. "," .. data.contractMailbox.y .. "," .. data.contractMailbox.z)
    else
        AmazoidDebug.log("Contract Mailbox: NOT SET (use AmazoidDebug.setContractMailbox())")
    end

    AmazoidDebug.log("Total Orders: " .. tostring(data.totalOrders or 0))
    AmazoidDebug.log("Total Spent: $" .. tostring(data.totalSpent or 0))
    AmazoidDebug.log("Missions Completed: " .. tostring(data.totalMissionsCompleted or data.missionsCompleted or 0))
    AmazoidDebug.log("Active Missions: " .. tostring(data.activeMissions and #data.activeMissions or 0))

    -- Show active mission details
    if data.activeMissions and #data.activeMissions > 0 then
        for i, mission in ipairs(data.activeMissions) do
            AmazoidDebug.log("  Mission " .. i .. ": " .. (mission.title or "Unknown"))
            if mission.requirements then
                AmazoidDebug.log("    - Need: " ..
                    (mission.requirements.count or 0) .. "x " .. (mission.requirements.itemType or "unknown"))
            end
            if mission.reward then
                AmazoidDebug.log("    - Reward: $" ..
                    (mission.reward.money or 0) .. ", +" .. (mission.reward.reputation or 0) .. " rep")
            end
        end
    end

    AmazoidDebug.log("Pending Orders: " .. tostring(data.pendingOrders and #data.pendingOrders or 0))

    -- Calculate discount
    local discount = 0
    if Amazoid and Amazoid.Utils then
        discount = Amazoid.Utils.calculateDiscount(data.reputation or 0)
    end
    AmazoidDebug.log("Current Discount: " .. tostring(discount * 100) .. "%")

    -- Show catalog unlock status
    local reputation = data.reputation or 0
    AmazoidDebug.log("")
    AmazoidDebug.log("=== Catalog Unlock Status ===")
    local thresholds = {
        { name = "Basic",       rep = 0,  category = "basic" },
        { name = "Medical",     rep = 10, category = "medical" },
        { name = "Tools",       rep = 25, category = "tools" },
        { name = "Seasonal",    rep = 35, category = "seasonal" },
        { name = "Weapons",     rep = 45, category = "weapons" },
        { name = "Blackmarket", rep = 60, category = "blackmarket" },
    }
    local unlockedCategories = data.unlockedCategories or {}
    for _, t in ipairs(thresholds) do
        local unlocked = unlockedCategories[t.category] or (t.rep == 0)
        local status = unlocked and "[UNLOCKED]" or "[LOCKED - need " .. t.rep .. " rep]"
        AmazoidDebug.log("  " .. t.name .. ": " .. status)
    end

    -- Show next unlock
    local nextUnlock = nil
    for _, t in ipairs(thresholds) do
        if reputation < t.rep then
            nextUnlock = t
            break
        end
    end
    if nextUnlock then
        AmazoidDebug.log("Next catalog unlock: " ..
            nextUnlock.name .. " at " .. nextUnlock.rep .. " rep (need " .. (nextUnlock.rep - reputation) .. " more)")
    else
        AmazoidDebug.log("All catalog categories unlocked!")
    end

    -- Show seasonal catalog status
    local currentSeason = "unknown"
    if Amazoid.Utils and Amazoid.Utils.getCurrentSeason then
        currentSeason = Amazoid.Utils.getCurrentSeason()
    end
    local lastSeasonCatalog = data.lastSeasonCatalog or "none"
    AmazoidDebug.log("")
    AmazoidDebug.log("=== Seasonal ===")
    AmazoidDebug.log("Current Season: " .. currentSeason)
    AmazoidDebug.log("Last Season Catalog: " .. lastSeasonCatalog)
    if currentSeason ~= lastSeasonCatalog then
        AmazoidDebug.log("Seasonal catalog available: YES (will receive on next merchant visit)")
    else
        AmazoidDebug.log("Seasonal catalog available: NO (already received for " .. currentSeason .. ")")
    end

    -- Show day tracking
    local currentDay = math.floor(getGameTime():getWorldAgeHours() / 24)
    local lastCatalogDay = data.lastCatalogDay or 0
    local lastMissionDay = data.lastMissionDay or 0
    AmazoidDebug.log("")
    AmazoidDebug.log("=== Day Tracking ===")
    AmazoidDebug.log("Current Day: " .. currentDay)
    AmazoidDebug.log("Last Catalog Day: " ..
        lastCatalogDay .. (currentDay > lastCatalogDay and " (can receive today)" or " (already received today)"))
    AmazoidDebug.log("Last Mission Day: " ..
        lastMissionDay .. (currentDay > lastMissionDay and " (can receive today)" or " (already received today)"))

    return data
end

-- Add reputation
function AmazoidDebug.giveRep(amount)
    if not Amazoid.Client or not Amazoid.Client.modifyReputation then
        AmazoidDebug.log("Amazoid.Client.modifyReputation not available")
        return
    end

    Amazoid.Client.modifyReputation(amount or 10, "debug")
    AmazoidDebug.log("Reputation modified by: " .. (amount or 10))
end

-- Give player a mission for testing
function AmazoidDebug.giveMission()
    local mailbox = AmazoidDebug.getContractMailbox()
    if not mailbox then return end

    local mission = Amazoid.Mailbox.spawnMission(mailbox, "collection", true, true)
    if mission then
        AmazoidDebug.log("Collection mission added: " .. (mission.title or "Unknown"))
        if mission.requirements then
            AmazoidDebug.log("  - Need: " ..
                (mission.requirements.count or 0) .. "x " .. (mission.requirements.itemType or "Unknown"))
        end
        if mission.reward then
            AmazoidDebug.log("  - Reward: $" ..
                (mission.reward.money or 0) .. ", +" .. (mission.reward.reputation or 0) .. " rep")
        end
    else
        AmazoidDebug.log("Failed to generate mission")
    end

    return mission
end

-- Give player an elimination mission for testing
function AmazoidDebug.giveEliminationMission()
    local mailbox = AmazoidDebug.getContractMailbox()
    if not mailbox then return end

    local mission = Amazoid.Mailbox.spawnMission(mailbox, "elimination", true, true)
    if mission then
        AmazoidDebug.log("Elimination mission added: " .. (mission.title or "Unknown"))
        if mission.requirements then
            AmazoidDebug.log("  - Kill: " ..
                (mission.requirements.killCount or 0) ..
                " zombies with " .. (mission.requirements.weaponName or "any weapon"))
        end
        if mission.reward then
            AmazoidDebug.log("  - Reward: $" ..
                (mission.reward.money or 0) .. ", +" .. (mission.reward.reputation or 0) .. " rep")
        end
    else
        AmazoidDebug.log("Failed to generate elimination mission")
    end

    return mission
end

-- Helper function to get the contract mailbox
function AmazoidDebug.getContractMailbox()
    if not Amazoid.Client or not Amazoid.Client.playerData then
        AmazoidDebug.log("Client not initialized")
        return nil
    end

    local mailboxLoc = Amazoid.Client.playerData.contractMailbox
    if not mailboxLoc then
        AmazoidDebug.log("No contract mailbox set. Use AmazoidDebug.setContractMailbox() first")
        return nil
    end

    local mailbox = Amazoid.Mailbox.getMailboxAt(mailboxLoc.x, mailboxLoc.y, mailboxLoc.z)
    if not mailbox then
        AmazoidDebug.log("Could not find mailbox at " .. mailboxLoc.x .. "," .. mailboxLoc.y .. "," .. mailboxLoc.z)
        return nil
    end

    return mailbox
end

-- Simulate zombie kills for testing elimination missions
---@param count number Number of kills to simulate (default 1)
---@param weaponType string|nil Weapon type to use (default "Base.BaseballBat")
function AmazoidDebug.simulateKills(count, weaponType)
    count = count or 1
    weaponType = weaponType or "Base.BaseballBat" -- Default melee weapon

    -- Use core MissionTracker function
    if Amazoid.MissionTracker and Amazoid.MissionTracker.recordKills then
        local updatedCount = Amazoid.MissionTracker.recordKills(count, weaponType)
        if updatedCount > 0 then
            AmazoidDebug.log("Added " .. updatedCount .. " kills with weapon: " .. weaponType)
        else
            AmazoidDebug.log("No matching elimination missions found")
        end
    else
        AmazoidDebug.log("MissionTracker.recordKills not available")
    end
end

-- Test if current weapon is detected as melee/firearm
-- Usage: AmazoidDebug.testWeapon() -- tests equipped weapon
-- Usage: AmazoidDebug.testWeapon("Base.Sword") -- tests specific item type
function AmazoidDebug.testWeapon(weaponType)
    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    -- If no weaponType provided, use equipped weapon
    if not weaponType then
        local weapon = player:getPrimaryHandItem()
        if weapon then
            weaponType = weapon:getFullType()
        else
            AmazoidDebug.log("No weapon equipped and no weapon type provided")
            return
        end
    end

    AmazoidDebug.log("=== Weapon Detection Test ===")
    AmazoidDebug.log("Weapon Type: " .. tostring(weaponType))

    if Amazoid.Missions then
        local isMelee = Amazoid.Missions.isWeaponMelee and Amazoid.Missions.isWeaponMelee(weaponType) or false
        local isRanged = Amazoid.Missions.isWeaponRanged and Amazoid.Missions.isWeaponRanged(weaponType) or false

        AmazoidDebug.log("Is Melee: " .. tostring(isMelee))
        AmazoidDebug.log("Is Ranged/Firearm: " .. tostring(isRanged))

        -- Test against requirements
        if Amazoid.Missions.weaponMatchesRequirement then
            AmazoidDebug.log("Matches 'any': " .. tostring(Amazoid.Missions.weaponMatchesRequirement(weaponType, "any")))
            AmazoidDebug.log("Matches 'melee': " ..
                tostring(Amazoid.Missions.weaponMatchesRequirement(weaponType, "melee")))
            AmazoidDebug.log("Matches 'firearm': " ..
                tostring(Amazoid.Missions.weaponMatchesRequirement(weaponType, "firearm")))
        end
    else
        AmazoidDebug.log("ERROR: Amazoid.Missions not loaded")
    end
end

-- Clear all active missions
function AmazoidDebug.clearMissions()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    if Amazoid.Client and Amazoid.Client.playerData then
        Amazoid.Client.playerData.activeMissions = {}
        Amazoid.Client.savePlayerData()
        AmazoidDebug.log("All active missions cleared")
    end
end

-- Diagnose mission issues - shows detailed info about active missions and mailbox contents
function AmazoidDebug.diagnoseMissions()
    AmazoidDebug.log("=== Mission Diagnosis ===")

    -- Check client data
    if not Amazoid.Client or not Amazoid.Client.playerData then
        AmazoidDebug.log("ERROR: Amazoid.Client.playerData not initialized!")
        return
    end

    local playerData = Amazoid.Client.playerData
    local activeMissions = playerData.activeMissions or {}
    local completedMissions = playerData.completedMissions or {}

    AmazoidDebug.log("Active missions: " .. #activeMissions)
    AmazoidDebug.log("Completed missions: " .. #completedMissions)

    -- Show each active mission details
    for i, mission in ipairs(activeMissions) do
        AmazoidDebug.log("--- Active Mission #" .. i .. " ---")
        AmazoidDebug.log("  ID: " .. tostring(mission.id))
        AmazoidDebug.log("  Type: " .. tostring(mission.type))
        AmazoidDebug.log("  Title: " .. tostring(mission.title))
        AmazoidDebug.log("  Status: " .. tostring(mission.status))
        AmazoidDebug.log("  MissionNumber: " .. tostring(mission.missionNumber))

        -- Check raw vs deserialized
        local deserialized = Amazoid.Missions.deserializeFromModData(mission)
        if deserialized and deserialized.requirements then
            if mission.type == Amazoid.MissionTypes.COLLECTION then
                AmazoidDebug.log("  Requirements (deserialized):")
                AmazoidDebug.log("    itemType: " .. tostring(deserialized.requirements.itemType))
                AmazoidDebug.log("    count: " .. tostring(deserialized.requirements.count))
            elseif mission.type == Amazoid.MissionTypes.ELIMINATION then
                AmazoidDebug.log("  Requirements (deserialized):")
                AmazoidDebug.log("    killCount: " .. tostring(deserialized.requirements.killCount))
                AmazoidDebug.log("    progress: " .. tostring(deserialized.progress or mission.progress or 0))
            end
        else
            AmazoidDebug.log("  ERROR: Failed to deserialize mission!")
            AmazoidDebug.log("  Raw keys: ")
            for k, v in pairs(mission) do
                AmazoidDebug.log("    " .. tostring(k) .. " = " .. tostring(v))
            end
        end
    end

    -- Check mailbox contents
    local mailboxLoc = playerData.contractMailbox
    if not mailboxLoc then
        AmazoidDebug.log("No contract mailbox set")
        return
    end

    local mailbox = Amazoid.Mailbox.getMailboxAt(mailboxLoc.x, mailboxLoc.y, mailboxLoc.z)
    if not mailbox then
        AmazoidDebug.log("Could not find mailbox at location")
        return
    end

    local container = mailbox:getContainer()
    if not container then
        AmazoidDebug.log("Mailbox has no container!")
        return
    end

    AmazoidDebug.log("--- Mailbox Contents ---")
    local items = container:getItems()
    local itemCounts = {}

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local fullType = item:getFullType()
        itemCounts[fullType] = (itemCounts[fullType] or 0) + 1
    end

    for itemType, count in pairs(itemCounts) do
        AmazoidDebug.log("  " .. count .. "x " .. itemType)
    end

    -- Check if any active collection missions can be completed
    AmazoidDebug.log("--- Mission Completion Check ---")
    for i, mission in ipairs(activeMissions) do
        local deserialized = Amazoid.Missions.deserializeFromModData(mission)
        if deserialized and deserialized.type == Amazoid.MissionTypes.COLLECTION then
            local reqType = deserialized.requirements and deserialized.requirements.itemType
            local reqCount = deserialized.requirements and deserialized.requirements.count or 1
            local foundCount = itemCounts[reqType] or 0

            AmazoidDebug.log("  Mission " .. i .. " (COLLECTION): Need " .. reqCount .. "x " .. tostring(reqType))
            AmazoidDebug.log("    Found: " ..
                foundCount .. " - " .. (foundCount >= reqCount and "READY!" or "Not enough"))
        elseif deserialized and deserialized.type == Amazoid.MissionTypes.ELIMINATION then
            local reqKills = deserialized.requirements and deserialized.requirements.killCount or 10
            local reqWeapon = deserialized.requirements and deserialized.requirements.weaponType or "any"
            local progress = deserialized.progress or mission.progress or 0
            local status = deserialized.status or mission.status or "active"

            AmazoidDebug.log("  Mission " .. i .. " (ELIMINATION): Kill " .. reqKills .. " with " .. tostring(reqWeapon))
            AmazoidDebug.log("    Progress: " .. progress .. "/" .. reqKills .. " - Status: " .. status)
            if progress >= reqKills then
                AmazoidDebug.log("    COMPLETE! Visit mailbox to claim reward.")
            end
        end
    end

    AmazoidDebug.log("=== End Diagnosis ===")
end

-- Force process missions now (manually trigger mission processing)
function AmazoidDebug.processMissionsNow()
    local mailboxLoc = nil
    if Amazoid.Client and Amazoid.Client.playerData then
        mailboxLoc = Amazoid.Client.playerData.contractMailbox
    end

    if not mailboxLoc then
        AmazoidDebug.log("No contract mailbox set")
        return
    end

    local mailbox = Amazoid.Mailbox.getMailboxAt(mailboxLoc.x, mailboxLoc.y, mailboxLoc.z)
    if not mailbox then
        AmazoidDebug.log("Could not find mailbox")
        return
    end

    AmazoidDebug.log("Processing missions at mailbox...")
    local result = Amazoid.Mailbox.processMissions(mailbox)

    if result then
        AmazoidDebug.log("Completed " .. #result.completedMissions .. " mission(s)!")
        AmazoidDebug.log("  Money reward: $" .. result.moneyReward)
        AmazoidDebug.log("  Reputation reward: +" .. result.reputationReward)
    else
        AmazoidDebug.log("No missions completed (check diagnoseMissions for details)")
    end
end

-- Set reputation to specific value
function AmazoidDebug.setRep(value)
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    local data = player:getModData().Amazoid or {}
    data.reputation = math.max(0, math.min(100, value or 0))
    player:getModData().Amazoid = data

    AmazoidDebug.log("Reputation set to: " .. data.reputation)
end

-- Safe function to add item with error checking
function AmazoidDebug.safeAddItem(inv, itemType)
    -- Try instanceItem first (Build 42 method)
    local item = instanceItem(itemType)
    if item then
        inv:addItem(item)
        return item
    end

    -- Fallback: try InventoryItemFactory if available
    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        item = InventoryItemFactory.CreateItem(itemType)
        if item then
            inv:addItem(item)
            return item
        end
    end

    -- Last resort: try AddItem directly (older method)
    local result = inv:AddItem(itemType)
    if result then
        return result
    end

    AmazoidDebug.log("WARNING: Could not create item: " .. itemType)
    return nil
end

-- Add a numbered item (for MerchantLetter and OrderReceipt)
function AmazoidDebug.addNumberedItem(inv, itemType, baseName, counterKey)
    local item = AmazoidDebug.safeAddItem(inv, itemType)
    if item then
        -- Get and increment the counter from global mod data
        local globalData = ModData.getOrCreate("Amazoid")
        globalData[counterKey] = (globalData[counterKey] or 0) + 1
        local count = globalData[counterKey]

        -- Set unique name with number
        item:setName(baseName .. " #" .. count)
        item:getModData().AmazoidLetterNumber = count
        return true
    end
    return false
end

-- Give discovery letter
function AmazoidDebug.giveLetter()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    local inv = player:getInventory()
    if AmazoidDebug.safeAddItem(inv, "Amazoid.DiscoveryLetter") then
        AmazoidDebug.log("Discovery letter added to inventory")
    end
end

-- Give all catalog editions (all types, all volumes)
function AmazoidDebug.giveAllCatalogs()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    -- Debug: Check what's loaded
    if not Amazoid then
        AmazoidDebug.log("ERROR: Amazoid global not defined")
        return
    end

    if not Amazoid.Catalogs then
        AmazoidDebug.log("ERROR: Amazoid.Catalogs not defined - loading now...")
        -- Try to load it now
        pcall(function() require "Amazoid/AmazoidCatalogs" end)
        if not Amazoid.Catalogs then
            AmazoidDebug.log("ERROR: Still not loaded after require")
            return
        end
    end

    if not Amazoid.Catalogs.Editions then
        AmazoidDebug.log("ERROR: Amazoid.Catalogs.Editions not defined")
        return
    end

    -- Give all editions for each catalog type
    local catalogTypes = { "basic", "tools", "weapons", "medical", "seasonal", "blackmarket" }
    local totalCount = 0

    for _, catalogType in ipairs(catalogTypes) do
        local count = 0
        for id, edition in pairs(Amazoid.Catalogs.Editions) do
            if edition.catalogType == catalogType then
                AmazoidDebug.giveCatalogEdition(id)
                count = count + 1
                totalCount = totalCount + 1
            end
        end
        if count > 0 then
            AmazoidDebug.log("Added " .. count .. " " .. catalogType .. " catalog editions")
        end
    end

    AmazoidDebug.log("Total: " .. totalCount .. " catalog editions added to inventory")
end

-- Give a single basic catalog for quick testing
function AmazoidDebug.giveCatalog()
    AmazoidDebug.giveCatalogEdition("basic_vol1")
end

-- Give a catalog with a specific edition
---@param editionId string Edition ID from AmazoidCatalogs (e.g., "basic_vol1", "weapons_vol2", "seasonal_winter")
function AmazoidDebug.giveCatalogEdition(editionId)
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    if not Amazoid.Catalogs or not Amazoid.Catalogs.Editions then
        AmazoidDebug.log("Catalog system not loaded")
        return
    end

    local edition = Amazoid.Catalogs.getEdition(editionId)
    if not edition then
        AmazoidDebug.log("Unknown edition: " .. tostring(editionId))
        AmazoidDebug.log("Available editions:")
        for id, _ in pairs(Amazoid.Catalogs.Editions) do
            AmazoidDebug.log("  - " .. id)
        end
        return
    end

    -- Create the unified catalog item
    local item = instanceItem("Amazoid.Catalog")
    if not item then
        AmazoidDebug.log("Could not create catalog item")
        return
    end

    -- Set the edition in modData
    local modData = item:getModData()
    modData.AmazoidEdition = editionId
    modData.AmazoidCircled = {}

    -- Set display name to show the edition
    if item.setName then
        item:setName(edition.title .. " - " .. edition.subtitle)
    end

    player:getInventory():addItem(item)
    AmazoidDebug.log("Added catalog: " .. edition.title .. " - " .. edition.subtitle .. " (" .. editionId .. ")")
end

-- List all available catalog editions
function AmazoidDebug.listEditions()
    if not Amazoid.Catalogs or not Amazoid.Catalogs.Editions then
        AmazoidDebug.log("Catalog system not loaded")
        return
    end

    AmazoidDebug.log("=== Catalog Editions ===")

    local types = { "basic", "tools", "weapons", "medical", "seasonal", "blackmarket" }

    for _, catType in ipairs(types) do
        AmazoidDebug.log("-- " .. string.upper(catType) .. " --")
        for id, edition in pairs(Amazoid.Catalogs.Editions) do
            if edition.catalogType == catType then
                local seasonStr = edition.season and (" [" .. edition.season .. " only]") or ""
                local repStr = " (Rep " .. edition.reputationRequired .. "+)"
                AmazoidDebug.log("  " .. id .. ": " .. edition.title .. " - " .. edition.subtitle .. repStr .. seasonStr)
            end
        end
    end
end

-- Give all editions of a specific catalog type
---@param catalogType string Catalog type (basic, tools, weapons, medical, seasonal, blackmarket)
function AmazoidDebug.giveAllEditions(catalogType)
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    if not Amazoid.Catalogs or not Amazoid.Catalogs.Editions then
        AmazoidDebug.log("Catalog system not loaded")
        return
    end

    local count = 0
    for id, edition in pairs(Amazoid.Catalogs.Editions) do
        if edition.catalogType == catalogType then
            AmazoidDebug.giveCatalogEdition(id)
            count = count + 1
        end
    end

    AmazoidDebug.log("Added " .. count .. " " .. catalogType .. " catalog editions")
end

-- Test catalog spawning (reputation and volume unlocks)
function AmazoidDebug.testCatalogSpawning()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    local mailboxLoc = nil
    if Amazoid.Client and Amazoid.Client.playerData then
        mailboxLoc = Amazoid.Client.playerData.contractMailbox
    end

    if not mailboxLoc then
        AmazoidDebug.log("No contract mailbox set. Use AmazoidDebug.setContractMailbox() first")
        return
    end

    local mailbox = Amazoid.Mailbox.getMailboxAt(mailboxLoc.x, mailboxLoc.y, mailboxLoc.z)
    if not mailbox then
        AmazoidDebug.log("Could not find mailbox")
        return
    end

    -- Reset the last spawn day to force a new catalog
    Amazoid.Mailbox.setLastCatalogSpawnDay(mailbox, 0)

    local reputation = 50 -- High reputation to test all catalogs
    local spawned = Amazoid.Mailbox.spawnCatalogs(mailbox, reputation)

    if spawned then
        AmazoidDebug.log("Catalog spawned in mailbox!")
    else
        AmazoidDebug.log("No catalog spawned (check logs)")
    end
end

-- Show current season
function AmazoidDebug.showSeason()
    if Amazoid.Utils and Amazoid.Utils.getCurrentSeason then
        local season = Amazoid.Utils.getCurrentSeason()
        AmazoidDebug.log("Current season: " .. season)

        local gameTime = getGameTime()
        if gameTime then
            local month = gameTime:getMonth() + 1
            local day = gameTime:getDay()
            AmazoidDebug.log("Game date: Month " .. month .. ", Day " .. day)
        end
    else
        AmazoidDebug.log("Season system not loaded")
    end
end

-- Give signed contract
function AmazoidDebug.giveContract()
    local player = AmazoidDebug.getLocalPlayer()
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
    local player = AmazoidDebug.getLocalPlayer()
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

-- Complete all pending orders instantly (deliver items now)
function AmazoidDebug.completeOrders()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    -- Get the contracted mailbox
    local mailboxLoc = nil
    if Amazoid.Client and Amazoid.Client.playerData then
        mailboxLoc = Amazoid.Client.playerData.contractMailbox
    end

    if not mailboxLoc then
        AmazoidDebug.log("No contract mailbox found")
        return
    end

    local mailbox = Amazoid.Mailbox.getMailboxAt(mailboxLoc.x, mailboxLoc.y, mailboxLoc.z)
    if not mailbox then
        AmazoidDebug.log("Could not find mailbox at " .. mailboxLoc.x .. "," .. mailboxLoc.y .. "," .. mailboxLoc.z)
        return
    end

    -- Get orders from mailbox
    local modData = mailbox:getModData()
    local orders = modData.AmazoidPendingOrders or {}

    if #orders == 0 then
        AmazoidDebug.log("No pending orders in mailbox")
        return
    end

    -- Set all delivery times to 0 so they deliver immediately
    for _, order in ipairs(orders) do
        order.orderTime = 0
        order.deliveryTime = 0
    end

    modData.AmazoidPendingOrders = orders
    mailbox:transmitModData()

    -- Process the orders now
    Amazoid.Mailbox.processOrders(mailbox)

    -- Play sound and notify players
    if Amazoid.Client and Amazoid.Client.notifyMerchantVisit then
        Amazoid.Client.notifyMerchantVisit(mailbox)
    end

    AmazoidDebug.log("Delivered " .. #orders .. " order(s)")
end

-- Trigger a merchant visit now (process catalogs and deliver ready orders)
function AmazoidDebug.merchantVisit()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    if Amazoid.Client and Amazoid.Client.merchantVisit then
        Amazoid.Client.merchantVisit()
        AmazoidDebug.log("Merchant visit triggered")
    else
        AmazoidDebug.log("Amazoid.Client.merchantVisit not available")
    end
end

-- Force first contact (merchant visits with discovery letter)
function AmazoidDebug.firstContact()
    -- Get all local players for split-screen support (for logging)
    local allPlayers = IsoPlayer.getPlayers()
    if not allPlayers or allPlayers:size() == 0 then
        AmazoidDebug.log("No players found")
        return
    end

    -- Log player positions for debugging
    AmazoidDebug.log("Searching for mailbox near " .. allPlayers:size() .. " player(s):")
    for i = 0, allPlayers:size() - 1 do
        local p = allPlayers:get(i)
        if p then
            AmazoidDebug.log("  Player " .. i .. " at (" .. math.floor(p:getX()) .. ", " .. math.floor(p:getY()) .. ")")
        end
    end

    -- Use core function to force first contact (with reset)
    if Amazoid.Mailbox and Amazoid.Mailbox.forceFirstContact then
        AmazoidDebug.log("First contact state reset")
        local success = Amazoid.Mailbox.forceFirstContact(nil, true)
        if success then
            AmazoidDebug.log("First contact triggered successfully")
        else
            AmazoidDebug.log("First contact failed - no mailbox found within 100 tiles")
        end
    else
        AmazoidDebug.log("Amazoid.Mailbox.forceFirstContact not available")
    end
end

-- Teleport player to the discovery/contract mailbox, or nearest mailbox
function AmazoidDebug.teleportToMailbox()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    local targetMailbox = nil
    local targetReason = ""

    -- Priority 1: Contract mailbox (if player has signed contract)
    if Amazoid.Client and Amazoid.Client.playerData and Amazoid.Client.playerData.contractMailbox then
        local loc = Amazoid.Client.playerData.contractMailbox
        local mailbox = Amazoid.Mailbox.getMailboxAt(loc.x, loc.y, loc.z)
        if mailbox then
            targetMailbox = mailbox
            targetReason = "contract mailbox"
        end
    end

    -- Priority 2: Find mailbox with discovery letter flag (first contact happened but not signed yet)
    if not targetMailbox then
        local px = math.floor(player:getX())
        local py = math.floor(player:getY())
        local pz = math.floor(player:getZ())
        local searchRadius = 200

        for x = px - searchRadius, px + searchRadius do
            for y = py - searchRadius, py + searchRadius do
                local square = getCell():getGridSquare(x, y, pz)
                if square then
                    local objects = square:getObjects()
                    for i = 0, objects:size() - 1 do
                        local obj = objects:get(i)
                        if Amazoid.Mailbox and Amazoid.Mailbox.isMailbox and Amazoid.Mailbox.isMailbox(obj) then
                            local modData = obj:getModData()
                            if modData and modData.AmazoidDiscoveryLetter then
                                targetMailbox = obj
                                targetReason = "discovery mailbox"
                                break
                            end
                        end
                    end
                end
                if targetMailbox then break end
            end
            if targetMailbox then break end
        end
    end

    -- Priority 3: Nearest mailbox (fallback)
    if not targetMailbox then
        if Amazoid.Mailbox and Amazoid.Mailbox.findNearestMailbox then
            targetMailbox = Amazoid.Mailbox.findNearestMailbox(nil, 500)
            if targetMailbox then
                targetReason = "nearest mailbox"
            end
        end
    end

    if targetMailbox then
        local x, y, z = targetMailbox:getX(), targetMailbox:getY(), targetMailbox:getZ()
        player:setX(x + 1)
        player:setY(y + 1)
        player:setZ(z)
        AmazoidDebug.log("Teleported to " .. targetReason .. " at (" .. x .. ", " .. y .. ", " .. z .. ")")
    else
        AmazoidDebug.log("No mailbox found within 500 tiles")
    end
end

-- Show mailbox status (what's in the contracted mailbox)
function AmazoidDebug.mailboxStatus()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then return end

    local mailboxLoc = nil
    if Amazoid.Client and Amazoid.Client.playerData then
        mailboxLoc = Amazoid.Client.playerData.contractMailbox
    end

    if not mailboxLoc then
        AmazoidDebug.log("No contract mailbox found")
        return
    end

    local mailbox = Amazoid.Mailbox.getMailboxAt(mailboxLoc.x, mailboxLoc.y, mailboxLoc.z)
    if not mailbox then
        AmazoidDebug.log("Could not find mailbox at " .. mailboxLoc.x .. "," .. mailboxLoc.y .. "," .. mailboxLoc.z)
        return
    end

    AmazoidDebug.log("=== Mailbox Status ===")
    AmazoidDebug.log("Location: " .. mailboxLoc.x .. "," .. mailboxLoc.y .. "," .. mailboxLoc.z)

    -- Check for contract
    local hasContract = Amazoid.Mailbox.hasContract(mailbox)
    AmazoidDebug.log("Has Contract: " .. tostring(hasContract))

    -- Count money
    local money = Amazoid.Mailbox.getMoneyInMailbox(mailbox)
    AmazoidDebug.log("Money in mailbox: $" .. money)

    -- Check for catalogs with circled items
    local container = mailbox:getContainer()
    if container then
        local items = container:getItems()
        local catalogCount = 0
        local circledItemCount = 0

        for i = 0, items:size() - 1 do
            local item = items:get(i)
            local itemType = item:getFullType()

            if itemType:find("Amazoid%.") and itemType:find("Catalog") then
                catalogCount = catalogCount + 1
                local modData = item:getModData()
                if modData and modData.AmazoidCircled then
                    for _, count in pairs(modData.AmazoidCircled) do
                        circledItemCount = circledItemCount + count
                    end
                end
            end
        end

        AmazoidDebug.log("Catalogs in mailbox: " .. catalogCount)
        AmazoidDebug.log("Total circled items: " .. circledItemCount)
    end

    -- Check pending orders
    local orders = Amazoid.Mailbox.getPendingOrders(mailbox)
    AmazoidDebug.log("Pending orders: " .. #orders)

    for i, order in ipairs(orders) do
        local actualTimeRemaining = order.deliveryTime - (getGameTime():getWorldAgeHours() - order.orderTime)
        local estimatedTimeRemaining = (order.estimatedTime or order.deliveryTime) -
            (getGameTime():getWorldAgeHours() - order.orderTime)
        AmazoidDebug.log("  Order #" ..
            order.id ..
            " - Status: " ..
            order.status ..
            " - Est: ~" .. math.ceil(estimatedTimeRemaining) .. "h (actual: " .. math.ceil(actualTimeRemaining) .. "h)")
    end
end

-- Set the contract mailbox to the nearest mailbox
function AmazoidDebug.setContractMailbox()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    -- Find nearest mailbox
    local mailbox = Amazoid.Mailbox.findNearestMailbox(player, 100)
    if not mailbox then
        AmazoidDebug.log("No mailbox found nearby (within 100 tiles)")
        return
    end

    local location = {
        x = mailbox:getX(),
        y = mailbox:getY(),
        z = mailbox:getZ()
    }

    -- Update both player modData and Amazoid.Client.playerData
    local data = player:getModData().Amazoid or {}
    data.hasContract = true
    data.contractMailbox = location
    player:getModData().Amazoid = data

    -- Also update the client cache
    if Amazoid.Client and Amazoid.Client.playerData then
        Amazoid.Client.playerData.hasContract = true
        Amazoid.Client.playerData.contractMailbox = location
        Amazoid.Client.playerData.contractStatus = Amazoid.ContractStatus.ACTIVE
    end

    -- Activate contract on the mailbox itself
    Amazoid.Mailbox.activateContract(mailbox, player:getPlayerNum())

    AmazoidDebug.log("Contract mailbox set to: " .. location.x .. "," .. location.y .. "," .. location.z)
end

-- Reset ALL Amazoid data (simulates a fresh new game start)
-- Clears: player data, inventory items, all nearby mailboxes, world data
function AmazoidDebug.reset()
    AmazoidDebug.log("=== Resetting ALL Amazoid Data ===")

    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    -- 1. Reset all player Amazoid data
    player:getModData().Amazoid = nil
    AmazoidDebug.log("Player modData reset")

    -- 2. Remove all Amazoid items from inventory
    local inv = player:getInventory()
    local toRemove = {}
    local items = inv:getItems()

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local fullType = item:getFullType()
            if fullType and string.find(fullType, "Amazoid%.") then
                table.insert(toRemove, item)
            end
        end
    end

    for _, item in ipairs(toRemove) do
        inv:Remove(item)
    end
    AmazoidDebug.log("Removed " .. #toRemove .. " Amazoid items from inventory")

    -- 3. Reset spawner state
    if Amazoid and Amazoid.Spawner then
        Amazoid.Spawner.processedCells = {}
        Amazoid.Spawner.startingHouseProcessed = false
        AmazoidDebug.log("Spawner state reset")
    end

    -- 4. Reset client state (all player data fields)
    if Amazoid and Amazoid.Client and Amazoid.Client.playerData then
        Amazoid.Client.playerData.reputation = Amazoid.Reputation.STARTING
        Amazoid.Client.playerData.contractStatus = Amazoid.ContractStatus.NONE
        Amazoid.Client.playerData.hasContract = false -- Legacy field
        Amazoid.Client.playerData.contractMailbox = nil
        Amazoid.Client.playerData.activeMissions = {}
        Amazoid.Client.playerData.completedMissions = {}
        Amazoid.Client.playerData.pendingOrders = {}
        Amazoid.Client.playerData.unlockedCatalogs = {}
        Amazoid.Client.playerData.discoveredLore = {}
        Amazoid.Client.playerData.giftHistory = {}
        -- First contact tracking
        Amazoid.Client.playerData.firstContactMade = false
        Amazoid.Client.playerData.firstContactDay = nil
        Amazoid.Client.playerData.lastFirstContactAttempt = 0
        -- Order tracking
        Amazoid.Client.playerData.hasPlacedFirstOrder = false
        Amazoid.Client.playerData.totalSpentByCategory = {}
        Amazoid.Client.playerData.totalOrders = 0
        Amazoid.Client.playerData.totalSpent = 0
        -- Catalog progression
        Amazoid.Client.playerData.unlockedVolumes = {}
        Amazoid.Client.playerData.unlockedCategories = {}
        -- Mission tracking
        Amazoid.Client.playerData.lastMissionDay = 0
        Amazoid.Client.playerData.totalMissionsCompleted = 0
        -- Merchant visit tracking
        Amazoid.Client.playerData.hoursSinceLastVisit = 0
        AmazoidDebug.log("Client playerData reset")

        -- Save reset player data
        Amazoid.Client.savePlayerData()
    end

    -- 5. Reset global mod data
    if ModData then
        local modData = ModData.getOrCreate("Amazoid")
        modData.processedCells = {}
        modData.startingHouseProcessed = false
        modData.merchantLetterCount = 0
        modData.orderReceiptCount = 0
        modData.missionLetterCount = 0
        modData.loreLetterCount = 0
        modData.deliveryNoteCount = 0
        modData.giftLetterCount = 0
        -- Reset world data as well
        modData.worldData = nil
        AmazoidDebug.log("Global mod data reset")
    end

    -- 5b. Reset server world data
    if Amazoid and Amazoid.Server and Amazoid.Server.worldData then
        Amazoid.Server.worldData.discoveryMailboxes = {}
        Amazoid.Server.worldData.activeOrders = {}
        Amazoid.Server.worldData.markedZombies = {}
        Amazoid.Server.worldData.protectionDevices = {}
        AmazoidDebug.log("Server world data reset")
    end

    -- 6. Reset ALL nearby mailboxes (not just nearest - important for first contact testing)
    local resetRadius = 150 -- Clear all mailboxes within this range
    local mailboxesReset = 0
    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())

    for x = px - resetRadius, px + resetRadius do
        for y = py - resetRadius, py + resetRadius do
            local square = getCell():getGridSquare(x, y, pz)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    if Amazoid and Amazoid.Mailbox and Amazoid.Mailbox.isMailbox and Amazoid.Mailbox.isMailbox(obj) then
                        local mailboxData = obj:getModData()
                        -- Clear mailbox contract/discovery state
                        mailboxData.AmazoidContract = nil
                        mailboxData.AmazoidContractOwner = nil
                        mailboxData.AmazoidContractTime = nil
                        mailboxData.AmazoidDiscoveryLetter = nil
                        mailboxData.AmazoidDiscoveryLetterTime = nil
                        mailboxData.AmazoidPendingOrders = nil
                        mailboxData.AmazoidLastPaymentLetterHash = nil
                        mailboxData.AmazoidCatalogType = nil
                        mailboxData.AmazoidPendingMission = nil
                        mailboxData.AmazoidLastCatalogSpawnDay = nil
                        mailboxData.AmazoidSpawnDay = nil

                        -- Also remove physical Amazoid items from mailbox container
                        local container = obj:getContainer()
                        if container then
                            local toRemove = {}
                            local items = container:getItems()
                            for j = 0, items:size() - 1 do
                                local item = items:get(j)
                                if item then
                                    local fullType = item:getFullType()
                                    if fullType and string.find(fullType, "Amazoid%.") then
                                        table.insert(toRemove, item)
                                    end
                                end
                            end
                            for _, item in ipairs(toRemove) do
                                container:Remove(item)
                            end
                        end

                        obj:transmitModData()
                        mailboxesReset = mailboxesReset + 1
                    end
                end
            end
        end
    end
    AmazoidDebug.log("Reset " .. mailboxesReset .. " mailbox(es) within " .. resetRadius .. " tiles")

    AmazoidDebug.log("=== Player Reset Complete ===")
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
        "shared/Amazoid/AmazoidCatalogs.lua",
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
    local player = AmazoidDebug.getLocalPlayer()
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

-- Kill the player (for testing respawn/new game)
function AmazoidDebug.killPlayer()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    AmazoidDebug.log("Killing player...")
    player:setHealth(0)
    -- Alternative methods if setHealth doesn't work
    -- player:Kill(nil)
    AmazoidDebug.log("Player killed - start a new character to test mailbox spawning")
end

-- Quick test function - gives all items for testing
function AmazoidDebug.test()
    AmazoidDebug.log("Running quick test...")

    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    local inv = player:getInventory()

    -- Sign contract and set reputation
    AmazoidDebug.giveContract()
    AmazoidDebug.setRep(50)

    -- Give ALL catalog editions
    AmazoidDebug.giveAllCatalogs()

    -- Give non-numbered letter types
    local letterItems = {
        "Amazoid.DiscoveryLetter",
    }

    local letterCount = 0
    for _, itemType in ipairs(letterItems) do
        if AmazoidDebug.safeAddItem(inv, itemType) then
            letterCount = letterCount + 1
        end
    end

    -- Give numbered letters (all types that can have multiple)
    if AmazoidDebug.addNumberedItem(inv, "Amazoid.MerchantLetter", "Merchant Letter", "merchantLetterCount") then
        letterCount = letterCount + 1
    end
    if AmazoidDebug.addNumberedItem(inv, "Amazoid.OrderReceipt", "Order Receipt", "orderReceiptCount") then
        letterCount = letterCount + 1
    end
    if AmazoidDebug.addNumberedItem(inv, "Amazoid.MissionLetter", "Mission Letter", "missionLetterCount") then
        letterCount = letterCount + 1
    end
    if AmazoidDebug.addNumberedItem(inv, "Amazoid.LoreLetter", "Lore Letter", "loreLetterCount") then
        letterCount = letterCount + 1
    end
    if AmazoidDebug.addNumberedItem(inv, "Amazoid.DeliveryNoteLetter", "Delivery Note", "deliveryNoteCount") then
        letterCount = letterCount + 1
    end
    if AmazoidDebug.addNumberedItem(inv, "Amazoid.GiftLetter", "Gift Letter", "giftLetterCount") then
        letterCount = letterCount + 1
    end

    AmazoidDebug.log("Added " .. letterCount .. "/7 letter items")

    -- Give other items (delivery packages and protection device)
    local otherItems = {
        "Amazoid.DeliveryPackageSmall",
        "Amazoid.DeliveryPackageMedium",
        "Amazoid.DeliveryPackageLarge",
        "Amazoid.DeliveryCrate",
        "Amazoid.ProtectionDevice",
    }

    local otherCount = 0
    for _, itemType in ipairs(otherItems) do
        if AmazoidDebug.safeAddItem(inv, itemType) then
            otherCount = otherCount + 1
        end
    end
    AmazoidDebug.log("Added " .. otherCount .. "/" .. #otherItems .. " other items")

    AmazoidDebug.status()
    AmazoidDebug.log("Test complete! Check your inventory.")
end

-- Scan nearby squares and report all objects with containers (potential mailboxes)
function AmazoidDebug.scanMailboxes()
    local player = AmazoidDebug.getLocalPlayer()
    if not player then
        AmazoidDebug.log("No player found")
        return
    end

    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())
    local radius = 10

    AmazoidDebug.log("=== Scanning for objects within " .. radius .. " tiles ===")
    AmazoidDebug.log("Player position: " .. px .. ", " .. py .. ", " .. pz)

    local foundObjects = {}

    for x = px - radius, px + radius do
        for y = py - radius, py + radius do
            local square = getCell():getGridSquare(x, y, pz)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    local sprite = obj:getSprite()
                    local spriteName = sprite and sprite:getName() or "nil"
                    local container = obj:getContainer()
                    local objName = obj:getName() or "unnamed"

                    -- Only report objects with containers or interesting sprites
                    if container or (spriteName and spriteName:find("mail")) then
                        local isMailbox = Amazoid.Mailbox.isMailbox(obj)
                        table.insert(foundObjects, {
                            x = x,
                            y = y,
                            sprite = spriteName,
                            name = objName,
                            hasContainer = container ~= nil,
                            containerType = container and container:getType() or "none",
                            isMailbox = isMailbox
                        })
                    end
                end
            end
        end
    end

    if #foundObjects == 0 then
        AmazoidDebug.log("No objects with containers found nearby")
    else
        AmazoidDebug.log("Found " .. #foundObjects .. " objects with containers:")
        for _, obj in ipairs(foundObjects) do
            AmazoidDebug.log("  [" ..
                obj.x ..
                "," ..
                obj.y ..
                "] " ..
                obj.sprite .. " | container: " .. obj.containerType .. " | isMailbox: " .. tostring(obj.isMailbox))
        end
    end
end

-- Register debug keybinds (only in debug mode)
local function onKeyPressed(key)
    -- Only work in debug mode
    if not (isDebugEnabled and isDebugEnabled()) and not (getDebug and getDebug()) then
        return
    end

    -- F9 = reset player (full reset like new game)
    if key == Keyboard.KEY_F9 then
        AmazoidDebug.reset()
        -- F10 = quick status
    elseif key == Keyboard.KEY_F10 then
        AmazoidDebug.status()
    end
end

-- Register the key handler if Events is available
if Events and Events.OnKeyPressed then
    Events.OnKeyPressed.Add(onKeyPressed)
    print("[Amazoid] Debug keybinds: F9=reset, F10=status")
end

print("[Amazoid] Debug utilities loaded - use AmazoidDebug.test() in console")
