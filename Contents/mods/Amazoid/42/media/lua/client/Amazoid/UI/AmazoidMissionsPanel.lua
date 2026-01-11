--[[
    Amazoid - Mysterious Mailbox Merchant
    Missions UI

    This file contains the UI for viewing and accepting missions.
]]

require "Amazoid/UI/AmazoidBasePanel"
require "Amazoid/AmazoidData"

---@class AmazoidMissionsPanel : AmazoidBasePanel
AmazoidMissionsPanel = AmazoidBasePanel:derive("AmazoidMissionsPanel")

function AmazoidMissionsPanel:createChildren()
    AmazoidBasePanel.createChildren(self)

    -- Start content below header (title bar 25 + poster 70 + spacing)
    local y = 25 + 70 + 10
    local padding = 10

    -- Tab buttons for Available / Active missions (dark theme)
    self.availableTabBtn = ISButton:new(padding, y, 100, 25, "Available", self, AmazoidMissionsPanel.onAvailableTab)
    self.availableTabBtn:initialise()
    self.availableTabBtn:instantiate()
    self.availableTabBtn.textColor = { r = 0.95, g = 0.95, b = 0.95, a = 1 }
    self:addChild(self.availableTabBtn)

    self.activeTabBtn = ISButton:new(padding + 110, y, 100, 25, "Active", self, AmazoidMissionsPanel.onActiveTab)
    self.activeTabBtn:initialise()
    self.activeTabBtn:instantiate()
    self.activeTabBtn.textColor = { r = 0.95, g = 0.95, b = 0.95, a = 1 }
    self:addChild(self.activeTabBtn)

    y = y + 35

    -- Missions list (dark theme)
    self.missionsList = ISScrollingListBox:new(padding, y, self.width / 2 - padding - 5, self.height - y - 60)
    self.missionsList:initialise()
    self.missionsList:instantiate()
    self.missionsList.itemheight = 50
    self.missionsList.backgroundColor = { r = 0.15, g = 0.15, b = 0.17, a = 0.9 }
    self.missionsList.borderColor = { r = 0.30, g = 0.30, b = 0.32, a = 1 }
    self.missionsList:setOnMouseDownFunction(self, AmazoidMissionsPanel.onSelectMission)
    self.missionsList.doDrawItem = AmazoidMissionsPanel.drawMissionRow
    self.missionsList.parent = self
    self:addChild(self.missionsList)

    -- Mission details panel (dark theme)
    local detailsX = self.width / 2 + 5
    local detailsWidth = self.width / 2 - padding - 5

    self.detailsPanel = ISRichTextPanel:new(detailsX, y, detailsWidth, self.height - y - 60)
    self.detailsPanel:initialise()
    self.detailsPanel:instantiate()
    self.detailsPanel.backgroundColor = { r = 0.15, g = 0.15, b = 0.17, a = 0.9 }
    self.detailsPanel.borderColor = { r = 0.30, g = 0.30, b = 0.32, a = 1 }
    self.detailsPanel.marginLeft = 10
    self.detailsPanel.marginTop = 10
    self:addChild(self.detailsPanel)

    -- Accept / Abandon button (dark theme)
    self.actionBtn = ISButton:new(self.width - 130, self.height - 50, 120, 35, "Accept", self,
        AmazoidMissionsPanel.onAction)
    self.actionBtn:initialise()
    self.actionBtn:instantiate()
    self.actionBtn.enable = false
    self.actionBtn.backgroundColor = { r = 0.2, g = 0.4, b = 0.2, a = 0.8 }
    self.actionBtn.backgroundColorMouseOver = { r = 0.3, g = 0.6, b = 0.3, a = 1 }
    self.actionBtn.textColor = { r = 0.95, g = 0.95, b = 0.95, a = 1 }
    self:addChild(self.actionBtn)

    -- Initialize
    self.showingAvailable = true
    self.selectedMission = nil
    self:refreshMissions()
    self:updateTabButtons()
end

