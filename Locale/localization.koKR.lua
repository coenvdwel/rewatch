-- only allow korean clients to use this localization
if (GetLocale() == "koKR") then

-- short strings
rewatch_loc["prefix"] = "Rw: ";

-- report messages
rewatch_loc["welcome"] = "이용해주셔서 감사합니다!";
rewatch_loc["info"] = "You can open the options menu using \"/rewatch options\". Be sure to check out mouse-over macros to enhance gameplay even more!";
rewatch_loc["cleared"] = "데이타를 완전히 제거합니다";
rewatch_loc["credits"] = "Rewatch was written by Dezine, Argent Dawn EU - for help, use \"/rewatch help\"";
rewatch_loc["invalid_command"] = "올바르지 않은 명령어입니다. 도움말은 \"/rewatch help\" 를 이용해주세요.";
rewatch_loc["noplayer"] = "플레이어를 찾을 수 없습니다";
rewatch_loc["combatfailed"] = "명령을 수행할 수 없습니다; 지금은 전투 중 입니다.";
rewatch_loc["removefailed"] = "명령을 수행할 수 없습니다; 마지막 플레이어를 삭제할 수 없습니다.";
rewatch_loc["sorted"] = "플레이어를 다시 정렬합니다.";
rewatch_loc["nosort"] = "플레이어를 정렬할 수 없습니다. 자동 그룹이 설정되지 않은 상태입니다. \"/rewatch autogroup 1\" 를 입력하시거나, \"/rewatch clear\" 로 데이타를 삭제할 수 있습니다.";
rewatch_loc["nonumber"] = "유효한 숫자가 아닙니다";
rewatch_loc["setalpha"] = "글로벌 쿨다운 오버레이 설정";
rewatch_loc["sethidesolo0"] = "솔로잉 시 사용";
rewatch_loc["sethidesolo1"] = "솔로잉 시 숨김";
rewatch_loc["sethide0"] = "rewatch 보기";
rewatch_loc["sethide1"] = "rewatch 숨김";
rewatch_loc["setautogroupauto0"] = "수동으로 플레이어를 프레임에서 삭제합니다; 더 이상 그룹을 자동으로 조절하지 않습니다! 자동 그룹을 활성화 하려면\"/rewatch autogroup 1\" 를 입력해주세요.";
rewatch_loc["setautogroup0"] = "자동 그룹을 비활성화";
rewatch_loc["setautogroup1"] = "자동 그룹을 활성화";
rewatch_loc["setfalpha"] = "프레임 배경을 설정합니다.";
rewatch_loc["notingroup"] = "그룹에 없는 플레이어 입니다. \"/rewatch add <name> always\" 로 추가할 수 있습니다.";
rewatch_loc["offFrame"] = "플레이어 프레임을 메인 프레임에서 제거합니다.";
rewatch_loc["backOnFrame"] = "플레이어 프레임을 메인 프레임에 불러들입니다.";
rewatch_loc["locked"] = "메인 프레임 이동을 잠급니다.";
rewatch_loc["unlocked"] = "메인 프레임 잠금을 해제합니다.";
rewatch_loc["lockedp"] = "플레이어 프레임 이동을 잠급니다.";
rewatch_loc["unlockedp"] = "플레이어 프레임 잠금을 해제합니다.";
rewatch_loc["repositioned"] = "위치를 초기화 합니다.";

