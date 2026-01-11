--[[
    Amazoid - Mysterious Mailbox Merchant
    Sandbox Options

    This file defines sandbox/server options for the mod.
]]

-- Sandbox options are defined in shared lua and loaded at game start

if not SandboxVars then SandboxVars = {} end
if not SandboxVars.Amazoid then SandboxVars.Amazoid = {} end

-- Default values (will be overridden by sandbox options if set)
local defaults = {
    -- First contact
    FirstContactDays = 3, -- Days within which first contact will happen

    -- Economy
    PriceMultiplier = 1.0,        -- Multiplier for all prices
    DeliveryTimeMultiplier = 1.0, -- Multiplier for delivery times
    MerchantVisitInterval = 1,    -- Hours between merchant visits to check mailboxes

    -- Reputation
    ReputationGainMultiplier = 1.0, -- Multiplier for reputation gains
    ReputationLossMultiplier = 1.0, -- Multiplier for reputation losses
}

-- Hardcoded values (not configurable)
local hardcoded = {
    StartingReputation = 0,
    MissionsEnabled = true,
    CollectionMissionsEnabled = true,
    EliminationMissionsEnabled = true,
    ScavengerMissionsEnabled = true,
    TimedDeliveryMissionsEnabled = true,
    ProtectionMissionsEnabled = true,
    MissionRewardMultiplier = 1.0,
    GiftsEnabled = true,
    GiftCooldownHours = 24,
    ProtectionDurationMinutes = 30,
    ProtectionDeviceHealth = 100,
    BasicCatalogEnabled = true,
    ToolsCatalogEnabled = true,
    WeaponsCatalogEnabled = true,
    MedicalCatalogEnabled = true,
    SeasonalCatalogEnabled = true,
    BlackMarketCatalogEnabled = true,
    ToolsCatalogReputation = 10,
    WeaponsCatalogReputation = 25,
    MedicalCatalogReputation = 25,
    SeasonalCatalogReputation = 35,
    BlackMarketCatalogReputation = 50,
}

-- Apply defaults if not already set
for key, value in pairs(defaults) do
    if SandboxVars.Amazoid[key] == nil then
        SandboxVars.Amazoid[key] = value
    end
end

--- Get a sandbox option value (checks sandbox options first, then hardcoded values)
---@param key string Option key
---@return any Option value
function Amazoid.getSandboxOption(key)
    -- Check hardcoded values first (these are not configurable)
    if hardcoded[key] ~= nil then
        return hardcoded[key]
    end
    -- Check sandbox options
    if SandboxVars and SandboxVars.Amazoid and SandboxVars.Amazoid[key] ~= nil then
        return SandboxVars.Amazoid[key]
    end
    return defaults[key]
end

--- Apply price multiplier
---@param basePrice number Base price
---@return number Adjusted price
function Amazoid.applyPriceMultiplier(basePrice)
    local multiplier = Amazoid.getSandboxOption("PriceMultiplier")
    return math.floor(basePrice * multiplier)
end

--- Apply delivery time multiplier
---@param baseTime number Base time in hours
---@return number Adjusted time
function Amazoid.applyDeliveryTimeMultiplier(baseTime)
    local multiplier = Amazoid.getSandboxOption("DeliveryTimeMultiplier")
    return math.floor(baseTime * multiplier)
end

--- Apply reputation gain multiplier
---@param baseGain number Base gain
---@return number Adjusted gain
function Amazoid.applyReputationGainMultiplier(baseGain)
    local multiplier = Amazoid.getSandboxOption("ReputationGainMultiplier")
    return math.floor(baseGain * multiplier)
end

--- Apply reputation loss multiplier
---@param baseLoss number Base loss (positive number)
---@return number Adjusted loss
function Amazoid.applyReputationLossMultiplier(baseLoss)
    local multiplier = Amazoid.getSandboxOption("ReputationLossMultiplier")
    return math.floor(baseLoss * multiplier)
end

--- Check if a mission type is enabled
---@param missionType string Mission type
---@return boolean Enabled
function Amazoid.isMissionTypeEnabled(missionType)
    if not Amazoid.getSandboxOption("MissionsEnabled") then
        return false
    end

    if missionType == Amazoid.MissionTypes.COLLECTION then
        return Amazoid.getSandboxOption("CollectionMissionsEnabled")
    elseif missionType == Amazoid.MissionTypes.ELIMINATION then
        return Amazoid.getSandboxOption("EliminationMissionsEnabled")
    elseif missionType == Amazoid.MissionTypes.SCAVENGER then
        return Amazoid.getSandboxOption("ScavengerMissionsEnabled")
    elseif missionType == Amazoid.MissionTypes.TIMED_DELIVERY then
        return Amazoid.getSandboxOption("TimedDeliveryMissionsEnabled")
    elseif missionType == Amazoid.MissionTypes.PROTECTION then
        return Amazoid.getSandboxOption("ProtectionMissionsEnabled")
    end

    return true
end

--- Check if a catalog is enabled
---@param catalogType string Catalog type
---@return boolean Enabled
function Amazoid.isCatalogEnabled(catalogType)
    if catalogType == Amazoid.CatalogCategories.BASIC then
        return Amazoid.getSandboxOption("BasicCatalogEnabled")
    elseif catalogType == Amazoid.CatalogCategories.TOOLS then
        return Amazoid.getSandboxOption("ToolsCatalogEnabled")
    elseif catalogType == Amazoid.CatalogCategories.WEAPONS then
        return Amazoid.getSandboxOption("WeaponsCatalogEnabled")
    elseif catalogType == Amazoid.CatalogCategories.MEDICAL then
        return Amazoid.getSandboxOption("MedicalCatalogEnabled")
    elseif catalogType == Amazoid.CatalogCategories.SEASONAL then
        return Amazoid.getSandboxOption("SeasonalCatalogEnabled")
    elseif catalogType == Amazoid.CatalogCategories.BLACKMARKET then
        return Amazoid.getSandboxOption("BlackMarketCatalogEnabled")
    end

    return true
end

--- Get reputation threshold for catalog (allows customization)
---@param catalogType string Catalog type
---@return number Required reputation
function Amazoid.getCatalogReputationThreshold(catalogType)
    if catalogType == Amazoid.CatalogCategories.BASIC then
        return 0
    elseif catalogType == Amazoid.CatalogCategories.TOOLS then
        return Amazoid.getSandboxOption("ToolsCatalogReputation")
    elseif catalogType == Amazoid.CatalogCategories.WEAPONS then
        return Amazoid.getSandboxOption("WeaponsCatalogReputation")
    elseif catalogType == Amazoid.CatalogCategories.MEDICAL then
        return Amazoid.getSandboxOption("MedicalCatalogReputation")
    elseif catalogType == Amazoid.CatalogCategories.SEASONAL then
        return Amazoid.getSandboxOption("SeasonalCatalogReputation")
    elseif catalogType == Amazoid.CatalogCategories.BLACKMARKET then
        return Amazoid.getSandboxOption("BlackMarketCatalogReputation")
    end

    return 0
end

print("[Amazoid] Sandbox options loaded")
