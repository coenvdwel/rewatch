-- todo; cleanup localizations
-- todo; hidden/hide solo as part of layouts
-- todo; activate layouts through commandline
-- todo; doublecheck no use of rewatch_loadInt remains
-- todo; improve fixed color list
-- todo; make sure initializing also sets rewatch.player[..].guid

rewatch = {};

-- init
rewatch.version = 80000;
rewatch.players = {};
rewatch.changed = false;
rewatch.inCombat = false;
rewatch.clear = false;
rewatch.options = nil;
rewatch.rezzing = "";
rewatch.swiftmend_cast = 0;

-- todo; bailing out here if not druid/shaman, but should support other classes (soon!)
if((select(3, UnitClass("player"))) ~= 11 and (select(3, UnitClass("player"))) ~= 7) then return; end;

-- build event frame
rewatch.events = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate"); 

rewatch.events:SetWidth(0); 
rewatch.events:SetHeight(0);
rewatch.events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"); 
rewatch.events:RegisterEvent("GROUP_ROSTER_UPDATE");
rewatch.events:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
rewatch.events:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
rewatch.events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED"); 
rewatch.events:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
rewatch.events:RegisterEvent("UNIT_HEAL_PREDICTION"); 
rewatch.events:RegisterEvent("PLAYER_ROLES_ASSIGNED");
rewatch.events:RegisterEvent("PLAYER_REGEN_DISABLED"); 
rewatch.events:RegisterEvent("PLAYER_REGEN_ENABLED");

-- build main frame
rewatch.frame = CreateFrame("Frame", "Rewatch_Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate");

rewatch.frame:SetWidth(100);
rewatch.frame:SetHeight(100);
rewatch.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100);
rewatch.frame:EnableMouse(true);
rewatch.frame:SetMovable(true);
rewatch.frame:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
rewatch.frame:SetBackdropColor(1, 0.49, 0.04, 0);

rewatch.frame:SetScript("OnMouseDown", function(_, button)
	if(button == "RightButton") then
		if(rewatch_load["Lock"]) then
			rewatch_load["Lock"] = false;
			rewatch_Message(rewatch_loc["unlocked"]);
		else
			rewatch_load["Lock"] = true;
			rewatch_Message(rewatch_loc["locked"]);
		end;
	else if(not rewatch_load["Lock"]) then rewatch.frame:StartMoving(); end; end;
end);

rewatch.frame:SetScript("OnMouseUp", function() rewatch.frame:StopMovingOrSizing(); end);
rewatch.frame:SetScript("OnEnter", function () rewatch.frame:SetBackdropColor(1, 0.49, 0.04, 1); end);
rewatch.frame:SetScript("OnLeave", function () rewatch.frame:SetBackdropColor(1, 0.49, 0.04, 0); end);

-- colors
rewatch.colors =
{
	health = { r=0.07; g=0.07; b=0.07, a=1 },
	frame = { r=0.07; g=0.07; b=0.07, a=1 },
	bars =
	[
		{ r=0; g=0.7; b=0, a=1 }, -- lifebloom
		{ r=0.85; g=0.15; b=0.80, a=1 }, -- reju
		{ r=0.4; g=0.85; b=0.34, a=1 }, -- germ
		{ r=0.05; g=0.3; b=0.1, a=1 }, -- regrowth
		{ r=0.5; g=0.8; b=0.3, a=1 }, -- wild growth
		{ r=0.0; g=0.1; b=0.8, a=1 }  -- riptide
	]
};

-- display a message to the user in the chat pane
-- msg: the message to pass onto the user
rewatch.Message = function(self, msg)

	DEFAULT_CHAT_FRAME:AddMessage(rewatch_loc["prefix"]..msg, 1, 1, 1);
	
end;

-- displays a message to the user in the raidwarning frame
-- msg: the message to pass onto the user
rewatch.RaidMessage = function(self, msg)

	RaidNotice_AddMessage(RaidWarningFrame, msg, { r = 1, g = 0.49, b = 0.04 });
	
end;

-- announce an action to the chat, preferring SAY but falling back to EMOTE & WHISPER
-- action: the thing you are announcing (rezzing, innervating, ...)
-- player: the name of the player you are targetting
rewatch.Announce = function(self, action, player)

	if(select(1, IsInInstance())) then
		SendChatMessage("I'm "..action.." "..player.."!", "SAY");
	else
		SendChatMessage("is "..action.." "..player.."!", "EMOTE");
		SendChatMessage("I'm "..action.." you!", "WHISPER", nil, player);
	end;

end;

