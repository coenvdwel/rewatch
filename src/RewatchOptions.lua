RewatchOptions = {};
RewatchOptions.__index = RewatchOptions;

function RewatchOptions:new()
    
    local self =
    {
		profile = nil,
        frame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    };

	setmetatable(self, RewatchOptions);

	-- load profile
	local guid = rewatch_config.profile[rewatch.guid];

	if(guid) then
		self:ActivateProfile(guid);
	else
		local profile = self:CreateProfile(rewatch.player);
		self:ActivateProfile(profile.guid);
	end;

	 -- build frame
	self.frame.name = "Rewatch";

	local addLayoutBtn = CreateFrame("BUTTON", nil, self.frame, "OptionsButtonTemplate");
	addLayoutBtn:SetText("New");
	addLayoutBtn:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0);
	addLayoutBtn:SetScript("OnClick", function() StaticPopup_Show("REWATCH_ADD_LAYOUT"); end);

	InterfaceOptions_AddCategory(self.frame);

	return self;

end;

-- create profile
function RewatchOptions:CreateProfile(name)
	
	local profile =
	{
		name = name,
		guid = rewatch:NewId(),

		spellBarWidth = 25,
		spellBarHeight = 14,
		healthBarHeight = 110,
		scaling = 100,
		numFramesWide = 5,
		
		bar = "Interface\\AddOns\\Rewatch\\assets\\Bar.tga",
		font = "Interface\\AddOns\\Rewatch\\assets\\BigNoodleTitling.ttf",
		fontSize = 10,
		highlightSize = 10,
		OORAlpha = 0.5,
		PBOAlpha = 0.2,
		layout = "vertical",
		highlighting = {},
		highlighting2 = {},
		highlighting3 = {},
		
		showButtons = false,
		showTooltips = true,
		frameColumns = true,

		altMacro = nil,
		ctrlMacro = nil,
		shiftMacro = nil,
		
		bars = {},
		buttons = {}
	};

	-- shaman
	if(rewatch.classId == 7) then
		profile.bars = { rewatch.locale["riptide"] };
		profile.buttons = { rewatch.locale["purifyspirit"], rewatch.locale["healingsurge"], rewatch.locale["healingwave"], rewatch.locale["chainheal"] };
	end;
	
	-- druid
	if(rewatch.classId == 11) then
		profile.bars = { rewatch.locale["lifebloom"], rewatch.locale["rejuvenation"], rewatch.locale["regrowth"], rewatch.locale["wildgrowth"] };
		profile.buttons = { rewatch.locale["swiftmend"], rewatch.locale["naturescure"], rewatch.locale["ironbark"], rewatch.locale["mushroom"] };
		profile.altMacro = "/cast [@mouseover] "..rewatch.locale["naturescure"];
		profile.ctrlMacro = "/cast [@mouseover] "..rewatch.locale["naturesswiftness"].."/cast [@mouseover] "..rewatch.locale["regrowth"];
		profile.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch.locale["rebirth"].."; "..rewatch.locale["revive"].."\n/targetlasttarget";
	end;

	rewatch_config.profiles[profile.guid] = profile;
	
	return profile;

end;

-- activate profile
function RewatchOptions:ActivateProfile(guid)

	rewatch_config.profile[rewatch.guid] = guid;
	self.profile = rewatch_config.profiles[guid];

end;






StaticPopupDialogs["REWATCH_ADD_LAYOUT"] =
{
	text = "Creating a new layout based on the currently active layout. Please enter the new layout name:",
	button1 = "OK",
	button2 = "Cancel",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
	preferredIndex = 3,
	OnAccept = function(self)
		rewatch_AddLayout(self.editBox:GetText());
	end,
	EditBoxOnEnterPressed = function(self)
		rewatch_AddLayout(self:GetText());
		self:GetParent():Hide();
	end
};

StaticPopupDialogs["REWATCH_DELETE_LAYOUT"] =
{
	text = "Are you sure you want to delete %s?",
	button1 = "Yes",
	button2 = "No",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
	preferredIndex = 3,
	OnAccept = function(self, data)
		rewatch_RemoveLayout(data);
	end
  };

