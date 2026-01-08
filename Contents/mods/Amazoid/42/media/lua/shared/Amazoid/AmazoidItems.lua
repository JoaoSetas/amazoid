--[[
    Amazoid - Mysterious Mailbox Merchant
    Items Database
    
    This file contains the catalog items and their properties.
]]

require "Amazoid/AmazoidData"

Amazoid.Items = Amazoid.Items or {}

-- Base catalog items (always available after contract)
Amazoid.Items.BasicCatalog = {
    -- Food
    {
        itemType = "Base.TinnedBeans",
        name = "Canned Beans",
        basePrice = 15,
        category = "food",
        size = 1,
    },
    {
        itemType = "Base.TinnedSoup",
        name = "Canned Soup",
        basePrice = 18,
        category = "food",
        size = 1,
    },
    {
        itemType = "Base.CannedCorn",
        name = "Canned Corn",
        basePrice = 12,
        category = "food",
        size = 1,
    },
    {
        itemType = "Base.Pop",
        name = "Soda",
        basePrice = 5,
        category = "drink",
        size = 1,
    },
    {
        itemType = "Base.WhiskeyFull",
        name = "Whiskey",
        basePrice = 35,
        category = "drink",
        size = 1,
    },
    -- Basic supplies
    {
        itemType = "Base.Matches",
        name = "Matches",
        basePrice = 8,
        category = "supplies",
        size = 1,
    },
    {
        itemType = "Base.Candle",
        name = "Candle",
        basePrice = 10,
        category = "supplies",
        size = 1,
    },
    {
        itemType = "Base.Battery",
        name = "Battery",
        basePrice = 12,
        category = "supplies",
        size = 1,
    },
}

-- Tools catalog (reputation >= 10)
Amazoid.Items.ToolsCatalog = {
    {
        itemType = "Base.Hammer",
        name = "Hammer",
        basePrice = 45,
        category = "tools",
        size = 1,
    },
    {
        itemType = "Base.Screwdriver",
        name = "Screwdriver",
        basePrice = 25,
        category = "tools",
        size = 1,
    },
    {
        itemType = "Base.Saw",
        name = "Saw",
        basePrice = 55,
        category = "tools",
        size = 2,
    },
    {
        itemType = "Base.Wrench",
        name = "Wrench",
        basePrice = 40,
        category = "tools",
        size = 1,
    },
    {
        itemType = "Base.Nails",
        name = "Box of Nails",
        basePrice = 20,
        category = "materials",
        size = 1,
    },
    {
        itemType = "Base.Plank",
        name = "Wooden Plank",
        basePrice = 15,
        category = "materials",
        size = 2,
    },
}

-- Weapons catalog (reputation >= 25)
Amazoid.Items.WeaponsCatalog = {
    {
        itemType = "Base.BaseballBat",
        name = "Baseball Bat",
        basePrice = 65,
        category = "melee",
        size = 2,
    },
    {
        itemType = "Base.Crowbar",
        name = "Crowbar",
        basePrice = 75,
        category = "melee",
        size = 2,
    },
    {
        itemType = "Base.Axe",
        name = "Axe",
        basePrice = 120,
        category = "melee",
        size = 2,
    },
    {
        itemType = "Base.HuntingKnife",
        name = "Hunting Knife",
        basePrice = 85,
        category = "melee",
        size = 1,
    },
    {
        itemType = "Base.Bullets9mm",
        name = "9mm Ammo (Box)",
        basePrice = 100,
        category = "ammo",
        size = 1,
    },
    {
        itemType = "Base.ShotgunShells",
        name = "Shotgun Shells (Box)",
        basePrice = 120,
        category = "ammo",
        size = 1,
    },
}

-- Medical catalog (reputation >= 25)
Amazoid.Items.MedicalCatalog = {
    {
        itemType = "Base.Bandage",
        name = "Bandage",
        basePrice = 25,
        category = "medical",
        size = 1,
    },
    {
        itemType = "Base.AlcoholBandage",
        name = "Sterilized Bandage",
        basePrice = 45,
        category = "medical",
        size = 1,
    },
    {
        itemType = "Base.Pills",
        name = "Painkillers",
        basePrice = 35,
        category = "medical",
        size = 1,
    },
    {
        itemType = "Base.Antibiotics",
        name = "Antibiotics",
        basePrice = 80,
        category = "medical",
        size = 1,
    },
    {
        itemType = "Base.SutureNeedle",
        name = "Suture Needle",
        basePrice = 60,
        category = "medical",
        size = 1,
    },
    {
        itemType = "Base.Disinfectant",
        name = "Disinfectant",
        basePrice = 50,
        category = "medical",
        size = 1,
    },
}

