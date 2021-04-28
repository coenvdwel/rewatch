RewatchCommands = {}
RewatchCommands.__index = RewatchCommands

function RewatchCommands:new()

	local self =
	{
		show = function() rewatch.options.profile.hide = false; rewatch.frame:Show() end,
		hide = function() rewatch.options.profile.hide = true; rewatch.frame:Hide() end,
		sort = function() rewatch.clear = true end,
		
		help = function()

			rewatch:Message("Supported commands are; |cffff7c0a/rew|r, |cffff7c0a/rew show|r, |cffff7c0a/rew hide|r, |cffff7c0a/rew sort|r and |cffff7c0a/rew profile (profile name)|r.")

		end,

		profile = function(name)

			for guid,profile in pairs(rewatch_config.profiles) do
				if(profile.name:lower() == name:lower()) then
					rewatch.options:ActivateProfile(profile.guid)
					return
				end
			end

			rewatch:Message("No profile \""..name.."\" found :<")
			
		end
	}

	rewatch:Debug("RewatchCommands:new")

	setmetatable(self, RewatchCommands)

	SLASH_REWATCH1 = "/rew"
	SLASH_REWATCH2 = "/rewatch"

	SlashCmdList["REWATCH"] = function(cmd)

		if(string.len(cmd) > 0) then

			local pos, args = 0, {}

			for st, sp in function() return string.find(cmd, " ", pos, true) end do
				table.insert(args, string.sub(cmd, pos, st-1))
				pos = sp + 1
			end
			
			table.insert(args, string.sub(cmd, pos))
			
			local handler = self[string.lower(args[1])] or self.help

			handler(unpack(args, 2))

			return

		end
			
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory("Rewatch")
	
	end

	return self

end