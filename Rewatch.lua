local rewatch_versioni = 70002;

--------------------------------------------------------------------------------------------------------------[ FUNCTIONS ]----------------------

-- display a message to the user in the chat pane
-- msg: the message to pass onto the user
-- return: void
function rewatch_Message(msg)

	-- send the message to the chat pane
	DEFAULT_CHAT_FRAME:AddMessage(rewatch_loc["prefix"]..msg, 1, 1, 1);
	
end

-- displays a message to the user in the raidwarning frame
-- msg: the message to pass onto the user
-- return: void
function rewatch_RaidMessage(msg)

	-- send the message to the raid warning frame
	RaidNotice_AddMessage(RaidWarningFrame, msg, { r = 1, g = 0.49, b = 0.04 });
	
end

-- loads the internal vars from the savedvariables
-- return: void
function rewatch_OnLoad()

	-- reset changed var (options window)
	rewatch_changedDimentions = false;
	
	-- has been loaded before, get vars
	if(rewatch_load) then
	
		-- support
		local supported, update = { 60000, 60001, 60002, 60003, 60004, 60005, 60006, 60007, 61000, 61001, 70000, 70001, 70002 }, false;
		for _, version in ipairs(supported) do update = update or (version == rewatch_version) end;
		
		-- supported? then update
		if(update) then
		
			if(rewatch_version < 60001) then
				rewatch_Message("The default layout preset has changed! Would you like to try? Type: /rew layout normal");
				rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = { r=0; g=0.7; b=0, a=1};
				rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=0.4; g=0.85; b=0.34, a=1};
			end;
			
			if(rewatch_version < 60002) then
				rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=0.4; g=0.85; b=0.34, a=1};
				rewatch_load["HealthColor"] = { r=0.07; g=0.07; b=0.07};
				rewatch_load["FrameColor"] = { r=0.07; g=0.07; b=0.07, a=1};
			end;
			
			if(rewatch_version < 60003) then
				rewatch_load["OORAlpha"] = 0.2;
			end;
			
			if(rewatch_version < 60005) then
				if(rewatch_load["Layout"] == "vertical") then rewatch_load["FrameColumns"] = 1; else rewatch_load["FrameColumns"] = 0; end;
			end;
			
			if(rewatch_version < 61000) then
				rewatch_load["ButtonSpells11"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
				rewatch_load["ButtonSpells7"] = { rewatch_loc["purifyspirit"], rewatch_loc["healingsurge"], rewatch_loc["healingwave"], rewatch_loc["chainheal"] };
				rewatch_load["BarColor"..rewatch_loc["riptide"]] = { r=0; g=0.1; b=0,8, a=1};
			end;
			
			if(rewatch_version < 70002) then
				rewatch_load["ShowDamageTaken"] = 1;
				rewatch_load["FontSize"] = 10;
				rewatch_load["HighlightSize"] = 10;
				rewatch_load["OORAlpha"] = 0.5;
			end;

			-- thank for using addon <3
			if(rewatch_version < rewatch_versioni) then
				rewatch_Message(rewatch_loc["welcome"]);
			end;
			
			-- get class properties
			rewatch_loadInt["ClassID"] = select(3, UnitClass("player"));
			if(rewatch_loadInt["ClassID"] == 7) then
				rewatch_loadInt["IsShaman"] = true;
				rewatch_loadInt["IsDruid"] = false;
				rewatch_loadInt["SampleSpell"] = rewatch_loc["healingsurge"];
			elseif(rewatch_loadInt["ClassID"] == 11) then
				rewatch_loadInt["IsShaman"] = false;
				rewatch_loadInt["IsDruid"] = true;
				rewatch_loadInt["SampleSpell"] = rewatch_loc["regrowth"];
			end;
			
			-- get spec properties
			rewatch_loadInt["InRestoSpec"] = false;
			if((GetSpecialization() == 4 and rewatch_loadInt["IsDruid"]) or (GetSpecialization() == 3 and rewatch_loadInt["IsShaman"])) then
				rewatch_loadInt["InRestoSpec"] = true;
			end;
			
			-- set internal vars from loaded vars
			rewatch_loadInt["Loaded"] = true;
			rewatch_loadInt["GcdAlpha"] = rewatch_load["GcdAlpha"];
			rewatch_loadInt["HideSolo"] = rewatch_load["HideSolo"];
			rewatch_loadInt["Hide"] = rewatch_load["Hide"];
			rewatch_loadInt["AutoGroup"] = rewatch_load["AutoGroup"];
			rewatch_loadInt["WildGrowth"] = rewatch_load["WildGrowth"];
			rewatch_loadInt["HealthColor"] = rewatch_load["HealthColor"];
			rewatch_loadInt["FrameColor"] = rewatch_load["FrameColor"];
			rewatch_loadInt["MarkFrameColor"] = rewatch_load["MarkFrameColor"];
			rewatch_loadInt["MaxPlayers"] = rewatch_load["MaxPlayers"];
			rewatch_loadInt["Highlighting"] = rewatch_load["Highlighting"];
			rewatch_loadInt["Highlighting2"] = rewatch_load["Highlighting2"];
			rewatch_loadInt["Highlighting3"] = rewatch_load["Highlighting3"];
			rewatch_loadInt["ShowButtons"] = rewatch_load["ShowButtons"];
			rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]] = rewatch_load["BarColor"..rewatch_loc["lifebloom"]];
			rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]] = rewatch_load["BarColor"..rewatch_loc["rejuvenation"]];
			rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]] = rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]];
			rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]] = rewatch_load["BarColor"..rewatch_loc["regrowth"]];
			rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]] = rewatch_load["BarColor"..rewatch_loc["wildgrowth"]];
			rewatch_loadInt["BarColor"..rewatch_loc["riptide"]] = rewatch_load["BarColor"..rewatch_loc["riptide"]];
			rewatch_loadInt["Labels"] = rewatch_load["Labels"];
			rewatch_loadInt["ShowTooltips"] = rewatch_load["ShowTooltips"];
			rewatch_loadInt["NameCharLimit"] = rewatch_load["NameCharLimit"];
			rewatch_loadInt["Bar"] = rewatch_load["Bar"];
			rewatch_loadInt["Font"] = rewatch_load["Font"];
			rewatch_loadInt["FontSize"] = rewatch_load["FontSize"];
			rewatch_loadInt["HighlightSize"] = rewatch_load["HighlightSize"];
			rewatch_loadInt["OORAlpha"] = rewatch_load["OORAlpha"];
			rewatch_loadInt["PBOAlpha"] = rewatch_load["PBOAlpha"];
			rewatch_loadInt["HealthDeficit"] = rewatch_load["HealthDeficit"];
			rewatch_loadInt["DeficitThreshold"] = rewatch_load["DeficitThreshold"];
			rewatch_loadInt["SpellBarWidth"] = rewatch_load["SpellBarWidth"];
			rewatch_loadInt["SpellBarHeight"] = rewatch_load["SpellBarHeight"];
			rewatch_loadInt["HealthBarHeight"] = rewatch_load["HealthBarHeight"];
			rewatch_loadInt["Scaling"] = rewatch_load["Scaling"];
			rewatch_loadInt["NumFramesWide"] = rewatch_load["NumFramesWide"];
			rewatch_loadInt["AltMacro"] = rewatch_load["AltMacro"];
			rewatch_loadInt["CtrlMacro"] = rewatch_load["CtrlMacro"];
			rewatch_loadInt["ShiftMacro"] = rewatch_load["ShiftMacro"];
			rewatch_loadInt["Layout"] = rewatch_load["Layout"];
			rewatch_loadInt["SortByRole"] = rewatch_load["SortByRole"];
			rewatch_loadInt["ShowIncomingHeals"] = rewatch_load["ShowIncomingHeals"];
			rewatch_loadInt["ShowDamageTaken"] = rewatch_load["ShowDamageTaken"];
			rewatch_loadInt["ShowSelfFirst"] = rewatch_load["ShowSelfFirst"];
			rewatch_loadInt["ButtonSpells7"] = rewatch_load["ButtonSpells7"];
			rewatch_loadInt["ButtonSpells11"] = rewatch_load["ButtonSpells11"];
			rewatch_loadInt["FrameColumns"] = rewatch_load["FrameColumns"];
			rewatch_loadInt["LockP"] = true;
			
			-- update later
			rewatch_changed = true;
			
			-- apply possible changes
			rewatch_DoUpdate();
			
			-- set current version
			rewatch_version = rewatch_versioni;
			
		else
		
			-- reset it all when new or no longer supported
			rewatch_load = nil;
			rewatch_version = nil;
			
		end;
	
	else
	
		-- not loaded before, initialize and welcome new user
		rewatch_load = {};
		rewatch_load["GcdAlpha"], rewatch_load["HideSolo"], rewatch_load["Hide"], rewatch_load["AutoGroup"] = 1, 0, 0, 1;
		rewatch_load["HealthColor"] = { r=0.07; g=0.07; b=0.07};
		rewatch_load["FrameColor"] = { r=0; g=0; b=0; a=0.3 };
		rewatch_load["MarkFrameColor"] = { r=0; g=1; b=0; a=1 };
		rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = { r=0; g=0.7; b=0, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation"]] = { r=0.85; g=0.15; b=0.80, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=0.4; g=0.85; b=0.34, a=1};
		rewatch_load["BarColor"..rewatch_loc["regrowth"]] = { r=0.05; g=0.3; b=0.1, a=1};
		rewatch_load["BarColor"..rewatch_loc["wildgrowth"]] = { r=0.5; g=0.8; b=0.3, a=1};
		rewatch_load["BarColor"..rewatch_loc["riptide"]] = { r=0.0; g=0.1; b=0.8, a=1};
		rewatch_load["Labels"] = 0;
		rewatch_load["SpellBarWidth"] = 25; rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110; rewatch_load["Scaling"] = 100;
		rewatch_load["NumFramesWide"] = 1;
		rewatch_load["WildGrowth"] = 1;
		rewatch_load["Bar"] = "Interface\\AddOns\\Rewatch\\Textures\\Bar.tga";
		rewatch_load["Font"] = "Interface\\AddOns\\Rewatch\\Fonts\\BigNoodleTitling.ttf";
		rewatch_load["FontSize"] = 10; rewatch_load["HighlightSize"] = 10;
		rewatch_load["HealthDeficit"] = 0;
		rewatch_load["DeficitThreshold"] = 0;
		rewatch_load["OORAlpha"] = 0.5;
		rewatch_load["PBOAlpha"] = 0.2;
		rewatch_load["NameCharLimit"] = 0; rewatch_load["MaxPlayers"] = 0;
		rewatch_load["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
		rewatch_load["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["innervate"];
		rewatch_load["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
		rewatch_load["Layout"] = "vertical";
		rewatch_load["SortByRole"] = 1;
		rewatch_load["ShowSelfFirst"] = 1;
		rewatch_load["ShowIncomingHeals"] = 1;
		rewatch_load["ShowDamageTaken"] = 1;
		rewatch_load["Highlighting"] = {
			-- todo: defaults
		};
		rewatch_load["Highlighting2"] = {
			-- todo: defaults
		};
		rewatch_load["Highlighting3"] = {
			-- todo: defaults
		};
		rewatch_load["ShowButtons"] = 0;
		rewatch_load["ShowTooltips"] = 1;
		rewatch_load["ButtonSpells11"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
		rewatch_load["ButtonSpells7"] = { rewatch_loc["purifyspirit"], rewatch_loc["healingsurge"], rewatch_loc["healingwave"], rewatch_loc["chainheal"] };
		rewatch_load["FrameColumns"] = 1;
		rewatch_RaidMessage(rewatch_loc["welcome"]);
		rewatch_Message(rewatch_loc["welcome"]);
		rewatch_Message(rewatch_loc["info"]);
		
		-- set current version
		rewatch_version = rewatch_versioni;
	end;
end;

-- apply a preset layout
-- name: name of the preset
-- return: void
function rewatch_SetLayout(name)

	if(name == "normal") then
	
		rewatch_load["ShowButtons"] = 0;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["FrameColumns"] = 1;
		rewatch_load["SpellBarWidth"] = 25;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Layout"] = "vertical";
		
	elseif(name == "compact") then
	
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["FrameColumns"] = 1;
		rewatch_load["SpellBarWidth"] = 50;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Layout"] = "vertical";
		
	elseif(name == "classic") then
	
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["FrameColumns"] = 0;
		rewatch_load["SpellBarWidth"] = 85;
		rewatch_load["SpellBarHeight"] = 10;
		rewatch_load["HealthBarHeight"] = 30;
		rewatch_load["Layout"] = "horizontal";
		
	end;
	
	rewatch_loadInt["ShowButtons"] = rewatch_load["ShowButtons"];
	rewatch_loadInt["NumFramesWide"] = rewatch_load["NumFramesWide"];
	rewatch_loadInt["FrameColumns"] = rewatch_load["FrameColumns"];
	rewatch_loadInt["SpellBarWidth"] = rewatch_load["SpellBarWidth"];
	rewatch_loadInt["SpellBarHeight"] = rewatch_load["SpellBarHeight"];
	rewatch_loadInt["HealthBarHeight"] = rewatch_load["HealthBarHeight"];
	rewatch_loadInt["Layout"] = rewatch_load["Layout"];
	
	rewatch_changed = true;
	rewatch_DoUpdate();
	
end;

-- update frame dimensions by changes in component sizes/margins
-- return: void
function rewatch_UpdateOffset()

	local n = 3 + rewatch_loadInt["WildGrowth"];
	
	if(rewatch_loadInt["IsShaman"]) then n = 1; end;
		
	if(rewatch_loadInt["Layout"] == "horizontal") then
	
		rewatch_loadInt["FrameWidth"] = (rewatch_loadInt["SpellBarWidth"]) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["ButtonSize"] = (rewatch_loadInt["SpellBarWidth"] / table.getn(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]])) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["FrameHeight"] = ((rewatch_loadInt["SpellBarHeight"] * n) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100) + (rewatch_loadInt["ButtonSize"]*rewatch_loadInt["ShowButtons"]);
		
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		
		rewatch_loadInt["FrameWidth"] = ((rewatch_loadInt["SpellBarHeight"] * n) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["ButtonSize"] = (rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100)) / table.getn(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]]);
		rewatch_loadInt["FrameHeight"] = (rewatch_loadInt["SpellBarWidth"]) * (rewatch_loadInt["Scaling"]/100);
		
	end;
	
end;

-- update everything
-- return: void
function rewatch_DoUpdate()

	rewatch_UpdateOffset();
	rewatch_CreateOptions();
	
	rewatch_gcd:SetAlpha(rewatch_loadInt["GcdAlpha"]);
	
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then val["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a); end; end;
	if(((rewatch_i == 2) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
	rewatch_OptionsFromData(true); rewatch_UpdateSwatch();
	
end;

-- pops up the tooltip bar
-- data: the data to put in the tooltip. either a spell name or player name.
-- return: void
function rewatch_SetTooltip(data)

	-- ignore if not wanted
	if(rewatch_loadInt["ShowTooltips"] ~= 1) then return; end;
	
	-- is it a spell?
	local md = rewatch_GetSpellId(data);
	if(md < 0) then
	
		-- if not, then is it a player?
		md = rewatch_GetPlayer(data);
		if(md >= 0) then
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
			GameTooltip:SetUnit(rewatch_bars[md]["Player"]);
		end;
		
		-- do nothing with the tooltip if not
		
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetSpellBookItem(md, BOOKTYPE_SPELL);
	end;
	
end;

-- gets the spell ID of the highest rank of the specified spell
-- spellName: the name of the spell to get the highest ranked spellId from
-- return: the corresponding spellId
function rewatch_GetSpellId(spellName)

	local i = 1;
	while true do
	   local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
	   if (not spell) then break; end;
	   if (spell == spellName) then return i; end;
	   i = i+1;
	end
	
	return -1;
	
end;

-- gets the icon of the specified spell
-- spellName: the name of the spell to get the icon from
-- return: the corresponding icon path
function rewatch_GetSpellIcon(spellName)

	return select(3, GetSpellInfo(spellName));
	
end;

-- get the corresponding colour for the power type
-- powerType: the type of power used (MANA, RAGE, FOCUS, ENERGY, CHI, ...)
-- return: a rgb table representing the 'mana bar' colour
function rewatch_GetPowerBarColor(powerType)

	if(powerType == 0 or powerType == "MANA") then
		return { r = 0.24, g = 0.35, b = 0.49 };
	end;
	
	if(powerType == 1 or powerType == "RAGE") then
		return { r = 0.52, g = 0.17, b = 0.17 };
	end;
	
	if(powerType == 3 or powerType == "ENERGY") then
		return { r = 0.5, g = 0.48, b = 0.27 };
	end;
	
	return PowerBarColor[powerType];
	
end;

-- get the number of the supplied player's place in the player table, or -1
-- player: name of the player to search for
-- return: the supplied player's table index, or -1 if not found
function rewatch_GetPlayer(player)

	-- prevent nil entries
	if(not player) then return -2; end;
	
	-- for every seen player; return if the name matches the supplied name
	local guid = UnitGUID(player);
	
	-- ignore pet guid; this changes sometimes
	if(not UnitIsPlayer(player)) then guid = false; end;
	
	-- browse list and return corresponding id
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then
		if(not guid) then
			if(val["Player"] == player) then return i; end;
		elseif(val["UnitGUID"] == guid) then return i;
		-- recognise pets (Playername-pet != Petname)
		elseif(val["Pet"]) then if(UnitGUID(val["Player"]) == UnitGUID(player)) then return i; end;
		-- load bug, UnitGUID returns nil when not fully loaded, even on "player"
		elseif((player == UnitName("player")) and (not val["UnitGUID"])) then val["UnitGUID"] = guid; return i; end;
	end; end;
	
	-- return -1 if not found
	return -1;
	
end;

-- checks if the player or pet is in the group
-- player: name of the player or pet to check for
-- return: true, if the player is the user, or in the user's party or raid (or pet); false elsewise
function rewatch_InGroup(player)

	-- catch a self-check; return true if searching for the user itself
	if(UnitName("player") == player) then return true;
	else
		if((GetNumGroupMembers() > 0) and IsInRaid()) then
			if(UnitPlayerOrPetInRaid(player)) then
				return true;
			end;
		elseif(GetNumSubgroupMembers() > 0) then
			if(UnitPlayerOrPetInParty(player)) then
				return true;
			end;
		end;
	end;
	
	-- return
	return false;
	
end;

-- colors the frame corresponding to the player with playerid accordingly
-- playerId: the index number of the player in the player table
-- return: void
function rewatch_SetFrameBG(playerId)

	-- high prio warning?
	if(rewatch_bars[playerId]["Notify3"]) then
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(1.0, 0.0, 0.0, 1);
		
	-- default warning?
	elseif(rewatch_bars[playerId]["Debuff"]) then
	
		rewatch_bars[playerId]["DebuffTexture"]:SetTexture(rewatch_bars[playerId]["DebuffIcon"]);
		rewatch_bars[playerId]["DebuffTexture"]:Show();
	
		if(rewatch_bars[playerId]["DebuffType"] == "Poison") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.0, 0.3, 0, 1);
		elseif(rewatch_bars[playerId]["DebuffType"] == "Curse") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.5, 0.0, 0.5, 1);
		elseif(rewatch_bars[playerId]["DebuffType"] == "Magic") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.0, 0.0, 0.5, 1);
		elseif(rewatch_bars[playerId]["DebuffType"] == "Disease") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.5, 0.5, 0.0, 1);
		end;
		
	-- medium prio warning?
	elseif(rewatch_bars[playerId]["Notify2"]) then
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(1.0, 0.5, 0.1, 1);
		
	-- low prio warning?
	elseif(rewatch_bars[playerId]["Notify"]) then
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.9, 0.8, 0.2, 1);
		
	-- manually marked?
	elseif(rewatch_bars[playerId]["Mark"]) then
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
		
	-- default
	else
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
		
	end;
	
