--[[
    Amazoid - Mysterious Mailbox Merchant
    Utility Functions

    This file contains shared utility functions.
]]

require "Amazoid/AmazoidData"

Amazoid.Utils = Amazoid.Utils or {}

--- Check if player has enough reputation for a catalog
---@param reputation number Current reputation
---@param catalogType string Catalog type from Amazoid.CatalogCategories
---@return boolean
function Amazoid.Utils.canAccessCatalog(reputation, catalogType)
    local thresholds = {
        [Amazoid.CatalogCategories.BASIC] = Amazoid.Reputation.CATALOG_BASIC,
        [Amazoid.CatalogCategories.TOOLS] = Amazoid.Reputation.CATALOG_TOOLS,
        [Amazoid.CatalogCategories.WEAPONS] = Amazoid.Reputation.CATALOG_WEAPONS,
        [Amazoid.CatalogCategories.MEDICAL] = Amazoid.Reputation.CATALOG_MEDICAL,
        [Amazoid.CatalogCategories.SEASONAL] = Amazoid.Reputation.CATALOG_SEASONAL,
        [Amazoid.CatalogCategories.BLACKMARKET] = Amazoid.Reputation.CATALOG_BLACKMARKET,
    }

    local required = thresholds[catalogType] or 0
    return reputation >= required
end

--- Calculate discount based on reputation
---@param reputation number Current reputation
---@return number Discount multiplier (0.0 to 0.3)
function Amazoid.Utils.calculateDiscount(reputation)
    if reputation <= 0 then
        return 0
    end
    -- Max 30% discount at max reputation
    local discount = (reputation / Amazoid.Reputation.MAX) * 0.3
    return math.min(discount, 0.3)
end

--- Get current season based on game time
---@return string Season from Amazoid.Seasons
function Amazoid.Utils.getCurrentSeason()
    local gameTime = getGameTime()
    if not gameTime then
        return Amazoid.Seasons.SUMMER
    end

    local month = gameTime:getMonth() + 1 -- Lua is 1-indexed

    if month >= 3 and month <= 5 then
        return Amazoid.Seasons.SPRING
    elseif month >= 6 and month <= 8 then
        return Amazoid.Seasons.SUMMER
    elseif month >= 9 and month <= 11 then
        return Amazoid.Seasons.AUTUMN
    else
        return Amazoid.Seasons.WINTER
    end
end

--- Calculate delivery time based on reputation, item count, and add randomness
---@param reputation number Current reputation
---@param isRush boolean Is this a rush order
---@param itemCount number Optional - number of items in the order
---@return number Delivery time in game hours (estimate - actual may vary)
function Amazoid.Utils.calculateDeliveryTime(reputation, isRush, itemCount)
    itemCount = itemCount or 1

    -- Base time range (6-24 hours)
    local baseTime = ZombRand(Amazoid.DeliveryTime.MIN, Amazoid.DeliveryTime.MAX + 1)

    -- Reputation bonus: up to 30% faster at max reputation
    local repBonus = (reputation / Amazoid.Reputation.MAX) * 0.3

    -- Item count penalty: each additional item adds 0.5-1.5 hours
    local itemPenalty = 0
    if itemCount > 1 then
        itemPenalty = (itemCount - 1) * (0.5 + ZombRand(0, 11) / 10) -- 0.5 to 1.5 per item
    end

    -- Calculate base delivery time
    local time = baseTime * (1 - repBonus) + itemPenalty

    if isRush then
        time = time * Amazoid.DeliveryTime.RUSH_MULTIPLIER
    end

    -- Round to nearest hour for the estimate shown to player
    return math.max(math.floor(time + 0.5), 1)
end

--- Calculate actual delivery time (adds variance to the estimate)
--- Actual delivery can be 10% early to 20% late
---@param estimatedTime number The estimated delivery time
---@return number Actual delivery time in game hours
function Amazoid.Utils.calculateActualDeliveryTime(estimatedTime)
    -- Variance: -10% to +20% of estimated time
    local variance = ZombRand(-10, 21) / 100 -- -0.10 to +0.20
    local actualTime = estimatedTime * (1 + variance)
    return math.max(math.floor(actualTime), 1)
end

--- Clamp reputation to valid range
---@param reputation number Current reputation
---@return number Clamped reputation
function Amazoid.Utils.clampReputation(reputation)
    return math.max(Amazoid.Reputation.MIN, math.min(Amazoid.Reputation.MAX, reputation))
end

--- Check if any player has read a specific item (split-screen support)
--- Uses modData.AmazoidRead flag which is set when ANY player closes the letter
---@param item InventoryItem The item to check
---@return boolean True if any player has read this item
function Amazoid.Utils.hasAnyPlayerRead(item)
    if not item then return false end

    -- First check our custom flag (set when any player closes the letter)
    local modData = item:getModData()
    if modData and modData.AmazoidRead then
        return true
    end

    -- Fallback: check PZ's literature tracking for all players
    if modData and modData.literatureTitle then
        local literatureTitle = modData.literatureTitle
        local players = IsoPlayer.getPlayers()
        if players then
            for i = 0, players:size() - 1 do
                local p = players:get(i)
                if p and p:getAlreadyReadPages() then
                    local readPages = p:getAlreadyReadPages()
                    if readPages:contains(literatureTitle) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

print("[Amazoid] Utils module loaded")
