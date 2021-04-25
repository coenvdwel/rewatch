if (GetLocale() ~= "esES") then return end

RewatchLocale = {}
RewatchLocale.__index = RewatchLocale

function RewatchLocale:new()
    
    local self =
    {
		-- druid
		["rejuvenation"] = "Rejuvenecimiento",
		["wildgrowth"] = "Crecimiento salvaje",
		["regrowth"] = "Recrecimiento",
		["lifebloom"] = "Flor de vida",
		["innervate"] = "Estimular",
		["naturesswiftness"] = "Presteza de la Naturaleza",
		["swiftmend"] = "Alivio presto",
		["naturescure"] = "Cura de la Naturaleza",
		["removecorruption"] = "Eliminar corrupci\195\179n",
		["ironbark"] = "Corteza de hierro",
		["barkskin"] = "Piel de corteza",
		["rebirth"] = "Renacer",
		["revive"] = "Revivir",
		["efflorescence"] = "Floraci\195\179n",
		["rejuvenationgermination"] = "Rejuvenecimiento (Germinaci\195\179n)",
		["flourish"] = "Florecer",
		["cenarionward"] = "Resguardo de Cenarius",

		-- shaman
		["earthshield"] = "Escudo de tierra",
		["riptide"] = "Mareas vivas",
		["purifyspirit"] = "Purificar esp\195\173ritu",
		["healingsurge"] = "Oleada de sanaci\195\179n",
		["healingwave"] = "Ola de sanaci\195\179n",
		["chainheal"] = "Sanaci\195\179n en cadena",
		["ancestralspirit"] = "Esp\195\173ritu ancestral",

		-- priest
		["powerwordshield"] = "Palabra de poder: escudo",
		["powerwordbarrier"] = "Palabra de poder: barrera",
		["shadowmend"] = "Alivio de las Sombras",
		["penance"] = "Penitencia",
		["flashheal"] = "Sanaci\195\179n rel\195\161mpago",
		["purify"] = "Purificar",
		["painsuppression"] = "Supresi\195\179n de dolor",
		["atonement"] = "Expiaci\195\179n",
		["powerwordradiance"] = "Palabra de poder: radiancia",
		["rapture"] = "\195\137xtasis",
		["resurrection"] = "Resurrecci\195\179n",

		-- paladin
		["beaconoflight"] = "Se\195\177al de la Luz",
		["bestowfaith"] = "Otorgar fe",
		["holyshock"] = "Choque Sagrado",
		["wordofglory"] = "Palabra de gloria",
		["holylight"] = "Luz Sagrada",
		["flashoflight"] = "Destello de Luz",
		["cleanse"] = "Limpiar",
		["layonhands"] = "Imposici\195\179n de manos",
		["redemption"] = "Redenci\195\179n",

		-- monk
		["renewingmist"] = "Niebla renovadora",
		["envelopingmist"] = "Niebla envolvente",
		["lifecocoon"] = "Cris\195\161lida vital",
		["vivify"] = "Vivificar",
		["soothingmist"] = "Niebla reconfortante",
		["detox"] = "Depuraci\195\179n",
		["resuscitate"] = "Resucitar",
		["risingsunkick"] = "Patada del sol naciente",
    }
    
    setmetatable(self, RewatchLocale)

    return self

end