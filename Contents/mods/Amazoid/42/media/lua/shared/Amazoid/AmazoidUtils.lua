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

--- Calculate reputation change from payment
---@param expectedPrice number Expected price
---@param paidAmount number Amount paid
---@return number Reputation change
function Amazoid.Utils.calculatePaymentReputation(expectedPrice, paidAmount)
    local difference = paidAmount - expectedPrice
    
    if difference >= 0 then
        -- Overpaid - gain reputation (capped at 5)
        return math.min(difference * Amazoid.Reputation.OVERPAY_BONUS, 5)
    else
        -- Underpaid - lose reputation
        return difference * Amazoid.Reputation.UNDERPAY_PENALTY
    end
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

--- Calculate delivery time based on reputation and rush order
---@param reputation number Current reputation
---@param isRush boolean Is this a rush order
---@return number Delivery time in game hours
function Amazoid.Utils.calculateDeliveryTime(reputation, isRush)
    -- Base time decreases slightly with reputation
    local repBonus = (reputation / Amazoid.Reputation.MAX) * 0.2 -- Up to 20% faster
    local baseTime = ZombRand(Amazoid.DeliveryTime.MIN, Amazoid.DeliveryTime.MAX + 1)
    
    local time = baseTime * (1 - repBonus)
    
    if isRush then
        time = time * Amazoid.DeliveryTime.RUSH_MULTIPLIER
    end
    
    return math.max(math.floor(time), 1)
end

--- Check if an item fits in a mailbox type
---@param item InventoryItem The item to check
---@param mailboxType table Mailbox type from Amazoid.MailboxTypes
---@return boolean
function Amazoid.Utils.itemFitsInMailbox(item, mailboxType)
    if not item or not mailboxType then
        return false
    end
    
    local weight = item:getWeight()
    -- TODO: Implement size checking based on item categories
    
    return weight <= mailboxType.maxWeight
end

--- Generate a random mission based on reputation
---@param reputation number Current reputation
---@return table|nil Mission data or nil if no mission available
function Amazoid.Utils.generateMission(reputation)
    -- TODO: Implement mission generation
    return nil
end

--- Clamp reputation to valid range
---@param reputation number Current reputation
---@return number Clamped reputation
function Amazoid.Utils.clampReputation(reputation)
    return math.max(Amazoid.Reputation.MIN, math.min(Amazoid.Reputation.MAX, reputation))
end

print("[Amazoid] Utils module loaded")
