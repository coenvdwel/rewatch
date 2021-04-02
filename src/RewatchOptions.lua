RewatchOptions = {}
RewatchOptions.__index = RewatchOptions

function RewatchOptions:new()
    
    local self =
    {
		frame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate"),

		profile = nil,
		selected = nil,
		selector = nil,
		activateButton = nil,
		deleteButton = nil,
		fields = {}
    }

	setmetatable(self, RewatchOptions)

	self.frame.name = "Rewatch"

	-- new profile button
	local newProfile = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	newProfile:SetText("New")
	newProfile:SetHeight(28)
	newProfile:SetWidth(75)
	newProfile:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -10)
	newProfile:SetScript("OnClick", function() StaticPopup_Show("REWATCH_ADD_PROFILE") end)
	
	-- profile selector
	self.selector = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	self.selector:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 80, -10)

	UIDropDownMenu_SetWidth(self.selector, 150)
	UIDropDownMenu_Initialize(self.selector, function()
		for _,profile in pairs(rewatch_config.profiles) do
			UIDropDownMenu_AddButton({
				value = profile.guid,
				text = profile.name,
				colorCode = self.profile and profile.guid == self.profile.guid and "|cffff7d0a" or "",
				checked = self.selected and profile.guid == self.selected.guid,
				func = function(x) self:SelectProfile(x.value) end
			})
		end
	end)

	-- activate button
	self.activateButton = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	self.activateButton:SetText("Activate")
	self.activateButton:SetHeight(28)
	self.activateButton:SetWidth(75)
	self.activateButton:Disable()
	self.activateButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 275, -10)
	self.activateButton:SetScript("OnClick", function() self:ActivateProfile(self.selected.guid) end)

	-- delete button
	self.deleteButton = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	self.deleteButton:SetText("Delete")
	self.deleteButton:SetHeight(28)
	self.deleteButton:SetWidth(75)
	self.deleteButton:Disable()
	self.deleteButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 350, -10)
	self.deleteButton:SetScript("OnClick", function() StaticPopup_Show("REWATCH_DELETE_PROFILE", self.selected.name) end)

	-- add profile prompt
	StaticPopupDialogs["REWATCH_ADD_PROFILE"] =
	{
		text = "Please enter the new layout name:",
		button1 = "OK",
		button2 = "Cancel",
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		hasEditBox = true,
		preferredIndex = 3,
		OnAccept = function(x)
			if(not x.editBox:GetText()) then return end
			self:SelectProfile(self:CreateProfile(x.editBox:GetText()).guid)
		end,
		EditBoxOnEnterPressed = function(x)
			if(not x:GetText()) then return end
			self:SelectProfile(self:CreateProfile(x:GetText()).guid)
			x:GetParent():Hide()
		end
	}
	
	-- delete profile prompt
	StaticPopupDialogs["REWATCH_DELETE_PROFILE"] =
	{
		text = "Are you sure you want to delete %s?",
		button1 = "Yes",
		button2 = "No",
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		showAlert = true,
		preferredIndex = 3,
		OnAccept = function()
			rewatch_config.profiles[self.selected.guid] = nil
			self:SelectProfile(self.profile.guid)
		end
	}

	self:ActivateProfile(rewatch_config.profile[rewatch.guid] or self:CreateProfile(rewatch.name).guid)
	self:SelectProfile(self.profile.guid)

	InterfaceOptions_AddCategory(self.frame)

	return self

end

