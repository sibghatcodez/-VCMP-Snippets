// Avg Ping & FPS Functions
function UpdatePlayerAveragePing(player)
{
    if (player.IsSpawned) {
        local currentPing = player.Ping;
        stats[player.ID].playerPing += currentPing;
        stats[player.ID].pingCount++;
        GetPlayerAveragePing(player);
    }
}



function GetPlayerAveragePing(player)
{
    local result;

    if (stats[player.ID].pingCount > 0) {
        result = stats[player.ID].playerPing / stats[player.ID].pingCount;
        stats[player.ID].Ping = result;
        return result;
    } else {
        return 0;
    }
}


function UpdatePlayerAverageFPS(player)
{
    if (player.IsSpawned) {
    local currentFPS = player.FPS;
    if (currentFPS > 60) {
        currentFPS = 60;
    }
    
    stats[player.ID].playerFPS += currentFPS;
    stats[player.ID].fpsCount++;
    GetPlayerAverageFPS(player)
    }
}

function GetPlayerAverageFPS(player)
{
    local result;

    if (stats[player.ID].fpsCount > 0) {
        result = stats[player.ID].playerFPS / stats[player.ID].fpsCount;
        stats[player.ID].FPS = result;
        return result;
    } else {
        return 0;
    }
}



function rotateRight(val, sbits)
 {
 return (val >> sbits) | (val << (0x20 - sbits));
 }



function getOrdinalNum(i)
 {
    local j = i % 10,
        k = i % 100;
    if (j == 1 && k != 11) {
        return i + "st";
    }
    if (j == 2 && k != 12) {
        return i + "nd";
    }
    if (j == 3 && k != 13) {
        return i + "rd";
    }
    return i + "th";
}



function GetPlayerPlayTime(player)
{
    local months, weeks, days, hours, minutes, seconds, result;
    local playTime = stats[player.ID].PlayTime;

    local totalTime = playTime;
    
    months = totalTime / (30 * 24 * 60 * 60);
    totalTime %= (30 * 24 * 60 * 60);

    weeks = totalTime / (7 * 24 * 60 * 60);
    totalTime %= (7 * 24 * 60 * 60);

    days = totalTime / (24 * 60 * 60);
    totalTime %= (24 * 60 * 60);

    hours = totalTime / (60 * 60);
    totalTime %= (60 * 60);

    minutes = totalTime / 60;
    totalTime %= 60;

    seconds = totalTime;

    result = "";

    if (months > 0) {
        result += "Months: " + months;
    }
    if (weeks > 0) {
        result += " Weeks: " + weeks;
    }
    if (days > 0) {
        result += " Days: " + days;
    }
    if (months == 0 && hours > 0) {
        result += " Hours: " + hours;
    }
    if (months == 0 && weeks == 0 && minutes > 0) {
        result += " Minutes: " + minutes;
    }
    if (months == 0 && weeks == 0 && days == 0 && minutes > 0) {
        result += " Seconds: " + seconds;
    }
    else {
        result = "Less than a minute";
    }
    return result;
}



function GetRandJoinMsg() 
{
    local rand = random(1, 13);
    switch (rand) {
        case 1:
            return "has yeeted from";
        case 2:
            return "has arrived from";
        case 3:
            return "has joined from";
        case 4:
            return "has established from";
        case 5:
            return "has teleported from";
        case 6:
            return "has crash-landed from";
        case 7:
            return "has beamed down from";
        case 8:
            return "has time-traveled from";
        case 9:
            return "has parachuted from";
        case 10:
            return "has disco-danced from";
        case 11:
            return "has moonwalked from";
        case 12:
            return "has roller-skated from";
        case 13:
            return "has been abducted from";
        default:
            return "has connected from";
    }
}




 // Account Functions
 function GetPass( player )
 {
 local result = GetSQLColumnData( QuerySQL( db, "SELECT Password FROM Accounts WHERE Name='"+player.Name+"'" ), 0 );
 if ( result ) return result;
 else return 0;
 }



 function SaveStats(player)
{
    // -> Account
QuerySQL( db, "UPDATE Accounts SET Level='"+stats[ player.ID ].Level+"',IP='"+stats[ player.ID ].IP+"', AutoLogin="+stats[ player.ID ].AutoLogin+" WHERE Name = '" + escapeSQLString(player.Name) + "'" );

    // -> Info
QuerySQL( db, "UPDATE Info SET Survivals = '"+stats[ player.ID ].Survivals+"', Kills = '"+stats[ player.ID ].Kills+"', Ping = '"+stats[ player.ID ].Ping+"', FPS = "+stats[ player.ID ].FPS+", Language = '"+stats[ player.ID ].Lang+"', PlayTime = '"+stats[player.ID].PlayTime+"' WHERE Name = '" + escapeSQLString(player.Name) + "'");
}



