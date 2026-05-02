# sampfuncs

> Library: `SAMPFUNCS` — native ASI plugin, functions available globally in MoonLoader  
> Require: **not needed** — functions are global once SAMPFUNCS.asi is loaded  
> Purpose: Low-level SA-MP network access — sending RPCs, reading/writing bitstreams

---

## Installation

Place `SAMPFUNCS.asi` inside your GTA San Andreas root folder (same folder as `gta_sa.exe`).  
Download: [blast.hk/attachments/22939](https://www.blast.hk/attachments/22939/)

**Required by:** `samp.raknet`, any script that uses `raknetEmitRpc` or bitstream functions.

---

## Bitstream functions

A bitstream is a binary buffer used to build RPC payloads before sending them to the server.  
Always follow this pattern: **create → write → emit → delete**

### `raknetNewBitStream()`
Creates a new empty bitstream.
```lua
local bs = raknetNewBitStream()
```
**Returns:** bitstream handle (number)

---

### `raknetDeleteBitStream(bs)`
Frees the bitstream from memory. Always call this after emitting.
```lua
raknetDeleteBitStream(bs)
```
| Parameter | Type   | Description       |
|-----------|--------|-------------------|
| bs        | number | Bitstream handle  |

---

### `raknetResetBitStream(bs)`
Resets the bitstream to empty without deleting it.
```lua
raknetResetBitStream(bs)
```

---

## Write functions

### `raknetBitStreamWriteBool(bs, value)`
Writes a boolean (1 bit).
```lua
raknetBitStreamWriteBool(bs, true)
raknetBitStreamWriteBool(bs, false)
```

---

### `raknetBitStreamWriteInt8(bs, value)`
Writes a signed 8-bit integer.
```lua
raknetBitStreamWriteInt8(bs, 127)
```

---

### `raknetBitStreamWriteInt16(bs, value)`
Writes a signed 16-bit integer.
```lua
raknetBitStreamWriteInt16(bs, 1000)
```

---

### `raknetBitStreamWriteInt32(bs, value)`
Writes a signed 32-bit integer.
```lua
raknetBitStreamWriteInt32(bs, -1)
```

---

### `raknetBitStreamWriteFloat(bs, value)`
Writes a 32-bit float.
```lua
raknetBitStreamWriteFloat(bs, 4.0)
```

---

### `raknetBitStreamWriteString(bs, value)`
Writes a length-prefixed string (8-bit length prefix).
```lua
raknetBitStreamWriteString(bs, "PED")
```
> ⚠️ Use this for `string8` fields (animLib, animName, etc.)

---

### `raknetBitStreamWriteBuffer(bs, data, size)`
Writes raw bytes into the bitstream.
```lua
raknetBitStreamWriteBuffer(bs, data, #data)
```

---

## Read functions

### `raknetBitStreamReadBool(bs)`
```lua
local value = raknetBitStreamReadBool(bs)
```

### `raknetBitStreamReadInt8(bs)`
```lua
local value = raknetBitStreamReadInt8(bs)
```

### `raknetBitStreamReadInt16(bs)`
```lua
local value = raknetBitStreamReadInt16(bs)
```

### `raknetBitStreamReadInt32(bs)`
```lua
local value = raknetBitStreamReadInt32(bs)
```

### `raknetBitStreamReadFloat(bs)`
```lua
local value = raknetBitStreamReadFloat(bs)
```

### `raknetBitStreamReadString(bs, length)`
```lua
local value = raknetBitStreamReadString(bs, 64)
```

---

## RPC functions

### `raknetEmitRpc(rpcId, bitstream)`
Sends an RPC packet to the server. This is the correct way to send outgoing RPCs in MoonLoader.
```lua
local bs = raknetNewBitStream()
-- write fields here
raknetEmitRpc(86, bs)
raknetDeleteBitStream(bs)
```
| Parameter | Type   | Description                        |
|-----------|--------|------------------------------------|
| rpcId     | number | RPC ID (see rpc/rpc_ids.md)        |
| bitstream | number | Bitstream handle with the payload  |

> ✅ This is the correct function — NOT `sampSendRPC`, NOT `emitOutcomingRpc`

---

### `raknetSendPacket(packetId, bitstream)`
Sends a raw packet to the server (used for player sync, etc).
```lua
raknetSendPacket(207, bs)
```

---

## Real examples

### Send APPLYANIMATION RPC (ID 86)
Makes the local player play an animation visible to all players on the server.
```lua
local function sendApplyAnimRPC(animLib, animName)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteString(bs, animLib)    -- string8: anim library
    raknetBitStreamWriteString(bs, animName)   -- string8: anim clip name
    raknetBitStreamWriteFloat(bs, 4.0)         -- float:   frame delta (speed)
    raknetBitStreamWriteBool(bs, false)        -- bool:    loop
    raknetBitStreamWriteBool(bs, false)        -- bool:    lockX
    raknetBitStreamWriteBool(bs, false)        -- bool:    lockY
    raknetBitStreamWriteBool(bs, true)         -- bool:    freeze
    raknetBitStreamWriteInt32(bs, -1)          -- int32:   time (-1 = natural)
    raknetEmitRpc(86, bs)
    raknetDeleteBitStream(bs)
end
```

---

### Send CLEARANIMATIONS RPC (ID 163)
Stops the current animation on all remote clients.
```lua
local function sendClearAnimRPC()
    local bs = raknetNewBitStream()
    raknetEmitRpc(163, bs)
    raknetDeleteBitStream(bs)
end
```

---

### Send chat message via RPC (ID 101)
Sends a chat message directly through RPC instead of the normal chat input.
```lua
local function sendChatRPC(message)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteString(bs, message)
    raknetEmitRpc(101, bs)
    raknetDeleteBitStream(bs)
end
```

---

## Common mistakes

| Mistake | Correct |
|---------|---------|
| `sampev.emitOutcomingRpc(86, {...})` | `raknetEmitRpc(86, bs)` |
| `sampSendRPC(86, bs)` | `raknetEmitRpc(86, bs)` |
| Not calling `raknetDeleteBitStream` | Always delete after emit |
| Writing fields in wrong order | Match exact field order from rpc_ids.md |
| `require 'sampfuncs'` | Not needed — functions are global |

---

## Notes

- SAMPFUNCS functions are globally available — no `require` needed
- Always delete the bitstream after use to avoid memory leaks
- Field write order must exactly match the RPC definition (see `rpc/rpc_ids.md`)
- `raknetEmitRpc` sends to the **server** — the server then replicates to other clients
- Works on SA-MP 0.3.7-R1 through R5

---

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