-- ui texts
rewatch_loc["visible"] = "시각화";
rewatch_loc["invisible"] = "비시각화";
rewatch_loc["gcdText"] = "글로벌 쿨다운 오버레이 투명도:";
rewatch_loc["OORText"] = "사거리 밖 플레이어 투명도:";
rewatch_loc["PBOText"] = "Passive bar transparency:";
rewatch_loc["hide"] = "언제나 숨김";
rewatch_loc["hideSolo"] = "솔로잉 시 숨김";
rewatch_loc["hideButtons"] = "Hide bottom frame buttons";
rewatch_loc["autoAdjust"] = "그룹을 자동으로 정리합니다";
rewatch_loc["buffCheck"] = "버프 체크";
rewatch_loc["sortList"] = "목록 정렬";
rewatch_loc["clearList"] = "목록 제거";
rewatch_loc["talentedwg"] = "특성 - 급속 성장";
rewatch_loc["frameText"] = "플레이어 배경 투명도:";
rewatch_loc["reset"] = "초기화";
rewatch_loc["frameback"] = "프레임 색상:";
rewatch_loc["healthback"] = "생명력 바 색상:";
rewatch_loc["barback"] = "주문 색상:";
rewatch_loc["showtooltips"] = "Show Tooltips";
rewatch_loc["optiondetails"] = "색상을 제외한 변경 사항은\"확인\" 를 눌러야 저장됩니다.";
rewatch_loc["dimentionschanges"] = "크기가 변경되었습니다. (/rewatch sort) 로 정렬할 수 있습니다.";
rewatch_loc["lockMain"] = "메인 잠금";
rewatch_loc["lockPlayers"] = "플레이어 잠금";
rewatch_loc["labelsOrTimers"] = "타이머 대신 라벨 표시";
rewatch_loc["healthbarHeight"] = "생명력 바 높이:";
rewatch_loc["castbarWidth"] = "시전 바 너비:";
rewatch_loc["castbarHeight"] = "시전 바 높이:";
rewatch_loc["sidebarWidth"] = "직업 바 너비:";
rewatch_loc["showDeficit"] = "Show health when HP less than";
rewatch_loc["numFramesWide"] = "라인 당 플레이어 수:";
rewatch_loc["maxNameLength"] = "이름 표시 길이:";
rewatch_loc["reposition"] = "위치 초기화";
rewatch_loc["scaling"] = "Scaling:";
rewatch_loc["horizontal"] = "Horizontal layout";
rewatch_loc["vertical"] = "Vertical layout";
rewatch_loc["showSelfFirst"] = "Show Self First";
rewatch_loc["sortByRole"] = "Sort By Role";
rewatch_loc["showIncomingHeals"] = "Show Incoming Heals";
rewatch_loc["showDamageTaken"] = "Show Damage Taken";
rewatch_loc["frameColumns"] = "Organise frames in columns";

-- help messages
rewatch_loc["help"] = {};
rewatch_loc["help"][1] = "Rewatch에서 가능한 명령어:";
rewatch_loc["help"][2] = " /rewatch: 크레딧을 보여줍니다";
rewatch_loc["help"][3] = " /rewatch add <name> always : 선택한 대상이나 정의된 플레이어를 목록에 추가합니다";
rewatch_loc["help"][4] = " /rewatch clear: 목록을 제거하고 초기화 합니다";
rewatch_loc["help"][5] = " /rewatch sort: 목록을 그룹 구조에 따라 정렬합니다";
rewatch_loc["help"][6] = " /rewatch gcdAlpha [0 through 1]: 글로벌 쿨다운 오버레이를 설정합니다. 기본값=1=완전한 시각화";
rewatch_loc["help"][7] = " /rewatch frameAlpha [0 through 1]: 프레임 배경을 설정합니다. 기본값=0.4";
rewatch_loc["help"][8] = " /rewatch hideSolo [0 or 1]: 솔로잉 시 사용을 설정합니다. default=0=비활성화";
rewatch_loc["help"][9] = " /rewatch autoGroup [0 or 1]: 자동 그룹 사용을 설정합니다. default=1=활성화";
rewatch_loc["help"][10] = " /rewatch version: 버전을 표시합니다.";
rewatch_loc["help"][11] = " /rewatch lock/unlock: 잠금/해제를 설정합니다.";
rewatch_loc["help"][12] = " /rewatch hide/show: Rewatch 보이기/숨기기";

-- spell names
rewatch_loc["rejuvenation"] = "회복";
rewatch_loc["wildgrowth"] = "급속 성장";
rewatch_loc["regrowth"] = "재생";
rewatch_loc["lifebloom"] = "피어나는 생명";
rewatch_loc["innervate"] = "정신 자극";
rewatch_loc["markofthewild"] = "야생의 징표";
rewatch_loc["naturesswiftness"] = "자연의 신속함";
rewatch_loc["tranquility"] = "평온";
rewatch_loc["swiftmend"] = "신속한 치유";
rewatch_loc["naturescure"] = "자연의 치유력";
rewatch_loc["removecorruption"] = "저주 해제";
rewatch_loc["ironbark"] = "무쇠껍질";
rewatch_loc["barkskin"] = "나무 껍질";
rewatch_loc["healingtouch"] = "치유의 손길";
rewatch_loc["genesis"] = "육성";
rewatch_loc["rebirth"] = "환생";
rewatch_loc["revive"] = "되살리기";
rewatch_loc["clearcasting"] = "번뜩임";
rewatch_loc["mushroom"] = "꽃피우기";
rewatch_loc["rejuvenation (germination)"] = "회복 (싹틔우기)";
rewatch_loc["flourish"] = "번성";

-- big non-druid heals
rewatch_loc["healingwave"] = "치유의 물결"; -- shaman
rewatch_loc["greaterheal"] = "상급 치유"; -- priest
rewatch_loc["holylight"] = "성스러운 빛"; -- paladin

-- shapeshifts
rewatch_loc["bearForm"] = "곰 변신";
rewatch_loc["direBearForm"] = "Dire Bear Form";
rewatch_loc["catForm"] = "표범 변신";
	
end;
