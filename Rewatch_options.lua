-- Rewatch originally by Dezine, Argent Dawn, Europe (Coen van der Wel, Almere, the Netherlands).
-- Also maintained by bobn64 (Tyrahis, Shu'halo).

-- Please give full credit when you want to redistribute or modify this addon!

function rewatch_CreateOptions()
	-- create only once, please
	if(rewatch_options ~= nil) then return; end;
	-- create the options frame
	rewatch_options = CreateFrame("FRAME", "Rewatch_Options", UIParent); rewatch_options.name = "Rewatch";
	rewatch_options2 = CreateFrame("FRAME", "Rewatch_Options2", UIParent); rewatch_options2.name = "Advanced"; rewatch_options2.parent = "Rewatch";
	rewatch_options3 = CreateFrame("FRAME", "Rewatch_Options3", UIParent); rewatch_options3.name = "Highlighting"; rewatch_options3.parent = "Rewatch";
	rewatch_options4 = CreateFrame("FRAME", "Rewatch_Options4", UIParent); rewatch_options4.name = "Macros"; rewatch_options4.parent = "Rewatch";
	-- slider
	local alphaSliderT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	alphaSliderT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -20); alphaSliderT:SetText(rewatch_loc["gcdText"]);
	local alphaSlider = CreateFrame("SLIDER", "Rewatch_AlphaSlider", rewatch_options, "OptionsSliderTemplate");
	alphaSlider:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -20); alphaSlider:SetMinMaxValues(0, 1); alphaSlider:SetValueStep(0.1);
	getglobal("Rewatch_AlphaSliderLow"):SetText(rewatch_loc["invisible"]); getglobal("Rewatch_AlphaSliderHigh"):SetText(rewatch_loc["visible"]);
	-- slider two
	local OORalphaSliderT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	OORalphaSliderT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -50); OORalphaSliderT:SetText(rewatch_loc["OORText"]);
	local OORalphaSlider = CreateFrame("SLIDER", "Rewatch_OORAlphaSlider", rewatch_options, "OptionsSliderTemplate");
	OORalphaSlider:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -50); OORalphaSlider:SetMinMaxValues(0, 1); OORalphaSlider:SetValueStep(0.1);
	getglobal("Rewatch_OORAlphaSliderLow"):SetText(rewatch_loc["invisible"]); getglobal("Rewatch_OORAlphaSliderHigh"):SetText(rewatch_loc["visible"]);
	-- health bar color
	local healthCPT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	healthCPT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -90); healthCPT:SetText(rewatch_loc["healthback"]);
	local healthCP = CreateFrame("BUTTON", "Rewatch_HealthCP", rewatch_options); healthCP:SetWidth(18); healthCP:SetHeight(18);
	healthCP:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	healthCP:SetBackdropColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 0.8);
	healthCP:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 213, -90);
	healthCP:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, nil, rewatch_UpdateHColor); end);
	local healthCPR = CreateFrame("BUTTON", "Rewatch_HealthCPR", rewatch_options, "OptionsButtonTemplate"); healthCPR:SetText(rewatch_loc["reset"]);
	healthCPR:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -88); healthCPR:SetScript("OnClick", function() rewatch_loadInt["HealthColor"] = { r=0; g=0.7; b=0}; rewatch_load["HealthColor"] = rewatch_loadInt["HealthColor"]; rewatch_UpdateSwatch(); end);
	-- frame color
	local frameCPT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	frameCPT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -110); frameCPT:SetText(rewatch_loc["frameback"]);
	local frameCP = CreateFrame("BUTTON", "Rewatch_FrameCP", rewatch_options); frameCP:SetWidth(18); frameCP:SetHeight(18);
	frameCP:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	frameCP:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a); frameCP:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 213, -110);
	frameCP:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a, rewatch_UpdateFColor); end);
	local frameCPR = CreateFrame("BUTTON", "Rewatch_FrameCPR", rewatch_options, "OptionsButtonTemplate"); frameCPR:SetText(rewatch_loc["reset"]);
	frameCPR:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -108); frameCPR:SetScript("OnClick", function()
		rewatch_loadInt["MarkFrameColor"] = { r=0; g=1; b=0; a=1 }; rewatch_load["MarkFrameColor"] = rewatch_loadInt["MarkFrameColor"];
		rewatch_loadInt["FrameColor"] = { r=0; g=0; b=0; a=0.3 }; rewatch_load["FrameColor"] = rewatch_loadInt["FrameColor"];
		rewatch_UpdateSwatch(); for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then val["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a); end; end;
	end);
	-- frame mark color
	local mframeCP = CreateFrame("BUTTON", "Rewatch_MFrameCP", rewatch_options); mframeCP:SetWidth(18); mframeCP:SetHeight(18);
	mframeCP:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	mframeCP:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a); mframeCP:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 195, -110);
	mframeCP:SetScript("OnClick", function() ColorPickerFrame:Hide(); OpacitySliderFrame:SetValue((1-rewatch_loadInt["MarkFrameColor"].a)); ColorPickerFrame.opacityFunc = rewatch_UpdateMFColor; ColorPickerFrame.func = rewatch_UpdateMFColor; ColorPickerFrame:SetColorRGB(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b); ColorPickerFrame.hasOpacity = true; ColorPickerFrame.opacity = (1-rewatch_loadInt["MarkFrameColor"].a); OpacitySliderFrame:SetValue((1-rewatch_loadInt["MarkFrameColor"].a)); ColorPickerFrame:Show(); end);
	-- bar colors
	local barCPT_lb = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	barCPT_lb:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -130); barCPT_lb:SetText(rewatch_loc["barback"].." "..rewatch_loc["lifebloom"]);
	local barCPT_rej = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	barCPT_rej:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -150); barCPT_rej:SetText(rewatch_loc["barback"].." "..rewatch_loc["rejuvenation"]);
	local barCPT_reg = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	barCPT_reg:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -170); barCPT_reg:SetText(rewatch_loc["barback"].." "..rewatch_loc["regrowth"]);
	local barCPT_wg = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	barCPT_wg:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -190); barCPT_wg:SetText(rewatch_loc["barback"].." "..rewatch_loc["wildgrowth"]);
	local barCP_lb = CreateFrame("BUTTON", "Rewatch_BarCP"..rewatch_loc["lifebloom"], rewatch_options); barCP_lb:SetWidth(18); barCP_lb:SetHeight(18);
	barCP_lb:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	barCP_lb:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].r, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].g, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].b, 0.8); barCP_lb:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 213, -130);
	barCP_lb:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].r, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].g, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].b, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].a, rewatch_UpdateBLBColor); end);
	local barCP_rej = CreateFrame("BUTTON", "Rewatch_BarCP"..rewatch_loc["rejuvenation"], rewatch_options); barCP_rej:SetWidth(18); barCP_rej:SetHeight(18);
	barCP_rej:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	barCP_rej:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].b, 0.8); barCP_rej:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 213, -150);
	barCP_rej:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].b, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].a, rewatch_UpdateBREJColor); end);
	local barCP_rej2 = CreateFrame("BUTTON", "Rewatch_BarCP"..rewatch_loc["rejuvenation"].."2", rewatch_options); barCP_rej2:SetWidth(18); barCP_rej2:SetHeight(18);
	barCP_rej2:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	barCP_rej2:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].b, 0.8); barCP_rej2:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 195, -150);
	barCP_rej2:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].b, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"].a, rewatch_UpdateBREJ2Color); end);
	local barCP_reg = CreateFrame("BUTTON", "Rewatch_BarCP"..rewatch_loc["regrowth"], rewatch_options); barCP_reg:SetWidth(18); barCP_reg:SetHeight(18);
	barCP_reg:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	barCP_reg:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].b, 0.8); barCP_reg:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 213, -170);
	barCP_reg:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].b, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].a, rewatch_UpdateBREWColor); end);
	local barCP_wg = CreateFrame("BUTTON", "Rewatch_BarCP"..rewatch_loc["wildgrowth"], rewatch_options); barCP_wg:SetWidth(18); barCP_wg:SetHeight(18);
	barCP_wg:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	barCP_wg:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].b, 0.8); barCP_wg:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 213, -190);
	barCP_wg:SetScript("OnClick", function() ShowColorPicker(rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].b, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].a, rewatch_UpdateBWGColor); end);
	-- reset buttons
	local barCPR_lb = CreateFrame("BUTTON", "Rewatch_BarCPR", rewatch_options, "OptionsButtonTemplate"); barCPR_lb:SetText(rewatch_loc["reset"]);
	barCPR_lb:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -128); barCPR_lb:SetScript("OnClick", function() rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]] = { r=0.6; g=0; b=0, a=1}; rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]]; rewatch_UpdateSwatch(); end);
	local barCPR_rej = CreateFrame("BUTTON", "Rewatch_BarCPR", rewatch_options, "OptionsButtonTemplate"); barCPR_rej:SetText(rewatch_loc["reset"]);
	barCPR_rej:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -148); barCPR_rej:SetScript("OnClick", function()
		rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]] = { r=0.85; g=0.15; b=0.80, a=1}; rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"] = { r=0.85; g=0.15; b=0.80, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation"]] = rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]]; rewatch_load["BarColor"..rewatch_loc["rejuvenation"].."2"] = rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"];
		rewatch_UpdateSwatch();
	end);
	local barCPR_reg = CreateFrame("BUTTON", "Rewatch_BarCPR", rewatch_options, "OptionsButtonTemplate"); barCPR_reg:SetText(rewatch_loc["reset"]);
	barCPR_reg:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -168); barCPR_reg:SetScript("OnClick", function() rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]] = { r=0.05; g=0.3; b=0.1, a=1}; rewatch_load["BarColor"..rewatch_loc["regrowth"]] = rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]]; rewatch_UpdateSwatch(); end);
	local barCPR_wg = CreateFrame("BUTTON", "Rewatch_BarCPR", rewatch_options, "OptionsButtonTemplate"); barCPR_wg:SetText(rewatch_loc["reset"]);
	barCPR_wg:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -188); barCPR_wg:SetScript("OnClick", function() rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]] = { r=0.5; g=0.8; b=0.3, a=1}; rewatch_load["BarColor"..rewatch_loc["wildgrowth"]] = rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]]; rewatch_UpdateSwatch(); end);
	-- left options
	local hideCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	hideCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -220); hideCBT:SetText(rewatch_loc["hide"]);
	local hideCB = CreateFrame("CHECKBUTTON", "Rewatch_HideCB", rewatch_options, "OptionsCheckButtonTemplate");
	hideCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -213);
	local hideButtonsCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	hideButtonsCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -240); hideButtonsCBT:SetText(rewatch_loc["hideButtons"]);
	local hideButtonsCB = CreateFrame("CHECKBUTTON", "Rewatch_HideButtonsCB", rewatch_options, "OptionsCheckButtonTemplate");
	hideButtonsCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -233);
	hideButtonsCB:SetScript("OnClick", function(self) rewatch_changedDimentions = true; end);
	local autoGroupCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	autoGroupCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -260); autoGroupCBT:SetText(rewatch_loc["autoAdjust"]);
	local autoGroupCB = CreateFrame("CHECKBUTTON", "Rewatch_AutoGroupCB", rewatch_options, "OptionsCheckButtonTemplate");
	autoGroupCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -253);
	local lockCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	lockCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -280); lockCBT:SetText(rewatch_loc["lockMain"]);
	local lockCB = CreateFrame("CHECKBUTTON", "Rewatch_LockCB", rewatch_options, "OptionsCheckButtonTemplate");
	lockCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -273);
	local labelsCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	labelsCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -300); labelsCBT:SetText(rewatch_loc["labelsOrTimers"]);
	local labelsCB = CreateFrame("CHECKBUTTON", "Rewatch_LabelsCB", rewatch_options, "OptionsCheckButtonTemplate");
	labelsCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -293);
	labelsCB:SetScript("OnClick", function(self) rewatch_changedDimentions = true; end);
	local lockPCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	lockPCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 250, -280); lockPCBT:SetText(rewatch_loc["lockPlayers"]);
	local lockPCB = CreateFrame("CHECKBUTTON", "Rewatch_LockPCB", rewatch_options, "OptionsCheckButtonTemplate");
	lockPCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 210, -273);
	local wgCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	wgCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 50, -320); wgCBT:SetText(rewatch_loc["talentedwg"]);
	local wgCB = CreateFrame("CHECKBUTTON", "Rewatch_WGCB", rewatch_options, "OptionsCheckButtonTemplate");
	wgCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 10, -313);
	wgCB:SetScript("OnClick", function(self) rewatch_changedDimentions = true; end);
	local soloHideCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	soloHideCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 250, -300); soloHideCBT:SetText(rewatch_loc["hideSolo"]);
	local soloHideCB = CreateFrame("CHECKBUTTON", "Rewatch_SoloHideCB", rewatch_options, "OptionsCheckButtonTemplate");
	soloHideCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 210, -293);
	local ttCBT = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ttCBT:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 250, -320); ttCBT:SetText(rewatch_loc["showtooltips"]);
	local ttCB = CreateFrame("CHECKBUTTON", "Rewatch_TTCB", rewatch_options, "OptionsCheckButtonTemplate");
	ttCB:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 210, -313);
	local bart = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	bart:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -350); bart:SetText("Bar texture:");
	local bar = CreateFrame("EDITBOX", "Rewatch_BarTexture", rewatch_options);
	bar:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	bar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	bar:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 200, -350);
	bar:SetWidth(175); bar:SetHeight(15); bar:SetAutoFocus(nil);
	bar:SetFontObject(GameFontHighlight);
	local fontTypet = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	fontTypet:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -370); fontTypet:SetText("Font type:");
	local fontType = CreateFrame("EDITBOX", "Rewatch_FontType", rewatch_options);
	fontType:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	fontType:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	fontType:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 200, -370);
	fontType:SetWidth(175); fontType:SetHeight(15); fontType:SetAutoFocus(nil);
	fontType:SetFontObject(GameFontHighlight);
	local fontSizet = rewatch_options:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	fontSizet:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 15, -390); fontSizet:SetText("Font size / Highlight size:");
	local fontSize = CreateFrame("EDITBOX", "Rewatch_FontSize", rewatch_options);
	fontSize:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	fontSize:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	fontSize:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 200, -390);
	fontSize:SetWidth(86); fontSize:SetHeight(15); fontSize:SetAutoFocus(nil);
	fontSize:SetFontObject(GameFontHighlight);
	local highlightSize = CreateFrame("EDITBOX", "Rewatch_HighlightSize", rewatch_options);
	highlightSize:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	highlightSize:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	highlightSize:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 290, -390);
	highlightSize:SetWidth(86); highlightSize:SetHeight(15); highlightSize:SetAutoFocus(nil);
	highlightSize:SetFontObject(GameFontHighlight);
	-- dimensions
	local slideCBWT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	slideCBWT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -30); slideCBWT:SetText(rewatch_loc["castbarWidth"]);
	local slideCBW = CreateFrame("SLIDER", "Rewatch_SlideCBW", rewatch_options2, "OptionsSliderTemplate");
	slideCBW:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -30); slideCBW:SetMinMaxValues(20, 150); slideCBW:SetValueStep(1);
	slideCBW:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; getglobal("Rewatch_SlideCBWText"):SetText(math.floor(self:GetValue()+0.5)); end);
	getglobal("Rewatch_SlideCBWLow"):SetText("20"); getglobal("Rewatch_SlideCBWHigh"):SetText("150");
	local slideHBHT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	slideHBHT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -60); slideHBHT:SetText(rewatch_loc["healthbarHeight"]);
	local slideHBH = CreateFrame("SLIDER", "Rewatch_SlideHBH", rewatch_options2, "OptionsSliderTemplate");
	slideHBH:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -60); slideHBH:SetMinMaxValues(5, 150); slideHBH:SetValueStep(1);
	slideHBH:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; getglobal("Rewatch_SlideHBHText"):SetText(math.floor(self:GetValue()+0.5)); end);
	getglobal("Rewatch_SlideHBHLow"):SetText("5"); getglobal("Rewatch_SlideHBHHigh"):SetText("150");
	local slideCBHT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	slideCBHT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -90); slideCBHT:SetText(rewatch_loc["castbarHeight"]);
	local slideCBH = CreateFrame("SLIDER", "Rewatch_SlideCBH", rewatch_options2, "OptionsSliderTemplate");
	slideCBH:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -90); slideCBH:SetMinMaxValues(5, 50); slideCBH:SetValueStep(1);
	slideCBH:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; getglobal("Rewatch_SlideCBHText"):SetText(math.floor(self:GetValue()+0.5)); end);
	getglobal("Rewatch_SlideCBHLow"):SetText("5"); getglobal("Rewatch_SlideCBHHigh"):SetText("50");
	local slideSCT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	slideSCT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -120); slideSCT:SetText(rewatch_loc["scaling"]);
	local slideSC = CreateFrame("SLIDER", "Rewatch_SlideSC", rewatch_options2, "OptionsSliderTemplate");
	slideSC:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -120); slideSC:SetMinMaxValues(1, 200); slideSC:SetValueStep(1);
	slideSC:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; getglobal("Rewatch_SlideSCText"):SetText(math.floor(self:GetValue()+0.5).."%"); end);
	getglobal("Rewatch_SlideSCLow"):SetText("1%"); getglobal("Rewatch_SlideSCHigh"):SetText("200%");
	local PBOalphaSliderT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	PBOalphaSliderT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -150); PBOalphaSliderT:SetText(rewatch_loc["PBOText"]);
	local PBOalphaSlider = CreateFrame("SLIDER", "Rewatch_PBOAlphaSlider", rewatch_options2, "OptionsSliderTemplate");
	PBOalphaSlider:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -150); PBOalphaSlider:SetMinMaxValues(0, 1); PBOalphaSlider:SetValueStep(0.1);
	PBOalphaSlider:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; end);
	getglobal("Rewatch_PBOAlphaSliderLow"):SetText(rewatch_loc["invisible"]); getglobal("Rewatch_PBOAlphaSliderHigh"):SetText(rewatch_loc["visible"]);
	-- layout
	local layoutDefaultT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	layoutDefaultT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -214); layoutDefaultT:SetText(rewatch_loc["horizontal"]);
	local layoutDefault = CreateFrame("CHECKBUTTON", "Rewatch_LDEFCB", rewatch_options2, "OptionsCheckButtonTemplate");
	layoutDefault:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -207);
	local layoutVerticalT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	layoutVerticalT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -240); layoutVerticalT:SetText(rewatch_loc["vertical"]);
	local layoutVertical = CreateFrame("CHECKBUTTON", "Rewatch_LVERTCB", rewatch_options2, "OptionsCheckButtonTemplate");
	layoutVertical:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -233);
	-- layout 'radio' button mech
	layoutDefault:SetScript("OnClick", function(self) rewatch_changedDimentions = true; layoutDefault:SetChecked(true); layoutVertical:SetChecked(false); end);
	layoutVertical:SetScript("OnClick", function(self) rewatch_changedDimentions = true; layoutVertical:SetChecked(true); layoutDefault:SetChecked(false); end);
	-- show incoming heals
	local showIncomingHealsT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	showIncomingHealsT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -188); showIncomingHealsT:SetText(rewatch_loc["showIncomingHeals"]);
	local showIncomingHeals = CreateFrame("CHECKBUTTON", "Rewatch_SIHCB", rewatch_options2, "OptionsCheckButtonTemplate");
	showIncomingHeals:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -181);
	-- sort options
	local sortByRoleT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	sortByRoleT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 250, -214); sortByRoleT:SetText(rewatch_loc["sortByRole"]);
	local sortByRole = CreateFrame("CHECKBUTTON", "Rewatch_SBRCB", rewatch_options2, "OptionsCheckButtonTemplate");
	sortByRole:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 210, -207);
	local showSelfFirstT = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	showSelfFirstT:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 250, -240); showSelfFirstT:SetText(rewatch_loc["showSelfFirst"]);
	local showSelfFirst = CreateFrame("CHECKBUTTON", "Rewatch_SSFCB", rewatch_options2, "OptionsCheckButtonTemplate");
	showSelfFirst:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 210, -233);
	-- show health
	local hdtext = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	hdtext:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 50, -285); hdtext:SetText(rewatch_loc["showDeficit"]);
	local hd = CreateFrame("CHECKBUTTON", "Rewatch_HDCB", rewatch_options2, "OptionsCheckButtonTemplate");
	hd:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -278);
	local hdt = CreateFrame("SLIDER", "Rewatch_HDT", rewatch_options2, "OptionsSliderTemplate");
	hdt:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -280); hdt:SetMinMaxValues(10, 300); hdt:SetValueStep(10);
	hdt:SetScript("OnValueChanged", function(self) local v = math.floor(self:GetValue()+0.5); if(v == 300) then v = "Always" else v = v.."k"; end; getglobal("Rewatch_HDTText"):SetText(v); end);
	getglobal("Rewatch_HDTLow"):SetText("10k"); getglobal("Rewatch_HDTHigh"):SetText("Always");
	-- num bars width
	local nbwt = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	nbwt:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -330); nbwt:SetText(rewatch_loc["numFramesWide"]);
	local nbw = CreateFrame("SLIDER", "Rewatch_NBW", rewatch_options2, "OptionsSliderTemplate");
	nbw:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -330); nbw:SetMinMaxValues(1, 25); nbw:SetValueStep(1);
	nbw:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; getglobal("Rewatch_NBWText"):SetText(math.floor(self:GetValue()+0.5)); end);
	getglobal("Rewatch_NBWLow"):SetText("1"); getglobal("Rewatch_NBWHigh"):SetText("25");
	-- name cutting
	local nct = rewatch_options2:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	nct:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -360); nct:SetText(rewatch_loc["maxNameLength"]);
	local ncw = CreateFrame("SLIDER", "Rewatch_NCW", rewatch_options2, "OptionsSliderTemplate");
	ncw:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 213, -360); ncw:SetMinMaxValues(0, 25); ncw:SetValueStep(1);
	ncw:SetScript("OnValueChanged", function(self) rewatch_changedDimentions = true; getglobal("Rewatch_NCWText"):SetText(math.floor(self:GetValue()+0.5)); end);
	getglobal("Rewatch_NCWLow"):SetText("(0 = Show all)"); getglobal("Rewatch_NCWHigh"):SetText("25");
	-- apply
	local applyBTN = CreateFrame("BUTTON", "Rewatch_ApplyBTN", rewatch_options2, "OptionsButtonTemplate"); applyBTN:SetText("Apply");
	applyBTN:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 10, -390); applyBTN:SetScript("OnClick", function() rewatch_OptionsFromData(false); rewatch_Clear(); rewatch_changed = true; rewatch_changedDimentions = false; end);
	-- presets
	local preset1BTN = CreateFrame("BUTTON", "Rewatch_ApplyBTN", rewatch_options2, "OptionsButtonTemplate"); preset1BTN:SetText("Normal");
	preset1BTN:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 120, -390); preset1BTN:SetScript("OnClick", function() rewatch_SetLayout("normal"); rewatch_OptionsFromData(true); end);
	local preset2BTN = CreateFrame("BUTTON", "Rewatch_ApplyBTN", rewatch_options2, "OptionsButtonTemplate"); preset2BTN:SetText("Minimalist");
	preset2BTN:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 200, -390); preset2BTN:SetScript("OnClick", function() rewatch_SetLayout("minimalist"); rewatch_OptionsFromData(true); end);
	local preset3BTN = CreateFrame("BUTTON", "Rewatch_ApplyBTN", rewatch_options2, "OptionsButtonTemplate"); preset3BTN:SetText("Classic");
	preset3BTN:SetPoint("TOPLEFT", rewatch_options2, "TOPLEFT", 280, -390); preset3BTN:SetScript("OnClick", function() rewatch_SetLayout("classic"); rewatch_OptionsFromData(true); end);
	-- buttons
	local sortBTN = CreateFrame("BUTTON", "Rewatch_BuffCheckBTN", rewatch_options, "OptionsButtonTemplate"); sortBTN:SetText(rewatch_loc["sortList"]);
	sortBTN:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -213); sortBTN:SetScript("OnClick", function() if(rewatch_loadInt["AutoGroup"] == 0) then rewatch_Message(rewatch_loc["nosort"]); else rewatch_Clear(); rewatch_changed = true; rewatch_Message(rewatch_loc["sorted"]); end; end);
	local clearBTN = CreateFrame("BUTTON", "Rewatch_BuffCheckBTN", rewatch_options, "OptionsButtonTemplate"); clearBTN:SetText(rewatch_loc["clearList"]);
	clearBTN:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -233); clearBTN:SetScript("OnClick", function() rewatch_Clear(); rewatch_Message(rewatch_loc["cleared"]); end);
	local reposBTN = CreateFrame("BUTTON", "Rewatch_RepositionBTN", rewatch_options, "OptionsButtonTemplate"); reposBTN:SetText(rewatch_loc["reposition"]);
	reposBTN:SetPoint("TOPLEFT", rewatch_options, "TOPLEFT", 235, -253); reposBTN:SetScript("OnClick", function() rewatch_f:ClearAllPoints(); rewatch_f:SetPoint("CENTER", UIParent); rewatch_Message(rewatch_loc["repositioned"]); end);
	-- custom highlighting
	local cht = rewatch_options3:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	cht:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 10, -10); cht:SetText("Low risk");
	local ch = CreateFrame("EDITBOX", "Rewatch_Highlighting", rewatch_options3);
	ch:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ch:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 10, -30);
	ch:SetPoint("BOTTOMLEFT", rewatch_options3, "BOTTOMLEFT", 10, 10);
	ch:SetWidth(130); ch:SetMultiLine(true); ch:SetAutoFocus(nil);
	ch:SetFontObject(GameFontHighlight);
	local ch2t = rewatch_options3:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ch2t:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 141, -10); ch2t:SetText("Medium risk");
	local ch2 = CreateFrame("EDITBOX", "Rewatch_Highlighting2", rewatch_options3);
	ch2:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ch2:SetPoint("TOPLEFT", rewatch_options3, "TOPLEFT", 141, -30);
	ch2:SetPoint("BOTTOMRIGHT", rewatch_options3, "BOTTOMRIGHT", -141, 10);
	ch2:SetMultiLine(true); ch2:SetAutoFocus(nil);
	ch2:SetFontObject(GameFontHighlight);
	local ch3t = rewatch_options3:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ch3t:SetPoint("TOPRIGHT", rewatch_options3, "TOPRIGHT", -10, -10); ch3t:SetText("OMGOMGOMG");
	local ch3 = CreateFrame("EDITBOX", "Rewatch_Highlighting3", rewatch_options3);
	ch3:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ch3:SetPoint("TOPRIGHT", rewatch_options3, "TOPRIGHT", -10, -30);
	ch3:SetPoint("BOTTOMRIGHT", rewatch_options3, "BOTTOMRIGHT", -10, 10);
	ch3:SetWidth(130); ch3:SetMultiLine(true); ch3:SetAutoFocus(nil);
	ch3:SetFontObject(GameFontHighlight);
	-- macros
	local altt = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	altt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -10); altt:SetText("Alt macro");
	local alt = CreateFrame("EDITBOX", "Rewatch_AltMacro", rewatch_options4);
	alt:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	alt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -30);
	alt:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -120);
	alt:SetMultiLine(true); alt:SetAutoFocus(nil);
	alt:SetFontObject(GameFontHighlight);
	alt:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	local ctrlt = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	ctrlt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -130); ctrlt:SetText("Ctrl macro");
	local ctrl = CreateFrame("EDITBOX", "Rewatch_CtrlMacro", rewatch_options4);
	ctrl:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	ctrl:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -150);
	ctrl:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -240);
	ctrl:SetMultiLine(true); ctrl:SetAutoFocus(nil);
	ctrl:SetFontObject(GameFontHighlight);
	ctrl:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	local shiftt = rewatch_options4:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	shiftt:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -250); shiftt:SetText("Shift macro");
	local shift = CreateFrame("EDITBOX", "Rewatch_ShiftMacro", rewatch_options4);
	shift:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 3, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	shift:SetPoint("TOPLEFT", rewatch_options4, "TOPLEFT", 10, -270);
	shift:SetPoint("BOTTOMRIGHT", rewatch_options4, "TOPRIGHT", -10, -360);
	shift:SetMultiLine(true); shift:SetAutoFocus(nil);
	shift:SetFontObject(GameFontHighlight);
	shift:SetScript("OnTextChanged", function(self) rewatch_changedDimentions = true; end);
	-- handlers
	rewatch_options.okay = function(self)
		rewatch_OptionsFromData(false);
		if(rewatch_changedDimentions) then
			if(InCombatLockdown() == 1) then
				rewatch_changed = true;
				rewatch_changedDimentions = false;
				rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_Clear();
				rewatch_changed = true;
				rewatch_Message(rewatch_loc["sorted"]);
				rewatch_changedDimentions = false;
			end;
		end;
	end;
	rewatch_options.cancel = function(self) rewatch_OptionsFromData(true); end;
	rewatch_options.default = function(self) rewatch_version, rewatch_load = nil, nil; rewatch_loadInt["Loaded"] = false; end;
	-- add panels
	InterfaceOptions_AddCategory(rewatch_options);
	InterfaceOptions_AddCategory(rewatch_options2);
	InterfaceOptions_AddCategory(rewatch_options3);
	InterfaceOptions_AddCategory(rewatch_options4);
