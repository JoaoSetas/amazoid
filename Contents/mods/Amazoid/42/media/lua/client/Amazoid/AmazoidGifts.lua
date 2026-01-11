--[[
    Amazoid - Mysterious Mailbox Merchant
    Gift System

    This file tracks player actions and triggers merchant gifts.
]]

require "Amazoid/AmazoidData"
require "Amazoid/AmazoidEvents"
require "Amazoid/AmazoidLetters"
require "Amazoid/AmazoidMailbox"

Amazoid.Gifts = Amazoid.Gifts or {}

-- Tracking data
Amazoid.Gifts.playerStats = {
    healCount = 0,
    killStreak = 0,
    lastKillTime = 0,
    booksRead = 0,
    foodCooked = 0,
    survivalDays = 0,
}

-- Gift cooldown (in game hours)
Amazoid.Gifts.COOLDOWN = 24

-- Minimum reputation for gifts
Amazoid.Gifts.MIN_REPUTATION = 10

-- Gift definitions
Amazoid.Gifts.giftTypes = {
    [Amazoid.GiftTriggers.HEAL_WOUND] = {
        threshold = 5, -- After 5 healing actions
        items = { "Base.Bandage", "Base.AlcoholBandage" },
        letter = Amazoid.Letters.Gifts.HealWound,
        resetAfterGift = true,
    },
    [Amazoid.GiftTriggers.KILL_MANY] = {
        threshold = 20, -- 20 kills in short time
        items = { "Base.Bullets9mm", "Base.BaseballBat" },
        letter = Amazoid.Letters.Gifts.KillStreak,
        resetAfterGift = true,
    },
    [Amazoid.GiftTriggers.SURVIVE_DAYS] = {
        threshold = 7, -- Every 7 days
        items = { "Base.TinnedBeans", "Base.TinnedSoup", "Base.Bandage" },
        letter = Amazoid.Letters.Gifts.SurviveDays,
        resetAfterGift = false, -- Don't reset, use milestone system
    },
    [Amazoid.GiftTriggers.COOK_FOOD] = {
        threshold = 10, -- After cooking 10 items
        items = { "Base.Pan", "Base.Pot" },
        letter = nil,
        resetAfterGift = true,
    },
    [Amazoid.GiftTriggers.READ_BOOK] = {
        threshold = 3,           -- After reading 3 skill books
        items = { "Base.Book" }, -- Random book
        letter = nil,
        resetAfterGift = true,
    },
}

--- Initialize gift system
function Amazoid.Gifts.init()
    print("[Amazoid] Gift system initializing...")
    Amazoid.Gifts.loadState()
end

--- Save gift state
function Amazoid.Gifts.saveState()
    local player = getPlayer()
    if not player then return end

    local modData = player:getModData()
    modData.AmazoidGifts = {
        playerStats = Amazoid.Gifts.playerStats,
        lastGiftTime = Amazoid.Gifts.lastGiftTime or 0,
        giftHistory = Amazoid.Gifts.giftHistory or {},
    }
end

--- Load gift state
function Amazoid.Gifts.loadState()
    local player = getPlayer()
    if not player then return end

    local modData = player:getModData()
    if modData.AmazoidGifts then
        Amazoid.Gifts.playerStats = modData.AmazoidGifts.playerStats or Amazoid.Gifts.playerStats
        Amazoid.Gifts.lastGiftTime = modData.AmazoidGifts.lastGiftTime or 0
        Amazoid.Gifts.giftHistory = modData.AmazoidGifts.giftHistory or {}
    end
end

--- Check if gift cooldown has passed
---@return boolean
function Amazoid.Gifts.isCooldownOver()
    local currentTime = getGameTime():getWorldAgeHours()
    local lastGift = Amazoid.Gifts.lastGiftTime or 0

    return (currentTime - lastGift) >= Amazoid.Gifts.COOLDOWN
end

--- Check if player has enough reputation for gifts
---@return boolean
function Amazoid.Gifts.hasEnoughReputation()
    if not Amazoid.Client then return false end

    local rep = Amazoid.Client.getReputation()
    return rep >= Amazoid.Gifts.MIN_REPUTATION
end

