-- sets the background color of this player's frame
rewatch.SetFrameBG = function(self, guid)

	-- high prio warning
	if(rewatch.players[guid].notify3) then rewatch.players[guid].frame:SetBackdropColor(1.0, 0.0, 0.0, 1);
		
	-- debuff warning
	elseif(rewatch.players[guid].debuff) then
	
		if(rewatch.players[guid].debuffType == "Poison") then rewatch.players[guid].frame:SetBackdropColor(0.0, 0.3, 0, 1);
		elseif(rewatch.players[guid].debuffType == "Curse") then rewatch.players[guid].frame:SetBackdropColor(0.5, 0.0, 0.5, 1);
		elseif(rewatch.players[guid].debuffType == "Magic") then rewatch.players[guid].frame:SetBackdropColor(0.0, 0.0, 0.5, 1);
		elseif(rewatch.players[guid].debuffType == "Disease") then rewatch.players[guid].frame:SetBackdropColor(0.5, 0.5, 0.0, 1);
		end;
		
	-- medium/ow prio warning
	elseif(rewatch.players[guid].notify2) then rewatch.players[guid].frame:SetBackdropColor(1.0, 0.5, 0.1, 1);
	elseif(rewatch.players[guid].notify) then rewatch.players[guid].frame:SetBackdropColor(0.9, 0.8, 0.2, 1);
		
	-- default
	else rewatch.players[guid].frame:SetBackdropColor(rewatch_colors.frame.r, rewatch_colors.frame.g, rewatch_colors.frame.b, rewatch_colors.frame.a); end;
	
end;
