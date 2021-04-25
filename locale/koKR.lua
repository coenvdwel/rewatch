if (GetLocale() ~= "koKR") then return end

RewatchLocale = {}
RewatchLocale.__index = RewatchLocale

function RewatchLocale:new()

	local self =
	{
		-- druid
		["rejuvenation"] = "회복",
		["wildgrowth"] = "급속 성장",
		["regrowth"] = "재생",
		["lifebloom"] = "피어나는 생명",
		["innervate"] = "정신 자극",
		["naturesswiftness"] = "자연의 신속함",
		["swiftmend"] = "신속한 치유",
		["naturescure"] = "자연의 치유력",
		["removecorruption"] = "저주 해제",
		["ironbark"] = "무쇠껍질",
		["barkskin"] = "나무 껍질",
		["rebirth"] = "환생",
		["revive"] = "되살리기",
		["efflorescence"] = "꽃피우기",
		["rejuvenationgermination"] = "회복 (싹틔우기)",
		["flourish"] = "번성",
		["cenarionward"] = "세나리온 수호물",

		-- shaman
		["earthshield"] = "대지의 보호막",
		["riptide"] = "성난 해일",
		["purifyspirit"] = "영혼 정화",
		["healingsurge"] = "치유의 파도",
		["healingwave"] = "치유의 물결",
		["chainheal"] = "연쇄 치유",
		["ancestralspirit"] = "고대의 영혼",

		-- priest
		["powerwordshield"] = "신의 권능: 보호막",
		["powerwordbarrier"] = "신의 권능: 방벽",
		["shadowmend"] = "어둠의 치유",
		["penance"] = "회개",
		["flashheal"] = "순간 치유",
		["purify"] = "정화",
		["painsuppression"] = "고통 억제",
		["atonement"] = "속죄",
		["powerwordradiance"] = "신의 권능: 광휘",
		["rapture"] = "환희",
		["resurrection"] = "부활",

		-- paladin
		["beaconoflight"] = "빛의 봉화",
		["bestowfaith"] = "신념 수여",
		["holyshock"] = "신성 충격",
		["wordofglory"] = "영광의 서약",
		["holylight"] = "성스러운 빛",
		["flashoflight"] = "빛의 섬광",
		["cleanse"] = "정화",
		["layonhands"] = "신의 축복",
		["redemption"] = "구원",

		-- monk
		["renewingmist"] = "소생의 안개",
		["envelopingmist"] = "포용의 안개",
		["lifecocoon"] = "기의 고치",
		["vivify"] = "생기 충전",
		["soothingmist"] = "위안의 안개",
		["detox"] = "해독",
		["resuscitate"] = "소생술",
		["risingsunkick"] = "해오름차기",
	}
	
	rewatch:Debug("RewatchLocale:new (koKR)")

	setmetatable(self, RewatchLocale)

	return self

end