function AmazoidMissionsPanel:updateTabButtons()
    if self.showingAvailable then
        self.availableTabBtn.backgroundColor = { r = 0.25, g = 0.25, b = 0.30, a = 1 }
        self.activeTabBtn.backgroundColor = { r = 0.15, g = 0.15, b = 0.17, a = 0.8 }
        self.actionBtn:setTitle("Accept")
        self.actionBtn.backgroundColor = { r = 0.2, g = 0.4, b = 0.2, a = 0.8 }
    else
        self.availableTabBtn.backgroundColor = { r = 0.15, g = 0.15, b = 0.17, a = 0.8 }
        self.activeTabBtn.backgroundColor = { r = 0.25, g = 0.25, b = 0.30, a = 1 }
        self.actionBtn:setTitle("Abandon")
        self.actionBtn.backgroundColor = { r = 0.4, g = 0.2, b = 0.2, a = 0.8 }
    end
end

function AmazoidMissionsPanel:onAvailableTab()
    self.showingAvailable = true
    self:updateTabButtons()
    self:refreshMissions()
end

function AmazoidMissionsPanel:onActiveTab()
    self.showingAvailable = false
    self:updateTabButtons()
    self:refreshMissions()
end

function AmazoidMissionsPanel:refreshMissions()
    self.missionsList:clear()
    self.selectedMission = nil
    self.actionBtn.enable = false
    self.detailsPanel:setText(" ") -- Use space instead of empty string to avoid RichTextPanel issues

    local missions = {}

    if self.showingAvailable then
        -- Generate available missions based on reputation
        if Amazoid.Server then
            missions = Amazoid.Server.generateAvailableMissions(self.reputation)
        end
    else
        -- Get active missions
        if Amazoid.Client then
            missions = Amazoid.Client.playerData.activeMissions or {}
        end
    end

    for _, mission in ipairs(missions) do
        self.missionsList:addItem(mission.title, mission)
    end
end

function AmazoidMissionsPanel.drawMissionRow(self, y, item, alt)
    local mission = item.item
    if not mission then return y + self.itemheight end

    -- Background
    if self.selected == item.index then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.3, 0.5, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0.1, 0.1, 0.1)
    end

    -- Mission title
    self:drawText(mission.title, 10, y + 5, 1, 1, 1, 1, UIFont.Small)

    -- Mission type
    local typeText = mission.type or "unknown"
    self:drawText(typeText, 10, y + 22, 0.6, 0.6, 0.8, 1, UIFont.Small)

    -- Reward
    if mission.reward then
        local rewardText = "$" .. (mission.reward.money or 0)
        self:drawText(rewardText, self.width - 60, y + 5, 0.5, 1, 0.5, 1, UIFont.Small)
    end

    -- Time limit
    if mission.timeLimit then
        local timeText = mission.timeLimit .. "h"
        self:drawText(timeText, self.width - 60, y + 22, 1, 0.7, 0.3, 1, UIFont.Small)
    end

    return y + self.itemheight
end

function AmazoidMissionsPanel:onSelectMission(item)
    if not item then return end

    self.selectedMission = item.item
    self.actionBtn.enable = true
    self:updateDetails()
end

