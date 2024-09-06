function onPlayerCommand( player, cmd, text )
{
 switch(cmd) {


 case "exec":
  if( !text ) MessagePlayer( "-> /exec <Squirrel code>", player);
  else
  {
   try
   {
    local script = compilestring( text );
    script();
   }
   catch(e) MessagePlayer( "Error: " + e, player);
  }
break;
 


 case "reload":
    local loaded = []
    foreach (v in getOnlinePlayers()) {
        if (getPlayer(v.ID) != null && getPlayer(v.ID).Spawned) loaded.append(player)
    }
    onServerStop()
    dofile("scripts/main.nut") // your main script.
    onScriptLoad()
    foreach (b in getOnlinePlayers()) {
        onPlayerJoin(getPlayer(b.ID))
    }
    foreach (player in loaded) {
        onPlayerRequestClass(getPlayer(v.ID), getPlayer(v.ID).Class, getPlayer(v.ID).Team, getPlayer(v.ID).Skin)
        if (getPlayer(v.ID).IsSpawned) onPlayerSpawn(getPlayer(v.ID))
    }
    AnnounceAll("Reloaded.", 0)
    SaveStats(player);
    break;



case "reloader":
        local loaded = []
    foreach (v in getOnlinePlayers()) {
        if (getPlayer(v.ID) != null && getPlayer(v.ID).Spawned) loaded.append(player)
    }
    onServerStop()
    dofile("main.nut")
    onScriptLoad()
    foreach (b in getOnlinePlayers()) {
        onPlayerJoin(getPlayer(b.ID))
    }
    foreach (player in loaded) {
        onPlayerRequestClass(getPlayer(v.ID), getPlayer(v.ID).Class, getPlayer(v.ID).Team, getPlayer(v.ID).Skin)
        if (getPlayer(v.ID).IsSpawned) onPlayerSpawn(getPlayer(v.ID))
    }
    AnnounceAll("Reloaded.", 0)
break;

case "register":
    if(stats[player.ID].Reg) ErrorMsg("Your account is already registered.",player);
    else if (!text) SyntaxMsg("/register pass",player);
    else if (text.len() < 4) ErrorMsg("Password is too short.",player);
    else if (text == "123" || text == "1234" || text == "12345") ErrorMsg("Password is too basic.",player);
    else {
        local Password = SHA256(text);
        local date = date();

        // -> Accounts
        QuerySQL(db, "INSERT INTO Accounts(Name, LowerName, Password, Level, TimeRegistered, IP, UID, AutoLogin) VALUES('"+escapeSQLString(player.Name)+"', '"+escapeSQLString(player.Name.tolower())+"', '"+Password+"', '"+1+"', '"+ date.year +"/"+date.month+"/"+date.day+"/"+date.hour+":"+ date.min + "', '"+player.IP+"', '"+player.UID+"', "+true+")");

        local q = QuerySQL(db, "SELECT * FROM Accounts WHERE Name = '"+escapeSQLString(player.Name)+"'");
            stats[ player.ID ].Reg = true;
            stats[ player.ID ].Log = true;
            stats[ player.ID ].ID = GetSQLColumnData(q, 0);
            stats[ player.ID ].Level = 1;
            stats[ player.ID ].IP = player.IP;
            stats[ player.ID ].UID = player.UID;
            stats[ player.ID ].AutoLogin = true;


        // -> Info
        QuerySQL(db, "INSERT INTO Info(Name, LowerName, Survivals, Kills, Ping, FPS, Language, PlayTime) VALUES('"+escapeSQLString(player.Name)+"', '"+escapeSQLString(player.Name.tolower())+"', '"+0+"', '"+0+"', '"+0+"', '"+0+"', '"+stats[ player.ID ].Lang+"', '"+stats[ player.ID ].PlayTime+"')");

            stats[ player.ID ].Survivals = 0;
            stats[ player.ID ].Kills = 0;
            stats[ player.ID ].Ping = 0;
            stats[ player.ID ].FPS = 0;
            stats[ player.ID ].Lang = "EN";

        Message("--> "+player.Name+" is now the "+getOrdinalNum(stats[player.ID].ID)+" registered player.");
    }
break;



case "login":
    if (!stats[player.ID].Reg)
        FilterMsg("[#FF6464]This account is not registered. Please /register to play.", "[#FF6464]Ye account register nahi hai. Khailne ke liye /register karain.", player);
    else if (stats[player.ID].Log)
        FilterMsg("[#FF6464]This account is already logged in.", "[#FF6464]Ye account pehle se login ho chuka hai.", player);
    else if (!text)
        SyntaxMsg("/login pass", player);
    else if (SHA256(text) != GetPass(player)) { 
        stats[player.ID].LogAttempt++;
        FilterMsg("[#FF6464]Invalid Password. Attempt: [" + stats[player.ID].LogAttempt + "/3]", "[#FF6464]Ghalt Password. Koshish: [" + stats[player.ID].LogAttempt + "/3]", player);
        if (stats[player.ID].LogAttempt == 3) {
            Message("[#FF6464]>> "+player.Name + " has been kicked login attempt exceeded");
            KickPlayer(player);
        }
    }
    else {
        stats[player.ID].Log = true;
        Message("[#ffffff]** [#AAE3E2]" + player.Name + " has logged in to the server.");
    }
break;


case "autologin":
    if (!stats[player.ID].Reg)
        FilterMsg("[#FF6464]This account is not registered. Please /register to use AutoLogin.", "[#FF6464]Ye account register nahi hai. AutoLogin istemal karne ke liye /register karein.", player);
    else if (!stats[player.ID].Log)
        FilterMsg("[#FF6464]This account is not logged in. Please /login to use AutoLogin.", "[#FF6464]Ye account login nahi hai. AutoLogin istemal karne ke liye /login karein.", player);
    else if (stats[player.ID].AutoLogin) {
        FilterMsg("-> AutoLogin turned off.", "-> AutoLogin band ho gaya hai.", player);
        stats[player.ID].AutoLogin = false;
    } else {
        FilterMsg("-> AutoLogin turned on.", "-> AutoLogin chalu ho gaya hai.", player);
        stats[player.ID].AutoLogin = true;
    }
break;



case "stats":
    if (!stats[player.ID].Reg)
        FilterMsg("[#FF6464]This account is not registered. Please /register to view stats.", "[#FF6464]Ye account register nahi hai. Stats dekhne ke liye /register karein.", player);
    else if (!stats[player.ID].Log)
        FilterMsg("[#FF6464]This account is not logged in. Please /login to view stats.", "[#FF6464]Ye account login nahi hai. Stats dekhne ke liye /login karein.", player);
    else if (!text)
        GetStats(player, null);
    else {
        local plr = GetPlayer(text);
        if (!plr)
            FilterMsg("[#FF6464]Player not found.", "[#FF6464]Player nahi mila.", player);
        else
            GetStats(player, plr);
    }
break;


case "changepass":
    if (!stats[player.ID].Reg) {
        FilterMsg("[#FF6464]This account is not registered. Please /register.", "[#FF6464]Ye account register nahi hai. Password change karne ke liye /register karein.", player);
    } else if (!stats[player.ID].Log) {
        FilterMsg("[#FF6464]This account is not logged in. Please /login.", "[#FF6464]Ye account login nahi hai. Password change karne ke liye /login karein.", player);
    } else if (!text) {
        SyntaxMsg("/changepass old_pass new_pass", player);
    } else {
        local args = split(text, " ");
        if (args.len() < 2) {
            FilterMsg("Usage: /changepass old_pass new_pass", "Usage: /changepass old_pass new_pass", player);
        } else {
            local oldPassword = SHA256(args[0]);
            local newPassword = SHA256(args[1]);
            local query = format("SELECT Password FROM Accounts WHERE ID=%d", stats[player.ID].ID);

            if (oldPassword != GetPass(player)) {
                FilterMsg("[#FF6464]Invalid old password. Please try again.", "[#FF6464]Galat old password. Dubara koshish karein.", player);
            } else if (newPassword.len() < 4) {
                FilterMsg("[#FF6464]New password is too short.", "[#FF6464]New password bohat chota hai.", player);
            } else if (newPassword == "123" || newPassword == "1234" || newPassword == "12345") {
                FilterMsg("[#FF6464]New password is too basic.", "[#FF6464]New password bohat asaan hai.", player);
            } else {
                local updateQuery = format("UPDATE Accounts SET Password='%s' WHERE ID=%d", escapeSQLString(newPassword), stats[player.ID].ID);
                QuerySQL(db, updateQuery);
                FilterMsg("Password changed successfully!", "Password kaamyaab sey tabdeel ho gaya!", player);
            }
        }
    }
break;


case "lang":
case "language":
    if (!stats[player.ID].Reg) {
        FilterMsg("[#FF6464]This account is not registered. Please /register.", "[#FF6464]Ye account register nahi hai. Language change karne ke liye /register karein.", player);
    } else if (!stats[player.ID].Log) {
        FilterMsg("[#FF6464]This account is not logged in. Please /login.", "[#FF6464]Ye account login nahi hai. Language change karne ke liye /login karein.", player);
    } else if (!text) {
        SyntaxMsg("/language <EN/Urdu>", player);
    } else {
        local langCode = text.toupper();
        if (langCode == "EN" || langCode == "URDU") {
            if (stats[player.ID].Lang == langCode) {
                FilterMsg("Language is already set to " + langCode, "Zubaan pehle sey " + langCode + " set hai.", player);
            } else {
                stats[player.ID].Lang = langCode;
                FilterMsg("Language set to " + langCode, "Zubaan " + langCode + " set ho gayi hai.", player);
            }
        } else {
            FilterMsg("[#FF6464]Invalid language code. Available codes: EN, Urdu", "Ghalt code. Dastiyab codes: EN, Urdu", player);
        }
    }
break;

case "cmds":
case "cmd":
case "command":
case "commands":
FilterMsg("register, login, autologin, changepass, stats, language","register, login, autologin, changepass, stats, language, discord",player);
break;


// case "discord":
// SetClipboardText("dcLink^_^");
// FilterMsg("Discord Link Copied!", "Discord server ki link copy hogyi!",player);
// break;

default:
local Commands = ["register", "login", "changepass", "stats", "gamemode", "language", "autologin", "commands", "discord"];
 if (cmd.len() >= 3) {
 local matchFound = false;
 local indexCmd = "";

 for (local i = 0; i < Commands.len(); i++) {
  if (cmd == Commands[i]) {
  matchFound = true;
  break;
  }
  indexCmd += cmd.slice(i, i + 1);
  
  if (i == 1) {
  break;
  }
 }
 
 if (!matchFound) {
  for (local i = 0; i < Commands.len(); i++) {
  local currentCmd = Commands[i].slice(0, 2);
  
  if (indexCmd == currentCmd) {
   ErrorMsg("Invalid Command, did you mean [#ffffff]'"+Commands[i]+"'", player);
   matchFound = true;
   break;
  }
  }
  
  if (!matchFound) {
  ErrorMsg("Invalid Command, check /cmds for available list of commands.", player);
  }
 }
 } else {
 ErrorMsg("Invalid Command, check /cmds for available list of commands.", player);
 }
}
}
