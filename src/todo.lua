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