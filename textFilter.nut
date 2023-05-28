function filterText(text)
{
  local x = "fuck,fucked,fucker,dick,dickhead,mf,bitch,motherfucker,ass,asshole,pussy,smd,dog,nigga,Bastard";
  local txt = text;
  local abuses = split(x, ",");
  local words = split(txt, " ");
  local text = "";
  local hashed = "";
  local abuseFound = false;

  for (local i = 0; i < words.len(); i++) {
    hashed = "";
    for (local j = 0; j < abuses.len(); j++) {
      if(words[i] == abuses[j]) {
        abuseFound = true;
      }
    }

    if(abuseFound) {
      for (local k = 0; k <= words[i].len()-1; k++) {
          hashed += "*";
        }
        text += hashed+" ";
        abuseFound = false;
      } else text += words[i]+" ";
  }

  return text;
}


/////USE\\\\
function onPlayerChat(player,text) { //this is a built-in function in VC:MP
  		   local p = "[#" + format("%02X%02X%02X", player.Color.r, player.Color.g, player.Color.b) + "]";
         Message(p+""+player.Name+": [#ffffff]"+filterText(text));
}

///If player types, what the fuck. It will show it as 'what the ****'
