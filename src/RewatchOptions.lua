RewatchOptions = {}
RewatchOptions.__index = RewatchOptions

function RewatchOptions:new()
    
    local self =
    {
		frame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate"),

		profile = nil,
		selected = nil,
		fields = {},

		newButton = nil,
		activateButton = nil,
		deleteButton = nil,
		profileSelector = nil,
		activationSelector = nil,
		activationOptions = {}
    }

	rewatch:Debug("RewatchOptions:new")

	setmetatable(self, RewatchOptions)

	self.frame.name = "Rewatch"
	self.frame.default = function() rewatch_config = nil; ReloadUI() end

	-- new profile button
	self.newButton = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	self.newButton:SetText("New")
	self.newButton:SetHeight(28)
	self.newButton:SetWidth(100)
	self.newButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -10)
	self.newButton:SetScript("OnClick", function() StaticPopup_Show("REWATCH_ADD_PROFILE") end)
	
	-- profile selector
	self.profileSelector = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	self.profileSelector:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 100, -10)

	UIDropDownMenu_SetWidth(self.profileSelector, 160)
	UIDropDownMenu_Initialize(self.profileSelector, function()

		for _,profile in pairs(rewatch_config.profiles) do
			UIDropDownMenu_AddButton(
			{
				text = profile.name,
				value = profile.guid,
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
	self.activateButton:SetWidth(100)
	self.activateButton:Disable()
	self.activateButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 300, -10)
	self.activateButton:SetScript("OnClick", function() self:ActivateProfile(self.selected.guid) end)

	-- delete button
	self.deleteButton = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	self.deleteButton:SetText("Delete")
	self.deleteButton:SetHeight(28)
	self.deleteButton:SetWidth(100)
	self.deleteButton:Disable()
	self.deleteButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 400, -10)
	self.deleteButton:SetScript("OnClick", function() StaticPopup_Show("REWATCH_DELETE_PROFILE", self.selected.name) end)

	-- auto-activate selector
	self.activationSelector = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	self.activationSelector:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self:Right(7).x + 92, self:Right(7).y + 10)
	
	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self:Right(7).x, self:Right(7).y)
	text:SetText("Auto-activate")

	self.activationOptions =
	{
		group =
		{
			text = "Group",
			isTitle = true,
			options =
			{
				{ text = "Solo", isActive = function() return not IsInGroup() end },
				{ text = "Party", isActive = function() return IsInGroup() and not IsInRaid() end },
				{ text = "Raid", isActive = function() return IsInRaid() end },
			}
		},
		spec =
		{
			text = "Spec",
			isTitle = true,
			options = {}
		}
	}

	for i=1,GetNumSpecializations() do
		table.insert(self.activationOptions.spec.options,
		{
			text = select(2, GetSpecializationInfo(i)),
			value = i,
			isActive = function(x) return GetSpecialization() == x end
		})
	end

	UIDropDownMenu_SetText(self.activationSelector, self:AutoActivateProfileText())
	UIDropDownMenu_SetWidth(self.activationSelector, 105)
	UIDropDownMenu_Initialize(self.activationSelector, function()

		for _,group in pairs(self.activationOptions) do

			UIDropDownMenu_AddButton({ text = group.text, isTitle = true, notCheckable = true })

			for _,option in ipairs(group.options) do
				UIDropDownMenu_AddButton(
				{
					text = option.text,
					value = option.value,
					keepShownOnClick = true,
					colorCode = option.isActive and option.isActive(option.value) and "|cffff7d0a" or "",
					checked = self.selected and self.selected.autoActivate and self.selected.autoActivate[rewatch.guid] and self.selected.autoActivate[rewatch.guid][option.value or option.text],
					func = function(x, _, _, value)
						
						if(not self.selected.autoActivate) then self.selected.autoActivate = {} end
						if(not self.selected.autoActivate[rewatch.guid]) then self.selected.autoActivate[rewatch.guid] = {} end
	
						self.selected.autoActivate[rewatch.guid][x.value or x.text] = value;
						UIDropDownMenu_SetText(self.activationSelector, self:AutoActivateProfileText())

					end
				})
			end
		end
	end)

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

		self:Number("spellBarWidth", "Size: Frame", self:Left(2)),
		self:Number("healthBarHeight", "Size: Health bar", self:Left(3)),
		self:Number("manaBarHeight", "Size: Mana bar", self:Left(4)),
		self:Number("spellBarHeight", "Size: Spell bar", self:Left(5)),

		self:Dropdown("layout", "Spell bar orientation", self:Right(2), { "horizontal", "vertical" }),
		self:Dropdown("grow", "Grow: direction", self:Right(3), { "down", "right" }),
		self:Number("numFramesWide", "Grow: max players", self:Right(4)),
		self:Number("scaling", "Scaling", self:Right(5)),

		self:Checkbox("hide", "Hide", self:Left(7)),
		self:Checkbox("showButtons", "Show buttons", self:Left(8)),
		self:Checkbox("showTooltips", "Show tooltips", self:Left(9)),

		function() UIDropDownMenu_SetText(self.activationSelector, self:AutoActivateProfileText()) end,

		self:Text("bar", "Texture", self:Left(11)),
		self:Text("font", "Font", self:Left(12)),
		self:Number("fontSize", "Font size", self:Left(13)),

		self:Multi(self:Left(15),
		{
			{ key = "bars", name = "Spells", type = "list" },
			{ key = "buttons", name = "Buttons", type = "list" },
			{ key = "notify3", name = "Highlight: red", type = "table" },
		 	{ key = "notify2", name = "Highlight: orange", type = "table" },
			{ key = "notify1", name = "Highlight: ignore", type = "table" },
			{ key = "altMacro", name = "Macro: Alt", type = "text" },
	 		{ key = "ctrlMacro", name = "Macro: Ctrl", type = "text" },
			{ key = "shiftMacro", name = "Macro: Shift", type = "text" },
		}),
	}

	self:ActivateProfile(rewatch_config.profile[rewatch.guid] or self:CreateProfile(table.concat({UnitFullName("player")}, "-")).guid)
	self:SelectProfile(self.profile.guid)

	InterfaceOptions_AddCategory(self.frame)

	return self

