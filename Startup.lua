rewatch = Rewatch:new()

local setup = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

setup:SetScript("OnUpdate", function(_, elapsed)
	
	if(not rewatch.loaded) then rewatch:Init() end

	setup:UnregisterAllEvents()
	setup:Hide()
	setup = nil

end)