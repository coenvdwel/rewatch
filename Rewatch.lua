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
-- todo; for each class, determine sampleSpell (earliest GCD spell)

rewatch =
{
	version = 80000,

	guid = nil,
	player = nil,
	classID = nil,
	isResto = false,
	sampleSpell = nil,

	loaded = false,
	frame = nil,
	options = nil,
	events = nil,
	players = {},
	locale = {},

	changed = false,
	inCombat = false,
	clear = false,
	rezzing = "",
	swiftmend_cast = 0,

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

rewatch.Init = function(self)

	rewatch.guid = UnitGuid("player");
	rewatch.player = UnitName("player");
	rewatch.classId = select(3, UnitClass("player"));

	if(not rewatch.guid) then return; end;

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

	-- updating users
	elseif(rewatch_config["Version"] < rewatch.version) then

		rewatch:Message("Thank you for updating Rewatch!");
		rewatch_config["Version"] = rewatch.version;

	end;

	rewatch.loaded = true;
	rewatch.frame = RewatchFrame:new();
	rewatch.options = RewatchOptions:new();

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