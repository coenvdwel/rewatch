RewatchFrame = {};
RewatchFrame.__index = RewatchFrame;

function RewatchFrame:new()
    
    local self =
    {
        frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate"),

        width = nil,
        height = nil,
        buttonSize = nil
    };

    setmetatable(self, RewatchFrame);

    self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y);
    self.frame:SetWidth(1);
    self.frame:SetHeight(1);
    self.frame:EnableMouse(true);
    self.frame:SetMovable(true);
    self.frame:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
    self.frame:SetBackdropColor(1, 0.49, 0.04, 0);
    self.frame:SetScript("OnEnter", function() self.frame:SetBackdropColor(1, 0.49, 0.04, 1); end);
    self.frame:SetScript("OnLeave", function() self.frame:SetBackdropColor(1, 0.49, 0.04, 0); end);

    self.frame:SetScript("OnMouseDown", function(_, button)

        if(button == "LeftButton" and not rewatch.locked) then
            self.frame:StartMoving();
        end;
    
        if(button == "RightButton") then
            if(rewatch.locked) then
                rewatch.locked = false;
                rewatch:Message("Unlocked frame");
            else
                rewatch.locked = true;
                rewatch:Message("Locked frame");
            end;
        end;
    
    end);

    self.frame:SetScript("OnMouseUp", function()
    
        self.frame:StopMovingOrSizing();
    
        rewatch_config.position.x = self.frame:GetLeft();
        rewatch_config.position.y = self.frame:GetTop();
    
    end);

    self:Apply();

    return self;

end;

-- calculate frame size
function RewatchFrame:Apply()

    local buttonCount, barCount = 0, 0;
	
	for _ in pairs(rewatch.options.profile.buttons) do buttonCount = buttonCount + 1 end;
	for _ in pairs(rewatch.options.profile.bars) do barCount = barCount + 1 end;

	-- recalculate total frame sizes
	if(rewatch.options.profile.layout == "horizontal") then
	
		self.width = rewatch:Scale(rewatch.options.profile.spellBarWidth);
		self.height = rewatch:Scale(rewatch.options.profile.healthBarHeight + (rewatch.options.profile.spellBarHeight * barCount) + self.buttonSize * rewatch.options.profile.showButtons);
		self.buttonSize = rewatch:Scale(rewatch.options.profile.spellBarWidth / buttonCount);

	elseif(rewatch.options.profile.layout == "vertical") then
		
		self.height = rewatch:Scale(rewatch.options.profile.spellBarWidth);
		self.width = rewatch:Scale(rewatch.options.profile.healthBarHeight + (rewatch.options.profile.spellBarHeight * barCount));
        self.buttonSize = rewatch:Scale(rewatch.options.profile.healthBarHeight / buttonCount);

	end;

end;

-- render everything
function RewatchFrame:Render()

	local playerCount = 0;

	for _ in pairs(rewatch.players) do playerCount = playerCount + 1 end;

	-- set frame dimensions
	if(rewatch.options.profile.frameColumns == 1) then

		self.frame:SetHeight(rewatch:Scale(10) + (math.min(rewatch.options.profile.numFramesWide,  math.max(playerCount, 1)) * self.height));
		self.frame:SetWidth(1 + (math.ceil(playerCount/rewatch.options.profile.numFramesWide) * self.width));

	else

		self.frame:SetHeight(rewatch:Scale(10) + (math.ceil(playerCount/rewatch.options.profile.numFramesWide) * self.height));
		self.frame:SetWidth(1 + (math.min(rewatch.options.profile.numFramesWide, math.max(playerCount, 1)) * self.width));

	end;
	
	-- set frame position
	self.frame:ClearAllPoints();
	self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y-UIParent:GetHeight());

end;

-- compares the current player table to the party/raid schedule
function RewatchFrame:ProcessGroup()

    local i = 1;

	if(not rewatch.players[rewatch.guid]) then
		rewatch.players[rewatch.guid] = RewatchPlayer:new(rewatch.guid, rewatch.player, i);
		i = i + 1;
	end;

    --local render = false;
	--local deletes, tanks, healers, rest = {}, {}, {}, {};

	-- local name, i, n;
	-- local names = {};
	
	-- -- remove non-grouped players
	-- for i=1,rewatch_i-1 do if(rewatch_bars[i]) then
	-- 	if(not (rewatch_InGroup(rewatch_bars[i]["Player"]) or rewatch_bars[i]["Pet"])) then rewatch_HidePlayer(i); end;
	-- end; end;

	-- -- add self
	-- if((rewatch_i == 1) and (rewatch_loadInt["ShowSelfFirst"] == 1)) then
	-- 	rewatch_AddPlayer(UnitName("player"), nil);
	-- end;

	-- -- process raid group
	-- if(IsInRaid()) then

	-- 	n = GetNumGroupMembers();

	-- 	-- for each group member, if he's not in the list, add him
	-- 	for i=1, n do
	-- 		name = GetRaidRosterInfo(i);
	-- 		if((name) and (rewatch:GetPlayerId(name) == -1)) then
	-- 			table.insert(names, name);
	-- 		end;
	-- 	end;

	-- -- process party group (only when not in a raid)
	-- else

	-- 	n = GetNumSubgroupMembers();

	-- 	-- for each group member, if he's not in the list, add him
	-- 	for i=1, n + 1 do
	-- 		if(i > n) then name = UnitName("player"); else name = UnitName("party"..i); end;
	-- 		if((name) and (rewatch:GetPlayerId(name) == -1)) then
	-- 			table.insert(names, name);
	-- 		end;
	-- 	end;

	-- end;

	-- -- sort by role
	-- if(rewatch_loadInt["SortByRole"] == 1) then

	-- 	local healers, tanks, others = {}, {}, {};

	-- 	for i, name in pairs(names) do
	-- 		role = UnitGroupRolesAssigned(name);
	-- 		if(role == "TANK") then
	-- 			table.insert(tanks, name);
	-- 		elseif(role == "HEALER") then
	-- 			table.insert(healers, name);
	-- 		else table.insert(others, name); end;
	-- 	end;

	-- 	-- add players
	-- 	rewatch_AddPlayers(tanks);
	-- 	rewatch_AddPlayers(healers);
	-- 	rewatch_AddPlayers(others);

	-- -- or just by groups
	-- else
	-- 	rewatch_AddPlayers(names);
	-- end;
	
end;