end;

-- trigger the cooldown overlays
-- return: void
function rewatch_TriggerCooldown()

	-- get global cooldown, and trigger it on all frames
	local start, duration, enabled = GetSpellCooldown(rewatch_loadInt["SampleSpell"]);
	CooldownFrame_Set(rewatch_gcd, start, duration, enabled);

end;

-- show the first rewatch frame, with the last 'flash' of the cooldown effect
-- return: void
function rewatch_ShowFrame()

	rewatch_f:Show();
	CooldownFrame_Set(rewatch_gcd, GetTime()-1, 1.25, 1);
	
end;

-- adjusts the parent frame container's height
-- return: void
function rewatch_AlterFrame()

	-- get current x and y
	local x, y = rewatch_f:GetLeft(), rewatch_f:GetTop();
	
	-- set height and width according to number of frames
	local num, height, width = rewatch_f:GetNumChildren()-1;
	if(rewatch_loadInt["FrameColumns"] == 1) then
		height = math.min(rewatch_loadInt["NumFramesWide"],  math.max(num, 1)) * rewatch_loadInt["FrameHeight"];
		width = math.ceil(num/rewatch_loadInt["NumFramesWide"]) * rewatch_loadInt["FrameWidth"];
	else
		height = math.ceil(num/rewatch_loadInt["NumFramesWide"]) * rewatch_loadInt["FrameHeight"];
		width = math.min(rewatch_loadInt["NumFramesWide"],  math.max(num, 1)) * rewatch_loadInt["FrameWidth"];
	end;
	
	-- apply
	rewatch_f:SetWidth(width+1);
	rewatch_f:SetHeight(height+20);
	
	rewatch_gcd:SetWidth(rewatch_f:GetWidth());
	rewatch_gcd:SetHeight(rewatch_f:GetHeight());
	
	-- reposition to x and y
	if(x ~= nil and y ~= nil) then
		rewatch_f:ClearAllPoints();
		rewatch_f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y-UIParent:GetHeight());
	end;
	
	-- hide/show on solo
	if(((num == 1) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_f:Show(); end;
	
	-- make sure frames have a solid height and width (bugfix)
	for j=1,rewatch_i-1 do local val = rewatch_bars[j]; if(val) then
		if(not((val["Frame"]:GetWidth() == rewatch_loadInt["FrameWidth"]) and (val["Frame"]:GetHeight() == rewatch_loadInt["FrameHeight"]))) then
			val["Frame"]:SetWidth(rewatch_loadInt["FrameWidth"]); val["Frame"]:SetHeight(rewatch_loadInt["FrameHeight"]);
		end;
	end; end;
	
end;

-- snap the supplied frame to the grid when it's placed on a rewatch_f frame
-- frame: the frame to snap to a grid
-- return: void
function rewatch_SnapToGrid(frame)

	-- return if in combat
	if(rewatch_inCombat) then return -1; end;
	
	-- get parent frame
	local parent = frame:GetParent();
	if(parent ~= UIParent) then
	
		-- get frame's location relative to it's parent's
		local dx, dy = frame:GetLeft()-parent:GetLeft(), frame:GetTop()-parent:GetTop();
		
		-- make it snap (make dx a number closest to frame:GetWidth*n...)
		dx = math.floor((dx/rewatch_loadInt["FrameWidth"])+0.5) * rewatch_loadInt["FrameWidth"];
		dy = math.floor((dy/rewatch_loadInt["FrameHeight"])+0.5) * rewatch_loadInt["FrameHeight"];
		
		-- check if this is outside the frame, remove it
		if((dx < 0) or (dy > 0) or (dx+5 >= parent:GetWidth()) or ((dy*-1)+5 >= parent:GetHeight())) then
			-- remove it from it's parent
			frame:SetParent(UIParent); rewatch_AlterFrame();
			rewatch_Message(rewatch_loc["offFrame"]);
		-- if it's in the frame, move it
		else
			-- set id and get children
			frame:SetID(1337); local children = { parent:GetChildren() };
			-- move a frame to a new position if this frame covers it now
			for i, child in ipairs(children) do if(child:GetID() ~= 1337) then
				if((child:GetLeft() and (i>1))) then
					if((math.abs(dx - (child:GetLeft()-parent:GetLeft())) < 1) and (math.abs(dy - (child:GetTop()-parent:GetTop())) < 1)) then
						local x, y = rewatch_GetFramePos(parent); child:ClearAllPoints(); child:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
						child:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", x+rewatch_loadInt["FrameWidth"], y-rewatch_loadInt["FrameHeight"]); break;
					end;
				end;
			end; end;
			-- reset id and apply the snap location
			frame:SetID(0); frame:ClearAllPoints(); frame:SetPoint("TOPLEFT", parent, "TOPLEFT", dx, dy);
			frame:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", dx+rewatch_loadInt["FrameWidth"], dy-rewatch_loadInt["FrameHeight"]);
		end;
	else
		-- check if there's need to snap it back onto the frame
		local dx, dy = frame:GetLeft()-rewatch_f:GetLeft(), frame:GetTop()-rewatch_f:GetTop();
		if((dx > 0) and (dy < 0) and (dx < rewatch_f:GetWidth()) and (dy < rewatch_f:GetHeight())) then
			frame:SetParent(rewatch_f); rewatch_AlterFrame();
			rewatch_SnapToGrid(frame); rewatch_Message(rewatch_loc["backOnFrame"]);
		end;
	end;
	
end;

-- return the first available empty spot in the frame
-- frame: the outline (parent) frame in which the player frame should be positioned
-- return: position coordinates; { x, y }
function rewatch_GetFramePos(frame)
	
	local children = { frame:GetChildren() };
	local x, y, found = 0, 0, false;
	local mx, my;
	
	if(rewatch_loadInt["FrameColumns"] == 1) then
		mx = ceil(frame:GetNumChildren()/rewatch_loadInt["NumFramesWide"])-1;
		my = 1-rewatch_loadInt["NumFramesWide"];
	else
		mx = rewatch_loadInt["NumFramesWide"]-1;
		my = 1-ceil(frame:GetNumChildren()/rewatch_loadInt["NumFramesWide"]);
	end;
	
	-- walk through the available spots, left to right, top to bottom
	if (rewatch_loadInt["FrameWidth"] ~= nil and rewatch_loadInt["FrameHeight"] ~= nil) then
  	for dy=0, my, -1 do
  		for dx=0, mx, 1 do
  			found, x, y = false, rewatch_loadInt["FrameWidth"]*dx, rewatch_loadInt["FrameHeight"]*dy;
  			-- check if there's a frame here already
  			for i, child in ipairs(children) do
  				if((child:GetLeft() and (i>1))) then
  					if((math.abs(x - (child:GetLeft()-frame:GetLeft())) < 1) and (math.abs(y - (child:GetTop()-frame:GetTop())) < 1)) then
  						found = true; break; --[[ break for children loop ]] end;
  				end;
  			end;
  			-- if not, we found a spot and we should break!
  			if(not found) then break; --[[ break for dxloop ]] end;
  		end;
  		if(not found) then break; --[[ break for dy loop ]] end;
	end;
	end;
	
	-- return either the found spot, or a formula based on array positioning (fallback)
	if(found) then
		if(rewatch_loadInt["FrameColumns"] == 1) then return frame:GetWidth()*math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]), ((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]) * frame:GetHeight() * -1;
		else return frame:GetWidth()*((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]), math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]) * frame:GetHeight() * -1; end;
	else return x, y; end;
	
