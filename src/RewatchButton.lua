RewatchButton = {}
RewatchButton.__index = RewatchButton

function RewatchButton:new(spell, parent, anchor, i)

	local self =
	{
		button = CreateFrame("BUTTON", nil, parent.frame, "SecureActionButtonTemplate"),
		parent = parent,
		spell = spell,

		cooldown = nil,
		dispel = rewatch.spells:IsDispel(spell)
	}

	rewatch:Debug("RewatchButton:new")

	setmetatable(self, RewatchButton)
	
	-- spell info
	local name, _, icon = GetSpellInfo(spell)
	if(not name) then return self end

	-- button
	self.button:SetWidth(rewatch.buttonSize)
	self.button:SetHeight(rewatch.buttonSize)
	self.button:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", rewatch.buttonSize*(i-1), 0)
	self.button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self.button:SetAttribute("unit", parent.name)
	self.button:SetAttribute("type1", "spell")
	self.button:SetAttribute("spell1", spell)
	
	-- texture
	self.button:SetNormalTexture(icon)
	self.button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
	self.button:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp")
	self.button:GetHighlightTexture():SetAlpha(0.2)
	
	-- transparency for highlighting icons
	self:SetAlpha()

	-- apply tooltip support
	self.button:SetScript("OnEnter", function() rewatch:SetSpellTooltip(spell) end)
	self.button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- add cooldown overlay
	self.cooldown = CreateFrame("Cooldown", nil, self.button, "CooldownFrameTemplate")
	self.cooldown:SetPoint("CENTER", 0, 0)
	self.cooldown:SetWidth(rewatch.buttonSize)
	self.cooldown:SetHeight(rewatch.buttonSize)
	self.cooldown:Hide()

	-- events
	local lastUpdate, interval = 0, 1/20

	self.button:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.button:SetScript("OnEvent", function(_, event) self:OnEvent(event) end)
	self.button:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed

		if lastUpdate > interval then
			self:OnUpdate()
			lastUpdate = 0
		end

	end)

	return self

end

-- event handler
function RewatchButton:OnEvent(event)

	local _, effect, _, sourceGUID, _, _, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()

	if(not spellName) then return end
	if(not sourceGUID) then return end
	if(spellName ~= self.spell) then return end
	if(sourceGUID ~= rewatch.guid) then return end
	if(effect ~= "SPELL_CAST_SUCCESS") then return end

	self.cast = true

end

-- update handler
function RewatchButton:OnUpdate()

	if(not self.cast) then return end

	self.cast = false
	CooldownFrame_Set(self.cooldown, GetSpellCooldown(self.spell))

end

-- set alpha (for dispels)
function RewatchButton:SetAlpha(dispel)

	rewatch:Debug("RewatchButton:SetAlpha")

	if(self.parent.dead or (self.dispel and not dispel)) then
		self.button:SetAlpha(0.2)
	else
		self.button:SetAlpha(1)
	end

end

-- dispose
function RewatchButton:Dispose()

	rewatch:Debug("RewatchButton:Dispose")

	self.cast = false
	self.button:UnregisterAllEvents()
	self.button:Hide()
	self.button = nil
	self.parent = nil

end