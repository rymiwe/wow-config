#!/usr/bin/env bash
# sync-forever.sh - pull the WoW: Forever layout from the repo onto THIS machine.
#
# One-way sync. BLD (the Windows main rig) is the only place Forever layout
# changes are made; its watcher (scripts/watch.ps1 -> checkpoint.ps1) commits
# and pushes them when WoW closes. The Steam Deck and ibp only PULL, with this
# script. It never commits or pushes anything.
#
# What it copies (the same short list .gitignore tracks for _forever_):
#   WTF/Account/<ACCOUNT>/SavedVariables/ElvUI.lua            ElvUI layout (see UIScale below)
#   WTF/Account/<ACCOUNT>/SavedVariables/KeyKit.lua           KeyKit settings
#   WTF/Account/<ACCOUNT>/<Realm>/<Char>/SavedVariables/KeyKit.lua
#   WTF/Account/<ACCOUNT>/bindings-cache.wtf                  keybinds
#   WTF/Account/<ACCOUNT>/<Realm>/<Char>/bindings-cache.wtf
#   Interface/AddOns/KeyKit/...                               our KeyKit addon
#
# What it never touches:
#   WTF/Config.wtf (graphics/CVars are per machine), per-character ElvUI.lua
#   (chat history), chat-cache.txt, macros, and every other addon folder
#   (ElvUI, Questie, BadBoy, OPie... - update those with update-addons.sh).
#
# UIScale: ElvUI stores the UI scale inside the account ElvUI.lua. Each
# screen needs its own (Deck 0.7111, BLD 0.6). When this script writes the
# account ElvUI.lua it keeps THIS machine's current UIScale value and only
# takes the rest of the layout from the repo.
#
# Safety:
#   - Refuses to run while WoW: Forever (Wow.exe, native or under Wine/Proton)
#     is running. WoW rewrites these files when it closes, so writing them
#     while it's open would be lost or clobbered. If it can't check (no /proc),
#     it refuses rather than guess.
#   - Before replacing a file that exists here, saves a copy under
#     _forever_/AddOnBackups/sync-<timestamp>/ (same relative path). That
#     folder is outside what git tracks.
#   - Skips files that are already identical, so running it twice in a row
#     changes nothing and makes no extra backups.
#   - --dry-run shows everything it would do and writes nothing.
#
# Usage (close WoW first):
#   scripts/sync-forever.sh
#   scripts/sync-forever.sh --dry-run
#   scripts/sync-forever.sh --wow-dir ~/Games/"World of Warcraft"
#   WOWDIR="/path/to/World of Warcraft/_forever_" scripts/sync-forever.sh
#   curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/scripts/sync-forever.sh | bash
#
# Options:
#   --wow-dir DIR   WoW folder (the one containing _forever_) or _forever_ itself.
#                   Default: $WOWDIR, else the first of DEFAULT_DIRS that exists.
#   --ref REF       Branch, tag, or commit to pull. Default: main.
#   --repo URL      Git repo to pull from. Default: this checkout's origin, else
#                   https://github.com/rymiwe/wow-config.git
#   --dry-run       Print what would happen; write nothing.
#   -h, --help      Show this help.
#
# Needs: bash, git, awk, cmp, md5sum. All present on SteamOS and Omarchy.

set -euo pipefail

DEFAULT_REPO="https://github.com/rymiwe/wow-config.git"
# Where Forever lives on our Linux machines. First one that exists wins.
DEFAULT_DIRS=(
    "$HOME/Games/World of Warcraft/_forever_"
    "$HOME/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_forever_"
)

usage() {
    # Print the header comment block (minus the shebang) as help text.
    sed -n '2,/^$/{s/^# \{0,1\}//;p;}' "${BASH_SOURCE[0]:-$0}" 2>/dev/null \
        || echo "Usage: sync-forever.sh [--wow-dir DIR] [--ref REF] [--repo URL] [--dry-run]"
}

