-- todo; cleanup localizations
-- todo; hidden/hide solo as part of layouts
-- todo; activate layouts through commandline
-- todo; save a dictionary of name->layout for activate layout
-- todo; rename layouts to profiles
-- todo; doublecheck no use of rewatch_loadInt remains
-- todo; improve fixed color list
-- todo; make sure initializing also sets rewatch.player[..].guid
-- todo; processgroup should just set all frames to their x,y based on sequence, resorting should just fix sequence
-- todo; phase out playerId in favor of guid

rewatch =
{
	version = 80000,

	frame = RewatchFrame:new(),
	players = {},

	changed = false,
	inCombat = false,
	clear = false,
	options = nil,
	rezzing = "",
	swiftmend_cast = 0,
	locale = {},

	colors =
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
	}
};

-- initialize Rewatch from previously saved data 
rewatch.Init = function(self)
	
	local guid = UnitGuid("player");
	if(not guid) then return; end;

	rewatch.loaded = true;
	rewatch.guid = guid;
	rewatch.player = UnitName("player");
	rewatch.classId = select(3, UnitClass("player"));

	-- shaman
	if(rewatch.classId == 7) then
		rewatch.isResto = GetSpecialization() == 3;
		rewatch.sampleSpell = rewatch_loc["healingsurge"];
	end;
	
	-- druid
	if(rewatch.classId == 11) then
		rewatch.isResto = GetSpecialization() == 4;
		rewatch.sampleSpell = rewatch_loc["regrowth"];
	end;
	
	-- new users
	if(not rewatch_config) then

		rewatch:RaidMessage("Thank you for using Rewatch!");
		rewatch:Message("Thank you for using Rewatch!");
		rewatch:Message("You can open the options menu using \"/rewatch options\".");
		rewatch:Message("💡 Be sure to check out mouse-over macros or Clique - it's the way Rewatch was meant to be used!");

		rewatch_config = {};
		rewatch_config["Version"] = rewatch.version;
		rewatch_config["Position"] = { x = 100, y = 100 };
		rewatch_config["Profiles"] = {};
		rewatch_config["Profile"] = {};

		rewatch:CreateProfile(rewatch.player);
		rewatch:ActivateProfile(rewatch.player);

	-- updating users
	elseif(rewatch_config["Version"] < rewatch.version) then

		rewatch:Message("Thank you for updating Rewatch!");
		rewatch_config["Version"] = rewatch.version;

	end;

	rewatch.frame:Render();

	rewatch:CreateOptions();
	rewatch:ProcessGroup();

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