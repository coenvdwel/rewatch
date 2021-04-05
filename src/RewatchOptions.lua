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

	-- add rest of the fields
	self.fields =
	{
		self:Text("name", "Name", self:Left(0)),

		self:Checkbox("hide", "Hide", self:Left(2)),
		self:Number("spellBarWidth", "Size: Frame", self:Left(3)),
		self:Number("healthBarHeight", "Size: Health bar", self:Left(4)),
		self:Number("spellBarHeight", "Size: Spell bar", self:Left(5)),

		self:Dropdown("layout", "Spell bar orientation", self:Right(2), { "horizontal", "vertical" }),
		self:Dropdown("grow", "Grow: direction", self:Right(3), { "down", "right" }),
		self:Number("numFramesWide", "Grow: max players", self:Right(4)),
		self:Number("scaling", "Scaling", self:Right(5)),

		self:Checkbox("showButtons", "Show buttons", self:Left(7)),
		self:Checkbox("showTooltips", "Show tooltips", self:Right(7)),

		self:Text("bar", "Texture", self:Left(9)),
		self:Text("font", "Font", self:Left(10)),
		self:Number("fontSize", "Font size", self:Left(11)),

		self:Multi(self:Left(13),
		{
			{ key = "buttons", name = "Buttons", type = "list" },
			{ key = "bars", name = "Spells", type = "list" },
			{ key = "notify3", name = "Highlight", type = "table" },
		 	{ key = "notify2", name = "Mediumlight", type = "table" },
			{ key = "notify1", name = "Lowlight", type = "table" },
			{ key = "altMacro", name = "Alt macro", type = "text" },
	 		{ key = "ctrlMacro", name = "Ctrl macro", type = "text" },
			{ key = "shiftMacro", name = "Shift macro", type = "text" },
		}),
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
		hide = false,

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
		profile.ctrlMacro = "/cast [@mouseover] "..rewatch.locale["naturesswiftness"].."\n/cast [@mouseover] "..rewatch.locale["regrowth"]
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

	for _,reset in pairs(self.fields) do reset() end

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
	input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetText() == self.selected[key]) then return end
		
		self.selected[key] = x:GetText()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)

	return function()
		input:SetText(self.selected[key])
		input:SetCursorPosition(0)
	end

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

	return function()
		input:SetText(self.selected[key])
		input:SetCursorPosition(0)
	end

end

-- dropdown template
function RewatchOptions:Dropdown(key, name, pos, values)
	
	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 72, pos.y + 10)
	
	UIDropDownMenu_SetWidth(input, 85)
	UIDropDownMenu_Initialize(input, function()
		for _,value in ipairs(values) do
			UIDropDownMenu_AddButton({
				value = value,
				text = value,
				checked = self.selected and value == self.selected[key],
				func = function(x)
					
					if(self.selected[key] == x.value) then return end

					self.selected[key] = x.value
					if(self.selected.guid == self.profile.guid) then rewatch.clear = true end
					UIDropDownMenu_SetText(input, self.selected[key])

				end
			})
		end
	end)

	return function()
		UIDropDownMenu_SetText(input, self.selected[key])
	end

end

-- checkbox template
function RewatchOptions:Checkbox(key, name, pos)

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("CHECKBUTTON", nil, self.frame, "ChatConfigCheckButtonTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 90, pos.y + 5)
	input:SetScript("OnClick", function()

		if(self.selected[key] == input:GetChecked()) then return end

		self.selected[key] = input:GetChecked()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end
		if(key == "hide") then rewatch.frame:Show() end

	end)

	return function()
		input:SetChecked(self.selected[key])
	end

end

-- multi template
function RewatchOptions:Multi(pos, fields)

	local currentField = nil

	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 90, pos.y)
	input:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", pos.x + 90, pos.y - 138) -- sets height
	input:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	input:SetBackdropColor(0.2, 0.2, 0.2, 1)
	input:SetMultiLine(true)
	input:SetWidth(320)
	input:SetAutoFocus(nil)
	input:SetFontObject(GameFontHighlight)

	local save = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	save:SetText("Save")
	save:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 87, pos.y - 138)
	save:SetWidth(233)

	local cancel = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	cancel:SetText("Cancel")
	cancel:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 320, pos.y - 138)
	cancel:SetWidth(93)

	save:SetScript("OnClick", function() currentField.save() end)
	cancel:SetScript("OnClick", function() currentField.reset() end)

	for i,field in ipairs(fields) do

		field.button = CreateFrame("BUTTON", nil, self.frame)

		field.button:SetHeight(35)
		field.button:SetWidth(90)
		field.button:SetNormalFontObject("GameFontNormalSmall")
		field.button:SetHighlightFontObject("GameFontHighlightSmall")
		field.button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y - (i-1)*20 + 10)
		field.button:SetText(field.name)
		field.button:SetScript("OnClick", function()

			field.button:SetNormalFontObject("GameFontHighlightSmall")
			currentField.button:SetNormalFontObject("GameFontNormalSmall")
			currentField = field
			currentField.reset()
			input:SetFocus()

		end)

		field.save = function()

			if(currentField.type == "list") then

				local lines = {}
				local changed = false

				for v in input:GetText():gmatch("[^\r\n]+") do table.insert(lines, v) end
				for i,v in ipairs(self.selected[currentField.key]) do changed = changed or lines[i] == v end

				if(changed) then

					self.selected[currentField.key] = {}
					for i,v in ipairs(lines) do self.selected[currentField.key][i] = v end

					if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

				end

			elseif(currentField.type == "table") then
				
				local lines = {}
				local changed = false

				for k in input:GetText():gmatch("[^\r\n]+") do lines[k] = true end
				for k,v in pairs(self.selected[currentField.key]) do changed = changed or lines[k] == v end

				if(changed) then

					self.selected[currentField.key] = {}
					for k,v in pairs(lines) do self.selected[currentField.key][k] = v end
					
					if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

				end

			else

				if(self.selected[currentField.key] ~= input:GetText()) then

					self.selected[currentField.key] = input:GetText()
					if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

				end
			end
		end

		field.reset = function()
	
			local text = ""
	
			if(currentField.type == "list") then
				for i,v in ipairs(self.selected[currentField.key]) do text = text..v.."\r\n" end
			elseif(currentField.type == "table") then
				for k,v in pairs(self.selected[currentField.key]) do text = text..k.."\r\n" end
			else
				text = self.selected[currentField.key]
			end

			input:SetText(text)
			input:SetCursorPosition(0)
	
		end

		if(currentField == nil) then
			currentField = field
			field.button:SetNormalFontObject("GameFontHighlightSmall")
		end

	end

	return currentField.reset

end