die() { echo "ERROR: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
WOW_DIR_ARG=""
REF="main"
REPO=""
DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --wow-dir)   [[ $# -ge 2 ]] || die "--wow-dir needs a path"; WOW_DIR_ARG="$2"; shift 2 ;;
        --wow-dir=*) WOW_DIR_ARG="${1#*=}"; shift ;;
        --ref)       [[ $# -ge 2 ]] || die "--ref needs a value"; REF="$2"; shift 2 ;;
        --ref=*)     REF="${1#*=}"; shift ;;
        --repo)      [[ $# -ge 2 ]] || die "--repo needs a URL"; REPO="$2"; shift 2 ;;
        --repo=*)    REPO="${1#*=}"; shift ;;
        --dry-run|-n) DRY_RUN=1; shift ;;
        -h|--help)   usage; exit 0 ;;
        *) die "Unknown argument: $1 (try --help)" ;;
    esac
done

for tool in git awk cmp md5sum mktemp; do
    command -v "$tool" >/dev/null 2>&1 || die "'$tool' is not installed; can't continue."
done

# ---------------------------------------------------------------------------
# Find the local _forever_ folder
# ---------------------------------------------------------------------------
# Accept either the WoW root (contains _forever_) or _forever_ itself.
resolve_forever_dir() {
    local d="${1%/}"
    if [[ "$(basename "$d")" == "_forever_" && -d "$d" ]]; then
        echo "$d"
    elif [[ -d "$d/_forever_" ]]; then
        echo "$d/_forever_"
    else
        return 1
    fi
}

FOREVER=""
if [[ -n "$WOW_DIR_ARG" ]]; then
    FOREVER="$(resolve_forever_dir "$WOW_DIR_ARG")" \
        || die "--wow-dir '$WOW_DIR_ARG' is not _forever_ and has no _forever_ folder inside."
elif [[ -n "${WOWDIR:-}" ]]; then
    FOREVER="$(resolve_forever_dir "$WOWDIR")" \
        || die "WOWDIR='$WOWDIR' is not _forever_ and has no _forever_ folder inside."
else
    for d in "${DEFAULT_DIRS[@]}"; do
        if FOREVER="$(resolve_forever_dir "$d")"; then break; fi
        FOREVER=""
    done
    [[ -n "$FOREVER" ]] || die "Could not find _forever_ in the default places:
$(printf '  %s\n' "${DEFAULT_DIRS[@]}")
Pass --wow-dir \"/path/to/World of Warcraft\" or set WOWDIR."
fi
FOREVER="$(cd "$FOREVER" && pwd -P)"   # absolute, no symlinks

# A real Forever install has WTF/ once the game has been launched once.
# Without it we'd be guessing at a folder the game may not use.
[[ -d "$FOREVER/WTF" ]] \
    || die "'$FOREVER' has no WTF folder. Launch WoW: Forever once (to character select), quit, then rerun."

# ---------------------------------------------------------------------------
# Refuse while WoW is running
# ---------------------------------------------------------------------------
# Under Wine/Proton the game shows up as a normal Linux process whose command
# line contains "...\_forever_\Wow.exe" (or a Z:\ / unix path to it). We can't
# reliably map a Wine process back to a particular install, so ANY Wow.exe
# counts. WowClassic.exe (Anniversary/Era) doesn't touch _forever_, so it's
# allowed. Reads /proc directly (no pgrep) so it works on a bare SteamOS.
wow_running() {
    # Returns 0 + prints the process if a Wow.exe is running, 1 if none,
    # 2 if we can't look at all (the caller treats 2 as "refuse").
    [[ -r /proc/self/cmdline ]] || return 2
    local p pid comm arg re hit
    local -a parts
    # One command-line ARGUMENT must be the exe itself: "Wow.exe", ".../Wow.exe"
    # or "C:\...\Wow.exe" (also Wow-64.exe), any case. Whole-argument match, so
    # a shell or editor that merely mentions Wow.exe in a longer string doesn't
    # count. Does NOT match WowClassic.exe.
    re='^(.*[\\/])?wow(-64)?\.exe$'
    shopt -s nocasematch
    for p in /proc/[0-9]*; do
        pid="${p#/proc/}"
        [[ "$pid" == "$$" || "$pid" == "${BASHPID:-$$}" ]] && continue
        comm=""; hit=""
        # Processes can vanish mid-scan; ignore read errors for those.
        { read -r comm < "$p/comm"; } 2>/dev/null || true
        parts=()
        { mapfile -d '' -t parts < "$p/cmdline"; } 2>/dev/null || true
        # Wine names the process after the exe, so comm alone is enough there.
        if [[ "$comm" == "Wow.exe" || "$comm" == "Wow-64.exe" ]]; then
            hit="$comm"
        else
            for arg in "${parts[@]}"; do
                if [[ "$arg" =~ $re ]]; then hit="$arg"; break; fi
            done
        fi
        if [[ -n "$hit" ]]; then
            shopt -u nocasematch
            echo "PID $pid: ${hit:0:200}"
            return 0
        fi
    done
    shopt -u nocasematch
    return 1
}

