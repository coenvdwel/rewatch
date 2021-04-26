RewatchDebuff = {}
RewatchDebuff.__index = RewatchDebuff

function RewatchDebuff:new(parent, spell, pos)

	local self =
	{
		frame = CreateFrame("Frame", nil, parent.health, BackdropTemplateMixin and "BackdropTemplate"),

		parent = parent,
		texture = nil,
		cooldown = nil,

		active = false,
		spell = nil,
		type = nil,
		icon = nil,
		expirationTime = nil,
		dispel = false,
	}

	rewatch:Debug("RewatchDebuff:new")

	setmetatable(self, RewatchDebuff)
	
	local size = rewatch:Scale(10)
	local x, y = size*pos + size/2, (size-self.parent.height)/2

	if(x > self.parent.width/2) then x = pos end -- overflow protection

	self.frame:SetWidth(size)
	self.frame:SetHeight(size)
	self.frame:SetPoint("TOPRIGHT", self.parent.health, "TOPRIGHT", -x, y)

	-- texture
	self.texture = self.frame:CreateTexture(nil, "ARTWORK")
	self.texture:SetAllPoints()

	-- cooldown
	self.cooldown = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
	self.cooldown:SetPoint("CENTER", 0, 0)
	self.cooldown:SetWidth(size)
	self.cooldown:SetHeight(size)
	self.cooldown:SetReverse(true)
	self.cooldown:Hide()

	self.text = self.cooldown:CreateFontString("$parentText", "ARTWORK", "NumberFontNormalYellow")
	self.text:SetAllPoints()

	-- border
	self.border = CreateFrame("FRAME", nil, self.cooldown, BackdropTemplateMixin and "BackdropTemplate")
	self.border:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 2 })
	self.border:SetBackdropBorderColor(0, 0, 0, 0)
	self.border:SetWidth(size)
	self.border:SetHeight(size)
	self.border:SetPoint("CENTER", 0, 0)

	-- events
	local lastUpdate, interval = 0, 1/20

	self.frame:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed
		if lastUpdate > interval then
			
			if(self.active and GetTime() > self.expirationTime) then
				self:Down()
			end

			lastUpdate = 0

		end
	
	end)

	-- init
	self:Up(spell)

	return self

end

-- bring it up
function RewatchDebuff:Up(spell)

	rewatch:Debug("RewatchDebuff:Up")

	local filter = "HARMFUL|RAID"
	local name, icon, count, type, expirationTime
	local dispel, color = true, nil

	if(rewatch.options.profile.notify1[spell]) then return end
	if(rewatch.options.profile.notify2[spell]) then filter = "HARMFUL"; dispel = false; color = { r=0.8, g=0.5, b=0.2 } end
	if(rewatch.options.profile.notify3[spell]) then filter = "HARMFUL"; dispel = false; color = { r=0.7, g=0.2, b=0.2 } end

	for i=1,40 do
		name, icon, count, type, _, expirationTime = UnitDebuff(self.parent.name, i, filter)
		if(name == nil) then break end
		if(name == spell) then break end
	end

	if(name ~= spell) then return end

	if(not color) then
		if(type == "Poison") then color = { r=0, g=0.3, b=0 }
		elseif(type == "Curse") then color = { r=0.5, g=0, b=0.5 }
		elseif(type == "Magic") then color = { r=0, g=0, b=0.5 }
		elseif(type == "Disease") then color = { r=0.5, g=0.5, b=0.0 }
		end
	end

	self.active = true
	self.spell = spell
	self.type = type
	self.icon = icon
	self.expirationTime = expirationTime
	self.dispel = dispel
	self.border:SetBackdropBorderColor(color.r*2, color.g*2, color.b*2, 1)

	self.texture:SetTexture(self.icon)
	self.texture:Show()

	if(count <= 1) then self.text:SetText("")
	else self.text:SetText(count)
	end

	local now = GetTime()
	local duration = expirationTime-now

	CooldownFrame_Set(self.cooldown, now, duration, true)

	if(self.dispel) then
		self.parent.frame:SetBackdropColor(color.r, color.g, color.b, 1)
		for _,button in pairs(self.parent.buttons) do button:SetAlpha(self.dispel) end
	end

end

-- bring it down
function RewatchDebuff:Down()

	rewatch:Debug("RewatchDebuff:Down")

	if(not self.active) then return end

	self.active = false
	self.texture:Hide()
	self.cooldown:Hide()
	self.border:SetBackdropBorderColor(0, 0, 0, 0)

	if(self.dispel) then
		self.parent.frame:SetBackdropColor(0.07, 0.07, 0.07, 1)
		for _,button in pairs(self.parent.buttons) do button:SetAlpha() end
	end

end

-- dispose
function RewatchDebuff:Dispose()

	rewatch:Debug("RewatchDebuff:Dispose")

	self.frame:Hide()

	self.icon = nil
	self.texture = nil
	self.cooldown = nil
	self.parent = nil

end