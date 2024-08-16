playeclass  >>>  lastPickupPickedUp = 0;


function onScriptLoad() >>>
 db <- ConnectSQL("Property.db");
 QuerySQL(db, "create table if not exists Property (ID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Owner TEXT, Shared TEXT, Price NUMERIC DEFAULT 0, Pos TEXT)");
 TOTAL_PROPERTIES <- 0;
 LoadProperties();

functions >>>>
function LoadProperties() {
  local query = QuerySQL(db, "SELECT * FROM Property");
  if(query) {
    do {
      local pos = GetSQLColumnData(query, 5);
      //pos = pos.slice(1, pos.len() - 1);
      local posArray = split(pos,",");
      local x = posArray[0].tofloat();
      local y = posArray[1].tofloat();
      local z = posArray[2].tofloat();

      TOTAL_PROPERTIES++;
      if (GetSQLColumnData(query, 2) == "None") CreatePickup(407, 1, 1, x, y, z, 255, true);
      else CreatePickup(406, 1, 1, x, y, z, 255, true);
    } while (GetSQLNextRow(query))
  }
  print("PROPERTIES: "+TOTAL_PROPERTIES);
}
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
function GetPlayer(target)
{
	target = "" + target;

	if (IsNum(target))
	{
		target = target.tointeger();

		if (FindPlayer(target)) return FindPlayer(target);
		else return null;
	}
	else if (FindPlayer(target)) return FindPlayer(target);
	else return null;
}
function PlayerToPoint( player, radi, x, y, z )
{
    local tempposx, tempposy, tempposz;
    tempposx = player.Pos.x -x;
    tempposy = player.Pos.y -y;
    tempposz = player.Pos.z -z;
    if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
    {
        return 1;
    }
    return 0;
}
function onPickupPickedUp( player, pickup )
{
  local pickupID = pickup.ID + 1; //doing this because PrimaryKey(ID) starts from 1 whereas PickupID's start from 0.
  local query = QuerySQL(db, "SELECT * FROM Property WHERE ID="+pickupID+"")
  local ID = GetSQLColumnData(query, 0), name = GetSQLColumnData(query, 1), owner = GetSQLColumnData(query, 2), shared = GetSQLColumnData(query, 3), price = GetSQLColumnData(query, 4);
  if (query) {
    if (owner == "None") MessagePlayer("[#f51bbe]Property: ID [#ffffff][ " + ID + " ] [#f51bbe]Name [#ffffff][ " + name + " ] [#f51bbe]Owner [#ffffff][ " + owner + " ] [#f51bbe]Price: [#ffffff]" + price + "$", player);
    else MessagePlayer("[#f51bbe]Property: ID [#ffffff][ " + ID + " ] [#f51bbe]Name [#ffffff][ " + name + " ] [#f51bbe]Owner [#ffffff][ " + owner + " ] [#f51bbe]Shared With [#ffffff][ " + shared + " ]", player);
  }
  stats[player.ID].lastPickupPickedUp = pickup.ID;
}


commands >>>>

   else if (cmd == "propcmds") {
    MessagePlayer("[#f51bbe](Property): [#ffffff]/addprop[#f51bbe], [#ffffff]/delprop[#f51bbe], [#ffffff]/buyprop[#f51bbe], [#ffffff]/sellprop[#f51bbe], [#ffffff]/shareprop[#f51bbe], [#ffffff]/delshareprop[#f51bbe], [#ffffff]/myprops[#f51bbe], [#ffffff]/sharedprops", player);
}

