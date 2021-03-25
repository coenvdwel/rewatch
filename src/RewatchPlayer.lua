RewatchPlayer = {};
RewatchPlayer.__index = RewatchPlayer;

function RewatchPlayer:Position(i)

	return 0, 0;

end;

function RewatchPlayer:new(frame, guid, player, i)

    -- todo; remove Mark
	-- todo; then what's with our own role icon tank/healer.tga's?
	-- todo; make something better than /rew add henk always
    -- todo; combat check before calling this
	-- todo; catch events like player role changed or shapeshifts (manabar)

	--playerBarInc = statusbarinc,
	--playerBar = statusbar,
	--manaBar = manabar,
	--notify = nil,
	--notify2 = nil,
	--notify3 = nil,
	--debuff = nil,
	--debuffTexture = debuffTexture,
	--debuffDuration = nil,
	--hover = 0,
	--bars = {},
	--buttons = {}

	local self =
    {
        frame = CreateFrame("Frame", nil, frame.frame, BackdropTemplateMixin and "BackdropTemplate"),

		guid = guid,
        player = player,
		classId = select(3, UnitClass(player)),
        name = player
    };

	setmetatable(self, RewatchPlayer);

	local powerType = rewatch:GetPowerBarColor(UnitPowerType(player));
	local classColors = RAID_CLASS_COLORS[select(2, GetClassInfo(self.classId or 11))];
	local x, y = self:Position(i);

	-- determine display name
	if(self.name:find("-")) then self.name = self.name:sub(1, self.name:find("-")-1).."*"; end;

	self.frame:SetWidth(frame.width);
	self.frame:SetHeight(frame.height);
	self.frame:SetPoint("TOPLEFT", frame.frame, "TOPLEFT", x, y);
	self.frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	self.frame:SetBackdropColor(0.07, 0.07, 0.07, 1);
	
	-- create player HP bar for estimated incoming health
	self.playerBarInc = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar");

	if(rewatch.profile.layout == "horizontal") then
		self.playerBarInc:SetWidth(rewatch:Scale(rewatch.profile.spellBarWidth));
		self.playerBarInc:SetHeight(rewatch:Scale(rewatch.profile.healthBarHeight * 0.8));
	elseif(rewatch.profile.layout == "vertical") then 
		self.playerBarInc:SetHeight(rewatch:Scale(rewatch.profile.spellBarWidth * 0.8) - (rewatch.profile.showButtons and frame.buttonSize or 0));
		self.playerBarInc:SetWidth(rewatch:Scale(rewatch.profile.healthBarHeight));
	end;

	self.playerBarInc:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0);
	self.playerBarInc:SetStatusBarTexture(rewatch.profile.bar);
	self.playerBarInc:GetStatusBarTexture():SetHorizTile(false);
	self.playerBarInc:GetStatusBarTexture():SetVertTile(false);
	self.playerBarInc:SetStatusBarColor(0.4, 1, 0.4, 1);
	self.playerBarInc:SetMinMaxValues(0, 1);
	self.playerBarInc:SetValue(0);
		
	-- create player HP bar
	self.playerBar = CreateFrame("STATUSBAR", nil, self.playerBarInc, "TextStatusBar");

	self.playerBar:SetWidth(self.playerBarInc:GetWidth());
	self.playerBar:SetHeight(self.playerBarInc:GetHeight());
	self.playerBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0);
	self.playerBar:SetStatusBarTexture(rewatch.profile.bar);
	self.playerBar:GetStatusBarTexture():SetHorizTile(false);
	self.playerBar:GetStatusBarTexture():SetVertTile(false);
	self.playerBar:SetStatusBarColor(0.07, 0.07, 0.07, 1);
	self.playerBar:SetMinMaxValues(0, 1);
	self.playerBar:SetValue(0);

	-- put text in HP bar
	self.playerBar.text = self.playerBar:CreateFontString("$parentText", "ARTWORK");
	self.playerBar.text:SetFont(rewatch.profile.font, rewatch:Scale(rewatch.profile.fontSize), "OUTLINE");
	self.playerBar.text:SetAllPoints();
	self.playerBar.text:SetText(name);
	self.playerBar.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1);
	
	-- role icon
	local roleIcon = self.playerBar:CreateTexture(nil, "OVERLAY");
	local role = UnitGroupRolesAssigned(player);

	roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES");
	roleIcon:SetSize(16, 16);
	roleIcon:SetPoint("TOPLEFT", self.playerBar, "TOPLEFT", 10, 8-self.playerBar:GetHeight()/2);
	
	if(role == "TANK") then
		roleIcon:SetTexCoord(0, 19/64, 22/64, 41/64);
		roleIcon:Show();
	elseif(role == "HEALER") then
		roleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		roleIcon:Show();
	else
		roleIcon:Hide();
	end;
	
	-- debuff icon
	local debuffIcon = CreateFrame("Frame", nil, self.playerBar, BackdropTemplateMixin and "BackdropTemplate");
	
	debuffIcon:SetWidth(16);
	debuffIcon:SetHeight(16);
	debuffIcon:SetPoint("TOPRIGHT", self.playerBar, "TOPRIGHT", -10, 8-self.playerBar:GetHeight()/2);
	debuffIcon:SetAlpha(0.8);

	-- debuff texture
	self.debuffTexture = debuffIcon:CreateTexture(nil, "ARTWORK");
	self.debuffTexture:SetAllPoints();
	
	-- create mana bar
	self.manaBar = CreateFrame("STATUSBAR", nil, self.frame, "TextStatusBar");

	if(rewatch.profile.layout == "horizontal") then
		self.manaBar:SetWidth(rewatch:Scale(rewatch.profile.spellBarWidth));
		self.manaBar:SetHeight(rewatch:Scale(rewatch.profile.healthBarHeight * 0.2));
	elseif(rewatch.profile.layout == "vertical") then
		self.manaBar:SetWidth(rewatch:Scale(rewatch.profile.healthBarHeight));
		self.manaBar:SetHeight(rewatch:Scale(rewatch.profile.spellBarWidth * 0.2));
	end;

	self.manaBar:SetPoint("TOPLEFT", self.playerBar, "BOTTOMLEFT", 0, 0);
	self.manaBar:SetStatusBarTexture(rewatch.profile.bar);
	self.manaBar:GetStatusBarTexture():SetHorizTile(false);
	self.manaBar:GetStatusBarTexture():SetVertTile(false);
	self.manaBar:SetMinMaxValues(0, 1);
	self.manaBar:SetValue(0);
	self.manaBar:SetStatusBarColor(powerType.r, powerType.g, powerType.b);

	-- create aggro bar
	self.aggroBar = CreateFrame("STATUSBAR", nil, self.manaBar, "TextStatusBar");

	self.aggroBar:SetPoint("TOPLEFT", self.manaBar, "TOPLEFT", 0, 0);
	self.aggroBar:SetHeight(2);
	self.aggroBar:SetWidth(self.manaBar:GetWidth());
	self.aggroBar:SetStatusBarTexture(rewatch.profile.bar);
	self.aggroBar:GetStatusBarTexture():SetHorizTile(false);
	self.aggroBar:GetStatusBarTexture():SetVertTile(false);
	self.aggroBar:SetMinMaxValues(0, 1);
	self.aggroBar:SetValue(0);
	self.aggroBar:SetStatusBarColor(1, 0, 0);

	-- build border frame
	self.border = CreateFrame("FRAME", nil, self.playerBar, BackdropTemplateMixin and "BackdropTemplate");

	self.border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	self.border:SetBackdropBorderColor(0, 0, 0, 1);
	self.border:SetWidth(frame.width+1);
	self.border:SetHeight(frame.height+1);
	self.border:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -0, 0);

	-- bars
	self.bars = {};

	local anchor = self.playerBar;
	if(rewatch.profile.layout == "horizontal") then anchor = self.manaBar; end;

	for i,spell in pairs(rewatch.profile.bars) do
		self.bars[spell] = RewatchBar:new(spell, rewatch_i, anchor, i);
		anchor = self.bars[spell].bar;
	end;
	
	-- buttons
	if(rewatch.profile.showButtons == 1) then

		self.buttons = {};

		if(rewatch.profile.layout == "vertical") then anchor = self.manaBar; end;

		for i,spell in pairs(rewatch.profile["ButtonSpells"..rewatch.profile["ClassId"]]) do

			if(rewatch.classId == 7 and rewatch.spec ~= 3) then
				if(spell == rewatch_loc["naturescure"]) then spell = rewatch_loc["removecorruption"];
				elseif(spell == rewatch_loc["ironbark"]) then spell = rewatch_loc["barkskin"];
				end;
			end;

			if(select(3, GetSpellInfo(spellName))) then
				rewatch_bars[rewatch_i]["Buttons"][spell] = rewatch_CreateButton(spell, rewatch_i, anchor, i);
			end;

		end;
	end;
	
	-- overlay target/remove button
	local overlay = CreateFrame("BUTTON", nil, self.playerBar, "SecureActionButtonTemplate");

	overlay:SetWidth(self.playerBar:GetWidth());
	overlay:SetHeight(self.playerBar:GetHeight()*1.25);
	overlay:SetPoint("TOPLEFT", self.playerBar, "TOPLEFT", 0, 0);
	overlay:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp");
	overlay:SetAlpha(0.05);
	
	overlay:SetAttribute("type1", "target");
	overlay:SetAttribute("unit", player);
	overlay:SetAttribute("alt-type1", "macro");
	overlay:SetAttribute("alt-macrotext1", rewatch.profile.altMacro);
	overlay:SetAttribute("ctrl-type1", "macro");
	overlay:SetAttribute("ctrl-macrotext1", rewatch.profile.ctrlMacro);
	overlay:SetAttribute("shift-type1", "macro");
	overlay:SetAttribute("shift-macrotext1", rewatch.profile.shiftMacro);
	
	overlay:SetScript("OnEnter", function()
		local playerId = rewatch:GetPlayerId(player);
		if(playerId > 0) then
			rewatch:SetPlayerTooltip(playerId);
			rewatch_bars[playerId]["Hover"] = 1;
		end;
	end);
	
	overlay:SetScript("OnLeave", function()
		GameTooltip:Hide();
		local playerId = rewatch:GetPlayerId(player);
		if(playerId > 0) then
			rewatch_bars[rewatch:GetPlayerId(player)]["Hover"] = 2;
		end;
	end);
	
	rewatch.players[guid] = self;
	
    return self;

end;

-- update frame dimensions and render everything
function RewatchPlayer:Render()


    -- move into position

end;

-- sets the background color of this player's frame
function RewatchPlayer:SetFrameBG()

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
	else rewatch.players[guid].frame:SetBackdropColor(0.07, 0.07, 0.07, 1); end;
	
end;
