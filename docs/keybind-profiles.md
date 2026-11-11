# Keybind profiles

These are Ryan's paladin keyboards for WoW: Forever, one profile per level step, from level 1 to 60. Each step adds the spells you learn at that level and moves a few keys around. Apply the step that matches your level in the game with KeyKit (below).

The level 50 step is the full level-60 layout:

- **Number keys:** 1 Seal of the Crusader, 2 Judgement, 3 Seal of Righteousness, 4 Hammer of Wrath, 5 Holy Strike, 6 Attack
- **Letter keys:** Q Consecration, E Exorcism, R Holy Wrath, T Blessing of Protection, Z Hammer of Justice, X Purify, C Lay on Hands, V Flash of Light
- **Shift:** F Holy Light, T Divine Protection, E Cleanse, G Divine Shield, 4 Divine Intervention
- **Alt, auras:** Q Devotion, E Retribution, R Concentration, F Shadow Resistance, T Frost Resistance, G Fire Resistance
- **Alt, blessings and other:** Z Might, C Wisdom, V Kings, X Righteous Fury, H Hearthstone

Seal of Justice and Seal of Fury get pushed off the keys as you level; by level 36 neither has a key.

Colors on the KeyKit keyboard:

| Color | Meaning |
|-------|---------|
| Gold | Rotation (the buttons you press most in a fight) |
| Coral | Crowd control and interrupts |
| Blue | Defensives |
| Green | Heals and dispels |
| Purple | Buffs (seals, blessings, auras) |
| Slate | Movement |
| Teal | Utility (bags, Hearthstone) |

## Why there is no PullCall map here

PullCall publishes first-login key layouts, including Forever paladin pages we looked at while researching:

