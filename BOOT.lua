rewatch = Rewatch:new()

rewatch.events = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

rewatch.events:SetWidth(0)
rewatch.events:SetHeight(0)

rewatch.events:SetScript("OnUpdate", function(self)
    
	if(not rewatch.loaded) then
	
		rewatch:Init();
		return;
		
	end;

	if(rewatch.loaded) then return; end; -- debug
	

	-- process updates
	for i=1,rewatch_i-1 do
	
		v = rewatch_bars[i];
	
		-- if this player exists
		if(v) then

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