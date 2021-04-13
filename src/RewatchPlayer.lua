RewatchPlayer = {}
RewatchPlayer.__index = RewatchPlayer

function RewatchPlayer:new(guid, name, position)
	
	local self =
    {
        frame = CreateFrame("Frame", nil, rewatch.frame, BackdropTemplateMixin and "BackdropTemplate"),

		guid = guid,
        name = name,
		classId = select(3, UnitClass(name)),
		position = position,
		displayName = name:sub(1, (name:find("-") or string.len(name))):gsub("-", "*"),
		color = nil,
		dead = false,

		incomingHealth = nil,
		health = nil,
		role = nil,
		mana = nil,
		border = nil,
		
		bars = {},
		buttons = {},

		debuff =
		{
			icon = nil,
			texture = nil,
			cooldown = nil,
	
			active = false,
			spell = nil,
			type = nil,
			icon = nil,
			expirationTime = nil,
		},
	}

	setmetatable(self, RewatchPlayer)

	local roleSize = rewatch:Scale(5)
	local debuffSize = rewatch:Scale(10)

	-- frame
	self.frame:SetWidth(rewatch.playerWidth)
	self.frame:SetHeight(rewatch.playerHeight)
	self.frame:SetPoint("TOPLEFT", rewatch.frame, "TOPLEFT", 0, 0)
	self.frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	self.frame:SetBackdropColor(0.07, 0.07, 0.07, 1)
	
	self:MoveTo(position)

	-- incoming health
	self.incomingHealth = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")
	self.incomingHealth:SetStatusBarTexture(rewatch.options.profile.bar)
	self.incomingHealth:GetStatusBarTexture():SetHorizTile(false)
	self.incomingHealth:GetStatusBarTexture():SetVertTile(false)
	self.incomingHealth:SetStatusBarColor(0.4, 1, 0.4, 1)
	self.incomingHealth:SetMinMaxValues(0, 1)
	self.incomingHealth:SetValue(0)
	self.incomingHealth:SetFrameLevel(10)
	
	if(rewatch.options.profile.layout == "horizontal") then
		self.incomingHealth:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.incomingHealth:SetHeight(rewatch:Scale(rewatch.options.profile.healthBarHeight - rewatch.options.profile.manaBarHeight))
	elseif(rewatch.options.profile.layout == "vertical") then 
		self.incomingHealth:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth - rewatch.options.profile.manaBarHeight) - (rewatch.options.profile.showButtons and rewatch.buttonSize or 0))
		self.incomingHealth:SetWidth(rewatch:Scale(rewatch.options.profile.healthBarHeight))
	end

	self.incomingHealth:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	
	-- health bar
	self.health = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")
	self.health:SetWidth(self.incomingHealth:GetWidth())
	self.health:SetHeight(self.incomingHealth:GetHeight())
	self.health:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.health:SetStatusBarTexture(rewatch.options.profile.bar)
	self.health:GetStatusBarTexture():SetHorizTile(false)
	self.health:GetStatusBarTexture():SetVertTile(false)
	self.health:SetMinMaxValues(0, 1)
	self.health:SetValue(0)
	self.health:SetFrameLevel(20)

	self.color = RAID_CLASS_COLORS[select(2, GetClassInfo(self.classId or 11))]
	self.health:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 1)

	self.health.text = self.health:CreateFontString("$parentText", "ARTWORK")
	self.health.text:SetFont(rewatch.options.profile.font, rewatch:Scale(rewatch.options.profile.fontSize), "OUTLINE")
	self.health.text:SetAllPoints()
	self.health.text:SetTextColor(1, 1, 1, 1)

	if(rewatch.options.profile.showNames) then
		self.health.text:SetText(self.displayName)
	end

	-- role icon
	self.role = self.health:CreateTexture(nil, "OVERLAY")
	self.role:SetTexture("Interface\\LFGFrame\\LFGRole")
	self.role:SetSize(roleSize, roleSize)
	self.role:SetPoint("TOPLEFT", self.health, "TOPLEFT", roleSize, (roleSize-self.health:GetHeight())/2)

	self:SetRole()

	-- debuff icon
	self.debuff.icon = CreateFrame("Frame", nil, self.health, BackdropTemplateMixin and "BackdropTemplate")
	self.debuff.icon:SetWidth(debuffSize)
	self.debuff.icon:SetHeight(debuffSize)
	self.debuff.icon:SetPoint("TOPRIGHT", self.health, "TOPRIGHT", -debuffSize, (debuffSize-self.health:GetHeight())/2)

	self.debuff.texture = self.debuff.icon:CreateTexture(nil, "ARTWORK")
	self.debuff.texture:SetAllPoints()

	self.debuff.cooldown = CreateFrame("Cooldown", nil, self.debuff.icon, "CooldownFrameTemplate")
	self.debuff.cooldown:SetPoint("CENTER", 0, 0)
	self.debuff.cooldown:SetWidth(debuffSize)
	self.debuff.cooldown:SetHeight(debuffSize)
	self.debuff.cooldown:SetReverse(true)
	self.debuff.cooldown:Hide()

	self.debuff.text = self.debuff.cooldown:CreateFontString("$parentText", "ARTWORK", "NumberFontNormalYellow")
	self.debuff.text:SetAllPoints()

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

			if(rewatch.classId == 7 and rewatch.spec ~= 4) then
				if(spell == rewatch.locale["naturescure"]) then spell = rewatch.locale["removecorruption"] end
				if(spell == rewatch.locale["ironbark"]) then spell = rewatch.locale["barkskin"] end
			end

			self.buttons[spell] = RewatchButton:new(spell, self, anchor, i)

		end
	end
	
	-- overlay target/remove button
	local overlay = CreateFrame("BUTTON", nil, self.health, "SecureActionButtonTemplate")

	overlay:SetWidth(self.health:GetWidth())
	overlay:SetHeight(self.health:GetHeight() + rewatch:Scale(rewatch.options.profile.manaBarHeight))
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
	self.border:SetWidth(rewatch.playerWidth)
	self.border:SetHeight(rewatch.playerHeight)
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

	rewatch.players[self.guid] = self
	
    return self

