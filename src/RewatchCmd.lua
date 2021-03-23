SLASH_REWATCH1 = "/rewatch";
SLASH_REWATCH2 = "/rew";

SlashCmdList["REWATCH"] = function(cmd)

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