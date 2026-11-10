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

To redraw the pictures after you edit a profile (Pillow required):

```bash
python3 scripts/render-keybinds.py --all
python3 scripts/render-keybinds.py profiles/keybinds/ryan-forever-paladin-10.json -o /tmp/preview.png
```

`--suggest '1=Holy Strike'` can overlay a Forever suggestion on a TBC picture without changing the profile itself.

## Next: applying a profile in the game

Not built yet. The next step is a small addon that reads one of these profiles and sets the action bars and keybinds on a character — the same job PaladinSetup already does for TBC, but driven by the JSON so Forever (and other classes later) can share the same source.

Until that exists, you can still copy bars, macros, and keybinds between characters with **Myslot**. It exports everything as a pasteable string. The current addon (v6.3.0, 8 November 2026) lists WoW: Forever and its TOC includes interface **16001**. Command is `/myslot`.

- [Myslot on GitHub](https://github.com/tg123/myslot)
- [Myslot on WowAce](https://www.wowace.com/projects/myslot) (Forever is listed on the recent-files row for v6.3.0)
- [myslot.net](https://www.myslot.net/) for storing and sharing the export strings

This repo does not install Myslot for you. If you add it, get it from one of the official pages above, then fully exit and relaunch WoW so the addon loads.