-- initialize Rewatch from previously saved data 
rewatch.Init = function(self)
	
	rewatch.loaded = true;
	rewatch.classID = select(3, UnitClass("player"));
	rewatch.init = GetTime();

	-- todo; make these bars and buttons configurable
	if(rewatch.classID == 7) then -- shaman

		rewatch.isResto = GetSpecialization() == 3;
		rewatch.sampleSpell = rewatch_loc["healingsurge"];
		rewatch.bars = { rewatch_loc["riptide"] };
		rewatch.barCount = 1;
		rewatch.buttons = { rewatch_loc["purifyspirit"], rewatch_loc["healingsurge"], rewatch_loc["healingwave"], rewatch_loc["chainheal"] };
		rewatch.buttonCount = 4;

	elseif(rewatch.classID == 11) then -- druid
		
		rewatch.isResto = GetSpecialization() == 4;
		rewatch.sampleSpell = rewatch_loc["regrowth"];
		rewatch.bars = { rewatch_loc["lifebloom"], rewatch_loc["rejuvenation"], rewatch_loc["regrowth"], rewatch_loc["wildgrowth"] };
		rewatch.barCount = 4;
		rewatch.buttons = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
		rewatch.buttonCount = 4;

	end;
	
	-- new users!
	if(not rewatch_load) then

		rewatch:RaidMessage("Thank you for using Rewatch!");
		rewatch:Message("Thank you for using Rewatch!");
		rewatch:Message("You can open the options menu using \"/rewatch options\".");
		rewatch:Message("💡 Be sure to check out mouse-over macros or Clique - it's the way Rewatch was meant to be used!");

		rewatch_load = {};
		rewatch_load["Version"] = rewatch.version;
		rewatch_load["SpellBarWidth"] = 25;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Scaling"] = 100;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["WildGrowth"] = 1;
		rewatch_load["Bar"] = "Interface\\AddOns\\Rewatch\\Textures\\Bar.tga";
		rewatch_load["Font"] = "Interface\\AddOns\\Rewatch\\Fonts\\BigNoodleTitling.ttf";
		rewatch_load["FontSize"] = 10;
		rewatch_load["HighlightSize"] = 10;
		rewatch_load["OORAlpha"] = 0.5;
		rewatch_load["PBOAlpha"] = 0.2;
		rewatch_load["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
		rewatch_load["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["naturesswiftness"].."/cast [@mouseover] "..rewatch_loc["regrowth"];
		rewatch_load["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
		rewatch_load["Layout"] = "vertical";
		rewatch_load["SortByRole"] = 1;
		rewatch_load["ShowSelfFirst"] = 1;
		rewatch_load["Highlighting"] = {};
		rewatch_load["Highlighting2"] = {};
		rewatch_load["Highlighting3"] = {};
		rewatch_load["ShowButtons"] = 0;
		rewatch_load["ShowTooltips"] = 1;
		rewatch_load["FrameColumns"] = 1;
		rewatch_load["Layouts"] = {};
	
	-- returning users
	else

		-- deprecations
		rewatch_load["Version"] = rewatch_load["Version"] or rewatch_version;
		
		if(not tonumber(rewatch_load["Version"]) or rewatch_load["Version"] < 70000) then
			rewatch_load = {};
			rewatch.loaded = false;
			return;
		end;

		--migrations
		if(rewatch_load["Version"]  < rewatch.version) then
				
			if(rewatch_load["Version"]  < 70002) then
				rewatch_load["FontSize"] = 10;
				rewatch_load["HighlightSize"] = 10;
				rewatch_load["OORAlpha"] = 0.5;
			end;

			if(rewatch_load["Version"]  < 80000) then
				rewatch_load["Layouts"] = {};
			end;
			
			rewatch_load["Version"] = rewatch.version;
			rewatch:Message("Thank you for updating Rewatch!");

		end;

	end;

	rewatch:CreateOptions();
	rewatch:Render();

end;

-- update frame dimensions ad render everything
rewatch.Render = function(self)

	if(rewatch_load["Layout"] == "horizontal") then
	
		rewatch_load["FrameWidth"] = (rewatch_load["SpellBarWidth"]) * (rewatch_load["Scaling"]/100);
		rewatch_load["ButtonSize"] = (rewatch_load["SpellBarWidth"] / rewatch.buttonCount) * (rewatch_load["Scaling"]/100);
		rewatch_load["FrameHeight"] = ((rewatch_load["SpellBarHeight"] * rewatch.barCount) + rewatch_load["HealthBarHeight"]) * (rewatch_load["Scaling"]/100) + (rewatch_load["ButtonSize"]*rewatch_load["ShowButtons"]);
		
	elseif(rewatch_load["Layout"] == "vertical") then
		
		rewatch_load["FrameWidth"] = ((rewatch_load["SpellBarHeight"] * rewatch.barCount) + rewatch_load["HealthBarHeight"]) * (rewatch_load["Scaling"]/100);
		rewatch_load["ButtonSize"] = (rewatch_load["HealthBarHeight"] * (rewatch_load["Scaling"]/100)) / rewatch.buttonCount;
		rewatch_load["FrameHeight"] = (rewatch_load["SpellBarWidth"]) * (rewatch_load["Scaling"]/100);
		
	end;
	
	rewatch:ProcessGroup();
	rewatch.frame:Show();

end;

-- get the corresponding colour for the power type
-- powerType: the type of power used (MANA, RAGE, FOCUS, ENERGY, CHI, ...)
-- return: a rgb table representing the 'mana bar' colour
rewatch.GetPowerBarColor = function(self, powerType)

	if(powerType == 0 or powerType == "MANA") then return { r = 0.24, g = 0.35, b = 0.49 }; end;
	if(powerType == 1 or powerType == "RAGE") then return { r = 0.52, g = 0.17, b = 0.17 }; end;
	if(powerType == 3 or powerType == "ENERGY") then return { r = 0.5, g = 0.48, b = 0.27 }; end;
	
	return PowerBarColor[powerType];
	
end;

-- pops up a tooltip for a spell
rewatch.SetSpellTooltip = function(self, spell)

	if(rewatch_load["ShowTooltips"] ~= 1) then return; end;

	local spellId = rewatch_GetSpellId(data);

	if(spellId) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetSpellBookItem(spellId, BOOKTYPE_SPELL);
	end;

end

-- pops up a tooltip for a player
rewatch.SetPlayerTooltip = function(self, playerId)
	
	if(rewatch_load["ShowTooltips"] ~= 1) then return; end;

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetUnit(rewatch.players[playerId].player);

end;

-- gets the spell ID of the highest rank of the specified spell
-- spellName: the name of the spell to get the highest ranked spellId from
-- return: the corresponding spellId
rewatch.GetSpellId = function(self, spellName)

	local i = 1;
	while true do
	   local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
	   if (not spell) then break; end;
	   if (spell == spellName) then return i; end;
	   i = i+1;
	end
	
	return -1;
	
end;

-- get the number of the supplied player's place in the player table, or -1
-- player: name of the player to search for
-- return: the supplied player's table index, or -1 if not found
rewatch.GetPlayerId = function(self, player)

	if(not player) then return -2; end;
	if(not UnitIsPlayer(player)) then return -2; end;

	local guid = UnitGUID(player);

	for i,v in pairs(rewatch.players) do
		if(not v) then continue; end;
		if(v.guid == guid) then return i; end;
	end;

	return -1;
	
end;

-- checks if the player or pet is in the group
-- player: name of the player or pet to check for
-- return: true, if the player is the user, or in the user's party or raid (or pet); false elsewise
rewatch.InGroup = function(player)

	if(UnitName("player") == player) then return true; end;

	if((GetNumGroupMembers() > 0) and IsInRaid()) then
		if(UnitPlayerOrPetInRaid(player)) then
			return true;
		end;
	elseif(GetNumSubgroupMembers() > 0) then
		if(UnitPlayerOrPetInParty(player)) then
			return true;
		end;
	end;

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
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_colors.mark.r, rewatch_colors.mark.g, rewatch_colors.mark.b, rewatch_colors.mark.a);
		
	-- default
	else
	
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_colors.frame.r, rewatch_colors.frame.g, rewatch_colors.frame.b, rewatch_colors.frame.a);
		
	end;
	
end;

-- adjusts the parent frame container's height
-- return: void
function rewatch_AlterFrame()

	-- get current x and y
	local x, y = rewatch_f:GetLeft(), rewatch_f:GetTop();
	
	-- set height and width according to number of frames
	local num, height, width = rewatch_f:GetNumChildren();
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

-- return the first available empty spot in the frame
-- return: position coordinates; { x, y }
function rewatch_GetFramePos()
	
	if (rewatch_loadInt["FrameWidth"] == nil and rewatch_loadInt["FrameHeight"] == nil) then return 0, 0 end;

	local children = { rewatch_f:GetChildren() };
	local x, y, free = 0, 0, true;
	
	-- walk through the available spots, left to right, top to bottom
	if(rewatch_loadInt["FrameColumns"] == 0) then
		
		local mx = rewatch_loadInt["NumFramesWide"]-1;
		local my = -floor(rewatch_f:GetNumChildren()/rewatch_loadInt["NumFramesWide"]);

		for dy=0, my, -1 do
			for dx=0, mx, 1 do

				free, x, y = true, rewatch_loadInt["FrameWidth"]*dx, rewatch_loadInt["FrameHeight"]*dy;

				for _, child in ipairs(children) do
					if((math.abs(x - (child:GetLeft()-rewatch_f:GetLeft())) < 1) and (math.abs(y - (child:GetTop()-rewatch_f:GetTop())) < 1)) then
						free = false;
						break;
					end;
				end;

				if(free) then return x, y; end;

			end;
		end;

		return rewatch_f:GetWidth()*((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]), math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]) * rewatch_f:GetHeight() * -1;

	-- walk through the available spots, top to bottom, left to right
	else

		local mx = floor(rewatch_f:GetNumChildren()/rewatch_loadInt["NumFramesWide"]);
		local my = 1-rewatch_loadInt["NumFramesWide"];
		
		for dx=0, mx, 1 do
			for dy=0, my, -1 do

				free, x, y = true, rewatch_loadInt["FrameWidth"]*dx, rewatch_loadInt["FrameHeight"]*dy;

				for _, child in ipairs(children) do
					if((math.abs(x - (child:GetLeft()-rewatch_f:GetLeft())) < 1) and (math.abs(y - (child:GetTop()-rewatch_f:GetTop())) < 1)) then
						free = false;
						break;
					end;
				end;

				if(free) then return x, y; end;

			end;
		end;

		return rewatch_f:GetWidth()*math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]), ((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]) * rewatch_f:GetHeight() * -1;
	
	end;
	