end

-- move to position
function RewatchPlayer:MoveTo(position)

	local div = math.floor((position-1) / rewatch.options.profile.numFramesWide)
	local mod = (position-1) % rewatch.options.profile.numFramesWide
	local x = div
	local y = mod

	if(rewatch.options.profile.grow ~= "down") then x = mod; y = div end

	self.frame:SetPoint("TOPLEFT", rewatch.frame, "TOPLEFT", x * rewatch.playerWidth, y * -rewatch.playerHeight)
	
end

-- set mana/power bar color
function RewatchPlayer:SetPower()

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

	local role = UnitGroupRolesAssigned(self.name)

	if(role == "TANK" or role == "HEALER") then
		self.role:SetTexCoord(GetTexCoordsForRoleSmall(role))
		self.role:Show()
	else
		self.role:Hide()
	end

end

-- update frame with debuff
function RewatchPlayer:SetDebuff(spellName)

	local filter = "HARMFUL|RAID"
	local name, icon, count, type, expirationTime
	local dispel, color = true, nil

	if(rewatch.options.profile.notify1[spellName]) then return end
	if(rewatch.options.profile.notify2[spellName]) then filter = "HARMFUL"; dispel = false; color = { r=1, g=0.5, b=0.1, a=0.8 } end
	if(rewatch.options.profile.notify3[spellName]) then filter = "HARMFUL"; dispel = false; color = { r=1, g=0, b=0, a=0.8 } end

	for i=1,40 do
		name, icon, count, type, _, expirationTime = UnitDebuff(self.name, i, filter)
		if(name == nil) then break end
		if(name == spellName) then break end
	end

	if(name ~= spellName) then return end

	if(not color) then
		if(type == "Poison") then color = { r=0, g=0.3, b=0, a=1 }
		elseif(type == "Curse") then color = { r=0.5, g=0, b=0.5, a=1 }
		elseif(type == "Magic") then color = { r=0, g=0, b=0.5, a=1 }
		elseif(type == "Disease") then color = { r=0.5, g=0.5, b=0.0, a=1 }
		end
	end

	self.debuff.active = true
	self.debuff.spell = spellName
	self.debuff.type = type
	self.debuff.icon = icon
	self.debuff.expirationTime = expirationTime

	self.debuff.texture:SetTexture(self.debuff.icon)
	self.debuff.texture:Show()

	if(count < 1) then self.debuff.text:SetText("")
	else self.debuff.text:SetText(count)
	end

	local now = GetTime()
	local duration = expirationTime-now

	CooldownFrame_Set(self.debuff.cooldown, now, duration, true)

	self.frame:SetBackdropColor(color.r, color.g, color.b, color.a)

	for _,button in pairs(self.buttons) do button:SetAlpha(dispel) end

