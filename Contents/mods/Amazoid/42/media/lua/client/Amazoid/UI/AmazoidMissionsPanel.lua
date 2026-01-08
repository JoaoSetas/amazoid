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
    
    local y = 35
    local padding = 10
    
    -- Tab buttons for Available / Active missions
    self.availableTabBtn = ISButton:new(padding, y, 100, 25, "Available", self, AmazoidMissionsPanel.onAvailableTab)
    self.availableTabBtn:initialise()
    self.availableTabBtn:instantiate()
    self:addChild(self.availableTabBtn)
    
    self.activeTabBtn = ISButton:new(padding + 110, y, 100, 25, "Active", self, AmazoidMissionsPanel.onActiveTab)
    self.activeTabBtn:initialise()
    self.activeTabBtn:instantiate()
    self:addChild(self.activeTabBtn)
    
    y = y + 35
    
    -- Missions list
    self.missionsList = ISScrollingListBox:new(padding, y, self.width / 2 - padding - 5, self.height - y - 60)
    self.missionsList:initialise()
    self.missionsList:instantiate()
    self.missionsList.itemheight = 50
    self.missionsList.backgroundColor = {r=0.15, g=0.15, b=0.2, a=0.9}
    self.missionsList.borderColor = {r=0.4, g=0.4, b=0.5, a=1}
    self.missionsList:setOnMouseDownFunction(self, AmazoidMissionsPanel.onSelectMission)
    self.missionsList.doDrawItem = AmazoidMissionsPanel.drawMissionRow
    self.missionsList.parent = self
    self:addChild(self.missionsList)
    
    -- Mission details panel
    local detailsX = self.width / 2 + 5
    local detailsWidth = self.width / 2 - padding - 5
    
    self.detailsPanel = ISRichTextPanel:new(detailsX, y, detailsWidth, self.height - y - 60)
    self.detailsPanel:initialise()
    self.detailsPanel.backgroundColor = {r=0.12, g=0.12, b=0.18, a=0.9}
    self.detailsPanel.borderColor = {r=0.4, g=0.4, b=0.5, a=1}
    self.detailsPanel.marginLeft = 10
    self.detailsPanel.marginTop = 10
    self:addChild(self.detailsPanel)
    
    -- Accept / Abandon button
    self.actionBtn = ISButton:new(self.width - 130, self.height - 50, 120, 35, "Accept", self, AmazoidMissionsPanel.onAction)
    self.actionBtn:initialise()
    self.actionBtn:instantiate()
    self.actionBtn.enable = false
    self.actionBtn.backgroundColor = {r=0.2, g=0.4, b=0.2, a=0.8}
    self.actionBtn.backgroundColorMouseOver = {r=0.3, g=0.6, b=0.3, a=1}
    self:addChild(self.actionBtn)
    
    -- Initialize
    self.showingAvailable = true
    self.selectedMission = nil
    self:refreshMissions()
    self:updateTabButtons()
end

function AmazoidMissionsPanel:updateTabButtons()
    if self.showingAvailable then
        self.availableTabBtn.backgroundColor = {r=0.3, g=0.3, b=0.5, a=1}
        self.activeTabBtn.backgroundColor = {r=0.2, g=0.2, b=0.3, a=0.8}
        self.actionBtn:setTitle("Accept")
        self.actionBtn.backgroundColor = {r=0.2, g=0.4, b=0.2, a=0.8}
    else
        self.availableTabBtn.backgroundColor = {r=0.2, g=0.2, b=0.3, a=0.8}
        self.activeTabBtn.backgroundColor = {r=0.3, g=0.3, b=0.5, a=1}
        self.actionBtn:setTitle("Abandon")
        self.actionBtn.backgroundColor = {r=0.4, g=0.2, b=0.2, a=0.8}
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
    self.detailsPanel:setText("")
    
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
        self.detailsPanel:setText("")
        return
    end
    
    local mission = self.selectedMission
    local text = " <H2> " .. mission.title .. " <LINE> <LINE> "
    text = text .. " <SIZE:medium> "
    text = text .. (mission.description or "No description") .. " <LINE> <LINE> "
    
    -- Requirements
    text = text .. " <RGB:1,0.8,0.3> Requirements: <RGB:1,1,1> <LINE> "
    if mission.requirements then
        for key, value in pairs(mission.requirements) do
            if value then
                text = text .. "- " .. key .. ": " .. tostring(value) .. " <LINE> "
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
    if not self.showingAvailable and mission.progress then
        text = text .. " <LINE> <LINE> <RGB:0.3,0.8,1> Progress: " .. mission.progress .. " <RGB:1,1,1> "
    end
    
    self.detailsPanel:setText(text)
    self.detailsPanel:paginate()
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

--- Static function to show missions panel
---@param player IsoPlayer The player
function AmazoidMissionsPanel.showMissions(player)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = 650
    local height = 450
    local x = (screenW - width) / 2
    local y = (screenH - height) / 2
    
    local reputation = 0
    if Amazoid.Client then
        reputation = Amazoid.Client.getReputation()
    end
    
    local panel = AmazoidMissionsPanel:new(x, y, width, height, player, reputation)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    
    return panel
end

print("[Amazoid] Missions UI loaded")