end;

-- compares the current player table to the party/raid schedule
-- return: void
function rewatch_ProcessGroup()

	local name, i, n;
	local names = {};
	
	-- remove non-grouped players
	for i=1,rewatch_i-1 do if(rewatch_bars[i]) then
		if(not (rewatch_InGroup(rewatch_bars[i]["Player"]) or rewatch_bars[i]["Pet"])) then rewatch_HidePlayer(i); end;
	end; end;
	-- add self
	if((rewatch_i == 1) and (rewatch_loadInt["ShowSelfFirst"] == 1)) then
		rewatch_AddPlayer(UnitName("player"), nil);
	end;
	-- process raid group
	if(IsInRaid()) then
		n = GetNumGroupMembers();
		-- for each group member, if he's not in the list, add him
		for i=1, n do
			name = GetRaidRosterInfo(i);
			if((name) and (rewatch_GetPlayer(name) == -1)) then
				table.insert(names, name);
			end;
		end;
	-- process party group (only when not in a raid)
	else
		n = GetNumSubgroupMembers();
		-- for each group member, if he's not in the list, add him
		for i=1, n + 1 do
			if(i > n) then name = UnitName("player"); else name = UnitName("party"..i); end;
			if((name) and (rewatch_GetPlayer(name) == -1)) then
				table.insert(names, name);
			end;
		end;
	end;
	-- sort by role
	if(rewatch_loadInt["SortByRole"] == 1) then
		local healers, tanks, others = {}, {}, {};
		for i, name in pairs(names) do
			role = UnitGroupRolesAssigned(name);
			if(role == "TANK") then
				table.insert(tanks, name);
			elseif(role == "HEALER") then
				table.insert(healers, name);
			else table.insert(others, name); end;
		end;
		-- add players
		rewatch_AddPlayers(tanks);
		rewatch_AddPlayers(healers);
		rewatch_AddPlayers(others);
	-- or just by groups
	else
		rewatch_AddPlayers(names);
	end;
	
end;

-- shortcut to allow adding a list of players at once
-- for further reference, see rewatch_AddPlayer()
function rewatch_AddPlayers(names)

	for i, name in ipairs(names) do
		rewatch_AddPlayer(name, nil);
	end;
	
end;

-- create a spell button with icon and add it to the global player table
-- spellName: the name of the spell to create a bar for
-- playerId: the index number of the player in the player table
-- relative: the name of the rewatch_bars[n] key, referencing to the relative cast bar for layout
-- offset: the (1-index) position of this button
-- return: the created spell button reference
function rewatch_CreateButton(spellName, playerId, relative, offset)

	-- build button
	local button = CreateFrame("BUTTON", nil, rewatch_bars[playerId]["Frame"], "SecureActionButtonTemplate");
	button:SetWidth(rewatch_loadInt["ButtonSize"]); button:SetHeight(rewatch_loadInt["ButtonSize"]);
	button:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", rewatch_loadInt["ButtonSize"]*(offset-1), 0);
	
	-- arrange clicking
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	button:SetAttribute("unit", rewatch_bars[playerId]["Player"]); button:SetAttribute("type1", "spell"); button:SetAttribute("spell1", spellName);
	
	-- texture
	button:SetNormalTexture(rewatch_GetSpellIcon(spellName));
	button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9);
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp");
	
	-- transparency for highlighting icons
	if(spellName == rewatch_loc["removecorruption"]) then button:SetAlpha(0.2);
	elseif(spellName == rewatch_loc["naturescure"]) then button:SetAlpha(0.2);
	elseif(spellName == rewatch_loc["purifyspirit"]) then button:SetAlpha(0.2);
	end;
	
	-- apply tooltip support
	button:SetScript("OnEnter", function() rewatch_SetTooltip(spellName); end);
	button:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	
	-- relate spell to button
	button.spellName = spellName;
	
	-- add cooldown overlay
	button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate");
	button.cooldown:SetPoint("CENTER", 0, -1);
	button.cooldown:SetWidth(button:GetWidth()); button.cooldown:SetHeight(button:GetHeight()); button.cooldown:Hide();
			
	-- return
	return button;
end;

-- create a spell bar with text and add it to the global player table
-- spellName: the name of the spell to create a bar for
-- playerId: the index number of the player in the player table
-- relative: the name of the rewatch_bars[n] key, referencing to the relative castbar for layout
-- return: the created bar reference, it's border reference, and a possible sidebar reference
function rewatch_CreateBar(spellName, playerId, relative)

	local bar, border, sidebar;
	
	-- create the bar
	bar = CreateFrame("STATUSBAR", spellName..playerId, rewatch_bars[playerId]["Frame"], "TextStatusBar");
	bar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	bar:GetStatusBarTexture():SetHorizTile(false);
	bar:GetStatusBarTexture():SetVertTile(false);
	
	-- arrange layout
	if(rewatch_loadInt["Layout"] == "horizontal") then
		bar:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		bar:SetHeight(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		bar:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", 0, 0);
		bar:SetOrientation("horizontal");
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		bar:SetHeight(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		bar:SetWidth(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		bar:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "TOPRIGHT", 0, 0);
		bar:SetOrientation("vertical");
	end;
	
	-- create bar border
	border = CreateFrame("FRAME", nil, bar, BackdropTemplateMixin and "BackdropTemplate");
	border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	border:SetBackdropBorderColor(1, 1, 1, 0);
	border:SetWidth(bar:GetWidth()+1);
	border:SetHeight(bar:GetHeight()+1);
	border:SetPoint("TOPLEFT", bar, "TOPLEFT", -0, 0);
	
	-- bar color
	bar:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
	
	-- set bar reach
	bar:SetMinMaxValues(0, 10); bar:SetValue(10);
	
	-- if this was reju, add a tiny germination sidebar to it
	if(spellName == rewatch_loc["rejuvenation"]) then
	
		-- create the tiny bar
		sidebar = CreateFrame("STATUSBAR", spellName.." (germination)"..playerId, bar, "TextStatusBar");
		sidebar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
		sidebar:GetStatusBarTexture():SetHorizTile(false);
		sidebar:GetStatusBarTexture():SetVertTile(false);
		
		-- adjust to layout
		if(rewatch_loadInt["Layout"] == "horizontal") then
			sidebar:SetWidth(bar:GetWidth());
			sidebar:SetHeight(bar:GetHeight() * 0.33);
			sidebar:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, bar:GetHeight() * 0.33);
			sidebar:SetOrientation("horizontal");
		elseif(rewatch_loadInt["Layout"] == "vertical") then
			sidebar:SetWidth(bar:GetWidth() * 0.33);
			sidebar:SetHeight(bar:GetHeight());
			sidebar:SetPoint("TOPLEFT", bar, "TOPRIGHT", -(bar:GetWidth() * 0.33), 0);
			sidebar:SetOrientation("vertical");
		end;
		
		-- bar color
		sidebar:SetStatusBarColor(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]].b, rewatch_loadInt["PBOAlpha"]);
		
		-- bar reach
		sidebar:SetMinMaxValues(0, 10); sidebar:SetValue(0);
		
		-- put text in bar
		sidebar.text = bar:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
		sidebar.text:SetPoint("RIGHT", sidebar); sidebar.text:SetAllPoints();
		sidebar.text:SetText("");

	end;
	
	-- overlay cast button
	local bc = CreateFrame("BUTTON", nil, bar, "SecureActionButtonTemplate");
	bc:SetWidth(bar:GetWidth());
	bc:SetHeight(bar:GetHeight());
	bc:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0);
	bc:RegisterForClicks("LeftButtonDown", "RightButtonDown"); bc:SetAttribute("type1", "spell"); bc:SetAttribute("unit", rewatch_bars[playerId]["Player"]);
	bc:SetAttribute("spell1", spellName); bc:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp");
	
	-- put text in bar
	bar.text = bc:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	bar.text:SetPoint("RIGHT", bc); bar.text:SetAllPoints(); bar.text:SetAlpha(1);
	if(rewatch_loadInt["Labels"] == 1) then bar.text:SetText(spellName); else bar.text:SetText(""); end;
	
	-- apply tooltip support
	bc:SetScript("OnEnter", function() bc:SetAlpha(0.2); rewatch_SetTooltip(spellName); end);
	bc:SetScript("OnLeave", function() bc:SetAlpha(1); GameTooltip:Hide(); end);
	
	return bar, border, sidebar;
	
end;

-- update a bar by resetting spell duration
-- spellName: the name of the spell to reset it's duration from
-- player: player name
-- return: void
function rewatch_UpdateBar(spellName, player)
	
	-- this shouldn't happen, but just in case
	if(not spellName) then return; end;
	
	-- get player
	local playerId = rewatch_GetPlayer(player);
	
	-- add if needed
    if(playerId < 0) then
        if((rewatch_loadInt["AutoGroup"] == 0) or (spellName == rewatch_loc["wildgrowth"])) then return; end;
        playerId = rewatch_AddPlayer(UnitName(player), nil);
		if(playerId < 0) then return; end;
    end;
	
	-- lag may cause this 'inconsistency', fixie here
	if(spellName == rewatch_loc["wildgrowth"] or spellName == rewatch_loc["riptide"]) then rewatch_bars[playerId]["Reverting"..spellName] = 0; end;

	-- if the spell exists
	if(rewatch_bars[playerId][spellName]) then
		
		-- get buff duration
		local a = rewatch_GetBuffDuration(player, spellName)
		if(a == nil) then return; end;
		local b = a - GetTime();
		
		-- update bar
		rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["BarColor"..spellName].a);
		
		-- set bar values
		rewatch_bars[playerId][spellName] = a;
		rewatch_bars[playerId][spellName.."Bar"]:SetMinMaxValues(0, b);
		rewatch_bars[playerId][spellName.."Bar"]:SetValue(b);
	end;