end

-- create profile
function RewatchOptions:CreateProfile(name)
	
	rewatch:Debug("RewatchOptions:CreateProfile")

	local profile =
	{
		name = name,
		guid = rewatch:NewId(),

		spellBarWidth = 25,
		spellBarHeight = 7,
		healthBarHeight = 75,
		manaBarHeight = 5,
		scaling = (GetScreenWidth() > 2048) and 200 or 100,
		numFramesWide = 5,
		
		bar = "Interface\\AddOns\\Rewatch\\assets\\Bar.tga",
		font = "Interface\\AddOns\\Rewatch\\assets\\PTSansNarrow.ttf",
		fontSize = 8,
		layout = "vertical",
		grow = "down",
		notify1 = -- ignore
		{
			["Clinging Darkness"] = true,
			["Disgusting Guts"] = true,
		},
		notify2 = -- medium
		{
			["Anima Injection"] = true,
			["Violent Detonation"] = true,
			["Debilitating Plague"] = true,
			["Infectious Rain"] = true,
			["Corrosive Gunk"] = true,
			["Explosive Anger"] = true,
			["Dark Lance"] = true,
			["Boneflay"] = true,
			["Goresplatter"] = true,
			["Soul Corruption"] = true,
			["Phantasmal Parasite"] = true,
			["Curse of Desolation"] = true,
		},
		notify3 = -- high
		{
			["Siphon Life"] = true,
			["Dying Breath"] = true,
			["Corroded Claws"] = true,
			["Wrack Soul"] = true,
			["Curse of Suppression"] = true,
			["Forced Confession"] = true,
			["Lingering Doubt"] = true,
			["Burden of Knowledge"] = true,
			["Lost Confidence"] = true,
			["Frozen Binds"] = true,
			["Shadow Vulnerability"] = true,
		},
		
		showButtons = false,
		showTooltips = true,
		hide = false,

		altMacro = nil,
		ctrlMacro = nil,
		shiftMacro = nil,
		bars = {},
		buttons = {},
		spell = nil,

		autoActivate = {},
	}

	-- druid
	if(rewatch.classId == 11) then

		profile.bars = { rewatch.locale["lifebloom"], rewatch.locale["rejuvenation"], rewatch.locale["regrowth"], rewatch.locale["wildgrowth"] }
		profile.buttons = { rewatch.locale["swiftmend"], rewatch.locale["naturescure"], rewatch.locale["ironbark"], rewatch.locale["efflorescence"] }
		profile.spell = rewatch.locale["regrowth"]

		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["naturescure"]
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch.rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch.locale["rebirth"].."; "..rewatch.locale["revive"].."\n/targetlasttarget"
		profile.ctrlMacro = "/cast [@mouseover] "..rewatch.locale["naturesswiftness"].."\n/cast [@mouseover] "..rewatch.locale["regrowth"]

	-- shaman
	elseif(rewatch.classId == 7) then

		profile.bars = { rewatch.locale["riptide"], rewatch.locale["earthshield"] }
		profile.buttons = { rewatch.locale["purifyspirit"], rewatch.locale["healingsurge"], rewatch.locale["healingwave"], rewatch.locale["chainheal"] }
		profile.spell = rewatch.locale["healingsurge"]

		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["purifyspirit"]
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch.rezzing = UnitName(\"target\");\n/cast "..rewatch.locale["ancestralspirit"].."\n/targetlasttarget"
		
	-- priest
	elseif(rewatch.classId == 5) then
		
		profile.bars = { rewatch.locale["powerwordshield"], rewatch.locale["painsuppression"] }
		profile.buttons = { rewatch.locale["shadowmend"], rewatch.locale["penance"], rewatch.locale["powerwordbarrier"], rewatch.locale["powerwordradiance"], rewatch.locale["rapture"], rewatch.locale["purify"] }
		profile.spell = rewatch.locale["powerwordshield"]

		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["purify"]
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch.rezzing = UnitName(\"target\");\n/cast "..rewatch.locale["resurrection"].."\n/targetlasttarget"

	-- paladin
	elseif(rewatch.classId == 2) then

		profile.bars = { rewatch.locale["beaconoflight"], rewatch.locale["bestowfaith"] }
		profile.buttons = { rewatch.locale["holyshock"], rewatch.locale["wordofglory"], rewatch.locale["holylight"], rewatch.locale["flashoflight"], rewatch.locale["cleanse"] }
		profile.spell = rewatch.locale["flashoflight"]

		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["cleanse"]
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch.rezzing = UnitName(\"target\");\n/cast "..rewatch.locale["redemption"].."\n/targetlasttarget"
		profile.ctrlMacro = "/cast [@mouseover] "..rewatch.locale["layonhands"]

	-- monk
	elseif(rewatch.classId == 10) then

		profile.bars = { rewatch.locale["renewingmist"], rewatch.locale["envelopingmist"], rewatch.locale["lifecocoon"] }
		profile.buttons = { rewatch.locale["vivify"], rewatch.locale["soothingmist"], rewatch.locale["detox"] }
		profile.spell = rewatch.locale["vivify"]

		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["detox"]
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch.rezzing = UnitName(\"target\");\n/cast "..rewatch.locale["resuscitate"].."\n/targetlasttarget"

	-- other
	else

		profile.hide = true

	end

	rewatch_config.profiles[profile.guid] = profile

	return profile

end

-- select profile
function RewatchOptions:SelectProfile(guid)
	
	rewatch:Debug("RewatchOptions:SelectProfile")

	self.selected = rewatch_config.profiles[guid]
	self.activateButton:SetEnabled(self.selected.guid ~= self.profile.guid)
	self.deleteButton:SetEnabled(self.selected.guid ~= self.profile.guid)

	UIDropDownMenu_SetText(self.profileSelector, self.selected.name)

	for _,reset in pairs(self.fields) do reset() end

end

-- activate profile
function RewatchOptions:ActivateProfile(guid)

	rewatch:Debug("RewatchOptions:ActivateProfile")

	self.profile = rewatch_config.profiles[guid]
	rewatch_config.profile[rewatch.guid] = guid

	if(self.selected) then

		self.activateButton:SetEnabled(self.selected.guid ~= self.profile.guid)
		self.deleteButton:SetEnabled(self.selected.guid ~= self.profile.guid)
	
		rewatch:Clear()

	end

end

-- check and auto-activate profile
function RewatchOptions:AutoActivateProfile()

	rewatch:Debug("RewatchOptions:AutoActivateProfile")

	for guid,profile in pairs(rewatch_config.profiles) do

		if(profile.autoActivate and profile.autoActivate[rewatch.guid]) then

			for _,group in pairs(self.activationOptions) do

				local ok = nil

				for _,option in ipairs(group.options) do
					if(not ok and profile.autoActivate[rewatch.guid][option.value or option.text]) then
						ok = option.isActive(option.value)
					end
				end

				if (ok ~= nil and not ok) then return end

			end

			if(self.profile.guid == guid) then return end

			rewatch:Message("Auto-activating profile "..profile.name)
			self:ActivateProfile(guid)

			return

		end
	end
end

-- get the auto-activate configuration in text
function RewatchOptions:AutoActivateProfileText()

	rewatch:Debug("RewatchOptions:AutoActivateProfileText")

	if(not self.selected) then return "(disabled)" end
	if(not self.selected.autoActivate) then return "(disabled)" end
	if(not self.selected.autoActivate[rewatch.guid]) then return "(disabled)" end
	
	local s = ""

	for _,group in pairs(self.activationOptions) do
		for _,option in ipairs(group.options) do
			if(self.selected.autoActivate[rewatch.guid][option.value or option.text]) then
				s = s..", "..option.text
			end
		end
	end

	return string.len(s) > 0 and string.sub(s, 3) or "(disabled)"

end

-- helper method for option input positioning (left column)
function RewatchOptions:Left(row, offset)
	return { x =  10 + (offset or 0), y = -60 - row*20 }
end

-- helper method for option input positioning (right column)
function RewatchOptions:Right(row, offset)
	return { x = 270 + (offset or 0), y = -60 - row*20 }
end

-- text template
function RewatchOptions:Text(key, name, pos)

	rewatch:Debug("RewatchOptions:Text")

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")

	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 110, pos.y)
	input:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	input:SetBackdropColor(0.2, 0.2, 0.2, 1)
	input:SetWidth(380)
	input:SetHeight(15)
	input:SetAutoFocus(nil)
	input:SetFontObject(GameFontHighlight)
	input:SetScript("OnTextChanged", function(x)

		if(x:GetText() == "") then return end
		if(x:GetText() == self.selected[key]) then return end
		
		self.selected[key] = x:GetText()
		
		if(key == "name") then UIDropDownMenu_SetText(self.profileSelector, self.selected[key]) end
		if(self.selected.guid == self.profile.guid) then rewatch:Clear() end

	end)

	return function()
		input:SetText(self.selected[key])
		input:SetCursorPosition(0)
	end

end

-- number template
function RewatchOptions:Number(key, name, pos)

	rewatch:Debug("RewatchOptions:Number")

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("EDITBOX", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")

	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 110, pos.y)
	input:SetJustifyH("RIGHT")
	input:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	input:SetBackdropColor(0.2, 0.2, 0.2, 1)
	input:SetWidth(120)
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
		if(self.selected.guid == self.profile.guid) then rewatch:Clear() end

	end)

	return function()
		input:SetText(self.selected[key])
		input:SetCursorPosition(0)
	end

end

-- dropdown template
function RewatchOptions:Dropdown(key, name, pos, values)
	
	rewatch:Debug("RewatchOptions:Dropdown")

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("FRAME", nil, self.frame, "UIDropDownMenuTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 92, pos.y + 10)
	
	UIDropDownMenu_SetWidth(input, 105)
	UIDropDownMenu_Initialize(input, function()

		for _,value in ipairs(values) do
			UIDropDownMenu_AddButton({
				text = value,
				value = value,
				checked = self.selected and value == self.selected[key],
				func = function(x)
					
					if(self.selected[key] == x.value) then return end

					self.selected[key] = x.value
					if(self.selected.guid == self.profile.guid) then rewatch:Clear() end
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

	rewatch:Debug("RewatchOptions:Checkbox")

	local text = self.frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	local input = CreateFrame("CHECKBUTTON", nil, self.frame, "ChatConfigCheckButtonTemplate")
	
	text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x, pos.y)
	text:SetText(name)
	
	input:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 110, pos.y + 5)
	input:SetScript("OnClick", function()

		if(self.selected[key] == input:GetChecked()) then return end

		self.selected[key] = input:GetChecked()
		if(self.selected.guid == self.profile.guid) then rewatch:Clear() end
		if(key == "hide") then rewatch.frame:Show() end

	end)

	return function()
		input:SetChecked(self.selected[key])
	end

end

-- multi template
function RewatchOptions:Multi(pos, fields)

	rewatch:Debug("RewatchOptions:Multi")

	local currentField = nil

	local scroll = CreateFrame("SCROLLFRAME", nil, self.frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 110, pos.y)
	scroll:SetSize(360, 138)

	local input = CreateFrame("EDITBOX", nil, scroll, BackdropTemplateMixin and "BackdropTemplate")
	input:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	input:SetBackdropColor(0.2, 0.2, 0.2, 1)
	input:SetMultiLine(true)
	input:SetWidth(360)
	input:SetAutoFocus(nil)
	input:SetFontObject(GameFontHighlight)
	input:SetFrameStrata("DIALOG")
	input:EnableKeyboard(true)

	scroll:SetScrollChild(input)
	input:SetAllPoints(scroll)

	local save = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	save:SetText("Save")
	save:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 107, pos.y - 138)
	save:SetWidth(253)
	save:Disable()

	local cancel = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate")
	cancel:SetText("Cancel")
	cancel:SetPoint("TOPLEFT", self.frame, "TOPLEFT", pos.x + 360, pos.y - 138)
	cancel:SetWidth(113)
	cancel:Disable()
	
	save:SetScript("OnClick", function() currentField.save() end)
	cancel:SetScript("OnClick", function() currentField.reset() end)
	input:SetScript("OnKeyDown", function() save:Enable(); cancel:Enable() end)

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
			input:SetAllPoints(scroll)

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

					if(self.selected.guid == self.profile.guid) then rewatch:Clear() end

				end

			elseif(currentField.type == "table") then
				
				local lines = {}
				local changed = false

				for k in input:GetText():gmatch("[^\r\n]+") do lines[k] = true end
				for k,v in pairs(self.selected[currentField.key]) do changed = changed or lines[k] == v end

				if(changed) then

					self.selected[currentField.key] = {}
					for k,v in pairs(lines) do self.selected[currentField.key][k] = v end
					
					if(self.selected.guid == self.profile.guid) then rewatch:Clear() end

				end

			else

				if(self.selected[currentField.key] ~= input:GetText()) then

					self.selected[currentField.key] = input:GetText()
					if(self.selected.guid == self.profile.guid) then rewatch:Clear() end

				end

			end

			save:Disable()
			cancel:Disable()

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

			save:Disable()
			cancel:Disable()
	
		end

		if(currentField == nil) then
			currentField = field
			field.button:SetNormalFontObject("GameFontHighlightSmall")
		end

	end

	return currentField.reset

end