- [Forever Paladin, level 10](https://pullcall.com/forever/key-bindings/paladin/10)
- [Forever Paladin, level 60 Retribution](https://pullcall.com/forever/key-bindings/paladin/60/retribution)

We did **not** copy those maps into this repo.

PullCall's [Terms of Service](https://pullcall.com/legal/terms) (version 1.1, effective 29 October 2026) say the Service — including the website — belongs to PullCall, and the terms give you only a personal, non-transferable right to use it: “They do not give you any other rights in the Service.” The [Acceptable Use Policy](https://pullcall.com/legal/aup) also says not to scrape the Service. [robots.txt](https://pullcall.com/robots.txt) allows crawlers to fetch `/forever/` and `/classic/`, but that is not a license to republish the layouts.

If you want to compare, open the PullCall pages above in a browser.

## What's in a profile

Each layout is a JSON file in `profiles/keybinds/`. Ryan's keys for every class and spec are generated into `profiles/keybinds/forever/` from `profiles/source/forever-keymaps.yaml` (see below). The shape is small on purpose:

```json
{
  "id": "forever-paladin-retribution-10",
  "class": "paladin",
  "level": 10,
  "spec": null,
  "source": { "name": "wow-config", "url": "https://github.com/rymiwe/wow-config", "credit": "Ryan Weiss" },
  "binds": [
    { "key": "1", "mod": null, "action": "Seal of the Crusader", "role": "buff" },
    { "key": "F", "mod": "shift", "action": "Holy Light", "role": "heal" },
    { "key": "H", "mod": "alt", "action": "Hearthstone", "role": "utility", "item": "Hearthstone" }
  ]
}
```

- `id`, `class`, `level`, `spec`, and `source` (with `url` and `credit`) describe the profile
- Each bind is `{ key, mod, action, role }`
- `action` is a spell name or a binding name (`Autorun`, `Strafe Left`, `Bags`)
- `mod` is `null`, `"shift"`, `"alt"`, or `"ctrl"`
- `role` is one of: `rotation`, `cc`, `defensive`, `heal`, `buff`, `movement`, `utility`
- Optional extras: `badge` (a small tag like `TBC`) and `notes` at the profile level
- For KeyKit: `summary` (one line for the list), `levels` (a band like `"1-60"`), a per-bind `command` (a WoW binding name such as `ACTIONBUTTON1`) when the action is not a spell, and a per-bind `item` (an item name such as `Hearthstone`) for items

To redraw the pictures after you edit a profile (Pillow required):

```bash
python3 scripts/render-keybinds.py --all
python3 scripts/render-keybinds.py profiles/keybinds/forever/forever-paladin-retribution-50.json -o /tmp/preview.png
```

## Applying a profile in the game: KeyKit

KeyKit is a small addon for **WoW: Forever** (its TOC also lists Classic Era and Anniversary, but the installers only copy it into Forever). It shows every profile in this folder on a keyboard, and sets the keys only when you press **Apply**.

**In the game:**

1. Install or update with `install-forever.bat` (Windows) or `install.sh --flavor _forever_` (Mac, Linux, Steam Deck). With WoW running, type `/reload` afterward, or restart WoW.
2. Type `/keykit`. A window opens with your class's profiles on the left, grouped by spec (Holy, Protection, Retribution, and so on). The step for your level is green and says **< your level**. Tick **Show all classes** to see every class.
3. Click a profile. The keyboard on the right shows what each key does. Use **Plain keys / Shift / Alt / Ctrl** to see each layer, including the mouse buttons. Keys marked *(look only)* are shown for reference and never set (OPie rings, cursor dispels).
4. **Clear these bars first** is ticked unless you untick it. Apply then empties every button on each bar the profile uses before it places the profile, so old spells don't linger. Bars the profile doesn't use are left alone. KeyKit remembers the tick.
5. Leave **Only this character** unticked to save for every character on the account. Tick it to save for this character only.
6. Press **Apply**. Each spell, item, or macro goes onto the action bar button its key fires, so the bar shows what the key does. In the wow-config layout the plain keys fire the two centre bars and Alt fires the two bars on the right. A key that fires no bar button is bound straight to the spell instead. The chat window lists any spell the character has not learned yet; those keys are skipped.
   Shift, Ctrl, and mouse keys (and Alt-H for the Hearthstone) don't get their own bar button. KeyKit binds them straight to the spell or item, so they work but don't show on a bar. If a later level leaves one of those keys empty, Apply sets it back to its wow-config binding.
7. Changed your mind? Press **Undo**. It puts back the keys and every bar button the last Apply changed or cleared, even after a `/reload`.
8. When you level up, open `/keykit` again and apply the green step. Each step includes everything from the steps before it.

KeyKit will not apply, clear bars, or undo in combat; it tells you to wait until the fight is over.

Talent spells (Holy Shock and the like) are not in the profiles on purpose. Put them on an empty key yourself.

**"Main Hand 0.0" bar across the action bars?** That is WoW: Forever's own swing timer (the Blizzard_SwingTimer UI; ElvUI only restyles it). Its on/off setting is saved per account, not in `Config.wtf`, so the kit cannot ship it. Type `/console showSwingTimer 0` once to hide it.

**Apply did nothing, or the status line shows an error?** KeyKit now prints any error in the window and in chat. Send a screenshot of it.

**Import and export.** **Export** writes your current keys on this board as text. **Import...** takes the same text and adds it to the list as your own profile (saved on this computer only). **Delete** removes one of your own profiles. The format is one line each:

```
# KeyKit 1
name = My hunter
class = hunter
levels = 10-30
note = Pet attack on Q
url = https://example.com/where-i-found-it
1 = spell Arcane Shot
ALT-1 = spell Serpent Sting
W = cmd TOGGLEAUTORUN
BUTTON4 = macro PetAttack
F = click SomeButton:LeftButton
```

Keys use WoW's names: `ALT-`, `CTRL-`, `SHIFT-` prefixes, and `BUTTON3` to `BUTTON5` for the mouse. Only `name` and one key line are required.

**Changing Ryan's keys.** Edit `profiles/source/forever-keymaps.yaml` (each class and spec lists only what changes at each level; `null` clears a key; `at_60` is the full layout at 60), then regenerate:

```bash
python3 scripts/gen-keykit-profiles.py          # YAML -> profiles/keybinds/forever/*.json -> KeyKit/Profiles.lua
python3 scripts/gen-keykit-profiles.py --check  # fails if anything is out of date, or a spec's steps don't add up to its at_60
```

Never edit the generated files in `profiles/keybinds/forever/` by hand. **Adding a profile for everyone** else works the same way: add a JSON file to `profiles/keybinds/` and run the generator.

The JSON stays the source. Never edit `Profiles.lua` by hand. Plain-English actions such as `Autorun`, `Strafe Left`, and `Bags` become WoW binding commands. Anything with a parenthesis, such as `Blessings (OPie)`, is look-only. Everything else is treated as a spell name.

Profiles from other sites carry a **source link only**. Never copy their maps in (see the PullCall section above).

### Copying everything between characters

KeyKit only sets keys. To copy bars, macros, and keybinds together, use **Myslot**. It exports everything as a pasteable string. The current addon (v6.3.0, 8 November 2026) lists WoW: Forever and its TOC includes interface **16001**. Command is `/myslot`.

- [Myslot on GitHub](https://github.com/tg123/myslot)
- [Myslot on WowAce](https://www.wowace.com/projects/myslot) (Forever is listed on the recent-files row for v6.3.0)
- [myslot.net](https://www.myslot.net/) for storing and sharing the export strings

This repo does not install Myslot for you. If you add it, get it from one of the official pages above, then fully exit and relaunch WoW so the addon loads.