end;

-- get duration of buff 
function rewatch_GetBuffDuration(player, spellName)

	for i=1,40 do
		local name, _, _, _, _, duration = UnitBuff(player, i, "PLAYER");
		if (spellName == nil) then return nil; end;
		if (spellName == name) then return duration; end;
	end;

	return nil;
	
end;

-- check if debuff is decursible
-- player: the name of the player
-- returns: type and icon of debuff, or nil if none
function rewatch_GetCleansableDebuffType(player)

	for i=1,40 do
		local name, icon, _, debuffType = UnitDebuff(player, i, 1);
		if(name == nil) then return nil; end;
		if((debuffType == "Curse") or (debuffType == "Poison" and rewatch_loadInt["IsDruid"]) or (debuffType == "Magic" and rewatch_loadInt["InRestoSpec"])) then return debuffType, icon; end;
	end;
	
	return nil;
	
end;

-- clear a bar back to 0 because it's been dispelled or removed
-- spellName: the name of the spell to reset it's duration from
-- playerId: the index number of the player in the player table
-- return: void
function rewatch_DowndateBar(spellName, playerId)

	-- if the spell exists for this player
	if(rewatch_bars[playerId][spellName] and rewatch_bars[playerId][spellName.."Bar"]) then
	
		-- ignore if it's WG and we have no WG bar
		if((spellName == rewatch_loc["wildgrowth"]) and (not rewatch_bars[playerId][spellName.."Bar"])) then return; end;
		
		-- reset bar values
		_, r = rewatch_bars[playerId][spellName.."Bar"]:GetMinMaxValues();
		rewatch_bars[playerId][spellName.."Bar"]:SetValue(r);
		rewatch_bars[playerId][spellName] = 0;
		if(rewatch_loadInt["Labels"] == 0) then rewatch_bars[playerId][spellName.."Bar"].text:SetText(""); end;
		
		-- hide germination bar by default
		if(spellName == rewatch_loc["rejuvenation (germination)"]) then
			rewatch_bars[playerId][spellName.."Bar"]:SetValue(0);
		end;
		
		-- check for wild growth overrides
		if((spellName == rewatch_loc["wildgrowth"] and GetSpellCooldown(rewatch_loc["wildgrowth"])) or (spellName == rewatch_loc["riptide"] and GetSpellCooldown(rewatch_loc["riptide"]))) then
		
			if(rewatch_bars[playerId]["Reverting"..spellName] == 1) then
				rewatch_bars[playerId]["Reverting"..spellName] = 0;
				rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
			else
				rewatch_bars[playerId]["Reverting"..spellName] = 1;
				rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(0, 0, 0, 0.8);
				r, b = GetSpellCooldown(spellName)
				r = r + b; b = r - GetTime();
				rewatch_bars[playerId][spellName] = r;
				rewatch_bars[playerId][spellName.."Bar"]:SetMinMaxValues(0, b);
				rewatch_bars[playerId][spellName.."Bar"]:SetValue(b);
			end;
			
		-- default
		else
			rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
		end;
	end;
	
end;

-- add a player to the players table and create his bars and button
-- player: the name of the player
-- pet: if it's the pet of the named player ("pet" if so, nil if not)
-- return: the index number the player has been assigned
function rewatch_AddPlayer(player, pet)

	-- return if in combat or if the max amount of players is passed
	if(rewatch_inCombat or ((rewatch_loadInt["MaxPlayers"] > 0) and (rewatch_loadInt["MaxPlayers"] < rewatch_f:GetNumChildren()))) then return -1; end;
	
	-- process pets
	if(pet) then
		player = player.."-pet";
		pet = UnitName(player);
		
		if(pet) then player = pet; end;
		pet = true;
	else 
		pet = false; 
	end;
	
	-- prepare table
	rewatch_bars[rewatch_i] = {};
	
	-- build frame
	local x, y = rewatch_GetFramePos(rewatch_f);
	local frame = CreateFrame("Frame", nil, rewatch_f, BackdropTemplateMixin and "BackdropTemplate");
	frame:SetWidth(rewatch_loadInt["FrameWidth"]);
	frame:SetHeight(rewatch_loadInt["FrameHeight"]);
	frame:SetPoint("TOPLEFT", rewatch_f, "TOPLEFT", x, y);
	frame:EnableMouse(true);
	frame:SetMovable(true);
	frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	frame:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
	frame:SetScript("OnMouseDown", function() if(not rewatch_loadInt["LockP"]) then frame:StartMoving(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end; end);
	frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); rewatch_SnapToGrid(frame); end);
	
	-- create player HP bar for estimated incoming health
	local statusbarinc = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	if(rewatch_loadInt["Layout"] == "horizontal") then
		statusbarinc:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		statusbarinc:SetHeight((rewatch_loadInt["HealthBarHeight"]*0.8) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		statusbarinc:SetHeight(((rewatch_loadInt["SpellBarWidth"]*0.8) * (rewatch_loadInt["Scaling"]/100)) -(rewatch_loadInt["ShowButtons"]*rewatch_loadInt["ButtonSize"]));
		statusbarinc:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
	end;
	statusbarinc:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	statusbarinc:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbarinc:GetStatusBarTexture():SetHorizTile(false);
	statusbarinc:GetStatusBarTexture():SetVertTile(false);
	statusbarinc:SetStatusBarColor(0.4, 1, 0.4, 1);
	statusbarinc:SetMinMaxValues(0, 1);
	statusbarinc:SetValue(0);
		
	-- create player HP bar
	local statusbar = CreateFrame("STATUSBAR", nil, statusbarinc, "TextStatusBar");
	statusbar:SetWidth(statusbarinc:GetWidth());
	statusbar:SetHeight(statusbarinc:GetHeight());
	statusbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	statusbar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbar:GetStatusBarTexture():SetHorizTile(false);
	statusbar:GetStatusBarTexture():SetVertTile(false);
	statusbar:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 1);
	statusbar:SetMinMaxValues(0, 1);
	statusbar:SetValue(0);
	
	-- determine class
	local classID, class, classColors;
	if(UnitName("player") == player) then classID = rewatch_loadInt["ClassID"]; else classID = select(3, UnitClass(player)); end;
	if(classID ~= nil) then
		_, class = GetClassInfo(classID);
		classColors = RAID_CLASS_COLORS[class];
	else
		classColors = {r=0,g=0,b=0}
	end;
	
	-- determine display name
	local name, pos = player, player:find("-");
	
	if(pos ~= nil) then name = name:sub(1, s-1).."*"; end;
	if((rewatch_loadInt["NameCharLimit"] ~= 0) and (name:len() >= rewatch_loadInt["NameCharLimit"])) then name = name:sub(1, rewatch_loadInt["NameCharLimit"] + 1); end;

	-- put text in HP bar
	statusbar.text = statusbar:CreateFontString("$parentText", "ARTWORK");
	statusbar.text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"] * (rewatch_loadInt["Scaling"]/100), "OUTLINE");
	statusbar.text:SetAllPoints();
	statusbar.text:SetText(name);
	statusbar.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1);
	
	-- role icon
	local roleIcon = statusbar:CreateTexture(nil, "OVERLAY");
	local role = UnitGroupRolesAssigned(player);
	roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES");
	roleIcon:SetSize(16, 16);
	roleIcon:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 10, 8-statusbar:GetHeight()/2);
	
	if(role == "TANK") then
		roleIcon:SetTexCoord(0, 19/64, 22/64, 41/64);
		roleIcon:Show();
	elseif(role == "HEALER") then
		roleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		roleIcon:Show();
	else
		roleIcon:Hide();
	end;
	
	-- debuff icon
	local debuffIcon = CreateFrame("Frame", nil, statusbar, BackdropTemplateMixin and "BackdropTemplate");
	debuffIcon:SetWidth(16);
	debuffIcon:SetHeight(16);
	debuffIcon:SetPoint("TOPRIGHT", statusbar, "TOPRIGHT", -10, 8-statusbar:GetHeight()/2);
	debuffIcon:SetAlpha(0.5);
	
	local debuffTexture = debuffIcon:CreateTexture(nil, "ARTWORK")
	debuffTexture:SetAllPoints();
	
	-- create mana bar
	local manabar = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	manabar:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, 0);
	manabar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	manabar:GetStatusBarTexture():SetHorizTile(false);
	manabar:GetStatusBarTexture():SetVertTile(false);
	manabar:SetMinMaxValues(0, 1);
	manabar:SetValue(0);
	
	-- size mana bar
	if(rewatch_loadInt["Layout"] == "horizontal") then
		manabar:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		manabar:SetHeight((rewatch_loadInt["HealthBarHeight"]*0.2) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		manabar:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		manabar:SetHeight((rewatch_loadInt["SpellBarWidth"]*0.2) * (rewatch_loadInt["Scaling"]/100));
	end;
	
	-- color mana bar
	local pt = rewatch_GetPowerBarColor(UnitPowerType(player));
	manabar:SetStatusBarColor(pt.r, pt.g, pt.b);
	
	-- create damage bar
	local damagebar = CreateFrame("STATUSBAR", nil, manabar, "TextStatusBar");
	damagebar:SetPoint("TOPLEFT", manabar, "TOPLEFT", 0, 0);
	damagebar:SetHeight(manabar:GetHeight() / 2);
	damagebar:SetWidth(manabar:GetWidth());
	damagebar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	damagebar:GetStatusBarTexture():SetHorizTile(false);
	damagebar:GetStatusBarTexture():SetVertTile(false);
	damagebar:SetMinMaxValues(0, 1);
	damagebar:SetValue(0);
	damagebar:SetStatusBarColor(1, 0, 0);
	
	-- overlay target/remove button
	local tgb = CreateFrame("BUTTON", nil, statusbar, "SecureActionButtonTemplate");
	tgb:SetWidth(statusbar:GetWidth()); tgb:SetHeight(statusbar:GetHeight()); tgb:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 0, 0);
	tgb:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp"); tgb:SetAlpha(0.2);
	
	-- add mouse interaction
	tgb:SetAttribute("type1", "target");
	tgb:SetAttribute("unit", player);
	tgb:SetAttribute("alt-type1", "macro");
	tgb:SetAttribute("alt-macrotext1", rewatch_loadInt["AltMacro"]);
	tgb:SetAttribute("ctrl-type1", "macro");
	tgb:SetAttribute("ctrl-macrotext1", rewatch_loadInt["CtrlMacro"]);
	tgb:SetAttribute("shift-type1", "macro");
	tgb:SetAttribute("shift-macrotext1", rewatch_loadInt["ShiftMacro"]);
	tgb:SetScript("OnMouseDown", function(_, button)
		if(button == "RightButton") then
			rewatch_dropDown.relativeTo = frame; rewatch_rightClickMenuTable[1] = player;
			ToggleDropDownMenu(1, nil, rewatch_dropDown, "rewatch_dropDown", -10, -10);
		elseif(not rewatch_loadInt["LockP"]) then frame:StartMoving(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end;
	end);
	tgb:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); rewatch_SnapToGrid(frame); end);
	tgb:SetScript("OnEnter", function() rewatch_SetTooltip(player); rewatch_bars[rewatch_GetPlayer(player)]["Hover"] = 1; end);
	tgb:SetScript("OnLeave", function() GameTooltip:Hide(); rewatch_bars[rewatch_GetPlayer(player)]["Hover"] = 2; end);
	
	-- build border frame
	local border = CreateFrame("FRAME", nil, statusbar, BackdropTemplateMixin and "BackdropTemplate");
	border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	border:SetBackdropBorderColor(0, 0, 0, 1);
	border:SetWidth(rewatch_loadInt["FrameWidth"]+1);
	border:SetHeight(rewatch_loadInt["FrameHeight"]+1);
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -0, 0);
	
	-- save player data
	rewatch_bars[rewatch_i]["UnitGUID"] = nil; if(UnitExists(player)) then rewatch_bars[rewatch_i]["UnitGUID"] = UnitGUID(player); end;
	rewatch_bars[rewatch_i]["Frame"] = frame;
	rewatch_bars[rewatch_i]["Init"] = GetTime();
	rewatch_bars[rewatch_i]["Player"] = player;
	rewatch_bars[rewatch_i]["DisplayName"] = name;
	rewatch_bars[rewatch_i]["PlayerBarInc"] = statusbarinc;
	rewatch_bars[rewatch_i]["Border"] = border;
	rewatch_bars[rewatch_i]["PlayerBar"] = statusbar;
	rewatch_bars[rewatch_i]["ManaBar"] = manabar;
	rewatch_bars[rewatch_i]["DamageBar"] = damagebar;
	rewatch_bars[rewatch_i]["Mark"] = false;
	rewatch_bars[rewatch_i]["Pet"] = pet;
	rewatch_bars[rewatch_i][rewatch_loc["lifebloom"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation (germination)"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["regrowth"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["wildgrowth"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["riptide"]] = 0;
	rewatch_bars[rewatch_i]["Notify"] = nil;
	rewatch_bars[rewatch_i]["Notify2"] = nil;
	rewatch_bars[rewatch_i]["Notify3"] = nil;
	rewatch_bars[rewatch_i]["Debuff"] = nil;
	rewatch_bars[rewatch_i]["DebuffTexture"] = debuffTexture;
	rewatch_bars[rewatch_i]["Class"] = class;
	rewatch_bars[rewatch_i]["Hover"] = 0;
	rewatch_bars[rewatch_i]["Reverting"..rewatch_loc["wildgrowth"]] = 0;
	rewatch_bars[rewatch_i]["Reverting"..rewatch_loc["riptide"]] = 0;
	rewatch_bars[rewatch_i]["Buttons"] = {};
	
	-- bars for druid
	if(rewatch_loadInt["IsDruid"]) then 
		if(rewatch_loadInt["Layout"] == "horizontal") then
			rewatch_bars[rewatch_i][rewatch_loc["lifebloom"].."Bar"], _ = rewatch_CreateBar(rewatch_loc["lifebloom"], rewatch_i, "ManaBar");
		elseif(rewatch_loadInt["Layout"] == "vertical") then
			rewatch_bars[rewatch_i][rewatch_loc["lifebloom"].."Bar"], _ = rewatch_CreateBar(rewatch_loc["lifebloom"], rewatch_i, "PlayerBar");
		end;
		rewatch_bars[rewatch_i][rewatch_loc["rejuvenation"].."Bar"], _, rewatch_bars[rewatch_i][rewatch_loc["rejuvenation (germination)"].."Bar"] = rewatch_CreateBar(rewatch_loc["rejuvenation"], rewatch_i, rewatch_loc["lifebloom"].."Bar");
		rewatch_bars[rewatch_i][rewatch_loc["regrowth"].."Bar"], rewatch_bars[rewatch_i][rewatch_loc["regrowth"].."Border"], _ = rewatch_CreateBar(rewatch_loc["regrowth"], rewatch_i, rewatch_loc["rejuvenation"].."Bar");
		pt = rewatch_loc["regrowth"].."Bar";
		if(rewatch_loadInt["WildGrowth"] == 1) then
			pt = rewatch_loc["wildgrowth"].."Bar";
			rewatch_bars[rewatch_i][rewatch_loc["wildgrowth"].."Bar"], _ = rewatch_CreateBar(rewatch_loc["wildgrowth"], rewatch_i, rewatch_loc["regrowth"].."Bar");
		end;
	
	-- bars for shaman
	elseif(rewatch_loadInt["IsShaman"]) then 
		if(rewatch_loadInt["Layout"] == "horizontal") then
			rewatch_bars[rewatch_i][rewatch_loc["riptide"].."Bar"], _ = rewatch_CreateBar(rewatch_loc["riptide"], rewatch_i, "ManaBar");
		elseif(rewatch_loadInt["Layout"] == "vertical") then
			rewatch_bars[rewatch_i][rewatch_loc["riptide"].."Bar"], _ = rewatch_CreateBar(rewatch_loc["riptide"], rewatch_i, "PlayerBar");
		end;
		pt = rewatch_loc["riptide"].."Bar";
	end;

	-- buttons
	if(rewatch_loadInt["ShowButtons"] == 1) then
		-- determine anchor
		if(rewatch_loadInt["Layout"] == "vertical") then pt = "ManaBar"; end;
		-- create buttons
		for buttonSpellId,buttonSpellName in pairs(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]]) do
			if(not rewatch_loadInt["InRestoSpec"]) then
				if(buttonSpellName == rewatch_loc["naturescure"]) then buttonSpellName = rewatch_loc["removecorruption"];
				elseif(buttonSpellName == rewatch_loc["ironbark"]) then buttonSpellName = rewatch_loc["barkskin"];
				end;
			end;
			if(rewatch_GetSpellIcon(buttonSpellName)) then
				rewatch_bars[rewatch_i]["Buttons"][buttonSpellName] = rewatch_CreateButton(buttonSpellName, rewatch_i, pt, buttonSpellId);
			end;
		end;
	end;
	
	-- increment the global index
	rewatch_i = rewatch_i+1; rewatch_AlterFrame(); rewatch_SnapToGrid(frame);

	-- return the inserted player's player table index
	return rewatch_GetPlayer(player);
	
