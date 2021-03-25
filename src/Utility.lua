-- display a message to the user in the chat pane
rewatch.Message = function(self, message)
	
	DEFAULT_CHAT_FRAME:AddMessage("Rw: "..message, 1, 1, 1);

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

	return value * (rewatch.profile.scaling/100);

end;

-- get the corresponding colour for the power type
rewatch.GetPowerBarColor = function(self, powerType)

	-- prettier colors!
	if(powerType == 0 or powerType == "MANA") then return { r = 0.24, g = 0.35, b = 0.49 }; end;
	if(powerType == 1 or powerType == "RAGE") then return { r = 0.52, g = 0.17, b = 0.17 }; end;
	if(powerType == 3 or powerType == "ENERGY") then return { r = 0.5, g = 0.48, b = 0.27 }; end;
	
	-- return standard colors
	return PowerBarColor[powerType];
	
end;

-- pops up a tooltip for a player
rewatch.SetPlayerTooltip = function(self, guid)
	
	if(not rewatch.profile.showTooltips) then return; end;

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetUnit(rewatch.players[guid].player);

end;

-- pops up a tooltip for a spell
rewatch.SetSpellTooltip = function(self, spellName)

	if(not rewatch.profile.showTooltips) then return; end;

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