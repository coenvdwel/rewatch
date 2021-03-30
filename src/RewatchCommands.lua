RewatchCommands = {}
RewatchCommands.__index = RewatchCommands

function RewatchCommands:new()
    
    local self =
    {
		show = function() rewatch.frame:Show() end,
		hide = function() rewatch.frame:Hide() end,
        options = function()
			InterfaceOptionsFrame_Show()
			InterfaceOptionsFrame_OpenToCategory("Rewatch")
		end
	}

    setmetatable(self, RewatchCommands)

	SLASH_REWATCH1 = "/rewatch"
	SLASH_REWATCH2 = "/rew"

	SlashCmdList["REWATCH"] = function(cmd)

		if(cmd) then
			
			local pos, args = 0, {}

			for st, sp in function() return string.find(cmd, " ", pos, true) end do
				table.insert(args, string.sub(cmd, pos, st-1))
				pos = sp + 1
			end
			
			table.insert(args, string.sub(cmd, pos))
			
			local handler = self[string.lower(args[1])]

			if(handler) then
				handler(args)
				return
			end

		end
	
		rewatch:Message("Thank you for using Rewatch!")
		rewatch:Message("Supported commands are; |cffff7d0ashow|r, |cffff7d0ahide|r and |cffff7d0aoptions|r.")
	
	end

	return self

end