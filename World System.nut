Inside PlayerClass ->
	 lastWorld = 0;

class PlayerData
{
	MapDelete = false;
	PositionMode = false;
	Speed = "normal";
	Editing = false;
	Holding = false;
	Motion = null;
	LastKey = null;
	CTRL = false;
	car = null;
}


constants -> 
	const WORLDS = 1000;
	const WORLD_PRICE = 1000000;
	const Motion_Speed = 100;

Inside onScriptLoad() ->
	 db <- ConnectSQL("Worlds.db");
 QuerySQL(db, "create table if not exists Worlds (World INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Owner TEXT, Shared TEXT, Price NUMERIC DEFAULT 0)");
//AddWorlds(); //Uncomment and use this only one and  then delete or comment it again.

pData <- array( GetMaxPlayers(), null );
Object <- array( GetMaxPlayers(), null );

// =========================================== DATABASE ============================================
Maps <- SQLite_Open( "Objects.sqlite" );
SQLite_Exec(Maps, "CREATE TABLE IF NOT EXISTS Objects (World INT, model INT, x INT, y INT, z INT, rotx FLOAT, roty FLOAT, rotz FLOAT )");
// =========================================== GLOBAL ==============================================
objCreated <- 0;
object_count <- 0;

// =========================================== BINDS ===============================================
del <- BindKey( true, 0x2E, 0, 0 );
backspace <- BindKey( true, 0x08, 0, 0 );
R <- BindKey( true, 0x52, 0, 0 );
one <- BindKey( true, 0x31, 0, 0 );
two <- BindKey( true, 0x32, 0, 0 );
ctrl <- BindKey( true, 0x11, 0, 0 );
c <- BindKey(true, 0x43, 0, 0 );
PageUp <- BindKey( true, 0x21, 0, 0 );
PageDown <- BindKey( true, 0x22, 0, 0 );
ArrowUp <- BindKey( true, 0x26, 0, 0 );
ArrowDown <- BindKey( true, 0x28, 0, 0 );
ArrowLeft <- BindKey( true, 0x25, 0, 0 );
ArrowRight <- BindKey( true, 0x27, 0, 0 );


Custom Functions:
	function AddWorlds() { //use this function only once.
    for (local i = 1; i <= WORLDS; i++) {
        QuerySQL(db, "INSERT INTO Worlds(Name, Owner, Shared, Price) VALUES('None', 'None', 'None', "+WORLD_PRICE+")");
    }
}

function LoadWorldObjects(worldID, player) {
    local query;
    try {
        query = SQLite_Query(Maps, "SELECT world,model, x, y, z, rotx, roty, rotz FROM Objects WHERE World = " + worldID);
    } catch (e) {
        return MessagePlayer("[#30cb68]**  [#ffffff]Failed to load objects for world " + worldID + ".", player);
    }

    if (!query || !SQLite_NextRow(query)) {
        return MessagePlayer("[#30cb68]** [#ffffff]No objects found for world " + worldID + ".", player);
    }

    local objCreated = 0;
    do {
        local world = GetSQLColumnData(query, 0);
        local model = GetSQLColumnData(query, 1);
        local x = GetSQLColumnData(query, 2);
        local y = GetSQLColumnData(query, 3);
        local z = GetSQLColumnData(query, 4);
        local rotx = GetSQLColumnData(query, 5);
        local roty = GetSQLColumnData(query, 6);
        local rotz = GetSQLColumnData(query, 7);

        local _obj = CreateObject(model, world, x, y, z, 255);
        _obj.RotationEuler.x = rotx;
        _obj.RotationEuler.y = roty;
        _obj.RotationEuler.z = rotz;

        objCreated++;
        _obj.TrackingShots = true;
        Object[player.ID] = _obj;
    }
    while (SQLite_NextRow(query));

    SQLite_Release(query);
    MessagePlayer("[#30cb68]** Loaded " + objCreated + " objects for world " + worldID + ".", player);
}
function GetWorldData(worldID) {
    local query = QuerySQL(db, "SELECT * FROM Worlds WHERE World = " + worldID);

    if (query) {
		local data = {
			"ID": GetSQLColumnData(query, 0),
			"Name": GetSQLColumnData(query, 1),
			"Owner": GetSQLColumnData(query, 2),
			"Shared": GetSQLColumnData(query, 3)
		};
		return data;
	}
}
function onPlayerJoin( player )
{
pData[ player.ID ] = PlayerData( player.Name );
Object[ player.ID ] = null;
}

