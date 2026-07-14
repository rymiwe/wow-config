# SoD bootstrap prompt

Season of Discovery runs on the `_classic_era_` client. To kick off the port,
launch a session there (`wowec`) and paste everything below the line as the
first message.

---

Read `../docs/agent-handoff.md` in full before doing anything - it holds this
repo's conventions, bar-layout philosophy, macro templates, workflow, and
known gotchas. Two corrections to it: (1) it predates several recent
sessions, so treat `git log --oneline -30` as the truth for recent changes
(e.g. the "in-progress pally-rd" section is stale - that shipped as the
`redirect-taunt` template); (2) project memories may live under
`C:\Users\rymiw\.claude\projects\E--Program-Files-World-of-Warcraft*\memory\`
(glob - the key suffix has varied); read `MEMORY.md` in any that exist.

**Mission:** bring the Anniversary (TBC, `_anniversary_`) custom config up on
this Season of Discovery client (`_classic_era_`, flavor `wow_classic_era`).
Infrastructure parity only - NO per-class rune curation yet; that happens in
a later pass with me in-game.

Ground rules:

- SoD = Classic Era client. Determine the Era interface version by reading an
  installed multi-flavor TOC (e.g. ElvUI's `*_Vanilla.toc`) - do not hardcode
  a number from memory.
- The custom addons skip untrained/unknown spells silently, so a straight
  copy of the TBC layouts degrades gracefully. Copy first, curate later.
- This server family has non-standard spell training levels, and SoD adds
  runes on top. Never assert spell/level facts from general knowledge -
  verify in-game with me, or caveat explicitly.
- Do NOT pre-port the Anniversary Zygor patches. Era runs a different build
  (`ZygorGuidesViewerClassic`, already installed here). Fix its bugs only as
  they actually surface.

Tasks, in order, small focused commits per the handoff workflow:

1. Copy the custom addon layer from `../_anniversary_/Interface/AddOns/` into
   `Interface/AddOns/` here: SetupCore, ElvUIFixes, QuestJunkHelper,
   GuildMotdCycler, and all nine `<Class>Setup` addons (cheap to carry even
   for classes we may not roll). Skip TSMSetup and ZygorSetup for now - their
   settings target the TBC editions; port them on request. Skip
   WeakAurasSetup unless its content is flavor-agnostic (read it and decide).
2. Set each copied TOC's `## Interface:` to the Era version (per ground rule
   1). Leave `## Version:` values as they are.
3. `.gitignore` whitelists custom addons flavor-generically
   (`!_*/Interface/AddOns/<Name>/**`), so most copies auto-track - verify
   with `git status`. Exception: QuestJunkHelper and HeyDaddy were never
   whitelisted (oversight). Add whitelist entries for them, which also brings
   the Anniversary originals under version control for the first time.
4. `scripts/bump-versions.sh` and `.ps1` only match `_anniversary_/` paths -
   extend both to `_*/` so Era addon commits get auto version bumps too.
5. Parameterize `scripts/update-addons.sh` (and `.ps1`) by flavor, or add an
   Era variant. Era still needs OPie, Questie, and BadBoy installed
   (ElvUI/WeakAuras/TSM/TomTom/Zygor Classic are already present). For
   AskMrRobot, the script scrapes the TBC section of askmrrobot.com/addon -
   check whether a Classic Era/SoD build exists at all before porting that
   part. IMPORTANT: do not change Anniversary-side behavior - the Anniversary
   install carries local patches that fresh re-downloads clobber (see git log
   around TotemTimers and AskMrRobotClassic).
6. `scripts/play.ps1` hardcodes `_anniversary_` - add a flavor parameter.
   `watch.ps1` needs no change (both clients run WowClassic.exe, so the
   checkpoint watcher already covers Era sessions).
7. Sanity-check SetupCore against the Era client: BINDINGS, CVars, and macro
   templates are client-agnostic, and the API shims (C_Container fallbacks
   etc.) already handle modern Classic clients. Grep for anything
   TBC-hardcoded and flag it (the TBC mount-item ID list is fine as-is -
   unknown IDs simply never match).
8. Push to main as you go. Do not run the Anniversary update-addons script.

When done, report: what is ready to use, what needs me in-game to finish
(ElvUI profile export/import, `/setupbars` per character, rune keybind
curation per class), and any Era-specific breakage you found. Then stop -
rune curation is a separate session with me at the keyboard.
