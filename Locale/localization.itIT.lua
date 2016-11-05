-- only allow german clients to use this localization
if (GetLocale() == "itIT") then
	
	-- short strings
	rewatch_loc["prefix"] = "Rw: ";
	
	-- report messages
	rewatch_loc["welcome"] = "Grazie per usare Rewatch!";
	rewatch_loc["info"] = "Puoi aprire il menu opzioni usando \"/rewatch options\". Assicurati di controllare le macro mouse-over per migliorare la tua esperienza di gioco !";
	rewatch_loc["cleared"] = "I dati di rewatch sono stati cancellati con successo";
	rewatch_loc["credits"] = "Rewatch \195\168 stato scritto da Dezine, Argent Dawn EU - per aiuto, usa \"/rewatch help\"";
	rewatch_loc["invalid_command"] = "Comando sconosciuto. Per aiuto, usa \"/rewatch help\"";
	rewatch_loc["noplayer"] = "Nessun giocatore!";
	rewatch_loc["combatfailed"] = "Impossibile eseguire l’azione richiesta; sei in combattimento";
	rewatch_loc["removefailed"] = "Impossibile eseguire l’azione richiesta; non puoi rimuovere l’ultimo giocatore";
	rewatch_loc["sorted"] = "Giocatori riorganizzati";
	rewatch_loc["nosort"] = "Impossibile riorganizzare i giocatori, perch\195\168 l’opzione di auto organizzazione \195\168 disabilitata (non salvata). Per abilitarla digitare \"/rewatch autogroup 1\", o per cancellarla semplicemente digitare \"/rewatch clear\"";
	rewatch_loc["nonumber"] = "Non \195\168 un numero valido!";
	rewatch_loc["setalpha"] = "Set the global cooldown overlay alpha to ";
	rewatch_loc["sethidesolo0"] = "Non nascondere Rewatch quando in solo.";
	rewatch_loc["sethidesolo1"] = "Nascondi Rewatch quando in solo.";
	rewatch_loc["sethide0"] = "Mostra Rewatch.";
	rewatch_loc["sethide1"] = "Nascondi Rewatch.";
	rewatch_loc["setautogroupauto0"] = "Hai rimosso manualmente un giocatore dalla griglia; nessuna correzione automatica del gruppo! Per abilitarla di nuovo, digitare /rewatch autogroup 1.";
	rewatch_loc["setautogroup0"] = "Nessuna correzione automatica del gruppo!";
	rewatch_loc["setautogroup1"] = "Correzione automatica del gruppo abilitata.";
	rewatch_loc["setfalpha"] = "Set the frame background alpha to ";
	rewatch_loc["notingroup"] = "Questo giocatore non \195\168 nel tuo gruppo e non verr\195\160 aggiunto. Usa \"/rewatch add <name> always\" per ignorare ci\195\178.";
	rewatch_loc["offFrame"] = "Player frame snapped off main frame.";
	rewatch_loc["backOnFrame"] = "Player frame snapped back onto main frame.";
	rewatch_loc["locked"] = "Bloccati i movimenti del frame principale di Rewatch.";
	rewatch_loc["unlocked"] = "Sbloccato il frame di Rewatch.";
	rewatch_loc["lockedp"] = "Bloccati i movimenti dei frame dei giocatori di Rewatch.";
	rewatch_loc["unlockedp"] = "Sbloccati i frame dei giocatori di Rewatch.";
	rewatch_loc["repositioned"] = "Riposizionato il frame di Rewatch.";
	
	-- ui texts
	rewatch_loc["visible"] = "Visible";
	rewatch_loc["invisible"] = "Invisible";
	rewatch_loc["gcdText"] = "Global cooldown overlay transparency:";
	rewatch_loc["OORText"] = "Out-Of-Range playerframe transparency:";
	rewatch_loc["PBOText"] = "Passive bar transparency:";
	rewatch_loc["hide"] = "Nascondi sempre";
	rewatch_loc["hideSolo"] = "Nascondi quando in solo";
	rewatch_loc["hideButtons"] = "Nascondi i bottoni inferiori del frame";
	rewatch_loc["autoAdjust"] = "Adatta automaticamente al gruppo";
	rewatch_loc["buffCheck"] = "Controlli dei Buff";
	rewatch_loc["sortList"] = "Ordina la lista";
	rewatch_loc["clearList"] = "Cancella la lista";
	rewatch_loc["talentedwg"] = "Show Wild Growth";
	rewatch_loc["frameText"] = "Player frame background transparency:";
	rewatch_loc["reset"] = "Resetta";
	rewatch_loc["frameback"] = "Frame backcolour:";
	rewatch_loc["healthback"] = "Healthbar colour:";
	rewatch_loc["barback"] = "Spell bar colour:";
	rewatch_loc["showtooltips"] = "Show Tooltips";
	rewatch_loc["optiondetails"] = "Assicurati di cliccare \"Okay\" per salvare i cambiamenti";
	rewatch_loc["dimentionschanges"] = "Hai cambiato alcune dimensioni. Riorganizza la lista (/rewatch sort) per applicare i cambiamenti.";
	rewatch_loc["lockMain"] = "Blocca la finestra principale ";
	rewatch_loc["lockPlayers"] = "Blocca la finestra dei giocatori";
	rewatch_loc["labelsOrTimers"] = "Etichette invece che i timers?";
	rewatch_loc["healthbarHeight"] = "Altezza barra della salute:";
	rewatch_loc["castbarWidth"] = "Larghezza della barra dei cast:";
	rewatch_loc["castbarHeight"] = "Altezza della barra dei cast:";
	rewatch_loc["sidebarWidth"] = "Barra laterale (classe) larghezza:";
	rewatch_loc["showDeficit"] = "Mostra la salute quando gli HP sono meno di";
	rewatch_loc["numFramesWide"] = "Numero di frame dei giocatori per ogni linea:";
	rewatch_loc["maxNameLength"] = "Lunghezza massima del nome visibile:";
	rewatch_loc["reposition"] = "Riposiziona";
	rewatch_loc["scaling"] = "Scala:";
	rewatch_loc["horizontal"] = "Layout orizzontale";
	rewatch_loc["vertical"] = "Layout verticale";
	rewatch_loc["showSelfFirst"] = "Mostra te stesso per primo";
	rewatch_loc["sortByRole"] = "Ordina per ruolo";
	rewatch_loc["showIncomingHeals"] = "Mostra le cure in arrivo";
	rewatch_loc["frameColumns"] = "Organizza i frames in colonne";

	-- help messages
	rewatch_loc["help"] = {};
	rewatch_loc["help"][1] = "Comandi di Rewatch disponibili:";
	rewatch_loc["help"][2] = " /rewatch: mostrerà i credits";
	rewatch_loc["help"][3] = " /rewatch add [_target||<name>] [_||always]: aggiungi il tuo bersaglio, o il giocatore col nome specificato alla lista";
	rewatch_loc["help"][4] = " /rewatch clear: cancella la lista di rewatch e resetta la sua altezza";
	rewatch_loc["help"][5] = " /rewatch sort: riorganizza la lista di rewatch con la struttura dei gruppi corrente";
	rewatch_loc["help"][6] = " /rewatch gcdAlpha [0 through 1]: sets the global cooldown overlay alpha, default=1=fully visible";
	rewatch_loc["help"][7] = " /rewatch frameAlpha [0 through 1]: sets the frame background alpha, default=0.4";
	rewatch_loc["help"][8] = " /rewatch hideSolo [0 or 1]: setta l’opzione di nascondi quando da solo, default=0=disabilitato";
	rewatch_loc["help"][9] = " /rewatch autoGroup [0 or 1]: setta l’opzione per autorganizzare il gruppo, default=1=abilitato";
	rewatch_loc["help"][10] = " /rewatch version: fornisce la versione attuale";
	rewatch_loc["help"][11] = " /rewatch lock/unlock: blocca o sblocca i movimenti di tutti i frame di Rewatch";
	rewatch_loc["help"][12] = " /rewatch hide/show: nascondi o mostra Rewatch";

	-- spell names
	rewatch_loc["rejuvenation"] = "Rinvigorimento";
	rewatch_loc["wildgrowth"] = "Crescita rigoliosa";
	rewatch_loc["regrowth"] = "Ricrescita";
	rewatch_loc["lifebloom"] = "Bocciolo di vita";
	rewatch_loc["innervate"] = "Innervazione";
	rewatch_loc["tranquility"] = "Tranquillit\195\160";
	rewatch_loc["swiftmend"] = "Guarigione Immediata";
	rewatch_loc["naturescure"] = "Nature's Cure";
	rewatch_loc["removecorruption"] = "Rimuovi Corruzione";
	rewatch_loc["ironbark"] = "Pelle di legnoduro";
	rewatch_loc["barkskin"] = "Pelledura";
	rewatch_loc["healingtouch"] = "Tocco Curativo";
	rewatch_loc["rebirth"] = "Pronto Ritorno";
	rewatch_loc["revive"] = "Rivivi";
	rewatch_loc["clearcasting"] = "Clearcasting";
	rewatch_loc["mushroom"] = "Efflorescenza";
	rewatch_loc["rejuvenation (germination)"] = "Rinvigorimento (Germinazione)";
	rewatch_loc["flourish"] = "Infiorescenza";
	
	-- big non-druid heals
	rewatch_loc["healingwave"] = "Ondata di Cura"; -- shaman
	rewatch_loc["greaterheal"] = "Greater Heal"; -- priest
	rewatch_loc["holylight"] = "Luce Sacra"; -- paladin
	
	-- shapeshifts
	rewatch_loc["bearForm"] = "Forma d’orso";
	rewatch_loc["direBearForm"] = "Dire Bear Form";
	rewatch_loc["catForm"] = "Forma Gatto";
	
end;