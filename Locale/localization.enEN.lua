-- default English localisation
rewatch_loc = {};

-- short strings
rewatch_loc["prefix"] = "Rw: ";

-- report messages
rewatch_loc["welcome"] = "Thank you for using Rewatch!";
rewatch_loc["info"] = "You can open the options menu using \"/rewatch options\". Be sure to check out mouse-over macros to enhance gameplay even more!";
rewatch_loc["cleared"] = "The rewatch data has been successfully cleared";
rewatch_loc["credits"] = "Rewatch was written by Dezine, Argent Dawn EU - for help, use \"/rewatch help\"";
rewatch_loc["invalid_command"] = "Unknown command. For help, use \"/rewatch help\"";
rewatch_loc["noplayer"] = "No such player!";
rewatch_loc["combatfailed"] = "Cannot perform requested action; you're in combat";
rewatch_loc["removefailed"] = "Cannot perform request action; you can't remove the last player";
rewatch_loc["sorted"] = "Re-sorted the players";
rewatch_loc["nosort"] = "Could not re-sort the players, because the auto-group feature is disabled (not saved). To enable this, type \"/rewatch autogroup 1\", or to just clear the list, type \"/rewatch clear\"";
rewatch_loc["nonumber"] = "This is not a valid number!";
rewatch_loc["setalpha"] = "Set the global cooldown overlay alpha to ";
rewatch_loc["sethidesolo0"] = "Not hiding Rewatch when soloing.";
rewatch_loc["sethidesolo1"] = "Hiding Rewatch when soloing.";
rewatch_loc["sethide0"] = "Showing Rewatch.";
rewatch_loc["sethide1"] = "Hiding Rewatch.";
rewatch_loc["setautogroupauto0"] = "You manually removed a player from the frame; Not automatically adjusting to group anymore! To enable this again, type /rewatch autogroup 1.";
rewatch_loc["setautogroup0"] = "Not automatically adjusting to group anymore!";
rewatch_loc["setautogroup1"] = "Automatically adjusting to group enabled.";
rewatch_loc["setfalpha"] = "Set the frame background alpha to ";
rewatch_loc["notingroup"] = "This player is not in your group and will not be added. Use \"/rewatch add <name> always\" to ignore this.";
rewatch_loc["offFrame"] = "Player frame snapped off main frame.";
rewatch_loc["backOnFrame"] = "Player frame snapped back onto main frame.";
rewatch_loc["locked"] = "Locked main Rewatch frame from moving.";
rewatch_loc["unlocked"] = "Unlocked Rewatch frame.";
rewatch_loc["lockedp"] = "Locked Rewatch playerframes from moving.";
rewatch_loc["unlockedp"] = "Unlocked Rewatch playerframes.";
rewatch_loc["repositioned"] = "Repositioned the Rewatch frame.";

