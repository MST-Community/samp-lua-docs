# samp-lua-docs

> Maintained by **MST Community** — Modding Samp Team  
> A reference repository for writing SA-MP Lua scripts with AI assistance (Claude, GPT, etc.)  
> All documentation is structured to be consumed directly by language models via Context7 or raw URL.

[![Discord](https://img.shields.io/badge/Discord-MST%20Community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/mst-community-1257189867020881962)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![SA-MP](https://img.shields.io/badge/SA--MP-0.3.7--R5-blue)]()
[![MoonLoader](https://img.shields.io/badge/MoonLoader-0.26%2B-orange)]()

---

## About MST Community

**Modding Samp Team** is an online community dedicated to advanced GTA San Andreas and SA-MP modding.

- 💬 Discord: [discord.com/invite/mst-community-1257189867020881962](https://discord.com/invite/mst-community-1257189867020881962)
- 👥 3500+ members

---

## What is this?

This repo is a **knowledge base for MoonLoader/SA-MP Lua scripting**, maintained by MST Community and designed so that AI models can read it and generate accurate, working scripts without hallucinating functions that don't exist.

It covers:
- Core libraries: `samp.events`, `samp.raknet`, `mimgui`, `moonloader`, `sampfuncs`
- RPC IDs and bitstream field layouts
- Annotated example scripts
- A ready-to-use base prompt for Claude

---

## Repository structure

```
samp-lua-docs/
├── README.md                  ← you are here
│
├── libs/                      ← library documentation
│   ├── samp.events.md         ← event hooks (onSendChat, onServerMessage, etc.)
│   ├── samp.raknet.md         ← RPC/packet ID constants
│   ├── mimgui.md              ← Dear ImGui bindings for MoonLoader
│   ├── moonloader.md          ← core MoonLoader API (wait, lua_thread, etc.)
│   └── sampfuncs.md           ← SAMPFUNCS functions (raknetEmitRpc, bitstream, etc.)
│
├── rpc/
│   └── rpc_ids.md             ← full SA-MP 0.3.7 RPC ID table + bitstream layouts
│
├── examples/                  ← real working scripts, fully commented
│   ├── chat_talk_anim.lua     ← plays animation when player sends chat message
│   ├── basic_menu.lua         ← simple mimgui menu skeleton
│   └── auto_message.lua       ← periodic chat message sender
│
└── prompt/
    └── base_prompt.md         ← copy-paste prompt for Claude with instructions
```

---

## How to use this with Claude

### Option A — Context7 (recommended)

If you have Context7 configured as an MCP server in Cursor or another editor:

1. Add this repo as a Context7 source
2. When prompting Claude, explicitly say:
   > "Use Context7, consult the `samp-lua-docs` library before writing any code."

### Option B — Raw URL (no setup needed)

Paste the raw URL of any file directly into your Claude conversation:

```
https://raw.githubusercontent.com/YOUR_USERNAME/samp-lua-docs/main/libs/samp.events.md
https://raw.githubusercontent.com/YOUR_USERNAME/samp-lua-docs/main/rpc/rpc_ids.md
https://raw.githubusercontent.com/YOUR_USERNAME/samp-lua-docs/main/prompt/base_prompt.md
```

Claude can read raw GitHub URLs natively — no tools required.

### Option C — Paste the base prompt

Open `prompt/base_prompt.md`, copy its contents, and paste it at the start of your conversation with Claude before describing what you want.

---

## Requirements

Scripts in this repo target:

| Dependency   | Version         | Required |
|--------------|-----------------|----------|
| MoonLoader   | 0.26+           | ✅ yes   |
| SA-MP        | 0.3.7-R5        | ✅ yes   |
| SAMP.Lua     | 2.3.0+          | ✅ yes   |
| SAMPFUNCS    | 5.x             | ✅ yes   |
| mimgui       | latest          | optional |

---

## Installing dependencies

```
moonloader/lib/samp/events.lua   ← from github.com/THE-FYP/SAMP.Lua
moonloader/lib/samp/raknet.lua   ← same repo
moonloader/lib/mimgui/           ← from blast.hk/threads/mimgui
SAMPFUNCS.asi                    ← from blast.hk/attachments/22939
```

---

## Contributing

Feel free to open a PR to add:
- New library documentation
- Fixed or improved example scripts
- Additional RPC layouts

---

## Contributing

This repo is maintained by MST Community members. Feel free to open a PR to add:
- New library documentation
- Fixed or improved example scripts
- Additional RPC layouts
- Corrections to existing docs

Join our Discord to discuss before submitting large changes.

---

## Credits

- **MST Community** — repo maintenance and example scripts
- **THE-FYP / BlastHack Team** — MoonLoader, SAMP.Lua
- **MISTER_GONWIK** — SAMP.Lua contributions
- **BlastHack community** — blast.hk

---

## License

MIT — use freely, credit MST Community appreciated.
