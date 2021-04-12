RewatchBar = {}
RewatchBar.__index = RewatchBar

local colors =
{
	{ r=0.00, g=0.70, b=0.0, a=1 },
	{ r=0.85, g=0.15, b=0.8, a=1 },
	{ r=0.05, g=0.30, b=0.1, a=1 },
	{ r=0.50, g=0.80, b=0.3, a=1 },
	{ r=0.00, g=0.10, b=0.8, a=1 }
}

function RewatchBar:new(spell, parent, anchor, i)

	local self =
	{
		bar = CreateFrame("STATUSBAR", nil, parent.frame, "TextStatusBar"),
		button = nil,
		parent = parent,
		sidebar = nil,

		value = 0,
		stacks = 0,
		spell = spell,
		color = colors[((i-1)%#colors)+1],
	}

	setmetatable(self, RewatchBar)

	-- bar
	self.bar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.bar:GetStatusBarTexture():SetHorizTile(false)
	self.bar:GetStatusBarTexture():SetVertTile(false)
	self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 0.2)
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(1)
	self.bar:SetFrameLevel(20)

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

	-- overlay cast button
	self.button = CreateFrame("BUTTON", nil, self.bar, "SecureActionButtonTemplate")
	self.button:SetWidth(self.bar:GetWidth())
	self.button:SetHeight(self.bar:GetHeight())
	self.button:SetPoint("TOPLEFT", self.bar, "TOPLEFT", 0, 0)
	self.button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self.button:SetAttribute("type1", "spell")
	self.button:SetAttribute("unit", parent.name)
	self.button:SetAttribute("spell1", spell)
	self.button:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp")
	self.button:SetFrameLevel(40)

	-- text
	self.bar.text = self.button:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	self.bar.text:SetPoint("RIGHT", self.button)
	self.bar.text:SetAllPoints()
	self.bar.text:SetAlpha(1)
	self.bar.text:SetText("")

	-- apply tooltip support
	self.button:SetScript("OnEnter", function() self.button:SetAlpha(0.2); rewatch:SetSpellTooltip(spell) end)
	self.button:SetScript("OnLeave", function() self.button:SetAlpha(1); GameTooltip:Hide() end)

	-- events
	local lastUpdate, interval = 0, 1/20

	self.bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.bar:SetScript("OnEvent", function(_, event) self:OnEvent(event) end)
	self.bar:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed

		if lastUpdate > interval then
			self:OnUpdate()
			lastUpdate = 0
		end

	end)

	-- germination haxx
	if(spell == rewatch.locale["rejuvenation"]) then

		self.sidebar = RewatchBar:new(rewatch.locale["rejuvenation (germination)"], parent, anchor, i)
		self.sidebar.color = { r = 1-self.color.r, g = 1-self.color.g, b = 1-self.color.b }
		self.sidebar.bar:SetFrameLevel(30)
		self.sidebar.bar:SetValue(0)
		self.sidebar.button:Hide()
		
		if(rewatch.options.profile.layout == "horizontal") then
			self.sidebar.bar:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarHeight)/3)
		else
			self.sidebar.bar:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarHeight)/3)
		end
	end
	
	return self

end

-- event handler
function RewatchBar:OnEvent(event)

	local _, effect, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

	-- ignore different spells on different players
	if(not spellName) then return end
	if(not sourceGUID) then return end
	if(not targetGUID) then return end
	if(sourceGUID ~= rewatch.guid) then return end

	-- ignore shield part of cenarion ward
	if(spellId == 102351) then return end

	-- normal hot updates
	if(spellName == self.spell and targetGUID == self.parent.guid) then

		if((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
			
			self:Up()

		elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then
			
			self:Down()

		elseif(self.value == 0) then
			
			self:Cooldown()

		end

	end

	-- when flourishing, update all hot bars
	if((spellName == rewatch.locale["flourish"]) and (effect == "SPELL_CAST_SUCCESS")) then self:Up() end

	-- when swiftmending, update all hot bars (verdant infusion check)
	if((spellName == rewatch.locale["swiftmend"]) and (effect == "SPELL_CAST_SUCCESS")) then self:Up() end

end

-- update handler
function RewatchBar:OnUpdate()

	if(self.value <= 0) then return end

	local currentTime = GetTime()
	local left = self.value - currentTime
	local s = left > 99 and "" or string.format("%.00f", left)

	if(left <= 0) then
		self:Down()
		return
	end

	if(self.cooldown) then
		self.bar:SetValue(select(2, self.bar:GetMinMaxValues()) - left)
	else
		self.bar:SetValue(left)
		if(math.abs(left-2)<0.1) then self.bar:SetStatusBarColor(0.6, 0.0, 0.0, 1) end
	end

	if(self.stacks > 1) then
		s = s..(rewatch.options.profile.layout == "horizontal" and " - " or "\n\n")..self:StacksAsRomanNumeral()
	end

	self.bar.text:SetText(s)

end

-- put it up
function RewatchBar:Up()

	local name, count, expirationTime, spellId

	for i=1,40 do
		name, _, count, _, _, expirationTime, _, _, _, spellId = UnitBuff(self.parent.name, i, "PLAYER")
		if(name == nil) then break end
		if(name == self.spell and spellId ~= 102351) then break end
	end

	if(name ~= self.spell or not expirationTime) then return false end

	local duration = expirationTime - GetTime()

	if(select(2, self.bar:GetMinMaxValues()) <= duration) then self.bar:SetMinMaxValues(0, duration) end

	self.value = expirationTime
	self.stacks = count
	self.cooldown = false
	self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, self.color.a)
	self.bar:SetValue(duration)
	self.bar.text:SetText(string.format("%.00f", duration))

	return true

end

-- take it down
function RewatchBar:Down()

	if(self.stacks > 1) then
		if(self:Up()) then return end
	end

	self.value = 0
	self.cooldown = false
	self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 0.2)
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(1)
	self.bar.text:SetText("")

	self:Cooldown()

end

-- count up for cooldown
function RewatchBar:Cooldown()

	if(self.parent.dead) then return end

	local start, duration, enabled = GetSpellCooldown(self.spell)

	if(start > 0 and duration > 0 and enabled > 0) then

		local expires = start + duration
		local seconds = expires - GetTime()

		self.value = expires
		self.cooldown = true
		self.bar:SetStatusBarColor(0, 0, 0, 0.8)
		self.bar:SetMinMaxValues(0, seconds)
		self.bar:SetValue(0)

	end

end

-- get current stacks as roman numeral
function RewatchBar:StacksAsRomanNumeral()

	if(not self.stacks) then return ""
	elseif(self.stacks == 1) then return "I"
	elseif(self.stacks == 2) then return "II"
	elseif(self.stacks == 3) then return "III"
	elseif(self.stacks == 4) then return "IV"
	elseif(self.stacks == 5) then return "V"
	elseif(self.stacks == 6) then return "VI"
	elseif(self.stacks == 7) then return "VII"
	elseif(self.stacks == 8) then return "IIX"
	elseif(self.stacks == 9) then return "IX"
	elseif(self.stacks == 10) then return "X"
	else return self.stacks end

end

-- dispose
function RewatchBar:Dispose()

	self.bar:UnregisterAllEvents()
	self.bar:Hide()

	if(self.sidebar) then self.sidebar:Dispose() end

	self.bar = nil
	self.parent = nil
	self.button = nil
	self.sidebar = nil

end