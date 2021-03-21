RewatchFrame = {};
RewatchFrame.__index = RewatchFrame;

function RewatchFrame:new()
    
    local self =
    {
        frame = CreateFrame("Frame", "Rewatch_Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate"),

        buttonSize = nil,
        frameWidth = nil,
    };

    setmetatable(self, RewatchFrame);

    self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100);
    self.frame:SetWidth(1);
    self.frame:SetHeight(1);
    self.frame:EnableMouse(true);
    self.frame:SetMovable(true);
    self.frame:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
    self.frame:SetBackdropColor(1, 0.49, 0.04, 0);
    self.frame:SetScript("OnEnter", function() self.frame:SetBackdropColor(1, 0.49, 0.04, 1); end);
    self.frame:SetScript("OnLeave", function() self.frame:SetBackdropColor(1, 0.49, 0.04, 0); end);

    local function OnMouseDown(_, button)

        if(button == "LeftButton" and not rewatch_config["Lock"]) then
            self.frame:StartMoving();
        end;
    
        if(button == "RightButton") then
            if(rewatch_config["Lock"]) then
                rewatch_config["Lock"] = false;
                rewatch:Message("Unlocked main frame");
            else
                rewatch_config["Lock"] = true;
                rewatch:Message("Locked main frame");
            end;
        end;
    
    end;
    
    local function OnMouseUp()
    
        self.frame:StopMovingOrSizing();
    
        rewatch_config["Position"].x = self.frame:GetLeft();
        rewatch_config["Position"].y = self.frame:GetTop();
    
    end;

    self.frame:SetScript("OnMouseDown", OnMouseDown);
    self.frame:SetScript("OnMouseUp", OnMouseUp);

    return self;

end;

-- update frame dimensions and render everything
function RewatchFrame:Render()

	local buttonCount, barCount, playerCount = 0, 0, 0;
	
	for _ in pairs(rewatch.profile["Buttons"]) do buttonCount = count + 1 end;
	for _ in pairs(rewatch.profile["Bars"]) do barCount = barCount + 1 end;
	for _ in pairs(rewatch.players) do playerCount = playerCount + 1 end;

	-- recalculate total frame sizes
	if(rewatch_config["Layout"] == "horizontal") then
	
		self.buttonSize = rewatch:Scale(rewatch_config["SpellBarWidth"] / buttonCount);
		self.frameWidth = rewatch:Scale(rewatch_config["SpellBarWidth"]);

		self.frameHeight = rewatch:Scale
		(
			rewatch_config["HealthBarHeight"]
			+ (rewatch_config["SpellBarHeight"] * barCount)
			+ self.buttonSize *rewatch_config["ShowButtons"]
		);
		
	elseif(rewatch_config["Layout"] == "vertical") then
		
		self.buttonSize = rewatch:Scale(rewatch_config["HealthBarHeight"] / buttonCount);
		self.frameHeight = rewatch:Scale(rewatch_config["SpellBarWidth"]);
		
		self.frameWidth = rewatch:Scale
		(
			rewatch_config["HealthBarHeight"]
			+ (rewatch_config["SpellBarHeight"] * barCount)
		);

	end;

	-- set frame dimensions
	if(rewatch_config["FrameColumns"] == 1) then

		self.frame:SetHeight(rewatch.Scale(10) + (math.min(rewatch_config["NumFramesWide"],  math.max(playerCount, 1)) * self.frameHeight));
		self.frame:SetWidth(1 + (math.ceil(playerCount/rewatch_config["NumFramesWide"]) * self.frameWidth));

	else

		self.frame:SetHeight(rewatch.Scale(10) + (math.ceil(playerCount/rewatch_config["NumFramesWide"]) * self.frameHeight));
		self.frame:SetWidth(1 + (math.min(rewatch_config["NumFramesWide"], math.max(playerCount, 1)) * self.frameWidth));

	end;
	
	-- set frame position
	self.frame:ClearAllPoints();
	self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config["Position"].x, rewatch_config["Position"].y-UIParent:GetHeight());

end;