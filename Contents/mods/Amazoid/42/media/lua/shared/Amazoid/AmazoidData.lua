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
    CATALOG_SEASONAL = 5,
    CATALOG_OUTDOOR = 10,
    CATALOG_CLOTHING = 15,
    CATALOG_TOOLS = 20,
    CATALOG_LITERATURE = 25,
    CATALOG_MEDICAL = 30,
    CATALOG_ELECTRONICS = 35,
    CATALOG_WEAPONS = 40,
    CATALOG_BLACKMARKET = 60,

    -- Threshold below which merchant may steal money
    STEAL_THRESHOLD = 10,

    -- Reputation changes
    MISSION_COMPLETE = 3,
    MISSION_FAIL = -10,
    UNDERPAY_PENALTY = -2,      -- Per dollar underpaid
    SCAVENGER_KEEP_ITEMS = -15, -- Keeping scavenger hunt items
    GIFT_RECEIVED = 1,
    ORDER_DELIVERED_BASE = 0,   -- Base reputation for completing an order
    ORDER_DELIVERED_PER_10 = 1, -- Additional reputation per $10 spent (e.g., $50 order = +5 rep)
}

-- Delivery times (in game hours)
Amazoid.DeliveryTime = {
    MIN = 2,
    MAX = 12,
    RUSH_MULTIPLIER = 0.5,      -- Rush orders take half the time
    RUSH_COST_MULTIPLIER = 2.0, -- Rush orders cost double
}

-- Mailbox types and their capacity
Amazoid.MailboxTypes = {
    STANDARD = {
        id = "standard",
        name = "Standard Mailbox",
        maxWeight = 5,
        maxSize = 1, -- Small items only
        description = "A regular mailbox. Can hold small items.",
    },
    LARGE = {
        id = "large",
        name = "Large Mailbox",
        maxWeight = 15,
        maxSize = 2, -- Medium items
        description = "An upgraded mailbox. Can hold medium items.",
    },
    CRATE = {
        id = "crate",
        name = "Delivery Crate",
        maxWeight = 50,
        maxSize = 3, -- Large items
        description = "A reinforced crate. Can hold large items like furniture.",
    },
}

-- Mission types
Amazoid.MissionTypes = {
    COLLECTION = "collection",         -- Leave items in mailbox
    ELIMINATION = "elimination",       -- Kill zombies (with specific weapon)
    SCAVENGER = "scavenger",           -- Find marked zombie
    TIMED_DELIVERY = "timed_delivery", -- Deliver to another mailbox
    PROTECTION = "protection",         -- Protect noisy device from zombies
}

-- Catalog categories
Amazoid.CatalogCategories = {
    BASIC = "basic",             -- Food, basic supplies
    TOOLS = "tools",             -- Hammers, saws, etc.
    WEAPONS = "weapons",         -- Melee and ranged weapons
    MEDICAL = "medical",         -- First aid, medicine
    SEASONAL = "seasonal",       -- Season-specific items
    BLACKMARKET = "blackmarket", -- Rare and powerful items
}

-- Seasons (for seasonal catalogs)
Amazoid.Seasons = {
    SPRING = "spring",
    SUMMER = "summer",
    AUTUMN = "autumn",
    WINTER = "winter",
}

-- Catalog volume unlock thresholds (money spent to unlock next volume)
-- When you spend this much total from a category, you unlock the next volume
Amazoid.CatalogVolumeThreshold = 100 -- Spend $100 total to unlock next volume

-- Gift triggers (player actions that can trigger merchant gifts)
Amazoid.GiftTriggers = {
    HEAL_WOUND = "heal_wound",     -- Using rags/bandages -> gift bandage
    COOK_FOOD = "cook_food",       -- Cooking -> gift cooking supplies
    READ_BOOK = "read_book",       -- Reading -> gift book
    KILL_MANY = "kill_many",       -- Kill streak -> gift weapon
    SURVIVE_DAYS = "survive_days", -- Survival milestone -> gift supplies
}

-- Contract status
Amazoid.ContractStatus = {
    NONE = "none",
    PENDING = "pending",     -- Letter found, not yet signed
    ACTIVE = "active",       -- Contract signed, service active
    SUSPENDED = "suspended", -- Reputation too low
}

print("[Amazoid] Shared data module loaded - v" .. Amazoid.VERSION)