-- create profile
function RewatchOptions:CreateProfile(name)
	
	local profile =
	{
		name = name,
		guid = rewatch:NewId(),

		spellBarWidth = 25,
		spellBarHeight = 7,
		healthBarHeight = 75,
		scaling = (GetScreenWidth() > 2048) and 200 or 100,
		numFramesWide = 5,
		
		bar = "Interface\\AddOns\\Rewatch\\assets\\Bar.tga",
		font = "Interface\\AddOns\\Rewatch\\assets\\BigNoodleTitling.ttf",
		fontSize = 10,
		layout = "vertical",
		grow = "down",
		notify1 = {},
		notify2 = {},
		notify3 = {},
		
		showButtons = false,
		showTooltips = true,

		altMacro = nil,
		ctrlMacro = nil,
		shiftMacro = nil,
		
		bars = {},
		buttons = {},
		spell = nil
	}

	-- shaman
	if(rewatch.classId == 7) then

		profile.bars = { rewatch.locale["riptide"] }
		profile.buttons = { rewatch.locale["purifyspirit"], rewatch.locale["healingsurge"], rewatch.locale["healingwave"], rewatch.locale["chainheal"] }
		profile.spell = rewatch.locale["healingsurge"]

	end
	
	-- druid
	if(rewatch.classId == 11) then

		profile.bars = { rewatch.locale["lifebloom"], rewatch.locale["rejuvenation"], rewatch.locale["regrowth"], rewatch.locale["wildgrowth"], rewatch.locale["cenarion ward"] }
		profile.buttons = { rewatch.locale["swiftmend"], rewatch.locale["naturescure"], rewatch.locale["ironbark"], rewatch.locale["mushroom"] }
		profile.spell = rewatch.locale["rejuvenation"]

		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["naturescure"]
		profile.ctrlMacro = "/cast [@mouseover] "..rewatch.locale["naturesswiftness"].."/cast [@mouseover] "..rewatch.locale["regrowth"]
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch.rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch.locale["rebirth"].."; "..rewatch.locale["revive"].."\n/targetlasttarget"

	end

	rewatch_config.profiles[profile.guid] = profile

	return profile

end

-- select profile
function RewatchOptions:SelectProfile(guid)
	
	self.selected = rewatch_config.profiles[guid]
	self.activateButton:SetEnabled(self.selected.guid ~= self.profile.guid)
	self.deleteButton:SetEnabled(self.selected.guid ~= self.profile.guid)

	UIDropDownMenu_SetText(self.selector, self.selected.name)

	for _,dispose in pairs(self.fields) do dispose() end

	self.fields =
	{
		self:Text("name", "Name", self:Left(0)),

		self:Number("spellBarWidth", "Size: Frame", self:Left(2)),
		self:Number("healthBarHeight", "Size: Health bar", self:Left(3)),
		self:Number("spellBarHeight", "Size: Spell bar", self:Left(4)),
		self:Number("scaling", "Scaling", self:Left(5)),

		self:Dropdown("layout", "Spell bar orientation", self:Right(2), { "horizontal", "vertical" }),
		self:Dropdown("grow", "Grow: direction", self:Right(3), { "down", "right" }),
		self:Number("numFramesWide", "Grow: max players", self:Right(4)),

		self:Checkbox("showButtons", "Show buttons", self:Left(7)),
		self:Checkbox("showTooltips", "Show tooltips", self:Right(7)),

		self:Text("bar", "Texture", self:Left(9)),
		self:Text("font", "Font", self:Left(10)),
		self:Number("fontSize", "Font size", self:Left(11)),

		self:Popup("notify3", "Notify (HIGH)", self:Right(13), true),
		self:Popup("notify2", "Notify (DEF)", self:Right(15), true),
		self:Popup("notify1", "Notify (LOW)", self:Right(17), true),

		self:Popup("altMacro", "Alt macro", self:Right(13, 90)),
		self:Popup("ctrlMacro", "Ctrl macro", self:Right(15, 90)),
		self:Popup("shiftMacro", "Shift macro", self:Right(17, 90)),
	}

end

-- activate profile
function RewatchOptions:ActivateProfile(guid)

	self.profile = rewatch_config.profiles[guid]
	rewatch_config.profile[rewatch.guid] = guid

	if(self.selected) then

		self.activateButton:SetEnabled(self.selected.guid ~= self.profile.guid)
		self.deleteButton:SetEnabled(self.selected.guid ~= self.profile.guid)
	
		rewatch.clear = true

	end

end

function RewatchOptions:Left(row, offset)
	return { x =  10 + (offset or 0), y = -60 - row*20 }
end

function RewatchOptions:Right(row, offset)
	return { x = 230 + (offset or 0), y = -60 - row*20 }
end

-- text template
function RewatchOptions:Text(key, name, pos)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")

	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 90, pos.y)
	input:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	input:SetBackdropColor(0.2, 0.2, 0.2, 1)
	input:SetWidth(320)
	input:SetHeight(15)
	input:SetAutoFocus(nil)
	input:SetFontObject(GameFontHighlight)
	input:SetText(self.selected[key])
	input:SetCursorPosition(0)
	input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetText() == self.selected[key]) then return end
		
		self.selected[key] = x:GetText()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)

	return function() input:Hide(); text:Hide() end

end

