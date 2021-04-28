RewatchPlayer = {}
RewatchPlayer.__index = RewatchPlayer

function RewatchPlayer:new(guid, name, position)
	
	local dummy = guid == name

	local classId = dummy and math.random(12) or select(3, UnitClass(name))
	local classColor = RAID_CLASS_COLORS[select(2, GetClassInfo(classId))]

	local self =
	{
		frame = CreateFrame("Frame", nil, rewatch.frame, BackdropTemplateMixin and "BackdropTemplate"),
		width = nil,
		height = nil,

		guid = guid,
		name = name,
		classId = classId,
		position = position,
		color = { r = classColor.r, g = classColor.g, b = classColor.b },
		dead = false,
		dummy = dummy,

		health = nil,
		healthBackdrop = nil,
		incomingHealth = nil,
		role = nil,
		mana = nil,
		border = nil,
		
		bars = {},
		buttons = {},
		debuffs = {},
	}

	rewatch:Debug("RewatchPlayer:new")

	setmetatable(self, RewatchPlayer)

	local roleSize = rewatch:Scale(5)

	if(rewatch.options.profile.layout == "horizontal") then
		self.width = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		self.height = rewatch:Scale(rewatch.options.profile.healthBarHeight - rewatch.options.profile.manaBarHeight)
	elseif(rewatch.options.profile.layout == "vertical") then
		self.width = rewatch:Scale(rewatch.options.profile.healthBarHeight)
		self.height = rewatch:Scale(rewatch.options.profile.spellBarWidth - rewatch.options.profile.manaBarHeight) - (rewatch.options.profile.showButtons and rewatch.buttonSize or 0)
	end

	-- frame
	self.frame:SetWidth(rewatch.playerWidth)
	self.frame:SetHeight(rewatch.playerHeight)
	self.frame:SetPoint("TOPLEFT", rewatch.frame, "TOPLEFT", 0, 0)
	self.frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	self.frame:SetBackdropColor(0.07, 0.07, 0.07, 1)
	
	self:MoveTo(position)

	-- health backdrop
	self.healthBackdrop = CreateFrame("Frame", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")
	self.healthBackdrop:SetWidth(self.width)
	self.healthBackdrop:SetHeight(self.height)
	self.healthBackdrop:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.healthBackdrop:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	self.healthBackdrop:SetBackdropColor(self.color.r, self.color.g, self.color.b, 0.2)
	self.healthBackdrop:SetFrameLevel(9)

	-- incoming health
	self.incomingHealth = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")
	self.incomingHealth:SetWidth(self.width)
	self.incomingHealth:SetHeight(self.height)
	self.incomingHealth:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.incomingHealth:SetStatusBarTexture(rewatch.options.profile.bar)
	self.incomingHealth:GetStatusBarTexture():SetHorizTile(false)
	self.incomingHealth:GetStatusBarTexture():SetVertTile(false)
	self.incomingHealth:SetStatusBarColor(0.4, 1, 0.4, 1)
	self.incomingHealth:SetMinMaxValues(0, 1)
	self.incomingHealth:SetValue(0)
	self.incomingHealth:SetFrameLevel(10)

	-- health bar
	self.health = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")
	self.health:SetWidth(self.width)
	self.health:SetHeight(self.height)
	self.health:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.health:SetStatusBarTexture(rewatch.options.profile.bar)
	self.health:GetStatusBarTexture():SetHorizTile(false)
	self.health:GetStatusBarTexture():SetVertTile(false)
	self.health:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 1)
	self.health:SetMinMaxValues(0, 1)
	self.health:SetValue(0)
	self.health:SetFrameLevel(20)
	self.health.text = self.health:CreateFontString("$parentText", "ARTWORK")
	self.health.text:SetFont(rewatch.options.profile.font, rewatch:Scale(rewatch.options.profile.fontSize))
	self.health.text:SetAllPoints()
	self.health.text:SetTextColor(1, 1, 1, 1)
	self.health.text:SetText(self.name)

	-- role icon
	self.role = self.health:CreateTexture(nil, "OVERLAY")
	self.role:SetTexture("Interface\\LFGFrame\\LFGRole")
	self.role:SetSize(roleSize, roleSize)
	self.role:SetPoint("TOPLEFT", self.health, "TOPLEFT", roleSize, (roleSize-self.height)/2)

	self:SetRole()

	-- mana bar
	self.mana = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")
	self.mana:SetPoint("TOPLEFT", self.health, "BOTTOMLEFT", 0, 0)
	self.mana:SetStatusBarTexture(rewatch.options.profile.bar)
	self.mana:GetStatusBarTexture():SetHorizTile(false)
	self.mana:GetStatusBarTexture():SetVertTile(false)
	self.mana:SetMinMaxValues(0, 1)
	self.mana:SetValue(0)

	if(rewatch.options.profile.layout == "horizontal") then
		self.mana:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.mana:SetHeight(rewatch:Scale(rewatch.options.profile.manaBarHeight))
	elseif(rewatch.options.profile.layout == "vertical") then
		self.mana:SetWidth(rewatch:Scale(rewatch.options.profile.healthBarHeight))
		self.mana:SetHeight(rewatch:Scale(rewatch.options.profile.manaBarHeight))
	end
	
	self:SetPower()

	-- spell bars
	local anchor = rewatch.options.profile.layout == "horizontal" and self.mana or self.health

	for i,spell in ipairs(rewatch.options.profile.bars) do

		if(GetSpellInfo(spell)) then
			self.bars[spell] = RewatchBar:new(spell, self, anchor, i)
			anchor = self.bars[spell].bar
		end

	end
	
	-- spell buttons
	if(rewatch.options.profile.showButtons) then

		if(rewatch.options.profile.layout == "vertical") then anchor = self.mana end

		for i,spell in ipairs(rewatch.options.profile.buttons) do

			if(rewatch.classId == 2 and rewatch.spec ~= 1) then
				if(spell == rewatch.spells:Name("Cleanse")) then spell = rewatch.spells:Name("Cleanse Toxins") end
			elseif(rewatch.classId == 5 and rewatch.spec == 3) then
				if(spell == rewatch.spells:Name("Purify")) then spell = rewatch.spells:Name("Purify Disease") end
			elseif(rewatch.classId == 7 and rewatch.spec ~= 3) then
				if(spell == rewatch.spells:Name("Purify Spirit")) then spell = rewatch.spells:Name("Cleanse Spirit") end
			elseif(rewatch.classId == 11 and rewatch.spec ~= 4) then
				if(spell == rewatch.spells:Name("Nature's Cure")) then spell = rewatch.spells:Name("Remove Corruption") end
				if(spell == rewatch.spells:Name("Ironbark")) then spell = rewatch.spells:Name("Barkskin") end
			end

			self.buttons[spell] = RewatchButton:new(spell, self, anchor, i)

		end
	end
	
	-- overlay target/remove button
	local overlay = CreateFrame("BUTTON", nil, self.health, "SecureActionButtonTemplate")

	overlay:SetWidth(self.width)
	overlay:SetHeight(self.height + rewatch:Scale(rewatch.options.profile.manaBarHeight))
	overlay:SetPoint("TOPLEFT", self.health, "TOPLEFT", 0, 0)
	overlay:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp")
	overlay:SetAlpha(0.05)
	overlay:SetAttribute("type1", "target")
	overlay:SetAttribute("unit", self.name)
	overlay:SetAttribute("alt-type1", "macro")
	overlay:SetAttribute("alt-macrotext1", rewatch.options.profile.altMacro)
	overlay:SetAttribute("ctrl-type1", "macro")
	overlay:SetAttribute("ctrl-macrotext1", rewatch.options.profile.ctrlMacro)
	overlay:SetAttribute("shift-type1", "macro")
	overlay:SetAttribute("shift-macrotext1", rewatch.options.profile.shiftMacro)
	overlay:SetScript("OnEnter", function() self.hover = 1; rewatch:SetPlayerTooltip(self.name) end)
	overlay:SetScript("OnLeave", function() self.hover = 2; GameTooltip:Hide() end)
	
	-- border
	self.border = CreateFrame("FRAME", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")
	self.border:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1 })
	self.border:SetBackdropBorderColor(0, 0, 0, 1)
	self.border:SetWidth(rewatch.playerWidth+1)
	self.border:SetHeight(rewatch.playerHeight+1)
	self.border:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.border:SetFrameLevel(10000)

	-- events
	local lastUpdate, interval, lastUpdateSlow, intervalSlow = 0, 1/20, 0, 1

	self.frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.frame:RegisterEvent("UNIT_DISPLAYPOWER")

	self.frame:SetScript("OnEvent", function(_, event, unitGUID) self:OnEvent(event, unitGUID) end)
	self.frame:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed
		if lastUpdate > interval then self:OnUpdate(); lastUpdate = 0 end

		lastUpdateSlow = lastUpdateSlow + elapsed
		if lastUpdateSlow > intervalSlow then self:OnUpdateSlow(); lastUpdateSlow = 0 end
	
	end)

	-- inject in lookup
	rewatch.players[self.guid] = self

	return self

