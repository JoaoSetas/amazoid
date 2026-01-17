--[[
    Amazoid - Mysterious Mailbox Merchant
    Client Module

    This file handles client-side logic including UI and player interactions.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidUtils"
require "Amazoid/AmazoidMissions"
require "Amazoid/AmazoidEvents"

Amazoid.Client = Amazoid.Client or {}

--- Get all local players (supports split-screen)
---@return table Array of IsoPlayer objects
function Amazoid.Client.getAllLocalPlayers()
    local players = {}
    local allPlayers = IsoPlayer.getPlayers()
    if allPlayers then
        for i = 0, allPlayers:size() - 1 do
            local p = allPlayers:get(i)
            if p and not p:isDead() then
                table.insert(players, p)
            end
        end
    end
    return players
end

-- Player data cache
Amazoid.Client.playerData = {
    reputation = Amazoid.Reputation.STARTING,
    contractStatus = Amazoid.ContractStatus.NONE,
    contractMailbox = nil, -- The mailbox where contract was signed
    activeMissions = {},
    completedMissions = {},
    pendingOrders = {},
    unlockedCatalogs = {},
    discoveredLore = {},
    giftHistory = {},
    -- First contact tracking
    firstContactMade = false,     -- Has the merchant made first contact?
    firstContactDay = nil,        -- Random day chosen for first contact attempt
    lastFirstContactAttempt = 0,  -- Last hour we tried first contact
    -- Order tracking
    hasPlacedFirstOrder = false,  -- Has the player placed their first order (free)?
    totalSpentByCategory = {},    -- Total money spent per catalog category (for volume unlock)
    totalOrders = 0,              -- Total number of orders placed
    totalSpent = 0,               -- Total money spent across all orders
    -- Catalog progression
    unlockedVolumes = {},         -- Current unlocked volume per category (e.g., {basic=2, tools=1})
    unlockedCategories = {},      -- Which categories have been unlocked (for tracking reputation unlocks)
    lastCatalogDay = 0,           -- Last day a new catalog was received (limit one per day)
    -- Mission tracking
    lastMissionDay = 0,           -- Last day a new mission was spawned
    totalMissionsCompleted = 0,   -- Total missions completed successfully
    -- Triggered letters tracking
    sentTriggeredLetters = {},    -- Which triggered letters have been sent (e.g., {kills_10=true, days_7=true})
    contractSignedDay = 0,        -- Day number when contract was signed (for days survived tracking)
    -- Merchant visit tracking
    hoursSinceLastVisit = 0,      -- Hours elapsed since last merchant visit
    pendingMerchantVisit = false, -- True if visit was blocked (player too close) and needs retry
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
---@param reason string? Optional reason for the change (for event listeners)
function Amazoid.Client.modifyReputation(amount, reason)
    local oldRep = Amazoid.Client.playerData.reputation
    Amazoid.Client.playerData.reputation = Amazoid.Utils.clampReputation(oldRep + amount)

    local newRep = Amazoid.Client.playerData.reputation
    print("[Amazoid] Reputation changed: " .. oldRep .. " -> " .. newRep .. " (reason: " .. (reason or "unknown") .. ")")

    -- Fire reputation changed event (listeners handle milestones, lore, gifts, etc.)
    if Amazoid.Events and Amazoid.Events.fire then
        Amazoid.Events.fire(Amazoid.Events.Names.REPUTATION_CHANGED, {
            oldRep = oldRep,
            newRep = newRep,
            amount = amount,
            reason = reason or "unknown",
        })
    end

    -- Legacy: Check for unlock notifications (will be replaced by event listeners)
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
    -- Check the new contractStatus field
    if Amazoid.Client.playerData.contractStatus == Amazoid.ContractStatus.ACTIVE then
        return true
    end
    -- Also check legacy hasContract field for backwards compatibility
    if Amazoid.Client.playerData.hasContract == true then
        return true
    end
    return false
end

--- Sign the merchant contract
---@param mailboxLocation table Location of the mailbox {x, y, z}
function Amazoid.Client.signContract(mailboxLocation)
    Amazoid.Client.playerData.contractStatus = Amazoid.ContractStatus.ACTIVE
    Amazoid.Client.playerData.hasContract = true -- Also set legacy field
    Amazoid.Client.playerData.contractMailbox = mailboxLocation

    -- Record the day the contract was signed (for days survived milestone)
    local currentDay = math.floor(getGameTime():getWorldAgeHours() / 24)
    Amazoid.Client.playerData.contractSignedDay = currentDay

    -- Unlock basic catalog category and first volume
    Amazoid.Client.playerData.unlockedCatalogs = Amazoid.Client.playerData.unlockedCatalogs or {}
    Amazoid.Client.playerData.unlockedCatalogs[Amazoid.CatalogCategories.BASIC] = true

    -- Mark basic category as unlocked for catalog progression
    Amazoid.Client.playerData.unlockedCategories = Amazoid.Client.playerData.unlockedCategories or {}
    Amazoid.Client.playerData.unlockedCategories["basic"] = true

    -- Set basic volume 1 as unlocked (and it will be spawned on first merchant visit)
    Amazoid.Client.playerData.unlockedVolumes = Amazoid.Client.playerData.unlockedVolumes or {}
    Amazoid.Client.playerData.unlockedVolumes["basic"] = 1

    print("[Amazoid] Contract signed at mailbox: " ..
        mailboxLocation.x .. "," .. mailboxLocation.y .. "," .. mailboxLocation.z)
    Amazoid.Client.savePlayerData()

    -- Fire ContractSigned event
    if Amazoid.Events and Amazoid.Events.fire then
        Amazoid.Events.fire(Amazoid.Events.Names.CONTRACT_SIGNED, {
            mailboxLocation = mailboxLocation,
        })
    end
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

    -- Count items for delivery time calculation
    local itemCount = 0
    for _, item in ipairs(items) do
        itemCount = itemCount + (item.count or 1)
    end

    local estimatedDeliveryTime = Amazoid.Utils.calculateDeliveryTime(
        Amazoid.Client.getReputation(),
        isRush,
        itemCount
    )

    local actualDeliveryTime = Amazoid.Utils.calculateActualDeliveryTime(estimatedDeliveryTime)

    local order = {
        id = ZombRand(100000, 999999),
        items = items,
        itemCount = itemCount,
        totalPrice = totalPrice,
        isRush = isRush,
        deliveryTime = actualDeliveryTime,
        estimatedTime = estimatedDeliveryTime,
        orderTime = getGameTime():getWorldAgeHours(),
        status = "pending",
    }

    table.insert(Amazoid.Client.playerData.pendingOrders, order)
    Amazoid.Client.savePlayerData()

    print("[Amazoid] Order placed! Delivery in approximately " .. estimatedDeliveryTime .. " hours.")
    return true
end

--- Accept a mission
---@param mission table Mission data
function Amazoid.Client.acceptMission(mission)
    table.insert(Amazoid.Client.playerData.activeMissions, mission)
    Amazoid.Client.savePlayerData()
    print("[Amazoid] Mission accepted: " .. mission.title)

    -- Fire MissionAccepted event
    if Amazoid.Events and Amazoid.Events.fire then
        Amazoid.Events.fire(Amazoid.Events.Names.MISSION_ACCEPTED, {
            mission = mission,
        })
    end
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
                Amazoid.Client.modifyReputation(Amazoid.Reputation.MISSION_COMPLETE, "mission_complete")
                print("[Amazoid] Mission completed successfully!")

                -- Fire MissionCompleted event
                if Amazoid.Events and Amazoid.Events.fire then
                    Amazoid.Events.fire(Amazoid.Events.Names.MISSION_COMPLETED, {
                        mission = mission,
                        rewards = mission.reward,
                    })
                end
            else
                Amazoid.Client.modifyReputation(Amazoid.Reputation.MISSION_FAIL, "mission_fail")
                print("[Amazoid] Mission failed.")

                -- Fire MissionFailed event
                if Amazoid.Events and Amazoid.Events.fire then
                    Amazoid.Events.fire(Amazoid.Events.Names.MISSION_FAILED, {
                        mission = mission,
                        reason = "failed",
                    })
                end
            end

            break
        end
    end
end

-- Event Hooks

--- Called when game starts
local function onGameStart()
    Amazoid.Client.init()

    -- Initialize reputation triggers (event listeners for milestones, lore, gifts)
    if Amazoid.ReputationTriggers and Amazoid.ReputationTriggers.init then
        Amazoid.ReputationTriggers.init()
    end
end

--- Called when player dies
local function onPlayerDeath(player)
    -- Optionally handle death - maybe reputation penalty?
end

--- Find a nearby mailbox within distance range
--- Supports split-screen by checking all local players
---@param player IsoPlayer The primary player (used for search center)
---@param minDistance number Minimum distance from any player
---@param maxDistance number Maximum distance to search
---@return IsoObject|nil mailbox Mailbox object or nil
---@return boolean tooClose True if mailboxes were found but player was too close
function Amazoid.Client.findNearbyMailbox(player, minDistance, maxDistance)
    if not player then return nil, false end

    local allPlayers = Amazoid.Client.getAllLocalPlayers()
    if #allPlayers == 0 then return nil, false end

    -- Use the primary player's position for the search center
    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())

    local candidates = {}
    local mailboxesFound = 0
    local tooClose = 0
    local tooFar = 0

    for x = px - maxDistance, px + maxDistance do
        for y = py - maxDistance, py + maxDistance do
            local square = getCell():getGridSquare(x, y, pz)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    if Amazoid.Mailbox and Amazoid.Mailbox.isMailbox and Amazoid.Mailbox.isMailbox(obj) then
                        mailboxesFound = mailboxesFound + 1

                        -- Calculate distance to the NEAREST local player
                        local minPlayerDist = -1
                        for _, p in ipairs(allPlayers) do
                            local ppx, ppy = p:getX(), p:getY()
                            local dx, dy = x - ppx, y - ppy
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if minPlayerDist < 0 or dist < minPlayerDist then
                                minPlayerDist = dist
                            end
                        end

                        -- Must be within min/max distance from at least one player
                        if minPlayerDist < minDistance then
                            tooClose = tooClose + 1
                        elseif minPlayerDist > maxDistance then
                            tooFar = tooFar + 1
                        else
                            table.insert(candidates, { mailbox = obj, distance = minPlayerDist })
                        end
                    end
                end
            end
        end
    end

    -- Debug logging
    if mailboxesFound > 0 then
        print("[Amazoid] Mailbox search: found=" ..
            mailboxesFound ..
            ", tooClose=" ..
            tooClose .. ", tooFar=" .. tooFar .. ", valid=" .. #candidates)
    end

    -- Return the closest non-visible mailbox
    if #candidates > 0 then
        table.sort(candidates, function(a, b) return a.distance < b.distance end)
        return candidates[1].mailbox, false
    end

    -- Return nil but indicate if it was because player was too close
    return nil, (tooClose > 0)
end

--- Attempt first contact with the player via a nearby mailbox
--- Supports split-screen: all nearby players will react
---@return boolean success True if first contact was successfully made
---@return boolean tooClose True if visit failed because player was too close
function Amazoid.Client.tryFirstContact()
    -- Get all local players for split-screen support
    local allPlayers = Amazoid.Client.getAllLocalPlayers()
    if #allPlayers == 0 then return false, false end

    -- Use first player as the primary reference for finding mailbox
    local player = allPlayers[1]

    -- Already has contract or first contact made
    if Amazoid.Client.hasContract() then
        Amazoid.Client.playerData.firstContactMade = true
        return false, false
    end

    if Amazoid.Client.playerData.firstContactMade then
        return false, false
    end

    -- Find a nearby mailbox
    -- Player should be 10-100 tiles away (close enough to hear)
    local mailbox, tooClose = Amazoid.Client.findNearbyMailbox(player, 10, 100)

    if not mailbox then
        if tooClose then
            print("[Amazoid] First contact: Player too close to mailbox, will retry")
            return false, true
        end
        print("[Amazoid] First contact: No suitable mailbox found (player needs to be 10-100 tiles from a mailbox)")
        return false, false
    end

    -- Don't visit if mailbox already has discovery letter
    local hasLetter = Amazoid.Mailbox.hasDiscoveryLetter(mailbox)
    if hasLetter then
        print("[Amazoid] First contact: Mailbox at " ..
            mailbox:getX() .. "," .. mailbox:getY() .. " already has discovery letter flag in modData")
        print("[Amazoid] Use AmazoidDebug.reset() to clear all Amazoid data")
        return false, false
    end

    -- Success! Add discovery letter and catalog to mailbox
    print("[Amazoid] First contact: Merchant visiting mailbox at " .. mailbox:getX() .. "," .. mailbox:getY())

    Amazoid.Mailbox.addDiscoveryLetter(mailbox)

    -- Play mailbox sound
    Amazoid.Client.playMailboxSound(mailbox)

    -- All nearby players say something (split-screen support)
    local notificationRange = 100 -- Players within this range hear it
    Amazoid.Client.makeNearbyPlayersSay(mailbox, notificationRange, "I think I heard someone at the mailbox...")

    -- Mark first contact as made
    Amazoid.Client.playerData.firstContactMade = true
    Amazoid.Client.savePlayerData()

    return true, false
end

--- Play the mailbox sound at a location
---@param mailbox IsoObject The mailbox object
function Amazoid.Client.playMailboxSound(mailbox)
    if not mailbox then return end

    -- Try to play custom sound
    -- For now, use a built-in sound that fits (door/container opening)
    local x, y, z = mailbox:getX(), mailbox:getY(), mailbox:getZ()

    -- Add world sound event (attracts zombies slightly, but also audible to player)
    addSound(nil, x, y, z, 10, 10)

    -- Play UI feedback sound
    getSoundManager():playUISound("UIInventoryPaperDrop")
end

--- Check if it's time to attempt first contact
---@return boolean True if we should try first contact this hour
function Amazoid.Client.shouldAttemptFirstContact()
    local player = getPlayer()
    if not player then return false end

    -- Already has contract
    if Amazoid.Client.hasContract() then return false end

    -- Already made first contact
    if Amazoid.Client.playerData.firstContactMade then return false end

    local currentHour = getGameTime():getWorldAgeHours()

    -- Track session start to avoid instant first contact on load
    if not Amazoid.Client.sessionStartHour then
        Amazoid.Client.sessionStartHour = currentHour
        print("[Amazoid] Session started at hour " .. currentHour)
    end

    -- Don't attempt first contact in the first hour after loading
    if currentHour < Amazoid.Client.sessionStartHour + 1 then
        return false
    end

    -- Get first contact window from sandbox (default 3 days = 72 hours)
    local firstContactDays = 3
    if SandboxVars and SandboxVars.Amazoid and SandboxVars.Amazoid.FirstContactDays then
        firstContactDays = SandboxVars.Amazoid.FirstContactDays
    end

    local firstContactHours = firstContactDays * 24

    -- Initialize random first contact day if not set
    if not Amazoid.Client.playerData.firstContactDay then
        -- Pick a random day within the first contact window
        Amazoid.Client.playerData.firstContactDay = ZombRand(1, firstContactDays + 1)
        Amazoid.Client.savePlayerData()
        print("[Amazoid] First contact scheduled for day " .. Amazoid.Client.playerData.firstContactDay)
    end

    local targetDay = Amazoid.Client.playerData.firstContactDay
    local targetHourStart = (targetDay - 1) * 24
    local targetHourEnd = targetDay * 24

    -- If we're past the first contact window entirely, trigger immediately on next opportunity
    if currentHour > firstContactHours then
        return true
    end

    -- If we're in the target day range, allow first contact attempts
    if currentHour >= targetHourStart and currentHour <= targetHourEnd then
        return true
    end

    return false
end

--- Check if any player is too close to the contract mailbox
--- The merchant won't visit if players are watching
---@return boolean True if any player is within 15 tiles of the contract mailbox
function Amazoid.Client.isPlayerTooCloseToMailbox()
    local contractMailbox = Amazoid.Client.playerData.contractMailbox
    if not contractMailbox then return false end

    local allPlayers = Amazoid.Client.getAllLocalPlayers()
    if #allPlayers == 0 then return false end

    local minDistance = 15 -- Same as first contact distance

    for _, player in ipairs(allPlayers) do
        local px, py = player:getX(), player:getY()
        local dx = contractMailbox.x - px
        local dy = contractMailbox.y - py
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < minDistance then
            print("[Amazoid] Player too close to mailbox: " ..
                math.floor(distance) .. " tiles (min: " .. minDistance .. ")")
            return true
        end
    end

    return false
end

--- Attempt the merchant visit, checking if player is too close
--- Returns true if visit was successful, false if player was too close
---@return boolean True if merchant visited successfully
function Amazoid.Client.tryMerchantVisit()
    -- Check if player is too close to the contract mailbox
    if Amazoid.Client.isPlayerTooCloseToMailbox() then
        print("[Amazoid] Merchant visit blocked - player too close. Will retry every 10 minutes.")
        Amazoid.Client.playerData.pendingMerchantVisit = true
        return false
    end

    -- Player is far enough, proceed with visit
    Amazoid.Client.playerData.pendingMerchantVisit = false
    Amazoid.Client.merchantVisit()
    return true
end

--- Called every game hour to check for first contact opportunity
--- Supports split-screen by checking all local players
local function onEveryHours()
    -- Check if any local players exist
    local allPlayers = Amazoid.Client.getAllLocalPlayers()
    if #allPlayers == 0 then return end

    -- Check for first contact (before contract is signed)
    if not Amazoid.Client.hasContract() and not Amazoid.Client.playerData.firstContactMade then
        -- Check if we're in the first contact window
        if Amazoid.Client.shouldAttemptFirstContact() then
            local success, tooClose = Amazoid.Client.tryFirstContact()
            if tooClose then
                -- Player was too close, set pending flag to retry every 10 minutes
                Amazoid.Client.playerData.pendingMerchantVisit = true
                print("[Amazoid] First contact blocked - player too close. Will retry every 10 minutes.")
            end
        end
        return -- Don't do merchant visits until contract is signed
    end

    -- Regular merchant visits (only after contract is signed)
    if not Amazoid.Client.hasContract() then return end

    -- Get merchant visit interval from sandbox
    local visitInterval = 1
    if SandboxVars and SandboxVars.Amazoid and SandboxVars.Amazoid.MerchantVisitInterval then
        visitInterval = SandboxVars.Amazoid.MerchantVisitInterval
    end

    -- Track hours since last visit
    Amazoid.Client.playerData.hoursSinceLastVisit = (Amazoid.Client.playerData.hoursSinceLastVisit or 0) + 1

    print("[Amazoid] Hours since last visit: " .. Amazoid.Client.playerData.hoursSinceLastVisit .. "/" .. visitInterval)

    if Amazoid.Client.playerData.hoursSinceLastVisit >= visitInterval then
        Amazoid.Client.playerData.hoursSinceLastVisit = 0
        -- Try to visit, but if player is too close, it will be retried every 10 minutes
        Amazoid.Client.tryMerchantVisit()
    end
end

--- Called every 10 game minutes to retry pending merchant visits
--- If the hourly visit was blocked because player was too close, we retry frequently
local function onEveryTenMinutes()
    -- Only process if there's a pending visit
    if not Amazoid.Client.playerData.pendingMerchantVisit then return end

    -- Check if any local players exist
    local allPlayers = Amazoid.Client.getAllLocalPlayers()
    if #allPlayers == 0 then return end

    -- Handle first contact retry
    if not Amazoid.Client.hasContract() and not Amazoid.Client.playerData.firstContactMade then
        print("[Amazoid] Retrying first contact...")
        local success, tooClose = Amazoid.Client.tryFirstContact()
        if success then
            Amazoid.Client.playerData.pendingMerchantVisit = false
            print("[Amazoid] First contact successful!")
        elseif not tooClose then
            -- Failed for a reason other than being too close, stop retrying
            Amazoid.Client.playerData.pendingMerchantVisit = false
        else
            print("[Amazoid] Still too close, will retry in 10 minutes...")
        end
        return
    end

    -- Handle regular merchant visit retry
    if not Amazoid.Client.hasContract() then
        Amazoid.Client.playerData.pendingMerchantVisit = false
        return
    end

    print("[Amazoid] Retrying pending merchant visit...")

    -- Try to visit again
    if Amazoid.Client.tryMerchantVisit() then
        print("[Amazoid] Pending merchant visit successful!")
    else
        print("[Amazoid] Still too close, will retry in 10 minutes...")
    end
end

--- Merchant visits all nearby mailboxes with signed contracts
--- Automatically processes orders - no player interaction needed
--- Supports split-screen by searching around all local players
function Amazoid.Client.merchantVisit()
    local allPlayers = Amazoid.Client.getAllLocalPlayers()
    if #allPlayers == 0 then return end

    print("[Amazoid] Merchant visit starting...")

    local searchRadius = 100 -- Check mailboxes within 100 tiles
    local processedCount = 0
    local mailboxCount = 0
    local processedLocations = {} -- Track processed mailboxes to avoid duplicates

    -- First, check the contract mailbox specifically (may be outside search radius but loaded)
    local contractMailbox = Amazoid.Client.playerData.contractMailbox
    if contractMailbox then
        local square = getCell():getGridSquare(contractMailbox.x, contractMailbox.y, contractMailbox.z)
        if square then
            local objects = square:getObjects()
            for i = 0, objects:size() - 1 do
                local obj = objects:get(i)
                if Amazoid.Mailbox.isMailbox(obj) and Amazoid.Mailbox.hasContract(obj) then
                    mailboxCount = mailboxCount + 1
                    processedCount = processedCount + 1
                    local locKey = contractMailbox.x .. "," .. contractMailbox.y .. "," .. contractMailbox.z
                    processedLocations[locKey] = true
                    print("[Amazoid] Processing contract mailbox at " .. contractMailbox.x .. "," .. contractMailbox.y)
                    Amazoid.Client.processMailbox(obj)
                    break
                end
            end
        end
    end

    -- Scan all nearby squares for each local player (split-screen support)
    for _, player in ipairs(allPlayers) do
        local playerX = math.floor(player:getX())
        local playerY = math.floor(player:getY())
        local playerZ = math.floor(player:getZ())

        for x = playerX - searchRadius, playerX + searchRadius do
            for y = playerY - searchRadius, playerY + searchRadius do
                local square = getCell():getGridSquare(x, y, playerZ)
                if square then
                    local objects = square:getObjects()
                    for i = 0, objects:size() - 1 do
                        local obj = objects:get(i)
                        if Amazoid.Mailbox.isMailbox(obj) then
                            local locKey = x .. "," .. y .. "," .. playerZ
                            if not processedLocations[locKey] then
                                mailboxCount = mailboxCount + 1
                                -- Check if this mailbox has a signed contract in it (and activate if so)
                                local hasNewContract = Amazoid.Mailbox.checkForSignedContract(obj)
                                local hasExistingContract = Amazoid.Mailbox.hasContract(obj)

                                if hasNewContract or hasExistingContract then
                                    processedCount = processedCount + 1
                                    processedLocations[locKey] = true
                                    print("[Amazoid] Processing mailbox at " ..
                                        x ..
                                        "," ..
                                        y ..
                                        " (new=" ..
                                        tostring(hasNewContract) .. ", existing=" .. tostring(hasExistingContract) .. ")")
                                    Amazoid.Client.processMailbox(obj)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    print("[Amazoid] Merchant visit complete: found " .. mailboxCount .. " mailbox(es), processed " .. processedCount)

    -- Play a sound if any mailboxes were processed
    if processedCount > 0 then
        -- Use a subtle UI sound to indicate merchant visited
        getSoundManager():playUISound("UIActivateTab")
    end
end

--- Process a single mailbox (catalog orders and deliveries)
---@param mailbox IsoObject The mailbox to process
function Amazoid.Client.processMailbox(mailbox)
    if not mailbox then return end

    local x, y, z = mailbox:getX(), mailbox:getY(), mailbox:getZ()
    local reputation = Amazoid.Client.getReputation()
    local merchantLeftSomething = false -- Only true if merchant ADDS something new

    -- Process catalogs with circled items FIRST (this records spending for volume unlocks)
    local result = Amazoid.Mailbox.processCatalogs(mailbox)
    if result then
        if result.status == "success" then
            print("[Amazoid] Merchant processed order #" .. result.order.id .. " at " .. x .. "," .. y)
            -- Order accepted - confirmation letter added
            merchantLeftSomething = true
        elseif result.status == "no_money" then
            print("[Amazoid] Not enough money at mailbox " .. x .. "," .. y)
            -- Payment needed letter may have been added (only on first request)
            -- Check if this was a new letter by looking at the result
            if result.letterAdded then
                merchantLeftSomething = true
            end
        elseif result.status == "stolen" then
            print("[Amazoid] Merchant took money at mailbox " .. x .. "," .. y)
            -- Theft letter added
            merchantLeftSomething = true
        end
    end

    -- Process pending orders that are ready for delivery
    local deliveredCount = Amazoid.Mailbox.processOrders(mailbox)
    if deliveredCount and deliveredCount > 0 then
        print("[Amazoid] " .. deliveredCount .. " order(s) delivered at mailbox " .. x .. "," .. y)
        merchantLeftSomething = true
    end

    -- Check for catalog unlocks AFTER processing orders (spending is now counted)
    reputation = Amazoid.Client.getReputation() -- Refresh in case it changed
    local catalogSpawned = Amazoid.Mailbox.spawnCatalogs(mailbox, reputation)
    if catalogSpawned then
        print("[Amazoid] Catalog unlocked at mailbox " .. x .. "," .. y)
        merchantLeftSomething = true
    end

    -- Process mission completions (check if player left mission items)
    local missionResult = Amazoid.Mailbox.processMissions(mailbox)
    if missionResult then
        print("[Amazoid] Completed " .. #missionResult.completedMissions .. " mission(s) at " .. x .. "," .. y)
        print("[Amazoid] Mission rewards: $" ..
            missionResult.moneyReward .. ", +" .. missionResult.reputationReward .. " reputation")
        -- Completion letter and rewards added
        merchantLeftSomething = true

        -- Spawn a new mission for each completed mission (bypasses daily limit)
        for _, completedMission in ipairs(missionResult.completedMissions) do
            -- Alternate between collection and elimination missions
            local missionType = "collection"
            if completedMission.type == Amazoid.MissionTypes.COLLECTION then
                -- If just completed collection, maybe offer elimination next
                if ZombRand(0, 100) < 40 then -- 40% chance for elimination
                    missionType = "elimination"
                end
            end

            local newMission = Amazoid.Mailbox.spawnMission(mailbox, missionType, true, false)
            if newMission then
                print("[Amazoid] New mission spawned as reward for completing: " .. (completedMission.title or "mission"))
            end
        end
    end

    -- Spawn daily mission (if eligible and no missions were just completed)
    if not missionResult then
        local missionSpawned = Amazoid.Mailbox.spawnDailyMission(mailbox)
        if missionSpawned then
            print("[Amazoid] New mission available at " .. x .. "," .. y)
            merchantLeftSomething = true
        end
    end

    -- Check for triggered letters (milestones, clothing, etc.)
    local triggeredLetterSpawned = Amazoid.Client.checkTriggeredLetters(mailbox)
    if triggeredLetterSpawned then
        print("[Amazoid] Triggered letter added at " .. x .. "," .. y)
        merchantLeftSomething = true
    end

    -- Only notify player if merchant actually left something new
    if merchantLeftSomething then
        Amazoid.Client.notifyMerchantVisit(mailbox)
    end
end

--- Make all nearby local players say something
--- Supports split-screen by notifying all players within range
---@param object IsoObject The object to check distance from
---@param range number Maximum range for notification
---@param sayText string|nil Optional specific text (random if nil)
function Amazoid.Client.makeNearbyPlayersSay(object, range, sayText)
    if not object then return end

    local ox, oy, oz = object:getX(), object:getY(), object:getZ()
    local sayOptions = {
        "I think I heard someone at the mailbox...",
        "Was that the mailbox?",
        "Sounds like something was delivered...",
        "I heard something outside...",
    }

    local playersNotified = 0
    for _, player in ipairs(Amazoid.Client.getAllLocalPlayers()) do
        local px, py, pz = player:getX(), player:getY(), player:getZ()
        local dx, dy = ox - px, oy - py
        local dist = math.sqrt(dx * dx + dy * dy)

        -- Check if player is within range and on same Z level
        if dist <= range and math.abs(pz - oz) <= 1 then
            local text = sayText or sayOptions[ZombRand(1, #sayOptions + 1)]
            player:Say(text)
            playersNotified = playersNotified + 1
            print("[Amazoid] Player " .. player:getPlayerNum() .. " says: " .. text)
        end
    end

    if playersNotified == 0 then
        print("[Amazoid] No players within range " .. range .. " of mailbox at " .. ox .. "," .. oy)
    end
end

--- Notify all nearby players that merchant visited the mailbox
--- Supports split-screen by notifying all local players within range
---@param mailbox IsoObject The mailbox that was visited
function Amazoid.Client.notifyMerchantVisit(mailbox)
    if not mailbox then return end

    -- Play mailbox sound
    Amazoid.Client.playMailboxSound(mailbox)

    -- All nearby players say something (random text for each)
    local notificationRange = 100 -- Players within 100 tiles hear it
    Amazoid.Client.makeNearbyPlayersSay(mailbox, notificationRange, nil)
end

--- Clothing items that trigger special letters
local CLOTHING_TRIGGERS = {
    -- Clown outfit
    { trigger = "clown_outfit",    items = { "Hat_ClownWig", "Jacket_Clown", "Trousers_Clown" } },
    -- Spiffo costume
    { trigger = "spiffo_costume",  items = { "SpiffoSuit", "SpiffoHead", "Suit_Spiffo" } },
    -- Santa outfit
    { trigger = "santa_outfit",    items = { "Hat_SantaHat", "Vest_SantaJacket", "Trousers_SantaRed" } },
    -- Prisoner outfit
    { trigger = "prisoner_outfit", items = { "Jumpsuit_Prisoner", "Tshirt_InmateOrange", "Trousers_Prisoner" } },
    -- Military outfit
    { trigger = "military_outfit", items = { "Hat_Army", "Hat_BalaclavaArmy", "Vest_BulletArmy", "Jacket_Army" } },
    -- Bathrobe
    { trigger = "bathrobe",        items = { "Robe_Bathrobe", "Vest_BathRobe" } },
}

--- Check if player is wearing a funny outfit
---@param player IsoPlayer The player to check
---@return string|nil The clothing trigger ID or nil
local function checkPlayerClothing(player)
    if not player then return nil end

    local wornItems = player:getWornItems()
    if not wornItems then return nil end

    for i = 0, wornItems:size() - 1 do
        local wornItem = wornItems:get(i)
        if wornItem and wornItem:getItem() then
            local itemType = wornItem:getItem():getType()
            local fullType = wornItem:getItem():getFullType()

            for _, clothingTrigger in ipairs(CLOTHING_TRIGGERS) do
                for _, triggerItem in ipairs(clothingTrigger.items) do
                    if itemType == triggerItem or fullType:find(triggerItem) then
                        return clothingTrigger.trigger
                    end
                end
            end
        end
    end

    return nil
end

--- Check for triggered letters and spawn them in the mailbox
--- Checks kill milestones, days survived, and funny clothing
---@param mailbox IsoObject The mailbox to add letters to
---@return boolean True if any triggered letter was added
function Amazoid.Client.checkTriggeredLetters(mailbox)
    if not mailbox then return false end
    if not Amazoid.Client.playerData then return false end

    local container = mailbox:getItemContainer() or mailbox:getContainer()
    if not container then return false end

    -- Get the sent letters tracking from player data
    local sentLetters = Amazoid.Client.playerData.sentTriggeredLetters or {}
    local lettersAdded = false

    -- Helper function to add a triggered letter
    local function addTriggeredLetter(triggerId)
        if sentLetters[triggerId] then return false end

        local letterData = Amazoid.Letters.getTriggeredLetter(triggerId)
        if not letterData then return false end

        -- Create the letter item
        local letter = instanceItem("Amazoid.MerchantLetter")
        if not letter then return false end

        local modData = letter:getModData()
        modData.AmazoidLetterType = "triggered"
        modData.AmazoidTriggerId = triggerId
        modData.AmazoidLetterData = {
            type = "triggered",
            title = letterData.title,
            content = letterData.content
        }
        modData.literatureTitle = "Amazoid_Triggered_" .. triggerId

        letter:setName("Letter - " .. letterData.title)
        container:addItem(letter)

        -- Mark as sent
        sentLetters[triggerId] = true
        Amazoid.Client.playerData.sentTriggeredLetters = sentLetters

        print("[Amazoid] Triggered letter added: " .. triggerId)
        return true
    end

    -- Check kill milestones
    local totalKills = 0
    if Amazoid.MissionTracker and Amazoid.MissionTracker.killCounts then
        totalKills = Amazoid.MissionTracker.killCounts["any"] or 0
    end

    if totalKills >= 10 then
        if addTriggeredLetter("kills_10") then lettersAdded = true end
    end
    if totalKills >= 50 then
        if addTriggeredLetter("kills_50") then lettersAdded = true end
    end
    if totalKills >= 100 then
        if addTriggeredLetter("kills_100") then lettersAdded = true end
    end

    -- Check days survived since contract was signed
    local contractDay = Amazoid.Client.playerData.contractSignedDay or 0
    if contractDay > 0 then
        local currentDay = math.floor(getGameTime():getWorldAgeHours() / 24)
        local daysSurvived = currentDay - contractDay

        if daysSurvived >= 7 then
            if addTriggeredLetter("days_7") then lettersAdded = true end
        end
        if daysSurvived >= 14 then
            if addTriggeredLetter("days_14") then lettersAdded = true end
        end
        if daysSurvived >= 30 then
            if addTriggeredLetter("days_30") then lettersAdded = true end
        end
    end

    -- Check player clothing for any local player
    for _, player in ipairs(Amazoid.Client.getAllLocalPlayers()) do
        local clothingTrigger = checkPlayerClothing(player)
        if clothingTrigger then
            if addTriggeredLetter(clothingTrigger) then lettersAdded = true end
        end
    end

    return lettersAdded
end

-- Register events
Events.OnGameStart.Add(onGameStart)
Events.OnPlayerDeath.Add(onPlayerDeath)
Events.EveryHours.Add(onEveryHours)
Events.EveryTenMinutes.Add(onEveryTenMinutes)

print("[Amazoid] Client module loaded")