Inside onPlayerPart()
	pData[ player.ID ].Editing = false;
pData[ player.ID ] = null;
	Object[ player.ID ] = null;

Inside onPlayerJoin()
	pData[ player.ID ] = PlayerData( player.Name );
	Object[ player.ID ] = null;

Commands: ->
 else if (cmd == "worldcmds") {
    MessagePlayer("[#30cb68]World Commands:[#ffffff] /gotoworld[#30cb68], [#ffffff]/buyworld[#30cb68], [#ffffff]/sellworld[#30cb68], [#ffffff]/shareworld[#30cb68], [#ffffff]/delshareworld[#30cb68], [#ffffff]/myworlds[#30cb68], [#ffffff]/sharedworlds[#30cb68], [#ffffff]/world[#30cb68], [#ffffff]/addobject[#30cb68], [#ffffff]/objects[#30cb68], [#ffffff]/setworldname", player);
}

  else if (cmd == "gotoworld") {
    if (!text) {
        MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<world ID>", player);
    } else if (player.World == text.tointeger()) MessagePlayer("[#30cb68]** You are already in world [#ffffff][ "+player.World+" ]", player);
	else if (pData[player.ID].Editing) MessagePlayer("[#30cb68]** You cannot tp while in editing mode, press backspace.", player);
	else {
		stats[player.ID].lastWorld = player.World;
        local worldID = text.tointeger();
        if (worldID > 1000 || worldID < 1) {
            MessagePlayer("[#30cb68]** World IDs should be between 1 and 1000.", player);
        } else {
			player.World = worldID;
			LoadWorldObjects(player.World, player);
			Message("[#30cb68]** [#ffffff]"+player + "[#30cb68] has teleported to world [#ffffff]" + player.World);
			local world = GetWorldData(player.World);
			MessagePlayer("[#30cb68]**World: [#ffffff]["+world.ID+" [#30cb68]: [#ffffff]"+world.Name+"] [#30cb68]Owned By: [#ffffff][ "+world.Owner+" ] [#30cb68]Shared With: [#ffffff][ "+world.Shared+" ]",player);
            }
        }
    }

	else if (cmd == "buyworld") {
		if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<world ID>", player);
		} else if (text.tointeger() == 1) {
			MessagePlayer("[#30cb68]** You cannot buy the main/public world.", player);
		} else {
			local world = GetWorldData(player.World);
			if (world.Owner != "None") {
				MessagePlayer("[#30cb68]** This world is already owned by [#ffffff][ " + world.Owner + " ]", player);
			} else if (player.Cash < WORLD_PRICE) {
				MessagePlayer("[#30cb68]** Insufficient funds! Required amount: [#ffffff][ " + WORLD_PRICE + " ]", player);
			} else {
				QuerySQL(db, "UPDATE Worlds SET Owner = '" + escapeSQLString(player.Name) + "' WHERE World = " + text.tointeger());
				Message("[#30cb68]** World: [#ffffff][" + world.ID + " : " + world.Name + "] [#30cb68]bought by [#ffffff][ " + player.Name + " ]");
			}
		}
	}

	else if (cmd == "sellworld") {
		if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<world ID>", player);
		} else if (text.tointeger() == 1) {
			MessagePlayer("[#30cb68]** You cannot sell the main/public world.", player);
		} else {
			local world = GetWorldData(player.World);
			QuerySQL(Maps, "DELETE FROM Objects WHERE World = " + player.World);
			if (world.Owner != player.Name) {
				MessagePlayer("[#30cb68]** You don't own this world.", player);
			} else {
				QuerySQL(db, "UPDATE Worlds SET Name = 'None', Owner = 'None', Shared = 'None' WHERE World = " + text.tointeger());
				Message("[#30cb68]** World: [#ffffff][" + world.ID + " : " + world.Name + "] [#30cb68]sold by [#ffffff][ " + player.Name + " ]");
				MessagePlayer("[#30cb68]** World sold for half of world's price: [#ffffff]$" + WORLD_PRICE / 2, player);
				player.Cash += WORLD_PRICE / 2;
			}
		}
	}	else if (cmd == "setworldname") {
		if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<name>", player);
		} else if (player.World == 1) {
			MessagePlayer("[#30cb68]** You are in main/public world.", player);
		} else {
			local world = GetWorldData(player.World);
			if (world.Owner != player.Name) {
				MessagePlayer("[#30cb68]** You don't own this world.", player);
			} else {
				local worldName = text.tostring();
				QuerySQL(db, "UPDATE Worlds SET Name = '" + worldName + "' WHERE World = " + player.World + "");
				MessagePlayer("[#30cb68]** World: [#ffffff][" + world.ID + " ] [#30cb68]named changed to [#ffffff][ " + text.tostring() + " ]", player);
			}
		}
	}

	else if (cmd == "shareworld") {
		if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<player>", player);
		} else if (player.World == 1) {
			MessagePlayer("[#30cb68]** You are in the main/public world.", player);
		} else {
			local world = GetWorldData(player.World);
			local plr = FindPlayer(text);
			if (!plr) {
				MessagePlayer("[#30cb68]** Unknown Player", player);
			} else if (world.Owner != player.Name) {
				MessagePlayer("[#30cb68]** This world is not owned by you", player);
			} else if (world.Shared != "None") {
				MessagePlayer("[#30cb68]** You are already sharing this world with [#ffffff][ " + world.Shared + " ]", player);
			} else if (text == player.Name) {
				MessagePlayer("[#30cb68]** Fool you can't share your world with yourself LOL", player);
			} else {
				QuerySQL(db, "UPDATE Worlds SET Shared = '" + escapeSQLString(plr.Name) + "' WHERE World = " + player.World);
				MessagePlayer("[#30cb68]** You are sharing this world with: [#ffffff][ " + plr.Name + " ]", player);
				MessagePlayer("[#ffffff][ " + player.Name + " ] [#30cb68]is sharing his world [#ffffff]["+world.ID+" : "+world.Name+"] [#30cb68]with you.", plr);
			}
		}
	}

	else if (cmd == "delshareworld") {
		if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<player>", player);
		} else if (player.World == 1) {
			MessagePlayer("[#30cb68]** You are in the main/public world.", player);
		} else {
			local world = GetWorldData(player.World);
			local plr = FindPlayer(text);
			if (!plr) {
				MessagePlayer("[#30cb68]** Unknown Player", player);
			} else if (world.Owner != player.Name) {
				MessagePlayer("[#30cb68]** This world is not owned by you", player);
			} else if (world.Shared == "None" || world.Shared != plr.Name) {
				MessagePlayer("[#30cb68]** You are not sharing this world with [#ffffff][ " + text + " ]", player);
			} else {
				QuerySQL(db, "UPDATE Worlds SET Shared = 'None' WHERE World = " + player.World + "");
				MessagePlayer("[#30cb68]** You are no longer sharing this world with: [#ffffff][ " + plr.Name + " ]", player);
				MessagePlayer("[#30cb68]** [#ffffff][ " + player.Name + " ] [#30cb68]is no longer sharing his world [#ffffff][" + world.ID + " : " + world.Name + "] [#30cb68]with you.", plr);
			}
		}
	}

	else if (cmd == "myworlds") {
		local query = QuerySQL(db, "SELECT * FROM Worlds WHERE Owner = '" + escapeSQLString(player.Name) + "'");
		local worldsOwned = 0;
		if (query) {
			do {
				worldsOwned++;
				MessagePlayer("[#30cb68]** World: [#ffffff][" + GetSQLColumnData(query, 0) + " : " + GetSQLColumnData(query, 1) + " ]", player);
			} while (GetSQLNextRow(query));
			MessagePlayer("[#30cb68]** -> Worlds Owned: [#ffffff][ " + worldsOwned + " ]", player);
		}
		if (worldsOwned == 0) {
			MessagePlayer("[#f51bbe]** There are no worlds owned by you", player);
		}
	}

	else if (cmd == "sharedworlds") {
		local query = QuerySQL(db, "SELECT * FROM Worlds WHERE Shared = '" + escapeSQLString(player.Name) + "'");
		local worldsShared = 0;
		if (query) {
			do {
				worldsShared++;
				MessagePlayer("[#30cb68]** World Shared: [#ffffff][" + GetSQLColumnData(query, 0) + " : " + GetSQLColumnData(query, 1) + " ] [#30cb68]by: [#ffffff][ " + GetSQLColumnData(query, 2) + " ]", player);
			} while (GetSQLNextRow(query));
			MessagePlayer("[#30cb68]** -> Worlds Shared: [#ffffff][ " + worldsShared + " ]", player);
		}
		if (worldsShared == 0) {
			MessagePlayer("[#f51bbe]** There are no worlds shared with you", player);
		}
	}

	else if (cmd == "world") {
		if (!text && player.World == 1) {
			MessagePlayer("[#30cb68]** You are in the main/public world.", player);
		} else if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<world ID>", player);
		} else if (text.tointeger() < 1 || text.tointeger() > 1000) {
			MessagePlayer("[#30cb68]** World ID should be between 1 to 1000.", player);
		} else {
			local query = QuerySQL(db, "SELECT * FROM Worlds WHERE World = " + text.tointeger());
			local WorldID = GetSQLColumnData(query, 0), WorldName = GetSQLColumnData(query, 1), Owner = GetSQLColumnData(query, 2), Shared = GetSQLColumnData(query, 3);
			MessagePlayer("[#30cb68]** World: [#ffffff][" + WorldID + " : " + WorldName + "] [#30cb68]owned by [#ffffff][ " + Owner + " ] [#30cb68]Shared With [#ffffff][ " + Shared + " ]", player);
		}
	}

	else if (cmd == "addobject") {
		local world = GetWorldData(player.World);
		if (player.World == 1) {
			MessagePlayer("[#30cb68]** You are in the main/public world.", player);
		} else if (!text) {
			MessagePlayer("[#30cb68]**/" + cmd + " [#ffffff]<object ID>", player);
		} else if (world.Owner != player.Name && world.Shared != player.Name) {
			MessagePlayer("[#30cb68]** You don't own this world.", player);
		}	else if (pData[player.ID].Editing) MessagePlayer("[#30cb68]** press backspace to save this object first.", player);
		 else if (text && text != "" && IsNum(text)) {
			Object[player.ID] = CreateObject(text.tointeger(), player.World, player.Pos.x, player.Pos.y, player.Pos.z, 255);
			Object[player.ID].TrackingShots = true;
			objCreated++;
			player.Pos = Vector(player.Pos.x, player.Pos.y, player.Pos.z + 3);
			pData[player.ID].Editing = true;
			Message("[#30cb68]** [#ffffff]Created object [#30cb68]" + text);
		}
	}

	else if (cmd == "objects") {
		local world = GetWorldData(player.World);
		local query2 = SQLite_Query(Maps, "SELECT model FROM Objects WHERE World = " + player.World);
		local objects = 0;

		if (!text && player.World == 1) {
			MessagePlayer("[#30cb68]** You are in the main/public world.", player);
		} else if (!query2 || !SQLite_NextRow(query2)) {
			return MessagePlayer("[#30cb68]** [#ffffff]No objects found for world " + player.World + ".", player);
		} else if (world.Owner != player.Name && world.Shared != player.Name) {
			MessagePlayer("[#30cb68]** You don't own this world.", player);
		} else {
			do {
				local model = GetSQLColumnData(query2, 0);
				MessagePlayer("[#30cb68]** Object Model: [#ffffff][ " + model + " ]", player);
				objects++;
			} while (SQLite_NextRow(query2));
			MessagePlayer("[#30cb68]** Total object(s) count: [#ffffff][ " + objects + " ]", player);
		}
	}

