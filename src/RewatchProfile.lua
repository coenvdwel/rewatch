RewatchProfile = {};
RewatchProfile.__index = RewatchProfile;

function RewatchProfile:new()

	local guid = rewatch_config.profile[rewatch.guid];

	if(guid) then
		return rewatch_config.profiles[guid];
	end;

	local self =
	{
		name = rewatch.player,
		guid = rewatch:NewId(),

		spellBarWidth = 25,
		spellBarHeight = 14,
		healthBarHeight = 110,
		scaling = 100,
		numFramesWide = 5,
		
		bar = "Interface\\AddOns\\Rewatch\\assets\\Bar.tga",
		font = "Interface\\AddOns\\Rewatch\\assets\\BigNoodleTitling.ttf",
		fontSize = 10,
		highlightSize = 10,
		OORAlpha = 0.5,
		PBOAlpha = 0.2,
		layout = "vertical",
		highlighting = {},
		highlighting2 = {},
		highlighting3 = {},
		
		showButtons = false,
		showTooltips = true,
		frameColumns = true,

		altMacro = nil,
		ctrlMacro = nil,
		shiftMacro = nil,
		
		bars = {},
		buttons = {}
	};

	-- shaman
	if(rewatch.classId == 7) then
		self.bars = { rewatch.locale["riptide"] };
		self.buttons = { rewatch.locale["purifyspirit"], rewatch.locale["healingsurge"], rewatch.locale["healingwave"], rewatch.locale["chainheal"] };
	end;
	
	-- druid
	if(rewatch.classId == 11) then
		self.bars = { rewatch.locale["lifebloom"], rewatch.locale["rejuvenation"], rewatch.locale["regrowth"], rewatch.locale["wildgrowth"] };
		self.buttons = { rewatch.locale["swiftmend"], rewatch.locale["naturescure"], rewatch.locale["ironbark"], rewatch.locale["mushroom"] };
		self.altMacro = "/cast [@mouseover] "..rewatch.locale["naturescure"];
		self.ctrlMacro = "/cast [@mouseover] "..rewatch.locale["naturesswiftness"].."/cast [@mouseover] "..rewatch.locale["regrowth"];
		self.shiftMacro = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch.locale["rebirth"].."; "..rewatch.locale["revive"].."\n/targetlasttarget";
	end;

	rewatch_config.profiles[self.guid] = self;
	rewatch_config.profile[rewatch.guid] = self.guid;
	
	return self;

end;