end;

-- hide all bars and buttons from - and the player himself, by name
-- player: the name of the player to hide
-- return: void
-- PRE: Called by specific user request
function rewatch_HidePlayerByName(player)

	if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
	else
		-- get the index of this player
		local playerId = rewatch_GetPlayer(player);
		-- if this player exists, hide all bars and buttons from - and the player himself
		if(playerId > 0) then
			-- check for others
			local others = false;
			for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then
				if(i ~= playerId) then others = true; break; end;
			end; end;
			-- if there are other people in the frame
			if(others) then
				-- hide the player
				rewatch_HidePlayer(playerId);
				-- prevent auto-adding grouped players automatically
				if((rewatch_loadInt["AutoGroup"] == 1) and (rewatch_InGroup(player)) and UnitIsPlayer(player) and UnitIsConnected(player)) then
					rewatch_load["AutoGroup"], rewatch_loadInt["AutoGroup"] = 0, 0;
					rewatch_OptionsFromData(true);
					rewatch_Message(rewatch_loc["setautogroupauto0"]);
				end;
			else rewatch_Message(rewatch_loc["removefailed"]); end;
		end;
	end;
	
end;

-- hide all bars and buttons from - and the player himself
-- playerId: the table index of the player to hide
-- return: void
function rewatch_HidePlayer(playerId)

	-- return if in combat
	if(rewatch_inCombat) then return; end;
	
	-- remove the bar
	local parent = rewatch_bars[playerId]["Frame"]:GetParent();
	rewatch_bars[playerId]["PlayerBar"]:Hide();
	rewatch_bars[playerId]["PlayerBarInc"]:Hide();
	
	-- druid
	if(rewatch_loadInt["IsDruid"]) then 
		rewatch_bars[playerId][rewatch_loc["lifebloom"].."Bar"]:Hide();
		rewatch_bars[playerId][rewatch_loc["rejuvenation"].."Bar"]:Hide();
		rewatch_bars[playerId][rewatch_loc["rejuvenation (germination)"].."Bar"]:Hide();
		if(rewatch_bars[playerId][rewatch_loc["wildgrowth"].."Bar"]) then
			rewatch_bars[playerId][rewatch_loc["wildgrowth"].."Bar"]:Hide();
		end;
		rewatch_bars[playerId][rewatch_loc["regrowth"].."Bar"]:Hide();
	
	-- shaman
	elseif(rewatch_loadInt["IsShaman"]) then 
		rewatch_bars[playerId][rewatch_loc["riptide"].."Bar"]:Hide();
	end;
	
	for _, b in pairs(rewatch_bars[playerId]["Buttons"]) do b:Hide(); end;
	
	rewatch_bars[playerId]["Frame"]:Hide();
	rewatch_bars[playerId]["Frame"]:SetParent(nil);
	rewatch_bars[playerId] = nil;
	
	-- update the frame width/height
	if(parent ~= UIParent) then rewatch_AlterFrame(); end;
	
end;

-- process highlighting
-- spell: name of the debuff caught
-- player: name of the player it was caught on
-- highlighting: list to check: Highlight, Highlight2 or Highlight3
-- notify: frame to affect: Notify, Notify2 or Notify3
-- return: true if a highlight was made, false if not
function rewatch_ProcessHighlight(spell, player, highlighting, notify)

	if(not rewatch_loadInt[highlighting]) then return false; end;
	for _, b in ipairs(rewatch_loadInt[highlighting]) do
		if(spell == b) then
			playerId = rewatch_GetPlayer(player);
			if(playerId > 0) then
				rewatch_bars[playerId][notify] = spell; rewatch_SetFrameBG(playerId);
				return true;
			end;
		end;
	end;
	
	return false;
	
end;

-- process damage registration (for damage taken per 5 seconds)
-- playerId: id of the player receiving damage
-- damage: the amount of damage
-- return: void
function rewatch_RegisterDamage(playerId, damage)

	local time = math.floor(GetTime());

	if(rewatch_damage[playerId] == nil) then rewatch_damage[playerId] = {}; end;
	if(rewatch_damage[0] == nil) then rewatch_damage[0] = {}; end;
	
	rewatch_damage[playerId][time + 0] = (rewatch_damage[playerId][time + 0] or 0) + damage;
	rewatch_damage[playerId][time + 1] = (rewatch_damage[playerId][time + 1] or 0) + damage;
	rewatch_damage[playerId][time + 2] = (rewatch_damage[playerId][time + 2] or 0) + damage;
	rewatch_damage[playerId][time + 3] = (rewatch_damage[playerId][time + 3] or 0) + damage;
	rewatch_damage[playerId][time + 4] = (rewatch_damage[playerId][time + 4] or 0) + damage;
	
	rewatch_damage[0][time + 0] = (rewatch_damage[0][time + 0] or 0) + damage;
	rewatch_damage[0][time + 1] = (rewatch_damage[0][time + 1] or 0) + damage;
	rewatch_damage[0][time + 2] = (rewatch_damage[0][time + 2] or 0) + damage;
	rewatch_damage[0][time + 3] = (rewatch_damage[0][time + 3] or 0) + damage;
	rewatch_damage[0][time + 4] = (rewatch_damage[0][time + 4] or 0) + damage;

end;

-- build a frame
-- return: void
function rewatch_BuildFrame()

	-- create it
	rewatch_f = CreateFrame("Frame", "Rewatch_Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate");
	
	-- set proper dimensions and location
	rewatch_f:SetWidth(100); rewatch_f:SetHeight(100); rewatch_f:SetPoint("CENTER", UIParent);
	rewatch_f:EnableMouse(true); rewatch_f:SetMovable(true);
	
	-- set looks
	rewatch_f:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0);
	
	-- make it draggable
	rewatch_f:SetScript("OnMouseDown", function(_, button)
		if(button == "RightButton") then
			if(rewatch_loadInt["Lock"]) then
				rewatch_loadInt["Lock"] = false; rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["unlocked"]);
			else
				rewatch_loadInt["Lock"] = true; rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["locked"]);
			end;
		else if(not rewatch_loadInt["Lock"]) then rewatch_f:StartMoving(); end; end;
	end);
	rewatch_f:SetScript("OnMouseUp", function() rewatch_f:StopMovingOrSizing(); end);
	rewatch_f:SetScript("OnEnter", function () rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end);
	rewatch_f:SetScript("OnLeave", function () rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); end);
	
	-- create cooldown overlay and add it to its own table
	rewatch_gcd = CreateFrame("Cooldown", "FrameCD", rewatch_f, "CooldownFrameTemplate"); rewatch_gcd:SetAlpha(1);
	rewatch_gcd:SetPoint("CENTER", 0, -1); rewatch_gcd:SetWidth(rewatch_f:GetWidth()); rewatch_gcd:SetHeight(rewatch_f:GetHeight()); rewatch_gcd:Hide();
	
