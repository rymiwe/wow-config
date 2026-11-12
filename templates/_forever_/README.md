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

## CVars in this kit
- `autoLootDefault 1`, `autoSelfCast 1`, `cameraSmoothStyle 0` (never adjust),
  `nameplateShowEnemies 1` (+ enemy minions/minus).
- `nameplateShowFriendlyPlayers 1` — Forever's name for Classic's
  `nameplateShowFriends` (see dropped list). Friendly NPCs stay off.
- `showTargetOfTarget 1` — Options > Gameplay > Combat (Forever UI source).
- `showQuestLevel 1` — Forever 1.60.1 CVar (quest log/list shows level).

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

## Keeping Forever in sync

**BLD is the only place to change the Forever layout.** When WoW: Forever
closes on BLD, the hidden watcher saves the layout to this repo. The Steam
Deck and ibp only pull it down, with `scripts/sync-forever.sh`.

- **Syncs:** ElvUI layout (account-wide), keybinds, and KeyKit.
- **Never syncs:** graphics settings (`Config.wtf`), chat history, other addons.
- **UI scale stays per machine.** The Deck keeps its own scale (0.7111), BLD its own (0.6).

Bars changed on the Deck or ibp get replaced at the next sync. The old copy
is saved first in `_forever_/AddOnBackups/sync-<date-time>/`.

### BLD: one-time setup

Do this once, after this change is merged, in PowerShell with WoW closed.

1. Bring the Windows checkout up to date. If git refuses because of local
   changes, stop and sort those out first. Do not force it.

```powershell
cd "E:\Program Files\World of Warcraft"
```

```powershell
git pull
```

2. Re-register the watcher. It stays hidden: no window, no taskbar entry.
   It now watches both `WowClassic.exe` (Anniversary) and `Wow.exe` (Forever).

```powershell
.\scripts\install-watch-task.ps1
```

3. Optional check that the task exists:

```powershell
Get-ScheduledTask -TaskName wow-config-watch
```

### Steam Deck / ibp: pull BLD's latest layout

1. **Quit WoW completely.** The script refuses to run while it is open.
2. Open a terminal (Deck: Desktop Mode, then Konsole).
3. Run the sync. From a clone of this repo:

```bash
scripts/sync-forever.sh
```

Or without a clone:

```bash
curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/scripts/sync-forever.sh | bash
```

To see what it would change without changing anything:

```bash
scripts/sync-forever.sh --dry-run
```

If it can't find WoW, tell it where. Steam Deck:

```bash
scripts/sync-forever.sh --wow-dir ~/Games/"World of Warcraft"
```

ibp:

```bash
WOWDIR=~/Games/battlenet/"drive_c/Program Files (x86)/World of Warcraft" scripts/sync-forever.sh
```

Either form also accepts the `_forever_` folder itself.

The script ends with a list: `NEW`, `UPDATE` (with the backup path), or
`SAME` for each file, with md5 checksums before and after. Running it twice
in a row changes nothing the second time. To undo a sync, copy the files
back from the `AddOnBackups/sync-<date-time>/` folder it printed.
