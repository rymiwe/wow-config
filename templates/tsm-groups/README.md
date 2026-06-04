# TSM setup for TBC Anniversary

Sane, casual-friendly TradeSkillMaster defaults: **what to import**, **in what order**, and how **TSMSetup** keeps pricing consistent.

## The three layers

| Layer | What it does | Where it lives |
|-------|----------------|----------------|
| **Groups** | Which items go in Materials, Consumables, Gear, etc. | MonChiSub import strings below (pinned in this repo) |
| **Operations** | Posting, shopping, crafting rules | TSM defaults, optional public pack, or ShyRai profile — see below |
| **Pricing math** | Mat cost, craft value, DE profit, vendor floors | **TSMSetup** addon (installed by `install.sh` / `install.ps1`) |

TSMSetup runs on every login and re-applies conservative pricing even if you import new operations later. Use `/tsmsetup` to force a refresh.

## Prerequisites

1. **TradeSkillMaster** + **TSM App Helper** — install from [CurseForge](https://www.curseforge.com/wow/addons/trade-skill-master) (not auto-fetched by our installer; CurseForge auth).
2. **TSMSetup** — shipped with wow-config; enable it in the addon list on the character select screen.
3. Log in once so TSM creates its profile, then follow the steps below.

## Recommended full stack (one-time per TSM profile)

### Step 1 — Groups (MonChiSub, ~15 min)

Import each file via `/tsm` → **Groups** → **Import / Export** → **Import String**. Copy the entire `.txt` contents, paste, click Import. `/reload` if TSM errors but the group appeared.

**Order:**

1. **Materials.txt** — herbs, ores, bars, leather, cloth, enchanting mats
2. **Consumables.txt** — flasks, elixirs, food, potions, scrolls
3. **Gems.txt** — uncut + cut gems
4. **Patterns-Plans.txt** — recipes, schematics, patterns
5. **Miscellaneous.txt** — bags, BoE epics, curiosities
6. **Gear-Looted-Crafted.txt** — largest file; BoE drops + crafted gear by slot

**Prospecting** — see [Prospecting.txt](Prospecting.txt) (structure guide, not a paste import).

### Step 2 — Operations (pick one)

**Path A — Minimal (recommended for family/casual)**

- After groups import, open `/tsm` → **Operations**.
- Use TSM’s built-in operations or create simple **#Default** auctioning/shopping ops.
- Attach **#Default** (or **Sell Gear** / stackable ops) to the parent groups you imported.
- Log out and back in (or `/tsmsetup` + `/reload`). TSMSetup adds vendor floors and aligned min prices to auctioning ops.

**Path B — Fuller posting/shopping (optional)**

Import one community pack that includes operations, then let TSMSetup normalize pricing:

- [Lobotomizer1 — TBC](https://tradeskillmaster.com/classic/groups/01kg7w4474wx0paqtezyh9xss7) — “Complete TBC classic group” on the [Classic groups directory](https://tradeskillmaster.com/classic/groups)
- Site: **Add to Addon** → copy string → `/tsm` → Import (same as MonChiSub files)
- Then `/tsmsetup` + `/reload` so mat cost / vendor floors match our defaults

**Path C — Drop-in profile (groups + operations + more)**

- [ShyRai’s TBC Anniversary + Classic Era combo](https://ko-fi.com/s/f675ff0efa) — fuller than MonChiSub strings alone; use if you want a single curated profile instead of Path A.

If you use Path B or C, you may still want MonChiSub **Materials** / **Consumables** unless the pack already covers your workflow.

### Step 3 — Verify TSMSetup (~2 min)

In `/tsm` → **Settings**:

| Setting | Expected value |
|---------|----------------|
| Crafting → default material cost | `min(dbminbuyout, dbmarket)` |
| Crafting → default craft price | `0.8 * dbmarket` |
| Shopping → % source | `min(dbminbuyout, dbmarket)` |

In **Shopping** search results, you should see a **deprofit** column (destroy minus cheapest buyout) for DE sniping.

Post or scan a grey — minimum price should not fall below vendor sell (vendor floor `vendorsell/0.95+1c`).

Chat on login may show green `TSMSetup:` lines when something was updated.

## What TSMSetup enforces

- Material, destroy, and shopping % pricing: `min(dbminbuyout, dbmarket)`
- Expected sale price for crafts: `0.8 * dbmarket`
- Custom **minprice** for sniping: `max(min(dbminbuyout, dbmarket), vendorsell)`
- Auctioning min price floors on known operation names (and wraps others with vendor floor)
- Custom source **deprofit** = `ifgt(dbminbuyout,0,max(destroy-dbminbuyout,0c))`

Slash: `/tsmsetup` — re-apply without relogging.

## Source & credit (groups)

Group import strings are **MonChiSub's TBC TSM4 Group Setup** (also used by streamer StudenAlbatroz):

- **Upstream:** <https://github.com/MonChiSub/TBC-TSM_Group_Setup>
- **Mirrored here** from the upstream `Export/` directory for one-stop install.

If you find them useful, star the upstream repo.

## Updating group files from upstream

```bash
cd "templates/tsm-groups"
for f in Consumables Gems Materials Miscellaneous; do
  curl -sL "https://raw.githubusercontent.com/MonChiSub/TBC-TSM_Group_Setup/main/Export/$f" -o "$f.txt"
done
curl -sL "https://raw.githubusercontent.com/MonChiSub/TBC-TSM_Group_Setup/main/Export/Patterns%20%26%20Plans" -o "Patterns-Plans.txt"
curl -sL "https://raw.githubusercontent.com/MonChiSub/TBC-TSM_Group_Setup/main/Export/Gear%20%7C%20Looted%20%26%20Crafted" -o "Gear-Looted-Crafted.txt"
```

TSMSetup updates ship with wow-config (`wcu` / re-run installer).

## Troubleshooting

- **TSMSetup: Could not apply settings** — TSM not loaded yet; wait a few seconds or `/reload`, then `/tsmsetup`.
- **Import error but group exists** — `/reload` and check Groups tree before re-importing.
- **Operations look wrong after import** — `/tsmsetup` + `/reload`; TSMSetup only patches pricing/min floors, not group membership.
- **Anniversary vs Classic on TSM website** — use the **Classic** game filter on [tradeskillmaster.com/classic/groups](https://tradeskillmaster.com/classic/groups); Anniversary uses the same item IDs.