end;

-- compares the current player table to the party/raid schedule
rewatch.ProcessGroup = function(self)

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
			if((name) and (rewatch:GetPlayerId(name) == -1)) then
				table.insert(names, name);
			end;
		end;

	-- process party group (only when not in a raid)
	else

		n = GetNumSubgroupMembers();

		-- for each group member, if he's not in the list, add him
		for i=1, n + 1 do
			if(i > n) then name = UnitName("player"); else name = UnitName("party"..i); end;
			if((name) and (rewatch:GetPlayerId(name) == -1)) then
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
	button:SetNormalTexture(select(3, GetSpellInfo(spellName)));
	button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9);
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp");
	
	-- transparency for highlighting icons
	if(spellName == rewatch_loc["removecorruption"]) then button:SetAlpha(0.2);
	elseif(spellName == rewatch_loc["naturescure"]) then button:SetAlpha(0.2);
	elseif(spellName == rewatch_loc["purifyspirit"]) then button:SetAlpha(0.2);
	end;
	
	-- apply tooltip support
	button:SetScript("OnEnter", function() rewatch:SetSpellTooltip(spellName); end);
	button:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	
	-- relate spell to button
	button.spellName = spellName;
	
	-- add cooldown overlay
	button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate");
	button.cooldown:SetPoint("CENTER", 0, -1);
	button.cooldown:SetWidth(button:GetWidth()); button.cooldown:SetHeight(button:GetHeight()); button.cooldown:Hide();
			
	return button;

end;