--- Send a gift to the player's contracted mailbox
---@param triggerType string Gift trigger type
---@param player IsoPlayer The player
function Amazoid.Gifts.sendGift(triggerType, player)
    if not player then return end
    if not Amazoid.Gifts.isCooldownOver() then return end
    if not Amazoid.Gifts.hasEnoughReputation() then return end
    if not Amazoid.Client or not Amazoid.Client.hasContract() then return end

    local giftDef = Amazoid.Gifts.giftTypes[triggerType]
    if not giftDef then return end

    -- Find contracted mailbox
    local contractLocation = Amazoid.Client.playerData.contractMailbox
    if not contractLocation then return end

    local mailbox = Amazoid.Mailbox.findMailboxAt(contractLocation.x, contractLocation.y, contractLocation.z)
    if not mailbox then return end

    local container = mailbox:getContainer()
    if not container then return end

    -- Add gift items
    local itemType = giftDef.items[ZombRand(1, #giftDef.items + 1)]
    container:AddItem(itemType)

    -- Add gift letter
    local letter = container:AddItem("Amazoid.GiftLetter")
    if letter then
        local letterModData = letter:getModData()
        if giftDef.letter then
            letterModData.AmazoidLetterData = giftDef.letter
        end
        -- Set literatureTitle for "already read" tracking (unique per gift)
        local globalData = ModData.getOrCreate("Amazoid")
        globalData.giftLetterCount = (globalData.giftLetterCount or 0) + 1
        letterModData.literatureTitle = "Amazoid_GiftLetter_" .. globalData.giftLetterCount
    end

    -- Update cooldown
    Amazoid.Gifts.lastGiftTime = getGameTime():getWorldAgeHours()

    -- Record in history
    Amazoid.Gifts.giftHistory = Amazoid.Gifts.giftHistory or {}
    table.insert(Amazoid.Gifts.giftHistory, {
        type = triggerType,
        time = Amazoid.Gifts.lastGiftTime,
        item = itemType,
    })

    -- Reset counter if needed
    if giftDef.resetAfterGift then
        if triggerType == Amazoid.GiftTriggers.HEAL_WOUND then
            Amazoid.Gifts.playerStats.healCount = 0
        elseif triggerType == Amazoid.GiftTriggers.KILL_MANY then
            Amazoid.Gifts.playerStats.killStreak = 0
        elseif triggerType == Amazoid.GiftTriggers.COOK_FOOD then
            Amazoid.Gifts.playerStats.foodCooked = 0
        elseif triggerType == Amazoid.GiftTriggers.READ_BOOK then
            Amazoid.Gifts.playerStats.booksRead = 0
        end
    end

    -- Add small reputation bonus
    if Amazoid.Client then
        Amazoid.Client.modifyReputation(Amazoid.Reputation.GIFT_RECEIVED, "gift_received")
    end

    -- Fire GiftSent event
    if Amazoid.Events and Amazoid.Events.fire then
        Amazoid.Events.fire(Amazoid.Events.Names.GIFT_SENT, {
            triggerType = triggerType,
            items = { itemType },
            mailbox = mailbox,
        })
    end

    Amazoid.Gifts.saveState()

    print("[Amazoid] Gift sent to mailbox: " .. itemType)
end

--- Track player healing
---@param player IsoPlayer The player
function Amazoid.Gifts.onPlayerHeal(player)
    Amazoid.Gifts.playerStats.healCount = (Amazoid.Gifts.playerStats.healCount or 0) + 1

    local threshold = Amazoid.Gifts.giftTypes[Amazoid.GiftTriggers.HEAL_WOUND].threshold
    if Amazoid.Gifts.playerStats.healCount >= threshold then
        Amazoid.Gifts.sendGift(Amazoid.GiftTriggers.HEAL_WOUND, player)
    end

    Amazoid.Gifts.saveState()
end

--- Track zombie kills for kill streak
---@param player IsoPlayer The player
function Amazoid.Gifts.onZombieKill(player)
    local currentTime = getGameTime():getWorldAgeHours()
    local lastKill = Amazoid.Gifts.playerStats.lastKillTime or 0

    -- Reset streak if too much time passed (more than 1 hour)
    if (currentTime - lastKill) > 1 then
        Amazoid.Gifts.playerStats.killStreak = 0
    end

    Amazoid.Gifts.playerStats.killStreak = (Amazoid.Gifts.playerStats.killStreak or 0) + 1
    Amazoid.Gifts.playerStats.lastKillTime = currentTime

    local threshold = Amazoid.Gifts.giftTypes[Amazoid.GiftTriggers.KILL_MANY].threshold
    if Amazoid.Gifts.playerStats.killStreak >= threshold then
        Amazoid.Gifts.sendGift(Amazoid.GiftTriggers.KILL_MANY, player)
    end

    Amazoid.Gifts.saveState()
end

--- Track cooking
---@param player IsoPlayer The player
function Amazoid.Gifts.onCookFood(player)
    Amazoid.Gifts.playerStats.foodCooked = (Amazoid.Gifts.playerStats.foodCooked or 0) + 1

    local threshold = Amazoid.Gifts.giftTypes[Amazoid.GiftTriggers.COOK_FOOD].threshold
    if Amazoid.Gifts.playerStats.foodCooked >= threshold then
        Amazoid.Gifts.sendGift(Amazoid.GiftTriggers.COOK_FOOD, player)
    end

    Amazoid.Gifts.saveState()
end

--- Track reading
---@param player IsoPlayer The player
---@param book InventoryItem The book
function Amazoid.Gifts.onReadBook(player, book)
    -- Only count skill books
    if not book then return end

    local bookType = book:getFullType()
    if string.find(bookType, "Skill") or string.find(bookType, "Book") then
        Amazoid.Gifts.playerStats.booksRead = (Amazoid.Gifts.playerStats.booksRead or 0) + 1

        local threshold = Amazoid.Gifts.giftTypes[Amazoid.GiftTriggers.READ_BOOK].threshold
        if Amazoid.Gifts.playerStats.booksRead >= threshold then
            Amazoid.Gifts.sendGift(Amazoid.GiftTriggers.READ_BOOK, player)
        end

        Amazoid.Gifts.saveState()
    end
end

--- Track survival days (checked periodically)
---@param player IsoPlayer The player
function Amazoid.Gifts.checkSurvivalMilestone(player)
    if not player then return end

    local stats = player:getStats()
    local days = player:getHoursSurvived() / 24
    local lastMilestone = Amazoid.Gifts.playerStats.survivalDays or 0

    local threshold = Amazoid.Gifts.giftTypes[Amazoid.GiftTriggers.SURVIVE_DAYS].threshold
    local currentMilestone = math.floor(days / threshold) * threshold

    if currentMilestone > lastMilestone then
        Amazoid.Gifts.playerStats.survivalDays = currentMilestone
        Amazoid.Gifts.sendGift(Amazoid.GiftTriggers.SURVIVE_DAYS, player)
    end
end

-- Event handlers

local function onGameStart()
    Amazoid.Gifts.init()
end

local function onZombieDead(zombie)
    -- In split-screen, check all local players for the closest one (likely killer)
    local players = IsoPlayer.getPlayers()
    if not players or players:size() == 0 then return end

    local closestPlayer = nil
    local closestDist = 9999

    for i = 0, players:size() - 1 do
        local p = players:get(i)
        if p and zombie then
            local dist = p:DistTo(zombie)
            if dist < closestDist then
                closestDist = dist
                closestPlayer = p
            end
        end
    end

    if closestPlayer then
        Amazoid.Gifts.onZombieKill(closestPlayer)
    end
end

local function onEveryHours()
    -- In split-screen, check survival milestone for all local players
    local players = IsoPlayer.getPlayers()
    if not players or players:size() == 0 then return end

    for i = 0, players:size() - 1 do
        local player = players:get(i)
        if player then
            Amazoid.Gifts.checkSurvivalMilestone(player)
        end
    end
end

local function onSave()
    Amazoid.Gifts.saveState()
end

-- Hook into healing events
local function onUseItem(player, item)
    if not player or not item then return end

    local itemType = item:getFullType()

    -- Check for bandages/healing items
    if string.find(itemType, "Bandage") or
        string.find(itemType, "Rag") or
        string.find(itemType, "Suture") then
        Amazoid.Gifts.onPlayerHeal(player)
    end
end

-- Hook into cooking events (simplified - would need proper event)
local function onCraftComplete(recipe, item, container, player)
    if not player or not recipe then return end

    local recipeName = recipe:getName()
    if string.find(recipeName:lower(), "cook") or
        string.find(recipeName:lower(), "grill") or
        string.find(recipeName:lower(), "fry") then
        Amazoid.Gifts.onCookFood(player)
    end
end

-- Register events
Events.OnGameStart.Add(onGameStart)
Events.OnZombieDead.Add(onZombieDead)
Events.EveryHours.Add(onEveryHours)
Events.OnSave.Add(onSave)
-- Events.OnUseItem.Add(onUseItem) -- This event may not exist, would need alternative
-- Events.OnCraftComplete.Add(onCraftComplete) -- Alternative crafting event

print("[Amazoid] Gift system loaded")
