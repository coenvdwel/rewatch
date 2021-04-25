if (GetLocale() ~= "enUS") then return end

RewatchLocale = {}
RewatchLocale.__index = RewatchLocale

function RewatchLocale:new()

	local self =
	{
		-- druid
		["rejuvenation"] = "Rejuvenation",
		["wildgrowth"] = "Wild Growth",
		["regrowth"] = "Regrowth",
		["lifebloom"] = "Lifebloom",
		["innervate"] = "Innervate",
		["naturesswiftness"] = "Nature's Swiftness",
		["swiftmend"] = "Swiftmend",
		["naturescure"] = "Nature's Cure",
		["removecorruption"] = "Remove Corruption",
		["ironbark"] = "Ironbark",
		["barkskin"] = "Barkskin",
		["rebirth"] = "Rebirth",
		["revive"] = "Revive",
		["efflorescence"] = "Efflorescence",
		["rejuvenationgermination"] = "Rejuvenation (Germination)",
		["flourish"] = "Flourish",
		["cenarionward"] = "Cenarion Ward",

		-- shaman
		["earthshield"] = "Earth Shield",
		["riptide"] = "Riptide",
		["purifyspirit"] = "Purify Spirit",
		["healingsurge"] = "Healing Surge",
		["healingwave"] = "Healing Wave",
		["chainheal"] = "Chain Heal",
		["ancestralspirit"] = "Ancestral Spirit",
		
		-- priest
		["powerwordshield"] = "Power Word: Shield",
		["powerwordbarrier"] = "Power Word: Barrier",
		["shadowmend"] = "Shadow Mend",
		["penance"] = "Penance",
		["flashheal"] = "Flash Heal",
		["purify"] = "Purify",
		["painsuppression"] = "Pain Suppression",
		["atonement"] = "Atonement",
		["powerwordradiance"] = "Power Word: Radiance",
		["rapture"] = "Rapture",
		["resurrection"] = "Resurrection",

		-- paladin
		["beaconoflight"] = "Beacon of Light",
		["bestowfaith"] = "Bestow Faith",
		["holyshock"] = "Holy Shock",
		["wordofglory"] = "Word of Glory",
		["holylight"] = "Holy Light",
		["flashoflight"] = "Flash of Light",
		["cleanse"] = "Cleanse",
		["layonhands"] = "Lay on Hands",
		["redemption"] = "Redemption",

		-- monk
		["renewingmist"] = "Renewing Mist",
		["envelopingmist"] = "Enveloping Mist",
		["lifecocoon"] = "Life Cocoon",
		["vivify"] = "Vivify",
		["soothingmist"] = "Soothing Mist",
		["detox"] = "Detox",
		["resuscitate"] = "Resuscitate",
		["risingsunkick"] = "Rising Sun Kick",
	}

	rewatch:Debug("RewatchLocale:new (enUS)")

	setmetatable(self, RewatchLocale)

	return self

end