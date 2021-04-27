RewatchBar = {}
RewatchBar.__index = RewatchBar

local colors =
{
	{ r=0.00, g=0.70, b=0.0 },
	{ r=0.85, g=0.15, b=0.8 },
	{ r=0.05, g=0.30, b=0.1 },
	{ r=0.50, g=0.80, b=0.3 },
	{ r=0.00, g=0.10, b=0.8 }
}

function RewatchBar:new(spell, parent, anchor, i, isSidebar)

	local self =
	{
		backdrop = CreateFrame("Frame", nil, parent.frame, BackdropTemplateMixin and "BackdropTemplate"),
		bar = nil,
		button = nil,
		parent = parent,
		sidebar = nil,
		isSidebar = isSidebar,

		expirationTime = nil,
		stacks = 0,
		spell = spell,
		spellId = nil,
		color = colors[((i-1)%#colors)+1],
		
		up = nil,
		down = nil,
	}

	rewatch:Debug("RewatchBar:new")

	setmetatable(self, RewatchBar)

	local width, height, snap, orientation

	if(rewatch.options.profile.layout == "horizontal") then
		width = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		height = rewatch:Scale(rewatch.options.profile.spellBarHeight / (self.isSidebar and 3 or 1))
		snap = "BOTTOMLEFT"
		orientation = "horizontal"
	else
		width = rewatch:Scale(rewatch.options.profile.spellBarHeight / (self.isSidebar and 3 or 1))
		height = rewatch:Scale(rewatch.options.profile.spellBarWidth)
		snap = "TOPRIGHT"
		orientation = "vertical"
	end

	-- backdrop
	self.backdrop:SetWidth(width)
	self.backdrop:SetHeight(height)
	self.backdrop:SetPoint("TOPLEFT", anchor, snap, 0, 0)
	self.backdrop:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	self.backdrop:SetBackdropColor(self.color.r, self.color.g, self.color.b, 0.15)
	self.backdrop:SetFrameLevel(10)
	
	-- bar
	self.bar = CreateFrame("STATUSBAR", nil, self.backdrop, "TextStatusBar")
	self.bar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.bar:SetWidth(width)
	self.bar:SetHeight(height)
	self.bar:SetPoint("TOPLEFT", anchor, snap, 0, 0)
	self.bar:SetOrientation(orientation)
	self.bar:GetStatusBarTexture():SetHorizTile(false)
	self.bar:GetStatusBarTexture():SetVertTile(false)
	self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 1)
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(0)
	self.bar:SetFrameLevel(self.isSidebar and 30 or 20)

	if(self.isSidebar) then

		-- sidebar overrides
		self.color = { r = 1-self.color.r, g = 1-self.color.g, b = 1-self.color.b }
		self.backdrop:SetBackdropColor(self.color.r, self.color.g, self.color.b, 0)
		self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 1)

	else

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

		-- germination sidebar
		if(spell == rewatch.spells:Name("Rejuvenation")) then

			self.sidebar = RewatchBar:new(rewatch.spells:Name("Rejuvenation (Germination)"), parent, anchor, i, true)

		end

		-- cenarion ward sidebar
		if(spell == rewatch.spells:Name("Cenarion Ward")) then

			self.sidebar = RewatchBar:new(rewatch.spells:Name("Cenarion Ward"), parent, anchor, i, true)
			self.sidebar.spellId = 102351
			self.spellId = 102352

		end

		-- shield/atonement sidebar
		if(spell == rewatch.spells:Name("Power Word: Shield")) then

			self.sidebar = RewatchBar:new(rewatch.spells:Name("Atonement"), parent, anchor, i, true)

		end

	end

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

	return self

end

-- event handler
function RewatchBar:OnEvent(event)

	local _, effect, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

	if(not spellName) then return end
	if(not sourceGUID) then return end
	if(not targetGUID) then return end
	if(sourceGUID ~= rewatch.guid) then return end

	-- normal hot updates
	if(spellName == self.spell and targetGUID == self.parent.guid and (not self.spellId or spellId == self.spellId)) then

		if(effect == "SPELL_AURA_APPLIED_DOSE" or effect == "SPELL_AURA_APPLIED" or effect == "SPELL_AURA_REFRESH") then
			
			self:Up()

		elseif(effect == "SPELL_AURA_REMOVED" or effect == "SPELL_AURA_DISPELLED" or effect == "SPELL_AURA_REMOVED_DOSE") then
			
			self:Down()
			self:Cooldown()

		elseif(effect == "SPELL_CAST_SUCCESS" and not self.expirationTime and not self.cooldown) then

			self.down = GetTime()

		end

	end

	-- catch global extensions
	if(effect == "SPELL_CAST_SUCCESS" and self.expirationTime and not self.cooldown) then

		if(spellName == rewatch.spells:Name("Flourish")) then

			self.up = GetTime()

		elseif(spellName == rewatch.spells:Name("Rising Sun Kick")) then
		
			self.up = GetTime() + 0.1

		elseif(spellName == rewatch.spells:Name("Swiftmend") and targetGUID == self.parent.guid) then
			
			self.up = GetTime() + 0.1

		end

	end

