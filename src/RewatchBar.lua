RewatchBar = {}
RewatchBar.__index = RewatchBar

function RewatchBar:new(spell, parent, anchor, color)

	local self =
	{
		bar = CreateFrame("STATUSBAR", nil, parent.frame, "TextStatusBar"),

		spell = spell,
		color = color
	}

	setmetatable(self, RewatchBar)

	self.bar:SetStatusBarTexture(rewatch.options.profile.bar)
	self.bar:GetStatusBarTexture():SetHorizTile(false)
	self.bar:GetStatusBarTexture():SetVertTile(false)
	
	-- arrange layout
	if(rewatch.options.profile.layout == "horizontal") then
		self.bar:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.bar:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarHeight))
		self.bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
		self.bar:SetOrientation("horizontal")
	else
		self.bar:SetHeight(rewatch:Scale(rewatch.options.profile.spellBarWidth))
		self.bar:SetWidth(rewatch:Scale(rewatch.options.profile.spellBarHeight))
		self.bar:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
		self.bar:SetOrientation("vertical")
	end
	
	-- create bar border
	self.border = CreateFrame("FRAME", nil, self.bar, BackdropTemplateMixin and "BackdropTemplate")
	self.border:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 2, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	self.border:SetBackdropBorderColor(1, 1, 1, 0)
	self.border:SetWidth(self.bar:GetWidth()+1)
	self.border:SetHeight(self.bar:GetHeight()+1)
	self.border:SetPoint("TOPLEFT", self.bar, "TOPLEFT", -0, 0)
	
	-- bar color
	self.bar:SetStatusBarColor(color.r, color.g, color.b, rewatch.options.profile.PBOAlpha)
	
	-- set bar reach
	self.bar:SetMinMaxValues(0, 1)
	self.bar:SetValue(1)
	
	-- -- if this was reju, add a tiny germination sidebar to it
	-- if(spellName == rewatch_loc["rejuvenation"]) then
	
	-- 	-- create the tiny bar
	-- 	self.sidebar = CreateFrame("STATUSBAR", nil, self.bar, "TextStatusBar")
	-- 	self.sidebar:SetStatusBarTexture(rewatch.options.profile["Bar"])
	-- 	self.sidebar:GetStatusBarTexture():SetHorizTile(false)
	-- 	self.sidebar:GetStatusBarTexture():SetVertTile(false)
		
	-- 	-- adjust to layout
	-- 	if(rewatch.options.profile.layout == "horizontal") then
	-- 		self.sidebar:SetWidth(self.bar:GetWidth())
	-- 		self.sidebar:SetHeight(self.bar:GetHeight() * 0.33)
	-- 		self.sidebar:SetPoint("TOPLEFT", self.bar, "BOTTOMLEFT", 0, self.bar:GetHeight() * 0.33)
	-- 		self.sidebar:SetOrientation("horizontal")
	-- 	elseif(rewatch.options.profile["Layout"] == "vertical") then
	-- 		self.sidebar:SetWidth(self.bar:GetWidth() * 0.33)
	-- 		self.sidebar:SetHeight(self.bar:GetHeight())
	-- 		self.sidebar:SetPoint("TOPLEFT", self.bar, "TOPRIGHT", -(self.bar:GetWidth() * 0.33), 0)
	-- 		self.sidebar:SetOrientation("vertical")
	-- 	end;
		
	-- 	-- bar color
	-- 	self.sidebar:SetStatusBarColor(1-rewatch_colors.bars[i].r, 1-rewatch_colors.bars[i].g, 1-rewatch_colors.bars[i].b, rewatch.options.profile["PBOAlpha"])
		
	-- 	-- bar reach
	-- 	result.sidebar:SetMinMaxValues(0, 1)
	-- 	result.sidebar:SetValue(0)
		
	-- 	-- put text in bar
	-- 	result.sidebar.text = result.bar:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	-- 	result.sidebar.text:SetPoint("RIGHT", result.sidebar)
	-- 	result.sidebar.text:SetAllPoints()
	-- 	result.sidebar.text:SetText("")

	-- end;
	
	-- overlay cast button
	local bc = CreateFrame("BUTTON", nil, self.bar, "SecureActionButtonTemplate")
	bc:SetWidth(self.bar:GetWidth())
	bc:SetHeight(self.bar:GetHeight())
	bc:SetPoint("TOPLEFT", self.bar, "TOPLEFT", 0, 0)
	bc:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	bc:SetAttribute("type1", "spell")
	bc:SetAttribute("unit", parent.name)
	bc:SetAttribute("spell1", spell)
	bc:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp")
	
	-- put text in bar
	self.bar.text = bc:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
	self.bar.text:SetPoint("RIGHT", bc)
	self.bar.text:SetAllPoints()
	self.bar.text:SetAlpha(1)
	self.bar.text:SetText("")

	-- apply tooltip support
	bc:SetScript("OnEnter", function() bc:SetAlpha(0.2); rewatch:SetSpellTooltip(spell) end)
	bc:SetScript("OnLeave", function() bc:SetAlpha(1); GameTooltip:Hide() end)

	return self

end






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