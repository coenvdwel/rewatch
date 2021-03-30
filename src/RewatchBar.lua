RewatchBar = {}
RewatchBar.__index = RewatchBar

function RewatchBar:new(spell, parent, anchor, color)

	local self =
	{
		bar = CreateFrame("STATUSBAR", nil, parent.frame, "TextStatusBar"),
		parent = parent,

		value = 0,
		spell = spell,
		color = color
	}

	setmetatable(self, RewatchBar)

	-- bar
	self.bar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.bar:GetStatusBarTexture():SetHorizTile(false)
	self.bar:GetStatusBarTexture():SetVertTile(false)
	self.bar:SetStatusBarColor(color.r, color.g, color.b, 0.2)
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(1)

	if(rewatch.options.profile.layout == "horizontal") then
		self.bar:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.bar:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarHeight))
		self.bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
		self.bar:SetOrientation("horizontal")
	else
		self.bar:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.bar:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarHeight))
		self.bar:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
		self.bar:SetOrientation("vertical")
	end

	-- border
	self.border = CreateFrame("FRAME", nil, self.bar, BackdropTemplateMixin and "BackdropTemplate")
	self.border:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 2, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	self.border:SetBackdropBorderColor(1, 1, 1, 0)
	self.border:SetWidth(self.bar:GetWidth()+1)
	self.border:SetHeight(self.bar:GetHeight()+1)
	self.border:SetPoint("TOPLEFT", self.bar, "TOPLEFT", -0, 0)

	-- overlay cast button
	local bc = CreateFrame("BUTTON", nil, self.bar, "SecureActionButtonTemplate")
	bc:SetWidth(self.bar:GetWidth())
	bc:SetHeight(self.bar:GetHeight())
	bc:SetPoint("TOPLEFT", self.bar, "TOPLEFT", 0, 0)
	bc:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	bc:SetAttribute("type1", "spell")
	bc:SetAttribute("unit", parent.name)
	bc:SetAttribute("spell1", spell)
	bc:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp")

	-- text
	self.bar.text = bc:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	self.bar.text:SetPoint("RIGHT", bc)
	self.bar.text:SetAllPoints()
	self.bar.text:SetAlpha(1)
	self.bar.text:SetText("")

	-- apply tooltip support
	bc:SetScript("OnEnter", function() bc:SetAlpha(0.2); rewatch:SetSpellTooltip(spell) end)
	bc:SetScript("OnLeave", function() bc:SetAlpha(1); GameTooltip:Hide() end)

	-- events
	local lastUpdate, interval = 0, 1/20

	self.bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.bar:SetScript("OnEvent", function(_, event) self:OnEvent(event) end)
	self.bar:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed;

		if lastUpdate > interval then
			self:OnUpdate();
			lastUpdate = 0
		end;

	end)

	return self

end

-- event handler
function RewatchBar:OnEvent(event)

	local _, effect, _, sourceGUID, _, _, _, targetGUID, targetName, _, _, _, spellName, _, school = CombatLogGetCurrentEventInfo()

	if(not spellName) then return end
	if(not sourceGUID) then return end
	if(not targetGUID) then return end
	if(spellName ~= self.spell) then return end
	if(sourceGUID ~= rewatch.guid) then return end
	if(targetGUID ~= self.parent.guid) then return end

	if((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then self:Up()
	elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then self:Down()
	end

end

-- update handler
function RewatchBar:OnUpdate()

	if(self.value <= 0) then return end

	local currentTime = GetTime()
	local left = self.value - currentTime

	if(left <= 0) then
		self:Down()
		return
	end

	if(self.cooldown) then
		local _, max = self.bar:GetMinMaxValues()
		self.bar:SetValue(max - left)
	else
		self.bar:SetValue(left)
		if(math.abs(left-2)<0.1) then self.bar:SetStatusBarColor(0.6, 0.0, 0.0, 1) end
	end

	self.bar.text:SetText(string.format("%.00f", left))

end

-- put it up
function RewatchBar:Up()

	local name, expires

	for i=1,40 do
		name, _, _, _, _, expires = UnitBuff(self.parent.name, i, "PLAYER")
		if (name == nil) then break end
		if (name == self.spell) then break end
	end

	if (name ~= self.spell) then return end
	if(not expires) then return end
	
	local seconds = expires - GetTime()

	if(select(2, self.bar:GetMinMaxValues()) <= seconds) then self.bar:SetMinMaxValues(0, seconds) end

	self.value = expires
	self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, self.color.a)
	self.bar:SetValue(seconds)
	self.bar.text:SetText(string.format("%.00f", seconds))

end

-- take it down
function RewatchBar:Down()

	self.value = 0
	self.cooldown = false
	self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 0.2)
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(1)
	self.bar.text:SetText("")

	-- cenarion ward haxx
	if(spellId == rewatch.locale["Cenarion Ward"]) then

		self:Up()
		if(self.value > 0) then return end

	end

	if(not self.parent.dead) then

		local start, duration = GetSpellCooldown(self.spell)

		if(start > 0) then

			local expires = start + duration
			local seconds = expires - GetTime()

			self.cooldown = true
			self.value = expires
			self.bar:SetStatusBarColor(0, 0, 0, 0.8)
			self.bar:SetMinMaxValues(0, seconds)
			self.bar:SetValue(0)

		end
		
	end

end

-- dispose
function RewatchBar:Dispose()

	self.bar:UnregisterAllEvents()
	self.bar:Hide()
	self.bar = nil
	self.parent = nil

end