-- create a spell bar with text and add it to the global player table
-- spellName: the name of the spell to create a bar for
-- playerId: the index number of the player in the player table
-- relative: the name of the rewatch_bars[n] key, referencing to the relative castbar for layout
-- return: the created bar reference, it's border reference, and a possible sidebar reference
function rewatch_CreateBar(spellName, playerId, relative, i)

	local result = {};
	
	-- create the bar
	result.bar = CreateFrame("STATUSBAR", spellName..playerId, rewatch_bars[playerId]["Frame"], "TextStatusBar")
	result.bar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	result.bar:GetStatusBarTexture():SetHorizTile(false);
	result.bar:GetStatusBarTexture():SetVertTile(false);
	
	-- arrange layout
	if(rewatch_loadInt["Layout"] == "horizontal") then
		result.bar:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		result.bar:SetHeight(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		result.bar:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", 0, 0);
		result.bar:SetOrientation("horizontal");
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		result.bar:SetHeight(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		result.bar:SetWidth(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		result.bar:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "TOPRIGHT", 0, 0);
		result.bar:SetOrientation("vertical");
	end;
	
	-- create bar border
	result.border = CreateFrame("FRAME", nil, result.bar, BackdropTemplateMixin and "BackdropTemplate");
	result.border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 2, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	result.border:SetBackdropBorderColor(1, 1, 1, 0);
	result.border:SetWidth(result.bar:GetWidth()+1);
	result.border:SetHeight(result.bar:GetHeight()+1);
	result.border:SetPoint("TOPLEFT", result.bar, "TOPLEFT", -0, 0);
	
	-- bar color
	result.bar:SetStatusBarColor(rewatch_colors.bars[i].r, rewatch_colors.bars[i].g, rewatch_colors.bars[i].b, rewatch_loadInt["PBOAlpha"]);
	
	-- set bar reach
	result.bar:SetMinMaxValues(0, 1);
	result.bar:SetValue(1);
	
	-- if this was reju, add a tiny germination sidebar to it
	if(spellName == rewatch_loc["rejuvenation"]) then
	
		-- create the tiny bar
		result.sidebar = CreateFrame("STATUSBAR", spellName.." (germination)"..playerId, result.bar, "TextStatusBar");
		result.sidebar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
		result.sidebar:GetStatusBarTexture():SetHorizTile(false);
		result.sidebar:GetStatusBarTexture():SetVertTile(false);
		
		-- adjust to layout
		if(rewatch_loadInt["Layout"] == "horizontal") then
			result.sidebar:SetWidth(result.bar:GetWidth());
			result.sidebar:SetHeight(result.bar:GetHeight() * 0.33);
			result.sidebar:SetPoint("TOPLEFT", result.bar, "BOTTOMLEFT", 0, result.bar:GetHeight() * 0.33);
			result.sidebar:SetOrientation("horizontal");
		elseif(rewatch_loadInt["Layout"] == "vertical") then
			result.sidebar:SetWidth(result.bar:GetWidth() * 0.33);
			result.sidebar:SetHeight(result.bar:GetHeight());
			result.sidebar:SetPoint("TOPLEFT", result.bar, "TOPRIGHT", -(result.bar:GetWidth() * 0.33), 0);
			result.sidebar:SetOrientation("vertical");
		end;
		
		-- bar color
		result.sidebar:SetStatusBarColor(1-rewatch_colors.bars[i].r, 1-rewatch_colors.bars[i].g, 1-rewatch_colors.bars[i].b, rewatch_loadInt["PBOAlpha"]);
		
		-- bar reach
		result.sidebar:SetMinMaxValues(0, 1);
		result.sidebar:SetValue(0);
		
		-- put text in bar
		result.sidebar.text = result.bar:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
		result.sidebar.text:SetPoint("RIGHT", result.sidebar);
		result.sidebar.text:SetAllPoints();
		result.sidebar.text:SetText("");

	end;
	
	-- overlay cast button
	local bc = CreateFrame("BUTTON", nil, result.bar, "SecureActionButtonTemplate");
	bc:SetWidth(result.bar:GetWidth());
	bc:SetHeight(result.bar:GetHeight());
	bc:SetPoint("TOPLEFT", result.bar, "TOPLEFT", 0, 0);
	bc:RegisterForClicks("LeftButtonDown", "RightButtonDown"); bc:SetAttribute("type1", "spell"); bc:SetAttribute("unit", rewatch_bars[playerId]["Player"]);
	bc:SetAttribute("spell1", spellName); bc:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp");
	
	-- put text in bar
	result.bar.text = bc:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	result.bar.text:SetPoint("RIGHT", bc); result.bar.text:SetAllPoints(); result.bar.text:SetAlpha(1);
	result.bar.text:SetText(""); -- todo; use this text generically for amount of stacks of this spell

	-- apply tooltip support
	bc:SetScript("OnEnter", function() bc:SetAlpha(0.2); rewatch:SetSpellTooltip(spellName); end);
	bc:SetScript("OnLeave", function() bc:SetAlpha(1); GameTooltip:Hide(); end);
	
	result.i = i;

	return result;
	
end;

-- update a bar by resetting spell duration
-- spellName: the name of the spell to reset it's duration from
-- player: player name
-- return: void
function rewatch_UpdateBar(spellName, player)
	
	-- this shouldn't happen, but just in case
	if(not spellName) then return; end;
	
	-- get player
	local playerId = rewatch:GetPlayerId(player); -- todo; don't we know the ID?
    if(playerId < 0) then return; end;
	
	-- lag may cause this 'inconsistency', fixie here
	if(spellName == rewatch_loc["wildgrowth"] or spellName == rewatch_loc["riptide"]) then rewatch_bars[playerId]["Reverting"..spellName] = 0; end; -- todo; reverting?

	-- if the spell exists
	if(rewatch_bars[playerId]["Bars"][spellName]) then
		
		-- get buff duration
		local a = rewatch_GetBuffExpirationTime(player, spellName)
		if(a == nil) then return; end;

		local b = a - GetTime();
		local c = rewatch_colors.bars[rewatch_bars[playerId]["Bars"][spellName].i];

		-- set bar color
		rewatch_bars[playerId]["Bars"][spellName].bar:SetStatusBarColor(c.r, c.g, c.b, c.a);
		
		-- set bar values
		rewatch_bars[playerId]["Bars"][spellName].value = a;
		if(select(2, rewatch_bars[playerId]["Bars"][spellName].bar:GetMinMaxValues()) <= b) then rewatch_bars[playerId]["Bars"][spellName].bar:SetMinMaxValues(0, b); end;
		rewatch_bars[playerId]["Bars"][spellName].bar:SetValue(b);
	end;
end;

-- get expirationTime of buff 
function rewatch_GetBuffExpirationTime(player, spellName)

	for i=1,40 do
		local name, _, _, _, _, expirationTime = UnitBuff(player, i, "PLAYER");
		if (name == nil) then return nil; end;
		if (name == spellName) then return expirationTime; end;
	end;

	return nil;
	
end;

-- check if debuff is decursible
-- player: the name of the player
-- returns: type, icon and expirationTime of debuff, or nil if none
function rewatch_GetDebuffInfo(player, spellName)

	for i=1,40 do
		local name, icon, _, debuffType, _, expirationTime  = UnitDebuff(player, i);
		if(name == nil) then return nil; end;
		if(name == spellName) then
			if((debuffType == "Curse") or (debuffType == "Poison" and rewatch_loadInt["IsDruid"]) or (debuffType == "Magic" and rewatch_loadInt["InRestoSpec"])) then
				return debuffType, icon, expirationTime;
			else
				return nil;
			end;
		end;
	end;
	
	return nil;
	
end;

-- clear a bar back to 0 because it's been dispelled or removed
-- spellName: the name of the spell to reset it's duration from
-- playerId: the index number of the player in the player table
-- return: void
function rewatch_DowndateBar(spellName, playerId)

	-- if the spell exists for this player
	if(rewatch_bars[playerId]["Bars"][spellName] and rewatch_bars[playerId]["Bars"][spellName].bar) then
		
		-- reset bar values
		rewatch_bars[playerId]["Bars"][spellName].value = 0;
		rewatch_bars[playerId]["Bars"][spellName].bar:SetMinMaxValues(0, 1);
		rewatch_bars[playerId]["Bars"][spellName].bar:SetValue(1);
		rewatch_bars[playerId]["Bars"][spellName].bar.text:SetText("");
		

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
-- return: the index number the player has been assigned
function rewatch_AddPlayer(player)

	-- todo; remove Mark
	-- todo; then what's with our own role icon tank/healer.tga's?
	-- todo; make something better than /rew add henk always

	--playerBarInc = statusbarinc,
	--playerBar = statusbar,
	--manaBar = manabar,
	--notify = nil,
	--notify2 = nil,
	--notify3 = nil,
	--debuff = nil,
	--debuffTexture = debuffTexture,
	--debuffDuration = nil,
	--hover = 0,
	--bars = {},
	--buttons = {}
	

	-- return if in combat
	if(rewatch_inCombat) then return -1; end;
	
	local o = {};
	local name, pos = player, player:find("-");
	local guid = UnitGUID(player);
	local powerType = rewatch_GetPowerBarColor(UnitPowerType(player));
	local classID = select(3, UnitClass(player));
	local class = GetClassInfo(classID or 11);
	local classColors = RAID_CLASS_COLORS[class];
	local x, y = rewatch_GetFramePos();

	-- determine display name
	if(pos ~= nil) then name = name:sub(1, pos-1).."*"; end;
	
	-- player name
	o.player = player;
	o.displayName = name;
	o.guid = guid;
	
	-- build frame
	o.frame = CreateFrame("Frame", nil, rewatch_f, BackdropTemplateMixin and "BackdropTemplate");

	o.frame:SetWidth(rewatch_loadInt["FrameWidth"]);
	o.frame:SetHeight(rewatch_loadInt["FrameHeight"]);
	o.frame:SetPoint("TOPLEFT", rewatch_f, "TOPLEFT", x, y);
	o.frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	o.frame:SetBackdropColor(rewatch_colors.frame.r, rewatch_colors.frame.g, rewatch_colors.frame.b, rewatch_colors.frame.a);
	
	-- create player HP bar for estimated incoming health
	o.playerBarInc = CreateFrame("STATUSBAR", nil, o.frame, "TextStatusBar");

	if(rewatch_loadInt["Layout"] == "horizontal") then
		o.playerBarInc:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		o.playerBarInc:SetHeight((rewatch_loadInt["HealthBarHeight"]*0.8) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		o.playerBarInc:SetHeight(((rewatch_loadInt["SpellBarWidth"]*0.8) * (rewatch_loadInt["Scaling"]/100)) -(rewatch_loadInt["ShowButtons"]*rewatch_loadInt["ButtonSize"]));
		o.playerBarInc:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
	end;

	o.playerBarInc:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	o.playerBarInc:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	o.playerBarInc:GetStatusBarTexture():SetHorizTile(false);
	o.playerBarInc:GetStatusBarTexture():SetVertTile(false);
	o.playerBarInc:SetStatusBarColor(0.4, 1, 0.4, 1);
	o.playerBarInc:SetMinMaxValues(0, 1);
	o.playerBarInc:SetValue(0);
		
	-- create player HP bar
	o.playerBar = CreateFrame("STATUSBAR", nil, o.playerBarInc, "TextStatusBar");

	o.playerBar:SetWidth(o.playerBarInc:GetWidth());
	o.playerBar:SetHeight(o.playerBarInc:GetHeight());
	o.playerBar:SetPoint("TOPLEFT", o.frame, "TOPLEFT", 0, 0);
	o.playerBar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	o.playerBar:GetStatusBarTexture():SetHorizTile(false);
	o.playerBar:GetStatusBarTexture():SetVertTile(false);
	o.playerBar:SetStatusBarColor(rewatch_colors.health.r, rewatch_colors.health.g, rewatch_colors.health.b, 1);
	o.playerBar:SetMinMaxValues(0, 1);
	o.playerBar:SetValue(0);

	-- put text in HP bar
	o.playerBar.text = o.playerBar:CreateFontString("$parentText", "ARTWORK");
	o.playerBar.text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"] * (rewatch_loadInt["Scaling"]/100), "OUTLINE");
	o.playerBar.text:SetAllPoints();
	o.playerBar.text:SetText(name);
	o.playerBar.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1);
	
	-- role icon
	local roleIcon = o.playerBar:CreateTexture(nil, "OVERLAY");
	local role = UnitGroupRolesAssigned(player);

	roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES");
	roleIcon:SetSize(16, 16);
	roleIcon:SetPoint("TOPLEFT", o.playerBar, "TOPLEFT", 10, 8-o.playerBar:GetHeight()/2);
	
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
	local debuffIcon = CreateFrame("Frame", nil, o.playerBar, BackdropTemplateMixin and "BackdropTemplate");
	
	debuffIcon:SetWidth(16);
	debuffIcon:SetHeight(16);
	debuffIcon:SetPoint("TOPRIGHT", o.playerBar, "TOPRIGHT", -10, 8-o.playerBar:GetHeight()/2);
	debuffIcon:SetAlpha(0.8);

	-- debuff texture
	o.debuffTexture = debuffIcon:CreateTexture(nil, "ARTWORK");
	o.debuffTexture:SetAllPoints();
	
	-- create mana bar
	o.manaBar = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");

	if(rewatch_loadInt["Layout"] == "horizontal") then
		o.manaBar:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		o.manaBar:SetHeight((rewatch_loadInt["HealthBarHeight"]*0.2) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		o.manaBar:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		o.manaBar:SetHeight((rewatch_loadInt["SpellBarWidth"]*0.2) * (rewatch_loadInt["Scaling"]/100));
	end;

	o.manaBar:SetPoint("TOPLEFT", o.playerBar, "BOTTOMLEFT", 0, 0);
	o.manaBar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	o.manaBar:GetStatusBarTexture():SetHorizTile(false);
	o.manaBar:GetStatusBarTexture():SetVertTile(false);
	o.manaBar:SetMinMaxValues(0, 1);
	o.manaBar:SetValue(0);
	o.manaBar:SetStatusBarColor(powerType.r, powerType.g, powerType.b);

	-- create aggro bar
	o.aggroBar = CreateFrame("STATUSBAR", nil, manabar, "TextStatusBar");

	o.aggroBar:SetPoint("TOPLEFT", manabar, "TOPLEFT", 0, 0);
	o.aggroBar:SetHeight(2);
	o.aggroBar:SetWidth(manabar:GetWidth());
	o.aggroBar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	o.aggroBar:GetStatusBarTexture():SetHorizTile(false);
	o.aggroBar:GetStatusBarTexture():SetVertTile(false);
	o.aggroBar:SetMinMaxValues(0, 1);
	o.aggroBar:SetValue(0);
	o.aggroBar:SetStatusBarColor(1, 0, 0);

	-- build border frame
	o.border = CreateFrame("FRAME", nil, o.playerBar, BackdropTemplateMixin and "BackdropTemplate");

	o.border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	o.border:SetBackdropBorderColor(0, 0, 0, 1);
	o.border:SetWidth(rewatch_loadInt["FrameWidth"]+1);
	o.border:SetHeight(rewatch_loadInt["FrameHeight"]+1);
	o.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -0, 0);

	-- bars
	o.bars = {};

	local anchor = o.playerBar;
	if(rewatch_loadInt["Layout"] == "horizontal") then anchor = o.manaBar; end;

	for i,spell in pairs(rewatch_loadInt["Bars"]) do
		o.bars[spell] = rewatch_CreateBar(spell, rewatch_i, anchor, i);
		anchor = o.bars[spell].bar;
	end;
	
	-- buttons
	if(rewatch_loadInt["ShowButtons"] == 1) then

		o.buttons = {};

		if(rewatch_loadInt["Layout"] == "vertical") then anchor = o.manaBar; end;

		for i,spell in pairs(rewatch_loadInt["ButtonSpells"..rewatch_loadInt["ClassID"]]) do

			if(not rewatch_loadInt["InRestoSpec"]) then
				if(spell == rewatch_loc["naturescure"]) then spell = rewatch_loc["removecorruption"];
				elseif(spell == rewatch_loc["ironbark"]) then spell = rewatch_loc["barkskin"];
				end;
			end;

			if(select(3, GetSpellInfo(spellName))) then
				rewatch_bars[rewatch_i]["Buttons"][spell] = rewatch_CreateButton(spell, rewatch_i, anchor, i);
			end;

		end;
	end;
	
	-- overlay target/remove button
	local overlay = CreateFrame("BUTTON", nil, o.playerBar, "SecureActionButtonTemplate");

	overlay:SetWidth(o.playerBar:GetWidth());
	overlay:SetHeight(o.playerBar:GetHeight()*1.25);
	overlay:SetPoint("TOPLEFT", o.playerBar, "TOPLEFT", 0, 0);
	overlay:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp");
	overlay:SetAlpha(0.05);
	
	overlay:SetAttribute("type1", "target");
	overlay:SetAttribute("unit", player);
	overlay:SetAttribute("alt-type1", "macro");
	overlay:SetAttribute("alt-macrotext1", rewatch_loadInt["AltMacro"]);
	overlay:SetAttribute("ctrl-type1", "macro");
	overlay:SetAttribute("ctrl-macrotext1", rewatch_loadInt["CtrlMacro"]);
	overlay:SetAttribute("shift-type1", "macro");
	overlay:SetAttribute("shift-macrotext1", rewatch_loadInt["ShiftMacro"]);
	
	overlay:SetScript("OnEnter", function()
		local playerId = rewatch:GetPlayerId(player);
		if(playerId > 0) then
			rewatch:SetPlayerTooltip(playerId);
			rewatch_bars[playerId]["Hover"] = 1;
		end;
	end);
	
	overlay:SetScript("OnLeave", function()
		GameTooltip:Hide();
		local playerId = rewatch:GetPlayerId(player);
		if(playerId > 0) then
			rewatch_bars[rewatch:GetPlayerId(player)]["Hover"] = 2;
		end;
	end);
	
	-- add to frames
	rewatch_bars[rewatch_i] = o;
	rewatch_i = rewatch_i+1;
	
	-- update frames
	rewatch_AlterFrame();

	-- return the inserted player's player table index
	-- todo; why?
	return rewatch:GetPlayerId(player);
	
end;

-- hide all bars and buttons from - and the player himself, by name
-- player: the name of the player to hide
-- return: void
-- PRE: Called by specific user request
function rewatch_HidePlayerByName(player)

	if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
	else

		-- get the index of this player
		local playerId = rewatch:GetPlayerId(player);

		-- if this player exists, hide all bars and buttons from - and the player himself
		if(playerId > 0) then

			-- check for others
			local others = false;
			for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then
				if(i ~= playerId) then others = true; break; end;
			end; end;

			if(others) then rewatch_HidePlayer(playerId);
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
	
	for _, spell in pairs(rewatch_loadInt["Bars"]) do
		rewatch_bars[playerId][spell.."Bar"]:Hide();
		if(rewatch_bars[playerId][spell.."Sidebar"]) then rewatch_bars[playerId][spell.."Sidebar"]:Hide(); end;
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
			playerId = rewatch:GetPlayerId(player);
			if(playerId > 0) then
				rewatch_bars[playerId][notify] = spell; rewatch_SetFrameBG(playerId);
				return true;
			end;
		end;
	end;
	
	return false;
	
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
				if(rewatch:GetPlayerId(commands[2]) < 0) then
					if(rewatch_InGroup(commands[2])) then rewatch_AddPlayer(commands[2], nil);
					elseif(commands[3]) then
						if(string.lower(commands[3]) == "always") then rewatch_AddPlayer(commands[2], nil);
						else rewatch_Message(rewatch_loc["notingroup"]); end;
					else rewatch_Message(rewatch_loc["notingroup"]); end;
				end;
			elseif(UnitName("target")) then if(rewatch:GetPlayerId(UnitName("target")) < 0) then rewatch_AddPlayer(UnitName("target"), nil); end;
			else rewatch_Message(rewatch_loc["noplayer"]); end;
			
		-- if the user wants to resort the list (clear and processgroup)
		elseif(string.lower(commands[1]) == "sort") then
		
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_clear = true;
				rewatch_changed = true;
				rewatch_Message(rewatch_loc["sorted"]);
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
			
		-- if the user wants to check his version
		elseif(string.lower(commands[1]) == "version") then
		
			rewatch_Message("Rewatch v"..rewatch_versioni);
			
		-- if the user wants to toggle the settings GUI
		elseif(string.lower(commands[1]) == "options") then
		
			rewatch_changedDimentions = false;
			
			InterfaceOptionsFrame_Show();
			InterfaceOptionsFrame_OpenToCategory("Layouts");
			InterfaceOptionsFrame_OpenToCategory("Rewatch");
			
		-- if the user wants something else (unsupported)
		elseif(string.len(commands[1]) > 0) then
		
			rewatch_Message(rewatch_loc["invalid_command"]);
			
		else
		
			rewatch_Message(rewatch_loc["credits"]);
			
		end;
		
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

-- local vars
local r, g, b, a, val, n;
local playerId, debuffType, debuffIcon, debuffDuration, role;
local d, x, y, v, left, i, currentTarget, currentTime;

-- add the slash command handler
SLASH_REWATCH1 = "/rewatch";
SLASH_REWATCH2 = "/rew";
SlashCmdList["REWATCH"] = function(cmd)
	rewatch_SlashCommandHandler(cmd);
end;

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
		
		-- update threat
	elseif(event == "UNIT_THREAT_SITUATION_UPDATE") then

		if(unitGUID) then
			playerId = rewatch:GetPlayerId(UnitName(unitGUID));
			if(playerId < 0) then return; end;
			if(playerId == nil) then return; end;
			val = rewatch_bars[playerId];
			if(val["UnitGUID"] and val["Player"]) then
				a = UnitThreatSituation(val["Player"]);
				if(a == nil or a == 0) then
					val["Border"]:SetBackdropBorderColor(0, 0, 0, 1);
					val["Border"]:Lower();
				else r, g, b = GetThreatStatusColor(a);
					val["Border"]:SetBackdropBorderColor(r, g, b, 1);
					val["Border"]:Raise();
				end;
			end;
		end;

	-- changed role
	elseif(event == "PLAYER_ROLES_ASSIGNED") then
	
		if(unitGUID) then
			playerId = rewatch:GetPlayerId(UnitName(unitGUID));
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
		local spell, school;

		-- buff applied/refreshed
		elseif((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
			
			-- get the player position, or if -1, return
			playerId = rewatch:GetPlayerId(targetName);
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

				rewatch_Announce("innervating", targetName);
				
			-- process custom highlighting
			elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting", "Notify")) then
			elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting2", "Notify2")) then
			elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting3", "Notify3")) then
			
				-- ignore further, already processed it		
				
			-- process debuff application
			elseif(school == "DEBUFF") then
				
				-- determine debuff type
				debuffType, debuffIcon, debuffDuration = rewatch_GetDebuffInfo(targetName, spell);
				
				if(debuffType ~= nil) then
					rewatch_bars[playerId]["Debuff"] = spell; 
					rewatch_bars[playerId]["DebuffType"] = debuffType;
					rewatch_bars[playerId]["DebuffIcon"] = debuffIcon;
					rewatch_bars[playerId]["DebuffDuration"] = debuffDuration;
					rewatch_bars[playerId]["DebuffTexture"]:SetTexture(rewatch_bars[playerId]["DebuffIcon"]);
					rewatch_bars[playerId]["DebuffTexture"]:Show();
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
			playerId = rewatch:GetPlayerId(targetName);
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
				rewatch_bars[playerId]["DebuffDuration"] = nil;
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
		elseif(isMe and (effect == "SPELL_CAST_START")) then
			
			-- get spell data
			spell = select(13, CombatLogGetCurrentEventInfo());
			
			if((spell == rewatch_loc["rebirth"]) or (spell == rewatch_loc["revive"])) then

				if(not rewatch_rezzing) then return; end;
				if(not UnitIsDeadOrGhost(rewatch_rezzing)) then return; end;

				rewatch_Announce("rezzing", rewatch_rezzing);
				rewatch_rezzing = "";
				
			end;
			
		end;
		
	end;
end);

-- update everything
rewatch_events:SetScript("OnUpdate", function()

	-- load saved vars
	if(not rewatch_loadInt["Loaded"]) then
	
		rewatch:Init();
		return;
		
	end;

	-- clearing and reprocessing the frames
	if(not rewatch_inCombat) then
	
		-- check if we have the extra need to clear
		if(rewatch_changed) then
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
			rewatch_ProcessGroup();
			rewatch_changed = false;
		end;
		
	end;
	
	-- get current target and time
	currentTarget = UnitGUID("target");
	currentTime = GetTime();
	
	-- if swiftmend was cast before, update HoTs (for legendary with effect: Verdant Infusion)
	if (rewatch_swiftmend_cast ~= 0 and rewatch_swiftmend_cast < currentTime) then
		rewatch_UpdateHoTBars();
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

					v["PlayerBar"]:SetStatusBarColor(rewatch_colors.health.r, rewatch_colors.health.g, rewatch_colors.health.b, 0.5);
					v["ManaBar"]:SetValue(0);
					v["PlayerBar"]:SetValue(0);
					v["PlayerBarInc"]:SetValue(0);
					if(v["Mark"]) then
						v["Frame"]:SetBackdropColor(rewatch_colors.mark.r, rewatch_colors.mark.g, rewatch_colors.mark.b, rewatch_colors.mark.a);
					else
						v["Frame"]:SetBackdropColor(rewatch_colors.frame.r, rewatch_colors.frame.g, rewatch_colors.frame.b, rewatch_colors.frame.a);
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
					v["DebuffDuration"] = nil;
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
				
				d = UnitGetIncomingHeals(v["Player"]) or 0;
				v["PlayerBarInc"]:SetMinMaxValues(0, x);
				if(y+d>=x) then v["PlayerBarInc"]:SetValue(x);
				else v["PlayerBarInc"]:SetValue(y+d); end;

				-- set healthbar color
				d = y/x;
				if(d < 0.5) then
					d = d * 2;
					v["PlayerBar"]:SetStatusBarColor(0.50 + ((1-d) * (1.00 - 0.50)), rewatch_colors.health.g, rewatch_colors.health.b, 1);
				else
					d = (d * 2) - 1;
					v["PlayerBar"]:SetStatusBarColor(rewatch_colors.health.r + ((1-d) * (0.50 - rewatch_colors.health.r)), rewatch_colors.health.g + ((1-d) * (0.50 - rewatch_colors.health.g)), rewatch_colors.health.b, 1);
				end;

				-- initialize player text
				if(rewatch_loadInt["Init"] ~= nil) then
				
					-- this is mainly because the set text in rewatch_AddPlayer during screen initialization (startup) does not render
					-- updating the field with the same value once everything is initialized is caught by the engine, because it's the same value as internally stored
					
					if(currentTime - rewatch_loadInt["Init"] > 10) then rewatch_loadInt["Init"] = nil; end;
					
					if(rewatch_loadInt["Init"] ~= nil and math.floor(currentTime%2) == 0) then
						v["PlayerBar"].text:SetText(" "..v["DisplayName"].." ");
					else
						v["PlayerBar"].text:SetText(v["DisplayName"]);
					end;
					
				-- set healthbar text (standard)
				elseif(v["Hover"] == 0) then
					
					if(v["EarthShield"] ~= nil) then
					
						if(v["EarthShield"] > 0) then
							v["PlayerBar"].text:SetText(v["EarthShield"].." "..v["DisplayName"]);
						else
							v["PlayerBar"].text:SetText(v["DisplayName"]);
							v["EarthShield"] = nil;
						end;
						
					end;
					
				-- set healthbar text (when hovering)
				elseif(v["Hover"] == 1) then
					
					v["PlayerBar"].text:SetText(string.format("%i/%i", y, x));
					
				-- set healthbar text (when unhovering)
				elseif(v["Hover"] == 2) then
					
					v["PlayerBar"].text:SetText(v["DisplayName"]);
					v["Hover"] = 0;
					
				end;
				
				-- get and set mana data
				v["ManaBar"]:SetMinMaxValues(0, UnitPowerMax(v["Player"]));
				v["ManaBar"]:SetValue(UnitPower(v["Player"]));
				
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
				
				-- debuff check
				if(v["DebuffDuration"] ~= nil and v["DebuffDuration"] > 0) then
					left = v["DebuffDuration"]-currentTime;
					if(left < -1) then
						v["Debuff"] = nil;
						v["DebuffTexture"]:Hide();
						v["DebuffDuration"] = nil;
					end;
				end;
				
				-- rejuvenation bar process
				if(v[rewatch_loc["rejuvenation"]] > 0) then
					left = v[rewatch_loc["rejuvenation"]]-currentTime;
					if(left > 0) then
						v[rewatch_loc["rejuvenation"].."Bar"]:SetValue(left);
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
					elseif((left < -1) or (v["Reverting"..spellName] == 1)) then
						rewatch_DowndateBar(rewatch_loc["riptide"], i);
					end;
				end;
				
			end;
		end;
	end;
end);