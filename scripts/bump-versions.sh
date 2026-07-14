#!/usr/bin/env bash
# Bump the ## Version field in any custom-addon .toc whose addon directory
# has changes staged for commit. Auto-stages the bumped .toc so it lands in
# the same commit.
#
# Called by scripts/checkpoint.sh before commit. Safe to call standalone.

set -e

REPO_ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$REPO_ROOT"

# Find unique addon dirs with staged changes. Matches any flavor (_anniversary_,
# _classic_era_, etc.), keeping the full flavor/Interface/AddOns/<addon>/ prefix
# so the .toc path resolves correctly per flavor.
dirs=$(git diff --cached --name-only 2>/dev/null \
    | grep -oE '^_[^/]+/Interface/AddOns/[^/]+/' \
    | sort -u)

[[ -z "$dirs" ]] && exit 0

while IFS= read -r dir; do
    [[ -z "$dir" ]] && continue
    addon="$(basename "$dir")"
    toc="${dir}${addon}.toc"
    [[ -f "$toc" ]] || continue

    # Extract current version
    old_ver=$(grep -m1 -oE '^## Version:[[:space:]]*.+$' "$toc" | sed -E 's/^## Version:[[:space:]]*//; s/[[:space:]]+$//')
    [[ -z "$old_ver" ]] && continue

    # Increment last numeric component, or append .1 if version has no trailing digits.
    if [[ "$old_ver" =~ ^(.*[^0-9])([0-9]+)$ ]]; then
        new_ver="${BASH_REMATCH[1]}$((${BASH_REMATCH[2]} + 1))"
    elif [[ "$old_ver" =~ ^([0-9]+)$ ]]; then
        new_ver="$((old_ver + 1))"
    else
        new_ver="${old_ver}.1"
    fi

    # Replace and re-stage
    if command -v sed >/dev/null; then
        # Portable sed: write to a temp then move (avoids -i differences across BSD/GNU)
        tmp="$(mktemp)"
        awk -v new="## Version: $new_ver" '/^## Version:/ && !done { print new; done=1; next } { print }' "$toc" > "$tmp"
        mv "$tmp" "$toc"
        git add "$toc" 2>/dev/null
        echo "Bumped ${dir}${addon}.toc: $old_ver -> $new_ver"
    fi
done <<< "$dirs"
