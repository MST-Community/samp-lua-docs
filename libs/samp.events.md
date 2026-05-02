# samp.events

> Library: `samp.events` — part of [SAMP.Lua](https://github.com/THE-FYP/SAMP.Lua)  
> Require: `local sampev = require 'samp.events'`  
> Purpose: Hook into SA-MP network events (incoming and outgoing packets/RPCs)

---

## Installation

Place `samp/events.lua` inside `moonloader/lib/samp/`.  
Full package: [github.com/THE-FYP/SAMP.Lua/releases](https://github.com/THE-FYP/SAMP.Lua/releases)

---

## Basic usage

```lua
local sampev = require 'samp.events'

-- Hook an event by defining a function with the event name
function sampev.onServerMessage(color, text)
    print("Server says: " .. text)
    -- return false to block the message from appearing in chat
end
```

**Return values:**
- `return false` — cancels/blocks the event (suppresses it)
- `return true` or no return — allows the event to pass through normally
- Returning modified values — overrides the original data

---

## Outgoing events (player → server)

These fire when the local player sends data to the server.

### `onSendChat(message)`
Fires when the player sends a chat message.
```lua
function sampev.onSendChat(message)
    print("Player sent: " .. message)
    -- return false to block the message
    -- return {"replaced text"} to change it (positional table, NOT {message = "..."})
end
```
| Parameter | Type   | Description          |
|-----------|--------|----------------------|
| message   | string | The chat message text |

---

### `onSendCommand(command)`
Fires when the player sends a slash command (e.g. `/help`).
```lua
function sampev.onSendCommand(command)
    if command == "/mycommand" then
        -- handle locally
        return false -- block from reaching server
    end
end
```
| Parameter | Type   | Description                  |
|-----------|--------|------------------------------|
| command   | string | Full command string with `/` (string32) |

---

### `onSendSpawn()`
Fires when the player clicks "Spawn" on the class selection screen.
```lua
function sampev.onSendSpawn()
    print("Player is spawning")
end
```

---

### `onSendEnterVehicle(vehicleId, passenger)`
Fires when the player attempts to enter a vehicle.
```lua
function sampev.onSendEnterVehicle(vehicleId, passenger)
    print("Entering vehicle: " .. vehicleId)
end
```
| Parameter   | Type    | Description                        |
|-------------|---------|------------------------------------|
| vehicleId   | number  | Vehicle ID (uint16)                |
| passenger   | boolean | true if entering as passenger (bool8) |

---

### `onSendExitVehicle(vehicleId)`
Fires when the player exits a vehicle.
```lua
function sampev.onSendExitVehicle(vehicleId)
    print("Exiting vehicle: " .. vehicleId)
end
```

---

### `onSendDialogResponse(dialogId, button, listboxId, input)`
Fires when the player responds to a dialog box.
```lua
function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
    print(string.format("Dialog %d: button=%d input=%s", dialogId, button, input))
end
```
| Parameter  | Type   | Description                          |
|------------|--------|--------------------------------------|
| dialogId   | number | ID of the dialog (int16)             |
| button     | number | 0 = left button, 1 = right button (int8) |
| listboxId  | number | Selected row index (int16)           |
| input      | string | Text input (string8)                 |

---

### `onSendClickPlayer(playerId, source)`
Fires when the player clicks on another player in the scoreboard.
```lua
function sampev.onSendClickPlayer(playerId, source)
    print("Clicked player: " .. playerId)
end
```

---

## Incoming events (server → player)

These fire when the server sends data to the local player.

### `onServerMessage(color, text)`
Fires when the server sends a colored message to chat.
```lua
function sampev.onServerMessage(color, text)
    if text:find("banned") then
        return false -- hide this message
    end
end
```
| Parameter | Type   | Description                  |
|-----------|--------|------------------------------|
| color     | number | ARGB color value             |
| text      | string | Message text                 |

---

### `onShowDialog(dialogId, type, title, button1, button2, text)`
Fires when the server shows a dialog to the player.
```lua
function sampev.onShowDialog(dialogId, type, title, button1, button2, text)
    print("Dialog shown: " .. title)
    -- return false to hide the dialog
    -- return {text = "custom text"} to modify it
end
```
| Parameter | Type   | Description                                      |
|-----------|--------|--------------------------------------------------|
| dialogId  | number | Dialog ID                                        |
| type      | number | 0=msgbox, 1=input, 2=list, 3=password, 4=tablist |
| title     | string | Dialog title                                     |
| button1   | string | Left button text                                 |
| button2   | string | Right button text (empty = hidden)               |
| text      | string | Dialog body content                              |

---

### `onShowTextDraw(id, data)`
Fires when a textdraw is shown to the player.
```lua
function sampev.onShowTextDraw(id, data)
    print("Textdraw shown: " .. id)
end
```

---

### `onApplyPlayerAnimation(playerId, animLib, animName, frameDelta, loop, lockX, lockY, freeze, time)`
Fires when the server applies an animation to a player.
```lua
function sampev.onApplyPlayerAnimation(playerId, animLib, animName, frameDelta, loop, lockX, lockY, freeze, time)
    print(string.format("Player %d: %s/%s", playerId, animLib, animName))
end
```
| Parameter  | Type    | Description                     |
|------------|---------|---------------------------------|
| playerId   | number  | Player ID receiving animation   |
| animLib    | string  | GTA SA animation library name   |
| animName   | string  | Animation clip name             |
| frameDelta | number  | Playback speed (float)          |
| loop       | boolean | Loop the animation              |
| lockX      | boolean | Lock X axis movement            |
| lockY      | boolean | Lock Y axis movement            |
| freeze     | boolean | Freeze player during animation  |
| time       | number  | Duration in ms (-1 = natural)   |

---

### `onSetPlayerHealth(health)`
Fires when the server sets the local player's health.
```lua
function sampev.onSetPlayerHealth(health)
    print("Health set to: " .. health)
end
```

---

### `onSetPlayerArmour(armour)`
Fires when the server sets the local player's armour.
```lua
function sampev.onSetPlayerArmour(armour)
    print("Armour set to: " .. armour)
end
```

---

### `onSetPlayerPos(position)`
Fires when the server teleports the local player.
```lua
function sampev.onSetPlayerPos(position)
    print(string.format("Teleported to %.1f %.1f %.1f", position.x, position.y, position.z))
end
```
| Parameter | Type   | Description               |
|-----------|--------|---------------------------|
| position  | table  | `{x, y, z}` coordinates  |

---

### `onTogglePlayerSpectating(state)`
Fires when spectate mode is toggled.
```lua
function sampev.onTogglePlayerSpectating(state)
    print("Spectating: " .. tostring(state))
end
```

---

## Modifying event data

samp.events uses **positional tables** to override values — NOT key-value tables.  
Return a table with values in the **same order as the function parameters**.

> Source: [github.com/THE-FYP/SAMP.Lua](https://github.com/THE-FYP/SAMP.Lua) README

```lua
-- Change the text of every server message to uppercase
-- onServerMessage(color, text) → return {color, newText}
function sampev.onServerMessage(color, text)
    return {color, text:upper()}  -- positional: {color, text}
end

-- Replace chat message before it reaches the server
-- onSendChat(message) → return {newMessage}
function sampev.onSendChat(message)
    return {message .. " :)"}  -- positional: {message}
end

-- Change dialog text before it shows
-- onShowDialog(dialogId, type, title, button1, button2, text)
function sampev.onShowDialog(dialogId, dialogType, title, button1, button2, text)
    return {dialogId, dialogType, title, button1, button2, "Custom: " .. text}
end
```

> ⚠️ **Wrong:** `return {text = text:upper()}` — key-value tables are NOT supported by samp.events  
> ✅ **Correct:** `return {color, text:upper()}` — positional order matching parameters

---

## Blocking events

Return `false` to completely suppress an event:

```lua
-- Block all dialogs from showing
function sampev.onShowDialog(dialogId, type, title, button1, button2, text)
    return false
end
```

---

## Notes

- All `sampev` functions are optional — only define the ones you need
- Multiple scripts can hook the same event simultaneously
- `samp.events` requires `samp.raknet` internally — both must be present
- SAMPFUNCS is required for outgoing RPC functionality (`samp.raknet`)
- Events fire on the main Lua thread — avoid blocking calls inside handlers

---

## Common mistakes

| Mistake | Correct approach |
|---------|-----------------|
| `require 'samp/events'` | `require 'samp.events'` |
| `sampev.onSendChat = function()` | `function sampev.onSendChat()` |
| Returning `nil` to block | Return `false` explicitly |
| `return {text = "new"}` to modify | `return {"new"}` — positional table |
| Using `sampev.emitOutcomingRpc()` | Use `raknetEmitRpc()` from SAMPFUNCS |

---

## Source & credits

This documentation is based on the official source code of **SAMP.Lua by THE-FYP / BlastHack Team**:

- Full event list: [github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua)
- Outgoing RPC field layouts: [github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua](https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua)
- README with usage examples: [github.com/THE-FYP/SAMP.Lua/blob/master/README.md](https://github.com/THE-FYP/SAMP.Lua/blob/master/README.md)

> For the complete list of all events, read `events.lua` directly — it is the authoritative source.

---

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
