rewatch = Rewatch:new()

local setup = CreateFrame("FRAME")

setup:SetScript("OnUpdate", function(_, elapsed)

	rewatch:Debug("RewatchStartup")

	local guid = UnitGUID("player")
	if(not guid) then return end

	local name = UnitName("player")
	if(not name) then return end

	local classId = select(3, UnitClass(name))
	if(not classId) then return end

	local classColor = select(2, GetClassInfo(classId))
	if(not classColor) then return end

	setup:UnregisterAllEvents()
	setup:Hide()
	setup = nil

	rewatch:Init()

end)