-- number template
function RewatchOptions:Number(key, name, pos)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")

	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 90, pos.y)
	input:SetJustifyH("RIGHT")
	input:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	input:SetBackdropColor(0.2, 0.2, 0.2, 1)
	input:SetWidth(100)
	input:SetHeight(15)
	input:SetAutoFocus(nil)
	input:SetFontObject(GameFontHighlight)
	input:SetText(self.selected[key])
	input:SetCursorPosition(0)
	input:SetNumeric(true)
	input:SetMaxLetters(3)
	input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetNumber() < 1) then x:SetText(1) end
		if(x:GetNumber() > 999) then x:SetText(999) end
		if(x:GetNumber() == self.selected[key]) then return end

		self.selected[key] = x:GetNumber()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)

	return function() input:Hide(); text:Hide() end

end

-- dropdown template
function RewatchOptions:Dropdown(key, name, pos, values)
	
	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 72, pos.y + 10)
	
	UIDropDownMenu_SetWidth(input, 85)
	UIDropDownMenu_SetText(input, self.selected[key])
	UIDropDownMenu_Initialize(input, function()
		for _,value in ipairs(values) do
			UIDropDownMenu_AddButton({
				value = value,
				text = value,
				checked = value == self.selected[key],
				func = function(x)
					
					if(self.selected[key] == x.value) then return end

					self.selected[key] = x.value
					if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

				end
			})
		end
	end)

	return function() input:Hide(); text:Hide() end

end

-- checkbox template
function RewatchOptions:Checkbox(key, name, pos)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("CHECKBUTTON", nil, self.frame, "ChatConfigCheckButtonTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 90, pos.y + 5)
	input:SetChecked(self.selected[key])
	
	input:SetScript("OnClick", function()

		self.selected[key] = input:GetChecked()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)

	return function() input:Hide(); text:Hide() end

end

-- popup template
function RewatchOptions:Popup(key, name, pos, table)

	local button = CreateFrame("BUTTON", nil, self.frame, "UIMenuButtonStretchTemplate") -- GameMenuButtonTemplate, UIPanelButtonGrayTemplate

	button:SetHeight(35)
	button:SetWidth(100)
	button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	button:SetText(name)

	button:SetScript("OnClick", function()

		local popup = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
		popup:SetHeight(200)
		popup:SetWidth(300)
		popup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		popup:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, edgeSize = 1 })
		popup:SetBackdropBorderColor(0, 0, 0, 1)
		popup:SetBackdropColor(0.07, 0.07, 0.07, 1)
		popup:SetFrameStrata("DIALOG")
		popup:SetMovable(true)
		popup:SetScript("OnMouseDown", function() popup:StartMoving() end)
		popup:SetScript("OnMouseUp", function() popup:StopMovingOrSizing() end)

		local text = popup:CreateFontString("$parentText", "ARTWORK", "GameTooltipText")
		text:SetPoint("TOP", popup, "TOP", 0, -10)
		text:SetText(name)
		text:SetTextColor(1, 1, 0, 1)

		local input = CreateFrame("EDITBOX", nil, popup, BackdropTemplateMixin and "BackdropTemplate")
		input:SetPoint("TOP", popup, "TOP", 0, -40)
		input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
		input:SetMultiLine(true)
		input:SetHeight(110)
		input:SetWidth(280)
		input:SetAutoFocus(nil)
		input:SetFontObject(GameFontHighlight)

		if(table) then
			-- todo
		else
			input:SetText(self.selected[key])
		end
		
		input:SetCursorPosition(0)
		input:SetJustifyV("TOP")
		input:SetJustifyH("LEFT")
		input:SetFocus()
		input:SetScript("OnEscapePressed", function() popup:Hide() end)

		local close = CreateFrame("BUTTON", nil, popup, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, 2)
		close:SetWidth(20)
		close:SetScript("OnClick", function() popup:Hide() end)

		local save = CreateFrame("BUTTON", nil, popup, "OptionsButtonTemplate")
		save:SetText("Save")
		save:SetPoint("BOTTOM", popup, "BOTTOM", 0, 10)
		save:SetWidth(280)
		save:SetScript("OnClick", function()

			if(table) then
				-- todo
			else
				if(self.selected[key] ~= x:GetText()) then

					self.selected[key] = x:GetText()
					if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

				end
			end

			popup:Hide()
		
		end)

		popup:Show()

	end)

	return function() button:Hide() end

end