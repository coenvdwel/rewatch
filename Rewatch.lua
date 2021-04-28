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
		locked = false,
		combat = false,
		changed = true,
		clear = false,
		setup = false,
		debug = false,

		-- modules
		commands = nil,
		options = nil,
		profile = nil,
		frame = nil,
		players = {},
		spells = {},

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

	rewatch:Debug("Rewatch:Init")

	rewatch.guid = UnitGUID("player")
	rewatch.name = UnitName("player")
	rewatch.classId = select(3, UnitClass("player"))
	rewatch.spec = GetSpecialization()
	rewatch.setupFriends = { rewatch.name.."IsTheBest", "Great"..rewatch.name, rewatch.name.."BFF", "DznLoves"..rewatch.name }

	local classColor = RAID_CLASS_COLORS[select(2, GetClassInfo(rewatch.classId))]

	rewatch.color = { r = classColor.r, g = classColor.g, b = classColor.b }

	-- new users
	if(not rewatch_config) then

		rewatch:RaidMessage("Thank you for using Rewatch!")
		rewatch:Message("|cffff7c0aThank you for using Rewatch!|r")
		rewatch:Message("You can open the options menu using |cffff7c0a/rew|r.")
		rewatch:Message("Tip: be sure to check out mouse-over macros or Clique!")

		rewatch_config =
		{
			version = rewatch.version,
			position = { x = UIParent:GetWidth()/2-120, y = -UIParent:GetHeight()/4 },
			profiles = {},
			profile = {}
		}

	-- updating users
	elseif(rewatch_config.version < rewatch.version) then

		rewatch:Message("|cffff7c0aThank you for updating Rewatch!|r")
		rewatch_config.version = rewatch.version

	end

	-- modules
	rewatch.spells = RewatchSpells:new()
	rewatch.commands = RewatchCommands:new()
	rewatch.options = RewatchOptions:new()

	-- frame
	rewatch.frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	
	rewatch.frame:SetWidth(1)
	rewatch.frame:SetHeight(1)
	rewatch.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y)
	rewatch.frame:EnableMouse(true)
	rewatch.frame:SetMovable(true)
	rewatch.frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	rewatch.frame:SetBackdropColor(rewatch.color.r, rewatch.color.g, rewatch.color.b, 0)
	rewatch.frame:SetScript("OnEnter", function() rewatch.frame:SetBackdropColor(rewatch.color.r, rewatch.color.g, rewatch.color.b, 1) end)
	rewatch.frame:SetScript("OnLeave", function() rewatch.frame:SetBackdropColor(rewatch.color.r, rewatch.color.g, rewatch.color.b, 0) end)

	rewatch:Apply()

	rewatch.frame:SetScript("OnMouseDown", function(_, button)

		if(button == "LeftButton" and not rewatch.locked) then
			rewatch.frame:StartMoving()
		end
	
		if(button == "RightButton") then
			if(rewatch.locked) then
				rewatch.locked = false
				rewatch:Message("Unlocked frame")
			else
				rewatch.locked = true
				rewatch:Message("Locked frame")
			end
		end
	
	end)

	rewatch.frame:SetScript("OnMouseUp", function()
	
		rewatch.frame:StopMovingOrSizing()
	
		rewatch_config.position.x = rewatch.frame:GetLeft()
		rewatch_config.position.y = rewatch.frame:GetTop() - UIParent:GetHeight()
	
	end)

	-- events
	local lastUpdate, interval = 0, 1

	rewatch.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	rewatch.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	rewatch.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	rewatch.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	rewatch.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	rewatch.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	
	rewatch.frame:SetScript("OnEvent", function(_, event, unitGUID) rewatch:OnEvent(event, unitGUID) end)
	rewatch.frame:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed

		if(not rewatch.combat and lastUpdate > interval) then
			rewatch:OnUpdate()
			lastUpdate = 0
		end

	end)

end

-- display a debug message
function Rewatch:Debug(message)
	
	if(not rewatch.debug) then return end

	ChatFrame4:AddMessage("|cffff7c0aRw|r: "..GetTime().." "..message, 1, 1, 1)

end

-- display a message to the user in the chat pane
function Rewatch:Message(message)
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffff7c0aRw|r: "..message, 1, 1, 1)

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

	return value * (rewatch.options.profile.scaling/100)

end

-- pops up a tooltip for a player
function Rewatch:SetPlayerTooltip(name)

	if(not rewatch.options.profile.showTooltips) then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(name)

end

-- pops up a tooltip for a spell
function Rewatch:SetSpellTooltip(name)

	if(not rewatch.options.profile.showTooltips) then return end

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

	rewatch:Debug("Rewatch:NewId")

	return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function (c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)

end

-- calculate frame size
function Rewatch:Apply()

	rewatch:Debug("Rewatch:Apply")

	local buttonCount, barCount = 0, 0

	for _ in ipairs(rewatch.options.profile.buttons) do buttonCount = buttonCount + 1 end
	for _ in ipairs(rewatch.options.profile.bars) do barCount = barCount + 1 end

	-- recalculate total frame sizes
	if(rewatch.options.profile.layout == "horizontal") then
	
		rewatch.buttonSize = rewatch:Scale(rewatch.options.profile.spellBarWidth / buttonCount)
		rewatch.playerWidth = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		rewatch.playerHeight = rewatch:Scale(rewatch.options.profile.healthBarHeight + (rewatch.options.profile.spellBarHeight * barCount)) + rewatch.buttonSize * (rewatch.options.profile.showButtons and 1 or 0)

	elseif(rewatch.options.profile.layout == "vertical") then
		
		rewatch.buttonSize = rewatch:Scale(rewatch.options.profile.healthBarHeight / buttonCount)
		rewatch.playerHeight = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		rewatch.playerWidth = rewatch:Scale(rewatch.options.profile.healthBarHeight + (rewatch.options.profile.spellBarHeight * barCount))

	end