# Note: this runs in a $(...) subshell, so the function can't exit the script
# itself; we act on its return code here instead. Anything other than a clean
# "none running" (1) stops the script: that's the fail-closed part.
wow_rc=0
running="$(wow_running)" || wow_rc=$?
case "$wow_rc" in
    1) ;;  # no Wow.exe found: safe to continue
    0) die "WoW: Forever looks like it's running. Close it, then rerun.
  $running" ;;
    *) die "Can't read /proc, so can't tell whether WoW is running. Refusing to write." ;;
esac

# ---------------------------------------------------------------------------
# Fetch the repo (shallow) into a temp folder
# ---------------------------------------------------------------------------
if [[ -z "$REPO" ]]; then
    # If this script lives in a clone, pull from that clone's origin.
    script_path="${BASH_SOURCE[0]:-}"
    if [[ -n "$script_path" && -f "$script_path" ]]; then
        script_dir="$(cd "$(dirname "$script_path")" && pwd)"
        REPO="$(git -C "$script_dir" remote get-url origin 2>/dev/null || true)"
    fi
    REPO="${REPO:-$DEFAULT_REPO}"
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/wow-forever-sync.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "== wow-config: sync WoW: Forever =="
echo "Local _forever_ : $FOREVER"
echo "Repo            : $REPO"
echo "Ref             : $REF"
[[ $DRY_RUN -eq 1 ]] && echo "Mode            : DRY RUN (nothing will be written)"
echo

SRC_REPO="$TMP/repo"
git init -q "$SRC_REPO"
if ! git -C "$SRC_REPO" fetch -q --depth 1 "$REPO" "$REF" 2>"$TMP/fetch.err"; then
    cat "$TMP/fetch.err" >&2
    die "Could not fetch '$REF' from $REPO"
fi
git -C "$SRC_REPO" -c advice.detachedHead=false checkout -q FETCH_HEAD
echo "Fetched $(git -C "$SRC_REPO" rev-parse --short HEAD): $(git -C "$SRC_REPO" log -1 --format=%s)"
echo

SRC="$SRC_REPO/_forever_"
if [[ ! -d "$SRC" ]]; then
    # Not an error: BLD hasn't pushed any Forever layout files yet.
    echo "The repo at '$REF' has no _forever_ files yet. Nothing to sync."
    exit 0
fi

