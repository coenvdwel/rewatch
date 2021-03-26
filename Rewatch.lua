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

	guid = nil,
	player = nil,
	classId = nil,
	spec = nil,

	loaded = false,
	frame = nil,
	options = nil,
	events = nil,
	players = {},
	locale = {},

	changed = false,
	inCombat = false,
	locked = true,
	clear = false,
	rezzing = "",
	swiftmend_cast = 0
};

rewatch.Init = function(self)

	rewatch.guid = UnitGUID("player");
	rewatch.player = UnitName("player");
	rewatch.classId = select(3, UnitClass("player"));
	rewatch.spec = GetSpecialization();

	if(not rewatch.guid) then return; end;
	
	-- new users
	if(not rewatch_config) then

		rewatch:RaidMessage("Thank you for using Rewatch!");
		rewatch:Message("|cffff7d0aThank you for using Rewatch!|r");
		rewatch:Message("You can open the options menu using \"/rewatch options\".");
		rewatch:Message("Tip: be sure to check out mouse-over macros or Clique - it's the way Rewatch was meant to be used!");

		rewatch_config =
		{
			version = rewatch.version,
			position = { x = 100, y = 100 },
			profiles = {},
			profile = {}
		};

	-- updating users
	elseif(rewatch_config.version < rewatch.version) then

		rewatch:Message("Thank you for updating Rewatch!");
		rewatch_config.version = rewatch.version;

	end;

	rewatch.loaded = true;
	rewatch.options = RewatchOptions:new();
	rewatch.profile = RewatchProfile:new();
	rewatch.frame = RewatchFrame:new();
	
	rewatch.frame:ProcessGroup();

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