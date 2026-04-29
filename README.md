# wow-config

Personal WoW client configuration backup across all installed flavors (Anniversary, Classic Era, Retail, etc).

This repo lives at the WoW install root (`World of Warcraft/`) and tracks only the files we explicitly whitelist in `.gitignore`. Everything else — game files, addons from upstream, caches, logs — is ignored automatically.

## What's tracked

- **Custom addons** (`_*/Interface/AddOns/ChatAnchor/`)
- **Client CVars** (`_*/WTF/Config.wtf`)
- **Account-wide bindings + macros** (`_*/WTF/Account/*/bindings-cache.wtf`, `macros-cache.txt`)
- **Account SavedVariables** (`_*/WTF/Account/*/SavedVariables/*.lua`) — ElvUI, WeakAuras, TomTom, etc.
- **Per-character config**: bindings, chat-cache, layout-local, edit-mode-cache, AddOns enable list
- **Per-character SavedVariables** under each character folder

## What's NOT tracked

- Upstream addon code (`Interface/AddOns/ElvUI/`, etc.) — reinstall from source
- Cache, Logs, `.bak`/`.old` autobackups, `cache.md5`, `config-cache.wtf`
- Battle.net launcher files, game data

## Custom addons

### `ChatAnchor`

Workaround for ElvUI on Anniversary client where `ChatFrame1` drifts away from `LeftChatPanel` after chat-content events (loot, kills, /rl). Hooks `ChatFrame1:SetPoint` and re-anchors on every login + every reposition attempt.

## Restore workflow

After a fresh WoW install or addon nuke:

1. Reinstall ElvUI (and other upstream addons) via the normal installer
2. `git clone` this repo over the WoW root, accepting overwrites
3. Launch WoW; SavedVariables and bindings restore on next login

## Commit cadence

WoW only flushes SavedVariables on logout/`/rl`. Commit after a session when something worth preserving has changed.
