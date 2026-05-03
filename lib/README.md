# lib/

This folder contains real `.lua` library files from the SA-MP/MoonLoader community.

Drop the contents of this folder directly into your `moonloader/lib/` directory to use them in your scripts.

---

## What goes here

These are actual Lua libraries — not documentation. Scripts in `examples/` and your own scripts can `require` these directly once placed in `moonloader/lib/`.

Common libraries you'll find here:

| File / Folder | Require | Description |
|---------------|---------|-------------|
| `samp/` | `require 'samp.events'` | SA-MP event hooks — part of [SAMP.Lua](https://github.com/THE-FYP/SAMP.Lua) |
| `samp/` | `require 'samp.raknet'` | RPC/Packet ID constants — part of [SAMP.Lua](https://github.com/THE-FYP/SAMP.Lua) |
| `mimgui/` | `require 'mimgui'` | Dear ImGui bindings for MoonLoader by FYP |
| `vkeys.lua` | `require 'vkeys'` | Virtual key constants (VK_F1, VK_RETURN, etc.) |
| `encoding.lua` | `require 'encoding'` | UTF-8 / Cyrillic string encoding helpers |
| `inicfg.lua` | `require 'inicfg'` | INI config file read/write |
| `sampapi/` | `require 'sampapi'` | SA-MP memory structures via FFI — [SAMP-API.lua](https://github.com/imring/SAMP-API.lua) |

> This list is illustrative — the actual files present depend on what has been added to this folder.

---

## Official sources

| Library | Author | Download |
|---------|--------|----------|
| SAMP.Lua (samp.events, samp.raknet) | THE-FYP / BlastHack | [github.com/THE-FYP/SAMP.Lua](https://github.com/THE-FYP/SAMP.Lua/releases) |
| mimgui | FYP | [luarocks.org/m/moonloader](https://luarocks.org/m/moonloader) |
| SAMP-API.lua | imring | [github.com/imring/SAMP-API.lua](https://github.com/imring/SAMP-API.lua) |
| SF.lua | SF-lua | [github.com/SF-lua/SF.lua](https://github.com/SF-lua/SF.lua) |
| vkeys, encoding, inicfg | FYP | bundled with MoonLoader 026 installer |

---

## Installation

```
moonloader/
└── lib/               ← everything in this folder goes here
    ├── samp/
    │   ├── events.lua
    │   ├── raknet.lua
    │   └── ...
    ├── mimgui/
    │   └── ...
    ├── vkeys.lua
    ├── encoding.lua
    └── inicfg.lua
```

---

*Maintained by MST Community — [discord.gg/mst-community](https://discord.com/invite/mst-community-1257189867020881962)*