function CheckLogin(player) 
{
    if (!stats[player.ID].Reg) {
        FilterMsg("-> This account is not registered. Please [#ffffff]/register[#B6E2A1] to play.", "Is account ko register nahi kya gaya hai. Khailne ke liye [#ffffff]/register[#B6E2A1] karein.", player);
        // SendDataToClient(player, 1, "Register");
    } else if (stats[player.ID].Reg && !stats[player.ID].AutoLogin) {
        FilterMsg("-> This account is not logged-in. Please [#ffffff]/login[#B6E2A1] to play.", "Is account mein login nahi kya gaya hai. Khailne ke liye [#ffffff]/login[#B6E2A1] karein.", player);
    } else if (stats[player.ID].AutoLogin && player.IP != stats[player.ID].IP) {
        FilterMsg("-> This account is not logged-in. Please [#ffffff]/login[#B6E2A1] to play.", "Is account mein login nahi kya gaya hai. Khailne ke liye [#ffffff]/login[#B6E2A1] karein.", player);
    } else if (stats[player.ID].AutoLogin && player.IP == stats[player.ID].IP) {
        FilterMsg("[#AAE3E2]Your account has been auto logged-in succesfully.", "[#AAE3E2]Your account has been auto logged-in successfully.!", player);
        stats[player.ID].Log = true;
    }
}



function GetStats(player, plr) 
{
    if(plr == null) {
    // local player = GetPlayer(player);
    MessagePlayer("[#ffffff]-> [#B6E2A1]Statistics ("+player.Name+") : Survivals: "+stats[player.ID].Survivals+" | Kills: "+stats[player.ID].Kills+"",player);
    MessagePlayer("[#ffffff]-> [#B6E2A1]Statistics: PlayTime: "+GetPlayerPlayTime(player)+" | Avg Ping: "+stats[player.ID].Ping+" | Avg FPS: "+stats[player.ID].FPS+"",player);
    } else {
    MessagePlayer("[#ffffff]-> [#B6E2A1]Statistics ("+plr.Name+") : Survivals: "+stats[plr.ID].Survivals+" | Kills: "+stats[plr.ID].Kills+"",player);
    MessagePlayer("[#ffffff]-> [#B6E2A1]Statistics: PlayTime: "+GetPlayerPlayTime(plr)+" | Avg Ping: "+stats[plr.ID].Ping+" | Avg FPS: "+stats[plr.ID].FPS+"",player);
    }
}



function GetInfo(player)
{
        // -> Account
 local q = QuerySQL(db, "SELECT * FROM Accounts WHERE Name = '" + escapeSQLString(player.Name) + "'");
 if (q)
 {
  stats[ player.ID ].ID = GetSQLColumnData(q, 0);
  stats[ player.ID ].Password = GetSQLColumnData(q, 3);
  stats[ player.ID ].Level = GetSQLColumnData(q, 4);
  stats[ player.ID ].IP = GetSQLColumnData(q, 6);
  stats[ player.ID ].UID = GetSQLColumnData(q, 7);
  stats[ player.ID ].AutoLogin = GetSQLColumnData(q, 8);
  stats[ player.ID ].Reg = true;
 }
    // -> Info
 local q_2 = QuerySQL(db, "SELECT * FROM Info WHERE Name = '" + escapeSQLString(player.Name) + "'");
 if (q_2)
 {
  stats[ player.ID ].Survivals = GetSQLColumnData(q_2, 3);
  stats[ player.ID ].Kills = GetSQLColumnData(q_2, 4);
  stats[ player.ID ].Ping = GetSQLColumnData(q_2, 5);
  stats[ player.ID ].FPS = GetSQLColumnData(q_2, 6);
  stats[ player.ID ].Lang = GetSQLColumnData(q_2, 7);
  stats[ player.ID ].PlayTime = GetSQLColumnData(q_2, 8);
 }

CheckLogin(player);
}









// FilterMessage Function for Langs



function FilterMsg(en, urdu, player)
{
    if(stats[player.ID].Lang == "EN") {
        MessagePlayer("[#FFFFFF]* [#B6E2A1]"+en+"",player);
    } else if(stats[player.ID].Lang == "URDU") {
        MessagePlayer("[#FFFFFF]* [#B6E2A1]"+urdu+"",player);
    }
}
function SyntaxMsg(msg,player)
{
        if(stats[player.ID].Lang == "EN") {
        MessagePlayer("[#FFFFFF]-> Usage: [#E97777]"+msg+"",player);
    } else if(stats[player.ID].Lang == "URDU") {
        MessagePlayer("[#FFFFFF]-> Istemaal: [#E97777]"+msg+"",player);
    }
}
function ErrorMsg(msg,player)
{
        MessagePlayer("[#FFFFFF]-> Error: [#FF6464]"+msg+"",player);
}



