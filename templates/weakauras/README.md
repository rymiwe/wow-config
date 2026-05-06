# WeakAura templates

Import strings for WeakAuras shipped with this config. Each `*.wa.txt` file contains a single base64-encoded WA import string (starts with `!WA:2!`).

## Install one

```powershell
notepad "templates\weakauras\<file>.wa.txt"
```

In Notepad: Ctrl+A, Ctrl+C. Then in WoW: `/wa` → **Import** → Ctrl+V → confirm.

## What's here

| file | source | purpose |
|---|---|---|
| `lightning-shield.wa.txt` | [wago.io/OPRZeg-u6](https://wago.io/OPRZeg-u6) | Shev's Water/Lightning Shield reminder. Auto-picks the right shield by spec; alerts when missing. |

## Building your own (Bandage reminder example)

Some WAs are too niche to find pre-made. Here's how to build a "remind to bandage when out of combat + first aid off cooldown + HP low" aura in 5 minutes:

1. `/wa` → **+ New** → **Icon**
2. **Display** tab: pick the Heavy Linen Bandage (or whatever bandage) icon
3. **Trigger 1** (Combat State):
   - Type: Status
   - Event: Conditions → Combat
   - State: not in combat
4. **Trigger 2** (Health):
   - Type: Status
   - Event: Health
   - Health between 1% and 90%
5. **Trigger 3** (Bandage CD ready):
   - Type: Status
   - Event: Cooldown Progress (Spell)
   - Spell: `Recently Bandaged` (spell ID 11196) — alert when this debuff is NOT active
   - OR use Spell ID 18610 (Heavy Silk Bandage) cooldown check
6. **Trigger Combination**: All triggers must be true
7. **Conditions**: optional — add a sound/glow when shown

After tweaking, you can `/wa` → right-click your aura → **Export** → copy the string, drop it in `templates/weakauras/bandage-reminder.wa.txt`, and we'll add it to this table.