-- Seasonal catalogs (reputation >= 35)
Amazoid.Items.SeasonalCatalogs = {
    [Amazoid.Seasons.SPRING] = {
        {
            itemType = "Base.FarmingSprayEmpty",
            name = "Farming Spray",
            basePrice = 40,
            category = "farming",
            size = 1,
        },
        {
            itemType = "Base.Trowel",
            name = "Trowel",
            basePrice = 30,
            category = "farming",
            size = 1,
        },
        -- Seeds would go here
    },
    [Amazoid.Seasons.SUMMER] = {
        {
            itemType = "Base.Sunglasses",
            name = "Sunglasses",
            basePrice = 25,
            category = "clothing",
            size = 1,
        },
        {
            itemType = "Base.Hat_BaseballCap",
            name = "Baseball Cap",
            basePrice = 20,
            category = "clothing",
            size = 1,
        },
    },
    [Amazoid.Seasons.AUTUMN] = {
        {
            itemType = "Base.Jacket_Padded",
            name = "Padded Jacket",
            basePrice = 75,
            category = "clothing",
            size = 2,
        },
    },
    [Amazoid.Seasons.WINTER] = {
        {
            itemType = "Base.Hat_WinterHat",
            name = "Winter Hat",
            basePrice = 35,
            category = "clothing",
            size = 1,
        },
        {
            itemType = "Base.Gloves_LeatherGloves",
            name = "Leather Gloves",
            basePrice = 45,
            category = "clothing",
            size = 1,
        },
        {
            itemType = "Base.Scarf",
            name = "Scarf",
            basePrice = 30,
            category = "clothing",
            size = 1,
        },
    },
}

-- Black Market catalog (reputation >= 50)
Amazoid.Items.BlackMarketCatalog = {
    {
        itemType = "Base.Pistol",
        name = "Pistol",
        basePrice = 350,
        category = "firearm",
        size = 1,
    },
    {
        itemType = "Base.Shotgun",
        name = "Shotgun",
        basePrice = 500,
        category = "firearm",
        size = 2, -- Needs large mailbox
    },
    {
        itemType = "Base.AssaultRifle",
        name = "Assault Rifle",
        basePrice = 750,
        category = "firearm",
        size = 2,
    },
    {
        itemType = "Base.Katana",
        name = "Katana",
        basePrice = 400,
        category = "melee",
        size = 2,
    },
    {
        itemType = "Base.NightVisionGoggles",
        name = "Night Vision Goggles",
        basePrice = 600,
        category = "equipment",
        size = 1,
    },
    {
        itemType = "Base.Generator",
        name = "Portable Generator",
        basePrice = 1000,
        category = "equipment",
        size = 3, -- Needs delivery crate
    },
}

--- Get all available items for a player based on reputation
---@param reputation number Player reputation
---@return table Available items
function Amazoid.Items.getAvailableItems(reputation)
    local items = {}
    
    -- Always available after contract
    for _, item in ipairs(Amazoid.Items.BasicCatalog) do
        table.insert(items, item)
    end
    
    -- Tools
    if Amazoid.Utils.canAccessCatalog(reputation, Amazoid.CatalogCategories.TOOLS) then
        for _, item in ipairs(Amazoid.Items.ToolsCatalog) do
            table.insert(items, item)
        end
    end
    
    -- Weapons
    if Amazoid.Utils.canAccessCatalog(reputation, Amazoid.CatalogCategories.WEAPONS) then
        for _, item in ipairs(Amazoid.Items.WeaponsCatalog) do
            table.insert(items, item)
        end
    end
    
    -- Medical
    if Amazoid.Utils.canAccessCatalog(reputation, Amazoid.CatalogCategories.MEDICAL) then
        for _, item in ipairs(Amazoid.Items.MedicalCatalog) do
            table.insert(items, item)
        end
    end
    
    -- Seasonal
    if Amazoid.Utils.canAccessCatalog(reputation, Amazoid.CatalogCategories.SEASONAL) then
        local season = Amazoid.Utils.getCurrentSeason()
        local seasonalItems = Amazoid.Items.SeasonalCatalogs[season]
        if seasonalItems then
            for _, item in ipairs(seasonalItems) do
                table.insert(items, item)
            end
        end
    end
    
    -- Black Market
    if Amazoid.Utils.canAccessCatalog(reputation, Amazoid.CatalogCategories.BLACKMARKET) then
        for _, item in ipairs(Amazoid.Items.BlackMarketCatalog) do
            table.insert(items, item)
        end
    end
    
    return items
end

--- Calculate price with discount
---@param basePrice number Base price
---@param reputation number Player reputation
---@return number Final price
function Amazoid.Items.calculateFinalPrice(basePrice, reputation)
    local discount = Amazoid.Utils.calculateDiscount(reputation)
    return math.floor(basePrice * (1 - discount))
end

print("[Amazoid] Items database loaded")
