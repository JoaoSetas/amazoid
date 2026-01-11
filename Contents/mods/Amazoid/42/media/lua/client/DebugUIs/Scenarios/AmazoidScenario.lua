--[[
    Amazoid Test Scenario

    Quick test scenario for the Amazoid mod.
    Spawns player near a mailbox with all Amazoid items.

    In debug mode: Main Menu > Scenarios > Amazoid Test
]]

if debugScenarios == nil then
    debugScenarios = {}
end

--- Helper to create a catalog with a specific edition
---@param inv ItemContainer Player inventory
---@param edition string Edition key (e.g. "basic_vol1", "tools_vol1")
local function addCatalogWithEdition(inv, edition)
    local catalog = instanceItem("Amazoid.Catalog")
    if catalog then
        catalog:getModData().AmazoidEdition = edition
        inv:addItem(catalog)
    end
end

debugScenarios.AmazoidScenario = {
    name = "Amazoid Test",

    -- Muldraugh residential area (has mailboxes)
    startLoc = { x = 10587, y = 10265, z = 0 },

    setSandbox = function()
        -- Safe testing environment
        SandboxVars.Zombies = 1            -- No zombies
        SandboxVars.VehicleEasyUse = true  -- Easy cars
        SandboxVars.Alarm = 1              -- No alarms
        SandboxVars.LootItemRemovalList = ""
        SandboxVars.WaterShutModifier = -1 -- Water never shuts off
        SandboxVars.ElecShutModifier = -1  -- Power never shuts off
        SandboxVars.TimeSinceApo = 1       -- Day 1
        SandboxVars.StartTime = 2          -- 9am start
    end,

    onStart = function()
        local player = getPlayer()
        if not player then return end

        local inv = player:getInventory()

        print("[Amazoid Scenario] Setting up test environment...")

        -- Give Amazoid items
        inv:AddItem("Amazoid.DiscoveryLetter")
        addCatalogWithEdition(inv, "basic_vol1")
        addCatalogWithEdition(inv, "tools_vol1")
        addCatalogWithEdition(inv, "medical_vol1")

        -- Give some money
        for i = 1, 10 do
            inv:AddItem("Base.Money")
        end

        -- Give useful tools
        inv:AddItem("Base.Hammer")
        inv:AddItem("Base.Screwdriver")
        inv:AddItem("Base.Crowbar")
        inv:AddItem("Base.Flashlight")

        -- Give food and water
        inv:AddItem("Base.WaterBottleFull")
        inv:AddItem("Base.CannedBeans")
        inv:AddItem("Base.CannedBeans")

        -- Set up player Amazoid data
        local data = player:getModData().Amazoid or {}
        data.reputation = 25 -- Start with some reputation
        player:getModData().Amazoid = data

        print("[Amazoid Scenario] Test environment ready!")
        print("[Amazoid Scenario] Find a mailbox nearby to test the mod")
        print("[Amazoid Scenario] Use right-click on Discovery Letter to read it")
    end
}

-- Also add a "signed contract" variant for faster testing
debugScenarios.AmazoidContractScenario = {
    name = "Amazoid Test (Contract Signed)",

    -- Same location
    startLoc = { x = 10587, y = 10265, z = 0 },

    setSandbox = function()
        SandboxVars.Zombies = 1
        SandboxVars.VehicleEasyUse = true
        SandboxVars.Alarm = 1
        SandboxVars.LootItemRemovalList = ""
        SandboxVars.WaterShutModifier = -1
        SandboxVars.ElecShutModifier = -1
        SandboxVars.TimeSinceApo = 1
        SandboxVars.StartTime = 2
    end,

    onStart = function()
        local player = getPlayer()
        if not player then return end

        local inv = player:getInventory()

        print("[Amazoid Scenario] Setting up FULL test environment...")

        -- Give signed contract (skip discovery phase)
        inv:AddItem("Amazoid.SignedContract")

        -- Give ALL catalog editions (Vol. I of each type)
        addCatalogWithEdition(inv, "basic_vol1")
        addCatalogWithEdition(inv, "tools_vol1")
        addCatalogWithEdition(inv, "weapons_vol1")
        addCatalogWithEdition(inv, "medical_vol1")
        addCatalogWithEdition(inv, "seasonal_vol1")
        addCatalogWithEdition(inv, "blackmarket_vol1")

        -- Give money
        for i = 1, 20 do
            inv:AddItem("Base.Money")
        end

        -- Give tools
        inv:AddItem("Base.Hammer")
        inv:AddItem("Base.Screwdriver")
        inv:AddItem("Base.Crowbar")
        inv:AddItem("Base.Flashlight")
        inv:AddItem("Base.WaterBottleFull")

        -- Set player as having signed contract with reputation
        local data = player:getModData().Amazoid or {}
        data.hasContract = true
        data.reputation = 50
        data.totalOrders = 5
        player:getModData().Amazoid = data

        print("[Amazoid Scenario] Contract already signed, ready to order!")
        print("[Amazoid Scenario] Open a catalog and circle items")
        print("[Amazoid Scenario] Find a mailbox and use it as your contract mailbox")
    end
}

print("[Amazoid] Debug scenarios registered")