end

-- render everything
function Rewatch:Render()

	rewatch:Debug("Rewatch:Render")

	local playerCount = 0

	for _ in pairs(rewatch.players) do playerCount = playerCount + 1 end

	-- set frame dimensions
	if(rewatch.options.profile.grow == "down") then
		rewatch.frame:SetHeight(rewatch:Scale(10) + (math.min(rewatch.options.profile.numFramesWide, math.max(playerCount, 1)) * rewatch.playerHeight))
		rewatch.frame:SetWidth(math.ceil(playerCount/rewatch.options.profile.numFramesWide) * rewatch.playerWidth)
	else
		rewatch.frame:SetHeight(rewatch:Scale(10) + (math.ceil(playerCount/rewatch.options.profile.numFramesWide) * rewatch.playerHeight))
		rewatch.frame:SetWidth(math.min(rewatch.options.profile.numFramesWide, math.max(playerCount, 1)) * rewatch.playerWidth)
	end
	
	-- set frame position
	rewatch.frame:ClearAllPoints()
	rewatch.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y)

	-- show/hide
	if(rewatch.options.profile.hide) then rewatch.frame:Hide() else rewatch.frame:Show() end

end

-- process frame clear
function Rewatch:Clear()

	if(rewatch.combat) then
		rewatch.clear = true
		return
	end

	rewatch.clear = false

	for guid in pairs(rewatch.players) do
		rewatch.players[guid]:Dispose()
		rewatch.players[guid] = nil
	end

	rewatch:Apply()
	rewatch:UpdateGroup()

end

-- process group update
function Rewatch:UpdateGroup()

	if(rewatch.combat) then
		rewatch.changed = true
		return
	end

	rewatch.changed = false

	-- get all players in group
	local playerLookup = {}
	local roleLookup = { TANK = {}, HEALER = {}, DAMAGER = {}, NONE = {} }
	local env = IsInRaid() and "RAID" or "PARTY"

	for i = 1, GetNumGroupMembers() do

		local guid = UnitGUID(env..i)
		local name = UnitName(env..i)

		if(not guid) then break end
		if(name == UNKNOWNOBJECT) then break end

		if(guid ~= rewatch.guid) then
			playerLookup[guid] = name
			local role = UnitGroupRolesAssigned(env..i)
			table.insert(roleLookup[role], guid)
		end
	end

	-- delete those in our frames but no longer in our group
	local remove = {}

	for guid in pairs(rewatch.players) do
		if(guid ~= rewatch.guid and not playerLookup[guid]) then
			table.insert(remove, guid)
		end
	end

	for _, guid in ipairs(remove) do
		if(not rewatch.setup or not rewatch.players[guid].dummy) then
			rewatch.players[guid]:Dispose()
			rewatch.players[guid] = nil
		end
	end

	-- process players & positions to our frames
	local position = 1
	local process = function(guid, name)

		if(not rewatch.players[guid]) then
			rewatch.players[guid] = RewatchPlayer:new(guid, name or playerLookup[guid], position)
		else
			rewatch.players[guid]:MoveTo(position)
		end

		position = position + 1

	end

	process(rewatch.guid, rewatch.name)

	for _, guid in ipairs(roleLookup.TANK) do process(guid) end
	for _, guid in ipairs(roleLookup.HEALER) do process(guid) end
	for _, guid in ipairs(roleLookup.DAMAGER) do process(guid) end
	for _, guid in ipairs(roleLookup.NONE) do process(guid) end

	if(rewatch.setup) then
		for _, name in ipairs(rewatch.setupFriends) do process(name, name) end
	end

	rewatch:Render()

	rewatch.options:AutoActivateProfile()

end

-- event handler
function Rewatch:OnEvent(event, unitGUID)

	if(event == "PLAYER_REGEN_ENABLED") then rewatch.combat = false
	elseif(event == "PLAYER_REGEN_DISABLED") then rewatch.combat = true
	elseif(event == "PLAYER_SPECIALIZATION_CHANGED" and unitGUID == "player") then rewatch.spec = GetSpecialization(); rewatch.clear = true
	elseif(event == "ACTIVE_TALENT_GROUP_CHANGED" and unitGUID == "player") then rewatch.spec = GetSpecialization(); rewatch.clear = true
	elseif(event == "GROUP_ROSTER_UPDATE") then rewatch.changed = true
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		
		local _, effect, _, sourceGUID, _, _, _, targetGUID, targetName, _, _, _, spellName = CombatLogGetCurrentEventInfo()
		
		if(not sourceGUID) then return end
		if(not targetGUID) then return end
		if(sourceGUID ~= rewatch.guid) then return end
		if(sourceGUID == targetGUID) then return end

		if(effect == "SPELL_AURA_APPLIED_DOSE" or effect == "SPELL_AURA_APPLIED" or effect == "SPELL_AURA_REFRESH") then

			if(spellName == rewatch.spells:Name("Innervate")) then
				rewatch:Announce("innervating", targetName)
			end

		elseif(effect == "SPELL_CAST_START" and rewatch.rezzing and rewatch.spells:IsRez(spellName)) then

			rewatch:Announce("rezzing", rewatch.rezzing)
			rewatch.rezzing = nil
			
		end

	end

end

-- update handler
function Rewatch:OnUpdate()

	if(rewatch.clear) then rewatch:Clear() end
	if(rewatch.changed) then rewatch:UpdateGroup() end

end