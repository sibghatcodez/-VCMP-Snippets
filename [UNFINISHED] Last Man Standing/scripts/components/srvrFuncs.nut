
// function SendDataToClient(player, integer, string)
// {
//  Stream.StartWrite();
//  Stream.WriteInt(integer);
//  if (string != null) Stream.WriteString(string);
//  Stream.SendStream(player);
// }


function SendDataToClient( player, ... )
{
 if( vargv[0] )
 {
  local   byte = vargv[0], len = vargv.len();
  Stream.StartWrite();
  Stream.WriteByte( byte );
  if( 1 < len )
  {
   for( local i = 1; i < len; i++ )
   {
    switch( typeof( vargv[i] ) )
    {
     case "integer": Stream.WriteInt( vargv[i] ); break;
     case "string": Stream.WriteString( vargv[i] ); break;
     case "float": Stream.WriteFloat( vargv[i] ); break;
    }
   }
  }
  if( player == null ) Stream.SendStream( null );
  else if( typeof( player ) == "instance" ) Stream.SendStream( player );
  else return;
 } 
}

// OnTimeChange
 function onTimeChange(oldHour, oldMin, newHour, newMin) {
    for(local i = 0; i < GetMaxPlayers(); i++) {
        local plr = FindPlayer(i);
        if(plr && stats[plr.ID].Log) {
        stats[plr.ID].PlayTime++;
        UpdatePlayerAverageFPS(plr)
        UpdatePlayerAveragePing(plr)
    }
    }
 }




// PlayerKill and Death


function onPlayerKill( player, killer, reason, bodypart )
{
stats[player.ID].Kills += 1;
}

function onPlayerDeath( player, reason )
{
}