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
-- todo; add / layout cmds
-- todo; add mana size bar option

rewatch =
{
	version = 80000,

	guid = nil,
	player = nil,
	classId = nil,
	spec = nil,

	loaded = false,
	cmd = nil,
	options = nil,
	profile = nil,
	frame = nil,

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

-- initialize addon
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
		rewatch:Message("You can open the options menu using |cffff7d0a/rewatch options|r.");
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
	rewatch.cmd = RewatchCommandLine:new();
	rewatch.options = RewatchOptions:new();
	rewatch.frame = RewatchFrame:new();
	
	rewatch.frame:ProcessGroup();

end;

-- display a message to the user in the chat pane
rewatch.Message = function(self, message)
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffff7d0aRw|r: "..message, 1, 1, 1);

end;

-- displays a message to the user in the raidwarning frame
rewatch.RaidMessage = function(self, message)

	RaidNotice_AddMessage(RaidWarningFrame, message, { r = 1, g = 0.49, b = 0.04 });

end;

-- announce an action to the chat, preferring SAY but falling back to EMOTE & WHISPER
rewatch.Announce = function(self, action, playerName)

	if(select(1, IsInInstance())) then
		SendChatMessage("I'm "..action.." "..playerName.."!", "SAY");
	else
		SendChatMessage("is "..action.." "..playerName.."!", "EMOTE");
		SendChatMessage("I'm "..action.." you!", "WHISPER", nil, playerName);
	end;

end;

-- return a scaled config value
rewatch.Scale = function(self, value)

	return value * (rewatch.options.profile.scaling/100);

end;

-- get the corresponding colour for the power type
rewatch.GetPowerBarColor = function(self, powerType)

	-- prettier colors!
	if(powerType == 0 or powerType == "MANA") then return { r = 0.24, g = 0.35, b = 0.49 }; end;
	if(powerType == 1 or powerType == "RAGE") then return { r = 0.52, g = 0.17, b = 0.17 }; end;
	if(powerType == 3 or powerType == "ENERGY") then return { r = 0.5, g = 0.48, b = 0.27 }; end;
	
	-- return boring standard colors
	return PowerBarColor[powerType];
	
end;

-- pops up a tooltip for a player
rewatch.SetPlayerTooltip = function(self, guid)
	
	if(not rewatch.options.profile.showTooltips) then return; end;

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetUnit(rewatch.players[guid].player);

end;

-- pops up a tooltip for a spell
rewatch.SetSpellTooltip = function(self, spellName)

	if(not rewatch.options.profile.showTooltips) then return; end;

	local spellId, found = 1, false;

	while not found do
	   local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL);
	   if (not spell) then break; end;
	   if (spell == spellName) then found = true; break; end;
	   spellId = spellId + 1;
	end;

	if(found) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetSpellBookItem(spellId, BOOKTYPE_SPELL);
	end;

end

-- checks if the player or pet is in the group
rewatch.InGroup = function(self, playerName)

	if(rewatch.player == playerName) then return true; end;
	if(UnitPlayerOrPetInRaid(playerName)) then return true; end;
	if(UnitPlayerOrPetInParty(playerName)) then return true; end;

	return false;
	
end;

-- generate a random new uuid
rewatch.NewId = function(self)

    return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end);

end;