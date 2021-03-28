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
		displayName = name,

		playerBarInc = nil,
		playerBar = nil,
		debuffTexture = nil,
		manaBar = nil,
		aggroBar = nil,
		border = nil,

		bars = {},
		buttons = {}
    }

	setmetatable(self, RewatchPlayer)

	local powerType = rewatch:GetPowerBarColor(UnitPowerType(self.name))
	local classColors = RAID_CLASS_COLORS[select(2, GetClassInfo(self.classId or 11))]
	if(self.displayName:find("-")) then self.displayName = self.displayName:sub(1, self.displayName:find("-")-1).."*" end

	self.frame:SetWidth(rewatch.playerWidth)
	self.frame:SetHeight(rewatch.playerHeight)
	self.frame:SetPoint("TOPLEFT", rewatch.frame, "TOPLEFT", 0, 0)
	self.frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	self.frame:SetBackdropColor(0.07, 0.07, 0.07, 1)
	
	self:MoveTo(position)

	-- create player HP bar for estimated incoming health
	self.playerBarInc = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")

	if(rewatch.options.profile.layout == "horizontal") then
		self.playerBarInc:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.playerBarInc:SetHeight(rewatch:Scale(rewatch.options.profile.healthBarHeight * 0.8))
	elseif(rewatch.options.profile.layout == "vertical") then 
		self.playerBarInc:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth * 0.8) - (rewatch.options.profile.showButtons and rewatch.buttonSize or 0))
		self.playerBarInc:SetWidth(rewatch:Scale(rewatch.options.profile.healthBarHeight))
	end

	self.playerBarInc:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.playerBarInc:SetStatusBarTexture(rewatch.options.profile.bar)
	self.playerBarInc:GetStatusBarTexture():SetHorizTile(false)
	self.playerBarInc:GetStatusBarTexture():SetVertTile(false)
	self.playerBarInc:SetStatusBarColor(0.4, 1, 0.4, 1)
	self.playerBarInc:SetMinMaxValues(0, 1)
	self.playerBarInc:SetValue(0)
		
	-- create player HP bar
	self.playerBar = CreateFrame("STATUSBAR", nil, self.playerBarInc, "TextStatusBar")

	self.playerBar:SetWidth(self.playerBarInc:GetWidth())
	self.playerBar:SetHeight(self.playerBarInc:GetHeight())
	self.playerBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	self.playerBar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.playerBar:GetStatusBarTexture():SetHorizTile(false)
	self.playerBar:GetStatusBarTexture():SetVertTile(false)
	self.playerBar:SetStatusBarColor(0.07, 0.07, 0.07, 1)
	self.playerBar:SetMinMaxValues(0, 1)
	self.playerBar:SetValue(0)

	-- put text in HP bar
	self.playerBar.text = self.playerBar:CreateFontString("$parentText", "ARTWORK")
	self.playerBar.text:SetFont(rewatch.options.profile.font, rewatch:Scale(rewatch.options.profile.fontSize), "OUTLINE")
	self.playerBar.text:SetAllPoints()
	self.playerBar.text:SetText(self.displayName)
	self.playerBar.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1)
	
	-- role icon
	local roleIcon = self.playerBar:CreateTexture(nil, "OVERLAY")
	local role = UnitGroupRolesAssigned(self.name)

	roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES")
	roleIcon:SetSize(16, 16)
	roleIcon:SetPoint("TOPLEFT", self.playerBar, "TOPLEFT", 10, 8-self.playerBar:GetHeight()/2)
	
	if(role == "TANK") then
		roleIcon:SetTexCoord(0, 19/64, 22/64, 41/64)
		roleIcon:Show()
	elseif(role == "HEALER") then
		roleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64)
		roleIcon:Show()
	else
		roleIcon:Hide()
	end
	
	-- debuff icon
	local debuffIcon = CreateFrame("Frame", nil, self.playerBar, BackdropTemplateMixin and "BackdropTemplate")
	
	debuffIcon:SetWidth(16)
	debuffIcon:SetHeight(16)
	debuffIcon:SetPoint("TOPRIGHT", self.playerBar, "TOPRIGHT", -10, 8-self.playerBar:GetHeight()/2)
	debuffIcon:SetAlpha(0.8)

	-- debuff texture
	self.debuffTexture = debuffIcon:CreateTexture(nil, "ARTWORK")
	self.debuffTexture:SetAllPoints()

	-- create mana bar
	self.manaBar = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar")

	if(rewatch.options.profile.layout == "horizontal") then
		self.manaBar:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.manaBar:SetHeight(rewatch:Scale(rewatch.options.profile.healthBarHeight * 0.2))
	elseif(rewatch.options.profile.layout == "vertical") then
		self.manaBar:SetWidth(rewatch:Scale(rewatch.options.profile.healthBarHeight))
		self.manaBar:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth * 0.2))
	end

	self.manaBar:SetPoint("TOPLEFT", self.playerBar, "BOTTOMLEFT", 0, 0)
	self.manaBar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.manaBar:GetStatusBarTexture():SetHorizTile(false)
	self.manaBar:GetStatusBarTexture():SetVertTile(false)
	self.manaBar:SetMinMaxValues(0, 1)
	self.manaBar:SetValue(0)
	self.manaBar:SetStatusBarColor(powerType.r, powerType.g, powerType.b)

	-- create aggro bar
	self.aggroBar = CreateFrame("STATUSBAR", nil, self.manaBar, "TextStatusBar")

	self.aggroBar:SetPoint("TOPLEFT", self.manaBar, "TOPLEFT", 0, 0)
	self.aggroBar:SetHeight(2)
	self.aggroBar:SetWidth(self.manaBar:GetWidth())
	self.aggroBar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.aggroBar:GetStatusBarTexture():SetHorizTile(false)
	self.aggroBar:GetStatusBarTexture():SetVertTile(false)
	self.aggroBar:SetMinMaxValues(0, 1)
	self.aggroBar:SetValue(0)
	self.aggroBar:SetStatusBarColor(1, 0, 0)

	-- build border frame
	self.border = CreateFrame("FRAME", nil, self.playerBar, BackdropTemplateMixin and "BackdropTemplate")

	self.border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	self.border:SetBackdropBorderColor(0, 0, 0, 1)
	self.border:SetWidth(rewatch.playerWidth+1)
	self.border:SetHeight(rewatch.playerHeight+1)
	self.border:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -0, 0)

	-- bars
	local anchor = rewatch.options.profile.layout == "horizontal" and self.manaBar or self.playerBar

	local colors =
	{
		{ r=0, g=0.7, b=0, a=1 }, -- lifebloom
		{ r=0.85, g=0.15, b=0.80, a=1 }, -- reju
		{ r=0.4, g=0.85, b=0.34, a=1 }, -- germ
		{ r=0.05, g=0.3, b=0.1, a=1 }, -- regrowth
		{ r=0.5, g=0.8, b=0.3, a=1 }, -- wild growth
		{ r=0.0, g=0.1, b=0.8, a=1 }  -- riptide
	}

	for i,spell in pairs(rewatch.options.profile.bars) do

		self.bars[spell] = RewatchBar:new(spell, self, anchor, colors[i])
		anchor = self.bars[spell].bar

	end
	
	-- buttons
	if(rewatch.options.profile.showButtons == 1) then

		if(rewatch.options.profile.layout == "vertical") then anchor = self.manaBar end

		for i,spell in pairs(rewatch.options.profile["ButtonSpells"..rewatch.options.profile["ClassId"]]) do

			if(rewatch.classId == 7 and rewatch.spec ~= 3) then
				if(spell == rewatch_loc["naturescure"]) then spell = rewatch_loc["removecorruption"]
				elseif(spell == rewatch_loc["ironbark"]) then spell = rewatch_loc["barkskin"]
				end
			end

			if(select(3, GetSpellInfo(spellName))) then
				rewatch_bars[rewatch_i]["Buttons"][spell] = rewatch_CreateButton(spell, rewatch_i, anchor, i)
			end

		end
	end
	
	-- overlay target/remove button
	local overlay = CreateFrame("BUTTON", nil, self.playerBar, "SecureActionButtonTemplate")

	overlay:SetWidth(self.playerBar:GetWidth())
	overlay:SetHeight(self.playerBar:GetHeight()*1.25)
	overlay:SetPoint("TOPLEFT", self.playerBar, "TOPLEFT", 0, 0)
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
	
	rewatch.players[self.guid] = self
	
    return self

