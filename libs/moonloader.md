# moonloader

> Library: `moonloader` — built-in MoonLoader API, globally available  
> Require: **not needed** — all functions are global once MoonLoader is loaded  
> Purpose: Core scripting API — script lifecycle, input, rendering, memory, threads, file I/O  
> Official docs: [wiki.blast.hk/moonloader/scripting-api](https://wiki.blast.hk/moonloader/scripting-api)

---

## Installation

MoonLoader is an ASI mod for GTA San Andreas.  
Download: [blast.hk/threads/13305](https://www.blast.hk/threads/13305/)  
Place `moonloader.asi` and the `moonloader/` folder inside your GTA SA root directory.

Scripts go in: `GTA SA/moonloader/`  
Libraries go in: `GTA SA/moonloader/lib/`

---

## Basic script structure

Every script must define a `main()` function. Use `wait()` to yield — never block.

```lua
script_name("MyScript")
script_author("YourName")
script_version("1.0")

function main()
    -- wait for SA-MP to be available before doing anything
    while not isSampLoaded() do
        wait(100)
    end

    -- main loop — wait(0) yields once per frame
    while true do
        wait(0)
        -- your logic here
    end
end
```

---

## Directives (metadata)

Call these at the top level, outside any function.

```lua
script_name("ScriptName")
script_author("AuthorName")
script_authors("Author1", "Author2")
script_version("1.0.0")
script_version_number(100)
script_description("What this script does")
script_moonloader(26)                   -- minimum MoonLoader version required
script_dependencies("lib1", "lib2")
script_url("https://example.com")
script_properties("prop1", "prop2")
```

---

## Events

Events are called automatically by MoonLoader. Register with a global function or `addEventHandler`.

```lua
-- Method 1: global function
function onExitScript(quitGame)
    print("Script exiting")
end

-- Method 2: addEventHandler
addEventHandler("onExitScript", function(quitGame)
    print("Script exiting")
end)
```

### Event list

> Source: [wiki.blast.hk/moonloader/events](https://wiki.blast.hk/moonloader/events)

| Since | Event | Description |
|---|---|---|
| v.015 | `main()` | Entry point — required in every script |
| v.022 | `onExitScript(bool quitGame)` | Script is terminating |
| v.015 | `onQuitGame()` | Game is closing |
| v.015 | `onScriptLoad(LuaScript s)` | Another script was loaded |
| v.022 | `onScriptTerminate(LuaScript s, bool quitGame)` | Another script terminated |
| v.015 | `onSystemInitialized()` | MoonLoader system initialized |
| v.015 | `onScriptMessage(string msg, LuaScript s)` | A script sent a message |
| v.015 | `onSystemMessage(string msg, int type, LuaScript s)` | System message received |
| v.022 | `onWindowMessage(uint msg, uint wparam, int lparam)` | Windows message hook |
| v.023 | `onStartNewGame(int mpack)` | New game started |
| v.023 | `onLoadGame(table saveData)` | Save game loaded |
| v.023 | `onSaveGame(table saveData) → table` | Game saving — return table to persist custom data |

### Low-level network events

For SA-MP scripting prefer `samp.events` over these. Return `false` as first value to cancel.

| Event | Description |
|---|---|
| `onReceivePacket(int id, bitstream bs)` | Incoming RakNet packet |
| `onReceiveRpc(int id, bitstream bs)` | Incoming RPC |
| `onSendPacket(int id, bitstream bs, int priority, int reliability, int orderingChannel)` | Outgoing packet |
| `onSendRpc(int id, bitstream bs, int priority, int reliability, int orderingChannel, bool shiftTs)` | Outgoing RPC |

```lua
function onReceiveRpc(id, bs)
    if id == 93 then
        return false -- cancel this incoming RPC
    end
end
```

---

## Script control

```lua
wait(int ms)          -- yield for ms milliseconds; wait(0) yields one frame
reloadScripts()       -- reload all running scripts
thisScript()          -- returns LuaScript handle of the current script
```

---

## State checks

```lua
bool = isSampLoaded()           -- true if SA-MP is loaded
bool = isSampfuncsLoaded()      -- true if SAMPFUNCS is loaded
bool = isCleoLoaded()           -- true if CLEO is loaded
bool = isOpcodesAvailable()     -- true if opcode functions are available
bool = isPauseMenuActive()      -- true if ESC menu is open
bool = isGamePaused()           -- true if game is paused
bool = isGameWindowForeground() -- true if GTA window has focus
int  = getMoonloaderVersion()   -- version number, e.g. 26
```

---

## Input / keyboard

```lua
bool = isKeyDown(int keyId)          -- true while key is held
bool = isKeyJustPressed(int keyId)   -- true on the frame the key was first pressed
bool = wasKeyPressed(int keyId)      -- true if pressed since last call
bool = wasKeyReleased(int keyId)     -- true if released since last call
int  = getMousewheelDelta()          -- mouse wheel scroll delta this frame
int posX, int posY = getCursorPos()  -- cursor position in screen pixels
showCursor(bool show, [bool lockControls])
consumeWindowMessage([bool game], [bool scripts])
lockPlayerControl(bool lock)
bool = isPlayerControlLocked()
```

Use `require 'vkeys'` for named key constants:

```lua
local vk = require 'vkeys'

function main()
    while true do
        wait(0)
        if isKeyJustPressed(vk.VK_F5) then
            print("F5 pressed")
        end
    end
end
```

---

## Rendering

> Color format: `0xAARRGGBB` — e.g. `0xFF00FF00` = opaque green.

```lua
-- Primitives
renderDrawBox(float x, float y, float w, float h, uint color)
renderDrawBoxWithBorder(float x, float y, float w, float h, uint color, float bsize, uint bcolor)
renderDrawLine(float x1, float y1, float x2, float y2, float width, uint color)
renderDrawPolygon(float x, float y, float sizeX, float sizeY, int corners, float rotation, uint color)

-- Fonts
DxFont font = renderCreateFont(string name, int height, uint flags, [uint charset])
renderFontDrawText(DxFont font, string text, float x, float y, uint color, [bool ignoreColorTags])
float len  = renderGetFontDrawTextLength(DxFont font, string text, [bool ignoreColorTags])
float h    = renderGetFontDrawHeight(DxFont font)
renderReleaseFont(DxFont font)

-- Textures
DxTexture tex = renderLoadTextureFromFile(string file)
renderDrawTexture(DxTexture tex, float x, float y, float w, float h, float rotation, uint color)
renderReleaseTexture(DxTexture tex)
```

---

## HUD / text display

```lua
printHelpString(string text)                       -- shows help message box
printStyledString(string text, int time, int style)
printString(string text, int time)
printStringNow(string text, int time)
clearPrints()
clearSmallPrints()
```

### GXT text (for displaying dynamic strings)

```lua
setGxtEntry(string key, string text)
string key  = setFreeGxtEntry(string text)   -- auto-allocate a free GXT key
string text = getGxtText(string key)
clearGxtEntry(string key)
```

---

## Screen coordinate conversion

```lua
float sx, float sy = convert3DCoordsToScreen(float x, float y, float z)
bool, float sx, float sy, float z, float w, float h = convert3DCoordsToScreenEx(float x, float y, float z, [bool checkMin], [bool checkMax])
float gx, float gy = convertWindowScreenCoordsToGameScreenCoords(float wx, float wy)
float wx, float wy = convertGameScreenCoordsToWindowScreenCoords(float gx, float gy)
float x, float y, float z = convertScreenCoordsToWorld3D(float x, float y, float depth)
```

---

## Memory

```lua
-- memory module — global in MoonLoader, no require needed
int   = memory.getint8(uint address,  [bool unprotect])
int   = memory.getint16(uint address, [bool unprotect])
int   = memory.getint32(uint address, [bool unprotect])
float = memory.getfloat(uint address, [bool unprotect])

bool = memory.setint8(uint address,  int value,   [bool unprotect])
bool = memory.setint16(uint address, int value,   [bool unprotect])
bool = memory.setint32(uint address, int value,   [bool unprotect])
bool = memory.setfloat(uint address, float value, [bool unprotect])

string = memory.tostring(uint address, [uint size], [bool unprotect])
uint   = memory.strptr(string str)
memory.fill(uint address, int value, uint size, [bool unprotect])
memory.copy(uint dest, uint src, uint size, [bool unprotect])
```

---

## Threads

```lua
LuaThread t = lua_thread.create(function func, ...)
LuaThread t = lua_thread.create_suspended(function func)
```

```lua
-- Example: run async task without blocking main()
lua_thread.create(function()
    wait(3000)
    print("3 seconds passed")
end)
```

---

## File / directory

```lua
bool = doesFileExist(string path)
bool = doesDirectoryExist(string path)
bool = createDirectory(string path)
Filesearch h, string name = findFirstFile(string mask)
string file = findNextFile(Filesearch h)
findClose(Filesearch h)
string = getWorkingDirectory()    -- returns moonloader/ directory path
string = getGameDirectory()       -- returns GTA SA root directory path
```

---

## JSON

```lua
string json = encodeJson(table data)
table data  = decodeJson(string json)
```

---

## INI config

```lua
-- reads/writes .ini files relative to the script's location
table data = inicfg.load([table defaults], [string file])
bool ok    = inicfg.save(table data, [string file])
```

```lua
-- Example
local cfg = inicfg.load({enabled = true, delay = 500})
cfg.delay = 1000
inicfg.save(cfg)
```

---

## Script management

```lua
LuaScript s  = script.load(string file)
LuaScript s  = script.find(string name)
table list   = script.list()
LuaScript s  = script.get(int scriptId)
-- script.this → current script handle (same as thisScript())
```

---

## Selected world / game functions

> MoonLoader exposes hundreds of GTA SA opcodes as Lua functions.  
> Full list: [wiki.blast.hk/moonloader/scripting-api](https://wiki.blast.hk/moonloader/scripting-api)  
> Opcode → function lookup: [library.sannybuilder.com/#/sa/find](https://library.sannybuilder.com/#/sa/find)

```lua
-- Time
int hours, int mins = getTimeOfDay()
setTimeOfDay(int hours, int minutes)
int ms = getGameTimer()             -- milliseconds since game start

-- Weather
forceWeather(int weather)
forceWeatherNow(int weather)
releaseWeather()

-- Player / Ped
bool, Ped ped = getPlayerChar(Player player)
float x, y, z = getCharCoordinates(Ped ped)
setCharCoordinates(Ped ped, float x, float y, float z)
int   = getCharHealth(Ped ped)
setCharHealth(Ped ped, int health)
float = getCharHeading(Ped ped)
setCharHeading(Ped ped, float angle)
int   = getCurrentCharWeapon(Ped ped)
warpCharIntoCar(Ped ped, Vehicle car)

-- Vehicle
float x, y, z = getCarCoordinates(Vehicle car)
float speed    = getCarSpeed(Vehicle car)
int   health   = getCarHealth(Vehicle car)
int   model    = getCarModel(Vehicle car)
Ped   driver   = getDriverOfCar(Vehicle car)

-- Map / blips
float z = getGroundZFor3dCoord(float x, float y, float z)
Marker m = addBlipForCoord(float x, float y, float z)
removeBlip(Marker m)
changeBlipColour(Marker m, int color)
changeBlipScale(Marker m, int size)
```

---

## Common patterns

### Wait for SA-MP before executing

```lua
function main()
    while not isSampLoaded() do wait(100) end
    wait(1000) -- extra time for SA-MP to fully initialize
    -- safe to use sampAddChatMessage, samp.events, etc.
end
```

### Toggle feature with a keybind

```lua
local vk = require 'vkeys'
local enabled = false

function main()
    while true do
        wait(0)
        if isKeyJustPressed(vk.VK_F6) then
            enabled = not enabled
            sampAddChatMessage(enabled and "{00FF00}Enabled" or "{FF0000}Disabled", -1)
        end
    end
end
```

### Timed loop

```lua
function main()
    while true do
        wait(5000)
        sampSendChat("/afk")
    end
end
```

---

## Common mistakes

| Mistake | Correct approach |
|---------|-----------------|
| Calling SA-MP functions before `isSampLoaded()` | Always wait in a loop first |
| `while true do` without `wait()` | Always include `wait(0)` or higher |
| `require 'moonloader'` | Not needed — all functions are global |
| Using `wait()` outside `main()` or a thread | Only valid inside `main()` or `lua_thread` |

---

## Notes

- MoonLoader uses **LuaJIT 2.1** — Lua 5.1 compatible, bit operations via `bit.*`
- Scripts go in `moonloader/` with `.lua` extension; libraries in `moonloader/lib/`
- Use `require 'libname'` to load from `moonloader/lib/libname.lua`
- All opcode-based functions documented at [library.sannybuilder.com](https://library.sannybuilder.com/#/sa/find)
- Latest stable version: MoonLoader v.026.5-beta

---

## Source & credits

This documentation is based on the official MoonLoader wiki maintained by **BlastHack Team**:

- Scripting API: [wiki.blast.hk/moonloader/scripting-api](https://wiki.blast.hk/moonloader/scripting-api)
- Events reference: [wiki.blast.hk/moonloader/events](https://wiki.blast.hk/moonloader/events)
- MoonLoader official thread: [blast.hk/threads/13305](https://www.blast.hk/threads/13305/)
- Opcode database: [library.sannybuilder.com/#/sa/find](https://library.sannybuilder.com/#/sa/find)

> MoonLoader developed by **FYP, hnnssy, EvgeN1137** — © BlastHack Team

---

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
