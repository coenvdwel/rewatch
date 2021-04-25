if (GetLocale() ~= "zhCN") then return end

RewatchLocale = {}
RewatchLocale.__index = RewatchLocale

function RewatchLocale:new()
    
    local self =
    {
        -- druid
        ["rejuvenation"] = "回春术",
        ["wildgrowth"] = "野性成长",
        ["regrowth"] = "愈合",
        ["lifebloom"] = "生命绽放",
        ["innervate"] = "激活",
        ["naturesswiftness"] = "自然迅捷",
        ["swiftmend"] = "迅捷治愈",
        ["naturescure"] = "自然之愈",
        ["removecorruption"] = "清除腐蚀",
        ["ironbark"] = "铁木树皮",
        ["barkskin"] = "树皮术",
        ["rebirth"] = "复生",
        ["revive"] = "起死回生",
        ["efflorescence"] = "百花齐放",
        ["rejuvenationgermination"] = "回春术（萌芽）",
        ["flourish"] = "繁盛",
        ["cenarionward"] = "塞纳里奥结界",

        -- shaman
        ["earthshield"] = "大地之盾",
        ["riptide"] = "激流",
        ["purifyspirit"] = "净化灵魂",
        ["healingsurge"] = "治疗之涌",
        ["healingwave"] = "治疗波",
        ["chainheal"] = "治疗链",
        ["ancestralspirit"] = "先祖之魂",

        -- priest
        ["powerwordshield"] = "真言术：盾",
        ["powerwordbarrier"] = "真言术：障",
        ["shadowmend"] = "暗影愈合",
        ["penance"] = "苦修",
        ["flashheal"] = "快速治疗",
        ["purify"] = "纯净术",
        ["painsuppression"] = "痛苦压制",
        ["atonement"] = "救赎",
        ["powerwordradiance"] = "真言术：耀",
        ["rapture"] = "全神贯注",
        ["resurrection"] = "复活术",

        -- paladin
        ["beaconoflight"] = "圣光道标",
        ["bestowfaith"] = "赋予信仰",
        ["holyshock"] = "神圣震击",
        ["wordofglory"] = "荣耀圣令",
        ["holylight"] = "圣光术",
        ["flashoflight"] = "圣光闪现",
        ["cleanse"] = "清洁术",
        ["layonhands"] = "圣疗术",
        ["redemption"] = "救赎",

        -- monk
        ["renewingmist"] = "复苏之雾",
        ["envelopingmist"] = "氤氲之雾",
        ["lifecocoon"] = "作茧缚命",
        ["vivify"] = "活血术",
        ["soothingmist"] = "抚慰之雾",
        ["detox"] = "清创生血",
        ["resuscitate"] = "轮回转世",
        ["risingsunkick"] = "旭日东升踢",
    }
    
    setmetatable(self, RewatchLocale)

    return self

end