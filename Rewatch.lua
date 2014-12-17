-- Rewatch originally by Dezine, Argent Dawn, Europe (Coen van der Wel, Almere, the Netherlands).
-- Also maintained by bobn64 (Tyrahis, Shu'halo).

-- Please give full credit when you want to redistribute or modify this addon!


local rewatch_versioni = 60000;
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
		local supported, update = { "5.4", "5.4.1", 50402, 50403, 50404, 50405, 50406, 50407, 50408, 50409, 50500, 50501, 50502, 50503, 50504, 50505, 50506, 50507, 60000 }, false;
		for _, version in ipairs(supported) do update = update or (version == rewatch_version) end;
		-- supported? then update
		if(update) then
			update = false;
			update = update or (rewatch_version == "5.4");
			update = update or (rewatch_version == "5.4.1");
			if(update) then
				rewatch_load["Font"] = "Interface\\AddOns\\Rewatch\\Fonts\\BigNoodleTitling.ttf";
				rewatch_load["Bar"] = "Interface\\AddOns\\Rewatch\\Textures\\Bar.tga";
				rewatch_load["SpellBarWidth"] = 60;
				rewatch_load["FontSize"] = 11;
				rewatch_load["HighlightSize"] = 11;
				rewatch_load["SpellBarHeight"] = 14;
				rewatch_load["HealthBarHeight"] = 110;
				rewatch_load["HealthDeficit"] = 0;
			end;
			if(rewatch_version < 50404) then
				rewatch_load["AltMacro"] = "/shrug";
				rewatch_load["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["innervate"];
				rewatch_load["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
			end;
			if(rewatch_version < 50405) then
				rewatch_load["BarColor"..rewatch_loc["lifebloom"]].a = 1;
				rewatch_load["BarColor"..rewatch_loc["rejuvenation"]].a = 1;
				rewatch_load["BarColor"..rewatch_loc["rejuvenation"].."2"].a = 1;
				rewatch_load["BarColor"..rewatch_loc["regrowth"]].a = 1;
				rewatch_load["BarColor"..rewatch_loc["wildgrowth"]].a = 1;
				rewatch_load["Scaling"] = 100;
				rewatch_load["PBOAlpha"] = 0.2;
				rewatch_load["Layout"] = "horizontal";
			end;
			if(rewatch_version < 50407) then
				rewatch_load["SortByRole"] = 1;
				rewatch_load["ShowSelfFirst"] = 1;
			end;
			if(rewatch_version < 50507) then
				rewatch_load["ShowIncomingHeals"] = 1;
			end;
			if(rewatch_version < 60000) then
				rewatch_load["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
				rewatch_load["BarColor"..rewatch_loc["rejuvenation"].."2"] = { r=1; g=0.5; b=0, a=1};
				if(rewatch_load["Layout"] == "default") then
					rewatch_load["Layout"] = "horizontal";
				end;
			end;
			
			-- get spec properties
			rewatch_loadInt["InRestoSpec"] = false;
			if(GetSpecialization() == 4) then
				rewatch_loadInt["InRestoSpec"] = true;
			end;
			rewatch_loadInt["HasBlooming"] = false;
			for i=1, NUM_GLYPH_SLOTS do
				if(select(6, GetGlyphSocketInfo(i)) == 434) then rewatch_loadInt["HasBlooming"] = true; end;
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
			rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"].."2"] = rewatch_load["BarColor"..rewatch_loc["rejuvenation"].."2"];
			rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]] = rewatch_load["BarColor"..rewatch_loc["regrowth"]];
			rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]] = rewatch_load["BarColor"..rewatch_loc["wildgrowth"]];
			rewatch_loadInt["Labels"] = rewatch_load["Labels"];
			rewatch_loadInt["ShowTooltips"] = rewatch_load["ShowTooltips"];
			rewatch_loadInt["NameCharLimit"] = rewatch_load["NameCharLimit"];
			rewatch_loadInt["Bar"] = rewatch_load["Bar"];
			rewatch_loadInt["Font"] = rewatch_load["Font"];
			rewatch_loadInt["FontSize"] = rewatch_load["FontSize"];
			rewatch_loadInt["HighlightSize"] = rewatch_load["HighlightSize"];
			rewatch_loadInt["ForcedHeight"] = rewatch_load["ForcedHeight"];
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
			rewatch_loadInt["ShowSelfFirst"] = rewatch_load["ShowSelfFirst"];
			rewatch_loadInt["LockP"] = true;
			-- update later
			rewatch_changed = true;
			-- apply possible changes
			rewatch_DoUpdate();
			-- set current version
			rewatch_version = rewatch_versioni;
		-- reset it all when new or no longer supported
		else rewatch_load = nil; rewatch_version = nil; end;
	-- not loaded before, initialise and welcome new user
	else
		rewatch_load = {};
		rewatch_load["GcdAlpha"], rewatch_load["HideSolo"], rewatch_load["Hide"], rewatch_load["AutoGroup"] = 1, 0, 0, 1;
		rewatch_load["HealthColor"] = { r=0; g=0.7; b=0};
		rewatch_load["FrameColor"] = { r=0; g=0; b=0; a=0.3 };
		rewatch_load["MarkFrameColor"] = { r=0; g=1; b=0; a=1 };
		rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = { r=0.6; g=0; b=0, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation"]] = { r=0.85; g=0.15; b=0.80, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation"].."2"] = { r=1; g=0.5; b=0, a=1};
		rewatch_load["BarColor"..rewatch_loc["regrowth"]] = { r=0.05; g=0.3; b=0.1, a=1};
		rewatch_load["BarColor"..rewatch_loc["wildgrowth"]] = { r=0.5; g=0.8; b=0.3, a=1};
		rewatch_load["Labels"] = 0;
		rewatch_load["SpellBarWidth"] = 60; rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110; rewatch_load["Scaling"] = 100;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["WildGrowth"] = 1;
		rewatch_load["Bar"] = "Interface\\AddOns\\Rewatch\\Textures\\Bar.tga";
		rewatch_load["Font"] = "Interface\\AddOns\\Rewatch\\Fonts\\BigNoodleTitling.ttf";
		rewatch_load["FontSize"] = 11; rewatch_load["HighlightSize"] = 11;
		rewatch_load["HealthDeficit"] = 0;
		rewatch_load["DeficitThreshold"] = 0;
		rewatch_load["ForcedHeight"] = 0;
		rewatch_load["OORAlpha"] = 0.3;
		rewatch_load["PBOAlpha"] = 0.2;
		rewatch_load["NameCharLimit"] = 0; rewatch_load["MaxPlayers"] = 0;
		rewatch_load["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
		rewatch_load["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["innervate"];
		rewatch_load["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
		rewatch_load["Layout"] = "vertical";
		rewatch_load["SortByRole"] = 1;
		rewatch_load["ShowSelfFirst"] = 1;
		rewatch_load["ShowIncomingHeals"] = 1;
		rewatch_load["Highlighting"] = {
			-- todo: wod defaults
		};
		rewatch_load["Highlighting2"] = {
			-- todo: wod defaults
		};
		rewatch_load["Highlighting3"] = {
			-- todo: wod defaults
		};
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["ShowTooltips"] = 1;
		rewatch_RaidMessage(rewatch_loc["welcome"]);
		rewatch_Message(rewatch_loc["welcome"]);
		rewatch_Message(rewatch_loc["info"]);
		-- set current version
		rewatch_version = rewatch_versioni;
	end;
end;

function rewatch_SetLayout(name)
	if(name == "normal") then
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["SpellBarWidth"] = 60;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Layout"] = "vertical";
	elseif(name == "minimalist") then
		rewatch_load["ShowButtons"] = 0;
		rewatch_load["NumFramesWide"] = 1;
		rewatch_load["SpellBarWidth"] = 25;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Layout"] = "vertical";
	elseif(name == "classic") then
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["SpellBarWidth"] = 85;
		rewatch_load["SpellBarHeight"] = 10;
		rewatch_load["HealthBarHeight"] = 30;
		rewatch_load["Layout"] = "horizontal";
	end;
	
	rewatch_loadInt["ShowButtons"] = rewatch_load["ShowButtons"];
	rewatch_loadInt["NumFramesWide"] = rewatch_load["NumFramesWide"];
	rewatch_loadInt["SpellBarWidth"] = rewatch_load["SpellBarWidth"];
	rewatch_loadInt["SpellBarHeight"] = rewatch_load["SpellBarHeight"];
	rewatch_loadInt["HealthBarHeight"] = rewatch_load["HealthBarHeight"];
	rewatch_loadInt["Layout"] = rewatch_load["Layout"];
	
	rewatch_changed = true;
	rewatch_DoUpdate();
end;

-- cut a name by the specified name character limit
-- name: the name to be cut
-- return: the cut name
function rewatch_CutName(name)
	-- strip realm name
	local s = name:find("-"); if(s ~= nil) then name = name:sub(1, s-1).."*"; end;
	-- fix length
	if((rewatch_loadInt["NameCharLimit"] == 0) or (name:len() < rewatch_loadInt["NameCharLimit"])) then return name;
	else return name:sub(1, rewatch_loadInt["NameCharLimit"]); end;
end;

-- update frame dimentions by changes in component sizes/margins
-- return: void
function rewatch_UpdateOffset()
	if(rewatch_loadInt["Layout"] == "horizontal") then
		rewatch_loadInt["FrameWidth"] = (rewatch_loadInt["SpellBarWidth"]) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["ButtonSize"] = (rewatch_loadInt["SpellBarWidth"] / 5) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["FrameHeight"] = ((rewatch_loadInt["SpellBarHeight"]*(3+rewatch_loadInt["WildGrowth"])) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100) + (rewatch_loadInt["ButtonSize"]*rewatch_loadInt["ShowButtons"]);
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		rewatch_loadInt["FrameWidth"] = ((rewatch_loadInt["SpellBarHeight"]*(3+rewatch_loadInt["WildGrowth"])) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["ButtonSize"] = (rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100)) / 5;
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
		end; -- do nothing with the tooltip if not
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetSpellBookItem(md, BOOKTYPE_SPELL);
	end;
end;

-- gets the spell ID of the highest rank of the specified spell
-- spellName: the name of the spell to get the highest ranked spellId from
-- return: the corresponding spellId
function rewatch_GetSpellId(spellName)
	-- get spell info and highest rank, return if the user can't cast it (not learned, etc)
	local name, rank, icon = GetSpellInfo(spellName);
	if(name == nil) then return -1; end;
	-- loop through all book spells, return the number if it matches above data
	local i, ispell, irank = 1, GetSpellBookItemName(1, BOOKTYPE_SPELL);
	repeat
		if ((ispell == name) and ((rank == irank) or (not irank))) then return i; end;
		i, ispell, irank = i+1, GetSpellBookItemName(i+1, BOOKTYPE_SPELL);
	until (not ispell);
	
	-- return default -1
	return -1;
end;

-- clears the entire list and resets it
-- return: void
function rewatch_Clear()
	-- call each playerframe's Hide method
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then rewatch_HidePlayer(i); end; end;
	rewatch_bars = nil; rewatch_bars = {}; rewatch_i = 1;
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
	if(rewatch_bars[playerId]["Notify3"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(1.0, 0.0, 0.0, 1);
	elseif(rewatch_bars[playerId]["Corruption"]) then
		if(rewatch_bars[playerId]["CorruptionType"] == "Poison") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.0, 0.3, 0, 1);
		elseif(rewatch_bars[playerId]["CorruptionType"] == "Curse") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.5, 0.0, 0.5, 1);
		else
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.0, 0.0, 0.5, 1);
		end;
	elseif(rewatch_bars[playerId]["Notify2"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(1.0, 0.5, 0.1, 1);
	elseif(rewatch_bars[playerId]["Notify"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.9, 0.8, 0.2, 1);
	elseif(rewatch_bars[playerId]["Mark"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
	else
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
	end;
end;

-- trigger the cooldown overlays
-- return: void
function rewatch_TriggerCooldown()
	-- get global cooldown, and trigger it on all frames
	local start, duration, enabled = GetSpellCooldown(rewatch_loc["rejuvenation"]); -- some non-cd spell
	CooldownFrame_SetTimer(rewatch_gcd, start, duration, enabled);
end;

-- show the first rewatch frame, with the last 'flash' of the cooldown effect
-- return: void
function rewatch_ShowFrame()
	rewatch_f:Show();
	CooldownFrame_SetTimer(rewatch_gcd, GetTime()-1, 1.25, 1);
end;

-- adjusts the parent frame container's height
-- return: void
function rewatch_AlterFrame()
	-- forcedHeight mode only alters width
	if(rewatch_loadInt["ForcedHeight"] > 0) then
		rewatch_AlterFrameWidth();
	else
		-- set height and width according to number of frames
		local num = rewatch_f:GetNumChildren()-1;
		local height = math.max(rewatch_loadInt["ForcedHeight"], math.ceil(num/rewatch_loadInt["NumFramesWide"])) * rewatch_loadInt["FrameHeight"];
		local width = math.min(rewatch_loadInt["NumFramesWide"],  math.max(num, 1)) * rewatch_loadInt["FrameWidth"];
		-- apply
		rewatch_f:SetWidth(width); rewatch_f:SetHeight(height+20);
		rewatch_gcd:SetWidth(rewatch_f:GetWidth()); rewatch_gcd:SetHeight(rewatch_f:GetHeight());
		-- hide/show on solo
		if(((num == 1) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_f:Show(); end;
		-- make sure frames have a solid height and width (bugfix)
		for j=1,rewatch_i-1 do local val = rewatch_bars[j]; if(val) then
			if(not((val["Frame"]:GetWidth() == rewatch_loadInt["FrameWidth"]) and (val["Frame"]:GetHeight() == rewatch_loadInt["FrameHeight"]))) then
				val["Frame"]:SetWidth(rewatch_loadInt["FrameWidth"]); val["Frame"]:SetHeight(rewatch_loadInt["FrameHeight"]);
			end;
		end; end;
	end;
end;

-- alter the frame width (instead of height) in forcedHeight mode (assumed)
-- return: void
function rewatch_AlterFrameWidth()
	-- get number of frames
	local num = rewatch_f:GetNumChildren()-1;
	-- for each frame
	local framesPerY, maxPerY = {}, 0;
	for j=1,rewatch_i-1 do local val = rewatch_bars[j]; if(val) then
		-- save Y to list
		if(framesPerY[val["Frame"]:GetTop()]) then framesPerY[val["Frame"]:GetTop()] = framesPerY[val["Frame"]:GetTop()]+1; maxPerY = max(maxPerY, framesPerY[val["Frame"]:GetTop()]);
		else framesPerY[val["Frame"]:GetTop()] = 1; maxPerY = max(maxPerY, 1); end;
		-- make sure frames have a solid height and width (bugfix)
		if(not((val["Frame"]:GetWidth() == rewatch_loadInt["FrameWidth"]) and (val["Frame"]:GetHeight() == rewatch_loadInt["FrameHeight"]))) then
			val["Frame"]:SetWidth(rewatch_loadInt["FrameWidth"]); val["Frame"]:SetHeight(rewatch_loadInt["FrameHeight"]);
		end;
	end; end;
	-- set width according to number of frames
	rewatch_loadInt["NumFramesWide"] = maxPerY;
	local height = rewatch_loadInt["ForcedHeight"] * rewatch_loadInt["FrameHeight"];
	local width = math.min(rewatch_loadInt["NumFramesWide"],  math.max(num, 1)) * rewatch_loadInt["FrameWidth"];
	-- apply
	rewatch_f:SetWidth(width+15); rewatch_f:SetHeight(height);
	rewatch_gcd:SetWidth(rewatch_f:GetWidth()); rewatch_gcd:SetHeight(rewatch_f:GetHeight());
	-- hide/show on solo
	if(((num == 1) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_f:Show(); end;
end;

-- snap the supplied frame to the grid when it's placed on a rewatch_f frame
-- frame: the frame to snap to a grid
-- return: void
function rewatch_SnapToGrid(frame)
	-- return if in combat
	if(InCombatLockdown() == 1) then return -1; end;
	
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
			-- now, if in forced height mode, recalculate frame width
			if(rewatch_loadInt["ForcedHeight"] > 0) then rewatch_AlterFrameWidth(); end;
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
	-- assume: there is at least one free position in the specified parent frame
	local children = { frame:GetChildren() }; local x, y, found = 0, 0, false;
	-- walk through the available spots, left to right, top to bottom
	for dy=0, 1-(ceil(frame:GetNumChildren()/rewatch_loadInt["NumFramesWide"])), -1 do for dx=0, rewatch_loadInt["NumFramesWide"]-1 do
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
	end; if(not found) then break; --[[ break for dy loop ]] end; end;
	
	-- return either the found spot, or a formula based on array positioning (fallback)
	if(found) then
		return frame:GetWidth()*((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]), math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]) * frame:GetHeight() * -1;
	else
		if(rewatch_loadInt["ForcedHeight"] > 0) then if(y < 1-frame:GetHeight()) then
			rewatch_loadInt["NumFramesWide"] = rewatch_loadInt["NumFramesWide"]+1;
			return rewatch_GetFramePos(frame);
		end; end;
		return x, y;
	end;
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
-- btnIcon: the string path and name with extension of the icon to use
-- relative: the name of the rewatch_bars[n] key, referencing to the relative cast bar for layout
-- return: the created spell button reference
function rewatch_CreateButton(spellName, playerId, btnIcon, relative)
	-- build button
	local button = CreateFrame("BUTTON", nil, rewatch_bars[playerId]["Frame"], "SecureActionButtonTemplate");
	button:SetWidth(rewatch_loadInt["ButtonSize"]); button:SetHeight(rewatch_loadInt["ButtonSize"]);
	button:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", rewatch_loadInt["ButtonSize"]*rewatch_buttons[spellName]["Offset"], 0);
	-- arrange clicking
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	button:SetAttribute("unit", rewatch_bars[playerId]["Player"]); button:SetAttribute("type1", "spell"); button:SetAttribute("spell1", spellName);
	-- texture
	button:SetNormalTexture(btnIcon); button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9);
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp");
	-- apply modifier-click for nature's swiftness
	if(spellName == rewatch_loc["healingtouch"]) then
		button:SetAttribute("*type1", "macro"); button:SetAttribute("*macrotext1", "/stopcasting\n/cast "..rewatch_loc["naturesswiftness"].."\n/stopcasting\n/cast [target=mouseover] "..rewatch_loc["healingtouch"]);
		button:SetAttribute("type2", "macro"); button:SetAttribute("macrotext2", "/stopcasting\n/cast "..rewatch_loc["naturesswiftness"].."\n/stopcasting\n/cast [target=mouseover] "..rewatch_loc["healingtouch"]);
	elseif(spellName == rewatch_loc["removecorruption"]) then
		button:SetAlpha(0.2);
	elseif(spellName == rewatch_loc["naturescure"]) then
		button:SetAlpha(0.2);
	end;
	-- apply tooltip support
	button:SetScript("OnEnter", function() rewatch_SetTooltip(spellName); end);
	button:SetScript("OnLeave", function() GameTooltip:Hide(); end);

	-- return
	return button;
end;

-- create a spell bar with text and add it to the global player table
-- spellName: the name of the spell to create a bar for
-- playerId: the index number of the player in the player table
-- relative: the name of the rewatch_bars[n] key, referencing to the relative castbar for layout
-- return: the created spell bar reference
function rewatch_CreateBar(spellName, playerId, relative)
	-- create the bar
	local b = CreateFrame("STATUSBAR", spellName..playerId, rewatch_bars[playerId]["Frame"], "TextStatusBar");
	b:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	b:GetStatusBarTexture():SetHorizTile(false);
	b:GetStatusBarTexture():SetVertTile(false);
	
	-- arrange layout
	if(rewatch_loadInt["Layout"] == "horizontal") then
		b:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		b:SetHeight(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		b:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", 0, 0);
		b:SetOrientation("horizontal");
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		b:SetHeight(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		b:SetWidth(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		b:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "TOPRIGHT", 0, 0);
		b:SetOrientation("vertical");
	end;
	
	b:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
	
	-- set bar reach
	b:SetMinMaxValues(0, 10); b:SetValue(10);
	
	-- put text in bar
	b.text = b:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	b.text:SetPoint("RIGHT", b); b.text:SetAllPoints();
	if(rewatch_loadInt["Labels"] == 1) then b.text:SetText(spellName); else b.text:SetText(""); end;
	-- overlay cast button
	local bc = CreateFrame("BUTTON", nil, b, "SecureActionButtonTemplate");
	bc:SetWidth(b:GetWidth());
	bc:SetHeight(b:GetHeight());
	bc:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0);
	bc:RegisterForClicks("LeftButtonDown", "RightButtonDown"); bc:SetAttribute("type1", "spell"); bc:SetAttribute("unit", rewatch_bars[playerId]["Player"]);
	bc:SetAttribute("spell1", spellName); bc:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp"); bc:SetAlpha(0.2);
	--bc:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp");
	-- apply modifier-clicks for nature's swiftness on Regrowth bar only
	if(spellName == rewatch_loc["regrowth"]) then
		bc:SetAttribute("*type1", "macro"); bc:SetAttribute("*macrotext1", "/stopcasting\n/cast "..rewatch_loc["naturesswiftness"].."\n/stopcasting\n/cast [target=mouseover] "..rewatch_loc["regrowth"]);
		bc:SetAttribute("type2", "macro"); bc:SetAttribute("macrotext2", "/stopcasting\n/cast "..rewatch_loc["naturesswiftness"].."\n/stopcasting\n/cast [target=mouseover] "..rewatch_loc["regrowth"]);
	-- apply modifier-clicks for Rejuvenation bar for Genesis
	elseif(spellName == rewatch_loc["rejuvenation"]) then
		bc:SetAttribute("*type1", "macro"); bc:SetAttribute("*macrotext1", "/stopcasting\n/cast [target=mouseover] "..rewatch_loc["genesis"]);
		bc:SetAttribute("type2", "macro"); bc:SetAttribute("macrotext2", "/stopcasting\n/cast [target=mouseover] "..rewatch_loc["genesis"]);
	end;
	
	-- apply tooltip support
	bc:SetScript("OnEnter", function() rewatch_SetTooltip(spellName); end);
	bc:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	
	-- return the reference to the spell bar
	return b;
end;

-- update a bar by resetting spell duration
-- spellName: the name of the spell to reset it's duration from
-- player: player name
-- stacks: if given, the amount of LB stacks
-- return: void
function rewatch_UpdateBar(spellName, player, stacks)
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
	if(spellName == rewatch_loc["wildgrowth"]) then rewatch_bars[playerId]["RevertingWG"] = 0; end;
	
	-- if the spell exists
	if(rewatch_bars[playerId][spellName]) then
	
		-- get buff duration
		local a = select(7, UnitBuff(player, spellName, nil, "PLAYER"));
		if(a == nil) then return; end;
		local b = a - GetTime();
		
		-- update rejuvenation stack counter
		local c = "";
		if(spellName == rewatch_loc["rejuvenation"]) then
			if(not rewatch_bars[playerId]["RejuvenationStacks"]) then stacks = 1; end;
			if(stacks) then rewatch_bars[playerId]["RejuvenationStacks"] = stacks; end;
			c = rewatch_bars[playerId]["RejuvenationStacks"]; if(c <= 1) then c = ""; end;
		end;
		
		-- update bar
		rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName..c].r, rewatch_loadInt["BarColor"..spellName..c].g, rewatch_loadInt["BarColor"..spellName..c].b, rewatch_loadInt["BarColor"..spellName..c].a);
		
		-- set bar values
        rewatch_bars[playerId][spellName] = a;
		rewatch_bars[playerId][spellName.."Bar"]:SetMinMaxValues(0, b);
		rewatch_bars[playerId][spellName.."Bar"]:SetValue(b);
	end;
end;

-- clear a bar back to 0 because it's been dispelled or removed
-- spellName: the name of the spell to reset it's duration from
-- playerId: the index number of the player in the player table
-- return: void
function rewatch_DowndateBar(spellName, playerId)
	-- if the spell exists for this player
	if(rewatch_bars[playerId][spellName]) then
		-- ignore if it's WG and we have no WG bar
		if((spellName == rewatch_loc["wildgrowth"]) and (not rewatch_bars[playerId][spellName.."Bar"])) then return; end;
		
		-- reset bar values
		_, r = rewatch_bars[playerId][spellName.."Bar"]:GetMinMaxValues();
		rewatch_bars[playerId][spellName.."Bar"]:SetValue(r);
		rewatch_bars[playerId][spellName] = 0;
		if(rewatch_loadInt["Labels"] == 0) then rewatch_bars[playerId][spellName.."Bar"].text:SetText(""); end;
		
		-- check for wild growth overrides
		if(spellName == rewatch_loc["wildgrowth"] and GetSpellCooldown(rewatch_loc["wildgrowth"])) then
			if(rewatch_bars[playerId]["RevertingWG"] == 1) then
				rewatch_bars[playerId]["RevertingWG"] = 0;
				rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
			else
				rewatch_bars[playerId]["RevertingWG"] = 1;
				rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(0, 0, 0, 0.8);
				r, b = GetSpellCooldown(spellName)
				r = r + b; b = r - GetTime();
				rewatch_bars[playerId][spellName] = r;
				rewatch_bars[playerId][spellName.."Bar"]:SetMinMaxValues(0, b);
				rewatch_bars[playerId][spellName.."Bar"]:SetValue(b);
			end;
		-- reset rejuvenation stack counter
		elseif(spellName == rewatch_loc["rejuvenation"]) then
			rewatch_bars[playerId]["RejuvenationStacks"] = 0;
		end;
		
		rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
	end;
end;

-- add a player to the players table and create his bars and button
-- player: the name of the player
-- pet: if it's the pet of the named player ("pet" if so, nil if not)
-- return: the index number the player has been assigned
function rewatch_AddPlayer(player, pet)
	-- return if in combat or if the max amount of players is passed
	if((InCombatLockdown() == 1) or ((rewatch_loadInt["MaxPlayers"] > 0) and (rewatch_loadInt["MaxPlayers"] < rewatch_f:GetNumChildren()))) then return -1; end;
	
	-- process pets
	if(pet) then
		player = player.."-pet"; pet = UnitName(player);
		if(pet) then player = pet; end; pet = true;
	else pet = false; end;
	-- prepare table
	rewatch_bars[rewatch_i] = {};
	-- build frame
	local x, y = rewatch_GetFramePos(rewatch_f);
	local frame = CreateFrame("FRAME", nil, rewatch_f);
	frame:SetWidth(rewatch_loadInt["FrameWidth"] * (rewatch_loadInt["Scaling"]/100));
	frame:SetHeight(rewatch_loadInt["FrameHeight"] * (rewatch_loadInt["Scaling"]/100));
	frame:SetPoint("TOPLEFT", rewatch_f, "TOPLEFT", x, y); frame:EnableMouse(true); frame:SetMovable(true);
	frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	frame:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
	frame:SetScript("OnMouseDown", function() if(not rewatch_loadInt["LockP"]) then frame:StartMoving(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end; end);
	frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); rewatch_SnapToGrid(frame); end);

	-- build border frame
	local border = CreateFrame("FRAME", nil, frame);
	border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	border:SetBackdropBorderColor(0, 0, 0, 1);
	border:SetFrameStrata("HIGH");
	border:SetWidth((rewatch_loadInt["FrameWidth"] * (rewatch_loadInt["Scaling"]/100))+2);
	border:SetHeight((rewatch_loadInt["FrameHeight"] * (rewatch_loadInt["Scaling"]/100))+2);
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1);
	
	-- create player HP bar for estimated incoming health
	local statusbarinc = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	if(rewatch_loadInt["Layout"] == "horizontal") then
		statusbarinc:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		statusbarinc:SetHeight((rewatch_loadInt["HealthBarHeight"]-4) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		statusbarinc:SetHeight(((rewatch_loadInt["SpellBarWidth"]-4) * (rewatch_loadInt["Scaling"]/100)) -(rewatch_loadInt["ShowButtons"]*rewatch_loadInt["ButtonSize"]));
		statusbarinc:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
	end;
	statusbarinc:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	statusbarinc:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbarinc:GetStatusBarTexture():SetHorizTile(false);
	statusbarinc:GetStatusBarTexture():SetVertTile(false);
	statusbarinc:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 0.4);
	statusbarinc:SetFrameStrata("LOW");
	statusbarinc:SetMinMaxValues(0, 1); statusbarinc:SetValue(0);
		
	-- create player HP bar
	local statusbar = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	if(rewatch_loadInt["Layout"] == "horizontal") then
		statusbar:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		statusbar:SetHeight((rewatch_loadInt["HealthBarHeight"]-4) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		statusbar:SetHeight(((rewatch_loadInt["SpellBarWidth"]-4) * (rewatch_loadInt["Scaling"]/100)) -(rewatch_loadInt["ShowButtons"]*rewatch_loadInt["ButtonSize"]));
		statusbar:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
	end;
	statusbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	statusbar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbar:GetStatusBarTexture():SetHorizTile(false);
	statusbar:GetStatusBarTexture():SetVertTile(false);
	statusbar:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 1);
	statusbar:SetMinMaxValues(0, 1); statusbar:SetValue(0);
	
	-- determine class
	local classID, class, classColors;
	if(UnitName("player") == player) then classID = 11; else classID = select(3, UnitClass(player)); end;
	if(classID ~= nil) then
		_, class = GetClassInfo(classID);
		classColors = RAID_CLASS_COLORS[class];
	else
		classColors = {r=0,g=0,b=0}
	end;
	
	-- put text in HP bar
	statusbar.text = statusbar:CreateFontString("$parentText", "ARTWORK");
	statusbar.text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"], "OUTLINE");
	statusbar.text:SetAllPoints(); statusbar.text:SetText(rewatch_CutName(player));
	-- class-color it
	statusbar.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1);
	
	-- role icon
	local roleIcon = statusbar:CreateTexture(nil, "OVERLAY");
	local role = UnitGroupRolesAssigned(player);
	roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES");
	roleIcon:SetSize(16, 16);
	roleIcon:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 2, -2);
	
	if(role == "TANK") then
		roleIcon:SetTexCoord(0, 19/64, 22/64, 41/64);
		roleIcon:Show();
	elseif(role == "HEALER") then
		roleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		roleIcon:Show();
	else
		roleIcon:Hide();
	end;
	
	-- energy/mana/rage bar
	local statusbar2 = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	if(rewatch_loadInt["Layout"] == "horizontal") then statusbar2:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then statusbar2:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100)); end;
	statusbar2:SetHeight(4 * (rewatch_loadInt["Scaling"]/100));
	statusbar2:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, 0);
	statusbar2:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbar2:GetStatusBarTexture():SetHorizTile(false);
	statusbar2:GetStatusBarTexture():SetVertTile(false);
	statusbar2:SetMinMaxValues(0, 1); statusbar2:SetValue(0);
	-- color it correctly
	local pt = PowerBarColor[UnitPowerType(player)];
	statusbar2:SetStatusBarColor(pt.r, pt.g, pt.b);
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
	-- save player data
	rewatch_bars[rewatch_i]["UnitGUID"] = nil; if(UnitExists(player)) then rewatch_bars[rewatch_i]["UnitGUID"] = UnitGUID(player); end;
	rewatch_bars[rewatch_i]["Frame"] = frame; rewatch_bars[rewatch_i]["Player"] = player;
	rewatch_bars[rewatch_i]["PlayerBarInc"] = statusbarinc;
	rewatch_bars[rewatch_i]["Border"] = border;
	rewatch_bars[rewatch_i]["PlayerBar"] = statusbar;
	rewatch_bars[rewatch_i]["ManaBar"] = statusbar2;
	rewatch_bars[rewatch_i]["Mark"] = false; rewatch_bars[rewatch_i]["Pet"] = pet;
	rewatch_bars[rewatch_i][rewatch_loc["lifebloom"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation"]] = 0; rewatch_bars[rewatch_i]["RejuvenationStacks"] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["regrowth"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["wildgrowth"]] = 0;
	if(rewatch_loadInt["Layout"] == "horizontal") then
		rewatch_bars[rewatch_i][rewatch_loc["lifebloom"].."Bar"] = rewatch_CreateBar(rewatch_loc["lifebloom"], rewatch_i, "ManaBar");
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		rewatch_bars[rewatch_i][rewatch_loc["lifebloom"].."Bar"] = rewatch_CreateBar(rewatch_loc["lifebloom"], rewatch_i, "PlayerBar");
	end;
	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation"].."Bar"] = rewatch_CreateBar(rewatch_loc["rejuvenation"], rewatch_i, rewatch_loc["lifebloom"].."Bar");
	rewatch_bars[rewatch_i][rewatch_loc["regrowth"].."Bar"] = rewatch_CreateBar(rewatch_loc["regrowth"], rewatch_i, rewatch_loc["rejuvenation"].."Bar");
	pt = rewatch_loc["regrowth"].."Bar";
	if(rewatch_loadInt["WildGrowth"] == 1) then
		pt = rewatch_loc["wildgrowth"].."Bar";
		rewatch_bars[rewatch_i][rewatch_loc["wildgrowth"].."Bar"] = rewatch_CreateBar(rewatch_loc["wildgrowth"], rewatch_i, rewatch_loc["regrowth"].."Bar");
	end;
	-- layout
	if(rewatch_loadInt["Layout"] == "vertical") then pt = "ManaBar"; end;
	-- buttons
	if(rewatch_loadInt["ShowButtons"] == 1) then
		rewatch_bars[rewatch_i]["SwiftmendButton"] = rewatch_CreateButton(rewatch_loc["swiftmend"], rewatch_i, "Interface\\Icons\\INV_Relics_IdolofRejuvenation.blp", pt);
			local smbcd = CreateFrame("Cooldown", "SwiftmendButtonCD"..rewatch_i, rewatch_bars[rewatch_i]["SwiftmendButton"], "CooldownFrameTemplate");
			rewatch_bars[rewatch_i]["SwiftmendButton"].cooldown = smbcd; smbcd:SetPoint("CENTER", 0, -1);
			smbcd:SetWidth(rewatch_bars[rewatch_i]["SwiftmendButton"]:GetWidth()); smbcd:SetHeight(rewatch_bars[rewatch_i]["SwiftmendButton"]:GetHeight()); smbcd:Hide();
		--Formerly Remove Corruption - Remove Corruption/Nature's Cure
			if(rewatch_loadInt["InRestoSpec"]) then
				rewatch_bars[rewatch_i]["RemoveCorruptionButton"] = rewatch_CreateButton(rewatch_loc["naturescure"], rewatch_i, "Interface\\Icons\\ability_shaman_cleansespirit.blp", pt);
			else
				rewatch_bars[rewatch_i]["RemoveCorruptionButton"] = rewatch_CreateButton(rewatch_loc["removecorruption"], rewatch_i, "Interface\\Icons\\Spell_Shadow_Curse.blp", pt);
			end;
			local rccd = CreateFrame("Cooldown", "RemoveCorruptionButtonCD"..rewatch_i, rewatch_bars[rewatch_i]["RemoveCorruptionButton"], "CooldownFrameTemplate");
			rewatch_bars[rewatch_i]["RemoveCorruptionButton"].cooldown = rccd; rccd:SetPoint("CENTER", 0, -1);
			rccd:SetWidth(rewatch_bars[rewatch_i]["RemoveCorruptionButton"]:GetWidth()); rccd:SetHeight(rewatch_bars[rewatch_i]["RemoveCorruptionButton"]:GetHeight()); rccd:Hide();
		--Formerly Thorns - Ironbark/Barkskin
			if(rewatch_loadInt["InRestoSpec"]) then
				rewatch_bars[rewatch_i]["ThornsButton"] = rewatch_CreateButton(rewatch_loc["ironbark"], rewatch_i, "Interface\\Icons\\Spell_druid_ironbark.blp", pt);
			else
				rewatch_bars[rewatch_i]["ThornsButton"] = rewatch_CreateButton(rewatch_loc["barkskin"], rewatch_i, "Interface\\Icons\\spell_nature_stoneclawtotem.blp", pt);
			end;
			local tbcd = CreateFrame("Cooldown", "ThornsButtonCD"..rewatch_i, rewatch_bars[rewatch_i]["ThornsButton"], "CooldownFrameTemplate");
			rewatch_bars[rewatch_i]["ThornsButton"].cooldown = tbcd; tbcd:SetPoint("CENTER", 0, -1);
			tbcd:SetWidth(rewatch_bars[rewatch_i]["ThornsButton"]:GetWidth()); tbcd:SetHeight(rewatch_bars[rewatch_i]["ThornsButton"]:GetHeight()); tbcd:Hide();
		rewatch_bars[rewatch_i]["HealingTouchButton"] = rewatch_CreateButton(rewatch_loc["healingtouch"], rewatch_i, "Interface\\Icons\\Spell_Nature_HealingTouch.blp", pt);
			local htbcd = CreateFrame("Cooldown", "HealingTouchButtonCD"..rewatch_i, rewatch_bars[rewatch_i]["HealingTouchButton"], "CooldownFrameTemplate");
			rewatch_bars[rewatch_i]["HealingTouchButton"].cooldown = htbcd; htbcd:SetPoint("CENTER", 0, -1);
			htbcd:SetWidth(rewatch_bars[rewatch_i]["HealingTouchButton"]:GetWidth()); htbcd:SetHeight(rewatch_bars[rewatch_i]["HealingTouchButton"]:GetHeight()); htbcd:Hide();
		rewatch_bars[rewatch_i]["MushroomButton"] = rewatch_CreateButton(rewatch_loc["mushroom"], rewatch_i, "Interface\\Icons\\druid_ability_wildmushroom_a.blp", pt);
			local nrbcd = CreateFrame("Cooldown", "MushroomButtonCD"..rewatch_i, rewatch_bars[rewatch_i]["MushroomButton"], "CooldownFrameTemplate");
			rewatch_bars[rewatch_i]["MushroomButton"].cooldown = nrbcd; nrbcd:SetPoint("CENTER", 0, -1);
			nrbcd:SetWidth(rewatch_bars[rewatch_i]["MushroomButton"]:GetWidth()); nrbcd:SetHeight(rewatch_bars[rewatch_i]["MushroomButton"]:GetHeight()); nrbcd:Hide();
	end;
	rewatch_bars[rewatch_i]["Notify"] = nil; rewatch_bars[rewatch_i]["Notify2"] = nil; rewatch_bars[rewatch_i]["Notify3"] = nil;
	rewatch_bars[rewatch_i]["Corruption"] = nil; rewatch_bars[rewatch_i]["Class"] = class; rewatch_bars[rewatch_i]["Hover"] = 0;
	rewatch_bars[rewatch_i]["RevertingWG"] = 0;
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
	if(InCombatLockdown() == 1) then rewatch_Message(rewatch_loc["combatfailed"]);
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
	if(InCombatLockdown() == 1) then return; end;
	
	-- remove the bar
	local parent = rewatch_bars[playerId]["Frame"]:GetParent();
	rewatch_bars[playerId]["PlayerBar"]:Hide();
	rewatch_bars[playerId]["PlayerBarInc"]:Hide();
	rewatch_bars[playerId][rewatch_loc["lifebloom"].."Bar"]:Hide();
	rewatch_bars[playerId][rewatch_loc["rejuvenation"].."Bar"]:Hide();
	if(rewatch_bars[playerId][rewatch_loc["wildgrowth"].."Bar"]) then
			rewatch_bars[playerId][rewatch_loc["wildgrowth"].."Bar"]:Hide();
	end;
	rewatch_bars[playerId][rewatch_loc["regrowth"].."Bar"]:Hide();
	if(rewatch_bars[playerId]["SwiftmendButton"]) then rewatch_bars[playerId]["SwiftmendButton"]:Hide(); end;
	if(rewatch_bars[playerId]["ThornsButton"]) then rewatch_bars[playerId]["ThornsButton"]:Hide(); end;
	if(rewatch_bars[playerId]["RemoveCorruptionButton"]) then rewatch_bars[playerId]["RemoveCorruptionButton"]:Hide(); end;
	if(rewatch_bars[playerId]["HealingTouchButton"]) then rewatch_bars[playerId]["HealingTouchButton"]:Hide(); end;
	if(rewatch_bars[playerId]["MushroomButton"]) then rewatch_bars[playerId]["MushroomButton"]:Hide(); end;
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

-- build a frame
-- return: void
function rewatch_BuildFrame()
	-- create it
	rewatch_f = CreateFrame("FRAME", "Rewatch_Frame", UIParent);
	-- set proper dimentions and location
	rewatch_f:SetWidth(100); rewatch_f:SetHeight(100); rewatch_f:SetPoint("CENTER", UIParent);
	rewatch_f:EnableMouse(true); rewatch_f:SetMovable(true);
	-- set looks
	rewatch_f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
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
		-- declaration and initialisation
		local pos, commands = 0, {};
		for st, sp in function() return string.find(cmd, " ", pos, true) end do
			table.insert(commands, string.sub(cmd, pos, st-1));
			pos = sp + 1;
		end; table.insert(commands, string.sub(cmd, pos));
		-- on a help request, reply with the localisation help table
		if(string.lower(commands[1]) == "help") then
			for _,val in ipairs(rewatch_loc["help"]) do
				rewatch_Message(val);
			end;
		-- if the user wants to add a player manually
		elseif(string.lower(commands[1]) == "add") then
			if(InCombatLockdown() == 1) then rewatch_Message(rewatch_loc["combatfailed"]);
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
				if(InCombatLockdown() == 1) then rewatch_Message(rewatch_loc["combatfailed"]);
				else
					rewatch_Clear();
					rewatch_changed = true;
					rewatch_Message(rewatch_loc["sorted"]);
				end;
			end;
		-- if the user wants to clear the player list
		elseif(string.lower(commands[1]) == "clear") then
			if(InCombatLockdown() == 1) then rewatch_Message(rewatch_loc["combatfailed"]);
			else rewatch_Clear(); rewatch_Message(rewatch_loc["cleared"]); end;
		-- allow setting the forced height
		elseif(string.lower(commands[1]) == "forcedheight") then
			if(tonumber(commands[2])) then
				rewatch_loadInt["ForcedHeight"] = tonumber(commands[2]); rewatch_load["ForcedHeight"] = rewatch_loadInt["ForcedHeight"];
				rewatch_loadInt["NumFramesWide"] = rewatch_load["NumFramesWide"];
				rewatch_Message("Forced height to "..rewatch_load["ForcedHeight"]..". Set to 0 to set to autosizing."); rewatch_AlterFrame();
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

--------------------------------------------------------------------------------------------------------------[ SCRIPT ]-------------------------

-- make the addon stop here if the user isn't a druid (classID 11)
if((select(3, UnitClass("player"))) ~= 11) then return; end;

-- build event logger
rewatch_events = CreateFrame("FRAME", nil, UIParent); rewatch_events:SetWidth(0); rewatch_events:SetHeight(0);
rewatch_events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"); rewatch_events:RegisterEvent("GROUP_ROSTER_UPDATE");
rewatch_events:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE"); rewatch_events:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
rewatch_events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED"); rewatch_events:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
rewatch_events:RegisterEvent("UNIT_HEAL_PREDICTION"); rewatch_events:RegisterEvent("PLAYER_ROLES_ASSIGNED");

-- initialise all vars
rewatch_changedDimentions = false;
rewatch_f = nil;
rewatch_gcd = nil;
rewatch_bars = {};
rewatch_buttons = {};
rewatch_rightClickMenuTable = {};
rewatch_loadInt = {};
rewatch_i = 1;
rewatch_dropDown = nil;
rewatch_changed = false;
rewatch_options = nil;
rewatch_rezzing = "";

-- define buttons
rewatch_buttons = {
	[rewatch_loc["swiftmend"]] = {
		Offset = 0;
	};
	[rewatch_loc["naturescure"]] = {
		Offset = 1;
	};
	[rewatch_loc["removecorruption"]] = {
		Offset = 1;
	};
	[rewatch_loc["ironbark"]] = {
		Offset = 2;
	};
	[rewatch_loc["barkskin"]] = {
		Offset = 2;
	};
	[rewatch_loc["healingtouch"]] = {
		Offset = 3;
	};
	[rewatch_loc["mushroom"]] = {
		Offset = 4;
	};
};

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
local playerId;
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
					rewatch_bars[playerId]["Notify"] = nil; rewatch_bars[playerId]["Notify2"] = nil;
					rewatch_bars[playerId]["Notify3"] = nil; rewatch_bars[playerId]["Corruption"] = nil;
					if(rewatch_bars[playerId]["RemoveCorruptionButton"]) then rewatch_bars[playerId]["RemoveCorruptionButton"]:SetAlpha(0.2); end;
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
local r, g, b, a, val, left, i, debuffType, currentTarget;
rewatch_events:SetScript("OnEvent", function(timestamp, event, unitGUID, effect, _, meGUID, _, _, _, _, targetName, _, _, _, spell, _, school, stacks)
	--print("event ",timestamp,event,unitGUID,effect,meGUID,targetName,spell,school,stacks);
	-- only process if properly loaded
	if(not rewatch_loadInt["Loaded"]) then
		return;
	-- switched talent/dual spec
	elseif((event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "ACTIVE_TALENT_GROUP_CHANGED")) then
		if(GetSpecialization() == 4) then rewatch_loadInt["InRestoSpec"] = true;
		else rewatch_loadInt["InRestoSpec"] = false; end;
		rewatch_loadInt["HasBlooming"] = false;
		for i=1, NUM_GLYPH_SLOTS do
			if(select(6, GetGlyphSocketInfo(i)) == 434) then rewatch_loadInt["HasBlooming"] = true; end;
		end;
		if(InCombatLockdown() == 1) then rewatch_Message(rewatch_loc["combatfailed"]);
		else rewatch_Clear(); end;
		rewatch_changed = true;
	-- party changed
	elseif(event == "GROUP_ROSTER_UPDATE") then		
		if(InCombatLockdown() ~= 1) then
			rewatch_changed = true;
		end;
	-- update threat
	elseif(event == "UNIT_THREAT_SITUATION_UPDATE") then
		if(unitGUID) then
			playerId = rewatch_GetPlayer(UnitName(unitGUID));
			if(playerId < 0) then return; end;
			val = rewatch_bars[playerId];
			if(val["UnitGUID"]) then
				a = UnitThreatSituation(val["Player"]);
				if(a == nil or a == 0) then val["Border"]:SetBackdropBorderColor(0, 0, 0, 1); val["Border"]:SetFrameStrata("HIGH");
				else r, g, b = GetThreatStatusColor(a); val["Border"]:SetBackdropBorderColor(r, g, b, 1); val["Border"]:SetFrameStrata("DIALOG"); end;
			end;
		end;
	-- changed role
	elseif(event == "PLAYER_ROLES_ASSIGNED") then
		if(unitGUID) then
			playerId = rewatch_GetPlayer(UnitName(unitGUID));
			if(playerId < 0) then return; end;
			val = rewatch_bars[playerId];
			if(val["UnitGUID"]) then
				local role = UnitGroupRolesAssigned(UnitName(unitGUID));
				if(role == "TANK") then roleIcon:SetTexture("Interface\\AddOns\\Rewatch\\Textures\\tank.tga"); roleIcon:Show();
				elseif(role == "HEALER") then roleIcon:SetTexture("Interface\\AddOns\\Rewatch\\Textures\\healer.tga"); roleIcon:Show();
				else roleIcon:Hide(); end;
			end;
		end;
	-- buff applied/refreshed
	elseif((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
		-- quick bug-fix for 4.0 REFRESH retriggering for every WG tick
		if((effect == "SPELL_AURA_REFRESH") and (spell == rewatch_loc["wildgrowth"])) then
			return;
		--  ignore heals on non-party-/raidmembers
		elseif(not rewatch_InGroup(targetName)) then
			return;
		-- if it was a HoT being applied
		elseif((meGUID == UnitGUID("player")) and (((spell == rewatch_loc["wildgrowth"]) and (rewatch_loadInt["WildGrowth"] == 1)) or (spell == rewatch_loc["regrowth"]) or (spell == rewatch_loc["rejuvenation"]) or (spell == rewatch_loc["lifebloom"]))) then
			-- bugfix Reju stack event
			if((not stacks) and (effect == "SPELL_AURA_APPLIED")) then stacks = 1; end;
			-- update the spellbar
			rewatch_UpdateBar(spell, targetName, stacks);
		-- if it's innervate that we cast, report
		elseif((meGUID == UnitGUID("player")) and (spell == rewatch_loc["innervate"]) and (targetName ~= UnitName("player"))) then
			SendChatMessage("Innervating "..targetName.."!", "SAY");
		-- if it's a spell that needs custom highlighting, notify by highlighting player frame	
		elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting", "Notify")) then
		elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting2", "Notify2")) then
		elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting3", "Notify3")) then
			-- ignore further, already processed it		
		-- else, if it was a debuff applied
		elseif(school == "DEBUFF") then
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			-- get the debuff type
			_, _, _, _, debuffType = UnitDebuff(targetName, spell);
			-- process it
			if((debuffType == "Curse") or (debuffType == "Poison") or (debuffType == "Magic" and rewatch_loadInt["InRestoSpec"])) then
				rewatch_bars[playerId]["Corruption"] = spell; rewatch_bars[playerId]["CorruptionType"] = debuffType;
				--local SpStart, SpDuration    --Time since cooldown began, duration of cooldown.. 0 for both is ok to cast
				--if(rewatch_loadInt["InRestoSpec"]) then SpStart, SpDuration = GetSpellCooldown(rewatch_loc["naturescure"])
				--	else SpStart, SpDuration = GetSpellCooldown(rewatch_loc["removecorruption"]); end;
				--if(rewatch_bars[playerId]["RemoveCorruptionButton"] and SpStart == 0 and SpDuration <= 1.5) then rewatch_bars[playerId]["RemoveCorruptionButton"]:SetAlpha(1); end;
				if(rewatch_loadInt["ShowButtons"] == 1) then
					rewatch_bars[playerId]["RemoveCorruptionButton"]:SetAlpha(1);
				end;
				rewatch_SetFrameBG(playerId);
			end;
		-- else, if it was a bear/cat shapeshift
		elseif((spell == rewatch_loc["bearForm"]) or (spell == rewatch_loc["direBearForm"]) or (spell == rewatch_loc["catForm"])) then
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			-- if it was cat, make it yellow
			if(spell == rewatch_loc["catForm"]) then
				rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(PowerBarColor["ENERGY"].r, PowerBarColor["ENERGY"],g, PowerBarColor["ENERGY"].b, 1);
			-- else, it was bear form, make it red
			else
				rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(PowerBarColor["RAGE"].r, PowerBarColor["RAGE"].g, PowerBarColor["RAGE"].b, 1);
			end;
		-- else, if it was Clearcasting being applied to us
		elseif((spell == rewatch_loc["clearcasting"])) then
			rewatch_f:SetBackdropColor(0.49, 1, 0.04, 1);
		-- else, if it was ironbark/barkskin
		elseif((meGUID == UnitGUID("player")) and ((spell == rewatch_loc["ironbark"]) or (spell == rewatch_loc["barkskin"]))) then
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			-- update cooldown pie
			for i=1,rewatch_i-1 do val = rewatch_bars[i]; if(val) then
				if(val["ThornsButton"]) then
					val["ThornsButton"].doUpdate = true;
					val["ThornsButton"].spellName = spell;
				else break end;
			end; end;
		end;
	-- if an aura faded
	elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then
		--  ignore non-party-/raidmembers
		if(not rewatch_InGroup(targetName)) then return; end;
		-- get the player position
		playerId = rewatch_GetPlayer(targetName);
		-- if it doesn't exists, stop
		if(playerId < 0) then -- nuffin!
		-- or, if a HoT runs out / has been dispelled, process it
		elseif((meGUID == UnitGUID("player")) and ((spell == rewatch_loc["regrowth"]) or (spell == rewatch_loc["rejuvenation"]) or (spell == rewatch_loc["lifebloom"]) or (spell == rewatch_loc["wildgrowth"]))) then
			rewatch_DowndateBar(spell, playerId);
		-- else, if Clearcasting ends
		elseif((spell == rewatch_loc["clearcasting"])) then
			rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0);
		-- or, process nature's swiftness CD pie on HT button
		elseif(rewatch_loc["naturesswiftness"] == spell) then
			for i=1,rewatch_i-1 do val = rewatch_bars[i]; if(val) then
				if(val["HealingTouchButton"]) then
					val["HealingTouchButton"].doUpdate = true;
				else break end;
			end; end;
		-- or, process it if it is the applied corruption or something else to be notified about
		elseif(rewatch_bars[playerId]["Corruption"] == spell) then
			rewatch_bars[playerId]["Corruption"] = nil; if(rewatch_bars[playerId]["RemoveCorruptionButton"]) then rewatch_bars[playerId]["RemoveCorruptionButton"]:SetAlpha(0.2); end; rewatch_SetFrameBG(playerId);
		elseif(rewatch_bars[playerId]["Notify"] == spell) then
			rewatch_bars[playerId]["Notify"] = nil; rewatch_SetFrameBG(playerId);
		elseif(rewatch_bars[playerId]["Notify2"] == spell) then
			rewatch_bars[playerId]["Notify2"] = nil; rewatch_SetFrameBG(playerId);
		elseif(rewatch_bars[playerId]["Notify3"] == spell) then
			rewatch_bars[playerId]["Notify3"] = nil; rewatch_SetFrameBG(playerId);
		-- else, if it was a bear/cat shapeshift
		elseif((spell == rewatch_loc["bearForm"]) or (spell == rewatch_loc["direBearForm"]) or (spell == rewatch_loc["catForm"])) then
			rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(PowerBarColor["MANA"].r, PowerBarColor["MANA"].g, PowerBarColor["MANA"].b, 1);
		end;
	-- if an other spell was cast successfull by the user or a heal has been received
	elseif((effect == "SPELL_CAST_SUCCESS") or (effect == "SPELL_HEAL")) then
		-- if it was your spell/heal
		if(meGUID == UnitGUID("player")) then
			rewatch_TriggerCooldown();
			-- if it is genesis
			if((spell == rewatch_loc["genesis"]) and (effect == "SPELL_CAST_SUCCESS")) then
				-- loop through all party members and update Rejuvenation bar
				for i=1,rewatch_i-1 do val = rewatch_bars[i]; if(val) then
					if(val[rewatch_loc["rejuvenation"]]) then
						rewatch_UpdateBar(rewatch_loc["rejuvenation"], val["Player"], nil);
					end;
				end; end;
			-- if a swiftmend was received
			elseif((spell == rewatch_loc["swiftmend"]) and (effect == "SPELL_HEAL")) then
				--  ignore heals on non-party-/raidmembers
				if(not rewatch_InGroup(targetName)) then return; end;
				-- trigger all cooldown overlays of every player's swiftmend button
				if(rewatch_loadInt["ShowButtons"] == 1) then
					for i=1,rewatch_i-1 do val = rewatch_bars[i]; if(val) then
						if(val["SwiftmendButton"]) then
							val["SwiftmendButton"].doUpdate = true;
						else break end;
					end; end;
				end;
			-- fix bug where the 3rd stack refresh of Reju doesn't trigger SPELL_AURA_REFRESH
			elseif((spell == rewatch_loc["rejuvenation"]) and rewatch_InGroup(targetName) and (effect == "SPELL_CAST_SUCCESS")) then
				rewatch_UpdateBar(rewatch_loc["rejuvenation"], targetName, nil);
			-- resolves refresh of Reju by a big heal (when not has blooming)
			elseif(((spell == rewatch_loc["regrowth"]) or (spell == rewatch_loc["healingtouch"]) or (spell == rewatch_loc["nourish"])) and not rewatch_loadInt["HasBlooming"] and rewatch_InGroup(targetName) and (effect == "SPELL_CAST_SUCCESS")) then
				rewatch_UpdateBar(rewatch_loc["rejuvenation"], targetName, nil);
			end;
		end;
	-- if target was dispelled/cleansed by me
	elseif((effect == "SPELL_DISPEL") and meGUID == UnitGUID("player") and ((spell == rewatch_loc["removecorruption"]) or (spell == rewatch_loc["naturescure"]))) then
		rewatch_TriggerCooldown();
		if(rewatch_loadInt["ShowButtons"] == 1) then
			for i=1,rewatch_i-1 do val = rewatch_bars[i]; if(val) then
				if(val["RemoveCorruptionButton"]) then
					val["RemoveCorruptionButton"].doUpdate = true;
					val["RemoveCorruptionButton"].spellName = spell;
				else break end;
			end; end;
		end;
	-- if we started casting Rebirth or Revive, check if we need to report
	elseif((effect == "SPELL_CAST_START") and ((spell == rewatch_loc["rebirth"]) or (spell == rewatch_loc["revive"])) and (meGUID == UnitGUID("player"))) then
		if(not rewatch_rezzing) then rewatch_rezzing = ""; end;
		if(UnitIsDeadOrGhost(rewatch_rezzing)) then
			SendChatMessage("Rezzing "..rewatch_rezzing.."!", "SAY");
			rewatch_rezzing = "";
		end;
	-- if it's a Rebirth cast
	elseif((effect == "SPELL_RESURRECT") and (spell == rewatch_loc["rebirth"]) and (meGUID == UnitGUID("player"))) then
		rewatch_TriggerCooldown();
		if(rewatch_loadInt["ShowButtons"] == 1) then
			for i=1,rewatch_i-1 do val = rewatch_bars[i]; if(val) then
				if(val["MushroomButton"]) then
					val["MushroomButton"].doUpdate = true;
				else break end;
			end; end;
		end;
	end;
end);

-- update everything
rewatch_events:SetScript("OnUpdate", function()
	-- load saved vars
	if(not rewatch_loadInt["Loaded"]) then
		rewatch_OnLoad();
	else
		-- if the group formation has been changed, add new group members to the list
		if(rewatch_changed) then
			if(rewatch_loadInt["AutoGroup"] == 1) then
				if(InCombatLockdown() ~= 1) then
					--if((GetNumGroupMembers() == 0) and (GetNumSubgroupMembers() == 0)) then rewatch_Clear(); end;
					if((GetNumGroupMembers() == 0 and IsInRaid()) or (GetNumSubgroupMembers() == 0 and not IsInRaid())) then rewatch_Clear(); end;
					rewatch_ProcessGroup(); rewatch_changed = nil;
				end;
			end;
		end;
		-- get current target
		currentTarget = UnitGUID("target");
		-- process updates
		for i=1,rewatch_i-1 do val = rewatch_bars[i];
			-- if this player exists
			if(val) then
				-- make targetted unit have highlighted font
				a = UnitGUID(val["Player"]);
				if(currentTarget and (not val["Highlighted"]) and (a == currentTarget)) then
					val["Highlighted"] = true;
					val["PlayerBar"].text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["HighlightSize"], "THICKOUTLINE");
				elseif((val["Highlighted"]) and (a ~= currentTarget)) then
					val["Highlighted"] = false;
					val["PlayerBar"].text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"], "OUTLINE");
				end;
				-- clear buffs if the player just died
				if(UnitIsDeadOrGhost(val["Player"])) then
					if(select(4, val["PlayerBar"]:GetStatusBarColor()) > 0.6) then
						val["PlayerBar"]:SetStatusBarColor(0.5, 0.5, 0.5, 0.5);
						val["ManaBar"]:SetValue(0); val["PlayerBar"]:SetValue(0);
						if(val["Mark"]) then
							val["Frame"]:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
						else
							val["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
						end;
						val["RejuvenationStacks"] = 0;
						val["PlayerBar"].text:SetText(rewatch_CutName(val["Player"]));
						rewatch_DowndateBar(rewatch_loc["lifebloom"], i);
						rewatch_DowndateBar(rewatch_loc["rejuvenation"], i);
						rewatch_DowndateBar(rewatch_loc["regrowth"], i);
						rewatch_DowndateBar(rewatch_loc["wildgrowth"], i);
						val["Notify"] = nil; val["Notify2"] = nil; val["Notify3"] = nil;
						val["Corruption"] = nil; val["Frame"]:SetAlpha(0.2);
						if(val["RemoveCorruptionButton"]) then val["RemoveCorruptionButton"]:SetAlpha(0.2); end;
					end;
					-- else, unit's dead and processed, ignore him now
				else
					-- get and set health data
					a, b = UnitHealthMax(val["Player"]), UnitHealth(val["Player"]);
					val["PlayerBar"]:SetMinMaxValues(0, a); val["PlayerBar"]:SetValue(b);
					-- set predicted heals
					if(rewatch_loadInt["ShowIncomingHeals"] == 1) then
						local c = 0;
						if(UnitGetIncomingHeals(val["Player"])) then
							c = UnitGetIncomingHeals(val["Player"]);
						end;
						val["PlayerBarInc"]:SetMinMaxValues(0, a);
						if(a>b+c) then
							val["PlayerBarInc"]:SetValue(b+c);
						else
							val["PlayerBarInc"]:SetValue(a);
						end;
					end;
					-- set healthbar color accordingly
					if(a == b) then val["PlayerBar"]:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 1);
					elseif(b/a < .25) then val["PlayerBar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1);
					elseif(b/a < .50) then val["PlayerBar"]:SetStatusBarColor(0.6, 0.6, 0.0, 1);
					else val["PlayerBar"]:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 0.8); end;
					-- update text if needed
					if(rewatch_loadInt["HealthDeficit"] == 1) then
						g = rewatch_CutName(val["Player"]); if(val["Hover"] == 1) then g = string.format("%i/%i", b, a); elseif(val["Hover"] == 2) then val["Hover"] = 0; end;
						if((val["Hover"] == 0) and (b < (rewatch_loadInt["DeficitThreshold"]*1000))) then
							g = g.."\n"..string.format("%#.1f", b/1000).."k";
						end;
						val["PlayerBar"].text:SetText(g);
					else
						if(val["Hover"] == 1) then val["PlayerBar"].text:SetText(string.format("%i/%i", b, a));
						elseif(val["Hover"] == 2) then val["PlayerBar"].text:SetText(rewatch_CutName(val["Player"])); val["Hover"] = 0;
						end;
					end;
					-- get and set mana data
					a, b = UnitPowerMax(val["Player"]), UnitPower(val["Player"]);
					val["ManaBar"]:SetMinMaxValues(0, a); val["ManaBar"]:SetValue(b);
					-- fade when out of range
					if(IsSpellInRange(rewatch_loc["rejuvenation"], val["Player"]) == 1) then val["Frame"]:SetAlpha(1); else val["Frame"]:SetAlpha(rewatch_loadInt["OORAlpha"]); end;
					-- current time
					a = GetTime();
					-- update cooldown layers
					if(val["MushroomButton"] and val["MushroomButton"].doUpdate == true) then
						CooldownFrame_SetTimer(val["MushroomButton"].cooldown, GetSpellCooldown(rewatch_loc["rebirth"]));
						val["MushroomButton"].doUpdate = false;
					end;
					if(val["RemoveCorruptionButton"] and val["RemoveCorruptionButton"].doUpdate == true) then
						CooldownFrame_SetTimer(val["RemoveCorruptionButton"].cooldown, GetSpellCooldown(val["RemoveCorruptionButton"].spellName));
						val["RemoveCorruptionButton"].doUpdate = false;
						val["RemoveCorruptionButton"].spellName = nil;
					end;
					if(val["SwiftmendButton"] and val["SwiftmendButton"].doUpdate == true) then
						CooldownFrame_SetTimer(val["SwiftmendButton"].cooldown, GetSpellCooldown(rewatch_loc["swiftmend"]));
						val["SwiftmendButton"].doUpdate = false;
					end;
					if(val["ThornsButton"] and val["ThornsButton"].doUpdate == true) then
						CooldownFrame_SetTimer(val["ThornsButton"].cooldown, GetSpellCooldown(val["ThornsButton"].spellName));
						val["ThornsButton"].doUpdate = false;
						val["ThornsButton"].spellName = nil;
					end;
					-- rejuvenation bar process
					if(rewatch_bars[i][rewatch_loc["rejuvenation"]] > 0) then
						left = val[rewatch_loc["rejuvenation"]]-a;
						if(left > 0) then
							val[rewatch_loc["rejuvenation"].."Bar"]:SetValue(left);
							if(rewatch_loadInt["Labels"] == 0) then val[rewatch_loc["rejuvenation"].."Bar"].text:SetText(string.format("%.00f", left)); end;
							if(math.abs(left-2)<0.1) then val[rewatch_loc["rejuvenation"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
						elseif(left < -1) then
							rewatch_DowndateBar(rewatch_loc["rejuvenation"], i);
						end;
					end;
					-- regrowth bar process
					if(rewatch_bars[i][rewatch_loc["regrowth"]] > 0) then
						left = rewatch_bars[i][rewatch_loc["regrowth"]]-a;
						if(left > 0) then
							val[rewatch_loc["regrowth"].."Bar"]:SetValue(left);
							if(rewatch_loadInt["Labels"] == 0) then val[rewatch_loc["regrowth"].."Bar"].text:SetText(string.format("%.00f", left)); end;
							if(math.abs(left-2)<0.1) then val[rewatch_loc["regrowth"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
						elseif(left < -1) then
							rewatch_DowndateBar(rewatch_loc["regrowth"], i);
						end;
					end;
					-- lifebloom bar process
					if(rewatch_bars[i][rewatch_loc["lifebloom"]] > 0) then
						left = rewatch_bars[i][rewatch_loc["lifebloom"]]-a;
						if(left > 0) then
							val[rewatch_loc["lifebloom"].."Bar"]:SetValue(left);
							if(rewatch_loadInt["Labels"] == 0) then val[rewatch_loc["lifebloom"].."Bar"].text:SetText(string.format("%.00f", left)); end;
							if(math.abs(left-2)<0.1) then val[rewatch_loc["lifebloom"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
						elseif(left < -1) then
							rewatch_DowndateBar(rewatch_loc["lifebloom"], i);
						end;
					end;
					-- wild growth bar process
					if((val[rewatch_loc["wildgrowth"].."Bar"]) and (rewatch_bars[i][rewatch_loc["wildgrowth"]] > 0)) then
						left = rewatch_bars[i][rewatch_loc["wildgrowth"]]-a;
						if(left > 0) then
							if(val["RevertingWG"] == 1) then
								_, b = val[rewatch_loc["wildgrowth"].."Bar"]:GetMinMaxValues();
								val[rewatch_loc["wildgrowth"].."Bar"]:SetValue(b - left);
							else
								val[rewatch_loc["wildgrowth"].."Bar"]:SetValue(left);
								if(math.abs(left-2)<0.1) then val[rewatch_loc["wildgrowth"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
							end;
							if(rewatch_loadInt["Labels"] == 0) then val[rewatch_loc["wildgrowth"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						elseif((left < -1) or (val["RevertingWG"] == 1)) then
							rewatch_DowndateBar(rewatch_loc["wildgrowth"], i);
						end;
					end;
				end;
			end;
		end;
	end;
end);