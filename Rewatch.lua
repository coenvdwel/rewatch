-- todo: cleanup localizations
-- todo: hidden/hide solo as part of layouts
-- todo: activate layouts through commandline
-- todo: doublecheck no use of rewatch_loadInt remains
-- todo: improve fixed color list
-- todo: add / layout cmds
-- todo: add mana size bar option
-- todo: dispose tree
-- todo: germination bar
-- todo: then what's with our own role icon tank/healer.tga's?
-- todo: make something better than /rew add henk always
-- todo: catch events like player role changed or shapeshifts (manabar)
-- todo: add some mythic helpers (affixes, default spells, ...)

rewatch =
{
	version = 80000,

	-- player variables
	guid = nil,
	name = nil,
	classId = nil,
	spec = nil,

	-- flags
	loaded = false,
	locked = false,
	inCombat = false,
	changed = false,

	-- modules
	cmd = nil,
	options = nil,
	profile = nil,
	frame = nil,
	events = nil,
	players = {},
	locale = {},

	-- other
	playerWidth = nil,
	playerHeight = nil,
	buttonSize = nil,
	--clear = false,
	--rezzing = "",
	--swiftmend_cast = 0,

	-- init
	Init = function()

		rewatch.guid = UnitGUID("player")
		rewatch.name = UnitName("player")
		rewatch.classId = select(3, UnitClass("player"))
		rewatch.spec = GetSpecialization()
	
		if(not rewatch.guid) then return end
		
		rewatch.loaded = true

		-- new users
		if(not rewatch_config) then
	
			rewatch:RaidMessage("Thank you for using Rewatch!")
			rewatch:Message("|cffff7d0aThank you for using Rewatch!|r")
			rewatch:Message("You can open the options menu using |cffff7d0a/rewatch options|r.")
			rewatch:Message("Tip: be sure to check out mouse-over macros or Clique - it's the way Rewatch was meant to be used!")
	
			rewatch_config =
			{
				version = rewatch.version,
				position = { x = 100, y = 100 },
				profiles = {},
				profile = {}
			}
	
		-- updating users
		elseif(rewatch_config.version < rewatch.version) then
	
			rewatch:Message("Thank you for updating Rewatch!")
			rewatch_config.version = rewatch.version
	
		end
		
		-- modules
		rewatch.cmd = RewatchCommandLine:new()
		rewatch.options = RewatchOptions:new()
	
		-- frame
		rewatch.frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	
		rewatch.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", rewatch_config.position.x, rewatch_config.position.y)
		rewatch.frame:SetWidth(1)
		rewatch.frame:SetHeight(1)
		rewatch.frame:EnableMouse(true)
		rewatch.frame:SetMovable(true)
		rewatch.frame:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
		rewatch.frame:SetBackdropColor(1, 0.49, 0.04, 0)
		rewatch.frame:SetScript("OnEnter", function() rewatch.frame:SetBackdropColor(1, 0.49, 0.04, 1) end)
		rewatch.frame:SetScript("OnLeave", function() rewatch.frame:SetBackdropColor(1, 0.49, 0.04, 0) end)
	
		rewatch.frame:SetScript("OnMouseDown", function(_, button)
	
			if(button == "LeftButton" and not rewatch.locked) then
				rewatch.frame:StartMoving()
			end
		
			if(button == "RightButton") then
				if(rewatch.locked) then
					rewatch.locked = false
					rewatch:Message("Unlocked frame")
				else
					rewatch.locked = true
					rewatch:Message("Locked frame")
				end
			end
		
		end)
	
		rewatch.frame:SetScript("OnMouseUp", function()
		
			rewatch.frame:StopMovingOrSizing()
		
			rewatch_config.position.x = rewatch.frame:GetLeft()
			rewatch_config.position.y = rewatch.frame:GetTop()
		
		end)

		-- events
		rewatch.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		rewatch.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
		rewatch.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		rewatch.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		rewatch.frame:RegisterEvent("GROUP_ROSTER_UPDATE")

		rewatch.frame:SetScript("OnEvent", function(self, event, unitGUID)

			if(event == "PLAYER_REGEN_ENABLED") then
				
				rewatch.inCombat = false

			elseif(event == "PLAYER_REGEN_DISABLED") then
				
				rewatch.inCombat = true
					
			elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
				
				rewatch.spec = GetSpecialization()

			elseif(event == "ACTIVE_TALENT_GROUP_CHANGED") then

				rewatch.spec = GetSpecialization()

			elseif(event == "GROUP_ROSTER_UPDATE") then
	
				rewatch.changed = true;
		
			end

		end)

		-- updates
		rewatch.frame:SetScript("OnUpdate", function(self)
		
			if(not rewatch.inCombat and rewatch.changed) then

				rewatch.changed = false
				rewatch:ProcessGroup()
				
			end

		end)

		-- let's go!
		rewatch:Apply()
		rewatch:ProcessGroup()

	end
}