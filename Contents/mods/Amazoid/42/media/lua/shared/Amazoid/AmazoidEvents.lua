--[[
    Amazoid - Mysterious Mailbox Merchant
    Event System

    Centralized pub/sub event system for decoupled communication between modules.
    Other modules can subscribe to events and react without tight coupling.

    Usage:
        -- Subscribe to an event
        Amazoid.Events.on("ReputationChanged", function(data)
            print("Reputation changed from " .. data.oldRep .. " to " .. data.newRep)
        end)

        -- Fire an event
        Amazoid.Events.fire("ReputationChanged", {oldRep = 10, newRep = 15, reason = "mission"})
]]

require "Amazoid/AmazoidData"

Amazoid.Events = Amazoid.Events or {}

-- Event listeners storage
-- Format: { eventName = { {callback = fn, priority = n}, ... } }
Amazoid.Events.listeners = {}

-- Event names (for documentation and autocomplete)
Amazoid.Events.Names = {
    -- Reputation events
    REPUTATION_CHANGED = "ReputationChanged", -- {oldRep, newRep, reason}

    -- Money events
    MONEY_SPENT = "MoneySpent", -- {amount, category, totalSpent, totalSpentByCategory}

    -- Order events
    ORDER_PLACED = "OrderPlaced",       -- {order, mailbox}
    ORDER_DELIVERED = "OrderDelivered", -- {order, mailbox}

    -- Mission events
    MISSION_ACCEPTED = "MissionAccepted",   -- {mission}
    MISSION_COMPLETED = "MissionCompleted", -- {mission, rewards}
    MISSION_FAILED = "MissionFailed",       -- {mission, reason}

    -- Contract events
    CONTRACT_SIGNED = "ContractSigned", -- {mailboxLocation}
    FIRST_CONTACT = "FirstContact",     -- {mailbox}

    -- Catalog events
    CATALOG_UNLOCKED = "CatalogUnlocked", -- {category, volume}
    VOLUME_UNLOCKED = "VolumeUnlocked",   -- {category, volume}

    -- Gift events
    GIFT_SENT = "GiftSent", -- {triggerType, items, mailbox}

    -- Player action events (for gift tracking)
    PLAYER_HEALED = "PlayerHealed", -- {player, healCount}
    ZOMBIE_KILLED = "ZombieKilled", -- {player, killStreak, weapon}
    FOOD_COOKED = "FoodCooked",     -- {player, cookCount}
    BOOK_READ = "BookRead",         -- {player, book, readCount}
    DAYS_SURVIVED = "DaysSurvived", -- {player, days}
}

--- Subscribe to an event
---@param eventName string The event name to listen for
---@param callback function The function to call when event fires
---@param priority number? Optional priority (higher = called first, default 0)
function Amazoid.Events.on(eventName, callback, priority)
    if not eventName or type(callback) ~= "function" then
        print("[Amazoid Events] ERROR: Invalid event subscription - eventName: " ..
            tostring(eventName) .. ", callback type: " .. type(callback))
        return
    end

    priority = priority or 0

    Amazoid.Events.listeners[eventName] = Amazoid.Events.listeners[eventName] or {}

    table.insert(Amazoid.Events.listeners[eventName], {
        callback = callback,
        priority = priority,
    })

    -- Sort by priority (descending - higher priority first)
    table.sort(Amazoid.Events.listeners[eventName], function(a, b)
        return a.priority > b.priority
    end)

    print("[Amazoid Events] Subscribed to '" .. eventName .. "' (priority: " .. priority .. ")")
end

--- Unsubscribe from an event
---@param eventName string The event name
---@param callback function The callback to remove
function Amazoid.Events.off(eventName, callback)
    if not Amazoid.Events.listeners[eventName] then return end

    for i = #Amazoid.Events.listeners[eventName], 1, -1 do
        if Amazoid.Events.listeners[eventName][i].callback == callback then
            table.remove(Amazoid.Events.listeners[eventName], i)
            print("[Amazoid Events] Unsubscribed from '" .. eventName .. "'")
            return
        end
    end
end

--- Fire an event, notifying all listeners
---@param eventName string The event name
---@param data table? Data to pass to listeners
function Amazoid.Events.fire(eventName, data)
    if not eventName then return end

    data = data or {}

    local listeners = Amazoid.Events.listeners[eventName]
    if not listeners or #listeners == 0 then
        -- No listeners, that's okay
        return
    end

    print("[Amazoid Events] Firing '" .. eventName .. "' to " .. #listeners .. " listener(s)")

    for _, listener in ipairs(listeners) do
        local success, err = pcall(listener.callback, data)
        if not success then
            print("[Amazoid Events] ERROR in listener for '" .. eventName .. "': " .. tostring(err))
        end
    end
end

--- Clear all listeners for an event (useful for testing)
---@param eventName string? The event name, or nil to clear all
function Amazoid.Events.clear(eventName)
    if eventName then
        Amazoid.Events.listeners[eventName] = nil
        print("[Amazoid Events] Cleared listeners for '" .. eventName .. "'")
    else
        Amazoid.Events.listeners = {}
        print("[Amazoid Events] Cleared all listeners")
    end
end

--- Get number of listeners for an event
---@param eventName string The event name
---@return number
function Amazoid.Events.getListenerCount(eventName)
    if not Amazoid.Events.listeners[eventName] then return 0 end
    return #Amazoid.Events.listeners[eventName]
end

--[[
    ============================================
    REPUTATION-BASED THRESHOLDS
    ============================================

    This section defines all reputation thresholds to avoid collisions.
    When adding new features, check this table first!

    Rep | Feature                  | Type
    ----|--------------------------|------------
    0   | Basic Catalog            | Catalog
    10  | Medical Catalog          | Catalog
    10  | Tools of Trade           | Milestone
    15  | How It Started           | Lore
    18  | First Gift               | Gift
    20  | Steady Customer          | Milestone
    25  | Armed & Dangerous        | Milestone
    25  | Tools Catalog            | Catalog
    28  | The Companions           | Lore
    32  | Second Gift              | Gift
    35  | Seasons Change           | Milestone
    35  | Seasonal Catalog         | Catalog
    38  | The Discovery            | Lore
    40  | Valued Partner           | Milestone
    45  | Weapons Catalog          | Catalog
    48  | Trial and Error          | Lore
    50  | Black Market Welcome     | Milestone
    52  | Third Gift               | Gift
    58  | Before the Fall          | Lore
    60  | Inner Circle             | Milestone
    60  | Black Market Catalog     | Catalog
    65  | Fourth Gift              | Gift
    70  | One of Us                | Milestone
    72  | The Secret               | Lore
    78  | Fifth Gift               | Gift
    80  | Trust Complete           | Milestone
    85  | Our Home                 | Lore
    90  | Final Stretch            | Milestone
    92  | Sixth Gift               | Gift
    100 | Welcome Home             | Milestone
]]

-- Gift reputation thresholds (used by gift system)
Amazoid.Events.GiftThresholds = { 18, 32, 52, 65, 78, 92 }

-- Lore reputation thresholds (must match Letters.Lore entries)
Amazoid.Events.LoreThresholds = { 15, 28, 38, 48, 58, 72, 85 }

print("[Amazoid] Events module loaded")
