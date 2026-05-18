# TSM Groups for TBC Anniversary

Importable TradeSkillMaster groups covering Consumables, Gems, Materials, Misc, Patterns & Plans, and Gear (looted + crafted). Pre-categorized for shopping scans, posting, and crafting workflows — sensible defaults for casual players who don't want to author groups from scratch.

## Source & credit

These import strings are **MonChiSub's TBC TSM4 Group Setup**, also used by the streamer StudenAlbatroz. Published free for community use:

- **Original repo:** <https://github.com/MonChiSub/TBC-TSM_Group_Setup>
- **Author:** MonChiSub#0001
- **Mirrored here** verbatim from the upstream `Export/` directory for one-stop install convenience.

If you find them useful, star the upstream repo.

## How to import

You import each group separately into TSM via the in-game UI. There's no automated install for these — TSM's SavedVariables format is too complex to safely write to from outside the addon.

### In-game steps
1. Make sure **TradeSkillMaster** is installed (it's in the WoWUp-CF bulk import list — see main repo README).
2. In WoW, type `/tsm` to open TSM.
3. Click **Groups** in the left sidebar.
4. Click **Import / Export** → **Import String**.
5. Open one of the `.txt` files in this folder, copy the entire contents (it's one long string), paste into the import box.
6. Click **Import**.
7. Repeat for each `.txt` file you want.

If TSM throws an error during import, run `/reload` and re-check whether the group was added — sometimes it imports correctly despite the error.

### Import order (recommended)
1. **Materials.txt** — herbs, ores, bars, leather, cloth, enchanting mats. Foundational.
2. **Consumables.txt** — flasks, elixirs, food, potions, scrolls.
3. **Gems.txt** — uncut + cut gems (TBC jewelcrafting).
4. **Prospecting.txt** — dedicated ore groups for Jewelcrafting prospecting loops (new, see file for setup).
5. **Patterns-Plans.txt** — recipes, schematics, formulas, patterns.
6. **Miscellaneous.txt** — bags, BoE epics, curiosities.
7. **Gear-Looted-Crafted.txt** — biggest file (~18KB); BoE drops + crafted gear by slot.

## What's NOT included

- **Operations** (post/cancel rules, restock thresholds) — these import strings are *groups only* (item categorization). You'll still need to set up Auctioning operations yourself, or use TSM's defaults. For casual play, default operations + these groups are usually enough.
- **Profile-level settings** — UI preferences, hotkey bindings, etc. Not needed; TSM defaults are fine.

If you want a more complete out-of-box setup (groups + operations + profile), consider [ShyRai's free TBC Anniversary + Classic Era combo profile on Ko-fi](https://ko-fi.com/s/f675ff0efa) as an alternative — fuller setup, drop-in for both flavors.

## Updating

The upstream repo updates rarely. To refresh from upstream:

```bash
cd "templates/tsm-groups"
for f in Consumables Gems Materials Miscellaneous; do
  curl -sL "https://raw.githubusercontent.com/MonChiSub/TBC-TSM_Group_Setup/main/Export/$f" -o "$f.txt"
done
curl -sL "https://raw.githubusercontent.com/MonChiSub/TBC-TSM_Group_Setup/main/Export/Patterns%20%26%20Plans" -o "Patterns-Plans.txt"
curl -sL "https://raw.githubusercontent.com/MonChiSub/TBC-TSM_Group_Setup/main/Export/Gear%20%7C%20Looted%20%26%20Crafted" -o "Gear-Looted-Crafted.txt"
```