end


function RewatchPlayer:MoveTo(i)

	-- todo

end

function RewatchPlayer:Dispose()

	-- todo

end

-- sets the background color of this player's frame
function RewatchPlayer:SetFrameBG()

	-- high prio warning
	if(rewatch.players[guid].notify3) then rewatch.players[guid].frame:SetBackdropColor(1.0, 0.0, 0.0, 1)
		
	-- debuff warning
	elseif(rewatch.players[guid].debuff) then
	
		if(rewatch.players[guid].debuffType == "Poison") then rewatch.players[guid].frame:SetBackdropColor(0.0, 0.3, 0, 1)
		elseif(rewatch.players[guid].debuffType == "Curse") then rewatch.players[guid].frame:SetBackdropColor(0.5, 0.0, 0.5, 1)
		elseif(rewatch.players[guid].debuffType == "Magic") then rewatch.players[guid].frame:SetBackdropColor(0.0, 0.0, 0.5, 1)
		elseif(rewatch.players[guid].debuffType == "Disease") then rewatch.players[guid].frame:SetBackdropColor(0.5, 0.5, 0.0, 1)
		end
		
	-- medium/ow prio warning
	elseif(rewatch.players[guid].notify2) then rewatch.players[guid].frame:SetBackdropColor(1.0, 0.5, 0.1, 1)
	elseif(rewatch.players[guid].notify) then rewatch.players[guid].frame:SetBackdropColor(0.9, 0.8, 0.2, 1)
		
	-- default
	else rewatch.players[guid].frame:SetBackdropColor(0.07, 0.07, 0.07, 1) end
	
end
