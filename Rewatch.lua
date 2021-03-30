Rewatch = {}
Rewatch.__index = Rewatch

function Rewatch:new()
	
	local self =
    {
		version = 80000,

		-- player variables
		guid = nil,
		name = nil,
		classId = nil,
		spec = nil,

		-- flags
		loaded = false,
		locked = false,
		inCombat = false,
		changed = true,

		-- modules
		commands = nil,
		options = nil,
		profile = nil,
		frame = nil,
		players = {},
		locale = {},

		-- other
		playerWidth = nil,
		playerHeight = nil,
		buttonSize = nil,
		rezzing = nil
	}

	setmetatable(self, Rewatch)

	return self

end

function Rewatch:Init()

	self.guid = UnitGUID("player")
	self.name = UnitName("player")
	self.classId = select(3, UnitClass("player"))
	self.spec = GetSpecialization()

	if(not self.guid) then return end

	self.loaded = true

	-- new users
	if(not rewatch_config) then

		self:RaidMessage("Thank you for using Rewatch!")
		self:Message("|cffff7d0aThank you for using Rewatch!|r")
		self:Message("You can open the options menu using |cffff7d0a/rewatch options|r.")
		self:Message("Tip: be sure to check out mouse-over macros or Clique!")

		rewatch_config =
		{
			version = self.version,
			position = { x = UIParent:GetWidth()/2-120, y = -UIParent:GetHeight()/4 },
			profiles = {},
			profile = {}
		}

	-- updating users
	elseif(rewatch_config.version < self.version) then

		self:Message("|cffff7d0aThank you for updating Rewatch!|r")
		rewatch_config.version = self.version

	end
	
	-- modules
	self.locale = self:Locale()
	self.commands = RewatchCommands:new()
	self.options = RewatchOptions:new()

	-- frame
	self.frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	
	self.frame:SetWidth(1)
	self.frame:SetHeight(1)
	self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y)
	self.frame:EnableMouse(true)
	self.frame:SetMovable(true)
	self.frame:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	self.frame:SetBackdropColor(1, 0.49, 0.04, 0)
	self.frame:SetScript("OnEnter", function() self.frame:SetBackdropColor(1, 0.49, 0.04, 1) end)
	self.frame:SetScript("OnLeave", function() self.frame:SetBackdropColor(1, 0.49, 0.04, 0) end)

	self:Apply()

	self.frame:SetScript("OnMouseDown", function(_, button)

		if(button == "LeftButton" and not self.locked) then
			self.frame:StartMoving()
		end
	
		if(button == "RightButton") then
			if(self.locked) then
				self.locked = false
				self:Message("Unlocked frame")
			else
				self.locked = true
				self:Message("Locked frame")
			end
		end
	
	end)

	self.frame:SetScript("OnMouseUp", function()
	
		self.frame:StopMovingOrSizing()
	
		rewatch_config.position.x = self.frame:GetLeft()
		rewatch_config.position.y = self.frame:GetTop() - UIParent:GetHeight()
	
	end)

	-- events
	local lastUpdate, interval = 0, 1

	self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.frame:SetScript("OnEvent", function(_, event, unitGUID) self:OnEvent(event, unitGUID) end)
	self.frame:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed;

		if lastUpdate > interval then
			self:OnUpdate();
			lastUpdate = 0
		end;

	end)

end

-- display a message to the user in the chat pane
function Rewatch:Message(message)
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffff7d0aRw|r: "..message, 1, 1, 1)

end

-- displays a message to the user in the raidwarning frame
function Rewatch:RaidMessage(message)

	RaidNotice_AddMessage(RaidWarningFrame, message, { r = 1, g = 0.49, b = 0.04 })

end

-- announce an action to the chat, preferring SAY but falling back to EMOTE & WHISPER
function Rewatch:Announce(action, playerName)

	if(select(1, IsInInstance())) then
		SendChatMessage("I'm "..action.." "..playerName.."!", "SAY")
	else
		SendChatMessage("is "..action.." "..playerName.."!", "EMOTE")
		SendChatMessage("I'm "..action.." you!", "WHISPER", nil, playerName)
	end

end

-- return a scaled config value
function Rewatch:Scale(value)

	return value * (self.options.profile.scaling/100)

end

-- pops up a tooltip for a player
function Rewatch:SetPlayerTooltip(name)
	
	if(not self.options.profile.showTooltips) then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(name)

end

-- pops up a tooltip for a spell
function Rewatch:SetSpellTooltip(name)

	if(not self.options.profile.showTooltips) then return end

	local spellId, found = 1, false

	while not found do
	   local spell = GetSpellBookItemName(spellId, BOOKTYPE_SPELL)
	   if (not spell) then break end
	   if (spell == name) then found = true break end
	   spellId = spellId + 1
	end

	if(found) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetSpellBookItem(spellId, BOOKTYPE_SPELL)
	end

end

