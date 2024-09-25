RewatchDebuff = {}
RewatchDebuff.__index = RewatchDebuff

function RewatchDebuff:new(parent, spell)

	local self =
	{
		spell = spell,

		frame = nil,
		parent = parent,
		cooldown = nil,
		text = nil,

		active = false,
		expirationTime = nil,
		count = 0,
		color = nil,
		type = nil,
		dispel = false,
		ignore = false,
	}

	rewatch:Debug("RewatchDebuff:new")

	setmetatable(self, RewatchDebuff)

	-- get info
	if(rewatch.options.profile.notify1[self.spell]) then

		self.ignore = true
		return self

	end

	local found, icon, count, type, expirationTime = self:Find(true)

	if(found) then

		self.dispel = true

		if(type == "Poison") then self.color = { r=0, g=0.3, b=0 }
		elseif(type == "Curse") then self.color = { r=0.5, g=0, b=0.5 }
		elseif(type == "Magic") then self.color = { r=0, g=0, b=0.5 }
		elseif(type == "Disease") then self.color = { r=0.5, g=0.5, b=0.0 }
		end

	else

		self.dispel = false

		if(rewatch.options.profile.notify2[self.spell]) then

			found, icon, count, type, expirationTime = self:Find()
			self.color = { r=0.5, g=0.5, b=0.1 }

		elseif(rewatch.options.profile.notify3[self.spell]) then

			found, icon, count, type, expirationTime = self:Find()
			self.color = { r=0.5, g=0.1, b=0.1 }

		end

		if(not found) then

			self.ignore = true
			return self

		end

	end

	self.active = true
	self.count = count
	self.expirationTime = expirationTime
	self.type = type

	-- frame
	self.frame = CreateFrame("Frame", nil, parent.health, BackdropTemplateMixin and "BackdropTemplate")
	self.frame:SetWidth(parent.debuffSize)
	self.frame:SetHeight(parent.debuffSize)

	-- texture
	local texture = self.frame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture(icon)
	texture:SetAllPoints()

	-- cooldown
	self.cooldown = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
	self.cooldown:SetPoint("CENTER", 0, 0)
	self.cooldown:SetWidth(parent.debuffSize)
	self.cooldown:SetHeight(parent.debuffSize)
	self.cooldown:SetReverse(true)
	self.cooldown:Hide()

	-- text
	self.text = self.cooldown:CreateFontString("$parentText", "ARTWORK", "NumberFontNormalYellow")
	self.text:SetAllPoints()

	-- border
	local border = CreateFrame("FRAME", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")
	border:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 2 })
	border:SetBackdropBorderColor(self.color.r*2, self.color.g*2, self.color.b*2, 1)
	border:SetWidth(parent.debuffSize)
	border:SetHeight(parent.debuffSize)
	border:SetPoint("CENTER", 0, 0)

	-- events
	local lastUpdate, interval = 0, 1/20

	self.frame:SetScript("OnUpdate", function(_, elapsed)

		lastUpdate = lastUpdate + elapsed
		if lastUpdate > interval then

			if(self.active and self.expirationTime > 0 and GetTime() > self.expirationTime) then
				self:Down()
			end

			lastUpdate = 0

		end

	end)

	self:Activate()

	return self

end

-- find and return debuff info
function RewatchDebuff:Find(dispellable)

	rewatch:Debug("RewatchDebuff:Find")

	local auraData
	local filter = ((self.dispel or dispellable) and "HARMFUL|RAID") or "HARMFUL"

	for i=1,40 do
		auraData = C_UnitAuras.GetDebuffDataByIndex(self.parent.name, i, filter)
		if(auraData == nil) then return false end
		if(auraData.name == self.spell) then break end
	end

	if(auraData.name ~= self.spell) then return false end

	return true, auraData.icon, auraData.applications, auraData.dispelName, auraData.expirationTime

end

-- check if we need to activate
function RewatchDebuff:Up()

	rewatch:Debug("RewatchDebuff:Up")

	if(self.ignore) then return end

	local found, _, count, _, expirationTime = self:Find()

	if(not found) then return end

	self.expirationTime = expirationTime
	self.count = count

	if(self.active) then self:Draw(); return end

	self:Activate()

end

-- bring it down
function RewatchDebuff:Down()

	rewatch:Debug("RewatchDebuff:Down")

	if(not self.active) then return end

	local found, _, count, _, expirationTime = self:Find()

	if(found) then

		self.expirationTime = expirationTime
		self.count = count

		self:Draw()

		return

	end

	self.active = false

	if(self.dispel) then
		self.parent.frame:SetBackdropColor(0.07, 0.07, 0.07, 1)
		for _,button in pairs(self.parent.buttons) do button:SetAlpha() end
	end

	for i,debuff in ipairs(self.parent.debuffs.active) do
		if(debuff.spell == self.spell) then
			table.remove(self.parent.debuffs.active, i)
			break;
		end
	end

	self.frame:Hide()
	self.parent:UpdateDebuffs()

end

-- activate debuff and trigger redraw
function RewatchDebuff:Activate()

	self.active = true

	table.insert(self.parent.debuffs.active, self)

	if(self.dispel) then
		self.parent.frame:SetBackdropColor(self.color.r, self.color.g, self.color.b, 1)
		for _,button in pairs(self.parent.buttons) do button:SetAlpha(self.dispel) end
	end

	self.parent:UpdateDebuffs() -- will call self:Draw with desired position

end

-- bring it up
function RewatchDebuff:Draw(pos, offset)

	local now = GetTime()
	local duration = ((self.expirationTime == 0) and 999999) or (self.expirationTime-now)

	if(pos and offset) then

		local x, y = offset*(pos - 1) + self.parent.debuffSize/2, (self.parent.debuffSize-self.parent.height)/2

		self.frame:SetPoint("TOPRIGHT", self.parent.health, "TOPRIGHT", -x, y)

	end

	self.text:SetText((self.count <= 1) and "" or self.count)

	self.frame:Show()

	CooldownFrame_Set(self.cooldown, now, duration, true)

end

-- dispose
function RewatchDebuff:Dispose()

	rewatch:Debug("RewatchDebuff:Dispose")

	if(self.ignore) then return end

	self.frame:Hide()

	self.frame = nil
	self.cooldown = nil
	self.text = nil
	self.parent = nil

end