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
		dead = false,

		incomingHealth = nil,
		health = nil,
		roleIcon = nil,
		debuffTexture = nil,
		mana = nil,
		aggro = nil,
		border = nil,
		
		bars = {},
		buttons = {},
    }

	setmetatable(self, RewatchPlayer)

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
		self.incomingHealth:SetHeight(rewatch:Scale(rewatch.options.profile.healthBarHeight * 0.8))
	elseif(rewatch.options.profile.layout == "vertical") then 
		self.incomingHealth:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth * 0.8) - (rewatch.options.profile.showButtons and rewatch.buttonSize or 0))
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
	self.health:SetStatusBarColor(0.07, 0.07, 0.07, 1)
	self.health:SetMinMaxValues(0, 1)
	self.health:SetValue(0)
	self.health:SetFrameLevel(20)

	local classColors = RAID_CLASS_COLORS[select(2, GetClassInfo(self.classId or 11))]

	self.health.text = self.health:CreateFontString("$parentText", "ARTWORK")
	self.health.text:SetFont(rewatch.options.profile.font, rewatch:Scale(rewatch.options.profile.fontSize), "OUTLINE")
	self.health.text:SetAllPoints()
	self.health.text:SetText(self.displayName)
	self.health.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1)
	
	-- role icon
	self.roleIcon = self.health:CreateTexture(nil, "OVERLAY")
	self.roleIcon:SetTexture("Interface\\LFGFrame\\LFGRole")
	self.roleIcon:SetSize(10, 10)
	self.roleIcon:SetPoint("TOPLEFT", self.health, "TOPLEFT", 10, 5-self.health:GetHeight()/2)

	self:SetRole()

	-- debuff icon
	self.debuffIcon = CreateFrame("Frame", nil, self.health, BackdropTemplateMixin and "BackdropTemplate")
	self.debuffIcon:SetWidth(16)
	self.debuffIcon:SetHeight(16)
	self.debuffIcon:SetPoint("TOPRIGHT", self.health, "TOPRIGHT", -10, 8-self.health:GetHeight()/2)
	self.debuffIcon:SetAlpha(0.8)

	self.debuffTexture = self.debuffIcon:CreateTexture(nil, "ARTWORK")
	self.debuffTexture:SetAllPoints()

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
		self.mana:SetHeight(rewatch:Scale(rewatch.options.profile.healthBarHeight * 0.2))
	elseif(rewatch.options.profile.layout == "vertical") then
		self.mana:SetWidth(rewatch:Scale(rewatch.options.profile.healthBarHeight))
		self.mana:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth * 0.2))
	end
	
	self:SetPower()

	-- aggro bar
	self.aggro = CreateFrame("STATUSBAR", nil, self.mana, "TextStatusBar")
	self.aggro:SetPoint("BOTTOMLEFT", self.mana, "BOTTOMLEFT", 0, 0)
	self.aggro:SetHeight(4)
	self.aggro:SetWidth(self.mana:GetWidth())
	self.aggro:SetStatusBarTexture(rewatch.options.profile.bar)
	self.aggro:GetStatusBarTexture():SetHorizTile(false)
	self.aggro:GetStatusBarTexture():SetVertTile(false)
	self.aggro:SetMinMaxValues(0, 3)
	self.aggro:SetValue(0)

	-- todo: hmmm
	local colors =
	{
		{ r=0, g=0.7, b=0, a=1 }, -- lifebloom
		{ r=0.85, g=0.15, b=0.80, a=1 }, -- reju
		{ r=0.05, g=0.3, b=0.1, a=1 }, -- regrowth
		{ r=0.5, g=0.8, b=0.3, a=1 }, -- wild growth
		{ r=0.0, g=0.1, b=0.8, a=1 },  -- riptide
		{ r=0.4, g=0.85, b=0.34, a=1 }, -- germ
	}

	-- spell bars
	local anchor = rewatch.options.profile.layout == "horizontal" and self.mana or self.health

	for i,spell in ipairs(rewatch.options.profile.bars) do

		self.bars[spell] = RewatchBar:new(spell, self, anchor, colors[i])
		anchor = self.bars[spell].bar

	end
	
	-- spell buttons
	if(rewatch.options.profile.showButtons == 1) then

		if(rewatch.options.profile.layout == "vertical") then anchor = self.mana end

		for i,spell in ipairs(rewatch.options.profile.buttons) do

			if(rewatch.classId == 7 and rewatch.spec ~= 3) then
				if(spell == rewatch.locale["naturescure"]) then spell = rewatch.locale["removecorruption"] end
				if(spell == rewatch.locale["ironbark"]) then spell = rewatch.locale["barkskin"] end
			end

			self.buttons[spell] = RewatchButton:new(spell, self, anchor)
			anchor = self.buttons[spell].button

		end
	end
	
	-- overlay target/remove button
	local overlay = CreateFrame("BUTTON", nil, self.health, "SecureActionButtonTemplate")

	overlay:SetWidth(self.health:GetWidth())
	overlay:SetHeight(self.health:GetHeight()*1.25)
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

		lastUpdate = lastUpdate + elapsed;
		if lastUpdate > interval then self:OnUpdate(); lastUpdate = 0 end;

		lastUpdateSlow = lastUpdateSlow + elapsed;
		if lastUpdateSlow > intervalSlow then self:OnUpdateSlow(); lastUpdateSlow = 0 end;
	
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
		self.roleIcon:SetTexCoord(GetTexCoordsForRoleSmall(role))
		self.roleIcon:Show()
	else
		self.roleIcon:Hide()
	end

