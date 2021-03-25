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

local r, g, b, a, val, n;
local playerId, debuffType, debuffIcon, debuffDuration, role;
local d, x, y, v, left, i, currentTarget, currentTime;

rewatch.events:SetScript("OnEvent", function(self, event, unitGUID)
	
	-- let's catch incombat here
	if(event == "PLAYER_REGEN_ENABLED") then rewatch.inCombat = false;
	elseif(event == "PLAYER_REGEN_DISABLED") then rewatch.inCombat = true; end;
	
	-- only process if properly loaded
	if(not rewatch.loaded) then return; end;
	
	if(rewatch.loaded) then return; end; -- debug

	-- switched talent/dual spec
	if((event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "ACTIVE_TALENT_GROUP_CHANGED")) then
	
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
		if((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then
			
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

rewatch.events:SetScript("OnUpdate", function(self)
    
	if(not rewatch.loaded) then
	
		rewatch:Init();
		return;
		
	end;

	if(rewatch.loaded) then return; end; -- debug

	-- clearing and reprocessing the frames
	if(not rewatch.inCombat) then
	
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