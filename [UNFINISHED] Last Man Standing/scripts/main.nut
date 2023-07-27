class PlayerClass
{
    // Accounts
 ID = 0;
 Password = null;
 Level = 0;
 IP = null;
 UID = null;
 AutoLogin = false;
 Log = false;
 Reg = false;

    // Info
 Survivals = 0;
 Kills = 0;
 Ping = 0;
 FPS = 0;
 Lang = "EN";
 PlayTime = 0;

 //Variables for Avg FPS & Avg Ping
 playerFPS = 0;
 fpsCount = 0;
 playerPing = 0;
 pingCount = 0;

 //Variable for LoginAttempt
 LogAttempt = 0;

 //Variable to check if player is in Lobby.
 InLobby = true;
}


Vehicles <- []
Pickups <- []
Objects <- []
Checkpoints <- []
Markers <- []
BindInstanceKeys <- {} 

// ---> SERVER FUNCTIONS <---

function onServerStart()
{
}
function onServerStop()
{
}
function onScriptLoad()
{




db <- ConnectSQL("scripts/Database/Accounts.db");
QuerySQL(db, "CREATE TABLE IF NOT EXISTS Accounts(ID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, LowerName TEXT, Password VARCHAR(255), Level NUMERIC DEFAULT 1, TimeRegistered VARCHAR(255) DEFAULT CURRENT_TIMESTAMP, IP VARCHAR(255), UID VARCHAR(255), AutoLogin BOOLEAN DEFAULT true ) ");
QuerySQL(db, "CREATE TABLE IF NOT EXISTS Info(ID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, LowerName TEXT, Survivals NUMERIC DEFAULT 0, Kills NUMERIC DEFAULT 0, Ping VARCHAR(50), FPS VARCHAR(50), Language VARCHAR(20), PlayTime INTEGER)")
stats <- array(GetMaxPlayers(), null);
dofile("scripts/components/srvrFuncs.nut");
dofile("scripts/components/cstmFuncs.nut");
dofile("scripts/components/commands.nut");

print("The server has been loaded without any errors.");
}

function onScriptUnload()
{
}

// =========================================== P L A Y E R   E V E N T S ==============================================

function onPlayerJoin(player) 
{
    local country = geoip_country_name_by_addr(player.IP);

    if (country != null) {
        Message("[#ffffff]>> [#AAE3E2]" + player.Name + " " + GetRandJoinMsg() + " " + country + " [" + geoip_country_code3_by_addr(player.IP) + "]");
    } else {
        Message("[#ffffff]>> [#AAE3E2]" + player.Name + " is connecting from No Man's Land");
    }

    stats[player.ID] = PlayerClass();
    GetInfo(player);

    FilterMsg("Welcome to Last Man Standing, [#FFFFFF]" + player.Name + "!\n[#FFFFFF]*Type [#ffffff]/gamemode[#B6E2A1] to understand the game mode or [#ffffff]/cmd[#B6E2A1] for a list of available commands.", "Last Man Standing mein khush amdeed, [#FFFFFF]" + player.Name + "!\n[#FFFFFF]* [#B6E2A1]Gamemode Samajhne ke liye [#ffffff]/gamemode[#B6E2A1] likhein aur commands ki list ke liye [#ffffff]/cmd[#B6E2A1] likhein.", player);
}


function onPlayerPart( player, reason )
{
SaveStats(player);
}

function onPlayerRequestClass( player, classID, team, skin )
{
	return 1;
}

function onPlayerRequestSpawn( player )
{
    return 1;
}

function onPlayerSpawn( player )
{
    SendDataToClient(player, 0x01, stats[player.ID].Kills)
}


function onPlayerTeamKill( player, killer, reason, bodypart )
{
}

function onPlayerChat( player, text )
{
	print( player.Name + ": " + text );
	return 1;
}

function onPlayerPM( player, playerTo, message )
{
	return 1;
}



function onPlayerBeginTyping( player )
{
}

function onPlayerEndTyping( player )
{
}

function onNameChangeable( player )
{
}

function onPlayerSpectate( player, target )
{
}

function onPlayerCrashDump( player, crash )
{
}

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ )
{
}

function onPlayerHealthChange( player, lastHP, newHP )
{
}

function onPlayerArmourChange( player, lastArmour, newArmour )
{
}

function onPlayerWeaponChange( player, oldWep, newWep )
{
}

function onPlayerAwayChange( player, status )
{
}

function onPlayerNameChange( player, oldName, newName )
{
}

function onPlayerActionChange( player, oldAction, newAction )
{
}

function onPlayerStateChange( player, oldState, newState )
{
}

function onPlayerOnFireChange( player, IsOnFireNow )
{
}

function onPlayerCrouchChange( player, IsCrouchingNow )
{
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
}

function onPlayerUpdate( player, update )
{
}



function onClientScriptData(player)
{
}

// ========================================== V E H I C L E   E V E N T S =============================================

function onPlayerEnteringVehicle( player, vehicle, door )
{
	return 1;
}

function onPlayerEnterVehicle( player, vehicle, door )
{
}

function onPlayerExitVehicle( player, vehicle )
{
}

function onVehicleExplode( vehicle )
{
}

function onVehicleRespawn( vehicle )
{
}

function onVehicleHealthChange( vehicle, oldHP, newHP )
{
}

function onVehicleMove( vehicle, lastX, lastY, lastZ, newX, newY, newZ )
{
}

// =========================================== P I C K U P   E V E N T S ==============================================

function onPickupClaimPicked( player, pickup )
{
	return 1;
}

function onPickupPickedUp( player, pickup )
{
}

function onPickupRespawn( pickup )
{
}

// ========================================== O B J E C T   E V E N T S ==============================================

function onObjectShot( object, player, weapon )
{
}

function onObjectBump( object, player )
{
}

// ====================================== C H E C K P O I N T   E V E N T S ==========================================

function onCheckpointEntered( player, checkpoint )
{
}

function onCheckpointExited( player, checkpoint )
{
}

// =========================================== B I N D   E V E N T S =================================================

function onKeyDown( player, key )
{
}

function onKeyUp( player, key )
{
}

// ================================== E N D   OF   O F F I C I A L   E V E N T S ======================================