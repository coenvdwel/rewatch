RewatchSpells = {}
RewatchSpells.__index = RewatchSpells

function RewatchSpells:new()

	local self =
	{
		locale = GetLocale(),
		cache = {},

		ids =
		{
			-- druid
			["Rejuvenation"] = 774,
			["Wild Growth"] = 48438,
			["Regrowth"] = 8936,
			["Lifebloom"] = 33763,
			["Innervate"] = 29166,
			["Nature's Swiftness"] = 132158,
			["Swiftmend"] = 18562,
			["Nature's Cure"] = 88423,
			["Remove Corruption"] = 2782,
			["Ironbark"] = 102342,
			["Barkskin"] = 22812,
			["Rebirth"] = 20484,
			["Revive"] = 50769,
			["Efflorescence"] = 145205,
			["Rejuvenation (Germination)"] = 155777,
			["Renewing Bloom"] = 364365,
			["Flourish"] = 197721,
			["Cenarion Ward"] = 102351,

			-- shaman
			["Earth Shield"] = 974,
			["Riptide"] = 61295,
			["Purify Spirit"] = 77130,
			["Cleanse Spirit"] = 51886,
			["Healing Surge"] = 8004,
			["Healing Wave"] = 77472,
			["Chain Heal"] = 1064,
			["Ancestral Spirit"] = 2008,

			-- priest
			["Power Word: Shield"] = 17,
			["Power Word: Barrier"] = 62618,
			["Shadow Mend"] = 186263,
			["Penance"] = 47540,
			["Flash Heal"] = 2061,
			["Purify"] = 527,
			["Purify Disease"] = 213634,
			["Pain Suppression"] = 33206,
			["Atonement"] = 81749,
			["Power Word: Radiance"] = 194509,
			["Rapture"] = 47536,
			["Resurrection"] = 2006,

			-- paladin
			["Beacon of Light"] = 53563,
			["Bestow Faith"] = 223306,
			["Holy Shock"] = 20473,
			["Word of Glory"] = 85673,
			["Holy Light"] = 82326,
			["Flash of Light"] = 19750,
			["Cleanse"] = 4987,
			["Cleanse Toxins"] = 213644,
			["Lay on Hands"] = 633,
			["Redemption"] = 7328,

			-- monk
			["Renewing Mist"] = 115151,
			["Enveloping Mist"] = 124682,
			["Life Cocoon"] = 116849,
			["Vivify"] = 116670,
			["Soothing Mist"] = 115175,
			["Detox"] = 115450,
			["Resuscitate"] = 115178,
			["Rising Sun Kick"] = 107428,

			-- lizardman
			["Echo"] = 364343,
			["Living Flame"] = 361469,
			["Emerald Blossom"] = 355913,
			["Expunge"] = 365585,
			["Cauterizing Flame"] = 374251,
			["Return"] = 361227,
			["Naturalize"] = 360823,
			["Verdant Embrace"] = 360995,
			["Dream Breath"] = 355936,
			["Spiritbloom"] = 382731,
			["Stasis"] = 370537,
			["Dream Flight"] = 359816,
			["Temporal Anomaly"] = 373861,
			["Rewind"] = 363534,
			["Reversion"] = 367364,

		},
	}

	rewatch:Debug("RewatchSpells:new")

	setmetatable(self, RewatchSpells)

	return self

end

function RewatchSpells:Id(id)

	if(not self.cache[id]) then
		local spellInfo = C_Spell.GetSpellInfo(id)
		self.cache[id] = spellInfo.name
	end

	return self.cache[id]

end

function RewatchSpells:Name(spellName)

	return self.locale == "enUS" and spellName or self:Id(self.ids[spellName])

end

function RewatchSpells:IsRez(spellName)

	return spellName == self:Name("Rebirth")
		or spellName == self:Name("Revive")
		or spellName == self:Name("Ancestral Spirit")
		or spellName == self:Name("Resurrection")
		or spellName == self:Name("Redemption")
		or spellName == self:Name("Resuscitate")
		or spellName == self:Name("Return")
end

function RewatchSpells:IsDispel(spellName)

	return spellName == self:Name("Remove Corruption")
		or spellName == self:Name("Nature's Cure")
		or spellName == self:Name("Purify Spirit")
		or spellName == self:Name("Purify")
		or spellName == self:Name("Cleanse")
		or spellName == self:Name("Detox")
		or spellName == self:Name("Expunge")
		or spellName == self:Name("Naturalize")
		or spellName == self:Name("Cauterizing Flame")

end