end

-- move to position
function RewatchPlayer:MoveTo(position)

	rewatch:Debug("RewatchPlayer:MoveTo")

	local div = math.floor((position-1) / rewatch.options.profile.numFramesWide)
	local mod = (position-1) % rewatch.options.profile.numFramesWide
	local x = div
	local y = mod

	if(rewatch.options.profile.grow ~= "down") then x = mod; y = div end

	self.frame:SetPoint("TOPLEFT", rewatch.frame, "TOPLEFT", x * rewatch.playerWidth, y * -rewatch.playerHeight)
	
end

-- set mana/power bar color
function RewatchPlayer:SetPower()

	rewatch:Debug("RewatchPlayer:SetPower")

	local powerType = UnitPowerType(self.name)

	if(powerType == 0 or powerType == "MANA") then self.mana:SetStatusBarColor(0.24, 0.35, 0.49)
	elseif(powerType == 1 or powerType == "RAGE") then self.mana:SetStatusBarColor(0.52, 0.17, 0.17)
	elseif(powerType == 3 or powerType == "ENERGY") then self.mana:SetStatusBarColor(0.5, 0.48, 0.27)
	else 
		local color = PowerBarColor[powerType]
		self.mana:SetStatusBarColor(color.r, color.g, color.b)
	end

end

