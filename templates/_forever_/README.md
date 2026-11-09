# templates/_forever_ (WoW: Forever kit)

WoW: Forever = client 1.60.1, Interface 16001, product `wowf`, exe `Wow.exe`,
folder `_forever_`. Modern (Mainline) UI/API, not the Classic Era one.

Bars + binds + CVars only. No SetupCore / class addons / ElvUIFixes here:
those are Classic-API code and are not ported. Place spells on bars by hand
(drag from the spellbook) -- the bar *positions* and *keys* match our layout.

| file | source | notes |
|---|---|---|
| `bindings-cache.wtf` | copy of `templates/bindings-cache.wtf` | Every Blizzard action it binds (ACTIONBUTTON, MULTIACTIONBAR2/3/4BUTTON, TOGGLEAUTORUN, STRAFE*, OPENALLBAGS) exists in Forever's `Bindings_*.xml` (wow-ui-source `forever` branch, 1.60.1.70790). `QUESTIE_TOGGLE_JOURNEY` comes from Questie. |
| `Config.wtf` | trimmed `templates/Config.wtf` | Only CVars referenced in Forever's Blizzard UI source. |
| ElvUI profile | `templates/ElvUI.lua` (shared, unchanged) | ElvUI 16.x uses one Shared/Defaults + DBConversions for every flavor, so the same profile table loads. |

## CVars dropped (could not confirm in Forever UI source)
- `nameplateShowFriends`, `nameplateShowFriendlyMinions` -> replaced by
  `nameplateShowFriendlyPlayers` / `nameplateShowFriendlyNpcs` (modern names).
- `nameplateMaxDistance`, `nameplateMaxAlpha`, `removeChatDelay`,
  `floatingCombatTextCombatDamage/Healing/LowManaHealth`,
  `takeScreenshotOnLevelUp`, `alwaysShowActionBars`: not referenced in the UI
  source. May still be engine CVars; set in-game via Options if wanted.
- `checkAddonVersion "0"` dropped ON PURPOSE: it is "Load out of date AddOns".
  On Forever that would load Classic-API addons that then throw errors.

## Known risks
- Modern clients can sync keybinds to the server. If the server copy wins on
  first login, our bindings-cache.wtf may be replaced. Fix: Esc -> Options ->
  Keybindings and check "Character specific" is off, then re-run the installer
  with WoW closed. Untested on the live client.
- No SetupCore = nobody suppresses the ElvUI install wizard. When it pops up,
  close it with the X. Clicking Install would overwrite the layout.
- ElvUI's Forever support is "initial" (16.00 changelog); gamepad not yet.
