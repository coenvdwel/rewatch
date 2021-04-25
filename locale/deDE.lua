if (GetLocale() ~= "deDE") then return end

RewatchLocale = {}
RewatchLocale.__index = RewatchLocale

function RewatchLocale:new()
    
    local self =
    {
		-- druid
		["rejuvenation"] = "Verj\195\188ngung",
		["wildgrowth"] = "Wildwuchs",
		["regrowth"] = "Nachwachsen",
		["lifebloom"] = "Bl\195\188hendes Leben",
		["innervate"] = "Anregen",
		["naturesswiftness"] = "Schnelligkeit der Natur",
		["swiftmend"] = "Rasche Heilung",
		["naturescure"] = "Heilung der Natur",
		["removecorruption"] = "Verderbnis entfernen",
		["ironbark"] = "Eisenborke",
		["barkskin"] = "Baumrinde",
		["rebirth"] = "Wiedergeburt",
		["revive"] = "Wiederbelebung",
		["efflorescence"] = "Erbl\195\188hen",
		["rejuvenationgermination"] = "Verj\195\188ngung (Verschmelzung)",
		["flourish"] = "Gedeihen",
		["cenarionward"] = "Cenarischer Zauberschutz",

		-- shaman
		["earthshield"] = "Erdschild",
		["riptide"] = "Springflut",
		["purifyspirit"] = "Geistreinigung",
		["healingsurge"] = "Heilende Woge",
		["healingwave"] = "Welle der Heilung",
		["chainheal"] = "Kettenheilung",
		["ancestralspirit"] = "Geist der Ahnen",

		-- priest
		["powerwordshield"] = "Machtwort: Schild",
		["powerwordbarrier"] = "Machtwort: Barriere",
		["shadowmend"] = "Schattenheilung",
		["penance"] = "S\195\188hne",
		["flashheal"] = "Blitzheilung",
		["purify"] = "L\195\164utern",
		["painsuppression"] = "Schmerzunterdr\195\188ckung",
		["atonement"] = "Abbitte",
		["powerwordradiance"] = "Machtwort: Glanz",
		["rapture"] = "Euphorie",
		["resurrection"] = "Auferstehung",

		-- paladin
		["beaconoflight"] = "Flamme des Glaubens",
		["bestowfaith"] = "Zuversicht verleihen",
		["holyshock"] = "Heiliger Schock",
		["wordofglory"] = "Wort der Herrlichkeit",
		["holylight"] = "Heiliges Licht",
		["flashoflight"] = "Lichtblitz",
		["cleanse"] = "L\195\164uterung",
		["layonhands"] = "Handauflegung",
		["redemption"] = "Erl\195\182sung",

		-- monk
		["renewingmist"] = "Erneuernder Nebel",
		["envelopingmist"] = "Einh\195\188llender Nebel",
		["lifecocoon"] = "Lebenskokon",
		["vivify"] = "Beleben",
		["soothingmist"] = "Beruhigender Nebel",
		["detox"] = "Entgiftung",
		["resuscitate"] = "Wiederbeleben",
		["risingsunkick"] = "Tritt der aufgehenden Sonne",
    }
    
    setmetatable(self, RewatchLocale)

    return self

end