-- ui texts
rewatch_loc["visible"] = "Visible";
rewatch_loc["invisible"] = "Invisible";
rewatch_loc["gcdText"] = "Global cooldown overlay transparency:";
rewatch_loc["OORText"] = "Out-Of-Range playerframe transparency:";
rewatch_loc["PBOText"] = "Passive bar transparency:";
rewatch_loc["hide"] = "Hide always";
rewatch_loc["hideSolo"] = "Hide when soloing";
rewatch_loc["hideButtons"] = "Hide bottom frame buttons";
rewatch_loc["autoAdjust"] = "Automatically adjust to group";
rewatch_loc["buffCheck"] = "Buff check";
rewatch_loc["sortList"] = "Sort list";
rewatch_loc["clearList"] = "Clear list";
rewatch_loc["talentedwg"] = "Show Wild Growth";
rewatch_loc["frameText"] = "Player frame background transparency:";
rewatch_loc["reset"] = "Reset";
rewatch_loc["frameback"] = "Frame backcolour:";
rewatch_loc["healthback"] = "Healthbar colour:";
rewatch_loc["barback"] = "Spell bar colour:";
rewatch_loc["showtooltips"] = "Show Tooltips";
rewatch_loc["optiondetails"] = "Be sure to click \"Okay\" to save the changes.";
rewatch_loc["dimentionschanges"] = "You changed some dimentions. Re-sort the list (/rewatch sort) for the changes to take effect.";
rewatch_loc["lockMain"] = "Lock main";
rewatch_loc["lockPlayers"] = "Lock players";
rewatch_loc["labelsOrTimers"] = "Labels instead of timers?";
rewatch_loc["healthbarHeight"] = "Healthbar height:";
rewatch_loc["castbarWidth"] = "Castbar width:";
rewatch_loc["castbarHeight"] = "Castbar height:";
rewatch_loc["sidebarWidth"] = "Sidebar (class) width:";
rewatch_loc["showDeficit"] = "Show health when HP less than";
rewatch_loc["numFramesWide"] = "Number of player frames each line:";
rewatch_loc["maxNameLength"] = "Max displayed name length:";
rewatch_loc["reposition"] = "Reposition";
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
rewatch_loc["help"][1] = "Rewatch available commands:";
rewatch_loc["help"][2] = " /rewatch: will display credits";
rewatch_loc["help"][3] = " /rewatch add [_target||<name>] [_||always]: adds either your target, or the player with the specified name to the list";
rewatch_loc["help"][4] = " /rewatch clear: clears the rewatch list and resets its height";
rewatch_loc["help"][5] = " /rewatch sort: resort the rewatch list with the current group structure";
rewatch_loc["help"][6] = " /rewatch gcdAlpha [0 through 1]: sets the global cooldown overlay alpha, default=1=fully visible";
rewatch_loc["help"][7] = " /rewatch frameAlpha [0 through 1]: sets the frame background alpha, default=0.4";
rewatch_loc["help"][8] = " /rewatch hideSolo [0 or 1]: set the hide on solo feature, default=0=disabled";
rewatch_loc["help"][9] = " /rewatch autoGroup [0 or 1]: set the auto-group feature, default=1=enabled";
rewatch_loc["help"][10] = " /rewatch version: get your current version";
rewatch_loc["help"][11] = " /rewatch lock/unlock: locks or unlocks all Rewatch frames from moving";
rewatch_loc["help"][12] = " /rewatch hide/show: hides or shows Rewatch";

-- druid spell names
rewatch_loc["rejuvenation"] = "Rejuvenation";
rewatch_loc["wildgrowth"] = "Wild Growth";
rewatch_loc["regrowth"] = "Regrowth";
rewatch_loc["lifebloom"] = "Lifebloom";
rewatch_loc["innervate"] = "Innervate";
rewatch_loc["tranquility"] = "Tranquility";
rewatch_loc["swiftmend"] = "Swiftmend";
rewatch_loc["naturescure"] = "Nature's Cure";
rewatch_loc["removecorruption"] = "Remove Corruption";
rewatch_loc["ironbark"] = "Ironbark";
rewatch_loc["barkskin"] = "Barkskin";
rewatch_loc["healingtouch"] = "Healing Touch";
rewatch_loc["rebirth"] = "Rebirth";
rewatch_loc["revive"] = "Revive";
rewatch_loc["clearcasting"] = "Clearcasting";
rewatch_loc["mushroom"] = "Efflorescence";
rewatch_loc["rejuvenation (germination)"] = "Rejuvenation (Germination)";
rewatch_loc["flourish"] = "Flourish";

-- big non-druid heals
rewatch_loc["healingwave"] = "Healing Wave"; -- shaman
rewatch_loc["greaterheal"] = "Greater Heal"; -- priest
rewatch_loc["holylight"] = "Holy Light"; -- paladin

-- shapeshifts
rewatch_loc["bearForm"] = "Bear Form";
rewatch_loc["direBearForm"] = "Dire Bear Form";
rewatch_loc["catForm"] = "Cat Form";

-- shaman spell names
rewatch_loc["earthshield"] = "Earth Shield";
rewatch_loc["riptide"] = "Riptide";
rewatch_loc["purifyspirit"] = "Purify Spirit";
rewatch_loc["healingsurge"] = "Healing Surge";
rewatch_loc["healingwave"] = "Healing Wave";
rewatch_loc["chainheal"] = "Chain Heal";
  
  