end

-- update handler
function RewatchBar:OnUpdate()

	local currentTime = GetTime()

	-- handle updates async
	if(self.up and currentTime > self.up) then

		self:Up()
		self.up = nil

	elseif(self.down and currentTime > self.down) then

		self:Cooldown()
		self.down = nil

	end

	-- update bar
	if(self.expirationTime and self.expirationTime > 0) then

		local left = self.expirationTime - currentTime

		if(left <= 0) then

			self:Down()
			--self:Cooldown()

		else

			-- value
			if(self.cooldown) then
				self.bar:SetValue(select(2, self.bar:GetMinMaxValues()) - left)
			else
				self.bar:SetValue(left)
			end

			-- color
			if(not self.cooldown and math.abs(left-3) < 0.1) then
				self.bar:SetStatusBarColor(0.6, 0.0, 0.0, 1)
			end

			-- text
			if(not self.isSidebar) then

				if(self.stacks <= 1) then

					self.bar.text:SetText(left > 99 and "" or string.format("%.00f", left))

				else

					local s = left > 99 and "" or string.format("%.00f", left)

					s = s..(rewatch.options.profile.layout == "horizontal" and " - " or "\n\n")

					if(self.stacks == 2) then s = s.."II"
					elseif(self.stacks == 3) then s = s.."III"
					elseif(self.stacks == 4) then s = s.."IV"
					elseif(self.stacks == 5) then s = s.."V"
					elseif(self.stacks == 6) then s = s.."VI"
					elseif(self.stacks == 7) then s = s.."VII"
					elseif(self.stacks == 8) then s = s.."IIX"
					elseif(self.stacks == 9) then s = s.."IX"
					elseif(self.stacks == 10) then s = s.."X"
					else s = s..self.stacks end

					self.bar.text:SetText(s)

				end
			end
		end
	end

end

-- put it up
function RewatchBar:Up()

	rewatch:Debug("RewatchBar:Up")

	local name, stacks, expirationTime, spellId
	local found = false

	for i=1,40 do

		name, _, stacks, _, _, expirationTime, _, _, _, spellId = UnitBuff(self.parent.name, i, "PLAYER")

		if(name == nil) then break end
		if(not self.spellId and name == self.spell) then found = true end
		if(spellId == self.spellId) then found = true end
		if(found) then break end

	end

	if(not found) then
		
		self.stacks = 0

	else

		local duration = math.max(1, expirationTime - GetTime())

		if(select(2, self.bar:GetMinMaxValues()) <= duration) then self.bar:SetMinMaxValues(0, duration) end

		self.expirationTime = expirationTime
		self.stacks = stacks
		self.cooldown = false
		self.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b, 1)
		self.bar:SetValue(duration)

	end

end

-- take it down
function RewatchBar:Down()

	rewatch:Debug("RewatchBar:Down")

	if(not self.parent.dead and self.stacks > 1) then self:Up() end
	if(not self.parent.dead and self.stacks > 1) then return end

	self.expirationTime = nil
	self.cooldown = false
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(0)

	if(not self.isSidebar) then self.bar.text:SetText("") end

end

-- count up for cooldown
function RewatchBar:Cooldown()

	rewatch:Debug("RewatchBar:Cooldown")

	if(self.parent.dead) then return end
	if(self.expirationTime or self.cooldown) then return end
	
	local start, duration, enabled = GetSpellCooldown(self.spell)

	if(start > 0 and duration > 0 and enabled > 0) then

		self.expirationTime = start + duration
		self.cooldown = true
		self.bar:SetStatusBarColor(0, 0, 0, 0.8)
		self.bar:SetMinMaxValues(0, self.expirationTime - GetTime())

	end

end

-- dispose
function RewatchBar:Dispose()

	rewatch:Debug("RewatchBar:Dispose")

	self.backdrop:Hide()
	self.bar:UnregisterAllEvents()

	if(self.sidebar) then self.sidebar:Dispose() end

	self.backdrop = nil
	self.bar = nil
	self.parent = nil
	self.button = nil
	self.sidebar = nil

end