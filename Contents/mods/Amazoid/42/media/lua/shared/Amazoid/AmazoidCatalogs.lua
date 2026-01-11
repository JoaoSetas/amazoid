--[[
    Amazoid - Mysterious Mailbox Merchant
    Catalog Editions System

    Each catalog is a "magazine edition" with:
    - Edition number (issue #)
    - Multiple pages with category sections
    - Different item selections per edition
    - Seasonal availability
    - Daily rotation system
]]

-- Ensure Amazoid global exists
Amazoid = Amazoid or {}

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidItems"

Amazoid.Catalogs = Amazoid.Catalogs or {}

-- ============================================================
-- CATALOG EDITIONS DATABASE
-- Each edition is a unique "magazine issue" with curated items
-- ============================================================

Amazoid.Catalogs.Editions = {
    -- ===================
    -- BASIC SUPPLY CATALOGS (Always available)
    -- ===================
    basic_vol1 = {
        id = "basic_vol1",
        catalogType = "basic",
        title = "Amazoid Essentials",
        subtitle = "Vol. I - Common Basics",
        issue = 1,
        season = nil,                                  -- Available year-round
        reputationRequired = 0,
        coverColor = { r = 0.85, g = 0.75, b = 0.55 }, -- Tan
        pages = {
            {
                title = "Snacks & Drinks",
                icon = "Pop",
                items = {
                    { itemType = "Base.Pop",    name = "Soda",   basePrice = 5 },
                    { itemType = "Base.Pop2",   name = "Cola",   basePrice = 5 },
                    { itemType = "Base.Crisps", name = "Crisps", basePrice = 6 },
                },
            },
            {
                title = "Lighting & Fire",
                icon = "Candle",
                items = {
                    { itemType = "Base.Matches", name = "Matches", basePrice = 8 },
                    { itemType = "Base.Candle",  name = "Candle",  basePrice = 10 },
                },
            },
            {
                title = "Kitchen & Storage",
                icon = "Bowl",
                items = {
                    { itemType = "Base.Bowl",       name = "Bowl",         basePrice = 8 },
                    { itemType = "Base.Garbagebag", name = "Garbage Bags", basePrice = 6 },
                },
            },
        },
    },

    basic_vol2 = {
        id = "basic_vol2",
        catalogType = "basic",
        title = "Amazoid Essentials",
        subtitle = "Vol. II - Survival Staples",
        issue = 2,
        season = nil,
        reputationRequired = 0,
        coverColor = { r = 0.75, g = 0.65, b = 0.50 },
        pages = {
            {
                title = "Canned Foods",
                icon = "TinnedBeans",
                items = {
                    { itemType = "Base.TinnedBeans",   name = "Canned Beans",   basePrice = 15 },
                    { itemType = "Base.CannedPeaches", name = "Canned Peaches", basePrice = 14 },
                    { itemType = "Base.CannedTomato",  name = "Canned Tomato",  basePrice = 10 },
                },
            },

            {
                title = "Lighting & Medical",
                icon = "Flashlight2",
                items = {
                    { itemType = "Base.Battery",            name = "Battery",     basePrice = 12 },
                    { itemType = "Base.PenLight",           name = "Pen Light",   basePrice = 15 },
                    { itemType = "Base.AdhesiveBandageBox", name = "Bandage Box", basePrice = 20 },
                },
            },
            {
                title = "Tools & Cooking",
                icon = "TinOpener",
                items = {
                    { itemType = "Base.TinOpener",   name = "Can Opener",   basePrice = 12 },
                    { itemType = "Base.Pan",         name = "Frying Pan",   basePrice = 22 },
                    { itemType = "Base.WaterBottle", name = "Water Bottle", basePrice = 10 },
                },
            },
        },
    },

    basic_vol3 = {
        id = "basic_vol3",
        catalogType = "basic",
        title = "Amazoid Essentials",
        subtitle = "Vol. III - Quality Gear",
        issue = 3,
        season = nil,
        reputationRequired = 0,
        coverColor = { r = 0.80, g = 0.70, b = 0.60 },
        pages = {

            {
                title = "Ready Meals",
                icon = "TVDinner",
                items = {
                    { itemType = "Base.TVDinner",  name = "TV Dinner",  basePrice = 12 },
                    { itemType = "Base.BeefJerky", name = "Beef Jerky", basePrice = 18 },
                },
            },
            {
                title = "Tools",
                icon = "KitchenKnife",
                items = {
                    { itemType = "Base.KitchenKnife", name = "Kitchen Knife", basePrice = 18 },
                    { itemType = "Base.HuntingKnife", name = "Pocket Knife",  basePrice = 35 },
                    { itemType = "Base.HandTorch",    name = "Flashlight",    basePrice = 25 },
                },
            },
            {
                title = "Bags",
                icon = "Bag_Schoolbag",
                items = {
                    { itemType = "Base.Bag_FannyPackFront", name = "Fanny Pack", basePrice = 25 },
                    { itemType = "Base.Bag_Schoolbag",      name = "School Bag", basePrice = 45 },
                },
            },
        },
    },

    -- ===================
    -- TOOLS CATALOGS (Reputation 10+)
    -- ===================
    tools_vol1 = {
        id = "tools_vol1",
        catalogType = "tools",
        title = "Builder's Workshop",
        subtitle = "Vol. I - Essential Tools",
        issue = 1,
        season = nil,
        reputationRequired = 20,
        coverColor = { r = 0.55, g = 0.45, b = 0.35 }, -- Brown
        pages = {
            {
                title = "Hand Tools",
                icon = "Hammer",
                items = {
                    { itemType = "Base.Hammer",      name = "Hammer",      basePrice = 45 },
                    { itemType = "Base.Screwdriver", name = "Screwdriver", basePrice = 25 },
                    { itemType = "Base.Wrench",      name = "Wrench",      basePrice = 40 },
                    { itemType = "Base.HandAxe",     name = "Hand Axe",    basePrice = 55 },
                },
            },
            {
                title = "Cutting Tools",
                icon = "Saw",
                items = {
                    { itemType = "Base.Saw",       name = "Hand Saw",   basePrice = 55 },
                    { itemType = "Base.GardenSaw", name = "Garden Saw", basePrice = 45 },
                    { itemType = "Base.WoodAxe",   name = "Wood Axe",   basePrice = 75 },
                },
            },
            {
                title = "Building Materials",
                icon = "Nails",
                items = {
                    { itemType = "Base.Nails",  name = "Box of Nails",  basePrice = 20 },
                    { itemType = "Base.Screws", name = "Box of Screws", basePrice = 22 },
                    { itemType = "Base.Plank",  name = "Wooden Plank",  basePrice = 15 },
                },
            },
        },
    },

    tools_vol2 = {
        id = "tools_vol2",
        catalogType = "tools",
        title = "Builder's Workshop",
        subtitle = "Vol. II - Advanced Equipment",
        issue = 2,
        season = nil,
        reputationRequired = 20,
        coverColor = { r = 0.50, g = 0.40, b = 0.30 },
        pages = {
            {
                title = "Mechanical",
                icon = "Wrench",
                items = {
                    { itemType = "Base.LugWrench", name = "Lug Wrench", basePrice = 35 },
                    { itemType = "Base.Jack",      name = "Car Jack",   basePrice = 30 },
                    { itemType = "Base.TirePump",  name = "Tire Pump",  basePrice = 40 },
                },
            },
            {
                title = "Electrical",
                icon = "ElectronicsScrap",
                items = {
                    { itemType = "Base.Wire",     name = "Electrical Wire", basePrice = 18 },
                    { itemType = "Base.DuctTape", name = "Duct Tape",       basePrice = 25 },
                    { itemType = "Base.Glue",     name = "Wood Glue",       basePrice = 15 },
                },
            },
            {
                title = "Gardening",
                icon = "GardeningFork",
                items = {
                    { itemType = "Base.HandFork",   name = "Garden Fork",  basePrice = 30 },
                    { itemType = "Base.WateredCan", name = "Watering Can", basePrice = 28 },
                    { itemType = "Base.Shovel",     name = "Shovel",       basePrice = 35 },
                },
            },
        },
    },

    -- ===================
    -- WEAPONS CATALOGS (Reputation 25+)
    -- ===================
    weapons_vol1 = {
        id = "weapons_vol1",
        catalogType = "weapons",
        title = "Survivor's Arsenal",
        subtitle = "Vol. I - Melee Combat",
        issue = 1,
        season = nil,
        reputationRequired = 40,
        coverColor = { r = 0.45, g = 0.35, b = 0.35 }, -- Dark red-brown
        pages = {
            {
                title = "Blunt Weapons",
                icon = "BaseballBat",
                items = {
                    { itemType = "Base.BaseballBat", name = "Baseball Bat", basePrice = 65 },
                    { itemType = "Base.Crowbar",     name = "Crowbar",      basePrice = 75 },
                    { itemType = "Base.LeadPipe",    name = "Lead Pipe",    basePrice = 45 },
                },
            },
            {
                title = "Bladed Weapons",
                icon = "HuntingKnife",
                items = {
                    { itemType = "Base.HuntingKnife", name = "Hunting Knife", basePrice = 85 },
                    { itemType = "Base.Machete",      name = "Machete",       basePrice = 95 },
                    { itemType = "Base.Axe",          name = "Fire Axe",      basePrice = 120 },
                },
            },
            {
                title = "Improvised",
                icon = "Plank",
                items = {
                    { itemType = "Base.Plank",    name = "Plank (Weapon)", basePrice = 15 },
                    { itemType = "Base.Pan",      name = "Frying Pan",     basePrice = 22 },
                    { itemType = "Base.Golfclub", name = "Golf Club",      basePrice = 50 },
                },
            },
        },
    },

    weapons_vol2 = {
        id = "weapons_vol2",
        catalogType = "weapons",
        title = "Survivor's Arsenal",
        subtitle = "Vol. II - Ranged & Ammo",
        issue = 2,
        season = nil,
        reputationRequired = 40,
        coverColor = { r = 0.40, g = 0.30, b = 0.30 },
        pages = {
            {
                title = "Silencers & Grips",
                icon = "Pistol",
                items = {
                    { itemType = "Base.GunLight", name = "Gun Light",     basePrice = 65 },
                    { itemType = "Base.Laser",    name = "Laser Sight",   basePrice = 120 },
                    { itemType = "Base.RedDot",   name = "Red Dot Sight", basePrice = 100 },
                },
            },
            {
                title = "Ammunition",
                icon = "Bullets9mm",
                items = {
                    { itemType = "Base.Bullets9mm",    name = "9mm Rounds (24)",    basePrice = 100 },
                    { itemType = "Base.ShotgunShells", name = "Shotgun Shells (6)", basePrice = 120 },
                    { itemType = "Base.223Bullets",    name = ".223 Rounds (30)",   basePrice = 150 },
                },
            },
            {
                title = "Protection",
                icon = "Hat_Army",
                items = {
                    { itemType = "Base.Hat_Army",                  name = "Army Helmet",   basePrice = 80 },
                    { itemType = "Base.Gloves_LeatherGlovesBlack", name = "Combat Gloves", basePrice = 55 },
                },
            },
        },
    },

    -- ===================
    -- MEDICAL CATALOGS (Reputation 25+)
    -- ===================
    medical_vol1 = {
        id = "medical_vol1",
        catalogType = "medical",
        title = "First Responder",
        subtitle = "Vol. I - Emergency Care",
        issue = 1,
        season = nil,
        reputationRequired = 30,
        coverColor = { r = 0.85, g = 0.85, b = 0.90 }, -- Medical white-blue
        pages = {
            {
                title = "Bandages",
                icon = "Bandage",
                items = {
                    { itemType = "Base.Bandage",        name = "Bandage",            basePrice = 25 },
                    { itemType = "Base.RippedSheets",   name = "Ripped Sheets",      basePrice = 10 },
                    { itemType = "Base.AlcoholBandage", name = "Sterilized Bandage", basePrice = 45 },
                },
            },
            {
                title = "Disinfectants",
                icon = "AlcoholWipes",
                items = {
                    { itemType = "Base.AlcoholWipes", name = "Alcohol Wipes", basePrice = 30 },
                    { itemType = "Base.Disinfectant", name = "Disinfectant",  basePrice = 50 },
                    { itemType = "Base.CottonBalls",  name = "Cotton Balls",  basePrice = 15 },
                },
            },
            {
                title = "Basic Medicine",
                icon = "Pills",
                items = {
                    { itemType = "Base.Pills",                name = "Painkillers",    basePrice = 35 },
                    { itemType = "Base.PillsVitamins",        name = "Vitamins",       basePrice = 25 },
                    { itemType = "Base.PillsSleepingTablets", name = "Sleeping Pills", basePrice = 40 },
                },
            },
        },
    },

    medical_vol2 = {
        id = "medical_vol2",
        catalogType = "medical",
        title = "First Responder",
        subtitle = "Vol. II - Advanced Medicine",
        issue = 2,
        season = nil,
        reputationRequired = 30,
        coverColor = { r = 0.80, g = 0.80, b = 0.88 },
        pages = {
            {
                title = "Surgery",
                icon = "SutureNeedle",
                items = {
                    { itemType = "Base.SutureNeedle", name = "Suture Needle",    basePrice = 60 },
                    { itemType = "Base.Tweezers",     name = "Tweezers",         basePrice = 35 },
                    { itemType = "Base.Scissors",     name = "Medical Scissors", basePrice = 30 },
                },
            },
            {
                title = "Antibiotics",
                icon = "Antibiotics",
                items = {
                    { itemType = "Base.Antibiotics",  name = "Antibiotics",     basePrice = 80 },
                    { itemType = "Base.PillsAntiDep", name = "Antidepressants", basePrice = 55 },
                    { itemType = "Base.PillsBeta",    name = "Beta Blockers",   basePrice = 50 },
                },
            },
            {
                title = "First Aid Kits",
                icon = "FirstAidKit",
                items = {
                    { itemType = "Base.FirstAidKit", name = "First Aid Kit", basePrice = 150 },
                    { itemType = "Base.Splint",      name = "Splint",        basePrice = 40 },
                },
            },
        },
    },

    -- ===================
    -- SEASONAL CATALOGS (Reputation 35+)
    -- ===================
    seasonal_spring = {
        id = "seasonal_spring",
        catalogType = "seasonal",
        title = "Spring Collection",
        subtitle = "Renewal Edition",
        issue = 1,
        season = "spring",                             -- Only appears in spring
        reputationRequired = 5,
        coverColor = { r = 0.70, g = 0.85, b = 0.65 }, -- Spring green
        pages = {
            {
                title = "Gardening",
                icon = "GardeningFork",
                items = {
                    { itemType = "Base.HandFork",            name = "Garden Fork",  basePrice = 30 },
                    { itemType = "Base.WateredCan",          name = "Watering Can", basePrice = 28 },
                    { itemType = "Base.GardeningSprayEmpty", name = "Spray Bottle", basePrice = 18 },
                    { itemType = "Base.Shovel",              name = "Shovel",       basePrice = 35 },
                },
            },
            {
                title = "Seeds",
                icon = "BroccoliSeed",
                items = {
                    { itemType = "Base.TomatoSeed",  name = "Tomato Seeds",  basePrice = 12 },
                    { itemType = "Base.CabbageSeed", name = "Cabbage Seeds", basePrice = 10 },
                    { itemType = "Base.CarrotSeed",  name = "Carrot Seeds",  basePrice = 10 },
                    { itemType = "Base.PotatoSeed",  name = "Potato Seeds",  basePrice = 12 },
                },
            },
            {
                title = "Rain Gear",
                icon = "Hat_FishermanRainHat",
                items = {
                    { itemType = "Base.Hat_FishermanRainHat", name = "Rain Hat",    basePrice = 25 },
                    { itemType = "Base.Jacket_Fireman",       name = "Rain Jacket", basePrice = 55 },
                },
            },
        },
    },

    seasonal_summer = {
        id = "seasonal_summer",
        catalogType = "seasonal",
        title = "Summer Collection",
        subtitle = "Heatwave Edition",
        issue = 2,
        season = "summer",
        reputationRequired = 5,
        coverColor = { r = 0.95, g = 0.85, b = 0.50 }, -- Summer yellow
        pages = {
            {
                title = "Sun Protection",
                icon = "Glasses_Sun",
                items = {
                    { itemType = "Base.Glasses_Sun",     name = "Sunglasses",   basePrice = 25 },
                    { itemType = "Base.Hat_BaseballCap", name = "Baseball Cap", basePrice = 20 },
                    { itemType = "Base.Hat_SummerHat",   name = "Sun Hat",      basePrice = 22 },
                },
            },
            {
                title = "Cooling & Hydration",
                icon = "WaterBottle",
                items = {
                    { itemType = "Base.WaterBottle",      name = "Water Bottle", basePrice = 15 },
                    { itemType = "Base.Pop",              name = "Cold Soda",    basePrice = 5 },
                    { itemType = "Base.WatermelonSliced", name = "Watermelon",   basePrice = 18 },
                },
            },
            {
                title = "Outdoor Gear",
                icon = "CampingTentKit2",
                items = {
                    { itemType = "Base.CampingTentKit2",      name = "Camping Tent", basePrice = 180 },
                    { itemType = "Base.SleepingBag_RedPlaid", name = "Sleeping Bag", basePrice = 75 },
                    { itemType = "Base.Firewood",             name = "Firewood",     basePrice = 25 },
                },
            },
        },
    },

    seasonal_autumn = {
        id = "seasonal_autumn",
        catalogType = "seasonal",
        title = "Autumn Collection",
        subtitle = "Harvest Edition",
        issue = 3,
        season = "autumn",
        reputationRequired = 5,
        coverColor = { r = 0.85, g = 0.55, b = 0.35 }, -- Autumn orange
        pages = {
            {
                title = "Warm Clothing",
                icon = "Jacket_Padded",
                items = {
                    { itemType = "Base.Jacket_Padded",       name = "Padded Jacket", basePrice = 75 },
                    { itemType = "Base.Vest_DefaultTEXTURE", name = "Warm Vest",     basePrice = 45 },
                    { itemType = "Base.Socks_Long",          name = "Wool Socks",    basePrice = 15 },
                },
            },
            {
                title = "Harvest Tools",
                icon = "HandScythe",
                items = {
                    { itemType = "Base.HandScythe",          name = "Hand Scythe",  basePrice = 55 },
                    { itemType = "Base.Bag_HideSack",        name = "Burlap Sack",  basePrice = 22 },
                    { itemType = "Base.GardeningSprayEmpty", name = "Garden Spray", basePrice = 15 },
                },
            },
            {
                title = "Preserving",
                icon = "JarLid",
                items = {
                    { itemType = "Base.JarLid",   name = "Jar Lids (10)",     basePrice = 18 },
                    { itemType = "Base.EmptyJar", name = "Empty Jars (5)",    basePrice = 22 },
                    { itemType = "Base.Salt",     name = "Salt (Preserving)", basePrice = 10 },
                },
            },
        },
    },

    seasonal_winter = {
        id = "seasonal_winter",
        catalogType = "seasonal",
        title = "Winter Collection",
        subtitle = "Survival Edition",
        issue = 4,
        season = "winter",
        reputationRequired = 5,
        coverColor = { r = 0.75, g = 0.85, b = 0.95 }, -- Winter blue
        pages = {
            {
                title = "Cold Weather Gear",
                icon = "Hat_WinterHat",
                items = {
                    { itemType = "Base.Hat_WinterHat",        name = "Winter Hat",     basePrice = 35 },
                    { itemType = "Base.Gloves_LeatherGloves", name = "Leather Gloves", basePrice = 45 },
                    { itemType = "Base.Scarf_White",          name = "Scarf",          basePrice = 30 },
                    { itemType = "Base.Jacket_PaddedDOWN",    name = "Down Jacket",    basePrice = 120 },
                },
            },
            {
                title = "Heating",
                icon = "Matches",
                items = {
                    { itemType = "Base.Matches",  name = "Matches (Bulk)",  basePrice = 15 },
                    { itemType = "Base.Firewood", name = "Firewood Bundle", basePrice = 25 },
                    { itemType = "Base.Charcoal", name = "Charcoal Bag",    basePrice = 30 },
                },
            },
            {
                title = "Hot Drinks",
                icon = "Teabag2",
                items = {
                    { itemType = "Base.Teabag2",     name = "Tea Bags (20)", basePrice = 18 },
                    { itemType = "Base.Coffee2",     name = "Ground Coffee", basePrice = 25 },
                    { itemType = "Base.CocoaPowder", name = "Cocoa Powder",  basePrice = 20 },
                },
            },
        },
    },

    -- ===================
    -- BLACK MARKET CATALOGS (Reputation 50+)
    -- ===================
    blackmarket_vol1 = {
        id = "blackmarket_vol1",
        catalogType = "blackmarket",
        title = "The Underground",
        subtitle = "Classified - Vol. I",
        issue = 1,
        season = nil,
        reputationRequired = 50,
        coverColor = { r = 0.15, g = 0.12, b = 0.12 }, -- Almost black
        pages = {
            {
                title = "Firearms",
                icon = "Pistol",
                items = {
                    { itemType = "Base.Pistol",   name = "9mm Pistol",   basePrice = 350 },
                    { itemType = "Base.Revolver", name = "Revolver",     basePrice = 300 },
                    { itemType = "Base.Shotgun",  name = "Pump Shotgun", basePrice = 500 },
                },
            },
            {
                title = "Exotic Weapons",
                icon = "Katana",
                items = {
                    { itemType = "Base.Katana",       name = "Katana",           basePrice = 400 },
                    { itemType = "Base.Machete",      name = "Military Machete", basePrice = 150 },
                    { itemType = "Base.SpearCrafted", name = "Combat Spear",     basePrice = 180 },
                },
            },
            {
                title = "Bulk Ammo",
                icon = "Bullets9mm",
                items = {
                    { itemType = "Base.Bullets9mm",    name = "9mm Case (100)",   basePrice = 350 },
                    { itemType = "Base.ShotgunShells", name = "Shells Case (50)", basePrice = 450 },
                    { itemType = "Base.308Bullets",    name = ".308 Case (50)",   basePrice = 400 },
                },
            },
        },
    },

    blackmarket_vol2 = {
        id = "blackmarket_vol2",
        catalogType = "blackmarket",
        title = "The Underground",
        subtitle = "Classified - Vol. II",
        issue = 2,
        season = nil,
        reputationRequired = 50,
        coverColor = { r = 0.12, g = 0.10, b = 0.15 },
        pages = {
            {
                title = "Heavy Weapons",
                icon = "AssaultRifle",
                items = {
                    { itemType = "Base.AssaultRifle", name = "Assault Rifle", basePrice = 750 },
                    { itemType = "Base.HuntingRifle", name = "Hunting Rifle", basePrice = 550 },
                    { itemType = "Base.VarmintRifle", name = "Varmint Rifle", basePrice = 400 },
                },
            },
            {
                title = "Military Gear",
                icon = "x4Scope",
                items = {
                    { itemType = "Base.x4Scope",       name = "4x Rifle Scope",  basePrice = 250 },
                    { itemType = "Base.Hat_Army",      name = "Military Helmet", basePrice = 120 },
                    { itemType = "Base.Bag_ALICEpack", name = "ALICE Pack",      basePrice = 200 },
                },
            },
            {
                title = "Power Equipment",
                icon = "Generator",
                items = {
                    { itemType = "Base.Generator",   name = "Generator",      basePrice = 1000 },
                    { itemType = "Base.PropaneTank", name = "Propane Tank",   basePrice = 150 },
                    { itemType = "Base.PetrolCan",   name = "Gas Can (Full)", basePrice = 80 },
                },
            },
        },
    },
    -- ===================
    -- ADDITIONAL TOOLS CATALOGS
    -- ===================
    tools_vol3 = {
        id = "tools_vol3",
        catalogType = "tools",
        title = "Builder's Workshop",
        subtitle = "Vol. III - Automotive",
        issue = 3,
        season = nil,
        reputationRequired = 20,
        coverColor = { r = 0.45, g = 0.45, b = 0.50 },
        pages = {
            {
                title = "Car Parts",
                icon = "TirePump",
                items = {
                    { itemType = "Base.TirePump",    name = "Tire Pump",  basePrice = 40 },
                    { itemType = "Base.Jack",        name = "Car Jack",   basePrice = 55 },
                    { itemType = "Base.LugWrench",   name = "Lug Wrench", basePrice = 35 },
                    { itemType = "Base.NormalTire1", name = "Car Tire",   basePrice = 80 },
                },
            },
            {
                title = "Fluids & Maintenance",
                icon = "PetrolCan",
                items = {
                    { itemType = "Base.PetrolCan",         name = "Gas Can",         basePrice = 50 },
                    { itemType = "Base.EngineParts",       name = "Engine Parts",    basePrice = 80 },
                    { itemType = "Base.CarBatteryCharger", name = "Battery Charger", basePrice = 120 },
                },
            },
            {
                title = "Electrical",
                icon = "CarBattery1",
                items = {
                    { itemType = "Base.CarBattery1", name = "Car Battery",   basePrice = 120 },
                    { itemType = "Base.CarBattery2", name = "Heavy Battery", basePrice = 150 },
                },
            },
        },
    },

    tools_vol4 = {
        id = "tools_vol4",
        catalogType = "tools",
        title = "Builder's Workshop",
        subtitle = "Vol. IV - Crafting Supplies",
        issue = 4,
        season = nil,
        reputationRequired = 20,
        coverColor = { r = 0.55, g = 0.50, b = 0.40 },
        pages = {
            {
                title = "Adhesives",
                icon = "DuctTape",
                items = {
                    { itemType = "Base.DuctTape", name = "Duct Tape",   basePrice = 25 },
                    { itemType = "Base.Glue",     name = "Wood Glue",   basePrice = 15 },
                    { itemType = "Base.Woodglue", name = "Strong Glue", basePrice = 20 },
                    { itemType = "Base.Epoxy",    name = "Epoxy Resin", basePrice = 35 },
                },
            },
            {
                title = "Materials",
                icon = "Wire",
                items = {
                    { itemType = "Base.Wire",             name = "Electrical Wire", basePrice = 18 },
                    { itemType = "Base.ElectronicsScrap", name = "Electronics",     basePrice = 12 },
                    { itemType = "Base.SheetMetal",       name = "Sheet Metal",     basePrice = 30 },
                    { itemType = "Base.MetalPipe",        name = "Metal Pipe",      basePrice = 22 },
                },
            },
            {
                title = "Sewing",
                icon = "Thread",
                items = {
                    { itemType = "Base.Thread",      name = "Thread Spool",  basePrice = 8 },
                    { itemType = "Base.Needle",      name = "Sewing Needle", basePrice = 5 },
                    { itemType = "Base.SewingKit",   name = "Sewing Kit",    basePrice = 25 },
                    { itemType = "Base.DenimStrips", name = "Denim Strips",  basePrice = 10 },
                },
            },
        },
    },

    -- ===================
    -- ADDITIONAL WEAPONS CATALOGS
    -- ===================
    weapons_vol3 = {
        id = "weapons_vol3",
        catalogType = "weapons",
        title = "Survivor's Arsenal",
        subtitle = "Vol. III - Heavy Hitters",
        issue = 3,
        season = nil,
        reputationRequired = 40,
        coverColor = { r = 0.35, g = 0.30, b = 0.35 },
        pages = {
            {
                title = "Two-Handed",
                icon = "Sledgehammer",
                items = {
                    { itemType = "Base.Sledgehammer",  name = "Sledgehammer", basePrice = 150 },
                    { itemType = "Base.Sledgehammer2", name = "Heavy Sledge", basePrice = 180 },
                    { itemType = "Base.PickAxe",       name = "Pickaxe",      basePrice = 100 },
                },
            },
            {
                title = "Axes",
                icon = "WoodAxe",
                items = {
                    { itemType = "Base.WoodAxe", name = "Wood Axe", basePrice = 85 },
                    { itemType = "Base.Axe",     name = "Fire Axe", basePrice = 120 },
                    { itemType = "Base.HandAxe", name = "Hatchet",  basePrice = 55 },
                },
            },
            {
                title = "Polearms",
                icon = "Shovel",
                items = {
                    { itemType = "Base.Shovel",  name = "Shovel",   basePrice = 45 },
                    { itemType = "Base.Rake",    name = "Rake",     basePrice = 30 },
                    { itemType = "Base.Poolcue", name = "Pool Cue", basePrice = 25 },
                },
            },
        },
    },

    weapons_vol4 = {
        id = "weapons_vol4",
        catalogType = "weapons",
        title = "Survivor's Arsenal",
        subtitle = "Vol. IV - Gunsmith Special",
        issue = 4,
        season = nil,
        reputationRequired = 40,
        coverColor = { r = 0.30, g = 0.25, b = 0.25 },
        pages = {
            {
                title = "Handguns",
                icon = "Pistol",
                items = {
                    { itemType = "Base.Pistol",  name = "9mm Pistol",   basePrice = 350 },
                    { itemType = "Base.Pistol2", name = "M9 Pistol",    basePrice = 400 },
                    { itemType = "Base.Pistol3", name = "Desert Eagle", basePrice = 550 },
                },
            },
            {
                title = "Revolvers",
                icon = "Revolver",
                items = {
                    { itemType = "Base.Revolver",       name = "Revolver",    basePrice = 300 },
                    { itemType = "Base.Revolver_Long",  name = "Long Barrel", basePrice = 380 },
                    { itemType = "Base.Revolver_Short", name = "Snub Nose",   basePrice = 280 },
                },
            },
            {
                title = "Gun Parts",
                icon = "x2Scope",
                items = {
                    { itemType = "Base.x2Scope", name = "2x Scope", basePrice = 150 },
                    { itemType = "Base.x4Scope", name = "4x Scope", basePrice = 250 },
                    { itemType = "Base.x8Scope", name = "8x Scope", basePrice = 400 },
                },
            },
        },
    },

    -- ===================
    -- ADDITIONAL MEDICAL CATALOGS
    -- ===================
    medical_vol3 = {
        id = "medical_vol3",
        catalogType = "medical",
        title = "First Responder",
        subtitle = "Vol. III - Field Medic",
        issue = 3,
        season = nil,
        reputationRequired = 30,
        coverColor = { r = 0.90, g = 0.90, b = 0.95 },
        pages = {
            {
                title = "Wound Care",
                icon = "Bandage",
                items = {
                    { itemType = "Base.Bandage",              name = "Clean Bandage", basePrice = 25 },
                    { itemType = "Base.BandageDirty",         name = "Used Bandage",  basePrice = 5 },
                    { itemType = "Base.RippedSheetsDirty",    name = "Dirty Rags",    basePrice = 3 },
                    { itemType = "Base.AlcoholedCottonBalls", name = "Cotton Swabs",  basePrice = 20 },
                },
            },
            {
                title = "Tools",
                icon = "Tweezers",
                items = {
                    { itemType = "Base.Tweezers",     name = "Tweezers",         basePrice = 35 },
                    { itemType = "Base.Scissors",     name = "Medical Scissors", basePrice = 30 },
                    { itemType = "Base.SutureNeedle", name = "Suture Needle",    basePrice = 60 },
                },
            },
            {
                title = "Sanitizers",
                icon = "Disinfectant",
                items = {
                    { itemType = "Base.Disinfectant", name = "Disinfectant",  basePrice = 50 },
                    { itemType = "Base.AlcoholWipes", name = "Alcohol Wipes", basePrice = 30 },
                    { itemType = "Base.Bleach",       name = "Bleach",        basePrice = 15 },
                },
            },
        },
    },

    medical_vol4 = {
        id = "medical_vol4",
        catalogType = "medical",
        title = "First Responder",
        subtitle = "Vol. IV - Pharmacy",
        issue = 4,
        season = nil,
        reputationRequired = 30,
        coverColor = { r = 0.85, g = 0.88, b = 0.92 },
        pages = {
            {
                title = "Pain Relief",
                icon = "Pills",
                items = {
                    { itemType = "Base.Pills",        name = "Painkillers",     basePrice = 35 },
                    { itemType = "Base.PillsBeta",    name = "Beta Blockers",   basePrice = 50 },
                    { itemType = "Base.PillsAntiDep", name = "Antidepressants", basePrice = 55 },
                },
            },
            {
                title = "Supplements",
                icon = "PillsVitamins",
                items = {
                    { itemType = "Base.PillsVitamins",        name = "Vitamins",       basePrice = 25 },
                    { itemType = "Base.PillsSleepingTablets", name = "Sleeping Pills", basePrice = 40 },
                },
            },
            {
                title = "Specialty",
                icon = "Antibiotics",
                items = {
                    { itemType = "Base.Antibiotics", name = "Antibiotics",   basePrice = 80 },
                    { itemType = "Base.FirstAidKit", name = "First Aid Kit", basePrice = 150 },
                },
            },
        },
    },

    -- ===================
    -- OUTDOOR & SURVIVAL CATALOG (New Category)
    -- ===================
    outdoor_vol1 = {
        id = "outdoor_vol1",
        catalogType = "outdoor",
        title = "Wilderness Outfitter",
        subtitle = "Vol. I - Camp Essentials",
        issue = 1,
        season = nil,
        reputationRequired = 10,
        coverColor = { r = 0.40, g = 0.55, b = 0.35 },
        pages = {
            {
                title = "Camping",
                icon = "CampingTentKit2",
                items = {
                    { itemType = "Base.CampingTentKit2",      name = "Camping Tent",  basePrice = 180 },
                    { itemType = "Base.SleepingBag_RedPlaid", name = "Sleeping Bag",  basePrice = 75 },
                    { itemType = "Base.Pillow",               name = "Travel Pillow", basePrice = 25 },
                },
            },
            {
                title = "Fire Making",
                icon = "Matches",
                items = {
                    { itemType = "Base.Matches",  name = "Matches",  basePrice = 8 },
                    { itemType = "Base.Lighter",  name = "Lighter",  basePrice = 15 },
                    { itemType = "Base.Firewood", name = "Firewood", basePrice = 12 },
                    { itemType = "Base.Charcoal", name = "Charcoal", basePrice = 20 },
                },
            },
            {
                title = "Navigation",
                icon = "CompassDirectional",
                items = {
                    { itemType = "Base.CompassDirectional", name = "Compass",  basePrice = 35 },
                    { itemType = "Base.LouisvilleMap1",     name = "Area Map", basePrice = 15 },
                },
            },
        },
    },

    outdoor_vol2 = {
        id = "outdoor_vol2",
        catalogType = "outdoor",
        title = "Wilderness Outfitter",
        subtitle = "Vol. II - Fishing & Hunting",
        issue = 2,
        season = nil,
        reputationRequired = 10,
        coverColor = { r = 0.35, g = 0.50, b = 0.40 },
        pages = {
            {
                title = "Fishing Gear",
                icon = "FishingRod",
                items = {
                    { itemType = "Base.FishingRod",  name = "Fishing Rod",  basePrice = 65 },
                    { itemType = "Base.FishingLine", name = "Fishing Line", basePrice = 15 },
                    { itemType = "Base.Tacklebox",   name = "Tackle Box",   basePrice = 45 },
                    { itemType = "Base.FishingNet",  name = "Fishing Net",  basePrice = 40 },
                },
            },
            {
                title = "Trapping",
                icon = "TrapMouse",
                items = {
                    { itemType = "Base.TrapMouse", name = "Mouse Trap", basePrice = 12 },
                    { itemType = "Base.TrapCage",  name = "Cage Trap",  basePrice = 45 },
                    { itemType = "Base.TrapSnare", name = "Snare Trap", basePrice = 30 },
                },
            },
            {
                title = "Hunting",
                icon = "HuntingKnife",
                items = {
                    { itemType = "Base.HuntingKnife", name = "Hunting Knife", basePrice = 85 },
                    { itemType = "Base.SpearCrafted", name = "Spear",         basePrice = 45 },
                    { itemType = "Base.Machete",      name = "Machete",       basePrice = 95 },
                },
            },
        },
    },

    -- ===================
    -- LITERATURE CATALOG (New Category)
    -- ===================
    literature_vol1 = {
        id = "literature_vol1",
        catalogType = "literature",
        title = "Survivor's Library",
        subtitle = "Vol. I - Skill Books",
        issue = 1,
        season = nil,
        reputationRequired = 25,
        coverColor = { r = 0.55, g = 0.45, b = 0.35 },
        pages = {
            {
                title = "Carpentry",
                icon = "BookCarpentry1",
                items = {
                    { itemType = "Base.BookCarpentry1", name = "Carpentry Vol 1", basePrice = 45 },
                    { itemType = "Base.BookCarpentry2", name = "Carpentry Vol 2", basePrice = 55 },
                    { itemType = "Base.BookCarpentry3", name = "Carpentry Vol 3", basePrice = 65 },
                },
            },
            {
                title = "First Aid",
                icon = "BookFirstAid1",
                items = {
                    { itemType = "Base.BookFirstAid1", name = "First Aid Vol 1", basePrice = 50 },
                    { itemType = "Base.BookFirstAid2", name = "First Aid Vol 2", basePrice = 60 },
                    { itemType = "Base.BookFirstAid3", name = "First Aid Vol 3", basePrice = 70 },
                },
            },
            {
                title = "Cooking",
                icon = "BookCooking1",
                items = {
                    { itemType = "Base.BookCooking1", name = "Cooking Vol 1", basePrice = 40 },
                    { itemType = "Base.BookCooking2", name = "Cooking Vol 2", basePrice = 50 },
                    { itemType = "Base.BookCooking3", name = "Cooking Vol 3", basePrice = 60 },
                },
            },
        },
    },

    literature_vol2 = {
        id = "literature_vol2",
        catalogType = "literature",
        title = "Survivor's Library",
        subtitle = "Vol. II - Advanced Studies",
        issue = 2,
        season = nil,
        reputationRequired = 25,
        coverColor = { r = 0.50, g = 0.42, b = 0.38 },
        pages = {
            {
                title = "Farming",
                icon = "BookFarming1",
                items = {
                    { itemType = "Base.BookFarming1", name = "Farming Vol 1", basePrice = 45 },
                    { itemType = "Base.BookFarming2", name = "Farming Vol 2", basePrice = 55 },
                    { itemType = "Base.BookFarming3", name = "Farming Vol 3", basePrice = 65 },
                },
            },
            {
                title = "Foraging",
                icon = "BookForaging1",
                items = {
                    { itemType = "Base.BookForaging1", name = "Foraging Vol 1", basePrice = 45 },
                    { itemType = "Base.BookForaging2", name = "Foraging Vol 2", basePrice = 55 },
                    { itemType = "Base.BookForaging3", name = "Foraging Vol 3", basePrice = 65 },
                },
            },
            {
                title = "Mechanics",
                icon = "BookMechanic1",
                items = {
                    { itemType = "Base.BookMechanic1", name = "Mechanics Vol 1", basePrice = 50 },
                    { itemType = "Base.BookMechanic2", name = "Mechanics Vol 2", basePrice = 60 },
                    { itemType = "Base.BookMechanic3", name = "Mechanics Vol 3", basePrice = 70 },
                },
            },
        },
    },

    literature_vol3 = {
        id = "literature_vol3",
        catalogType = "literature",
        title = "Survivor's Library",
        subtitle = "Vol. III - Expert Knowledge",
        issue = 3,
        season = nil,
        reputationRequired = 25,
        coverColor = { r = 0.45, g = 0.38, b = 0.35 },
        pages = {
            {
                title = "Electrical",
                icon = "BookElectrician1",
                items = {
                    { itemType = "Base.BookElectrician1", name = "Electrical Vol 1", basePrice = 55 },
                    { itemType = "Base.BookElectrician2", name = "Electrical Vol 2", basePrice = 65 },
                    { itemType = "Base.BookElectrician3", name = "Electrical Vol 3", basePrice = 75 },
                },
            },
            {
                title = "Metalworking",
                icon = "BookMetalWelding1",
                items = {
                    { itemType = "Base.BookMetalWelding1", name = "Metalworking Vol 1", basePrice = 55 },
                    { itemType = "Base.BookMetalWelding2", name = "Metalworking Vol 2", basePrice = 65 },
                    { itemType = "Base.BookMetalWelding3", name = "Metalworking Vol 3", basePrice = 75 },
                },
            },
            {
                title = "Tailoring",
                icon = "BookTailoring1",
                items = {
                    { itemType = "Base.BookTailoring1", name = "Tailoring Vol 1", basePrice = 45 },
                    { itemType = "Base.BookTailoring2", name = "Tailoring Vol 2", basePrice = 55 },
                    { itemType = "Base.BookTailoring3", name = "Tailoring Vol 3", basePrice = 65 },
                },
            },
        },
    },

    -- ===================
    -- CLOTHING CATALOG (New Category)
    -- ===================
    clothing_vol1 = {
        id = "clothing_vol1",
        catalogType = "clothing",
        title = "Survivor Fashion",
        subtitle = "Vol. I - Everyday Wear",
        issue = 1,
        season = nil,
        reputationRequired = 15,
        coverColor = { r = 0.70, g = 0.60, b = 0.55 },
        pages = {
            {
                title = "Tops",
                icon = "Tshirt_DefaultTEXTURE",
                items = {
                    { itemType = "Base.Tshirt_DefaultTEXTURE", name = "T-Shirt",     basePrice = 20 },
                    { itemType = "Base.Shirt_FormalWhite",     name = "Dress Shirt", basePrice = 35 },
                    { itemType = "Base.Vest_DefaultTEXTURE",   name = "Vest",        basePrice = 30 },
                },
            },
            {
                title = "Bottoms",
                icon = "Trousers_DefaultTEXTURE",
                items = {
                    { itemType = "Base.Trousers_DefaultTEXTURE", name = "Pants",      basePrice = 30 },
                    { itemType = "Base.Trousers_JeanBlue",       name = "Blue Jeans", basePrice = 35 },
                    { itemType = "Base.Shorts_LongDenim",        name = "Shorts",     basePrice = 25 },
                },
            },
            {
                title = "Footwear",
                icon = "Shoes_Black",
                items = {
                    { itemType = "Base.Shoes_Black",       name = "Dress Shoes", basePrice = 40 },
                    { itemType = "Base.Shoes_Brown",       name = "Work Boots",  basePrice = 50 },
                    { itemType = "Base.Shoes_TrainerTINT", name = "Sneakers",    basePrice = 45 },
                },
            },
        },
    },

    clothing_vol2 = {
        id = "clothing_vol2",
        catalogType = "clothing",
        title = "Survivor Fashion",
        subtitle = "Vol. II - Protection Gear",
        issue = 2,
        season = nil,
        reputationRequired = 15,
        coverColor = { r = 0.60, g = 0.55, b = 0.50 },
        pages = {
            {
                title = "Jackets",
                icon = "Jacket_Padded",
                items = {
                    { itemType = "Base.Jacket_Padded",     name = "Padded Jacket",  basePrice = 75 },
                    { itemType = "Base.Jacket_PaddedDOWN", name = "Down Jacket",    basePrice = 120 },
                    { itemType = "Base.Jacket_Black",      name = "Leather Jacket", basePrice = 90 },
                },
            },
            {
                title = "Work Gear",
                icon = "Apron_White",
                items = {
                    { itemType = "Base.Apron_White", name = "Apron",       basePrice = 25 },
                    { itemType = "Base.HazmatSuit",  name = "Hazmat Suit", basePrice = 200 },
                    { itemType = "Base.Boilersuit",  name = "Boilersuit",  basePrice = 55 },
                },
            },
            {
                title = "Gloves",
                icon = "Gloves_LeatherGloves",
                items = {
                    { itemType = "Base.Gloves_LeatherGloves",      name = "Leather Gloves",  basePrice = 45 },
                    { itemType = "Base.Gloves_LeatherGlovesBlack", name = "Black Gloves",    basePrice = 50 },
                    { itemType = "Base.Gloves_Surgical",           name = "Surgical Gloves", basePrice = 15 },
                },
            },
        },
    },

    -- ===================
    -- ELECTRONICS CATALOG (New Category)
    -- ===================
    electronics_vol1 = {
        id = "electronics_vol1",
        catalogType = "electronics",
        title = "Tech Depot",
        subtitle = "Vol. I - Gadgets & Power",
        issue = 1,
        season = nil,
        reputationRequired = 35,
        coverColor = { r = 0.25, g = 0.35, b = 0.45 },
        pages = {
            {
                title = "Lighting",
                icon = "Flashlight2",
                items = {
                    { itemType = "Base.Flashlight2",       name = "Flashlight",     basePrice = 25 },
                    { itemType = "Base.HandTorch",         name = "Headlamp",       basePrice = 40 },
                    { itemType = "Base.Lantern_Hurricane", name = "Hurricane Lamp", basePrice = 55 },
                },
            },
            {
                title = "Power",
                icon = "Battery",
                items = {
                    { itemType = "Base.Battery",     name = "Batteries",   basePrice = 12 },
                    { itemType = "Base.CarBattery1", name = "Car Battery", basePrice = 120 },
                    { itemType = "Base.Generator",   name = "Generator",   basePrice = 1000 },
                },
            },
            {
                title = "Communication",
                icon = "WalkieTalkie2",
                items = {
                    { itemType = "Base.WalkieTalkie2", name = "Walkie Talkie", basePrice = 85 },
                    { itemType = "Base.HamRadio1",     name = "HAM Radio",     basePrice = 250 },
                },
            },
        },
    },
}

-- ============================================================
-- CATALOG HELPER FUNCTIONS
-- ============================================================

--- Get edition by ID
---@param editionId string Edition ID
---@return table|nil Edition data
function Amazoid.Catalogs.getEdition(editionId)
    return Amazoid.Catalogs.Editions[editionId]
end

--- Calculate the total value of all items in a catalog edition
--- This is used to determine the spending threshold for unlocking the next volume
---@param editionId string Edition ID
---@return number Total value of all items (each counted once)
function Amazoid.Catalogs.getEditionTotalValue(editionId)
    local edition = Amazoid.Catalogs.Editions[editionId]
    if not edition then return 100 end -- Default fallback

    local total = 0
    if edition.pages then
        for _, page in ipairs(edition.pages) do
            if page.items then
                for _, item in ipairs(page.items) do
                    total = total + (item.basePrice or 0)
                end
            end
        end
    end

    return total
end

--- Get cumulative threshold for unlocking a specific volume
--- Volume 2 requires spending >= half of vol1 total
--- Volume 3 requires spending >= half of (vol1 + vol2) totals
---@param category string Catalog category (e.g., "basic")
---@param targetVolume number The volume to unlock (2, 3, etc.)
---@return number The cumulative spending threshold (half of previous volumes' total)
function Amazoid.Catalogs.getVolumeUnlockThreshold(category, targetVolume)
    local cumulative = 0

    for vol = 1, targetVolume - 1 do
        local editionId = category .. "_vol" .. vol
        local edition = Amazoid.Catalogs.Editions[editionId]
        if edition then
            cumulative = cumulative + Amazoid.Catalogs.getEditionTotalValue(editionId)
        else
            -- Fallback if edition doesn't exist
            cumulative = cumulative + (Amazoid.CatalogVolumeThreshold or 100)
        end
    end

    -- Return half the cumulative (makes progression faster)
    return math.floor(cumulative / 2)
end

--- Legacy support - determine edition from catalog type
---@param catalogType string Old catalog type (basic, tools, etc.)
---@return string Edition ID
function Amazoid.Catalogs.getEditionFromType(catalogType)
    local typeMap = {
        basic = "basic_vol1",
        tools = "tools_vol1",
        weapons = "weapons_vol1",
        medical = "medical_vol1",
        seasonal = nil, -- Determined by current season
        blackmarket = "blackmarket_vol1",
    }

    if catalogType == "seasonal" then
        local season = "summer"
        if Amazoid.Utils and Amazoid.Utils.getCurrentSeason then
            season = Amazoid.Utils.getCurrentSeason()
        end
        return "seasonal_" .. season
    end

    return typeMap[catalogType] or "basic_vol1"
end

-- Helper for counting tables (add to Utils if not present)
if not Amazoid.Utils then
    Amazoid.Utils = {}
end
if not Amazoid.Utils.tableCount then
    function Amazoid.Utils.tableCount(t)
        local count = 0
        for _ in pairs(t) do count = count + 1 end
        return count
    end
end

local editionCount = 0
if Amazoid.Catalogs and Amazoid.Catalogs.Editions then
    editionCount = Amazoid.Utils.tableCount(Amazoid.Catalogs.Editions)
end
print("[Amazoid] Catalog editions system loaded (" .. editionCount .. " editions)")
