# samp.raknet

> Library: `samp.raknet` — part of [SAMP.Lua](https://github.com/THE-FYP/SAMP.Lua)  
> Require: `local raknet = require 'samp.raknet'`  
> Purpose: Provides RPC and Packet ID constants for use with `samp.events` and SAMPFUNCS bitstream functions

---

## Installation

Place `samp/raknet.lua` inside `moonloader/lib/samp/`.  
Full package: [github.com/THE-FYP/SAMP.Lua/releases](https://github.com/THE-FYP/SAMP.Lua/releases)

> ⚠️ `samp.raknet` requires **SAMPFUNCS** to be loaded — it calls `require 'sampfuncs'` internally.

---

## Basic usage

```lua
local sampev = require 'samp.events'
local raknet = require 'samp.raknet'

-- Register a custom incoming RPC hook using a raknet.RPC constant
sampev.INTERFACE.INCOMING_RPCS[raknet.RPC.PLAYSOUND] = {
    'onPlaySound',
    {soundId = 'int32'},
    {coordinates = 'vector3d'}
}

function sampev.onPlaySound(sound, coords)
    print(string.format('Sound %d at %.2f, %.2f, %.2f', sound, coords.x, coords.y, coords.z))
    return false -- block the sound
end
```

---

## `raknet.RPC` — RPC ID constants

These constants map named RPCs to their numeric IDs. Used with `samp.events.INTERFACE` to register custom hooks, or with SAMPFUNCS functions like `raknetEmitRpc()`.

### Outgoing RPCs (player → server)

| Constant | Description |
|----------|-------------|
| `raknet.RPC.CLICKPLAYER` | Player clicks another player in scoreboard |
| `raknet.RPC.CLIENTJOIN` | Client join packet |
| `raknet.RPC.ENTERVEHICLE` | Player enters a vehicle |
| `raknet.RPC.SCRIPTCASH` | Script cash transfer |
| `raknet.RPC.SERVERCOMMAND` | Player sends a slash command |
| `raknet.RPC.SPAWN` | Player spawns |
| `raknet.RPC.DEATH` | Player death report |
| `raknet.RPC.NPCJOIN` | NPC join packet |
| `raknet.RPC.DIALOGRESPONSE` | Player responds to a dialog |
| `raknet.RPC.CLICKTEXTDRAW` | Player clicks a textdraw |
| `raknet.RPC.SCMEVENT` | SCM event |
| `raknet.RPC.WEAPONPICKUPDESTROY` | Weapon pickup destroyed |
| `raknet.RPC.CHAT` | Player sends chat message |
| `raknet.RPC.SRVNETSTATS` | Server network stats request |
| `raknet.RPC.CLIENTCHECK` | Client check response |
| `raknet.RPC.DAMAGEVEHICLE` | Vehicle damage report |
| `raknet.RPC.GIVETAKEDAMAGE` | Player gives/takes damage |
| `raknet.RPC.EDITATTACHEDOBJECT` | Edit attached object |
| `raknet.RPC.EDITOBJECT` | Edit object |
| `raknet.RPC.MAPMARKER` | Map marker placed |
| `raknet.RPC.REQUESTCLASS` | Request class selection |
| `raknet.RPC.REQUESTSPAWN` | Request spawn |
| `raknet.RPC.PICKEDUPPICKUP` | Player picks up a pickup |
| `raknet.RPC.MENUSELECT` | Player selects menu item |
| `raknet.RPC.VEHICLEDESTROYED` | Vehicle destroyed |
| `raknet.RPC.MENUQUIT` | Player closes menu |
| `raknet.RPC.EXITVEHICLE` | Player exits vehicle |
| `raknet.RPC.UPDATESCORESPINGSIPS` | Score/ping/IP update |
| `raknet.RPC.CAMTARGETUPDATE` | Camera target update (ID 168) |
| `raknet.RPC.GIVEACTORDAMAGE` | Give damage to actor (ID 177) |
| `raknet.RPC.SETINTERIORID` | Set interior ID |

### Incoming RPCs (server → player)

| Constant | Description |
|----------|-------------|
| `raknet.RPC.SETPLAYERNAME` | Set player name |
| `raknet.RPC.SETPLAYERPOS` | Teleport player |
| `raknet.RPC.SETPLAYERPOSFINDZ` | Set player pos with Z find |
| `raknet.RPC.SETPLAYERHEALTH` | Set player health |
| `raknet.RPC.TOGGLEPLAYERCONTROLLABLE` | Toggle player controllable |
| `raknet.RPC.PLAYSOUND` | Play a sound |
| `raknet.RPC.SETPLAYERWORLDBOUNDS` | Set world bounds |
| `raknet.RPC.GIVEPLAYERMONEY` | Give money to player |
| `raknet.RPC.SETPLAYERFACINGANGLE` | Set facing angle |
| `raknet.RPC.RESETPLAYERMONEY` | Reset player money |
| `raknet.RPC.RESETPLAYERWEAPONS` | Reset player weapons |
| `raknet.RPC.GIVEPLAYERWEAPON` | Give weapon to player |
| `raknet.RPC.SETVEHICLEPARAMSEX` | Set vehicle params extended |
| `raknet.RPC.CANCELEDIT` | Cancel object edit |
| `raknet.RPC.SETPLAYERTIME` | Set player time |
| `raknet.RPC.TOGGLECLOCK` | Toggle clock display |
| `raknet.RPC.WORLDPLAYERADD` | Player added to world |
| `raknet.RPC.SETPLAYERSHOPNAME` | Set shop name |
| `raknet.RPC.SETPLAYERSKILLLEVEL` | Set weapon skill level |
| `raknet.RPC.SETPLAYERDRUNKLEVEL` | Set drunk level |
| `raknet.RPC.CREATE3DTEXTLABEL` | Create 3D text label |
| `raknet.RPC.DISABLECHECKPOINT` | Disable checkpoint |
| `raknet.RPC.SETRACECHECKPOINT` | Set race checkpoint |
| `raknet.RPC.DISABLERACECHECKPOINT` | Disable race checkpoint |
| `raknet.RPC.GAMEMODERESTART` | Gamemode restart |
| `raknet.RPC.PLAYAUDIOSTREAM` | Play audio stream |
| `raknet.RPC.STOPAUDIOSTREAM` | Stop audio stream |
| `raknet.RPC.REMOVEBUILDINGFORPLAYER` | Remove map building |
| `raknet.RPC.CREATEOBJECT` | Create object |
| `raknet.RPC.SETOBJECTPOS` | Set object position |
| `raknet.RPC.SETOBJECTROT` | Set object rotation |
| `raknet.RPC.DESTROYOBJECT` | Destroy object |
| `raknet.RPC.DEATHMESSAGE` | Death message in killfeed |
| `raknet.RPC.SETPLAYERMAPICON` | Set map icon |
| `raknet.RPC.REMOVEVEHICLECOMPONENT` | Remove vehicle component |
| `raknet.RPC.CHATBUBBLE` | Chat bubble above player |
| `raknet.RPC.SHOWDIALOG` | Show dialog to player |
| `raknet.RPC.DESTROYPICKUP` | Destroy pickup |
| `raknet.RPC.LINKVEHICLETOINTERIOR` | Link vehicle to interior |
| `raknet.RPC.SETPLAYERARMOUR` | Set player armour |
| `raknet.RPC.SETPLAYERARMEDWEAPON` | Set armed weapon |
| `raknet.RPC.SETSPAWNINFO` | Set spawn info |
| `raknet.RPC.SETPLAYERTEAM` | Set player team |
| `raknet.RPC.PUTPLAYERINVEHICLE` | Put player in vehicle |
| `raknet.RPC.REMOVEPLAYERFROMVEHICLE` | Remove player from vehicle |
| `raknet.RPC.SETPLAYERCOLOR` | Set player color |
| `raknet.RPC.DISPLAYGAMETEXT` | Display game text (GTAtext) |
| `raknet.RPC.FORCECLASSSELECTION` | Force class selection |
| `raknet.RPC.ATTACHOBJECTTOPLAYER` | Attach object to player |
| `raknet.RPC.INITMENU` | Initialize menu |
| `raknet.RPC.SHOWMENU` | Show menu |
| `raknet.RPC.HIDEMENU` | Hide menu |
| `raknet.RPC.CREATEEXPLOSION` | Create explosion |
| `raknet.RPC.SHOWPLAYERNAMETAGFORPLAYER` | Show nametag |
| `raknet.RPC.ATTACHCAMERATOOBJECT` | Attach camera to object |
| `raknet.RPC.INTERPOLATECAMERA` | Interpolate camera |
| `raknet.RPC.SETOBJECTMATERIAL` | Set object material |
| `raknet.RPC.APPLYANIMATION` | Apply animation to player |
| `raknet.RPC.CLEARANIMATIONS` | Clear player animations |
| `raknet.RPC.SETPLAYERSPECIALACTION` | Set special action |
| `raknet.RPC.SETPLAYERFIGHTINGSTYLE` | Set fighting style |
| `raknet.RPC.SETPLAYERVELOCITY` | Set player velocity |
| `raknet.RPC.SETVEHICLEVELOCITY` | Set vehicle velocity |
| `raknet.RPC.CLIENTMESSAGE` | Server message to chat |
| `raknet.RPC.SETWORLDTIME` | Set world time |
| `raknet.RPC.CREATEPICKUP` | Create pickup |
| `raknet.RPC.MOVEOBJECT` | Move object |
| `raknet.RPC.SETCHECKPOINT` | Set checkpoint |
| `raknet.RPC.GANGZONECREATE` | Create gang zone |
| `raknet.RPC.GANGZONEDESTROY` | Destroy gang zone |
| `raknet.RPC.GANGZONEFLASH` | Flash gang zone |
| `raknet.RPC.GANGZONESTOPFLASH` | Stop flashing gang zone |
| `raknet.RPC.TOGGLEPLAYERSPECTATING` | Toggle spectate mode |
| `raknet.RPC.PLAYERSPECTATEPLAYER` | Spectate another player |
| `raknet.RPC.PLAYERSPECTATEVEHICLE` | Spectate a vehicle |
| `raknet.RPC.SETPLAYERWANTEDLEVEL` | Set wanted level |
| `raknet.RPC.SHOWTEXTDRAW` | Show textdraw |
| `raknet.RPC.TEXTDRAWHIDEFORPLAYER` | Hide textdraw |
| `raknet.RPC.TEXTDRAWSETSTRING` | Update textdraw string |
| `raknet.RPC.SERVERJOIN` | Server join notification |
| `raknet.RPC.SERVERQUIT` | Server quit notification |
| `raknet.RPC.INITGAME` | Game initialization |
| `raknet.RPC.SETPLAYERAMMO` | Set weapon ammo |
| `raknet.RPC.SETGRAVITY` | Set world gravity |
| `raknet.RPC.SETVEHICLEHEALTH` | Set vehicle health |
| `raknet.RPC.ATTACHTRAILERTOVEHICLE` | Attach trailer |
| `raknet.RPC.DETACHTRAILERFROMVEHICLE` | Detach trailer |
| `raknet.RPC.SETWEATHER` | Set weather |
| `raknet.RPC.SETPLAYERSKIN` | Set player skin |
| `raknet.RPC.SETPLAYERINTERIOR` | Set player interior |
| `raknet.RPC.SETPLAYERCAMERAPOS` | Set camera position |
| `raknet.RPC.SETPLAYERCAMERALOOKAT` | Set camera look-at |
| `raknet.RPC.SETVEHICLEPOS` | Set vehicle position |
| `raknet.RPC.SETVEHICLEZANGLE` | Set vehicle Z angle |
| `raknet.RPC.SETVEHICLEPARAMSFORPLAYER` | Set vehicle params for player |
| `raknet.RPC.SETCAMERABEHINDPLAYER` | Reset camera behind player |
| `raknet.RPC.WORLDPLAYERREMOVE` | Player removed from world |
| `raknet.RPC.WORLDVEHICLEADD` | Vehicle added to world |
| `raknet.RPC.WORLDVEHICLEREMOVE` | Vehicle removed from world |
| `raknet.RPC.WORLDPLAYERDEATH` | Player death in world |
| `raknet.RPC.CREATEACTOR` | Create actor (ID 171) |
| `raknet.RPC.DESTROYACTOR` | Destroy actor (ID 172) |
| `raknet.RPC.DESTROY3DTEXTLABEL` | Destroy 3D text label (ID 58) |
| `raknet.RPC.SELECTOBJECT` | Select object (ID 27) |
| `raknet.RPC.DISABLEVEHICLECOLLISIONS` | Disable vehicle collisions (ID 167) |
| `raknet.RPC.TOGGLEWIDESCREEN` | Toggle widescreen (ID 111) |
| `raknet.RPC.SETVEHICLETIRES` | Set vehicle tires (ID 98) |
| `raknet.RPC.SETPLAYERDRUNKVISUALS` | Set drunk visuals (ID 92) |
| `raknet.RPC.SETPLAYERDRUNKHANDLING` | Set drunk handling (ID 150) |
| `raknet.RPC.APPLYACTORANIMATION` | Apply actor animation (ID 173) |
| `raknet.RPC.CLEARACTORANIMATION` | Clear actor animation (ID 174) |
| `raknet.RPC.SETACTORROTATION` | Set actor rotation (ID 175) |
| `raknet.RPC.SETACTORPOSITION` | Set actor position (ID 176) |
| `raknet.RPC.SETACTORHEALTH` | Set actor health (ID 178) |
| `raknet.RPC.TOGGLECAMERATARGET` | Toggle camera target (ID 170) |
| `raknet.RPC.CONNECTIONREJECTED` | Connection rejected (ID 130) |

---

## `raknet.PACKET` — Packet ID constants

Used with SAMPFUNCS bitstream packet functions.

| Constant | Description |
|----------|-------------|
| `raknet.PACKET.VEHICLE_SYNC` | Vehicle sync packet |
| `raknet.PACKET.RCON_COMMAND` | RCON command |
| `raknet.PACKET.RCON_RESPONCE` | RCON response |
| `raknet.PACKET.AIM_SYNC` | Aim sync packet |
| `raknet.PACKET.WEAPONS_UPDATE` | Weapons update |
| `raknet.PACKET.STATS_UPDATE` | Stats update |
| `raknet.PACKET.BULLET_SYNC` | Bullet sync |
| `raknet.PACKET.PLAYER_SYNC` | Player sync |
| `raknet.PACKET.MARKERS_SYNC` | Markers sync |
| `raknet.PACKET.UNOCCUPIED_SYNC` | Unoccupied vehicle sync |
| `raknet.PACKET.TRAILER_SYNC` | Trailer sync |
| `raknet.PACKET.PASSENGER_SYNC` | Passenger sync |
| `raknet.PACKET.SPECTATOR_SYNC` | Spectator sync |
| `raknet.PACKET.RPC` | Generic RPC packet |
| `raknet.PACKET.RPC_REPLY` | RPC reply packet |
| `raknet.PACKET.CONNECTION_REQUEST` | Connection request |
| `raknet.PACKET.CONNECTION_REQUEST_ACCEPTED` | Connection accepted |
| `raknet.PACKET.DISCONNECTION_NOTIFICATION` | Disconnection |
| `raknet.PACKET.CONNECTION_LOST` | Connection lost |
| `raknet.PACKET.NEW_INCOMING_CONNECTION` | New incoming connection |
| `raknet.PACKET.PING` | Ping packet |
| `raknet.PACKET.CONNECTED_PONG` | Pong response |
| `raknet.PACKET.AUTH_KEY` | Auth key |

---

## Registering custom RPC hooks

`samp.raknet` is used together with `samp.events` to hook RPCs that are not natively supported out of the box:

```lua
local sampev = require 'samp.events'
local raknet = require 'samp.raknet'

-- Hook an incoming RPC manually using its constant
sampev.INTERFACE.INCOMING_RPCS[raknet.RPC.CREATEEXPLOSION] = {
    'onCreateExplosion',
    {x = 'float'},
    {y = 'float'},
    {z = 'float'},
    {type = 'int32'},
    {radius = 'float'}
}

function sampev.onCreateExplosion(x, y, z, expType, radius)
    print(string.format('Explosion at %.1f %.1f %.1f type=%d', x, y, z, expType))
    return false -- block
end
```

---

## Notes

- `raknet.RPC` constants map to SAMPFUNCS global variables (e.g. `RPC_CHAT`, `RPC_SCRSHOWDIALOG`)
- `raknet.PACKET` constants map to SAMPFUNCS packet globals (e.g. `PACKET_PLAYER_SYNC`)
- Some IDs (actors, newer RPCs) are hardcoded numeric values — not SAMPFUNCS globals
- Constants marked as "Invalid — retained for backward compatibility" should not be used in new scripts

---

## Common mistakes

| Mistake | Correct approach |
|---------|-----------------|
| Using raw numeric RPC IDs | Use `raknet.RPC.CONSTANT_NAME` for readability |
| Forgetting `require 'samp.raknet'` | Always require it when registering custom hooks |
| Using `raknet` without SAMPFUNCS loaded | SAMPFUNCS must be installed — raknet depends on it |

---

## Source & credits

This documentation is based on the official source code of **SAMP.Lua by THE-FYP / BlastHack Team**:

- Full RPC/Packet constant list: [github.com/THE-FYP/SAMP.Lua/blob/master/samp/raknet.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/raknet.lua)
- Custom hook example: [github.com/THE-FYP/SAMP.Lua/blob/master/README.md](https://github.com/THE-FYP/SAMP.Lua/blob/master/README.md)

> For the complete and authoritative constant list, always read `raknet.lua` directly from the source.

---

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
