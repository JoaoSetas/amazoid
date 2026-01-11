--[[
    Amazoid - Mysterious Mailbox Merchant
    Reputation Triggers

    This module listens to events and triggers reputation-based rewards:
    - Milestone letters
    - Lore letters
    - Reputation-based gifts

    All thresholds are designed to avoid collisions (see AmazoidEvents.lua for full table).
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidEvents"
require "Amazoid/AmazoidLetters"
require "Amazoid/AmazoidMailbox"

Amazoid.ReputationTriggers = Amazoid.ReputationTriggers or {}

-- Track which reputation-based gifts have been sent
Amazoid.ReputationTriggers.sentGifts = {}

--[[
    ============================================
    MILESTONE LETTERS
    ============================================
    Sent when player crosses a milestone threshold.
    Thresholds: 10, 20, 25, 35, 40, 50, 60, 70, 80, 90, 100
]]

--- Handle milestone letters when reputation changes
---@param data table Event data {oldRep, newRep, amount, reason}
local function onReputationChangedMilestones(data)
    if not data or not data.oldRep or not data.newRep then return end

    -- Only trigger on reputation increase
    if data.newRep <= data.oldRep then return end

    -- Check if player has contract
    if not Amazoid.Client or not Amazoid.Client.hasContract() then return end

    -- Get milestone letter if threshold crossed
    local letter = Amazoid.Letters.getMilestoneLetter(data.newRep, data.oldRep)
    if not letter then return end

    -- Find the contracted mailbox
    local contractLocation = Amazoid.Client.playerData.contractMailbox
    if not contractLocation then return end

    local mailbox = Amazoid.Mailbox.findMailboxAt(contractLocation.x, contractLocation.y, contractLocation.z)
    if not mailbox then return end

    -- Add milestone letter to mailbox
    local container = mailbox:getContainer()
    if not container then return end

    local letterItem = container:AddItem("Amazoid.MerchantLetter")
    if letterItem then
        local modData = letterItem:getModData()
        modData.AmazoidLetterData = letter

        print("[Amazoid ReputationTriggers] Milestone letter sent: " .. letter.title)
    end
end

--[[
    ============================================
    LORE LETTERS
    ============================================
    Unlocked at specific reputation thresholds.
    Thresholds: 15, 28, 38, 48, 58, 72, 85 (avoid milestone collisions)
]]

--- Handle lore letters when reputation changes
---@param data table Event data {oldRep, newRep, amount, reason}
local function onReputationChangedLore(data)
    if not data or not data.oldRep or not data.newRep then return end

    -- Only trigger on reputation increase
    if data.newRep <= data.oldRep then return end

    -- Check if player has contract
    if not Amazoid.Client or not Amazoid.Client.hasContract() then return end

    -- Get player's discovered lore
    local discoveredLore = Amazoid.Client.playerData.discoveredLore or {}

    -- Get next available lore letter
    local lore = Amazoid.Letters.getNextLoreLetter(data.newRep, discoveredLore)
    if not lore then return end

    -- Check if we just crossed the threshold (wasn't available before)
    local wasAvailableBefore = data.oldRep >= lore.reputationRequired
    if wasAvailableBefore then return end

    -- Find the contracted mailbox
    local contractLocation = Amazoid.Client.playerData.contractMailbox
    if not contractLocation then return end

    local mailbox = Amazoid.Mailbox.findMailboxAt(contractLocation.x, contractLocation.y, contractLocation.z)
    if not mailbox then return end

    -- Add lore letter to mailbox
    local container = mailbox:getContainer()
    if not container then return end

    local letterItem = container:AddItem("Amazoid.LoreLetter")
    if letterItem then
        local modData = letterItem:getModData()
        modData.AmazoidLetterData = {
            title = lore.title,
            content = lore.content,
        }
        modData.AmazoidLoreId = lore.id

        -- Mark as discovered
        table.insert(discoveredLore, lore.id)
        Amazoid.Client.playerData.discoveredLore = discoveredLore
        Amazoid.Client.savePlayerData()

        print("[Amazoid ReputationTriggers] Lore letter sent: " .. lore.title)
    end
end

--[[
    ============================================
    REPUTATION-BASED GIFTS
    ============================================
    Sent when player reaches certain reputation thresholds.
    Thresholds: 18, 32, 52, 65, 78, 92 (avoid milestone/lore collisions)

    Gifts are wrapped in appropriately-sized packages.
]]

-- Gift definitions by reputation threshold
-- New thresholds: 8, 23, 33, 48, 65, 78, 92 (65+ unchanged)
Amazoid.ReputationTriggers.GiftDefinitions = {
    [8] = {
        id = "gift_8",
        title = "First Appreciation",
        items = { "Base.Bandage", "Base.Bandage", "Base.Pills" },
        letter = {
            title = "A Small Token",
            content = [[
Dear Customer,

You've been reliable. That deserves recognition.

We've left a small gift for you. Nothing fancy - just some supplies we thought you might need.

Consider it encouragement. There's more where that came from.

Your friends,
The Merchants
]]
        },
    },
    [23] = {
        id = "gift_23",
        title = "Growing Trust",
        items = { "Base.Axe", "Base.RippedSheets", "Base.RippedSheets", "Base.RippedSheets" },
        letter = {
            title = "Tools of Survival",
            content = [[
Dear Customer,

Twenty-three points. You're climbing the ladder.

We've noticed you're serious about survival. Here's something to help.

An axe. Multipurpose. Chops wood. Chops... other things. You know.

Keep building that trust,
The Merchants

P.S. - The ripped sheets are for bandages. We hope you won't need them.
]]
        },
    },
    [33] = {
        id = "gift_33",
        title = "Steady Progress",
        items = { "Base.HuntingKnife", "Base.AlcoholBandage", "Base.AlcoholBandage" },
        letter = {
            title = "For the Journey",
            content = [[
Dear Customer,

Thirty-three points. You're proving yourself.

A hunting knife and some quality bandages. The basics of survival, done right.

The medical catalog should be available soon. Until then, stay safe.

With appreciation,
The Merchants
]]
        },
    },
    [48] = {
        id = "gift_48",
        title = "Inner Circle Welcome",
        items = { "Base.Pistol", "Base.Bullets9mmBox" },
        letter = {
            title = "Protection",
            content = [[
Dear Trusted Customer,

You've crossed into the inner circle. Congratulations.

With greater trust comes greater firepower. We've included a pistol and some ammunition.

Use it wisely. We'd hate to lose such a promising customer.

Welcome to the family,
Marcus & Julia

P.S. - We recommend practicing before you need it for real.
]]
        },
    },
    [65] = {
        id = "gift_65",
        title = "Family Privilege",
        items = { "Base.Katana" },
        letter = {
            title = "A Blade of Honor",
            content = [[
Dear Friend,

Sixty-five. You've earned our respect.

Words cannot express what this means, so we'll let the gift speak for itself.

A katana. Rare. Deadly. Silent. Perfect for the world we live in.

Treat it well. It belonged to someone we cared about.

With deep respect,
M & J
]]
        },
    },
    [78] = {
        id = "gift_78",
        title = "Trusted Ally",
        items = { "Base.AssaultRifle", "Base.556Box", "Base.556Box" },
        letter = {
            title = "Heavy Artillery",
            content = [[
Dear Partner,

We don't give these out lightly.

You've proven yourself time and time again. Your reputation precedes you. The dead should fear you.

Use this wisely. Noise attracts attention. But when you need to clear a path... this will clear it.

Almost there,
Marcus & Julia
]]
        },
    },
    [92] = {
        id = "gift_92",
        title = "Ultimate Trust",
        items = { "Base.Sledgehammer", "Base.KevlarHelmet", "Base.BulletproofVest" },
        letter = {
            title = "For the Final Push",
            content = [[
Dear True Friend,

You're almost at the top. Eight more points.

We've assembled a care package for you. The best we have. Body armor, a helmet, and a sledgehammer for when subtlety isn't an option.

When you hit one hundred, come find us. We mean it.

Until then, stay alive. You're too valuable to lose.

With all our trust,
Marcus & Julia

P.S. - Sergeant Fluffington picked out the helmet. He has good taste.
]]
        },
    },
}

--- Calculate package type based on total item weight
---@param items table List of item type strings
---@return string Package type (DeliveryPackageSmall, Medium, or Large)
local function getPackageTypeForItems(items)
    local totalWeight = 0

    for _, itemType in ipairs(items) do
        local scriptItem = ScriptManager.instance:getItem(itemType)
        if scriptItem then
            totalWeight = totalWeight + scriptItem:getActualWeight()
        else
            totalWeight = totalWeight + 1 -- Default weight if unknown
        end
    end

    if totalWeight <= 5 then
        return "Amazoid.DeliveryPackageSmall"
    elseif totalWeight <= 15 then
        return "Amazoid.DeliveryPackageMedium"
    else
        return "Amazoid.DeliveryPackageLarge"
    end
end

--- Send a reputation-based gift
---@param threshold number The reputation threshold
---@param giftDef table The gift definition
---@return boolean Success
local function sendReputationGift(threshold, giftDef)
    if not Amazoid.Client or not Amazoid.Client.hasContract() then return false end

    -- Find the contracted mailbox
    local contractLocation = Amazoid.Client.playerData.contractMailbox
    if not contractLocation then return false end

    local mailbox = Amazoid.Mailbox.findMailboxAt(contractLocation.x, contractLocation.y, contractLocation.z)
    if not mailbox then return false end

    local container = mailbox:getContainer()
    if not container then return false end

    -- Determine package type based on items
    local packageType = getPackageTypeForItems(giftDef.items)

    -- Create the package
    local package = container:AddItem(packageType)
    if not package then
        print("[Amazoid ReputationTriggers] ERROR: Failed to create gift package")
        return false
    end

    -- Get the package's internal container
    local packageContainer = package:getItemContainer()
    if packageContainer then
        -- Add gift items to package
        for _, itemType in ipairs(giftDef.items) do
            packageContainer:AddItem(itemType)
        end
    else
        -- Fallback: add items directly to mailbox
        for _, itemType in ipairs(giftDef.items) do
            container:AddItem(itemType)
        end
    end

    -- Add gift letter
    local letterItem = container:AddItem("Amazoid.GiftLetter")
    if letterItem then
        local modData = letterItem:getModData()
        modData.AmazoidLetterData = giftDef.letter
        modData.AmazoidGiftId = giftDef.id
    end

    -- Mark gift as sent
    Amazoid.ReputationTriggers.sentGifts[giftDef.id] = true

    -- Save to player data
    Amazoid.Client.playerData.sentReputationGifts = Amazoid.Client.playerData.sentReputationGifts or {}
    Amazoid.Client.playerData.sentReputationGifts[giftDef.id] = true
    Amazoid.Client.savePlayerData()

    print("[Amazoid ReputationTriggers] Gift sent: " .. giftDef.title .. " (rep " .. threshold .. ")")

    -- Fire GiftSent event
    if Amazoid.Events and Amazoid.Events.fire then
        Amazoid.Events.fire(Amazoid.Events.Names.GIFT_SENT, {
            triggerType = "reputation",
            giftId = giftDef.id,
            threshold = threshold,
            items = giftDef.items,
            mailbox = mailbox,
        })
    end

    return true
end

--- Handle reputation-based gifts when reputation changes
---@param data table Event data {oldRep, newRep, amount, reason}
local function onReputationChangedGifts(data)
    if not data or not data.oldRep or not data.newRep then return end

    -- Only trigger on reputation increase
    if data.newRep <= data.oldRep then return end

    -- Load sent gifts from player data if needed
    if Amazoid.Client and Amazoid.Client.playerData then
        local sentGifts = Amazoid.Client.playerData.sentReputationGifts or {}
        for id, _ in pairs(sentGifts) do
            Amazoid.ReputationTriggers.sentGifts[id] = true
        end
    end

    -- Check each gift threshold
    for threshold, giftDef in pairs(Amazoid.ReputationTriggers.GiftDefinitions) do
        -- Did we just cross this threshold?
        if data.newRep >= threshold and data.oldRep < threshold then
            -- Has this gift already been sent?
            if not Amazoid.ReputationTriggers.sentGifts[giftDef.id] then
                sendReputationGift(threshold, giftDef)
            end
        end
    end
end

--[[
    ============================================
    INITIALIZATION
    ============================================
]]

--- Initialize reputation triggers
function Amazoid.ReputationTriggers.init()
    -- Load sent gifts from player data
    if Amazoid.Client and Amazoid.Client.playerData then
        local sentGifts = Amazoid.Client.playerData.sentReputationGifts or {}
        for id, _ in pairs(sentGifts) do
            Amazoid.ReputationTriggers.sentGifts[id] = true
        end
    end

    -- Register event listeners
    if Amazoid.Events and Amazoid.Events.on then
        -- Milestone letters (priority 100 - happens first)
        Amazoid.Events.on(Amazoid.Events.Names.REPUTATION_CHANGED, onReputationChangedMilestones, 100)

        -- Lore letters (priority 90)
        Amazoid.Events.on(Amazoid.Events.Names.REPUTATION_CHANGED, onReputationChangedLore, 90)

        -- Reputation gifts (priority 80)
        Amazoid.Events.on(Amazoid.Events.Names.REPUTATION_CHANGED, onReputationChangedGifts, 80)

        print("[Amazoid] Reputation triggers initialized")
    else
        print("[Amazoid] ERROR: Events system not available for reputation triggers")
    end
end

print("[Amazoid] ReputationTriggers module loaded")
