-- display a message to the user in the chat pane
rewatch.Message = function(self, message)
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffff7d0aRw|r: "..message, 1, 1, 1)

end

-- displays a message to the user in the raidwarning frame
rewatch.RaidMessage = function(self, message)

	RaidNotice_AddMessage(RaidWarningFrame, message, { r = 1, g = 0.49, b = 0.04 })

end

-- announce an action to the chat, preferring SAY but falling back to EMOTE & WHISPER
rewatch.Announce = function(self, action, playerName)

	if(select(1, IsInInstance())) then
		SendChatMessage("I'm "..action.." "..playerName.."!", "SAY")
	else
		SendChatMessage("is "..action.." "..playerName.."!", "EMOTE")
		SendChatMessage("I'm "..action.." you!", "WHISPER", nil, playerName)
	end

end

-- return a scaled config value
rewatch.Scale = function(self, value)

	return value * (rewatch.options.profile.scaling/100)

end

-- get the corresponding colour for the power type
rewatch.GetPowerBarColor = function(self, powerType)

	-- prettier colors!
	if(powerType == 0 or powerType == "MANA") then return { r = 0.24, g = 0.35, b = 0.49 } end
	if(powerType == 1 or powerType == "RAGE") then return { r = 0.52, g = 0.17, b = 0.17 } end
	if(powerType == 3 or powerType == "ENERGY") then return { r = 0.5, g = 0.48, b = 0.27 } end
	
	-- return boring standard colors
	return PowerBarColor[powerType]
	
end

-- pops up a tooltip for a player
rewatch.SetPlayerTooltip = function(self, name)
	
	if(not rewatch.options.profile.showTooltips) then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(name)

end

-- pops up a tooltip for a spell
rewatch.SetSpellTooltip = function(self, name)

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
rewatch.NewId = function(self)

    return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)

end

-- calculate frame size
rewatch.Apply = function(self)

    local buttonCount, barCount = 0, 0
	
	for _ in pairs(rewatch.options.profile.buttons) do buttonCount = buttonCount + 1 end
	for _ in pairs(rewatch.options.profile.bars) do barCount = barCount + 1 end

	-- recalculate total frame sizes
	if(rewatch.options.profile.layout == "horizontal") then
	
		rewatch.playerWidth = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		rewatch.playerHeight = rewatch:Scale(rewatch.options.profile.healthBarHeight + (rewatch.options.profile.spellBarHeight * barCount) + rewatch.buttonSize * rewatch.options.profile.showButtons)
		rewatch.buttonSize = rewatch:Scale(rewatch.options.profile.spellBarWidth / buttonCount)

	elseif(rewatch.options.profile.layout == "vertical") then
		
		rewatch.playerHeight = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		rewatch.playerWidth = rewatch:Scale(rewatch.options.profile.healthBarHeight + (rewatch.options.profile.spellBarHeight * barCount))
        rewatch.buttonSize = rewatch:Scale(rewatch.options.profile.healthBarHeight / buttonCount)

	end

end

-- render everything
rewatch.Render = function(self)

	local playerCount = 0

	for _ in pairs(rewatch.players) do playerCount = playerCount + 1 end

	-- set frame dimensions
	if(rewatch.options.profile.frameColumns) then

		rewatch.frame:SetHeight(rewatch:Scale(10) + (math.min(rewatch.options.profile.numFramesWide, math.max(playerCount, 1)) * rewatch.playerHeight))
		rewatch.frame:SetWidth(1 + (math.ceil(playerCount/rewatch.options.profile.numFramesWide) * rewatch.playerWidth))

	else

		rewatch.frame:SetHeight(rewatch:Scale(10) + (math.ceil(playerCount/rewatch.options.profile.numFramesWide) * rewatch.playerHeight))
		rewatch.frame:SetWidth(1 + (math.min(rewatch.options.profile.numFramesWide, math.max(playerCount, 1)) * rewatch.playerWidth))

	end
	
	-- set frame position
	rewatch.frame:ClearAllPoints()
	rewatch.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y-UIParent:GetHeight())

end

-- compares the current player table to the party/raid schedule
rewatch.ProcessGroup = function(self)

	if(rewatch.inCombat) then return end

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

	for guid in pairs(rewatch.players) do
		if(guid ~= rewatch.guid and not playerLookup[guid]) then
			table.insert(remove, guid)
		end
	end

	for _, guid in ipairs(remove) do
		rewatch.players[guid]:Dispose()
		rewatch.players[guid] = nil
	end

	-- process players & positions to our frames
	local position = 1

	local process = function(guid, name)

		if(not rewatch.players[guid]) then
			rewatch.players[guid] = RewatchPlayer:new(guid, name or playerLookup[guid], position)
		else
			rewatch.player[guid]:MoveTo(position)
		end

		position = position + 1

	end

	process(rewatch.guid, rewatch.name)

	for _, guid in ipairs(playerList.TANK) do process(guid) end
	for _, guid in ipairs(playerList.HEALER) do process(guid) end
	for _, guid in ipairs(playerList.DAMAGER) do process(guid) end
	for _, guid in ipairs(playerList.NONE) do process(guid) end
	
	rewatch:Render()

end