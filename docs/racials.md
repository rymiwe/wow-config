# Racial abilities — TBC Classic / Anniversary

Per-racial placement intent for the `wow-class-setup` skill and class addons.

## Principle

A racial's slot is determined by **mechanical category**, not by "being a racial." Five categories:

| Category | Examples | Slot intent | Macro template |
|---|---|---|---|
| **Combat damage CD** | Blood Fury, Berserking | Alt-numrow CD cluster (Alt-3 to Alt-`) — joins class burst CDs | `self-cast` |
| **Combat CC** | War Stomp, Arcane Torrent | Mid-combat instant: **C** (Bar 3 button 10) is the cross-class racial-CC slot. Falls back to Z/B if C is taken. | none |
| **Defensive break** | Stoneform, Will of the Forsaken, Escape Artist | Alt-bottom defensive cluster (Alt-V/B), joins class defensives | `self-cast` |
| **Heal** | Gift of the Naaru | Heal slot (Alt-QERT row preferred; falls back to Alt-G if QERT full) | `mouseover-help` |
| **OOC / utility** | Shadowmeld, Cannibalize, Find Treasure, Perception | Bar 3 unbound gap, alt-bottom low-pri slot, OR IGNORE — rare-use, doesn't deserve high-value | none |

**Key rule:** if no clean slot exists for a racial in a given class layout (e.g., Hunter Alt-numrow is fully booked by spec CDs), **IGNORE** it and document — friends can drag manually if they specifically want it. Better than displacing a class ability.

## Implementation

Class addons append racial entries via `UnitRace("player")` check at addon-load time:

```lua
do
    local _, race = UnitRace("player")
    if race == "Tauren" then
        table.insert(LAYOUT, {"War Stomp", 3, 10})  -- C: combat AOE stun
    elseif race == "Orc" then
        table.insert(LAYOUT, {"Blood Fury", 4, 6, "self-cast"})  -- Alt-5: burst CD
    -- ...
    end
end
```

Untrained racials (wrong race) silently skip via SetupCore.

## Per-racial reference

### Alliance

#### Human
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Diplomacy | Passive | — | IGNORE |
| Perception | OOC toggle | Stealth detect (low-use TBC) | IGNORE |
| Sword Specialization | Passive | — | IGNORE |
| Mace Specialization | Passive | — | IGNORE |
| The Human Spirit | Passive | — | IGNORE |

Human has no combat-active racial worth a slot. All IGNORE.

#### Dwarf
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Stoneform | Defensive break | -bleed/poison/disease + 10% armor 8s, 2min CD | Alt-V or Alt-bottom defensive slot, `self-cast` |
| Find Treasure | OOC toggle | Tracking minimap | IGNORE (Hunter: add to OPie tracking ring instead) |
| Gun Specialization | Passive | — | IGNORE |
| Frost Resistance | Passive | — | IGNORE |

#### Night Elf
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Shadowmeld | OOC stealth | Drop combat OOC; "fall reset" | Alt-bottom low-pri OR IGNORE |
| Quickness | Passive | — | IGNORE |
| Wisp Spirit | Passive | — | IGNORE |
| Touch of Elune | Passive | Obsolete | IGNORE |

#### Gnome
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Escape Artist | Defensive break | Snare break, 1.75min CD | Alt-V or alt-bottom, `self-cast` |
| Expansive Mind | Passive | — | IGNORE |
| Arcane Resistance | Passive | — | IGNORE |
| Engineering Specialization | Passive | — | IGNORE |

#### Draenei (TBC only)
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Gift of the Naaru | Heal | 15s HoT friend, 1.5s cast, 3min CD | **Alt-Q** if free, else Alt-G; `mouseover-help`. Established Shaman convention: Alt-G. |
| Heroic Presence | Passive | Party hit aura | IGNORE |
| Shadow Resistance | Passive | — | IGNORE |
| Gemcutting | Passive | JC bonus | IGNORE |

### Horde

#### Orc
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Blood Fury | Combat damage CD | +25-33% AP 15s, 2min CD | Alt-numrow CD slot (Alt-3 or Alt-` if numrow full), `self-cast` |
| Hardiness | Passive | +stun resist | IGNORE |
| Axe Specialization | Passive | — | IGNORE |
| Command | Passive | +5% pet damage (Hunter-relevant) | IGNORE |

#### Tauren
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| War Stomp | Combat CC | 2s AOE stun, 8yd, 2min CD | **C (Bar 3 button 10)** — cross-class racial-CC slot |
| Endurance | Passive | +5% base HP | IGNORE |
| Cultivation | Passive | Herbalism bonus | IGNORE |
| Nature Resistance | Passive | — | IGNORE |

#### Troll
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Berserking | Combat damage CD | 10-30% haste 10s, 3min CD (HP-scaled) | Alt-numrow CD slot, `self-cast` (same slot Orc would use) |
| Da Voodoo Shuffle | Passive | -snare duration | IGNORE |
| Bow Specialization | Passive | +1% crit w/ bows (Hunter-relevant) | IGNORE |
| Beast Slaying | Passive | +5% vs beasts (Hunter-relevant) | IGNORE |
| Regeneration | Passive | +HP regen | IGNORE |

#### Undead
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Will of the Forsaken | Defensive break | Removes fear/charm/sleep, 2min CD | Alt-bottom defensive slot, `self-cast` |
| Cannibalize | OOC channel | 10s channel ~35% HP from humanoid corpse | IGNORE (rare-use, OOC) |
| Underwater Breathing | Passive | — | IGNORE |
| Shadow Resistance | Passive | — | IGNORE |

#### Blood Elf (TBC only)
| Spell | Category | Combat use | Recommended placement |
|---|---|---|---|
| Arcane Torrent | Combat CC + mana | 8yd AOE silence + restores mana, 2min CD | **C** if free (combat CC), else Alt-numrow utility slot |
| Mana Tap | Combat utility | Drain enemy mana, builds AT charge | Alt-bottom utility OR IGNORE (low-pri unless macro'd into AT) |
| Magic Resistance | Passive | — | IGNORE |
| Enchanting | Passive | — | IGNORE |

## Per-class slot conflicts

Some class layouts can't accommodate every racial's ideal slot. Pragmatic resolutions:

- **Hunter Alt-numrow** is fully booked by Steady Shot/Aimed Shot/Volley/Kill Command/Bestial Wrath. Orc/Troll Hunters: Blood Fury/Berserking → IGNORE; document manual drag.
- **Hunter Alt-Q** is Mend Pet. Draenei Hunter: Gift of the Naaru → Alt-bottom unbound slot OR IGNORE.
- **Paladin Z** is Hammer of Justice (stun). Tauren can't be Paladin in TBC, so War Stomp slot conflict is moot.
- **Druid Alt-bottom** is full of utility (dispels/Soothe/Track/NG/Barkskin/Dash). Night Elf Druid: Shadowmeld → IGNORE.

When a class addon can't cleanly place a racial, IGNORE it and add a tip print() line: `"Race: <Race>, drag <Spell> manually — no clean slot for your class layout."`

## Asog (Draenei Shaman) — established convention

Gift of the Naaru is on **Alt-G** (Bar 5 button 5) with `mouseover-help`. Documented here as the reference for Draenei classes whose Alt-QERT heal row is full.