function AmazoidMissionsPanel:updateDetails()
    if not self.selectedMission then
        self.detailsPanel:setText(" ") -- Use space instead of empty string to avoid RichTextPanel issues
        return
    end

    local mission = self.selectedMission
    local text = " <H2> " .. (mission.title or "Unknown Mission") .. " <LINE> <LINE> "
    text = text .. " <SIZE:medium> "
    text = text .. (mission.description or "No description") .. " <LINE> <LINE> "

    -- Requirements
    text = text .. " <RGB:1,0.8,0.3> Requirements: <RGB:1,1,1> <LINE> "
    if mission.requirements then
        if mission.type == Amazoid.MissionTypes.ELIMINATION then
            -- Display elimination-specific requirements
            local killCount = mission.requirements.killCount or 10
            local weaponName = mission.requirements.weaponName or "any weapon"
            text = text .. "- Kill " .. killCount .. " zombies <LINE> "
            text = text .. "- Using: " .. weaponName .. " <LINE> "
        elseif mission.type == Amazoid.MissionTypes.COLLECTION then
            -- Display collection-specific requirements
            local count = mission.requirements.count or 1
            local itemType = mission.requirements.itemType or "Unknown"
            -- Try to get friendly name
            local itemName = itemType
            if string.find(itemType, "Base.") then
                itemName = string.gsub(itemType, "Base.", "")
            end
            text = text .. "- Collect " .. count .. "x " .. itemName .. " <LINE> "
        else
            -- Generic display for other types
            for key, value in pairs(mission.requirements) do
                if value then
                    text = text .. "- " .. key .. ": " .. tostring(value) .. " <LINE> "
                end
            end
        end
    end

    text = text .. " <LINE> "

    -- Rewards
    text = text .. " <RGB:0.5,1,0.5> Rewards: <RGB:1,1,1> <LINE> "
    if mission.reward then
        if mission.reward.money then
            text = text .. "- Money: $" .. mission.reward.money .. " <LINE> "
        end
        if mission.reward.reputation then
            text = text .. "- Reputation: +" .. mission.reward.reputation .. " <LINE> "
        end
    end

    -- Time limit
    if mission.timeLimit then
        text = text .. " <LINE> <RGB:1,0.5,0.3> Time Limit: " .. mission.timeLimit .. " hours <RGB:1,1,1> "
    end

    -- Progress (for active missions)
    if not self.showingAvailable then
        if mission.type == Amazoid.MissionTypes.ELIMINATION then
            local progress = mission.progress or 0
            local required = mission.requirements and mission.requirements.killCount or 10
            local color = progress >= required and "<RGB:0.3,1,0.3>" or "<RGB:0.3,0.8,1>"
            text = text .. " <LINE> <LINE> " .. color .. "Progress: " .. progress .. "/" .. required .. " kills"
            if progress >= required then
                text = text .. " <LINE> <RGB:0.3,1,0.3> COMPLETE - Return to mailbox! "
            end
            text = text .. " <RGB:1,1,1> "
        elseif mission.type == Amazoid.MissionTypes.COLLECTION then
            text = text .. " <LINE> <LINE> <RGB:0.6,0.6,0.6> Leave items in the mailbox <RGB:1,1,1> "
        end
    end

    self.detailsPanel:setText(text)
    -- Wrap paginate in pcall to catch any RichTextPanel errors gracefully
    local success, err = pcall(function()
        self.detailsPanel:paginate()
    end)
    if not success then
        print("[Amazoid] Warning: paginate error - " .. tostring(err))
    end
end

function AmazoidMissionsPanel:onAction()
    if not self.selectedMission then return end

    if self.showingAvailable then
        -- Accept mission
        if Amazoid.Client then
            Amazoid.Client.acceptMission(self.selectedMission)
        end
        print("[Amazoid] Mission accepted: " .. self.selectedMission.title)
    else
        -- Abandon mission
        if Amazoid.Client then
            Amazoid.Client.completeMission(self.selectedMission.id, false)
        end
        print("[Amazoid] Mission abandoned: " .. self.selectedMission.title)
    end

    self:refreshMissions()
end

function AmazoidMissionsPanel:new(x, y, width, height, player, reputation)
    local o = AmazoidBasePanel:new(x, y, width, height, "Amazoid Missions")
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.reputation = reputation or 0
    return o
end

-- Per-player window position storage (legacy - now uses shared Amazoid.UI.sharedWindowPositions)
AmazoidMissionsPanel.savedPositions = {}

function AmazoidMissionsPanel:onClose()
    -- Save window position to shared storage for this player
    if self.playerNum ~= nil and Amazoid.UI and Amazoid.UI.saveWindowPosition then
        Amazoid.UI.saveWindowPosition(self.playerNum, self:getX(), self:getY())
    end

    AmazoidBasePanel.onClose(self)
end

--- Static function to show missions panel
---@param player IsoPlayer The player
function AmazoidMissionsPanel.showMissions(player)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local playerNum = player and player:getPlayerNum() or 0

    local width = 650
    local height = 550 -- Taller to accommodate header

    -- Use shared position storage, fall back to centered
    local x, y
    if Amazoid.UI and Amazoid.UI.getWindowPositionOrCenter then
        x, y = Amazoid.UI.getWindowPositionOrCenter(playerNum, width, height)
    else
        x = (screenW - width) / 2
        y = (screenH - height) / 2
    end

    local reputation = 0
    if Amazoid.Client then
        reputation = Amazoid.Client.getReputation()
    end

    local panel = AmazoidMissionsPanel:new(x, y, width, height, player, reputation)
    panel.playerNum = playerNum -- Store for saving position later
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)

    return panel
end

print("[Amazoid] Missions UI loaded")
