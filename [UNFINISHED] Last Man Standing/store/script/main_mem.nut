function Script::ScriptLoad()
{
sX <- GUI.GetScreenSize().X;
sY <- GUI.GetScreenSize().Y;
}


 
function Server::ServerData( stream )
{
 local byte = stream.ReadByte();
 switch (byte)
 {
  case 0x01:
  break;
  default: break;
 }
}
