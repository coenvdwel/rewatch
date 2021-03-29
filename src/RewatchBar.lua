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

	self.bar.text = bc:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	self.bar.text:SetPoint("RIGHT", bc)
	self.bar.text:SetAllPoints()
	self.bar.text:SetAlpha(1)
	self.bar.text:SetText("")

	-- apply tooltip support
	bc:SetScript("OnEnter", function() bc:SetAlpha(0.2); rewatch:SetSpellTooltip(spell) end)
	bc:SetScript("OnLeave", function() bc:SetAlpha(1); GameTooltip:Hide() end)

	-- events
	self.bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.bar:SetScript("OnEvent", function(_, event)

		local _, effect, _, sourceGUID, _, _, _, targetGUID, targetName, _, _, _, spellName, _, school = CombatLogGetCurrentEventInfo()

		if(not spellName) then return end
		if(not sourceGUID) then return end
		if(not targetGUID) then return end

		if(spellName ~= self.spell) then return end
		if(sourceGUID ~= rewatch.guid) then return end
		if(targetGUID ~= parent.guid) then return end
		
		if((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
			
			local expires = self:GetExpirationTime()
			if(not expires) then return end
	
			local seconds = expires - GetTime()
	
			if(select(2, self.bar:GetMinMaxValues()) <= seconds) then self.bar:SetMinMaxValues(0, seconds) end

			self.value = expires
			self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, self.color.a)
			self.bar:SetValue(seconds)

		elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then

			self.value = 0
			self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 0.2)
			self.bar:SetMinMaxValues(0, 1)
			self.bar:SetValue(1)
			self.bar.text:SetText("")
	
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

	end)

	return self

end

-- get expirationTime of buff
function RewatchBar:GetExpirationTime()

	for i=1,40 do
		local name, _, _, _, _, expirationTime = UnitBuff(self.parent.name, i, "PLAYER")
		if (name == nil) then return nil end
		if (name == self.spell) then return expirationTime end
	end

	return nil
	
end