else if (cmd == "addprop") {
    if (!text) {
        MessagePlayer("[#f51bbe]/" + cmd + " [#ffffff]<name> <price>", player);
    } else {
        local name = GetTok(text, " ", 1);
        local price = GetTok(text, " ", 2);
        if (!IsNum(price)) {
            MessagePlayer("[#f51bbe]Price should be in integers", player);
        } else if (name == null || price == null) {
            MessagePlayer("[#f51bbe]Name/Price should not be null", player);
        } else {
            local pos = player.Pos.x + "," + player.Pos.y + "," + player.Pos.z;
            QuerySQL(db, "INSERT INTO Property(Name,Owner,Shared,Price, Pos) VALUES('" + name + "', 'None', 'None', " + price + ", '"+pos+"')");
            TOTAL_PROPERTIES++;
            MessagePlayer("[#f51bbe]" + player + " [#ffffff]have added property [#f51bbe][ " + TOTAL_PROPERTIES + " ] | Name: [#ffffff][ " + name + " ] [#f51bbe]| for [#ffffff][ " + price + " ]", player);
            CreatePickup(407, player.Pos);
        }
    }
}

   /*else if (cmd == "delprop") {
     local pickup = FindPickup(stats[player.ID].lastPickupPickedUp);
     if (pickup && !PlayerToPoint(player, 1, pickup.Pos.x.tofloat(), pickup.Pos.y.tofloat(), pickup.Pos.z.tofloat())) MessagePlayer( "You must be near to a property.", player );
     else {
       local pickupID = stats[player.ID].lastPickupPickedUp + 1;
       local query = QuerySQL(db, "SELECT * FROM Property WHERE ID = " + pickupID + "");
       local ID = GetSQLColumnData(query, 0), name = GetSQLColumnData(query, 1), owner = GetSQLColumnData(query, 2), shared = GetSQLColumnData(query, 3), price = GetSQLColumnData(query, 4);
      if(pickup && query) {
        MessagePlayer("You deleted property [ "+ID+" ] : [ "+name+" ]", player);
		    QuerySQL(db, "DELETE FROM Property WHERE Name = '" + name + "'");
        pickup.Remove();
        TOTAL_PROPERTIES--;
    } else MessagePlayer("[ "+text+" ] property does not exist.", player);
    }
   }*/
   else if (cmd == "buyprop") {
    local pickup = FindPickup(stats[player.ID].lastPickupPickedUp);
    if (pickup && !PlayerToPoint(player, 1, pickup.Pos.x.tofloat(), pickup.Pos.y.tofloat(), pickup.Pos.z.tofloat())) {
        MessagePlayer("[#f51bbe]You must be near to a property.", player);
    } else {
        local pickupID = stats[player.ID].lastPickupPickedUp + 1;
        local query = QuerySQL(db, "SELECT * FROM Property WHERE ID = " + pickupID + "");
        local ID = GetSQLColumnData(query, 0), name = GetSQLColumnData(query, 1), owner = GetSQLColumnData(query, 2), shared = GetSQLColumnData(query, 3), price = GetSQLColumnData(query, 4);
        if (owner != "None") {
            MessagePlayer("[#f51bbe]This property is already owned by [#ffffff][ " + owner + " ]", player);
        } else if (owner == player.Name) {
            MessagePlayer("[#f51bbe]Idiot! you already own this property", player);
        } else if (player.Cash < price) {
            MessagePlayer("[#f51bbe]You do not have sufficient amount to purchase this property.", player);
        } else {
            QuerySQL(db, "UPDATE Property SET Owner = '" + escapeSQLString(player.Name) + "' WHERE ID = "+pickupID+"");
            MessagePlayer("[#f51bbe](Property) Name [#ffffff][ " + name + " ] [#f51bbe]has been bought by [#ffffff][ " + player + " ] [#f51bbe]for [#ffffff]" + price + "$", player);
            player.Cash -= price;
        }
    }
}

else if (cmd == "sellprop") {
    local pickup = FindPickup(stats[player.ID].lastPickupPickedUp);
    if (pickup && !PlayerToPoint(player, 1, pickup.Pos.x.tofloat(), pickup.Pos.y.tofloat(), pickup.Pos.z.tofloat())) {
        MessagePlayer("[#f51bbe]You must be near to a property.", player);
    } else {
        local pickupID = stats[player.ID].lastPickupPickedUp + 1;
        local query = QuerySQL(db, "SELECT * FROM Property WHERE ID = " + pickupID + "");
        local ID = GetSQLColumnData(query, 0), name = GetSQLColumnData(query, 1), owner = GetSQLColumnData(query, 2), shared = GetSQLColumnData(query, 3), price = GetSQLColumnData(query, 4);
        if (owner != player.Name) {
            MessagePlayer("[#f51bbe]This property is not owned by you", player);
        } else {
            QuerySQL(db, "UPDATE Property SET Owner = 'None', Shared = 'None' WHERE ID = "+pickupID+"");
            MessagePlayer("[#f51bbe](Property) Name [#ffffff][ " + name + " ] [#f51bbe]has been sold by [#ffffff][ " + player + " ] [#f51bbe]for [#ffffff]" + price / 2 + "$", player);
            MessagePlayer("[#f51bbe]Property sold for half of its price $[#ffffff]" + price / 2, player);
            player.Cash += price / 2;
        }
    }
}

else if (cmd == "myprops") {
    local query = QuerySQL(db, "SELECT * FROM Property WHERE Owner = '" + escapeSQLString(player.Name) + "'");
    local propertiesOwned = 0;
    if (query) {
        do {
            propertiesOwned++;
            MessagePlayer("[#f51bbe]Property: [#ffffff][ " + GetSQLColumnData(query, 1) + " ]", player);
        } while (GetSQLNextRow(query))
        MessagePlayer("[#f51bbe]Properties Owned: [#ffffff][ " + propertiesOwned + " ]", player);
    }
    if (propertiesOwned == 0) {
        MessagePlayer("[#f51bbe]There are no properties owned by you", player);
    }
}

