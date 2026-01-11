--[[
    Amazoid - Mysterious Mailbox Merchant
    Missions Module

    This file contains mission definitions and generation logic.
]]

require "Amazoid/AmazoidData"

Amazoid.Missions = Amazoid.Missions or {}

-- Collection mission tiers based on reputation
-- Each tier unlocks at a certain reputation level
-- Items are craftable or findable, NOT sold by the merchant
Amazoid.Missions.CollectionTiers = {
    -- Tier 1: Very basic items (reputation 0+) - craftable and common loot
    {
        minReputation = 0,
        maxReputation = 9,
        items = {
            { item = "Base.RippedSheets", count = 5,  name = "Ripped Sheets", baseReward = 12 },
            { item = "Base.Nails",        count = 15, name = "Nails",         baseReward = 15 },
            { item = "Base.SheetRope",    count = 2,  name = "Sheet Ropes",   baseReward = 18 },
            { item = "Base.Thread",       count = 3,  name = "Thread",        baseReward = 10 },
            { item = "Base.DuctTape",     count = 1,  name = "Duct Tape",     baseReward = 14 },
        },
    },
    -- Tier 2: Common supplies (reputation 10+) - crafted and scavenged
    {
        minReputation = 10,
        maxReputation = 24,
        items = {
            { item = "Base.Plank",        count = 8, name = "Wooden Planks", baseReward = 25 },
            { item = "Base.RippedSheets", count = 5, name = "Ripped Sheets", baseReward = 20 },
            { item = "Base.Twine",        count = 3, name = "Twine",         baseReward = 22 },
            { item = "Base.WoodenMallet", count = 1, name = "Wooden Mallet", baseReward = 28 },
            { item = "Base.Glue",         count = 2, name = "Glue",          baseReward = 25 },
            { item = "Base.Scotchtape",   count = 2, name = "Scotch Tape",   baseReward = 18 },
        },
    },
    -- Tier 3: Valuable items (reputation 25+) - harder to find/craft
    {
        minReputation = 25,
        maxReputation = 34,
        items = {
            { item = "Base.ElectronicsScrap", count = 3, name = "Electronics Scrap", baseReward = 45 },
            { item = "Base.MetalPipe",        count = 2, name = "Metal Pipes",       baseReward = 50 },
            { item = "Base.MetalBar",         count = 3, name = "Metal Bars",        baseReward = 55 },
            { item = "Base.ScrapMetal",       count = 5, name = "Scrap Metal",       baseReward = 40 },
            { item = "Base.BookCarpentry1",   count = 1, name = "Carpentry Vol 1",   baseReward = 60 },
            { item = "Base.Log",              count = 4, name = "Logs",              baseReward = 50 },
        },
    },
    -- Tier 4: Rare items (reputation 35+) - rare finds and crafted
    {
        minReputation = 35,
        maxReputation = 59,
        items = {
            { item = "Base.Gravelbag",       count = 3, name = "Gravel Bags",       baseReward = 80 },
            { item = "Base.Sandbag",         count = 4, name = "Sandbags",          baseReward = 70 },
            { item = "Base.WeldingRods",     count = 2, name = "Welding Rods",      baseReward = 90 },
            { item = "Base.SmallSheetMetal", count = 3, name = "Small Sheet Metal", baseReward = 85 },
            { item = "Base.PropaneTank",     count = 1, name = "Propane Tank",      baseReward = 100 },
        },
    },
    -- Tier 5: Legendary items (reputation 60+) - very rare crafting/finds
    {
        minReputation = 60,
        maxReputation = 999,
        items = {
            { item = "Base.SheetMetal",           count = 3, name = "Sheet Metal",   baseReward = 120 },
            { item = "Base.MetalDrum",            count = 1, name = "Metal Drum",    baseReward = 150 },
            { item = "Base.BarricadeCube_Folded", count = 2, name = "Barricades",    baseReward = 130 },
            { item = "Base.Generator",            count = 1, name = "Generator Mag", baseReward = 140 },
            { item = "Base.WeldingMask",          count = 1, name = "Welding Mask",  baseReward = 160 },
        },
    },
}