// Reload Script Functions




function getOnlinePlayers() 
{
    local players = []
    for (local i = 0; i < GetMaxPlayers(); i++) if (FindPlayer(i) != null) players.append({Name = FindPlayer(i).Name, ID = i});
    return players;
}
function getPlayer(object) 
{
    if (type(object) == "integer") return FindPlayer(object)
    else foreach (v in getOnlinePlayers()) if (v.Name.tolower() == (object + "").tolower()) return FindPlayer(v.ID)
    return null
}

function addVehicle(vehicle) 
{
    if (vehicle != null) Vehicles.append(vehicle)
    return vehicle
}
function removeVehicles() 
{
    foreach (i, a in Vehicles) {
        if (a != null) a.Delete();
    }
    Vehicles.clear()
}
function removeVehicle(id) 
{
    foreach (i, a in Vehicles) {
        if (a != null && (a.ID == id || a == id)) {
            Vehicles.remove(i)
            a.Delete()
            return null
        }
    }
    return null;
}
function VehicleFind(id) 
{
    foreach (i, a in Vehicles) {
        if (a.ID == id) return a
    }
    return null;
}
function addCheckpoint(checkpoint) 
{
    Checkpoints.append(checkpoint)
    return checkpoint
}
function removeCheckpoints()
 {
    foreach (i, a in Checkpoints) {
        if (a != null) a.Delete();
    }
    Checkpoints.clear()
}
function removeCheckpoint(id)
 {
    foreach (i, a in Checkpoints) {
        if (a != null && (a.ID == id || a == id)) {
            Checkpoints.remove(i)
            a.Remove()
            return null
        }
    }
    return null;
}
function CheckpointFind(id) 
{
    foreach (i, a in Checkpoints) {
        if (a != null && a.ID == id) return a
    }
    return null;
}
function addObject(object) 
{
    Objects.append(object)
    return object
}
function removeObjects() 
{
    foreach (i, a in Objects) {
        if (a != null) a.Delete();
    }
    Objects.clear()
}
function removeObject(id) 
{
    foreach (i, a in Objects) {
        if (a != null && (a.ID == id || a == id)) {
            Objects.remove(i)
            a.Delete()
            return null
        }
    }
    return null;
}
function ObjectFind(id) 
{
    foreach (i, a in Objects) {
        if (a != null && a.ID == id) return a
    }
    return null;
}
function addMarker(marker)
 {
    Markers.append(marker)
    return marker
}
function removeMarker(marker) 
{
    foreach (i, a in Markers) {
        if (a != null && a == marker) {
            Markers.remove(i)
            DestroyMarker(marker)
            return null
        }
    }
    return marker
}
function removeMarkers() 
{
    foreach (i, a in Markers) {
        DestroyMarker(a)
    }
    Markers.clear()
}
function removePickup(obj) 
{
    foreach (i, a in pickups) {
        if (a != null && (a.ID == obj || a == obj)) {
            pPickups.remove(i)
            a.Remove()
            return null
        }
    }
    return null;
}
function PickupFind(obj)
 {
    foreach (i, a in pickups) {
        if (a != null && (a.ID == obj || a == obj)) return a
    }
    return null;
}
function addPickup(pickup) 
{
    Pickups.append(pickup)
    return pickup
}
function removePickups() 
{
    foreach (i, a in Pickups) {
        a.Remove();
    }
    Pickups.clear()
}




// Most Important Functions



function GetTok(string, separator, n, ...)
{
local m = vargv.len() > 0 ? vargv[0] : n,
tokenized = split(string, separator),
text = "";
if (n > tokenized.len() || n < 1) return null;
for (; n <= m; n++)
{
text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
}
return text;
}



function NumTok(string, separator)
{
	local tokenized = split(string, separator);
	return tokenized.len();
}



function GetPlayer( target )
{
 local target1 = target.tostring();

 if ( IsNum( target ) )
 {
  target = target.tointeger();

  if ( FindPlayer( target) ) return FindPlayer( target );
  else return null;
 }
 else if ( FindPlayer( target ) ) return FindPlayer( target );
 else return null;
}



function random( min, max )
{
        if ( min < max )
                return rand() % (max - min + 1) + min.tointeger();
        else if ( min > max )
                return rand() % (min - max + 1) + max.tointeger();
        else if ( min == max )
                return min.tointeger();
}