else if (cmd == "sharedprops") {
    local query = QuerySQL(db, "SELECT * FROM Property WHERE Shared = '" + escapeSQLString(player.Name) + "'");
    local propertiesShared = 0;
    if (query) {
        do {
            propertiesShared++;
            MessagePlayer("[#f51bbe]Property: [#ffffff][ " + GetSQLColumnData(query, 1) + " ] [#f51bbe]shared by [#ffffff][ " + GetSQLColumnData(query, 2) + " ]", player);
        } while (GetSQLNextRow(query))
        MessagePlayer("[#f51bbe]Properties Shared With You: [#ffffff][ " + propertiesShared + " ]", player);
    }
    if (propertiesShared == 0) {
        MessagePlayer("[#f51bbe]There are no properties shared with you", player);
    }
}

else if (cmd == "shareprop") {
    local pickup = FindPickup(stats[player.ID].lastPickupPickedUp);
    if (pickup && !PlayerToPoint(player, 1, pickup.Pos.x.tofloat(), pickup.Pos.y.tofloat(), pickup.Pos.z.tofloat())) {
        MessagePlayer("[#f51bbe]You must be near to a property.", player);
    } else if (!text) {
        MessagePlayer("[#f51bbe]/" + cmd + " [#ffffff]<player>", player);
    } else {
        local pickupID = stats[player.ID].lastPickupPickedUp + 1;
        local query = QuerySQL(db, "SELECT * FROM Property WHERE ID = " + pickupID + "");
        local plr = FindPlayer(text);
        local ID = GetSQLColumnData(query, 0), name = GetSQLColumnData(query, 1), owner = GetSQLColumnData(query, 2), shared = GetSQLColumnData(query, 3), price = GetSQLColumnData(query, 4);
        if (!plr) {
            MessagePlayer("[#f51bbe]Unknown Player", player);
        } else if (owner != player.Name) {
            MessagePlayer("[#f51bbe]This property is not owned by you", player);
        } else if (shared != "None") {
            MessagePlayer("[#f51bbe]You are already sharing this property with [#ffffff][ " + shared + " ]", player);
        } else if (text == player.Name) {
            MessagePlayer("[#f51bbe]Fool you can't share your property with yourself LOL", player);
        } else {
            QuerySQL(db, "UPDATE Property SET Shared = '" + escapeSQLString(plr.Name) + "' WHERE ID = " + pickupID + "");
            MessagePlayer("[#f51bbe]You are sharing this property with: [#ffffff][ " + plr.Name + " ]", player);
            MessagePlayer("[#f51bbe][ " + player.Name + " ] [#f51bbe]is sharing his property [#ffffff][ " + name + " ] [#f51bbe]with you.", plr);
        }
    }
}


    else if (cmd == "delshareprop") {
      local pickup = FindPickup(stats[player.ID].lastPickupPickedUp);
      if (pickup && !PlayerToPoint(player, 1, pickup.Pos.x.tofloat(), pickup.Pos.y.tofloat(), pickup.Pos.z.tofloat())) {
          MessagePlayer("[#f51bbe]You must be near to a property.", player);
      }
      else if (!text) {
          MessagePlayer("[#f51bbe]/" + cmd + " [#ffffff]<player>", player);
      }
      else {
          local pickupID = stats[player.ID].lastPickupPickedUp + 1;
          local query = QuerySQL(db, "SELECT * FROM Property WHERE ID = " + pickupID + "");
          local plr = FindPlayer(text);
          local ID = GetSQLColumnData(query, 0), name = GetSQLColumnData(query, 1), owner = GetSQLColumnData(query, 2), shared = GetSQLColumnData(query, 3), price = GetSQLColumnData(query, 4);

          if (owner != player.Name) {
              MessagePlayer("[#f51bbe]This property is not owned by you", player);
          }
          else if (shared == "None") {
              MessagePlayer("[#f51bbe]You are not sharing this property with anyone", player);
          }
          else if (shared != text) {
              MessagePlayer("[#f51bbe]You are not sharing this property with [#ffffff][ " + text + " ]", player);
          }
          else {
              if (plr) {
                  MessagePlayer("[#f51bbe]You are no longer sharing this property with: [#ffffff][ " + plr.Name + " ]", player);
                  MessagePlayer("[#ffffff][ " + player.Name + " ][#f51bbe] is no longer sharing his property [#ffffff][ " + name + " ][#f51bbe] with you.", plr);
              }
              if (!plr) {
                  MessagePlayer("[#f51bbe]You are no longer sharing this property with: [#ffffff][ " + text + " ]", player);
              }
              QuerySQL(db, "UPDATE Property SET Shared = 'None' WHERE ID = " + pickupID + "");
          }
      }
  }