end

-- set background color
function RewatchPlayer:SetBackground()

	if(self.notify3) then self.frame:SetBackdropColor(1.0, 0.0, 0.0, 1)
	elseif(self.debuff) then
	
		if(self.debuffType == "Poison") then self.frame:SetBackdropColor(0.0, 0.3, 0, 1)
		elseif(self.debuffType == "Curse") then self.frame:SetBackdropColor(0.5, 0.0, 0.5, 1)
		elseif(self.debuffType == "Magic") then self.frame:SetBackdropColor(0.0, 0.0, 0.5, 1)
		elseif(self.debuffType == "Disease") then self.frame:SetBackdropColor(0.5, 0.5, 0.0, 1)
		end

	elseif(self.notify2) then self.frame:SetBackdropColor(1.0, 0.5, 0.1, 1)
	elseif(self.notify1) then self.frame:SetBackdropColor(0.9, 0.8, 0.2, 1)
	else self.frame:SetBackdropColor(0.07, 0.07, 0.07, 1) end
	
end

-- update frame with debuff (if dispellable)
function RewatchPlayer:SetDebuff(spellName)

	local name, icon, debuffType, expires

	for i=1,40 do
		name, icon, _, debuffType, _, expires = UnitDebuff(self.name, i, "HARMFUL|RAID")
		if(name == nil) then break end
		if(name == spellName) then break end
	end

	if(name ~= spellName) then return end

	self.debuff = spellName
	self.debuffType = debuffType
	self.debuffIcon = icon
	self.debuffDuration = expires
	self.debuffTexture:SetTexture(self.debuffIcon)
	self.debuffTexture:Show()

	self:SetBackground()

end

-- event handler
function RewatchPlayer:OnEvent(event, unitGUID)

	-- update threat
	if(event == "UNIT_THREAT_SITUATION_UPDATE") then

		if(unitGUID == "player") then unitGUID = rewatch.guid end
		if(unitGUID ~= self.guid) then return end

		local threat = UnitThreatSituation(self.name)
		local r, g, b = GetThreatStatusColor(threat or 0)

		self.aggro:SetValue(threat or 0)
		self.aggro:SetStatusBarColor(r, g, b, 1)

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

			if(rewatch.options.profile.notify1[spellName]) then self.notify1 = spellName; self:SetBackground() end
			if(rewatch.options.profile.notify2[spellName]) then self.notify2 = spellName; self:SetBackground() end
			if(rewatch.options.profile.notify3[spellName]) then self.notify3 = spellName; self:SetBackground() end
			
			if(school == "DEBUFF") then self:SetDebuff(spellName) end

		elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then

			if(self.notify1 == spellName) then self.notify1 = nil; self:SetBackground() end
			if(self.notify2 == spellName) then self.notify2 = nil; self:SetBackground() end
			if(self.notify3 == spellName) then self.notify3 = nil; self:SetBackground() end
			
			if(self.debuff == spellName) then
				self.debuff = nil
				self.debuffTexture:Hide()
				self:SetBackground()
			end

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
	
	if(percentage < 0.5) then
		percentage = percentage * 2
		self.health:SetStatusBarColor(0.50 + ((1-percentage) * (1.00 - 0.50)), 0.07, 0.07, 1)
	else
		percentage = (percentage * 2) - 1
		self.health:SetStatusBarColor(0.07 + ((1-percentage) * (0.50 - 0.07)), 0.07 + ((1-percentage) * (0.50 - 0.07)), 0.07, 1)
	end

	-- hover
	if(self.hover == 1) then
		self.health.text:SetText(string.format("%i/%i", health, maxHealth))
	elseif(self.hover == 2) then
		self.health.text:SetText(self.displayName)
		self.hover = 0
	end

	-- mana
	self.mana:SetMinMaxValues(0, UnitPowerMax(self.name))
	self.mana:SetValue(UnitPower(self.name))

	-- debuff check
	if(self.debuffDuration ~= nil and self.debuffDuration > 0) then

		local left = self.debuffDuration - currentTime

		if(left < 0) then
			self.debuff = nil
			self.debuffDuration = nil
			self.debuffTexture:Hide()
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
			self.health:SetStatusBarColor(0.07, 0.07, 0.07, 1)
			self.mana:SetValue(0)
			self.incomingHealth:SetValue(0)
			self.aggro:SetValue(0)
			self.health.text:SetText(self.displayName)
			self.notify1 = nil
			self.notify2 = nil
			self.notify3 = nil
			self.debuff = nil
			self.debuffDuration = nil
			self.debuffTexture:Hide()
			self:SetBackground()
			self.frame:SetAlpha(0.2)

			for spell,bar in pairs(self.bars) do bar:Down() end

		end

		return

	end

	self.dead = false

	-- fade when out of range
	if(IsSpellInRange(rewatch.options.profile.spell, self.name) == 1) then
		self.frame:SetAlpha(1)
		self.incomingHealth:SetAlpha(1);
	else
		self.frame:SetAlpha(0.5)
		self.incomingHealth:SetAlpha(0);
	end

end

-- dispose
function RewatchPlayer:Dispose()

	for spell,bar in pairs(self.bars) do bar:Dispose() end

	self.frame:UnregisterAllEvents()
	self.frame:Hide()
	self.frame = nil
	self.bars = {}
	self.buttons = {}

end