-- update role icon
function RewatchPlayer:SetRole()

	rewatch:Debug("RewatchPlayer:SetRole")
	
	local role = UnitGroupRolesAssigned(self.name)

	if(role == "TANK" or role == "HEALER") then
		self.role:SetTexCoord(GetTexCoordsForRoleSmall(role))
		self.role:Show()
	else
		self.role:Hide()
	end

end

-- update debuffs
function RewatchPlayer:SetDebuff(spell)

	rewatch:Debug("RewatchPlayer:SetDebuff")

	for _,debuff in pairs(self.debuffs) do
		if(not debuff.active or debuff.spell == spell) then
			debuff:Up(spell)
			return
		end
	end

	table.insert(self.debuffs, RewatchDebuff:new(self, spell, #self.debuffs))

end

-- remove debuff
function RewatchPlayer:RemoveDebuff(spell)

	rewatch:Debug("RewatchPlayer:RemoveDebuff")

	for _,debuff in pairs(self.debuffs) do
		if(debuff.active and debuff.spell == spell) then
			debuff:Down()
			return
		end
	end
	
end

-- event handler
function RewatchPlayer:OnEvent(event, unitGUID)

	-- update threat
	if(event == "UNIT_THREAT_SITUATION_UPDATE") then

		if(UnitGUID(unitGUID) ~= self.guid) then return end

		local threat = UnitThreatSituation(self.name)

		if((threat or 0) == 0) then
			self.border:SetBackdropBorderColor(0, 0, 0, 1)
			self.border:SetFrameLevel(10000)
		else
			local r, g, b = GetThreatStatusColor(threat)
			self.border:SetBackdropBorderColor(r, g, b, 1)
			self.border:SetFrameLevel(10001)
		end

	-- changed role
	elseif(event == "PLAYER_ROLES_ASSIGNED") then
	
		self:SetRole()

	-- shapeshift
	elseif(event == "UNIT_DISPLAYPOWER") then

		self:SetPower()

	-- player was the target of by some combat event
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then

		local _, effect, _, _, _, _, _, targetGUID, _, _, _, _, spellName, _, auraType = CombatLogGetCurrentEventInfo()
		
		if(not targetGUID) then return end
		if(targetGUID ~= self.guid) then return end
		if(auraType ~= "DEBUFF") then return end

		if(effect == "SPELL_AURA_APPLIED_DOSE" or effect == "SPELL_AURA_APPLIED" or effect == "SPELL_AURA_REFRESH") then
			
			self:SetDebuff(spellName)

		elseif(effect == "SPELL_AURA_REMOVED" or effect == "SPELL_AURA_DISPELLED" or effect == "SPELL_AURA_REMOVED_DOSE") then
			
			self:RemoveDebuff(spellName)

		end
	end

end

-- update handler
function RewatchPlayer:OnUpdate()

	if(self.dead) then return end
	if(not self.frame) then return end

	-- health
	local currentTime = GetTime()
	local maxHealth = UnitHealthMax(self.name)
	local health = UnitHealth(self.name)
	local incomingHealth = UnitGetIncomingHeals(self.name) or 0
	local percentage = health/maxHealth

	if(self.dummy) then
		health = 1
		maxHealth = 1
		percentage = 1
	end

	self.health:SetMinMaxValues(0, maxHealth)
	self.health:SetValue(health)
	self.incomingHealth:SetMinMaxValues(0, maxHealth)
	self.incomingHealth:SetValue(math.min(health + incomingHealth, maxHealth))

	-- color
	if(percentage > 0.75) then
		self.health:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 1)
	elseif(percentage < 0.5) then
		self.health:SetStatusBarColor(1, percentage * 2, 0, 1)
	else
		percentage = (percentage * 4) - 2
		self.health:SetStatusBarColor(1 + (self.color.r-1)*percentage, 1 + (self.color.g-1)*percentage, self.color.b*percentage, 1)
	end

	-- hover
	if(self.hover == 1) then
		self.health.text:SetText(string.format("%i/%i", health, maxHealth))
	elseif(self.hover == 2) then
		self.health.text:SetText(self.name)
		self.hover = 0
	end

	-- power
	local power = UnitPower(self.name)
	local maxPower = UnitPowerMax(self.name)
	
	if(self.dummy) then
		power = 1
		maxPower = 1
	end

	self.mana:SetMinMaxValues(0, maxPower)
	self.mana:SetValue(power)

end

-- update handler for 'slower' parts
function RewatchPlayer:OnUpdateSlow()

	if(not self.frame) then return end

	-- death
	if(UnitIsDeadOrGhost(self.name)) then

		if(not self.dead) then

			self.dead = true
			self.health:SetValue(0)
			self.mana:SetValue(0)
			self.incomingHealth:SetValue(0)
			self.border:SetBackdropBorderColor(0, 0, 0, 1)
			self.border:SetFrameLevel(10000)
			self.frame:SetAlpha(0.2)

			for _,bar in pairs(self.bars) do bar:Down() end
			for _,button in pairs(self.buttons) do button:SetAlpha() end
			for _,debuff in pairs(self.debuffs) do debuff:Down() end

		end

		return

	end

	-- aliiiiiiive
	if(self.dead) then

		self.dead = false

		for _,button in pairs(self.buttons) do button:SetAlpha() end

	end

	-- fade when out of range
	if(not rewatch.options.profile.spell or IsSpellInRange(rewatch.options.profile.spell, self.name) == 1 or self.dummy) then
		self.frame:SetAlpha(1)
		self.incomingHealth:SetAlpha(1)
	else
		self.frame:SetAlpha(0.5)
		self.incomingHealth:SetAlpha(0)
	end

end

-- dispose
function RewatchPlayer:Dispose()

	rewatch:Debug("RewatchPlayer:Dispose")

	self.frame:UnregisterAllEvents()
	self.frame:Hide()

	for _,bar in pairs(self.bars) do bar:Dispose() end
	for _,button in pairs(self.buttons) do button:Dispose() end
	for _,debuff in pairs(self.debuffs) do debuff:Dispose() end

	self.frame = nil
	self.healthBackdrop = nil
	self.incomingHealth = nil
	self.health = nil
	self.role = nil
	self.mana = nil
	self.border = nil
	self.bars = {}
	self.buttons = {}
	self.debuffs = {}

end