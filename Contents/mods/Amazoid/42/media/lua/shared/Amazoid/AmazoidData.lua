--[[
    Amazoid - Mysterious Mailbox Merchant
    Shared Data Module
    
    This file contains shared data structures and constants used across client and server.
]]

Amazoid = Amazoid or {}

-- Version info
Amazoid.VERSION = "0.1.0"
Amazoid.MOD_ID = "Amazoid"

-- Reputation thresholds
Amazoid.Reputation = {
    MIN = -100,
    MAX = 100,
    STARTING = 0,
    
    -- Thresholds for unlocks
    CATALOG_BASIC = 0,
    CATALOG_TOOLS = 10,
    CATALOG_WEAPONS = 25,
    CATALOG_MEDICAL = 25,
    CATALOG_SEASONAL = 35,
    CATALOG_BLACKMARKET = 50,
    
    -- Reputation changes
    MISSION_COMPLETE = 5,
    MISSION_FAIL = -10,
    OVERPAY_BONUS = 1,          -- Per dollar overpaid (capped)
    UNDERPAY_PENALTY = -2,      -- Per dollar underpaid
    SCAVENGER_KEEP_ITEMS = -15, -- Keeping scavenger hunt items
    GIFT_RECEIVED = 1,
}

-- Delivery times (in game hours)
Amazoid.DeliveryTime = {
    MIN = 6,
    MAX = 24,
    RUSH_MULTIPLIER = 0.5,      -- Rush orders take half the time
    RUSH_COST_MULTIPLIER = 2.0, -- Rush orders cost double
}

-- Mailbox types and their capacity
Amazoid.MailboxTypes = {
    STANDARD = {
        id = "standard",
        name = "Standard Mailbox",
        maxWeight = 5,
        maxSize = 1,            -- Small items only
        description = "A regular mailbox. Can hold small items.",
    },
    LARGE = {
        id = "large",
        name = "Large Mailbox",
        maxWeight = 15,
        maxSize = 2,            -- Medium items
        description = "An upgraded mailbox. Can hold medium items.",
    },
    CRATE = {
        id = "crate",
        name = "Delivery Crate",
        maxWeight = 50,
        maxSize = 3,            -- Large items
        description = "A reinforced crate. Can hold large items like furniture.",
    },
}

-- Mission types
Amazoid.MissionTypes = {
    COLLECTION = "collection",       -- Leave items in mailbox
    ELIMINATION = "elimination",     -- Kill zombies (with specific weapon)
    SCAVENGER = "scavenger",         -- Find marked zombie
    TIMED_DELIVERY = "timed_delivery", -- Deliver to another mailbox
    PROTECTION = "protection",       -- Protect noisy device from zombies
}

-- Catalog categories
Amazoid.CatalogCategories = {
    BASIC = "basic",           -- Food, basic supplies
    TOOLS = "tools",           -- Hammers, saws, etc.
    WEAPONS = "weapons",       -- Melee and ranged weapons
    MEDICAL = "medical",       -- First aid, medicine
    SEASONAL = "seasonal",     -- Season-specific items
    BLACKMARKET = "blackmarket", -- Rare and powerful items
}

-- Seasons (for seasonal catalogs)
Amazoid.Seasons = {
    SPRING = "spring",
    SUMMER = "summer",
    AUTUMN = "autumn",
    WINTER = "winter",
}

-- Gift triggers (player actions that can trigger merchant gifts)
Amazoid.GiftTriggers = {
    HEAL_WOUND = "heal_wound",       -- Using rags/bandages -> gift bandage
    COOK_FOOD = "cook_food",         -- Cooking -> gift cooking supplies
    READ_BOOK = "read_book",         -- Reading -> gift book
    KILL_MANY = "kill_many",         -- Kill streak -> gift weapon
    SURVIVE_DAYS = "survive_days",   -- Survival milestone -> gift supplies
}

-- Contract status
Amazoid.ContractStatus = {
    NONE = "none",
    PENDING = "pending",      -- Letter found, not yet signed
    ACTIVE = "active",        -- Contract signed, service active
    SUSPENDED = "suspended",  -- Reputation too low
}

print("[Amazoid] Shared data module loaded - v" .. Amazoid.VERSION)