-- Elimination mission tiers based on reputation
-- Each tier requires more kills and offers better rewards
-- Rewards are balanced: roughly $1-2 per zombie, with bonuses for weapon restrictions
Amazoid.Missions.EliminationTiers = {
    -- Tier 1: Easy kills (reputation 0+)
    {
        minReputation = 0,
        maxReputation = 9,
        missions = {
            { killCount = 5, weaponType = "any",   weaponName = "any weapon",     baseReward = 8,  timeLimit = nil },
            { killCount = 8, weaponType = "any",   weaponName = "any weapon",     baseReward = 12, timeLimit = nil },
            { killCount = 5, weaponType = "melee", weaponName = "a melee weapon", baseReward = 12, timeLimit = nil },
        },
    },
    -- Tier 2: Moderate challenge (reputation 10+)
    {
        minReputation = 10,
        maxReputation = 24,
        missions = {
            { killCount = 10, weaponType = "any",   weaponName = "any weapon",     baseReward = 15, timeLimit = nil },
            { killCount = 10, weaponType = "melee", weaponName = "a melee weapon", baseReward = 20, timeLimit = nil },
            { killCount = 15, weaponType = "any",   weaponName = "any weapon",     baseReward = 25, timeLimit = 24 },
        },
    },
    -- Tier 3: Skilled kills (reputation 25+)
    {
        minReputation = 25,
        maxReputation = 34,
        missions = {
            { killCount = 15, weaponType = "any",      weaponName = "any weapon",     baseReward = 25, timeLimit = nil },
            { killCount = 15, weaponType = "melee",    weaponName = "a melee weapon", baseReward = 35, timeLimit = 12 },
            { killCount = 12, weaponType = "Base.Axe", weaponName = "an axe",         baseReward = 40, timeLimit = nil },
            { killCount = 20, weaponType = "any",      weaponName = "any weapon",     baseReward = 35, timeLimit = 24 },
        },
    },
    -- Tier 4: Dangerous hunts (reputation 35+)
    {
        minReputation = 35,
        maxReputation = 59,
        missions = {
            { killCount = 25, weaponType = "any",          weaponName = "any weapon",    baseReward = 40, timeLimit = nil },
            { killCount = 15, weaponType = "Base.Crowbar", weaponName = "a crowbar",     baseReward = 50, timeLimit = nil },
            { killCount = 20, weaponType = "melee",        weaponName = "melee weapons", baseReward = 50, timeLimit = 18 },
            { killCount = 15, weaponType = "Base.Katana",  weaponName = "a katana",      baseReward = 60, timeLimit = nil },
        },
    },
    -- Tier 5: Elite exterminator (reputation 60+)
    {
        minReputation = 60,
        maxReputation = 999,
        missions = {
            { killCount = 30, weaponType = "any",               weaponName = "any weapon",     baseReward = 50,  timeLimit = nil },
            { killCount = 25, weaponType = "melee",             weaponName = "melee weapons",  baseReward = 60,  timeLimit = 12 },
            { killCount = 20, weaponType = "Base.Sledgehammer", weaponName = "a sledgehammer", baseReward = 80,  timeLimit = nil },
            { killCount = 50, weaponType = "any",               weaponName = "any weapon",     baseReward = 100, timeLimit = 48 },
        },
    },
}

--- Check if a weapon type is a ranged weapon (firearm)
--- Uses PZ's ScriptManager to dynamically check the weapon's script
---@param weaponType string The weapon type (e.g., "Base.Katana")
---@return boolean True if weapon is ranged
function Amazoid.Missions.isWeaponRanged(weaponType)
    if not weaponType or weaponType == "unarmed" then
        return false
    end

    -- Get the item's script from ScriptManager
    local script = ScriptManager.instance:getItem(weaponType)
    if not script then
        return false
    end

    -- Check if it's a ranged weapon using the script's isRanged property
    if script.isRanged then
        return script:isRanged()
    end

    return false
end

