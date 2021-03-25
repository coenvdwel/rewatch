RewatchBar = {};
RewatchBar.__index = RewatchBar;

local colors =
{
	{ r=0; g=0.7; b=0, a=1 }, -- lifebloom
	{ r=0.85; g=0.15; b=0.80, a=1 }, -- reju
	{ r=0.4; g=0.85; b=0.34, a=1 }, -- germ
	{ r=0.05; g=0.3; b=0.1, a=1 }, -- regrowth
	{ r=0.5; g=0.8; b=0.3, a=1 }, -- wild growth
	{ r=0.0; g=0.1; b=0.8, a=1 }  -- riptide
};

function RewatchBar:new(spellName, playerId, relative, i)

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

-- get expirationTime of buff 
local function rewatch_GetBuffExpirationTime(player, spellName)

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
local function rewatch_GetDebuffInfo(player, spellName)

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

function RewatchBar:Update()

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

function RewatchBar:Downdate(spellName, playerId)

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