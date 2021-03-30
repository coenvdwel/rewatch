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
		spellBarHeight = 9,
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

	for key,field in pairs(self.fields) do field:Hide() end
	
	local left = 0
	local right = 1

	self.fields =
	{
		self:Number("spellBarWidth", "Frame size", 0, left),
		self:Number("scaling", "Scaling", 0, right),

		self:Number("healthBarHeight", "Healthbar size", 1, left),
		self:Number("numFramesWide", "Players per column", 1, right),

		self:Number("spellBarHeight", "Spellbar size", 2, left),
	}

	--rewatch_AddCheckbox(frame, layout, 0, 0, "", "")
	--rewatch_AddCheckbox(frame, layout, 0, 1, "", "")
	--rewatch_AddPercentage(frame, layout, 6, left, "Out of range fade", "OORAlpha")

end

-- activate profile
function RewatchOptions:ActivateProfile(guid)

	self.profile = rewatch_config.profiles[guid]

	if(self.selected) then
		self.activateButton:SetEnabled(self.selected.guid ~= self.profile.guid)
		self.deleteButton:SetEnabled(self.selected.guid ~= self.profile.guid)
	end

	rewatch_config.profile[rewatch.guid] = guid

end

-- text template
function RewatchOptions:Text(key, name, row, col)

	local o =
	{
		key = key,
		name = name,
		text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall"),
		input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")
	}
	
	o.text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10 + col*180, -60 - row*20)
	o.text:SetText(name)
	
	o.input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 100 + col*180, -60 - row*20)
	o.input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	o.input:SetWidth(70)
	o.input:SetHeight(15)
	o.input:SetAutoFocus(nil)
	o.input:SetFontObject(GameFontHighlight)
	o.input:SetText(self.selected[key])
	o.input:SetCursorPosition(0)
	-- todo: ontextchanged?

	o.Hide = function()
		o.input:Hide()
		o.text:Hide()
	end

	return o

end

-- number template
function RewatchOptions:Number(key, name, row, col)

	local o = self:Text(key, name, row, col)

	o.input:SetNumeric(true)
	o.input:SetMaxLetters(3)
	o.input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetNumber() < 1) then x:SetText(1) end
		if(x:GetNumber() > 999) then x:SetText(999) end
		
		self.selected[key] = x:GetNumber()
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)
	
	return o

end

function RewatchOptions:Percentage(key, name, row, col)

	local o = rewatch_AddText(key, name, row, col)

	o.input:SetNumeric(true)
	o.input:SetMaxLetters(3)
	o.input:SetText(self.selected[key]*100)
	o.input:SetCursorPosition(0)
	o.input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetNumber() < 0) then x:SetText(0) end
		if(x:GetNumber() > 100) then x:SetText(100) end

		self.selected[key] = x:GetNumber()/100
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)
	
	return o

end

function RewatchOptions:Checkbox(key, name, row, col)

	local o =
	{
		key = key,
		name = name,
		text = frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall"),
		input = CreateFrame("EDITBOX", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	}
	
	o.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + col*180, -60 - row*20)
	o.text:SetText(name)
	
	o.input:SetPoint("TOPLEFT", frame, "TOPLEFT", 100 + col*180, -60 - row*20)
	o.input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	o.input:SetWidth(70)
	o.input:SetHeight(15)
	o.input:SetAutoFocus(nil)
	o.input:SetNumeric(true)
	o.input:SetMaxLetters(3)
	o.input:SetFontObject(GameFontHighlight)
	o.input:SetText(rewatch_load["Layouts"][layout].values[key])
	o.input:SetCursorPosition(0)
	o.input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetNumber() < 1) then x:x(1) end
		if(x:GetNumber() > 999) then self:SetText(999) end
		
		self.selected[key] = x:GetNumber()/100
		if(self.selected.guid == self.profile.guid) then rewatch.clear = true end

	end)
	
	return o

end