# ---------------------------------------------------------------------------
# The allowlist: which repo files we copy
# ---------------------------------------------------------------------------
# Keep this in step with the _forever_ block in .gitignore. Paths are relative
# to _forever_. Globs with no match expand to nothing (nullglob).
collect_files() {
    shopt -s nullglob
    local f
    for f in \
        "$SRC"/WTF/Account/*/SavedVariables/ElvUI.lua \
        "$SRC"/WTF/Account/*/SavedVariables/KeyKit.lua \
        "$SRC"/WTF/Account/*/bindings-cache.wtf \
        "$SRC"/WTF/Account/*/*/*/bindings-cache.wtf \
        "$SRC"/WTF/Account/*/*/*/SavedVariables/KeyKit.lua; do
        [[ -f "$f" ]] && echo "${f#"$SRC"/}"
    done
    # KeyKit addon: every file in the folder, any depth.
    if [[ -d "$SRC/Interface/AddOns/KeyKit" ]]; then
        (cd "$SRC" && find Interface/AddOns/KeyKit -type f | LC_ALL=C sort)
    fi
    shopt -u nullglob
}

# Second line of defence: even if the list above were edited wrong, refuse
# anything that isn't one of the allowed shapes.
is_allowed() {
    local rel="$1"
    case "$rel" in
        WTF/Config.wtf|*/chat-cache.txt) return 1 ;;
        WTF/Account/*/*/*/SavedVariables/ElvUI.lua) return 1 ;;  # per-char ElvUI = chat history
        WTF/Account/*/SavedVariables/ElvUI.lua) [[ "$rel" != WTF/Account/*/*/*/* ]] ;;
        */SavedVariables/KeyKit.lua|*/bindings-cache.wtf) [[ "$rel" == WTF/Account/* ]] ;;
        Interface/AddOns/KeyKit/*) return 0 ;;
        *) return 1 ;;
    esac
}

# Account-level ElvUI.lua: WTF/Account/<ACCOUNT>/SavedVariables/ElvUI.lua
is_account_elvui() {
    [[ "$1" == WTF/Account/*/SavedVariables/ElvUI.lua && "$1" != WTF/Account/*/*/*/* ]]
}

# ---------------------------------------------------------------------------
# UIScale helpers (awk, line-based)
# ---------------------------------------------------------------------------
# WoW writes SavedVariables one key per line, e.g.
#   ElvDB = {
#   ["global"] = {
#   ["general"] = {
#   ["UIScale"] = 0.6,
# Strings never span lines (WoW escapes newlines), so we can track the table
# path by watching lines that open "{" and close "}". ElvUI keeps the scale at
# ElvDB.global.general.UIScale; ElvDB.global.UIScale is also accepted.
# Keys may be written ["x"], ['x'], or bare x.
#
#   mode=get : print the UIScale value text (e.g. 0.7111) or nothing
#   mode=set : print the file with that one value replaced by $val
UISCALE_AWK='
function keyof(line,   k) {
    k = line
    sub(/^[ \t]*/, "", k)
    if (k ~ /^\[/) {                      # ["key"] or [\x27key\x27] or [1]
        sub(/^\[/, "", k); sub(/\].*$/, "", k)
        gsub(/["\047]/, "", k)
        return k
    }
    sub(/[ \t]*=.*$/, "", k)              # bare key
    return k
}
function inpath(   p) {
    p = ""
    for (i = 1; i <= depth; i++) p = p "/" stack[i]
    return (p == "/ElvDB/global/general" || p == "/ElvDB/global")
}
BEGIN { depth = 0; done = 0 }
{
    line = $0
    is_scale = (line ~ /^[ \t]*(\[["\047]UIScale["\047]\]|UIScale)[ \t]*=[ \t]*[^,{]+,?[ \t]*$/)
    if (!done && is_scale && inpath()) {
        if (mode == "get") {
            v = line
            sub(/^[^=]*=[ \t]*/, "", v); sub(/[ \t]*,?[ \t]*$/, "", v)
            print v
            done = 1
            next
        } else {
            pre = line; sub(/=.*$/, "", pre)
            print pre "= " val ","
            done = 1
            next
        }
    }
    if (line ~ /=[ \t]*\{[ \t]*$/) {               # key = {
        stack[++depth] = keyof(line)
    } else if (line ~ /^[ \t]*\{[ \t]*$/) {        # array element {
        stack[++depth] = "[]"
    } else if (line ~ /^[ \t]*\}/ && depth > 0) {  # }, or }, -- [1]
        depth--
    }
    if (mode == "set") print line
}
END { if (mode == "set" && !done) exit 3 }
'

uiscale_get() { awk -v mode=get "$UISCALE_AWK" "$1"; }
uiscale_set() { awk -v mode=set -v val="$2" "$UISCALE_AWK" "$1"; }

md5_of() { if [[ -f "$1" ]]; then md5sum < "$1" | cut -c1-32; else echo "(none)"; fi; }

# ---------------------------------------------------------------------------
# Plan + copy
# ---------------------------------------------------------------------------
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$FOREVER/AddOnBackups/sync-$STAMP"
[[ -e "$BACKUP_DIR" ]] && BACKUP_DIR="$BACKUP_DIR-$$"

n_new=0; n_upd=0; n_same=0; n_skip=0; n_bak=0
SUMMARY="$TMP/summary.txt"; : > "$SUMMARY"

# Copy via a temp file in the same folder + rename, so a crash never leaves a
# half-written SavedVariables file behind.
install_file() {
    local from="$1" to="$2"
    mkdir -p "$(dirname "$to")"
    cp "$from" "$to.sync-tmp.$$"
    mv -f "$to.sync-tmp.$$" "$to"
}

mapfile -t FILES < <(collect_files)
if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "The repo has no Forever layout files yet (nothing whitelisted under _forever_)."
fi
if [[ ! -d "$SRC/Interface/AddOns/KeyKit" ]]; then
    echo "Note: the repo has no KeyKit addon at this ref; skipping KeyKit."
fi

for rel in "${FILES[@]}"; do
    if ! is_allowed "$rel"; then
        echo "SKIP (not allowlisted) $rel"
        printf '%-8s %s\n' "SKIP" "$rel  (not allowlisted)" >> "$SUMMARY"
        n_skip=$((n_skip + 1)); continue
    fi
    src="$SRC/$rel"
    dst="$FOREVER/$rel"
    want="$src"   # the content we intend to write

    # UIScale preserve for the account ElvUI.lua.
    if is_account_elvui "$rel"; then
        local_scale=""; incoming_scale=""
        [[ -f "$dst" ]] && local_scale="$(uiscale_get "$dst")"
        incoming_scale="$(uiscale_get "$src")"
        if [[ ! -f "$dst" ]]; then
            echo "UIScale: no local $rel yet; copying the repo version as-is (UIScale ${incoming_scale:-not set})."
        elif [[ -z "$local_scale" ]]; then
            echo "UIScale: local $rel has no UIScale key; copying the repo version as-is (UIScale ${incoming_scale:-not set})."
        elif [[ -z "$incoming_scale" ]]; then
            # Copying would drop this machine's scale. Keep the local file.
            echo "UIScale: repo $rel has no UIScale key; keeping the local file so its UIScale $local_scale isn't lost."
            printf '%-8s %s\n' "SKIP" "$rel  (repo copy has no UIScale; local kept)" >> "$SUMMARY"
            n_skip=$((n_skip + 1)); continue
        else
            mkdir -p "$TMP/patched/$(dirname "$rel")"
            want="$TMP/patched/$rel"
            uiscale_set "$src" "$local_scale" > "$want" \
                || die "Could not rewrite UIScale in $rel"
            if [[ "$local_scale" == "$incoming_scale" ]]; then
                echo "UIScale: local $local_scale = repo $incoming_scale; nothing to preserve."
            else
                echo "UIScale: keeping local $local_scale (repo has $incoming_scale)."
            fi
        fi
    fi

    before="$(md5_of "$dst")"
    after="$(md5_of "$want")"

    if [[ -f "$dst" ]] && cmp -s "$want" "$dst"; then
        printf '%-8s %s\n' "SAME" "$rel  $before" >> "$SUMMARY"
        n_same=$((n_same + 1)); continue
    fi

    if [[ -f "$dst" ]]; then
        bak="$BACKUP_DIR/$rel"
        if [[ $DRY_RUN -eq 0 ]]; then
            mkdir -p "$(dirname "$bak")"
            cp -p "$dst" "$bak"
            install_file "$want" "$dst"
        fi
        printf '%-8s %s\n' "UPDATE" "$rel  $before -> $after  (backup: ${bak#"$FOREVER"/})" >> "$SUMMARY"
        n_upd=$((n_upd + 1)); n_bak=$((n_bak + 1))
    else
        [[ $DRY_RUN -eq 0 ]] && install_file "$want" "$dst"
        printf '%-8s %s\n' "NEW" "$rel  (none) -> $after" >> "$SUMMARY"
        n_new=$((n_new + 1))
    fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo
if [[ $DRY_RUN -eq 1 ]]; then
    echo "== DRY RUN: would do this (md5 before -> after) =="
else
    echo "== Done (md5 before -> after) =="
fi
cat "$SUMMARY"
echo
verb=""; [[ $DRY_RUN -eq 1 ]] && verb="would be "
echo "${verb}new: $n_new   ${verb}updated: $n_upd   unchanged: $n_same   skipped: $n_skip   ${verb}backed up: $n_bak"
if [[ $n_bak -gt 0 ]]; then
    echo "Backups ${verb}in: $BACKUP_DIR"
fi
echo "Not touched: WTF/Config.wtf, per-character ElvUI.lua, chat-cache, other addons."