end;

-- process the sent commands
-- cmd: the command that has to be executed
-- return: void
function rewatch_SlashCommandHandler(cmd)

	-- when there's a command typed
	if(cmd) then
	
		-- declaration and initialization
		local pos, commands = 0, {};
		for st, sp in function() return string.find(cmd, " ", pos, true) end do
			table.insert(commands, string.sub(cmd, pos, st-1));
			pos = sp + 1;
		end; table.insert(commands, string.sub(cmd, pos));
		
		-- on a help request, reply with the localization help table
		if(string.lower(commands[1]) == "help") then
			for _,val in ipairs(rewatch_loc["help"]) do
				rewatch_Message(val);
			end;
			
		-- if the user wants to add a player manually
		elseif(string.lower(commands[1]) == "add") then
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			elseif(commands[2]) then
				if(rewatch_GetPlayer(commands[2]) < 0) then
					if(rewatch_InGroup(commands[2])) then rewatch_AddPlayer(commands[2], nil);
					elseif(commands[3]) then
						if(string.lower(commands[3]) == "always") then rewatch_AddPlayer(commands[2], nil);
						else rewatch_Message(rewatch_loc["notingroup"]); end;
					else rewatch_Message(rewatch_loc["notingroup"]); end;
				end;
			elseif(UnitName("target")) then if(rewatch_GetPlayer(UnitName("target")) < 0) then rewatch_AddPlayer(UnitName("target"), nil); end;
			else rewatch_Message(rewatch_loc["noplayer"]); end;
			
		-- if the user wants to resort the list (clear and processgroup)
		elseif(string.lower(commands[1]) == "sort") then
			if(rewatch_loadInt["AutoGroup"] == 0) then
				rewatch_Message(rewatch_loc["nosort"]);
			else
				if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
				else
					rewatch_clear = true;
					rewatch_changed = true;
					rewatch_Message(rewatch_loc["sorted"]);
				end;
			end;
			
		-- if the user wants to change to a layout preset
		elseif(string.lower(commands[1]) == "layout") then
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_SetLayout(commands[2]);
			end;
			
		-- if the user wants to clear the player list
		elseif(string.lower(commands[1]) == "clear") then
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_clear = true;
				rewatch_Message(rewatch_loc["cleared"]);
			end;
			
		-- allow setting the max amount of players to be in the list
		elseif(string.lower(commands[1]) == "maxplayers") then
			if(tonumber(commands[2])) then
				rewatch_loadInt["MaxPlayers"] = tonumber(commands[2]); rewatch_load["MaxPlayers"] = rewatch_loadInt["MaxPlayers"];
				rewatch_Message("Set max players to "..rewatch_load["MaxPlayers"]..". Set to 0 to ignore the maximum."); rewatch_changed = true;
			end;
			
		-- if the user wants to set the gcd alpha
		elseif(string.lower(commands[1]) == "gcdalpha") then
			if(not tonumber(commands[2])) then rewatch_Message(rewatch_loc["nonumber"]);
			elseif((tonumber(commands[2]) < 0) or (tonumber(commands[2]) > 1)) then rewatch_Message(rewatch_loc["nonumber"]);
			else
				rewatch_load["GcdAlpha"] = tonumber(commands[2]); rewatch_loadInt["GcdAlpha"] = rewatch_load["GcdAlpha"];
				rewatch_gcd:SetAlpha(rewatch_loadInt["GcdAlpha"]);
				rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["setalpha"]..commands[2]);
			end;
			
		-- if the user wants to set the hide solo feature
		elseif(string.lower(commands[1]) == "hidesolo") then
			if(not((commands[2] == "0") or (commands[2] == "1"))) then rewatch_Message(rewatch_loc["nonumber"]);
			else
				rewatch_load["HideSolo"] = tonumber(commands[2]); rewatch_loadInt["HideSolo"] = rewatch_load["HideSolo"];
				if(((rewatch_i == 2) and (rewatch_load["HideSolo"] == 1)) or (rewatch_load["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
				rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["sethidesolo"..commands[2]]);
			end;
			
		-- if the user wants to set the hide feature
		elseif(string.lower(commands[1]) == "hide") then
			rewatch_load["Hide"] = 1; rewatch_loadInt["Hide"] = rewatch_load["Hide"];
			if(((rewatch_i == 2) and (rewatch_load["HideSolo"] == 1)) or (rewatch_load["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
			rewatch_OptionsFromData(true); rewatch_Message(rewatch_loc["sethide1"]);
		elseif(string.lower(commands[1]) == "show") then
			rewatch_load["Hide"] = 0; rewatch_loadInt["Hide"] = rewatch_load["Hide"];
			if(((rewatch_i == 2) and (rewatch_load["HideSolo"] == 1)) or (rewatch_load["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
			rewatch_OptionsFromData(true); rewatch_Message(rewatch_loc["sethide0"]);
			
		-- if the user wants to set the autoadjust list to group feature
		elseif(string.lower(commands[1]) == "autogroup") then
			if(not((commands[2] == "0") or (commands[2] == "1"))) then rewatch_Message(rewatch_loc["nonumber"]);
			else
				rewatch_load["AutoGroup"] = tonumber(commands[2]); rewatch_loadInt["AutoGroup"] = rewatch_load["AutoGroup"];
				rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["setautogroup"..commands[2]]);
				rewatch_changed = true;
			end;
			
		-- if the user wants to use the lock feature
		elseif(string.lower(commands[1]) == "lock") then
			rewatch_loadInt["Lock"] = true; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["locked"]);
			
		-- if the user wants to use the unlock feature
		elseif(string.lower(commands[1]) == "unlock") then
			rewatch_loadInt["Lock"] = false; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["unlocked"]);
			
		-- if the user wants to use the player lock feature
		elseif(string.lower(commands[1]) == "lockp") then
			rewatch_loadInt["LockP"] = true; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["lockedp"]);
			
		-- if the user wants to use the player unlock feature
		elseif(string.lower(commands[1]) == "unlockp") then
			rewatch_loadInt["LockP"] = false; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["unlockedp"]);
			
		-- if the user wants to check his version
		elseif(string.lower(commands[1]) == "version") then
			rewatch_Message("Rewatch v"..rewatch_versioni);
			
		-- if the user wants to toggle the settings GUI
		elseif(string.lower(commands[1]) == "options") then
			rewatch_changedDimentions = false;
			InterfaceOptionsFrame_OpenToCategory("Rewatch");
			
		-- if the user wants something else (unsupported)
		elseif(string.len(commands[1]) > 0) then rewatch_Message(rewatch_loc["invalid_command"]);
		else rewatch_Message(rewatch_loc["credits"]); end;
		
	-- if there's no command typed
	else rewatch_Message(rewatch_loc["credits"]); end;
	
end;

-- update all HoT bars for all players
function rewatch_UpdateHoTBars()

	for n=1,rewatch_i-1 do
		
		val = rewatch_bars[n];

		if(val) then
			if(val[rewatch_loc["lifebloom"]]) then
				rewatch_UpdateBar(rewatch_loc["lifebloom"], val["Player"]);
			end;
			if(val[rewatch_loc["rejuvenation"]]) then
				rewatch_UpdateBar(rewatch_loc["rejuvenation"], val["Player"]);
			end;
			if(val[rewatch_loc["regrowth"]]) then
				rewatch_UpdateBar(rewatch_loc["regrowth"], val["Player"]);
			end;
			if(val[rewatch_loc["wildgrowth"]]) then
				rewatch_UpdateBar(rewatch_loc["wildgrowth"], val["Player"]);
			end;
			if(val[rewatch_loc["riptide"]]) then
				rewatch_UpdateBar(rewatch_loc["riptide"], val["Player"]);
			end;
		end;

	end;

end;

--------------------------------------------------------------------------------------------------------------[ SCRIPT ]-------------------------

-- make the addon stop here if the user isn't a druid (classID 11) or a shaman (classid = 7)
if((select(3, UnitClass("player"))) ~= 11 and (select(3, UnitClass("player"))) ~= 7) then return; end;

-- build event logger
rewatch_events = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate"); 
rewatch_events:SetWidth(0); 
rewatch_events:SetHeight(0);
rewatch_events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"); 
rewatch_events:RegisterEvent("GROUP_ROSTER_UPDATE");
rewatch_events:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
rewatch_events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED"); 
rewatch_events:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
rewatch_events:RegisterEvent("UNIT_HEAL_PREDICTION"); 
rewatch_events:RegisterEvent("PLAYER_ROLES_ASSIGNED");
rewatch_events:RegisterEvent("PLAYER_REGEN_DISABLED"); 
rewatch_events:RegisterEvent("PLAYER_REGEN_ENABLED");

-- initialize all vars
rewatch_changedDimentions = false;
rewatch_f = nil;
rewatch_gcd = nil;
rewatch_bars = {};
rewatch_rightClickMenuTable = {};
rewatch_loadInt = {};
rewatch_i = 1;
rewatch_dropDown = nil;
rewatch_changed = false;
rewatch_inCombat = false;
rewatch_clear = false;
rewatch_options = nil;
rewatch_rezzing = "";
rewatch_damage = {};
rewatch_swiftmend_cast = 0;

-- local vars
local r, g, b, a, val, n;
local playerId, debuffType, debuffIcon, role;
local d, x, y, v, left, i, currentTarget, currentTime;

-- add the slash command handler
SLASH_REWATCH1 = "/rewatch";
SLASH_REWATCH2 = "/rew";
SlashCmdList["REWATCH"] = function(cmd)
	rewatch_SlashCommandHandler(cmd);
end;

-- create the outline frame
rewatch_BuildFrame();

-- create the rightclick menu frame
rewatch_rightClickMenuTable = { "", "Remove player", "Add his/her pet", "Mark this player", "Clear all highlighting", "Lock playerframes", "Close menu" };
rewatch_dropDown = CreateFrame("FRAME", "rewatch_dropDownFrame", nil, "UIDropDownMenuTemplate");
rewatch_dropDown.point = "TOPLEFT";
rewatch_dropDown.relativePoint = "TOPRIGHT";
rewatch_dropDown.displayMode = "MENU";
rewatch_dropDown.relativeTo = rewatch_f;

UIDropDownMenu_Initialize(rewatch_dropDownFrame, function(self)
	for i, title in ipairs(rewatch_rightClickMenuTable) do
		local info = UIDropDownMenu_CreateInfo();
		info.isTitle = (i == 1); info.notCheckable = ((i < 2) or (i > 6));
		info.text = title; info.value = i; info.owner = rewatch_dropDown;
		if(i == 4) then
			playerId = rewatch_GetPlayer(rewatch_rightClickMenuTable[1]);
			if(playerId >= 0) then info.checked = rewatch_bars[playerId]["Mark"]; end;
		end;
		if(i == 6) then info.checked = rewatch_loadInt["LockP"]; end;
		info.func = function(self)
			if(self.value == 2) then rewatch_HidePlayerByName(rewatch_rightClickMenuTable[1]);
			elseif(self.value == 3) then
				rewatch_AddPlayer(rewatch_rightClickMenuTable[1], "pet");
			elseif(self.value == 4) then
				playerId = rewatch_GetPlayer(rewatch_rightClickMenuTable[1]);
				if(playerId) then
					rewatch_bars[playerId]["Mark"] = not rewatch_bars[playerId]["Mark"];
					rewatch_SetFrameBG(playerId);
				end;
			elseif(self.value == 5) then
				playerId = rewatch_GetPlayer(rewatch_rightClickMenuTable[1]);
				if(playerId) then
					rewatch_bars[playerId]["Mark"] = false;
					rewatch_bars[playerId]["Notify"] = nil;
					rewatch_bars[playerId]["Notify2"] = nil;
					rewatch_bars[playerId]["Notify3"] = nil;
					rewatch_bars[playerId]["EarthShield"] = nil;
					rewatch_bars[playerId]["Debuff"] = nil;
					rewatch_bars[playerId]["DebuffTexture"]:Hide();
					if(rewatch_bars[playerId]["Buttons"][rewatch_loc["removecorruption"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["removecorruption"]]:SetAlpha(0.2); end;
					if(rewatch_bars[playerId]["Buttons"][rewatch_loc["naturescure"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["naturescure"]]:SetAlpha(0.2); end;
					if(rewatch_bars[playerId]["Buttons"][rewatch_loc["purifyspirit"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["purifyspirit"]]:SetAlpha(0.2); end;
					rewatch_SetFrameBG(playerId);
				end;
			elseif(self.value == 6) then
				rewatch_loadInt["LockP"] = (not self.checked); if(rewatch_loadInt["LockP"]) then rewatch_Message(rewatch_loc["lockedp"]); else rewatch_Message(rewatch_loc["unlockedp"]); end;
				rewatch_OptionsFromData(true);
			end; 
		end;
		UIDropDownMenu_AddButton(info);
	end;
end, "MENU");
UIDropDownMenu_SetWidth(rewatch_dropDown, 90);

-- make sure we catch events and process them
rewatch_events:SetScript("OnEvent", function(_, event, unitGUID, _)
	
	-- let's catch incombat here
	if(event == "PLAYER_REGEN_ENABLED") then rewatch_inCombat = false;
	elseif(event == "PLAYER_REGEN_DISABLED") then rewatch_inCombat = true; end;
	
	-- only process if properly loaded
	if(not rewatch_loadInt["Loaded"]) then return;
	
	-- switched talent/dual spec
	elseif((event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "ACTIVE_TALENT_GROUP_CHANGED")) then
	
		if((GetSpecialization() == 4 and rewatch_loadInt["IsDruid"]) or (GetSpecialization() == 3 and rewatch_loadInt["IsShaman"])) then
			rewatch_loadInt["InRestoSpec"] = true;
		else
			rewatch_loadInt["InRestoSpec"] = false;
		end;
		
		rewatch_clear = true;
		rewatch_changed = true;
		
	-- party changed
	elseif(event == "GROUP_ROSTER_UPDATE") then
	
		rewatch_changed = true;
		
	-- changed role
	elseif(event == "PLAYER_ROLES_ASSIGNED") then
	
		if(unitGUID) then
			playerId = rewatch_GetPlayer(UnitName(unitGUID));
			if(playerId < 0) then return; end;
			val = rewatch_bars[playerId];
			if(val["UnitGUID"]) then
				role = UnitGroupRolesAssigned(UnitName(unitGUID));
				if(role == "TANK") then roleIcon:SetTexture("Interface\\AddOns\\Rewatch\\Textures\\tank.tga"); roleIcon:Show();
				elseif(role == "HEALER") then roleIcon:SetTexture("Interface\\AddOns\\Rewatch\\Textures\\healer.tga"); roleIcon:Show();
				else roleIcon:Hide(); end;
			end;
		end;
	
	-- combat stuff
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		
		-- setup data
		local _, effect, _, sourceGUID, _, _, _, _, targetName = CombatLogGetCurrentEventInfo();
		local isMe = sourceGUID == UnitGUID("player");
		local spell, school, amount;
		
		-- damage taken
		if(effect == "SWING_DAMAGE" or effect == "SPELL_DAMAGE") then
		
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			
			-- get amount
			if(effect == "SWING_DAMAGE") then amount = select(12, CombatLogGetCurrentEventInfo());
			else amount = select(15, CombatLogGetCurrentEventInfo()); end;
			
			-- register
			rewatch_RegisterDamage(playerId, amount);
			
		-- buff applied/refreshed
		elseif((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
			
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			
			-- get spell data
			spell, _, school = select(13, CombatLogGetCurrentEventInfo());
			
			-- process our HoTs
			if(isMe and
			(
				((spell == rewatch_loc["wildgrowth"]) and (rewatch_loadInt["WildGrowth"] == 1))
				or (spell == rewatch_loc["regrowth"])
				or (spell == rewatch_loc["rejuvenation"])
				or (spell == rewatch_loc["rejuvenation (germination)"])
				or (spell == rewatch_loc["lifebloom"])
				or (spell == rewatch_loc["riptide"])
			)) then
				
				rewatch_UpdateBar(spell, targetName);
			
			-- process earthshield
			elseif(isMe and (spell == rewatch_loc["earthshield"])) then
				
				local es0, es1, es2;
				
				for es0 = 1, 40 do
					es1, _, es2, _ = UnitBuff(targetName, es0, "PLAYER");
					if (es1 == nil) then return; end;
					if (es1 == spell) then rewatch_bars[playerId]["EarthShield"] = es2; return; end;
				end;
				
			-- process innervate
			elseif(isMe and (spell == rewatch_loc["innervate"]) and (targetName ~= UnitName("player"))) then
			
				SendChatMessage("Innervating "..targetName.."!", "SAY");
				
			-- process custom highlighting
			elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting", "Notify")) then
			elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting2", "Notify2")) then
			elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting3", "Notify3")) then
			
				-- ignore further, already processed it		
				
			-- process debuff application
			elseif(school == "DEBUFF") then
				
				-- determine debuff type
				debuffType, debuffIcon = rewatch_GetCleansableDebuffType(targetName);
				
				if(debuffType ~= nil) then
					rewatch_bars[playerId]["Debuff"] = spell; 
					rewatch_bars[playerId]["DebuffType"] = debuffType;
					rewatch_bars[playerId]["DebuffIcon"] = debuffIcon;
					if(rewatch_bars[playerId]["Buttons"][rewatch_loc["removecorruption"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["removecorruption"]]:SetAlpha(1); end;
					if(rewatch_bars[playerId]["Buttons"][rewatch_loc["naturescure"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["naturescure"]]:SetAlpha(1); end;
					if(rewatch_bars[playerId]["Buttons"][rewatch_loc["purifyspirit"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["purifyspirit"]]:SetAlpha(1); end;
					rewatch_SetFrameBG(playerId);
				end;
				
			-- process shapeshift
			elseif((spell == rewatch_loc["bearForm"]) or (spell == rewatch_loc["direBearForm"]) or (spell == rewatch_loc["catForm"])) then
			
				-- if it was cat, make it yellow
				if(spell == rewatch_loc["catForm"]) then
					val = rewatch_GetPowerBarColor("ENERGY");
					rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(val.r, val.g, val.b, 1);
					
				-- else, it was bear form, make it red
				else
					val = rewatch_GetPowerBarColor("RAGE");
					rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(val.r, val.g, val.b, 1);
				end;
				
			-- process clearcasting
			elseif((spell == rewatch_loc["clearcasting"]) and (targetName == UnitName("player"))) then
				for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
					if(val[rewatch_loc["regrowth"]]) then
						val[rewatch_loc["regrowth"].."Border"]:SetBackdropBorderColor(1, 1, 1, 1);
						val[rewatch_loc["regrowth"].."Border"]:SetFrameStrata("HIGH");
					end;
				end; end;
			end;
			
		-- if an aura faded
		elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then
			
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			
			-- get spell data
			spell = select(13, CombatLogGetCurrentEventInfo());
			
			-- process HoTs we cast
			if(isMe and
			(
				(spell == rewatch_loc["regrowth"])
				or (spell == rewatch_loc["rejuvenation"])
				or (spell == rewatch_loc["rejuvenation (germination)"])
				or (spell == rewatch_loc["lifebloom"])
				or (spell == rewatch_loc["wildgrowth"])
				or (spell == rewatch_loc["riptide"]))
			) then
				
				rewatch_DowndateBar(spell, playerId);
			
			-- process earthshield
			elseif(isMe and (spell == rewatch_loc["earthshield"])) then
				
				local es0, es1, es2;
				
				for es0 = 1, 40 do
					es1, _, es2, _ = UnitBuff(targetName, es0, "PLAYER");
					if (es1 == nil) then return; end;
					if (es1 == spell) then rewatch_bars[playerId]["EarthShield"] = es2; return; end;
				end;
				
				rewatch_bars[playerId]["EarthShield"] = 0;
				
			-- process end of clearcasting
			elseif((spell == rewatch_loc["clearcasting"]) and (targetName == UnitName("player"))) then
				
				for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
					if(val[rewatch_loc["regrowth"]]) then
						val[rewatch_loc["regrowth"].."Border"]:SetBackdropBorderColor(1, 1, 1, 0);
						val[rewatch_loc["regrowth"].."Border"]:SetFrameStrata("MEDIUM");
					end;
				end; end;
				
			-- process debuff highlighting removal
			elseif(rewatch_bars[playerId]["Debuff"] == spell) then
				rewatch_bars[playerId]["Debuff"] = nil;
				rewatch_bars[playerId]["DebuffTexture"]:Hide();
				if(rewatch_bars[playerId]["Buttons"][rewatch_loc["removecorruption"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["removecorruption"]]:SetAlpha(0.2); end;
				if(rewatch_bars[playerId]["Buttons"][rewatch_loc["naturescure"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["naturescure"]]:SetAlpha(0.2); end;
				if(rewatch_bars[playerId]["Buttons"][rewatch_loc["purifyspirit"]]) then rewatch_bars[playerId]["Buttons"][rewatch_loc["purifyspirit"]]:SetAlpha(0.2); end;
				rewatch_SetFrameBG(playerId);
			elseif(rewatch_bars[playerId]["Notify"] == spell) then
				rewatch_bars[playerId]["Notify"] = nil; rewatch_SetFrameBG(playerId);
			elseif(rewatch_bars[playerId]["Notify2"] == spell) then
				rewatch_bars[playerId]["Notify2"] = nil; rewatch_SetFrameBG(playerId);
			elseif(rewatch_bars[playerId]["Notify3"] == spell) then
				rewatch_bars[playerId]["Notify3"] = nil; rewatch_SetFrameBG(playerId);
				
			-- process shapeshift
			elseif((spell == rewatch_loc["bearForm"]) or (spell == rewatch_loc["direBearForm"]) or (spell == rewatch_loc["catForm"])) then
				val = rewatch_GetPowerBarColor("MANA");
				rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(val.r, val.g, val.b, 1);
			end;
			
		-- if an other spell was cast successful by the user or a heal has been received
		elseif(isMe and ((effect == "SPELL_CAST_SUCCESS") or (effect == "SPELL_HEAL"))) then
	
			rewatch_TriggerCooldown();
			
			-- get spell data
			spell = select(13, CombatLogGetCurrentEventInfo());
			
			-- update button cooldowns
			for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
				if(val["Buttons"][spell]) then val["Buttons"][spell].doUpdate = true; else break; end;
			end; end;
			
			-- for flourish, update all hot bars from all players
			if((spell == rewatch_loc["flourish"]) and (effect == "SPELL_CAST_SUCCESS")) then
				rewatch_UpdateHoTBars();
			end;
			
			-- if swiftmend, inform that all buffs shall be refreshed on next event
			if(spell == rewatch_loc["swiftmend"]) then
				rewatch_swiftmend_cast = GetTime();
			end;
			
		-- if we started casting Rebirth or Revive, check if we need to report
		elseif(isMe and (effect == "SPELL_CAST_START") and ((spell == rewatch_loc["rebirth"]) or (spell == rewatch_loc["revive"]))) then
		
			if(not rewatch_rezzing) then rewatch_rezzing = ""; end;
			if(UnitIsDeadOrGhost(rewatch_rezzing)) then
				SendChatMessage("Rezzing "..rewatch_rezzing.."!", "SAY");
				rewatch_rezzing = "";
			end;
			
		end;
		
	end;
end);

-- update everything
rewatch_events:SetScript("OnUpdate", function()

	-- load saved vars
	if(not rewatch_loadInt["Loaded"]) then
	
		rewatch_OnLoad();
		return;
		
	end;

	-- clearing and reprocessing the frames
	if(not rewatch_inCombat) then
	
		-- check if we have the extra need to clear
		if(rewatch_changed and rewatch_loadInt["AutoGroup"] == 1) then
			if((GetNumGroupMembers() == 0 and IsInRaid()) or (GetNumSubgroupMembers() == 0 and not IsInRaid())) then rewatch_clear = true; end;
		end;
		
		-- clear
		if(rewatch_clear) then
			for i=1,rewatch_i-1 do v = rewatch_bars[i]; if(v) then rewatch_HidePlayer(i); end; end;
			rewatch_bars = nil; rewatch_bars = {}; rewatch_i = 1;
			rewatch_clear = false;
		end;
		
		-- changed
		if(rewatch_changed) then
			if(rewatch_loadInt["AutoGroup"] == 1) then rewatch_ProcessGroup(); end;
			rewatch_changed = false;
		end;
		
	end;
	
	-- get current target and time
	currentTarget = UnitGUID("target");
	currentTime = GetTime();
	
	-- if swiftmend was cast before, update HoTs (for legendary with effect: Verdant Infusion)
	if (rewatch_swiftmend_cast ~= 0 and rewatch_swiftmend_cast < currentTime) then
		rewatch_UpdateHoTBars(rewatch_i);
		rewatch_swiftmend_cast = 0;
	end;

	-- process updates
	for i=1,rewatch_i-1 do
	
		v = rewatch_bars[i];
	
		-- if this player exists
		if(v) then
			
			-- make targeted unit have highlighted font
			x = UnitGUID(v["Player"]);
			if(currentTarget and (not v["Highlighted"]) and (x == currentTarget)) then
				v["Highlighted"] = true;
				v["PlayerBar"].text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["HighlightSize"] * (rewatch_loadInt["Scaling"]/100), "THICKOUTLINE");
			elseif((v["Highlighted"]) and (x ~= currentTarget)) then
				v["Highlighted"] = false;
				v["PlayerBar"].text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"] * (rewatch_loadInt["Scaling"]/100), "OUTLINE");
			end;

			-- clear buffs if the player just died
			if(UnitIsDeadOrGhost(v["Player"])) then

				if(select(4, v["PlayerBar"]:GetStatusBarColor()) > 0.6) then

					v["PlayerBar"]:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 0.5);
					v["ManaBar"]:SetValue(0);
					v["DamageBar"]:SetValue(0);
					v["PlayerBar"]:SetValue(0);
					v["PlayerBarInc"]:SetValue(0);
					if(v["Mark"]) then
						v["Frame"]:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
					else
						v["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
					end;
					v["PlayerBar"].text:SetText(v["DisplayName"]);
					rewatch_DowndateBar(rewatch_loc["lifebloom"], i);
					rewatch_DowndateBar(rewatch_loc["rejuvenation"], i);
					rewatch_DowndateBar(rewatch_loc["rejuvenation (germination)"], i);
					rewatch_DowndateBar(rewatch_loc["regrowth"], i);
					rewatch_DowndateBar(rewatch_loc["wildgrowth"], i);
					rewatch_DowndateBar(rewatch_loc["riptide"], i);
					v["Notify"] = nil;
					v["Notify2"] = nil;
					v["Notify3"] = nil;
					v["EarthShield"] = nil;
					v["Debuff"] = nil;
					v["DebuffTexture"]:Hide();
					v["Frame"]:SetAlpha(0.2);
					if(v["Buttons"][rewatch_loc["removecorruption"]]) then v["Buttons"][rewatch_loc["removecorruption"]]:SetAlpha(0.2); end;
					if(v["Buttons"][rewatch_loc["naturescure"]]) then v["Buttons"][rewatch_loc["naturescure"]]:SetAlpha(0.2); end;
					if(v["Buttons"][rewatch_loc["purifyspirit"]]) then v["Buttons"][rewatch_loc["purifyspirit"]]:SetAlpha(0.2); end;
					
				end;
				
				-- else, unit's dead and processed, ignore him now
				
			else
			
				-- get and set health data
				x, y = UnitHealthMax(v["Player"]), UnitHealth(v["Player"]);
				v["PlayerBar"]:SetMinMaxValues(0, x); v["PlayerBar"]:SetValue(y);
				
				-- set predicted heals
				if(rewatch_loadInt["ShowIncomingHeals"] == 1) then
					d = UnitGetIncomingHeals(v["Player"]) or 0;
					v["PlayerBarInc"]:SetMinMaxValues(0, x);
					if(y+d>=x) then v["PlayerBarInc"]:SetValue(x);
					else v["PlayerBarInc"]:SetValue(y+d); end;
				end;

				-- set healthbar color
				d = y/x;
				if(d < 0.5) then
					d = d * 2;
					v["PlayerBar"]:SetStatusBarColor(0.50 + ((1-d) * (1.00 - 0.50)), rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 1);
				else
					d = (d * 2) - 1;
					v["PlayerBar"]:SetStatusBarColor(rewatch_loadInt["HealthColor"].r + ((1-d) * (0.50 - rewatch_loadInt["HealthColor"].r)), rewatch_loadInt["HealthColor"].g + ((1-d) * (0.50 - rewatch_loadInt["HealthColor"].g)), rewatch_loadInt["HealthColor"].b, 1);
				end;

				-- initialize player text
				-- this is mainly because the set text in rewatch_AddPlayer during screen initialization (startup) does not render
				-- updating the field with the same value once everything is initialized is caught by the engine, because it's the same value as internally stored
				-- this 'solution' shows a 'typing' animation when adding a player to the group
				if(v["Init"] ~= nil) then

					local displayName, displayPos = v["DisplayName"], math.floor((currentTime - v["Init"]) * 10);
					if(displayPos < displayName:len()) then displayName = displayName:sub(1, displayPos).."_"; else v["Init"] = nil; end;
					
					v["PlayerBar"].text:SetText(displayName);

				-- set healthbar text (standard)
				elseif(v["Hover"] == 0) then
					
					if(v["EarthShield"] ~= nil) then
					
						if(v["EarthShield"] > 0) then
							v["PlayerBar"].text:SetText(v["EarthShield"].." "..v["DisplayName"]);
						else
							v["PlayerBar"].text:SetText(v["DisplayName"]);
							v["EarthShield"] = nil;
						end;
						
					elseif((rewatch_loadInt["HealthDeficit"] == 1) and (y < (rewatch_loadInt["DeficitThreshold"]*1000))) then
						
						v["PlayerBar"].text:SetText(v["DisplayName"].."\n"..string.format("%#.1f", y/1000).."k");
						
					end;
					
				-- set healthbar text (when hovering)
				elseif(v["Hover"] == 1) then
					
					d = string.format("%i/%i", y, x);
					
					if(rewatch_loadInt["ShowDamageTaken"] == 1) then
						
						x = ((rewatch_damage[i] or {})[math.floor(currentTime)] or 0) / 5;
						
						if(x > 0) then
							if(x > 1000) then x = string.format("%#.1f", x/1000).."k"; end;
							d = d.."\n"..x.." DTPS";
						end;
						
					end;
					
					v["PlayerBar"].text:SetText(d);
					
				-- set healthbar text (when unhovering)
				elseif(v["Hover"] == 2) then
					
					v["PlayerBar"].text:SetText(v["DisplayName"]);
					v["Hover"] = 0;
					
				end;
				
				-- get and set mana data
				v["ManaBar"]:SetMinMaxValues(0, UnitPowerMax(v["Player"]));
				v["ManaBar"]:SetValue(UnitPower(v["Player"]));
				
				-- update damage bar
				if(rewatch_loadInt["ShowDamageTaken"] == 1) then
				
					(rewatch_damage[0] or {})[math.floor(currentTime)-1] = nil;
					(rewatch_damage[i] or {})[math.floor(currentTime)-1] = nil;
					
					v["DamageBar"]:SetMinMaxValues(0, (rewatch_damage[0] or {})[math.floor(currentTime)] or 0);
					v["DamageBar"]:SetValue((rewatch_damage[i] or {})[math.floor(currentTime)] or 0);
					
				end;
				
				-- fade when out of range
				if(IsSpellInRange(rewatch_loadInt["SampleSpell"], v["Player"]) == 1) then
					v["Frame"]:SetAlpha(1);
				else
					v["Frame"]:SetAlpha(rewatch_loadInt["OORAlpha"]);
					v["PlayerBarInc"]:SetValue(0);
				end;
				
				-- update button cooldown layers
				for _, d in pairs(v["Buttons"]) do
					if(d.doUpdate == true) then
						CooldownFrame_Set(d.cooldown, GetSpellCooldown(d.spellName));
						d.doUpdate = false;
					end;
				end;
				
				-- rejuvenation bar process
				if(v[rewatch_loc["rejuvenation"]] > 0) then
					left = v[rewatch_loc["rejuvenation"]]-currentTime;
					if(left > 0) then
						v[rewatch_loc["rejuvenation"].."Bar"]:SetValue(left);
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["rejuvenation"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						if(math.abs(left-2)<0.1) then v[rewatch_loc["rejuvenation"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["rejuvenation"], i);
					end;
				end;
				
				-- rejuvenation (germination) bar process
				if(v[rewatch_loc["rejuvenation (germination)"]] > 0) then
					left = v[rewatch_loc["rejuvenation (germination)"]]-currentTime;
					if(left > 0) then
						v[rewatch_loc["rejuvenation (germination)"].."Bar"]:SetValue(left);
						if(math.abs(left-2)<0.1) then v[rewatch_loc["rejuvenation (germination)"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["rejuvenation (germination)"], i);
					end;
				end;
				
				-- regrowth bar process
				if(v[rewatch_loc["regrowth"]] > 0) then
					left = v[rewatch_loc["regrowth"]]-currentTime;
					if(left > 0) then
						v[rewatch_loc["regrowth"].."Bar"]:SetValue(left);
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["regrowth"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						if(math.abs(left-2)<0.1) then v[rewatch_loc["regrowth"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["regrowth"], i);
					end;
				end;
				
				-- lifebloom bar process
				if(v[rewatch_loc["lifebloom"]] > 0) then
					left = v[rewatch_loc["lifebloom"]]-currentTime;
					if(left > 0) then
						v[rewatch_loc["lifebloom"].."Bar"]:SetValue(left);
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["lifebloom"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						if(math.abs(left-2)<0.1) then v[rewatch_loc["lifebloom"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["lifebloom"], i);
					end;
				end;
				
				-- wild growth bar process
				if((v[rewatch_loc["wildgrowth"].."Bar"]) and (v[rewatch_loc["wildgrowth"]] > 0)) then
					spellName = rewatch_loc["wildgrowth"];
					left = v[rewatch_loc["wildgrowth"]]-currentTime;
					if(left > 0) then
						if(v["Reverting"..spellName] == 1) then
							_, y = v[rewatch_loc["wildgrowth"].."Bar"]:GetMinMaxValues();
							v[rewatch_loc["wildgrowth"].."Bar"]:SetValue(y - left);
						else
							v[rewatch_loc["wildgrowth"].."Bar"]:SetValue(left);
							if(math.abs(left-2)<0.1) then v[rewatch_loc["wildgrowth"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
						end;
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["wildgrowth"].."Bar"].text:SetText(string.format("%.00f", left)); end;
					elseif((left < -1) or (v["Reverting"..spellName] == 1)) then
						rewatch_DowndateBar(rewatch_loc["wildgrowth"], i);
					end;
				end;

				-- riptide bar process
				if((v[rewatch_loc["riptide"].."Bar"]) and (v[rewatch_loc["riptide"]] > 0)) then
					spellName = rewatch_loc["riptide"];
					left = v[rewatch_loc["riptide"]]-currentTime;
					if(left > 0) then
						-- Riptide has smaller cooldown than duration, for that show
						-- cooldown to know if it can be cast on other players.
						-- Get start, duration to write cooldown behind ticks of hot
						spell_start, spell_duration = GetSpellCooldown(spellName)
						spell_start = spell_start + spell_duration; 
						spell_cd = spell_start - currentTime;
						if(v["Reverting"..spellName] == 1) then
							_, y = v[rewatch_loc["riptide"].."Bar"]:GetMinMaxValues();
							v[rewatch_loc["riptide"].."Bar"]:SetValue( y - left);
						else
							v[rewatch_loc["riptide"].."Bar"]:SetValue(left);
							if(math.abs(left-2)<0.1) then v[rewatch_loc["riptide"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
						end;
						if (spell_cd > 0 and spell_cd ~= left) then
							if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["riptide"].."Bar"].text:SetText(string.format("%.00f / %.00f", left,  spell_cd)); end;
						else
							if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["riptide"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						end;
					elseif((left < -1) or (v["Reverting"..spellName] == 1)) then
						rewatch_DowndateBar(rewatch_loc["riptide"], i);
					end;
				end;
				
			end;
		end;
	end;
end);