--- Check if a weapon type is a melee weapon
--- A melee weapon is any weapon that is NOT ranged and NOT unarmed
---@param weaponType string The weapon type (e.g., "Base.Katana")
---@return boolean True if weapon is melee
function Amazoid.Missions.isWeaponMelee(weaponType)
    if not weaponType or weaponType == "unarmed" then
        return false
    end

    -- Get the item's script from ScriptManager
    local script = ScriptManager.instance:getItem(weaponType)
    if not script then
        return false
    end

    -- It's melee if it's a weapon but NOT ranged
    -- Check if it has weapon properties (MaxDamage, MinDamage, etc.)
    local maxDamage = script:getMaxDamage()
    if maxDamage and maxDamage > 0 then
        -- It's a weapon - check if ranged
        if script.isRanged and script:isRanged() then
            return false
        end
        return true
    end

    return false
end

--- Check if a weapon matches a requirement
---@param weaponType string The actual weapon type (full item type)
---@param requirement string The requirement ("any", "melee", "firearm", or specific type)
---@return boolean True if weapon matches requirement
function Amazoid.Missions.weaponMatchesRequirement(weaponType, requirement)
    if requirement == "any" then
        return true
    end

    if requirement == "melee" then
        return Amazoid.Missions.isWeaponMelee(weaponType)
    end

    if requirement == "firearm" then
        return Amazoid.Missions.isWeaponRanged(weaponType)
    end

    -- Specific weapon type match
    return weaponType == requirement
end

--- Get available elimination tiers for a given reputation
---@param reputation number Player reputation
---@return table List of available tiers
function Amazoid.Missions.getAvailableEliminationTiers(reputation)
    local available = {}
    for _, tier in ipairs(Amazoid.Missions.EliminationTiers) do
        if reputation >= tier.minReputation then
            table.insert(available, tier)
        end
    end
    return available
end

