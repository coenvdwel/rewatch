rewatch.CreateProfile = function(self, name)

	local profile = 
	{
		SpellBarWidth = 25,
		SpellBarHeight = 14,
		HealthBarHeight = 110,
		Scaling = 100,
		NumFramesWide = 5,
		WildGrowth = 1,
		Bar = "Interface\\AddOns\\Rewatch\\assets\\Bar.tga",
		Font = "Interface\\AddOns\\Rewatch\\assets\\BigNoodleTitling.ttf",
		FontSize = 10,
		HighlightSize = 10,
		OORAlpha = 0.5,
		PBOAlpha = 0.2,
		Layout = "vertical",
		SortByRole = 1,
		ShowSelfFirst = 1,
		Highlighting = {},
		Highlighting2 = {},
		Highlighting3 = {},
		ShowButtons = 0,
		ShowTooltips = 1,
		FrameColumns = 1
	};	

	-- shaman
	if(rewatch.classId == 7) then
		profile["Bars"] = { rewatch_loc["riptide"] };
		profile["Buttons"] = { rewatch_loc["purifyspirit"], rewatch_loc["healingsurge"], rewatch_loc["healingwave"], rewatch_loc["chainheal"] };
	end;
	
	-- druid
	if(rewatch.classId == 11) then
		profile["Bars"] = { rewatch_loc["lifebloom"], rewatch_loc["rejuvenation"], rewatch_loc["regrowth"], rewatch_loc["wildgrowth"] };
		profile["Buttons"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
		profile["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
		profile["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["naturesswiftness"].."/cast [@mouseover] "..rewatch_loc["regrowth"];
		profile["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
	end;

	rewatch_config["Profiles"][name] = profile;

end;

rewatch.ActivateProfile = function(self, name)

	rewatch_config["Profile"][rewatch.guid] = name;
	rewatch.profile = rewatch_config["Profiles"][name];

end;

rewatch.CreateOptions = function(self)

	-- create only once, please
	if(rewatch_options ~= nil) then return; end;

	-- create the options tabs
	rewatch_options = CreateFrame("FRAME", "Rewatch_Options", UIParent, BackdropTemplateMixin and "BackdropTemplate"); rewatch_options.name = "Rewatch";
	rewatch_options2 = CreateFrame("FRAME", "Rewatch_Options2", UIParent, BackdropTemplateMixin and "BackdropTemplate"); rewatch_options2.name = "Layouts"; rewatch_options2.parent = "Rewatch";
	rewatch_options3 = CreateFrame("FRAME", "Rewatch_Options3", UIParent, BackdropTemplateMixin and "BackdropTemplate"); rewatch_options3.name = "Highlighting"; rewatch_options3.parent = "Rewatch";
	rewatch_options4 = CreateFrame("FRAME", "Rewatch_Options4", UIParent, BackdropTemplateMixin and "BackdropTemplate"); rewatch_options4.name = "Macro's & buttons"; rewatch_options4.parent = "Rewatch";

	-- create the Add Layout button
	local addLayoutBtn = CreateFrame("BUTTON", "Rewatch_AddLayoutButton", rewatch_options2, "OptionsButtonTemplate");
	addLayoutBtn:SetText("+");
	addLayoutBtn:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 0, 0);
	addLayoutBtn:SetScript("OnClick", function() StaticPopup_Show("REWATCH_ADD_LAYOUT"); end);

	-- allow selection of automatic layout conditions

	-- local conditions = { "Manual", "Solo", "Group", "Raid" };
	-- local conditionDropdown = CreateFrame("FRAME", "Rewatch_Layout"..layout.."Condition", frame, "UIDropDownMenuTemplate");

	-- conditionDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 215, -10);

	-- UIDropDownMenu_Initialize(conditionDropdown, function()

	--     for key, val in pairs(conditions) do

	-- 		local info = UIDropDownMenu_CreateInfo();

	--         info.text = val;
	--         info.checked = false;
	--         info.menuList = key;
	--         info.hasArrow = false;
	--         info.func = function(b)
	--             UIDropDownMenu_SetSelectedValue(conditionDropdown, b.value, b.value);
	--             UIDropDownMenu_SetText(conditionDropdown, b.value);
	--             b.checked = true;
	--         end;

	--         UIDropDownMenu_AddButton(info);

	--     end
	-- end);

	-- UIDropDownMenu_SetWidth(conditionDropdown, 100);
	-- UIDropDownMenu_SetSelectedValue(conditionDropdown, "Manual", "Manual");
	-- UIDropDownMenu_SetText(conditionDropdown, "Manual");

	-- left options
	local hideCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	hideCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -220); hideCBT:SetText(rewatch_loc["hide"]);
	local hideCB = CreateFrame("CHECKBUTTON", "Rewatch_HideCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	hideCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -213);
	
	local hideButtonsCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	hideButtonsCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -240); hideButtonsCBT:SetText(rewatch_loc["hideButtons"]);
	local hideButtonsCB = CreateFrame("CHECKBUTTON", "Rewatch_HideButtonsCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	hideButtonsCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -233);
	hideButtonsCB:SetScript("OnClick", function(self) rewatch_changedDimentions = true; end);
	
	local autoGroupCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	autoGroupCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -260); autoGroupCBT:SetText(rewatch_loc["autoAdjust"]);
	local autoGroupCB = CreateFrame("CHECKBUTTON", "Rewatch_AutoGroupCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	autoGroupCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -253);

	local lockCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	lockCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -280); lockCBT:SetText(rewatch_loc["lockMain"]);
	local lockCB = CreateFrame("CHECKBUTTON", "Rewatch_LockCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	lockCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -273);
	
	local labelsCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	labelsCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -300); labelsCBT:SetText(rewatch_loc["labelsOrTimers"]);
	local labelsCB = CreateFrame("CHECKBUTTON", "Rewatch_LabelsCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	labelsCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -293);
	labelsCB:SetScript("OnClick", function(self) rewatch_changedDimentions = true; end);
	
	local wgCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	wgCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -320); wgCBT:SetText(rewatch_loc["talentedwg"]);
	local wgCB = CreateFrame("CHECKBUTTON", "Rewatch_WGCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	wgCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -313);
	wgCB:SetScript("OnClick", function(self) rewatch_changedDimentions = true; end);

	local soloHideCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	soloHideCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 250, -300); soloHideCBT:SetText(rewatch_loc["hideSolo"]);
	local soloHideCB = CreateFrame("CHECKBUTTON", "Rewatch_SoloHideCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	soloHideCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 210, -293);
	
	local ttCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ttCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 250, -320); ttCBT:SetText(rewatch_loc["showtooltips"]);
	local ttCB = CreateFrame("CHECKBUTTON", "Rewatch_TTCB", rewatch_options, "ChatConfigCheckButtonTemplate");
	ttCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 210, -313);
	
	local bart = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	bart:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -350); bart:SetText("Bar texture:");
	local bar = CreateFrame("EDITBOX", "Rewatch_BarTexture", rewatch_options, BackdropTemplateMixin and "BackdropTemplate");
	bar:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	bar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	bar:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 200, -350);
	bar:SetWidth(175); bar:SetHeight(15); bar:SetAutoFocus(nil);
	bar:SetFontObject(GameFontHighlight);
	local fontTypet = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	fontTypet:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -370); fontTypet:SetText("Font type:");
	local fontType = CreateFrame("EDITBOX", "Rewatch_FontType", rewatch_options, BackdropTemplateMixin and "BackdropTemplate");
	fontType:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	fontType:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	fontType:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 200, -370);
	fontType:SetWidth(175); fontType:SetHeight(15); fontType:SetAutoFocus(nil);
	fontType:SetFontObject(GameFontHighlight);
	local fontSizet = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	fontSizet:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -390); fontSizet:SetText("Font size / Highlight size:");
	local fontSize = CreateFrame("EDITBOX", "Rewatch_FontSize", rewatch_options, BackdropTemplateMixin and "BackdropTemplate");
	fontSize:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	fontSize:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	fontSize:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 200, -390);
	fontSize:SetWidth(86); fontSize:SetHeight(15); fontSize:SetAutoFocus(nil);
	fontSize:SetFontObject(GameFontHighlight);
	local highlightSize = CreateFrame("EDITBOX", "Rewatch_HighlightSize", rewatch_options, BackdropTemplateMixin and "BackdropTemplate");
	highlightSize:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	highlightSize:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	highlightSize:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 290, -390);
	highlightSize:SetWidth(86); highlightSize:SetHeight(15); highlightSize:SetAutoFocus(nil);
	highlightSize:SetFontObject(GameFontHighlight);
	
	-- dimensions	
	-- pbo alpha
	local PBOalphaSliderT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	PBOalphaSliderT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -150); PBOalphaSliderT:SetText(rewatch_loc["PBOText"]);
	local PBOalphaSlider = CreateFrame("SLIDER", "Rewatch_PBOAlphaSlider", rewatch_options2, "OptionsSliderTemplate");
	PBOalphaSlider:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -150); PBOalphaSlider:SetMinMaxValues(0, 1); PBOalphaSlider:SetValueStep(0.1);
	PBOalphaSlider:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; end);
	getglobal("Rewatch_PBOAlphaSliderLow"):SetText(rewatch_loc["invisible"]); getglobal("Rewatch_PBOAlphaSliderHigh"):SetText(rewatch_loc["visible"]);
	
	-- show damage taken
	local showDamageTakenT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	showDamageTakenT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -214); showDamageTakenT:SetText(rewatch_loc["showDamageTaken"]);
	local showDamageTaken = CreateFrame("CHECKBUTTON", "Rewatch_SDTCB", rewatch_options2, "ChatConfigCheckButtonTemplate");
	showDamageTaken:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -207);
	
	-- layout
	local layoutDefaultT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	layoutDefaultT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -240); layoutDefaultT:SetText(rewatch_loc["horizontal"]);
	local layoutDefault = CreateFrame("CHECKBUTTON", "Rewatch_LDEFCB", rewatch_options2, "ChatConfigCheckButtonTemplate");
	layoutDefault:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -233);
	local layoutVerticalT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	layoutVerticalT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -266); layoutVerticalT:SetText(rewatch_loc["vertical"]);
	local layoutVertical = CreateFrame("CHECKBUTTON", "Rewatch_LVERTCB", rewatch_options2, "ChatConfigCheckButtonTemplate");
	layoutVertical:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -258);
	
	-- layout 'radio' button mech
	layoutDefault:SetScript("OnClick", function(self) rewatch_changedDimentions = true; layoutDefault:SetChecked(true); layoutVertical:SetChecked(false); end);
	layoutVertical:SetScript("OnClick", function(self) rewatch_changedDimentions = true; layoutVertical:SetChecked(true); layoutDefault:SetChecked(false); end);
	
	-- column option
	local frameColumnsT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	frameColumnsT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 250, -188); frameColumnsT:SetText(rewatch_loc["frameColumns"]);
	local frameColumns = CreateFrame("CHECKBUTTON", "Rewatch_FCCB", rewatch_options2, "ChatConfigCheckButtonTemplate");
	frameColumns:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 210, -181);
	
	-- sort options
	local sortByRoleT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	sortByRoleT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 250, -214); sortByRoleT:SetText(rewatch_loc["sortByRole"]);
	local sortByRole = CreateFrame("CHECKBUTTON", "Rewatch_SBRCB", rewatch_options2, "ChatConfigCheckButtonTemplate");
	sortByRole:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 210, -207);
	local showSelfFirstT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	showSelfFirstT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 250, -240); showSelfFirstT:SetText(rewatch_loc["showSelfFirst"]);
	local showSelfFirst = CreateFrame("CHECKBUTTON", "Rewatch_SSFCB", rewatch_options2, "ChatConfigCheckButtonTemplate");
	showSelfFirst:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 210, -233);
	
	-- apply
	local applyBTN = CreateFrame("BUTTON", "Rewatch_ApplyBTN", rewatch_options2, "OptionsButtonTemplate"); applyBTN:SetText("Apply");
	applyBTN:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -390); applyBTN:SetScript("OnClick", function() rewatch_OptionsFromData(false); rewatch_clear = true; rewatch_changed = true; rewatch_changedDimentions = false; end);
	
	-- buttons
	local sortBTN = CreateFrame("BUTTON", "Rewatch_BuffCheckBTN", rewatch_options, "OptionsButtonTemplate"); sortBTN:SetText(rewatch_loc["sortList"]);
	sortBTN:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -213); sortBTN:SetScript("OnClick", function() if(rewatch_loadInt["AutoGroup"] == 0) then rewatch_Message(rewatch_loc["nosort"]); else rewatch_clear = true; rewatch_changed = true; rewatch_Message(rewatch_loc["sorted"]); end; end);
	local clearBTN = CreateFrame("BUTTON", "Rewatch_BuffCheckBTN", rewatch_options, "OptionsButtonTemplate"); clearBTN:SetText(rewatch_loc["clearList"]);
	clearBTN:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -233); clearBTN:SetScript("OnClick", function() rewatch_clear = true; rewatch_Message(rewatch_loc["cleared"]); end);
	local reposBTN = CreateFrame("BUTTON", "Rewatch_RepositionBTN", rewatch_options, "OptionsButtonTemplate"); reposBTN:SetText(rewatch_loc["reposition"]);
	reposBTN:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -253); reposBTN:SetScript("OnClick", function()
		
		rewatch_f:ClearAllPoints();
		rewatch_f:SetPoint("TOPLEFT", UIParent, "TOPLEFT");
		rewatch_Message(rewatch_loc["repositioned"]);
		
	end);
	
	-- custom highlighting
	local cht = rewatch_options3:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	cht:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 10, -10); cht:SetText("Low risk");
	local ch = CreateFrame("EDITBOX", "Rewatch_Highlighting", rewatch_options3, BackdropTemplateMixin and "BackdropTemplate");
	ch:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ch:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 10, -30);
	ch:SetPoint("BOTTOMLEFT", rewatch_options3, "BOTTOMLEFT", 10, 10);
	ch:SetWidth(130); ch:SetMultiLine(true); ch:SetAutoFocus(nil);
	ch:SetFontObject(GameFontHighlight);
	local ch2t = rewatch_options3:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ch2t:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 141, -10); ch2t:SetText("Medium risk");
	local ch2 = CreateFrame("EDITBOX", "Rewatch_Highlighting2", rewatch_options3, BackdropTemplateMixin and "BackdropTemplate");
	ch2:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ch2:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 141, -30);
	ch2:SetPoint("BOTTOMRIGHT", rewatch_options3, "BOTTOMRIGHT", -141, 10);
	ch2:SetMultiLine(true); ch2:SetAutoFocus(nil);
	ch2:SetFontObject(GameFontHighlight);
	local ch3t = rewatch_options3:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ch3t:SetPoint("TOPRIGHT", rewatch_options3, "TOPRIGHT", -10, -10); ch3t:SetText("OMGOMGOMG");
	local ch3 = CreateFrame("EDITBOX", "Rewatch_Highlighting3", rewatch_options3, BackdropTemplateMixin and "BackdropTemplate");
	ch3:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ch3:SetPoint("TOPRIGHT", rewatch_options3, "TOPRIGHT", -10, -30);
	ch3:SetPoint("BOTTOMRIGHT", rewatch_options3, "BOTTOMRIGHT", -10, 10);
	ch3:SetWidth(130); ch3:SetMultiLine(true); ch3:SetAutoFocus(nil);
	ch3:SetFontObject(GameFontHighlight);
	
	-- macros
	local altt = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	altt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -10); altt:SetText("Alt macro");
	local alt = CreateFrame("EDITBOX", "Rewatch_AltMacro", rewatch_options4, BackdropTemplateMixin and "BackdropTemplate");
	alt:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	alt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -30);
	alt:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -100);
	alt:SetMultiLine(true); alt:SetAutoFocus(nil);
	alt:SetFontObject(GameFontHighlight);
	alt:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	local ctrlt = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ctrlt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -110); ctrlt:SetText("Ctrl macro");
	local ctrl = CreateFrame("EDITBOX", "Rewatch_CtrlMacro", rewatch_options4, BackdropTemplateMixin and "BackdropTemplate");
	ctrl:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ctrl:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -130);
	ctrl:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -200);
	ctrl:SetMultiLine(true); ctrl:SetAutoFocus(nil);
	ctrl:SetFontObject(GameFontHighlight);
	ctrl:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	local shiftt = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	shiftt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -210); shiftt:SetText("Shift macro");
	local shift = CreateFrame("EDITBOX", "Rewatch_ShiftMacro", rewatch_options4, BackdropTemplateMixin and "BackdropTemplate");
	shift:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	shift:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -230);
	shift:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -300);
	shift:SetMultiLine(true); shift:SetAutoFocus(nil);
	shift:SetFontObject(GameFontHighlight);
	shift:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	local buttonst = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	buttonst:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -310); buttonst:SetText("Buttons");
	
	-- buttons by selected class; shaman(7) , druid(11)
	local buttons = CreateFrame("EDITBOX", "Rewatch_Buttons"..rewatch_loadInt["ClassID"], rewatch_options4, BackdropTemplateMixin and "BackdropTemplate");
	buttons:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	buttons:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -330);
	buttons:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -400);
	buttons:SetMultiLine(true); buttons:SetAutoFocus(nil);
	buttons:SetFontObject(GameFontHighlight);
	buttons:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	
	-- handlers
	rewatch_options.okay = function(self)
		rewatch_OptionsFromData(false);
		if(rewatch_changedDimentions) then
			if(InCombatLockdown() == 1) then
				rewatch_changed = true;
				rewatch_changedDimentions = false;
				rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_clear = true;
				rewatch_changed = true;
				rewatch_Message(rewatch_loc["sorted"]);
				rewatch_changedDimentions = false;
			end;
		end;
	end;
	rewatch_options.cancel = function(self) rewatch_OptionsFromData(true); end;
	rewatch_options.default = function(self) rewatch_version, rewatch_load = nil, nil; rewatch_loadInt["Loaded"] = false; InterfaceAddOnsList_Update(); end;
	
	-- add panels
	InterfaceOptions_AddCategory(rewatch_options);
	InterfaceOptions_AddCategory(rewatch_options2);
	InterfaceOptions_AddCategory(rewatch_options3);
	InterfaceOptions_AddCategory(rewatch_options4);
	
	-- add layouts
	local any = false;

	for k,v in pairs(rewatch_load["Layouts"]) do
		any = true;
		rewatch_AddLayout(k, true);
	end;
	
	if(not any) then
		rewatch_AddLayout(UnitName("player"), true);
		rewatch_ActivateLayout(UnitName("player"), true);
	end;