-- generate a random new uuid
function Rewatch:NewId()

    return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)

end

-- calculate frame size
function Rewatch:Apply()

    local buttonCount, barCount = 0, 0
	
	for _ in ipairs(self.options.profile.buttons) do buttonCount = buttonCount + 1 end
	for _ in ipairs(self.options.profile.bars) do barCount = barCount + 1 end

	-- recalculate total frame sizes
	if(self.options.profile.layout == "horizontal") then
	
		self.playerWidth = self:Scale(self.options.profile.spellBarWidth)
		self.playerHeight = self:Scale(self.options.profile.healthBarHeight + (self.options.profile.spellBarHeight * barCount) + self.buttonSize * self.options.profile.showButtons)
		self.buttonSize = self:Scale(self.options.profile.spellBarWidth / buttonCount)

	elseif(self.options.profile.layout == "vertical") then
		
		self.playerHeight = self:Scale(self.options.profile.spellBarWidth)
		self.playerWidth = self:Scale(self.options.profile.healthBarHeight + (self.options.profile.spellBarHeight * barCount))
        self.buttonSize = self:Scale(self.options.profile.healthBarHeight / buttonCount)

	end

end

-- render everything
function Rewatch:Render()

	local playerCount = 0

	for _ in pairs(self.players) do playerCount = playerCount + 1 end

	-- set frame dimensions
	if(self.options.profile.grow == "down") then
		self.frame:SetHeight(self:Scale(10) + (math.min(self.options.profile.numFramesWide, math.max(playerCount, 1)) * self.playerHeight))
		self.frame:SetWidth(math.ceil(playerCount/self.options.profile.numFramesWide) * self.playerWidth)
	else
		self.frame:SetHeight(self:Scale(10) + (math.ceil(playerCount/self.options.profile.numFramesWide) * self.playerHeight))
		self.frame:SetWidth(math.min(self.options.profile.numFramesWide, math.max(playerCount, 1)) * self.playerWidth)
	end
	
	-- set frame position
	self.frame:ClearAllPoints()
	self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y)

end

-- event handler
function Rewatch:OnEvent(event)

	if(event == "PLAYER_REGEN_ENABLED") then self.inCombat = false
	elseif(event == "PLAYER_REGEN_DISABLED") then self.inCombat = true
	elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then self.spec = GetSpecialization()
	elseif(event == "ACTIVE_TALENT_GROUP_CHANGED") then self.spec = GetSpecialization()
	elseif(event == "GROUP_ROSTER_UPDATE") then self.changed = true
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then

		local _, effect, _, sourceGUID, _, _, _, targetGUID, targetName, _, _, _, spellName, _, school = CombatLogGetCurrentEventInfo()
		
		if(not sourceGUID) then return end
		if(not targetGUID) then return end
		if(sourceGUID ~= rewatch.guid) then return end
		if(sourceGUID == targetGUID) then return end

		if((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then

			if(spellName == rewatch.locale["innervate"]) then
				rewatch_Announce("innervating", targetName)
			end

		elseif(effect == "SPELL_CAST_START") then

			if((spellName == rewatch.locale["rebirth"]) or (spellName == rewatch.locale["revive"])) then
				if(rewatch.rezzing) then
					rewatch_Announce("rezzing", rewatch.rezzing)
				end
			end

		end

	end

end

-- update handler
function Rewatch:OnUpdate()

	if(self.inCombat) then return end
	if(not self.changed) then return end

	self.changed = false

	-- gather the players in our group
	local playerList = { TANK = {}, HEALER = {}, DAMAGER = {}, NONE = {} }
	local playerLookup = {}
	local env = IsInRaid() and "RAID" or "PARTY"

	for i = 1, GetNumGroupMembers() do

		local guid = UnitGUID(env..i)
		local name = UnitName(env..i)

		if(not guid) then break end

		playerLookup[guid] = name

		local role = UnitGroupRolesAssigned(env..i)

		table.insert(playerList[role], guid)

	end

	-- delete those in our frames but no longer in our group
	local remove = {}

	for guid in pairs(self.players) do
		if(guid ~= self.guid and not playerLookup[guid]) then
			table.insert(remove, guid)
		end
	end

	for _, guid in ipairs(remove) do
		self.players[guid]:Dispose()
		self.players[guid] = nil
	end

	-- process players & positions to our frames
	local position = 1

	local process = function(guid, name)

		if(not self.players[guid]) then
			self.players[guid] = RewatchPlayer:new(guid, name or playerLookup[guid], position)
		else
			self.player[guid]:MoveTo(position)
		end

		position = position + 1

	end

	process(self.guid, self.name)

	for _, guid in ipairs(playerList.TANK) do process(guid) end
	for _, guid in ipairs(playerList.HEALER) do process(guid) end
	for _, guid in ipairs(playerList.DAMAGER) do process(guid) end
	for _, guid in ipairs(playerList.NONE) do process(guid) end
	
	self:Render()

end