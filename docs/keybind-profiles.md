# Keybind pictures

These are pictures of our paladin keyboards — the same idea as a Steam controller community profile. You can see which ability sits on which key, including the Alt layer and the side mouse buttons, without opening the game.

Pictures live next to the profiles that generate them:

- [Ryan — Paladin (TBC Anniversary)](../profiles/keybinds/renders/ryan-paladin-anniversary.png)
- [Ryan — Forever Paladin (level 10)](../profiles/keybinds/renders/ryan-forever-paladin-10.png)

Colors are the same on every picture:

| Color | Meaning |
|-------|---------|
| Gold | Rotation (the buttons you press most in a fight) |
| Coral | Crowd control and interrupts |
| Blue | Defensives |
| Green | Heals and dispels |
| Purple | Buffs (seals, blessings, auras) |
| Slate | Movement |
| Teal | Utility (bags and similar) |

## Ryan's paladin layouts

Both pictures use the same left-hand feel from the wow-config bindings template: **A/D strafe**, **W autorun** (you still move forward by holding both mouse buttons), combat keys around WASD, **Shift does not change the ability** (it only blocks accidental action-bar paging; Shift-B still opens bags), and **Alt is the second layer**.

**TBC Anniversary** is what PaladinSetup will put on the bars today. Crusader Strike, Avenger's Shield, Avenging Wrath, and Righteous Defense are marked **TBC** — they do not exist in WoW: Forever.

**Forever, level 10** is the same philosophy with early Forever spells only. **Holy Strike sits on 1**, the slot Crusader Strike uses in TBC. Empty keys are left empty on purpose, so later spells (Consecration, Flash of Light, and so on) can land in their usual homes as you level. This profile is a picture and a plan. PaladinSetup does not apply a Forever layout in-game yet.

A few things are deliberately not on the keyboard picture:

- Righteous Fury and Redemption live on the click-only utility bar (Bar 10)
- Divine Favor is click-only
- Questie opens on the semicolon key, off the left-hand cluster
- Racials are per-character (Draenei Alt-G, Dwarf Alt-Z, Blood Elf Arcane Torrent on C)

## Why there is no PullCall map here

PullCall publishes first-login key layouts, including Forever paladin pages we looked at while researching:

