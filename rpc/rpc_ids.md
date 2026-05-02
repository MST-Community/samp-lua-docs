# SA-MP RPC IDs Reference

> **This file is a summary for AI-assisted scripting. For the complete and authoritative RPC list, always refer to the official sources below.**

---

## Official sources (read these first)

| Source | Description | URL |
|--------|-------------|-----|
| **samp-packet-list** (Brunoo16 / NexiusTailer) | Most complete SA-MP RPC + packet wiki, community maintained | [github.com/Brunoo16/samp-packet-list/wiki/RPC-List](https://github.com/Brunoo16/samp-packet-list/wiki/RPC-List) |
| **SAMP.Lua — samp/raknet.lua** (THE-FYP) | RPC constants used in MoonLoader scripts | [github.com/THE-FYP/SAMP.Lua/blob/master/samp/raknet.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/raknet.lua) |
| **SAMP.Lua — samp/events.lua** (THE-FYP) | Full incoming/outgoing RPC field layouts | [github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua) |
| **YSF — RPCs.h** (IllidanS4) | Server-side RPC IDs reference | [github.com/IllidanS4/YSF/blob/master/src/RPCs.h](https://github.com/IllidanS4/YSF/blob/master/src/RPCs.h) |
| **RakSAMP — SAMPRPC.cpp** (BlastHack) | Old but extensive RPC list | [gitlab.com/blasthack/raksamp](https://gitlab.com/blasthack/raksamp/blob/master/raknet/SAMP/SAMPRPC.cpp) |

---

## How to use RPC IDs in MoonLoader

```lua
-- Always: create → write fields in order → emit → delete
local bs = raknetNewBitStream()
raknetBitStreamWriteString(bs, "PED")
raknetBitStreamWriteString(bs, "IDLE_CHAT")
-- ... more fields in exact order
raknetEmitRpc(86, bs)
raknetDeleteBitStream(bs)
```

Field type → write function mapping:

| Type     | Write function                  |
|----------|---------------------------------|
| bool     | `raknetBitStreamWriteBool`      |
| uint8    | `raknetBitStreamWriteInt8`      |
| uint16   | `raknetBitStreamWriteInt16`     |
| int32    | `raknetBitStreamWriteInt32`     |
| float    | `raknetBitStreamWriteFloat`     |
| string8  | `raknetBitStreamWriteString`    |
| vector3d | `raknetBitStreamWriteFloat` × 3 |

---

## Most used RPCs for Lua scripting

> IDs and field layouts taken from [samp/events.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua) and [Brunoo16/samp-packet-list](https://github.com/Brunoo16/samp-packet-list/wiki/RPC-List).

### Outgoing (client → server)

#### RPC 86 — `APPLYANIMATION` ⭐
Play an animation visible to all players.
```
string8   animLib      -- e.g. "PED"
string8   animName     -- e.g. "IDLE_CHAT"
float     frameDelta   -- speed, usually 4.0
bool      loop
bool      lockX
bool      lockY
bool      freeze
int32     time         -- ms, -1 = natural length
```
```lua
local bs = raknetNewBitStream()
raknetBitStreamWriteString(bs, "PED")
raknetBitStreamWriteString(bs, "IDLE_CHAT")
raknetBitStreamWriteFloat(bs, 4.0)
raknetBitStreamWriteBool(bs, false)
raknetBitStreamWriteBool(bs, false)
raknetBitStreamWriteBool(bs, false)
raknetBitStreamWriteBool(bs, true)
raknetBitStreamWriteInt32(bs, -1)
raknetEmitRpc(86, bs)
raknetDeleteBitStream(bs)
```

---

#### RPC 163 — `CLEARANIMATIONS`
Stop the current animation.
```
(no fields)
```
```lua
local bs = raknetNewBitStream()
raknetEmitRpc(163, bs)
raknetDeleteBitStream(bs)
```

---

#### RPC 101 — `CHAT`
Send a chat message.
```
string8   message
```
```lua
local bs = raknetNewBitStream()
raknetBitStreamWriteString(bs, "Hello!")
raknetEmitRpc(101, bs)
raknetDeleteBitStream(bs)
```

---

#### RPC 50 — `SERVERCOMMAND`
Send a slash command.
```
string8   command    -- include the slash: "/cmd arg"
```

---

#### RPC 52 — `SPAWN`
Request spawn after class selection.
```
(no fields)
```

---

#### RPC 53 — `DEATH`
Notify server of player death.
```
uint8    killerWeapon
uint16   killerId      -- 65535 = no killer
```

---

#### RPC 60 — `DIALOGRESPONSE`
Respond to a dialog.
```
uint16   dialogId
uint8    buttonId      -- 0 = left, 1 = right
uint16   listboxId
string8  input
```

---

#### RPC 84 — `ENTERVEHICLE`
Request to enter a vehicle.
```
uint16   vehicleId
bool8    isPassenger
```

---

#### RPC 85 — `EXITVEHICLE`
Request to exit a vehicle.
```
uint16   vehicleId
```

---

### Incoming (server → client)
> Hook these via `samp.events` — see [libs/samp.events.md](../libs/samp.events.md)

| RPC ID | Event name in samp.events | Description |
|--------|---------------------------|-------------|
| 86 | `onApplyPlayerAnimation` | Server applies animation to a player |
| 93 | `onServerMessage` | Colored chat message from server |
| 61 | `onShowDialog` | Dialog box shown to player |
| 103 | `onSetPlayerHealth` | Server sets player health |
| 116 | `onSetPlayerArmour` | Server sets player armour |
| 12 | `onSetPlayerPos` | Server teleports player |
| 163 | `onClearPlayerAnimation` | Server clears player animation |

> For the full list of all incoming RPCs and their exact field layouts, see the official source:
> [github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua)

---

## Common animation libraries

> GTA SA native animation libs — verified in-game.

| AnimLib | AnimName | Description |
|---------|----------|-------------|
| `PED` | `IDLE_CHAT` | Casual standing chat |
| `GANGS` | `PRTIAL_GNGTLKM` | Gang talk male |
| `GANGS` | `PRTIAL_GNGTLKF` | Gang talk female |
| `PHONE` | `PHONE_TALK` | Phone conversation |
| `PHONE` | `PHONE_IN` | Answer phone |
| `PHONE` | `PHONE_OUT` | Hang up |
| `SMOKING` | `M_smklean_loop` | Smoking lean |
| `COP_AMBIENT` | `Coplook_loop` | Officer look around |
| `DANCING` | `dance_loop` | Dance loop |

---

## Notes

- Field order is **strict** — wrong order = server ignores or kicks
- Always call `raknetDeleteBitStream` after every `raknetEmitRpc`
- This file only covers the most common RPCs for Lua scripting
- **For the full RPC list** visit: [github.com/Brunoo16/samp-packet-list/wiki/RPC-List](https://github.com/Brunoo16/samp-packet-list/wiki/RPC-List)
- **For RPC constants by name** (e.g. `raknet.RPC.APPLYANIMATION`): [samp/raknet.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/raknet.lua)

---

## Credits

- **Brunoo16 / NexiusTailer** — samp-packet-list wiki
- **THE-FYP / MISTER_GONWIK / BlastHack Team** — SAMP.Lua / samp.raknet
- **IllidanS4** — YSF RPCs.h

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