function rewatch_AddText(frame, layout, row, col, name, key)

	if(rewatch_load["Layouts"][layout].values[key] == nil) then rewatch_load["Layouts"][layout].values[key] = rewatch_loadInt[key]; end;
	
	local o =
	{
		name = name,
		key = key,
		text = frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall"),
		input = CreateFrame("EDITBOX", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	};
	
	o.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + col*180, -60 - row*20);
	o.text:SetText(name);
	
	o.input:SetPoint("TOPLEFT", frame, "TOPLEFT", 100 + col*180, -60 - row*20);
	o.input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	o.input:SetWidth(70);
	o.input:SetHeight(15);
	o.input:SetAutoFocus(nil);
	o.input:SetFontObject(GameFontHighlight);
	o.input:SetText(rewatch_load["Layouts"][layout].values[key]);
	o.input:SetCursorPosition(0);
	
	return o;

end;

function rewatch_AddNumber(frame, layout, row, col, name, key)

	local o = rewatch_AddText(frame, layout, row, col, name, key);

	o.input:SetNumeric(true);
	o.input:SetMaxLetters(3);
	o.input:SetScript("OnTextChanged", function(self)

		if(self:GetText() == "") then return; end;
		if(self:GetNumber() < 1) then self:SetText(1); end;
		if(self:GetNumber() > 999) then self:SetText(999); end;
		
		rewatch_load["Layouts"][layout].values[key] = self:GetNumber();

		if(rewatch_load["Layouts"][layout].active) then
			rewatch_ApplyLayout(layout);
		end;

	end);
	
	return o;

end;

function rewatch_AddPercentage(frame, layout, row, col, name, key)

	local o = rewatch_AddText(frame, layout, row, col, name, key);

	o.input:SetNumeric(true);
	o.input:SetMaxLetters(3);
	o.input:SetText(rewatch_load["Layouts"][layout].values[key]*100);
	o.input:SetCursorPosition(0);
	o.input:SetScript("OnTextChanged", function(self)

		if(self:GetText() == "") then return; end;
		if(self:GetNumber() < 0) then self:SetText(0); end;
		if(self:GetNumber() > 100) then self:SetText(100); end;
		
		rewatch_load["Layouts"][layout].values[key] = self:GetNumber()/100;

		if(rewatch_load["Layouts"][layout].active) then
			rewatch_ApplyLayout(layout);
		end;

	end);
	
	return o;

end;

function rewatch_AddCheckbox(frame, layout, row, col, name, key)

	if(rewatch_load["Layouts"][layout].values[key] == nil) then rewatch_load["Layouts"][layout].values[key] = rewatch_loadInt[key]; end;
	
	local o =
	{
		name = name,
		key = key,
		text = frame:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall"),
		input = CreateFrame("EDITBOX", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	};
	
	o.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + col*180, -60 - row*20);
	o.text:SetText(name);
	
	o.input:SetPoint("TOPLEFT", frame, "TOPLEFT", 100 + col*180, -60 - row*20);
	o.input:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	o.input:SetWidth(70);
	o.input:SetHeight(15);
	o.input:SetAutoFocus(nil);
	o.input:SetNumeric(true);
	o.input:SetMaxLetters(3);
	o.input:SetFontObject(GameFontHighlight);
	o.input:SetText(rewatch_load["Layouts"][layout].values[key]);
	o.input:SetCursorPosition(0);
	o.input:SetScript("OnTextChanged", function(self)

		if(self:GetText() == "") then return; end;
		if(self:GetNumber() < 1) then self:SetText(1); end;
		if(self:GetNumber() > 999) then self:SetText(999); end;
		
		rewatch_load["Layouts"][layout].values[key] = self:GetNumber();

		if(rewatch_load["Layouts"][layout].active) then
			rewatch_ApplyLayout(layout);
		end;

	end);
	
	return o;

end;
	