end;

-- function set set the options frame values
-- get: boolean if the function will get data (true) or set data (false) from the options frame
-- return: void
function rewatch_OptionsFromData(get)
	-- get the childeren elements
	local children = { rewatch_options:GetChildren() };
	for _, child in ipairs(children) do
		-- if it's the slider, set or get his data
		if(child:GetName() == "Rewatch_AlphaSlider") then
			if(get) then child:SetValue(rewatch_loadInt["GcdAlpha"]);
			else rewatch_load["GcdAlpha"], rewatch_loadInt["GcdAlpha"] = child:GetValue(), child:GetValue(); end;
		-- if it's the OOR slider, set or get his data
		elseif(child:GetName() == "Rewatch_OORAlphaSlider") then
			if(get) then child:SetValue(rewatch_loadInt["OORAlpha"]);
			else rewatch_load["OORAlpha"], rewatch_loadInt["OORAlpha"] = child:GetValue(), child:GetValue(); end;
		-- if it's the autogroup checkbutton, set or get his data
		elseif(child:GetName() == "Rewatch_AutoGroupCB") then
			if(get) then if(rewatch_loadInt["AutoGroup"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["AutoGroup"], rewatch_loadInt["AutoGroup"] = 1, 1;
				else
					if(rewatch_loadInt["AutoGroup"] == 1) then rewatch_load["AutoGroup"], rewatch_loadInt["AutoGroup"] = 0, 0; rewatch_changed = true;
					else rewatch_load["AutoGroup"], rewatch_loadInt["AutoGroup"] = 0, 0; end;
				end; end;
		-- if it's the hidesolo checkbutton, set or get his data
		elseif(child:GetName() == "Rewatch_SoloHideCB") then
			if(get) then if(rewatch_loadInt["HideSolo"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["HideSolo"], rewatch_loadInt["HideSolo"] = 1, 1;
				else rewatch_load["HideSolo"], rewatch_loadInt["HideSolo"] = 0, 0; end; end;
		-- if it's the hide buttons checkbutton, set or get his data
		elseif(child:GetName() == "Rewatch_HideButtonsCB") then
			if(get) then if(rewatch_loadInt["ShowButtons"] == 0) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["ShowButtons"], rewatch_loadInt["ShowButtons"] = 0, 0;
				else rewatch_load["ShowButtons"], rewatch_loadInt["ShowButtons"] = 1, 1; end; end;
		-- if it's the hide checkbutton, set or get his data
		elseif(child:GetName() == "Rewatch_HideCB") then
			if(get) then if(rewatch_loadInt["Hide"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["Hide"], rewatch_loadInt["Hide"] = 1, 1;
				else rewatch_load["Hide"], rewatch_loadInt["Hide"] = 0, 0; end; end;
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
		-- if it's the lock checkbox, set or get this data
		elseif(child:GetName() == "Rewatch_LockCB") then
			if(get) then if(rewatch_loadInt["Lock"]) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_loadInt["Lock"] = true; else rewatch_loadInt["Lock"] = false; end; end;
		-- if it's the lock players checkbox, set or get this data
		elseif(child:GetName() == "Rewatch_LockPCB") then
			if(get) then if(rewatch_loadInt["LockP"]) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_loadInt["LockP"] = true; else rewatch_loadInt["LockP"] = false; end; end;
		-- if it's the labels checkbox, set or get this data
		elseif(child:GetName() == "Rewatch_LabelsCB") then
			if(get) then if(rewatch_loadInt["Labels"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["Labels"] = 1; rewatch_loadInt["Labels"] = 1; else rewatch_loadInt["Labels"] = 0; rewatch_load["Labels"] = 0; end; end;
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
	-- dimentions
	children = { rewatch_options2:GetChildren() };
	for _, child in ipairs(children) do
		if(child:GetName() == "Rewatch_PBOAlphaSlider") then
			if(get) then child:SetValue(rewatch_loadInt["PBOAlpha"]);
			else rewatch_load["PBOAlpha"], rewatch_loadInt["PBOAlpha"] = child:GetValue(), child:GetValue(); end;
		elseif(child:GetName() == "Rewatch_SIHCB") then
			if(get) then if(rewatch_loadInt["ShowIncomingHeals"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["ShowIncomingHeals"], rewatch_loadInt["ShowIncomingHeals"] = 1, 1;
				else rewatch_load["ShowIncomingHeals"], rewatch_loadInt["ShowIncomingHeals"] = 0, 0; end; end;
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
		elseif(child:GetName() == "Rewatch_SlideSC") then
			if(get) then child:SetValue(rewatch_loadInt["Scaling"]); getglobal("Rewatch_SlideSCText"):SetText(rewatch_loadInt["Scaling"].."%");
			else rewatch_load["Scaling"], rewatch_loadInt["Scaling"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
		elseif(child:GetName() == "Rewatch_SlideHBH") then
			if(get) then child:SetValue(rewatch_loadInt["HealthBarHeight"]); getglobal("Rewatch_SlideHBHText"):SetText(rewatch_loadInt["HealthBarHeight"]);
			else rewatch_load["HealthBarHeight"], rewatch_loadInt["HealthBarHeight"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
		elseif(child:GetName() == "Rewatch_SlideCBW") then
			if(get) then child:SetValue(rewatch_loadInt["SpellBarWidth"]); getglobal("Rewatch_SlideCBWText"):SetText(rewatch_loadInt["SpellBarWidth"]);
			else rewatch_load["SpellBarWidth"], rewatch_loadInt["SpellBarWidth"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
		elseif(child:GetName() == "Rewatch_SlideCBH") then
			if(get) then child:SetValue(rewatch_loadInt["SpellBarHeight"]); getglobal("Rewatch_SlideCBHText"):SetText(rewatch_loadInt["SpellBarHeight"]);
			else rewatch_load["SpellBarHeight"], rewatch_loadInt["SpellBarHeight"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
		elseif(child:GetName() == "Rewatch_HDT") then
			if(get) then child:SetValue(rewatch_loadInt["DeficitThreshold"]); getglobal("Rewatch_HDTText"):SetText(rewatch_loadInt["DeficitThreshold"].."k");
			else rewatch_load["DeficitThreshold"], rewatch_loadInt["DeficitThreshold"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
		elseif(child:GetName() == "Rewatch_HDCB") then
			if(get) then if(rewatch_loadInt["HealthDeficit"] == 1) then child:SetChecked(true); else child:SetChecked(false); end;
			else if(child:GetChecked()) then rewatch_load["HealthDeficit"], rewatch_loadInt["HealthDeficit"] = 1, 1;
				else rewatch_load["HealthDeficit"], rewatch_loadInt["HealthDeficit"] = 0, 0; end; end;
		elseif(child:GetName() == "Rewatch_NBW") then
			if(get) then child:SetValue(rewatch_loadInt["NumFramesWide"]); getglobal("Rewatch_NBWText"):SetText(rewatch_loadInt["NumFramesWide"]);
			else rewatch_load["NumFramesWide"], rewatch_loadInt["NumFramesWide"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
		elseif(child:GetName() == "Rewatch_NCW") then
			if(get) then child:SetValue(rewatch_loadInt["NameCharLimit"]); getglobal("Rewatch_NCWText"):SetText(rewatch_loadInt["NameCharLimit"]);
			else rewatch_load["NameCharLimit"], rewatch_loadInt["NameCharLimit"] = math.floor(child:GetValue()+0.5), math.floor(child:GetValue()+0.5); end;
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
	-- custom highlighting
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
		end;
	end;
	-- apply changes
	if((not get) and (InCombatLockdown() ~= 1)) then
		rewatch_UpdateOffset();
		rewatch_gcd:SetAlpha(rewatch_loadInt["GcdAlpha"]);
		if(((rewatch_i == 2) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
	end;
end;

-- update a bar color and it's swatch
-- return: void
function rewatch_UpdateBLBColor()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]] = { r=rc, g=gc, b=bc, a=ac };
	rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]]; rewatch_UpdateSwatch();
end;
function rewatch_UpdateBREJColor()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]] = { r=rc, g=gc, b=bc, a=ac };
	rewatch_load["BarColor"..rewatch_loc["rejuvenation"]] = rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]]; rewatch_UpdateSwatch();
end;
function rewatch_UpdateBREJ2Color()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"] = { r=rc, g=gc, b=bc, a=ac };
	rewatch_load["BarColor"..rewatch_loc["rejuvenation"].."2"] = rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"]; rewatch_UpdateSwatch();
end;
function rewatch_UpdateBREWColor()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]] = { r=rc, g=gc, b=bc, a=ac };
	rewatch_load["BarColor"..rewatch_loc["regrowth"]] = rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]]; rewatch_UpdateSwatch();
end;
function rewatch_UpdateBWGColor()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]] = { r=rc, g=gc, b=bc, a=ac };
	rewatch_load["BarColor"..rewatch_loc["wildgrowth"]] = rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]]; rewatch_UpdateSwatch();
end;

-- update the frame color and it's swatch
-- return: void
function rewatch_UpdateFColor()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["FrameColor"] = { r=rc, g=gc, b=bc, a=ac};
	rewatch_load["FrameColor"] = rewatch_loadInt["FrameColor"]; rewatch_UpdateSwatch();
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then val["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a); end; end;
end;

-- update the mark frame color and it's swatch
-- return: void
function rewatch_UpdateMFColor()
	local ac, rc, gc, bc = (1-OpacitySliderFrame:GetValue()), ColorPickerFrame:GetColorRGB(); rewatch_loadInt["MarkFrameColor"] = { r=rc, g=gc, b=bc, a=ac};
	rewatch_load["MarkFrameColor"] = rewatch_loadInt["MarkFrameColor"]; rewatch_UpdateSwatch();
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then if(val["Mark"]) then rewatch_SetFrameBG(i); end; end; end;
end;

-- update the healthbar color and it's swatch
-- return: void
function rewatch_UpdateHColor()
	local rc, gc, bc = ColorPickerFrame:GetColorRGB();
	rewatch_loadInt["HealthColor"] = { r=rc, g=gc, b=bc };
	rewatch_load["HealthColor"] = rewatch_loadInt["HealthColor"];
	rewatch_UpdateSwatch();
end;

-- update the swatches
-- return: void
function rewatch_UpdateSwatch()
	local children = { rewatch_options:GetChildren() };
	for _, child in ipairs(children) do
		-- if it's the framecolor colorpicker, get this data
		if(child:GetName() == "Rewatch_FrameCP") then
			child:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
		-- if it's the framecolor colorpicker, get this data
		elseif(child:GetName() == "Rewatch_MFrameCP") then
			child:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
		-- if it's the framecolor colorpicker, get this data
		elseif(child:GetName() == "Rewatch_HealthCP") then
			child:SetBackdropColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 0.8);
		-- if it's a barcolor colorpicker, get that data
		elseif(child:GetName() == "Rewatch_BarCP"..rewatch_loc["lifebloom"]) then
			child:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].r, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].g, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].b, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]].a);
		elseif(child:GetName() == "Rewatch_BarCP"..rewatch_loc["lifebloom"].."2") then
			child:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."2"].r, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."2"].g, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."2"].b, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."2"].a);
		elseif(child:GetName() == "Rewatch_BarCP"..rewatch_loc["lifebloom"].."3") then
			child:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."3"].r, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."3"].g, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."3"].b, rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"].."3"].a);
		elseif(child:GetName() == "Rewatch_BarCP"..rewatch_loc["rejuvenation"]) then
			child:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].b, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]].a);
		elseif(child:GetName() == "Rewatch_BarCP"..rewatch_loc["regrowth"]) then
			child:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].b, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].a);
		elseif(child:GetName() == "Rewatch_BarCP"..rewatch_loc["wildgrowth"]) then
			child:SetBackdropColor(rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].b, rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]].a);
		end;
	end;
end;

-- display the color picker
-- thank you WoWWiki.com
function ShowColorPicker(r, g, b, a, changedCallback)
	ColorPickerFrame:Hide();
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc = changedCallback, changedCallback;
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame.hasOpacity = (a ~= nil);
	if(ColorPickerFrame.hasOpacity) then ColorPickerFrame.opacity = (1-a); end;
	ColorPickerFrame:Show();
end;