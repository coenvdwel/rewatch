rewatch = Rewatch:new()

local setup = CreateFrame("FRAME")

setup:SetScript("OnUpdate", function(_, elapsed)

	rewatch:Debug("RewatchStartup")

	local guid = UnitGUID("player")
	local name = UnitName("player")

	if(not guid or not name) then return end

	setup:UnregisterAllEvents()
	setup:Hide()
	setup = nil

	rewatch:Init()
	
end)