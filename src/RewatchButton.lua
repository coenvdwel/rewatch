RewatchButton = {}
RewatchButton.__index = RewatchButton

function RewatchButton:new(spellName, playerId, relative, offset)

	local self = 
	{

	}

	setmetatable(self, RewatchButton)

	-- build button
	local button = CreateFrame("BUTTON", nil, rewatch_bars[playerId]["Frame"], "SecureActionButtonTemplate")
	button:SetWidth(rewatch_loadInt["ButtonSize"])
	button:SetHeight(rewatch_loadInt["ButtonSize"])
	button:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", rewatch_loadInt["ButtonSize"]*(offset-1), 0)
	
	-- arrange clicking
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	button:SetAttribute("unit", rewatch_bars[playerId]["Player"])
	button:SetAttribute("type1", "spell")
	button:SetAttribute("spell1", spellName)
	
	-- texture
	button:SetNormalTexture(select(3, GetSpellInfo(spellName)))
	button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	
	-- transparency for highlighting icons
	if(spellName == rewatch.locale["removecorruption"]) then button:SetAlpha(0.2)
	elseif(spellName == rewatch.locale["naturescure"]) then button:SetAlpha(0.2)
	elseif(spellName == rewatch.locale["purifyspirit"]) then button:SetAlpha(0.2)
	end
	
	-- apply tooltip support
	button:SetScript("OnEnter", function() rewatch:SetSpellTooltip(spellName) end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- relate spell to button
	button.spellName = spellName
	
	-- add cooldown overlay
	button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cooldown:SetPoint("CENTER", 0, -1)
	button.cooldown:SetWidth(button:GetWidth())
	button.cooldown:SetHeight(button:GetHeight())
	button.cooldown:Hide()

    return self

end

-- update frame dimensions and render everything
function RewatchButton:Render()

	-- todo
	
end