end;

-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- rewatch_load is persistent and holds layout names and values
-- rewatch_loadInt is an instance of the UI and resets on relogging

-- todo; move the current 'layout' thingies to actual preset layouts (and steal the /rew layout command)
-- todo; move all layout specific fields into layout screens
-- todo; activate automatically by some sort of condition

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

	local frame = CreateFrame("FRAME", "Rewatch_Layout"..layout, UIParent, BackdropTemplateMixin and "BackdropTemplate");
	
	frame.name = "- "..layout;
	frame.parent = "Layouts";

	local activateButton = CreateFrame("BUTTON", "Rewatch_Layout"..layout.."Activate", frame, "OptionsButtonTemplate");

	activateButton:SetText("Activate");
	activateButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10);
	activateButton:SetScript("OnClick", function()
		rewatch_ActivateLayout(layout);
	end);
	
	local deleteButton = CreateFrame("BUTTON", "Rewatch_Layout"..layout.."Delete", frame, "OptionsButtonTemplate");

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

-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- function set set the options frame values
-- get: if true the options frame will GET the data from the loaded variables, if false this frame will SET data to the loaded variables
-- return: void
function rewatch_OptionsFromData(get)

	-- get the children elements
	local children = { rewatch_options:GetChildren() };
	for _, child in ipairs(children) do
		-- if it's the hide buttons checkbutton, set or get his data
		if(child:GetName() == "Rewatch_HideButtonsCB") then
			if(get) then if(rewatch_loadInt["ShowButtons"] == 0) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["ShowButtons"], rewatch_loadInt["ShowButtons"] = 0, 0;
				else rewatch_load["ShowButtons"], rewatch_loadInt["ShowButtons"] = 1, 1; end; end;
		-- if it's the wild growth checkbox, set or get this data
		elseif(child:GetName() == "Rewatch_WGCB") then
			if(get) then if(rewatch_loadInt["WildGrowth"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["WildGrowth"], rewatch_loadInt["WildGrowth"] = 1, 1;
				else rewatch_load["WildGrowth"], rewatch_loadInt["WildGrowth"] = 0, 0; end; end;
		-- if it's the tooltip checkbox, set or get this data
		elseif(child:GetName() == "Rewatch_TTCB") then
			if(get) then if(rewatch_loadInt["ShowTooltips"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["ShowTooltips"], rewatch_loadInt["ShowTooltips"] = 1, 1;
				else rewatch_load["ShowTooltips"], rewatch_loadInt["ShowTooltips"] = 0, 0; end; end;
		-- if it's the bar texture, set or get this data
		elseif(child:GetName() == "Rewatch_BarTexture") then
			if(get) then child:SetText(rewatch_load["Bar"]); child:SetCursorPosition(0);
			else rewatch_load["Bar"] = child:GetText(); rewatch_loadInt["Bar"] = child:GetText(); end;
		-- if it's the font type, set or get this data
		elseif(child:GetName() == "Rewatch_FontType") then
			if(get) then child:SetText(rewatch_load["Font"]); child:SetCursorPosition(0);
			else rewatch_load["Font"] = child:GetText(); rewatch_loadInt["Font"] = child:GetText(); end;
		-- if it's the font size, set or get this data
		elseif(child:GetName() == "Rewatch_FontSize") then
			if(get) then child:SetText(rewatch_load["FontSize"]); child:SetCursorPosition(0);
			else rewatch_load["FontSize"] = child:GetNumber(); rewatch_loadInt["FontSize"] = child:GetNumber(); end;
		-- if it's the highlight size, set or get this data
		elseif(child:GetName() == "Rewatch_HighlightSize") then
			if(get) then child:SetText(rewatch_load["HighlightSize"]); child:SetCursorPosition(0);
			else rewatch_load["HighlightSize"] = child:GetNumber(); rewatch_loadInt["HighlightSize"] = child:GetNumber(); end;
		end;
	end;
	
	-- dimensions
	children = { rewatch_options2:GetChildren() };
	for _, child in ipairs(children) do
		if(child:GetName() == "Rewatch_PBOAlphaSlider") then
			if(get) then child:SetValue(rewatch_loadInt["PBOAlpha"]);
			else rewatch_load["PBOAlpha"], rewatch_loadInt["PBOAlpha"] = child:GetValue(), child:GetValue(); end;
		elseif(child:GetName() == "Rewatch_FCCB") then
			if(get) then if(rewatch_loadInt["FrameColumns"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["FrameColumns"], rewatch_loadInt["FrameColumns"] = 1, 1;
				else rewatch_load["FrameColumns"], rewatch_loadInt["FrameColumns"] = 0, 0; end; end;
		elseif(child:GetName() == "Rewatch_SSFCB") then
			if(get) then if(rewatch_loadInt["ShowSelfFirst"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["ShowSelfFirst"], rewatch_loadInt["ShowSelfFirst"] = 1, 1;
				else rewatch_load["ShowSelfFirst"], rewatch_loadInt["ShowSelfFirst"] = 0, 0; end; end;
		elseif(child:GetName() == "Rewatch_SBRCB") then
			if(get) then if(rewatch_loadInt["SortByRole"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["SortByRole"], rewatch_loadInt["SortByRole"] = 1, 1;
				else rewatch_load["SortByRole"], rewatch_loadInt["SortByRole"] = 0, 0; end; end;
		elseif(child:GetName() == "Rewatch_LDEFCB") then
			if(get) then if(rewatch_loadInt["Layout"] == "horizontal") then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["Layout"], rewatch_loadInt["Layout"] = "horizontal", "horizontal"; end; end;
		elseif(child:GetName() == "Rewatch_LVERTCB") then
			if(get) then if(rewatch_loadInt["Layout"] == "vertical") then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["Layout"], rewatch_loadInt["Layout"] = "vertical", "vertical"; end; end;
		end;
	end;
	
	-- custom highlighting
	children = { rewatch_options3:GetChildren() };
	for _, child in ipairs(children) do
		if(child:GetName() == "Rewatch_Highlighting") then
			if(get) then
				child:SetText(""); if(rewatch_loadInt["Highlighting"]) then for i, s in ipairs(rewatch_loadInt["Highlighting"]) do if(i > 1) then child:Insert("\n"); end; child:Insert(s); end; end;
			else
				rewatch_loadInt["Highlighting"] = {};
				local s, pos = child:GetText(), 0;
				for st, sp in function() return string.find(s, "\n", pos, true) end do
					table.insert(rewatch_loadInt["Highlighting"], string.sub(s, pos, st-1)); pos = sp + 1;
				end; table.insert(rewatch_loadInt["Highlighting"], string.sub(s, pos));
				rewatch_load["Highlighting"] = rewatch_loadInt["Highlighting"];
			end;
		elseif(child:GetName() == "Rewatch_Highlighting2") then
			if(get) then
				child:SetText(""); if(rewatch_loadInt["Highlighting2"]) then for i, s in ipairs(rewatch_loadInt["Highlighting2"]) do if(i > 1) then child:Insert("\n"); end; child:Insert(s); end; end;
			else
				rewatch_loadInt["Highlighting2"] = {};
				local s, pos = child:GetText(), 0;
				for st, sp in function() return string.find(s, "\n", pos, true) end do
					table.insert(rewatch_loadInt["Highlighting2"], string.sub(s, pos, st-1)); pos = sp + 1;
				end; table.insert(rewatch_loadInt["Highlighting2"], string.sub(s, pos));
				rewatch_load["Highlighting2"] = rewatch_loadInt["Highlighting2"];
			end;
		elseif(child:GetName() == "Rewatch_Highlighting3") then
			if(get) then
				child:SetText(""); if(rewatch_loadInt["Highlighting3"]) then for i, s in ipairs(rewatch_loadInt["Highlighting3"]) do if(i > 1) then child:Insert("\n"); end; child:Insert(s); end; end;
			else
				rewatch_loadInt["Highlighting3"] = {};
				local s, pos = child:GetText(), 0;
				for st, sp in function() return string.find(s, "\n", pos, true) end do
					table.insert(rewatch_loadInt["Highlighting3"], string.sub(s, pos, st-1)); pos = sp + 1;
				end; table.insert(rewatch_loadInt["Highlighting3"], string.sub(s, pos));
				rewatch_load["Highlighting3"] = rewatch_loadInt["Highlighting3"];
			end;
		end;
	end;
	
	-- macro's & spells
	children = { rewatch_options4:GetChildren() };
	for _, child in ipairs(children) do
		-- if it's the alt macro
		if(child:GetName() == "Rewatch_AltMacro") then
			if(get) then child:SetText(rewatch_load["AltMacro"]); child:SetCursorPosition(0);
			else rewatch_load["AltMacro"] = child:GetText(); rewatch_loadInt["AltMacro"] = child:GetText(); end;
		-- if it's the ctrl macro
		elseif(child:GetName() == "Rewatch_CtrlMacro") then
			if(get) then child:SetText(rewatch_load["CtrlMacro"]); child:SetCursorPosition(0);
			else rewatch_load["CtrlMacro"] = child:GetText(); rewatch_loadInt["CtrlMacro"] = child:GetText(); end;
		-- if it's the shift macro
		elseif(child:GetName() == "Rewatch_ShiftMacro") then
			if(get) then child:SetText(rewatch_load["ShiftMacro"]); child:SetCursorPosition(0);
			else rewatch_load["ShiftMacro"] = child:GetText(); rewatch_loadInt["ShiftMacro"] = child:GetText(); end;
		-- if it's the buttons
		-- special buttons  for current class: shaman (7) , druid (11)
		elseif(child:GetName() == "Rewatch_Buttons"..rewatch_loadInt["ClassID"]) then
			if(get) then
				child:SetText("");
				if(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]]) 
				then 
				  for i, s in ipairs(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]]) do if(i > 1) then child:Insert("\n"); end; child:Insert(s); end; end;
			else
				rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]] = {};
				local s, pos = child:GetText(), 0;
				for st, sp in function() return string.find(s, "\n", pos, true) end do
					table.insert(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]], string.sub(s, pos, st-1)); pos = sp + 1;
				end; table.insert(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]], string.sub(s, pos));
				rewatch_load["ButtonSpells"..rewatch_loadInt["ClassID"]] = rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]];
			end;
		end;
	end;
	
	-- apply changes
	if((not get) and (InCombatLockdown() ~= 1)) then
		rewatch:Render();
		if(((rewatch_i == 2) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
	end;
	
end;