--- Generate an elimination mission appropriate for player's reputation
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Missions.generateEliminationMission(reputation)
    local availableTiers = Amazoid.Missions.getAvailableEliminationTiers(reputation)

    if #availableTiers == 0 then
        -- Fallback to tier 1
        availableTiers = { Amazoid.Missions.EliminationTiers[1] }
    end

    -- Pick a random tier from available ones (weighted toward higher tiers)
    local tierIndex = #availableTiers
    if #availableTiers > 1 then
        -- 60% chance to pick highest tier, 40% chance for random lower tier
        if ZombRand(100) < 40 then
            tierIndex = ZombRand(1, #availableTiers)
        end
    end

    local selectedTier = availableTiers[tierIndex]
    local selectedMission = selectedTier.missions[ZombRand(1, #selectedTier.missions + 1)]

    -- Calculate reward with reputation bonus
    local reputationBonus = 1 + (reputation / 100)
    local reward = math.floor(selectedMission.baseReward * reputationBonus)
    local reputationReward = Amazoid.Reputation.MISSION_COMPLETE or 3

    -- Create mission description
    local description = "The dead are getting too numerous. We need " ..
        selectedMission.killCount .. " zombies eliminated"

    if selectedMission.weaponType ~= "any" then
        description = description .. " using " .. selectedMission.weaponName
    end
    description = description .. "."

    if selectedMission.timeLimit then
        description = description .. " <RGB:1,0.6,0.3> Complete within " .. selectedMission.timeLimit .. " hours."
    end

    -- Create mission
    local mission = {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.ELIMINATION,
        title = "Elimination: " .. selectedMission.killCount .. " Zombies",
        description = description,
        requirements = {
            killCount = selectedMission.killCount,
            weaponType = selectedMission.weaponType,
            weaponName = selectedMission.weaponName,
        },
        reward = {
            money = reward,
            reputation = reputationReward,
        },
        progress = 0, -- Current kill count
        timeLimit = selectedMission.timeLimit,
        createdAt = getGameTime():getWorldAgeHours(),
        acceptedAt = nil, -- Set when player picks up mission letter
        status = "available",
    }

    return mission
end

--- Get available collection tiers for a given reputation
---@param reputation number Player reputation
---@return table List of available tiers
function Amazoid.Missions.getAvailableTiers(reputation)
    local available = {}
    for _, tier in ipairs(Amazoid.Missions.CollectionTiers) do
        if reputation >= tier.minReputation then
            table.insert(available, tier)
        end
    end
    return available
end

--- Generate a collection mission appropriate for player's reputation
---@param reputation number Player reputation
---@return table Mission data
function Amazoid.Missions.generateCollectionMission(reputation)
    local availableTiers = Amazoid.Missions.getAvailableTiers(reputation)

    if #availableTiers == 0 then
        -- Fallback to tier 1
        availableTiers = { Amazoid.Missions.CollectionTiers[1] }
    end

    -- Pick a random tier from available ones (weighted toward higher tiers)
    local tierIndex = #availableTiers
    if #availableTiers > 1 then
        -- 60% chance to pick highest tier, 40% chance for random lower tier
        if ZombRand(100) < 40 then
            tierIndex = ZombRand(1, #availableTiers)
        end
    end

    local selectedTier = availableTiers[tierIndex]
    local selectedItem = selectedTier.items[ZombRand(1, #selectedTier.items + 1)]

    -- Calculate reward with reputation bonus
    local reputationBonus = 1 + (reputation / 100)
    local reward = math.floor(selectedItem.baseReward * reputationBonus)
    local reputationReward = Amazoid.Reputation.MISSION_COMPLETE or 5

    -- Create mission
    local mission = {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.COLLECTION,
        title = "Collection: " .. selectedItem.name,
        description = "The merchants request " ..
            selectedItem.count .. "x " .. selectedItem.name .. ". Leave them in the mailbox.",
        requirements = {
            itemType = selectedItem.item,
            count = selectedItem.count,
        },
        reward = {
            money = reward,
            reputation = reputationReward,
        },
        timeLimit = nil,      -- Collection missions have no time limit
        createdAt = getGameTime():getWorldAgeHours(),
        status = "available", -- available, active, completed, failed
    }

    return mission
end

--- Generate a simple first contact mission
--- This is always a very easy collection mission
---@return table Mission data
function Amazoid.Missions.generateFirstMission()
    -- Always start with something very simple - avoid liquid items
    local simpleItems = {
        { item = "Base.TinnedBeans", count = 2, name = "Canned Beans", baseReward = 20 },
        { item = "Base.Apple",       count = 3, name = "Apples",       baseReward = 12 },
        { item = "Base.Nails",       count = 5, name = "Nails",        baseReward = 15 },
    }

    local selectedItem = simpleItems[ZombRand(1, #simpleItems + 1)]

    local mission = {
        id = ZombRand(100000, 999999),
        type = Amazoid.MissionTypes.COLLECTION,
        title = "First Task: " .. selectedItem.name,
        description = "To prove your worth, bring us " ..
            selectedItem.count ..
            "x " ..
            selectedItem.name ..
            ". <LINE><LINE> <RGB:1,0.9,0.3> Leave them in the mailbox after signing the contract. <RGB:1,1,1>",
        requirements = {
            itemType = selectedItem.item,
            count = selectedItem.count,
        },
        reward = {
            money = selectedItem.baseReward,
            reputation = 3,
        },
        timeLimit = nil,
        createdAt = getGameTime():getWorldAgeHours(),
        status = "available",
        isFirstMission = true,
    }

    return mission
end

--- Check if a mailbox contains the required items for a mission
---@param mailbox IsoObject The mailbox to check
---@param mission table The mission to check for
---@return boolean, number Whether requirements are met, and how many items found
function Amazoid.Missions.checkMissionItems(mailbox, mission)
    if not mailbox or not mission then return false, 0 end
    if mission.type ~= Amazoid.MissionTypes.COLLECTION then return false, 0 end

    -- Ensure mission has proper structure (deserialize if needed)
    mission = Amazoid.Missions.deserializeFromModData(mission)
    if not mission or not mission.requirements then
        print("[Amazoid] Mission missing requirements data")
        return false, 0
    end

    local container = mailbox:getContainer()
    if not container then return false, 0 end

    local requiredType = mission.requirements.itemType
    local requiredCount = mission.requirements.count or 1

    -- Count matching items in mailbox
    local foundCount = 0
    local items = container:getItems()

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getFullType() == requiredType then
            foundCount = foundCount + 1
        end
    end

    return foundCount >= requiredCount, foundCount
end

--- Remove mission items from mailbox and complete mission
---@param mailbox IsoObject The mailbox
---@param mission table The mission
---@return boolean Success
function Amazoid.Missions.collectMissionItems(mailbox, mission)
    if not mailbox or not mission then return false end
    if mission.type ~= Amazoid.MissionTypes.COLLECTION then return false end

    -- Ensure mission has proper structure (deserialize if needed)
    mission = Amazoid.Missions.deserializeFromModData(mission)
    if not mission or not mission.requirements then
        print("[Amazoid] Mission missing requirements data for collection")
        return false
    end

    local container = mailbox:getContainer()
    if not container then return false end

    local requiredType = mission.requirements.itemType
    local requiredCount = mission.requirements.count or 1
    local collectedCount = 0

    -- Collect items (remove from container)
    local items = container:getItems()
    local itemsToRemove = {}

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getFullType() == requiredType and collectedCount < requiredCount then
            table.insert(itemsToRemove, item)
            collectedCount = collectedCount + 1
        end
    end

    -- Remove collected items
    for _, item in ipairs(itemsToRemove) do
        container:Remove(item)
    end

    print("[Amazoid] Collected " .. collectedCount .. " items for mission " .. mission.id)
    return collectedCount >= requiredCount
end

--- Create a mission letter item with mission data
---@param mission table The mission data
---@return string The letter content
function Amazoid.Missions.createMissionLetterContent(mission)
    local content = " <CENTRE> <SIZE:medium> <RGB:0.8,0.6,0.2> MISSION REQUEST <LINE> "
    content = content .. " <LEFT> <SIZE:small> <RGB:1,1,1> <LINE> "
    content = content .. mission.title .. " <LINE><LINE> "

    -- For collection missions, show what's needed
    if mission.type == Amazoid.MissionTypes.COLLECTION and mission.requirements then
        local itemType = mission.requirements.itemType
        local itemCount = mission.requirements.count or 1
        if itemType then
            -- Get display name for the item
            local displayName = itemType:gsub("Base%.", ""):gsub("([A-Z])", " %1"):gsub("^%s+", "")
            content = content .. " <CENTRE> <RGB:0.9,0.8,0.5> " .. itemCount .. "x " .. displayName .. " <LINE><LINE> "
            content = content .. " <LEFT> <RGB:1,1,1> "
        end
    end

    content = content .. mission.description .. " <LINE><LINE> "
    content = content .. " <RGB:0.6,0.8,0.4> Reward: <LINE> "
    content = content .. "  - $" .. mission.reward.money .. " <LINE> "
    content = content .. "  - +" .. mission.reward.reputation .. " Reputation <LINE><LINE> "

    if mission.timeLimit then
        content = content .. " <RGB:0.8,0.4,0.4> Time Limit: " .. mission.timeLimit .. " hours <LINE> "
    else
        content = content .. " <RGB:0.6,0.6,0.6> No time limit <LINE> "
    end

    content = content .. " <LINE> <CENTRE> <RGB:0.5,0.5,0.5> <SIZE:small> "

    -- Add mission-type specific instructions
    if mission.type == Amazoid.MissionTypes.ELIMINATION then
        content = content .. "Eliminate the required zombies. <LINE> "
        content = content .. "Progress is tracked automatically. <LINE> "
        content = content .. "Return to the mailbox when complete. <LINE> "
    else
        content = content .. "Leave the requested items in the mailbox. <LINE> "
        content = content .. "We will collect them on our next visit. <LINE> "
    end

    return content
end

--- Create a mission completion letter
---@param mission table The completed mission
---@return string The letter content
function Amazoid.Missions.createCompletionLetterContent(mission)
    local content = " <CENTRE> <SIZE:medium> <RGB:0.4,0.8,0.4> MISSION COMPLETE <LINE> "
    content = content .. " <LEFT> <SIZE:small> <RGB:1,1,1> <LINE> "
    content = content .. "Excellent work! <LINE><LINE> "

    if mission.type == Amazoid.MissionTypes.ELIMINATION then
        content = content .. "We have confirmed your kills for: <LINE> "
    else
        content = content .. "We have collected the items for: <LINE> "
    end

    content = content .. " <RGB:0.8,0.6,0.2> " .. mission.title .. " <LINE><LINE> "
    content = content .. " <RGB:1,1,1> Your reward has been placed in the mailbox: <LINE> "
    content = content .. " <RGB:0.6,0.8,0.4> "
    content = content .. "  - $" .. mission.reward.money .. " <LINE> "
    content = content .. "  - +" .. mission.reward.reputation .. " Reputation <LINE><LINE> "
    content = content .. " <CENTRE> <RGB:0.5,0.5,0.5> <SIZE:small> "
    content = content .. "We look forward to working with you again. <LINE> "
    content = content .. " <LINE> - The Merchants <LINE> "

    return content
end

--- Serialize mission data for storing in modData
--- Flattens nested tables to ensure proper serialization
---@param mission table The mission data
---@return table Flattened mission data safe for modData
function Amazoid.Missions.serializeForModData(mission)
    if not mission then return nil end

    return {
        id = mission.id,
        type = mission.type,
        title = mission.title,
        description = mission.description,
        missionNumber = mission.missionNumber, -- Track mission number for completion letters
        -- Flatten requirements (collection)
        reqItemType = mission.requirements and mission.requirements.itemType,
        reqCount = mission.requirements and mission.requirements.count,
        -- Flatten requirements (elimination)
        reqKillCount = mission.requirements and mission.requirements.killCount,
        reqWeaponType = mission.requirements and mission.requirements.weaponType,
        reqWeaponName = mission.requirements and mission.requirements.weaponName,
        -- Flatten reward
        rewardMoney = mission.reward and mission.reward.money,
        rewardReputation = mission.reward and mission.reward.reputation,
        rewardItem = mission.reward and mission.reward.item,
        -- Progress tracking (elimination)
        progress = mission.progress,
        -- Other fields
        timeLimit = mission.timeLimit,
        createdAt = mission.createdAt,
        acceptedAt = mission.acceptedAt,
        status = mission.status,
    }
end

--- Deserialize mission data from modData
--- Reconstructs nested tables from flattened data
---@param flatMission table Flattened mission data from modData
---@return table Full mission data with nested tables
function Amazoid.Missions.deserializeFromModData(flatMission)
    if not flatMission then return nil end

    -- If it already has nested tables (from activeMissions), return as-is
    if flatMission.requirements and flatMission.reward then
        return flatMission
    end

    local mission = {
        id = flatMission.id,
        type = flatMission.type,
        title = flatMission.title,
        description = flatMission.description,
        missionNumber = flatMission.missionNumber, -- Restore mission number for completion letters
        requirements = {},
        reward = {
            money = flatMission.rewardMoney,
            reputation = flatMission.rewardReputation,
            item = flatMission.rewardItem,
        },
        progress = flatMission.progress,
        timeLimit = flatMission.timeLimit,
        createdAt = flatMission.createdAt,
        acceptedAt = flatMission.acceptedAt,
        status = flatMission.status,
    }

    -- Reconstruct requirements based on mission type
    if flatMission.type == Amazoid.MissionTypes.ELIMINATION then
        mission.requirements = {
            killCount = flatMission.reqKillCount,
            weaponType = flatMission.reqWeaponType,
            weaponName = flatMission.reqWeaponName,
        }
    else
        -- Collection or other mission types
        mission.requirements = {
            itemType = flatMission.reqItemType,
            count = flatMission.reqCount,
        }
    end

    return mission
end

print("[Amazoid] Missions module loaded")
