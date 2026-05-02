# mimgui

> Library: `mimgui` — Dear ImGui for MoonLoader  
> Require: `local imgui = require 'mimgui'`  
> Purpose: Full-featured immediate mode GUI for MoonLoader scripts using Dear ImGui v1.72  
> Version: v1.7.1 — requires MoonLoader v.025+

---

## Installation

Place the `mimgui/` folder inside `moonloader/lib/`.  
Download: [github.com/THE-FYP/mimgui/releases](https://github.com/THE-FYP/mimgui/releases)  
Official guide (Russian): [blast.hk/threads/66959](https://www.blast.hk/threads/66959/)

---

## Basic structure

Every mimgui script follows this pattern:

```lua
local imgui = require 'mimgui'
local ffi = require 'ffi'
local new, str = imgui.new, ffi.string

-- Persistent state variables (must be ffi-allocated, not plain Lua)
local showWindow = new.bool(false)
local myText = new.char[256]('')

-- Register the render frame
imgui.OnFrame(
    function() return showWindow[0] end,  -- condition: render only when true
    function(player)
        -- called every frame when condition is true
        imgui.Begin('My Window', showWindow)
        imgui.Text('Hello, World!')
        imgui.End()
    end
)

function main()
    while not isSampLoaded() do wait(100) end
    showWindow[0] = true  -- show the window
    wait(-1)              -- keep script alive
end
```

---

## imgui.OnFrame

```lua
local sub = imgui.OnFrame(condition, cbBeforeFrame, [cbDraw])
```

> Source: [github.com/THE-FYP/mimgui/blob/master/lua/init.lua](https://github.com/THE-FYP/mimgui/blob/master/lua/init.lua)

| Parameter | Type | Description |
|---|---|---|
| condition | function | Called every frame — return true to render, false to hide |
| cbBeforeFrame | function | If cbDraw is absent: the draw callback. If cbDraw is present: called before the frame |
| cbDraw | function (optional) | The actual draw callback |

The returned `sub` object has:
- `sub.LockPlayer = true/false` — lock player controls when GUI is active
- `sub.HideCursor = true/false` — hide cursor when GUI is shown
- `sub:Unsubscribe()` — remove this frame handler
- `sub:IsActive()` — returns true if currently rendering

```lua
-- Common pattern: lock player and show cursor while window is open
local sub = imgui.OnFrame(
    function() return showWindow[0] end,
    function()
        imgui.Begin('Menu', showWindow)
        imgui.Text('Controls locked while open')
        imgui.End()
    end
)
sub.LockPlayer = true   -- lock WASD/movement
sub.HideCursor = false  -- show mouse cursor
```

---

## imgui.OnInitialize

```lua
imgui.OnInitialize(function()
    -- called once after DX9 renderer is ready
    -- use this to load fonts or textures
    local fontPath = getFolderPath(0x14) .. '\\consola.ttf'
    imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, 15.0)
end)
```

---

## State variables (imgui.new)

mimgui uses LuaJIT FFI types for all mutable state. Plain Lua variables will NOT work for ImGui widgets.

```lua
local new = imgui.new

-- Scalars
local myBool   = new.bool(false)      -- checkbox, window open flag
local myInt    = new.int(0)           -- sliders, combo index
local myFloat  = new.float(0.5)       -- float sliders
local myFloat3 = new.float[3](0)      -- color/vector widgets

-- Strings (text input buffers)
local myText   = new.char[256]('')    -- InputText buffer

-- Access and assign values
myBool[0] = true
myInt[0] = 5
local val = myFloat[0]

-- Copy a Lua string into a char buffer
imgui.StrCopy(myText, "hello")
-- Read back from buffer
local luaStr = ffi.string(myText)
```

---

## Windows

```lua
-- Basic window
imgui.Begin('Title')
-- widgets here
imgui.End()

-- Window with close button (pass bool*)
local open = new.bool(true)
imgui.Begin('Title', open)       -- open[0] becomes false when X is clicked
imgui.End()

-- Window with flags
imgui.Begin('Title', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
imgui.End()

-- Set position/size before Begin
imgui.SetNextWindowPos(imgui.ImVec2(100, 100), imgui.Cond.FirstUseEver)
imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
imgui.Begin('My Window')
imgui.End()
```

---

## Common widgets

```lua
-- Text
imgui.Text('Hello!')
imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), 'Red text')  -- RGBA 0.0–1.0
imgui.TextWrapped('Long text that wraps automatically...')
imgui.Separator()
imgui.Spacing()
imgui.SameLine()  -- put next widget on same line

-- Button
if imgui.Button('Click me') then
    -- button was pressed
end

if imgui.SmallButton('small') then end

-- Checkbox
local enabled = new.bool(false)
imgui.Checkbox('Enable feature', enabled)
-- enabled[0] is true/false

-- Slider
local value = new.float(0.5)
imgui.SliderFloat('Speed', value, 0.0, 1.0)

local intVal = new.int(10)
imgui.SliderInt('Count', intVal, 0, 100)

-- Input text
local buf = new.char[256]('')
imgui.InputText('Label', buf, ffi.sizeof(buf))
local result = ffi.string(buf)

-- Input int / float
local n = new.int(0)
imgui.InputInt('Value', n)

-- Combo (dropdown)
local items = {'Option A', 'Option B', 'Option C'}
local selected = new.int(0)
if imgui.BeginCombo('Pick', items[selected[0] + 1]) then
    for i, item in ipairs(items) do
        if imgui.Selectable(item, selected[0] == i - 1) then
            selected[0] = i - 1
        end
    end
    imgui.EndCombo()
end

-- Color picker
local color = new.float[4](1, 0, 0, 1)  -- RGBA
imgui.ColorEdit4('Color', color)

-- Tree node
if imgui.TreeNodeStr('Section') then
    imgui.Text('Inside tree')
    imgui.TreePop()
end
```

---

## Layout helpers

```lua
imgui.SameLine()                              -- next widget on same line
imgui.SameLine(100)                           -- at x offset 100
imgui.Indent()                                -- indent following items
imgui.Unindent()
imgui.Columns(3, 'cols', true)                -- 3-column layout
imgui.NextColumn()
imgui.Columns(1)                              -- reset to 1 column

imgui.PushItemWidth(120)                      -- set widget width
imgui.PopItemWidth()

-- Child region (scrollable sub-area)
imgui.BeginChild('region', imgui.ImVec2(0, 200), true)
-- widgets
imgui.EndChild()
```

---

## Style / Colors

```lua
-- Push temporary style changes
imgui.PushStyleColorU32(imgui.Col.Text, 0xFF00FF00)  -- ABGR uint32
imgui.Text('Green text')
imgui.PopStyleColor()

imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.5, 0.8, 1.0))
imgui.Button('Blue button')
imgui.PopStyleColor()

imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.5)
imgui.Text('Half transparent')
imgui.PopStyleVar()

imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(4, 4))
imgui.PopStyleVar()
```

> Color format for `PushStyleColorU32`: `0xAABBGGRR` (note: ABGR, not ARGB)

---

## Fonts

```lua
imgui.OnInitialize(function()
    local fontPath = getFolderPath(0x14) .. '\\arial.ttf'
    myFont = imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, 16.0)
end)

-- In draw callback:
imgui.PushFont(myFont)
imgui.Text('Custom font')
imgui.PopFont()
```

---

## Flags enums

Flags are accessed through mimgui enum tables:

```lua
imgui.WindowFlags.NoResize
imgui.WindowFlags.NoMove
imgui.WindowFlags.NoTitleBar
imgui.WindowFlags.AlwaysAutoResize
imgui.WindowFlags.MenuBar

imgui.InputTextFlags.AllowTabInput
imgui.InputTextFlags.Password
imgui.InputTextFlags.ReadOnly

imgui.Cond.Always
imgui.Cond.FirstUseEver
imgui.Cond.Appearing

imgui.Col.Text
imgui.Col.Button
imgui.Col.WindowBg
imgui.Col.FrameBg

imgui.StyleVar.Alpha
imgui.StyleVar.FramePadding
imgui.StyleVar.ItemSpacing

imgui.SelectableFlags.DontClosePopups
imgui.TreeNodeFlags.DefaultOpen
```

Combine flags with `+`:
```lua
imgui.Begin('Win', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
```

---

## Utility types

```lua
-- ImVec2: 2D position or size
imgui.ImVec2(x, y)

-- ImVec4: color or rect (RGBA, values 0.0–1.0)
imgui.ImVec4(r, g, b, a)

-- Get display size
local io = imgui.GetIO()
local w = io.DisplaySize.x
local h = io.DisplaySize.y

-- Get center of screen
local cx = io.DisplaySize.x / 2
local cy = io.DisplaySize.y / 2
```

---

## Common patterns

### Toggle window with a key

```lua
local vk = require 'vkeys'
local showWindow = imgui.new.bool(false)

imgui.OnFrame(function() return showWindow[0] end, function()
    imgui.Begin('Menu', showWindow)
    imgui.Text('Press F5 to toggle')
    imgui.End()
end)

function main()
    while true do
        wait(0)
        if isKeyJustPressed(vk.VK_F5) then
            showWindow[0] = not showWindow[0]
        end
    end
end
```

### Centered window on first open

```lua
imgui.OnFrame(function() return showWindow[0] end, function()
    local io = imgui.GetIO()
    imgui.SetNextWindowPos(
        imgui.ImVec2(io.DisplaySize.x / 2, io.DisplaySize.y / 2),
        imgui.Cond.FirstUseEver,
        imgui.ImVec2(0.5, 0.5)
    )
    imgui.Begin('Centered', showWindow)
    imgui.End()
end)
```

### InputText with read-back

```lua
local buf = imgui.new.char[128]('')

imgui.OnFrame(function() return true end, function()
    imgui.Begin('Input')
    imgui.InputText('Name', buf, ffi.sizeof(buf))
    if imgui.Button('Submit') then
        local value = ffi.string(buf)
        sampSendChat('/say ' .. value)
    end
    imgui.End()
end)
```

---

## Common mistakes

| Mistake | Correct |
|---|---|
| `local open = false` for window flag | `local open = imgui.new.bool(true)` |
| `imgui.Text(number)` | `imgui.Text(tostring(number))` |
| Calling ImGui functions outside `OnFrame` | Only call ImGui functions inside the draw callback |
| Forgetting `imgui.End()` after `imgui.Begin()` | Always pair Begin/End |
| `imgui.Begin('Win', false)` | `imgui.Begin('Win', myBoolPtr)` — must be a pointer |
| `return false` in condition to hide | Just set `showWindow[0] = false` |

---

## Notes

- Requires MoonLoader v.025 or higher (checked on load)
- Uses LuaJIT FFI — all widget state must be FFI-allocated (`imgui.new`)
- The condition function in `OnFrame` is called every frame — keep it cheap
- `imgui.DisableInput = true` disables mouse/keyboard capture globally
- Config (window positions, etc.) is saved automatically to `moonloader/config/mimgui/`
- For the full Dear ImGui function reference: [github.com/ocornut/imgui](https://github.com/ocornut/imgui)

---

## Credits

- **THE-FYP / BlastHack Team** — mimgui library ([github.com/THE-FYP/mimgui](https://github.com/THE-FYP/mimgui))
- **ocornut** — Dear ImGui ([github.com/ocornut/imgui](https://github.com/ocornut/imgui))
- **Northn** — mimgui guide on BlastHack ([blast.hk/threads/66959](https://www.blast.hk/threads/66959/))

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