- [Forever Paladin, level 10](https://pullcall.com/forever/key-bindings/paladin/10)
- [Forever Paladin, level 60 Retribution](https://pullcall.com/forever/key-bindings/paladin/60/retribution)

We did **not** copy those maps into this repo.

PullCall's [Terms of Service](https://pullcall.com/legal/terms) (version 1.1, effective 29 October 2026) say the Service — including the website — belongs to PullCall, and the terms give you only a personal, non-transferable right to use it: “They do not give you any other rights in the Service.” The [Acceptable Use Policy](https://pullcall.com/legal/aup) also says not to scrape the Service. [robots.txt](https://pullcall.com/robots.txt) allows crawlers to fetch `/forever/` and `/classic/`, but that is not a license to republish the layouts.

If you want to compare, open the PullCall pages above in a browser.

## What's in a profile

Each layout is a JSON file in `profiles/keybinds/`. The shape is small on purpose:

```json
{
  "id": "ryan-forever-paladin-10",
  "class": "paladin",
  "level": 10,
  "spec": null,
  "source": { "name": "wow-config", "url": "https://github.com/rymiwe/wow-config", "credit": "Ryan Weiss" },
  "binds": [
    { "key": "1", "mod": null, "action": "Holy Strike", "role": "rotation" },
    { "key": "1", "mod": "alt", "action": "Holy Light", "role": "heal" }
  ]
}
```

- `id`, `class`, `level`, `spec`, and `source` (with `url` and `credit`) describe the profile
- Each bind is `{ key, mod, action, role }`
- `action` is a spell name or a binding name (`Autorun`, `Strafe Left`, `Bags`)
- `mod` is `null`, `"shift"`, `"alt"`, or `"ctrl"`
- `role` is one of: `rotation`, `cc`, `defensive`, `heal`, `buff`, `movement`, `utility`
- Optional extras: `badge` (a small tag like `TBC`) and `notes` at the profile level
- For KeyKit: `summary` (one line for the list), `levels` (a band like `"1-60"`), and a per-bind `command` (a WoW binding name such as `ACTIONBUTTON1`) when the action is not a spell

To redraw the pictures after you edit a profile (Pillow required):

```bash
python3 scripts/render-keybinds.py --all
python3 scripts/render-keybinds.py profiles/keybinds/ryan-forever-paladin-10.json -o /tmp/preview.png
```

`--suggest '1=Holy Strike'` can overlay a Forever suggestion on a TBC picture without changing the profile itself.

## Applying a profile in the game: KeyKit

KeyKit is a small addon for **WoW: Forever** (its TOC also lists Classic Era and Anniversary, but the installers only copy it into Forever). It shows every profile in this folder on a keyboard, and sets the keys only when you press **Apply**.

**In the game:**

1. Install or update with `install-forever.bat` (Windows) or `install.sh --flavor _forever_` (Mac, Linux, Steam Deck). With WoW running, type `/reload` afterward, or restart WoW.
2. Type `/keykit`. A window opens with the profiles on the left.
3. Click a profile. The keyboard on the right shows what each key does. Use **Plain keys / Shift / Alt / Ctrl** to see each layer, including the mouse buttons. Keys marked *(look only)* are shown for reference and never set (OPie rings, cursor dispels).
4. Leave **Only this character** unticked to save for every character on the account. Tick it to save for this character only.
5. Press **Apply**. Each spell, item, or macro goes onto the action bar button its key fires, so the bar shows what the key does. In the wow-config layout the plain keys fire the two centre bars and Alt fires the two bars on the right. A key that fires no bar button is bound straight to the spell instead. The chat window lists any spell the character has not learned yet; those keys are skipped.
6. Changed your mind? Press **Undo**. It puts back the keys and the bar buttons the last Apply changed, even after a `/reload`.

KeyKit will not apply or undo in combat; it tells you to wait until the fight is over.

**Applied the first KeyKit version already?** It bound keys straight to spells, which left the bars empty. Press **Apply** again: keys that point at a spell are moved back to their bar button (from `templates/_forever_/bindings-cache.wtf`) and the spell goes on the bar.

**"Main Hand 0.0" bar across the action bars?** That is WoW: Forever's own swing timer (the Blizzard_SwingTimer UI; ElvUI only restyles it). Its on/off setting is saved per account, not in `Config.wtf`, so the kit cannot ship it. Type `/console showSwingTimer 0` once to hide it.

The two **Starter** profiles work for any class. Every key points at an action bar slot, so you drag your spells onto the bar and the keys follow. The one-bar starter puts the main bar on 1-4, Q, E, R, F, C and mouse buttons 3-5, with A/D strafe. The Alt-layer starter adds the bottom-left bar on Alt plus the same keys.

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

**Adding a profile for everyone.** Add a JSON file here, then regenerate the addon's profile list:

```bash
python3 scripts/gen-keykit-profiles.py          # writes _forever_/Interface/AddOns/KeyKit/Profiles.lua
python3 scripts/gen-keykit-profiles.py --check  # fails if Profiles.lua is out of date
```

The JSON stays the source. Never edit `Profiles.lua` by hand. Plain-English actions such as `Autorun`, `Strafe Left`, and `Bags` become WoW binding commands. Anything with a parenthesis, such as `Blessings (OPie)`, is look-only. Everything else is treated as a spell name.

Profiles from other sites carry a **source link only**. Never copy their maps in (see the PullCall section above).

### Copying everything between characters

KeyKit only sets keys. To copy bars, macros, and keybinds together, use **Myslot**. It exports everything as a pasteable string. The current addon (v6.3.0, 8 November 2026) lists WoW: Forever and its TOC includes interface **16001**. Command is `/myslot`.

- [Myslot on GitHub](https://github.com/tg123/myslot)
- [Myslot on WowAce](https://www.wowace.com/projects/myslot) (Forever is listed on the recent-files row for v6.3.0)
- [myslot.net](https://www.myslot.net/) for storing and sharing the export strings

This repo does not install Myslot for you. If you add it, get it from one of the official pages above, then fully exit and relaunch WoW so the addon loads.