function rewatch_AddLayout(layout, preload)
	
	-- if it already exists, the user is adding one with a duplicate name - just open the existing one to show him he's been a silly person
	if(rewatch_loadInt["Layouts"][layout] ~= nil) then
		InterfaceOptionsFrame_OpenToCategory(rewatch_loadInt["Layouts"][layout].frame.name);
		return;
	end;

	local frame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate");
	
	frame.name = "- "..layout;
	frame.parent = "Layouts";

	local activateButton = CreateFrame("BUTTON", nil, frame, "OptionsButtonTemplate");

	activateButton:SetText("Activate");
	activateButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10);
	activateButton:SetScript("OnClick", function()
		rewatch_ActivateLayout(layout);
	end);
	
	local deleteButton = CreateFrame("BUTTON", nil, frame, "OptionsButtonTemplate");

	deleteButton:SetText("Delete");
	deleteButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 100, -10);
	deleteButton:SetScript("OnClick", function()
		StaticPopup_Show("REWATCH_DELETE_LAYOUT", layout).data = layout;
	end);

	if(rewatch_load["Layouts"][layout] == nil) then rewatch_load["Layouts"][layout] = {}; end;
	if(rewatch_load["Layouts"][layout].values == nil) then rewatch_load["Layouts"][layout].values = {}; end;

	if(rewatch_load["Layouts"][layout].active) then
		frame.name = "> "..layout;
		activateButton:Disable();
		deleteButton:Disable();
	end;

	--rewatch_AddCheckbox(frame, layout, 0, 0, "", "");
	--rewatch_AddCheckbox(frame, layout, 0, 1, "", "");

	local left = 0;
	local right = 1;

	rewatch_AddNumber(frame, layout, 2, left, "Frame size", "SpellBarWidth");
	rewatch_AddNumber(frame, layout, 3, left, "Healthbar size", "HealthBarHeight");
	rewatch_AddNumber(frame, layout, 4, left, "Spellbar size", "SpellBarHeight");

	rewatch_AddNumber(frame, layout, 2, right, "Scaling", "Scaling");
	rewatch_AddNumber(frame, layout, 3, right, "Players per column", "NumFramesWide");

	rewatch_AddPercentage(frame, layout, 6, left, "Out of range fade", "OORAlpha");

	rewatch_loadInt["Layouts"][layout] =
	{
		frame = frame,
		activateButton = activateButton,
		deleteButton = deleteButton
	};
	
	InterfaceOptions_AddCategory(frame);
	InterfaceAddOnsList_Update();
	
	if(not preload) then InterfaceOptionsFrame_OpenToCategory(frame.name); end;
	
end;

function rewatch_RemoveLayout(layout)

	if(rewatch_load["Layouts"][layout].active) then
		rewatch_Message("Cannot delete your active layout!");
		return;
	end;

	local n = 1;

	for i=1, #INTERFACEOPTIONS_ADDONCATEGORIES do
		if(INTERFACEOPTIONS_ADDONCATEGORIES[i].name ~= "- "..layout) then
			INTERFACEOPTIONS_ADDONCATEGORIES[n] = INTERFACEOPTIONS_ADDONCATEGORIES[i];
			n = n + 1;
		end;
	end;
	
	for i=n, #INTERFACEOPTIONS_ADDONCATEGORIES do
		INTERFACEOPTIONS_ADDONCATEGORIES[i] = nil;
	end;

	rewatch_load["Layouts"][layout] = nil;
	rewatch_loadInt["Layouts"][layout] = nil;

	InterfaceAddOnsList_Update();
	InterfaceOptionsFrame_OpenToCategory("Layouts");

end;

function rewatch_ActivateLayout(layout, silent)

	if(rewatch_load["Layouts"][layout].active) then
		return;
	end;

	if(InCombatLockdown() == 1) then
		rewatch_Message(rewatch_loc["combatfailed"]);
		return;
	end;

	for k,v in pairs(rewatch_load["Layouts"]) do
		rewatch_load["Layouts"][k].active = false;
		rewatch_loadInt["Layouts"][k].frame.name = "- "..k;
		rewatch_loadInt["Layouts"][k].activateButton:Enable();
		rewatch_loadInt["Layouts"][k].deleteButton:Enable();
	end;

	rewatch_load["Layouts"][layout].active = true;
	rewatch_loadInt["Layouts"][layout].frame.name = "> "..layout;
	rewatch_loadInt["Layouts"][layout].activateButton:Disable();
	rewatch_loadInt["Layouts"][layout].deleteButton:Disable();

	InterfaceAddOnsList_Update();
	rewatch_ApplyLayout(layout);

	if(not silent) then rewatch_Message("Activated layout "..layout.."."); end;

end;

function rewatch_ApplyLayout(layout)

	for k,v in pairs(rewatch_load["Layouts"][layout].values) do
		rewatch_load[k] = v;
		rewatch_loadInt[k] = v;
	end;

	rewatch_clear = true;
	rewatch_changed = true;
	rewatch:Render();

end;