end

-- remove debuff
function RewatchPlayer:RemoveDebuff(spellName)

	if(self.debuff.active and (not spellName or self.debuff.spell == spellName)) then

		self.debuff.active = false
		self.debuff.texture:Hide()
		self.debuff.cooldown:Hide()

		self.frame:SetBackdropColor(0.07, 0.07, 0.07, 1)

		for _,button in pairs(self.buttons) do button:SetAlpha() end

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
		else
			local r, g, b = GetThreatStatusColor(threat)
			self.border:SetBackdropBorderColor(r, g, b, 1)
		end

	-- changed role
	elseif(event == "PLAYER_ROLES_ASSIGNED") then
	
		self:SetRole()

	-- shapeshift
	elseif(event == "UNIT_DISPLAYPOWER") then

		self:SetPower()

	-- player was the target of by some combat event
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then

		local _, effect, _, sourceGUID, _, _, _, targetGUID, targetName, _, _, _, spellName, _, school = CombatLogGetCurrentEventInfo()
		
		if(not targetGUID) then return end
		if(targetGUID ~= self.guid) then return end

		if((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
			
			if(school == "DEBUFF") then self:SetDebuff(spellName) end

		elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then
			
			if(school == "DEBUFF") then self:RemoveDebuff(spellName) end

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
	if(rewatch.options.profile.showNames) then
		if(self.hover == 1) then
			self.health.text:SetText(string.format("%i/%i", health, maxHealth))
		elseif(self.hover == 2) then
			self.health.text:SetText(self.displayName)
			self.hover = 0
		end
	else
		if(self.hover == 1) then
			self.health.text:SetText(self.displayName)
		elseif(self.hover == 2) then
			self.health.text:SetText()
			self.hover = 0
		end
	end

	-- mana
	self.mana:SetMinMaxValues(0, UnitPowerMax(self.name))
	self.mana:SetValue(UnitPower(self.name))

	-- debuff check
	if(self.debuff.active) then
		if(currentTime > self.debuff.expirationTime) then
			self:RemoveDebuff()
		end
	end

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
			self:RemoveDebuff()
			self.frame:SetAlpha(0.2)

			for _,bar in pairs(self.bars) do bar:Down() end
			for _,button in pairs(self.buttons) do button:SetAlpha() end

		end

		return

	end

	-- aliiiiiiive
	if(self.dead) then

		self.dead = false

		for _,button in pairs(self.buttons) do button:SetAlpha() end

	end

	-- fade when out of range
	if(IsSpellInRange(rewatch.options.profile.spell, self.name) == 1) then
		self.frame:SetAlpha(1)
		self.incomingHealth:SetAlpha(1)
	else
		self.frame:SetAlpha(0.5)
		self.incomingHealth:SetAlpha(0)
	end

end

-- dispose
function RewatchPlayer:Dispose()

	self.frame:UnregisterAllEvents()
	self.frame:Hide()

	for _,bar in pairs(self.bars) do bar:Dispose() end
	for _,button in pairs(self.buttons) do button:Dispose() end

	self.frame = nil
	self.incomingHealth = nil
	self.health = nil
	self.role = nil
	self.debuff.icon = nil
	self.debuff.texture = nil
	self.debuff.cooldown = nil
	self.mana = nil
	self.border = nil
	self.bars = {}
	self.buttons = {}

end