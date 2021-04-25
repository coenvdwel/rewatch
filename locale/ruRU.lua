if (GetLocale() ~= "ruRU") then return end

RewatchLocale = {}
RewatchLocale.__index = RewatchLocale

function RewatchLocale:new()

	local self =
	{
		-- druid
		["rejuvenation"] = "Омоложение",
		["wildgrowth"] = "Буйный рост",
		["regrowth"] = "Восстановление",
		["lifebloom"] = "Жизнецвет",
		["innervate"] = "Озарение",
		["naturesswiftness"] = "Природная стремительность",
		["swiftmend"] = "Быстрое восстановление",
		["naturescure"] = "Природный целитель",
		["removecorruption"] = "Снятие порчи",
		["ironbark"] = "Железная кора",
		["barkskin"] = "Дубовая кожа",
		["rebirth"] = "Возрождение",
		["revive"] = "Оживление",
		["efflorescence"] = "Период цветения",
		["rejuvenationgermination"] = "Омоложение (зарождение)",
		["flourish"] = "Расцвет",
		["cenarionward"] = "Щит Кенария",

		-- shaman
		["earthshield"] = "Щит земли",
		["riptide"] = "Быстрина",
		["purifyspirit"] = "Возрождение духа",
		["healingsurge"] = "Исцеляющий всплеск",
		["healingwave"] = "Волна исцеления",
		["chainheal"] = "Цепное исцеление",
		["ancestralspirit"] = "Дух предков",

		-- priest
		["powerwordshield"] = "Слово силы: Щит",
		["powerwordbarrier"] = "Слово силы: Барьер",
		["shadowmend"] = "Темное восстановление",
		["penance"] = "Исповедь",
		["flashheal"] = "Быстрое исцеление",
		["purify"] = "Очищение",
		["painsuppression"] = "Подавление боли",
		["atonement"] = "Искупление вины",
		["powerwordradiance"] = "Слово силы: Сияние",
		["rapture"] = "Вознесение",
		["resurrection"] = "Воскрешение",

		-- paladin
		["beaconoflight"] = "Частица Света",
		["bestowfaith"] = "Дарование веры",
		["holyshock"] = "Шок небес",
		["wordofglory"] = "Торжество",
		["holylight"] = "Свет небес",
		["flashoflight"] = "Вспышка Света",
		["cleanse"] = "Очищение",
		["layonhands"] = "Возложение рук",
		["redemption"] = "Искупление",

		-- monk
		["renewingmist"] = "Заживляющий туман",
		["envelopingmist"] = "Окутывающий туман",
		["lifecocoon"] = "Исцеляющий кокон",
		["vivify"] = "Оживить",
		["soothingmist"] = "Успокаивающий туман",
		["detox"] = "Детоксикация",
		["resuscitate"] = "Воскрешение",
		["risingsunkick"] = "Удар восходящего солнца",
	}

	rewatch:Debug("RewatchLocale:new (ruRU)")

	setmetatable(self, RewatchLocale)

	return self

end