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
	self.selector:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 75, -10)

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
	
	local left = 0
	local right = 1

	self.fields =
	{
		self:Text("name", "Name", 0, left, true),

		self:Number("spellBarWidth", "Size: Frame", 2, left),
		self:Number("healthBarHeight", "Size: Health bar", 3, left),
		self:Number("spellBarHeight", "Size: Spell bar", 4, left),
		self:Number("scaling", "Scaling", 5, left),

		self:Dropdown("layout", "Spell bar orientation", 2, right, { "horizontal", "vertical" }),
		self:Dropdown("grow", "Grow: direction", 3, right, { "down", "right" }),
		self:Number("numFramesWide", "Grow: max players", 4, right),

		self:Checkbox("showButtons", "Show buttons", 7, left),
		self:Checkbox("showTooltips", "Show tooltips", 7, right),

		self:Text("bar", "Texture", 9, left, true),
		self:Text("font", "Font", 10, left, true),
		self:Number("fontSize", "Font size", 11, left),

		self:Popup("altMacro", "Alt macro", 12, left),
		self:Popup("ctrlMacro", "Ctrl macro", 12, (left+right)/2),
		self:Popup("shiftMacro", "Shift macro", 12, right),

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

-- text template
function RewatchOptions:Text(key, name, row, col, wide)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")

	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10 + col*180, -62 - row*20)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 100 + col*180, -60 - row*20)
	input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	input:SetWidth(wide and 250 or 70)
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
function RewatchOptions:Number(key, name, row, col)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")

	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10 + col*180, -62 - row*20)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 100 + col*180, -60 - row*20)
	input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	input:SetWidth(wide and 250 or 70)
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
function RewatchOptions:Dropdown(key, name, row, col, values)
	
	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10 + col*180, -62 - row*20)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 82 + col*180, -50 - row*20)

	UIDropDownMenu_SetWidth(input, 70)
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
function RewatchOptions:Checkbox(key, name, row, col)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("CHECKBUTTON", nil, self.frame, "ChatConfigCheckButtonTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10 + col*180, -62 - row*20)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 100 + col*180, -60 - row*20)
	input:SetChecked(self.selected[key])
	
	input:SetScript("OnClick", function()

		self.selected[key] = input:GetChecked()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)

	return function() input:Hide(); text:Hide() end

end

-- popup template
function RewatchOptions:Popup(key, name, row, col)

	local button = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")

	button:SetHeight(28)
	button:SetWidth(75)
	button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10 + col*180, -62 - row*20)
	button:SetText(name)

	button:SetScript("OnClick", function()

		local popup = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

		popup:SetHeight(400)
		popup:SetWidth(600)
		popup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		popup:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
		popup:SetBackdropColor(1, 0.49, 0.04, 1)
		popup:SetFrameStrata("DIALOG")
		popup:Show()

		--self.selected[key] = x:GetText()
		--if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)

	return function() button:Hide() end

end