Server functions: ->
function onObjectShot( object, player, weapon )
{
	local world = GetWorldData(player.World);
	if (world.Owner == player.Name || world.Shared ==  player.Name) {
	local obj = FindObject( object.ID );
	local plr = FindPlayer( player.ID );
	Object[ plr.ID ] = obj;
	pData[ player.ID ].Editing = true;
	MessagePlayer( "[#159242][SELECT]: [#ffffff]Selected object " + object.ID, player );
}
	return 1;
}


function onObjectBump( object, player )
{
	local obj = FindObject( object.ID );
	local plr = FindPlayer( player.ID );
	obj.Delete();
	pData[ player.ID ].Editing = false;
	objCreated--;
	MessagePlayer( "[#159242][SELECT]: [#ffffff]Object deleted!", player );
}function onKeyDown( plr, key )
{
	local player;
	if( typeof plr != "instance" ) player = FindPlayer( plr );
	else player = plr;

	if( pData[ player.ID ].Motion == null && key != one && key != R && key != two && key != backspace && key != del ) pData[ player.ID ].Motion = NewTimer( "onKeyDown", Motion_Speed, 0, player.ID, key );

	if( key == ArrowLeft && !pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, 0.05 ), 100 );
			break;

			case "fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, 0.30 ), 100 );
			break;

			case "very fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, 1.30 ), 100 );
			break;

			case "very slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, 0.01 ), 100 );
			break;

			case "slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, 0.03 ), 100 );
			break;
		}
		return;
	}

	else if( key == ArrowRight && !pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, -0.05 ), 100 );
			break;

			case "fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, -0.30 ), 100 );
			break;

			case "very fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, -1.30 ), 100 );
			break;

			case "very slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, -0.01 ), 100 );
			break;

			case "slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0, -0.03 ), 100 );
			break;
		}
		return;
	}

	else if( key == PageUp && !pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].RotateByEuler( Vector( 0.05, 0, 0 ), 100 );
			break;

			case "fast":
			Object[ player.ID ].RotateByEuler( Vector( 0.30, 0, 0 ), 100 );
			break;

			case "very fast":
			Object[ player.ID ].RotateByEuler( Vector( 1.30, 0, 0 ), 100 );
			break;

			case "very slow":
			Object[ player.ID ].RotateByEuler( Vector( 0.01, 0, 0 ), 100 );
			break;

			case "slow":
			Object[ player.ID ].RotateByEuler( Vector( 0.03, 0, 0 ), 100 );
			break;
		}
		return;
	}

	else if( key == PageDown && !pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].RotateByEuler( Vector( -0.05, 0, 0 ), 100 );
			break;

			case "fast":
			Object[ player.ID ].RotateByEuler( Vector( -0.30, 0, 0 ), 100 );
			break;

			case "very fast":
			Object[ player.ID ].RotateByEuler( Vector( -1.30, 0, 0 ), 100 );
			break;

			case "very slow":
			Object[ player.ID ].RotateByEuler( Vector( -0.01, 0, 0 ), 100 );
			break;

			case "slow":
			Object[ player.ID ].RotateByEuler( Vector( -0.03, 0, 0 ), 100 );
			break;
		}
		return;
	}

	if( key == ArrowUp && !pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0.05, 0 ), 100 );
			break;

			case "fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0.30, 0 ), 100 );
			break;

			case "very fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, 1.30, 0 ), 100 );
			break;

			case "very slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0.01, 0 ), 100 );
			break;

			case "slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, 0.03, 0 ), 100 );
			break;
		}
		return;
	}

	else if( key == ArrowDown && !pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].RotateByEuler( Vector( 0, -0.05, 0 ), 100 );
			break;

			case "fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, -0.30, 0 ), 100 );
			break;

			case "very fast":
			Object[ player.ID ].RotateByEuler( Vector( 0, -1.30, 0 ), 100 );
			break;

			case "very slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, -0.01, 0 ), 100 );
			break;

			case "slow":
			Object[ player.ID ].RotateByEuler( Vector( 0, -0.03, 0 ), 100 );
			break;
		}
		return;
	}

	else if( key == PageUp && pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		local x = Object[ player.ID ].Pos.x;
		local y = Object[ player.ID ].Pos.y;
		local z = Object[ player.ID ].Pos.z;
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].Pos = Vector( x, y, z + 0.05 );
			break;

			case "fast":
			Object[ player.ID ].Pos = Vector( x, y, z + 0.30 );
			break;

			case "very fast":
			Object[ player.ID ].Pos = Vector( x, y, z + 1.30 );
			break;

			case "very slow":
			Object[ player.ID ].Pos = Vector( x, y, z + 0.01 );
			break;

			case "slow":
			Object[ player.ID ].Pos = Vector( x, y, z + 0.03 );
			break;
		}
		return;
	}


	else if( key == PageDown && pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		local x = Object[ player.ID ].Pos.x;
		local y = Object[ player.ID ].Pos.y;
		local z = Object[ player.ID ].Pos.z;
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].Pos = Vector( x, y, z - 0.05 );
			break;

			case "fast":
			Object[ player.ID ].Pos = Vector( x, y, z - 0.30 );
			break;

			case "very fast":
			Object[ player.ID ].Pos = Vector( x, y, z - 1.30 );
			break;

			case "very slow":
			Object[ player.ID ].Pos = Vector( x, y, z - 0.01 );
			break;

			case "slow":
			Object[ player.ID ].Pos = Vector( x, y, z - 0.03 );
			break;
		}
		return;
	}

	if( key == ArrowLeft && pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		local x = Object[ player.ID ].Pos.x;
		local y = Object[ player.ID ].Pos.y;
		local z = Object[ player.ID ].Pos.z;
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].Pos = Vector( x - 0.05, y, z );
			break;

			case "fast":
			Object[ player.ID ].Pos = Vector( x - 0.30, y, z );
			break;

			case "very fast":
			Object[ player.ID ].Pos = Vector( x - 1.30, y, z);
			break;

			case "very slow":
			Object[ player.ID ].Pos = Vector( x - 0.01, y, z );
			break;

			case "slow":
			Object[ player.ID ].Pos = Vector( x - 0.03, y, z );
			break;
		}
		return;
	}

	if( key == ArrowRight && pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		local x = Object[ player.ID ].Pos.x;
		local y = Object[ player.ID ].Pos.y;
		local z = Object[ player.ID ].Pos.z;
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].Pos = Vector( x + 0.05, y, z );
			break;

			case "fast":
			Object[ player.ID ].Pos = Vector( x + 0.30, y, z );
			break;

			case "very fast":
			Object[ player.ID ].Pos = Vector( x + 1.30, y, z);
			break;

			case "very slow":
			Object[ player.ID ].Pos = Vector( x + 0.01, y, z );
			break;

			case "slow":
			Object[ player.ID ].Pos = Vector( x + 0.03, y, z );
			break;
		}
		return;
	}

	else if( key == ArrowUp && pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		local x = Object[ player.ID ].Pos.x;
		local y = Object[ player.ID ].Pos.y;
		local z = Object[ player.ID ].Pos.z;
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].Pos = Vector( x, y + 0.05, z );
			break;

			case "fast":
			Object[ player.ID ].Pos = Vector( x, y + 0.30, z );
			break;

			case "very fast":
			Object[ player.ID ].Pos = Vector( x, y + 1.30, z);
			break;

			case "very slow":
			Object[ player.ID ].Pos = Vector( x, y + 0.01, z );
			break;

			case "slow":
			Object[ player.ID ].Pos = Vector( x, y + 0.03, z );
			break;
		}
		return;
	}

	else if( key == ArrowDown && pData[ player.ID ].PositionMode && Object[ player.ID ] != null )
	{
		local x = Object[ player.ID ].Pos.x;
		local y = Object[ player.ID ].Pos.y;
		local z = Object[ player.ID ].Pos.z;
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			Object[ player.ID ].Pos = Vector( x, y - 0.05, z );
			break;

			case "fast":
			Object[ player.ID ].Pos = Vector( x, y - 0.30, z );
			break;

			case "very fast":
			Object[ player.ID ].Pos = Vector( x, y - 1.30, z);
			break;

			case "very slow":
			Object[ player.ID ].Pos = Vector( x, y - 0.01, z );
			break;

			case "slow":
			Object[ player.ID ].Pos = Vector( x, y - 0.03, z );
			break;
		}
		return;
	}

	else if( key == one && Object[ player.ID ] != null )
	{
		if( !pData[ player.ID ].PositionMode )
		{
			pData[ player.ID ].PositionMode = true;
			MessagePlayer( "[#ffffff]Map positioning mode is [#00ff00]ON[#ffffff]! Rotation mode [#ff0000]OFF[#ffffff]!", player );
		}

		else if( pData[ player.ID ].PositionMode )
		{
			pData[ player.ID ].PositionMode = false;
			MessagePlayer( "[#ffffff]Map positioning mode is [#ff0000]OFF[#ffffff]! Rotation mode [#00ff00]ON[#ffffff]!", player );
		}
	}

	else if( key == two && Object[ player.ID ] != null )
	{
		switch( pData[ player.ID ].Speed )
		{
			case "normal":
			pData[ player.ID ].Speed = "fast";
			MessagePlayer( "[#ffffff]Speed movement level is now [#00ff00]Fast[#ffffff]!", player );
			break;

			case "fast":
			pData[ player.ID ].Speed = "very fast";
			MessagePlayer( "[#ffffff]Speed movement level is now [#00ff00]Very Fast[#ffffff]!", player );
			break;

			case "very fast":
			pData[ player.ID ].Speed = "very slow";
			MessagePlayer( "[#ffffff]Speed movement level is now [#00ff00]Very Slow[#ffffff]!", player );
			break;

			case "very slow":
			pData[ player.ID ].Speed = "slow";
			MessagePlayer( "[#ffffff]Speed movement level is now [#00ff00]Slow[#ffffff]!", player );
			break;

			case "slow":
			pData[ player.ID ].Speed = "normal";
			MessagePlayer( "[#ffffff]Speed movement level is now [#00ff00]Normal[#ffffff]!", player );
			break;
		}
	}

	else if( key == ctrl ) { pData[ player.ID ].CTRL = true; }

	else if( key == c && pData[ player.ID ].CTRL && Object[ player.ID ] != null )
	{
		local old_obj = Object[ player.ID ].Pos;
		local old_objid = Object[ player.ID ].Model;
		local old_objrot = Object[ player.ID ].RotationEuler;

		Object[ player.ID ] = CreateObject( old_objid, 0, old_obj, 255 );
		Object[ player.ID ].RotateToEuler( old_objrot, 0 );
		Object[ player.ID ].TrackingShots = true;
		objCreated++;
		pData[ player.ID ].Editing = true;
		Message( "[#159242][CLONE]: [#ffffff]Cloned object " + old_objid + " at its position" );
	}

	else if( key == del && Object[ player.ID ] != null )
	{
		if( typeof Object[ player.ID ] != "instance" ) FindObject( Object[ player.ID ] ).Delete();
		else Object[ player.ID ].Delete();
		pData[ player.ID ].Editing = false;
		objCreated--;
		MessagePlayer( "[#159242][SELECT]: [#ffffff]Object deleted!", player );
	}

	else if( key == R && Object[ player.ID ] != null )
	{
		Object[ player.ID ].RotateToEuler( Vector( 0, 0, 0 ), 0 );
		MessagePlayer( "[#ffffff]Rotation angles have been Reset!", player );
		return;
	}

	else if( key == backspace && pData[ player.ID ].Editing )
	{
		pData[ player.ID ].Editing = false;
		local obj = Object[player.ID];
		SQLite_Exec(Maps, "INSERT INTO Objects VALUES ( "+player.World+",'" + obj.Model + "', '" + obj.Pos.x + "', '" + obj.Pos.y + "', '" + obj.Pos.z + "', '" + obj.RotationEuler.x + "', '" + obj.RotationEuler.y + "', '" + obj.RotationEuler.z + "');");
		Object[ player.ID ] = null;
		MessagePlayer( "[#159242][EDIT]: [#ffffff]You have finished editing the object.", player );
	}
}
function onKeyUp( player, key )
{
	if( pData[ player.ID ].Motion != null )
	{
		pData[ player.ID ].Motion.Delete();
		pData[ player.ID ].Motion = null;
	}

	if( key == ctrl ) { pData[ player.ID ].CTRL = false; }
}
