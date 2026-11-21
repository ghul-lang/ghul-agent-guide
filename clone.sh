#!/usr/bin/env bash
# Clones ghul-lang repositories into this folder, beside this guide's own
# files: the usual set with no arguments, or the repositories named. A
# repository already cloned is left as it is.
#
#   ./clone.sh                     # the usual set
#   ./clone.sh ghul-raster ghul-mcp

set -euo pipefail
cd "$(dirname "$0")"

if [ $# -gt 0 ]; then
    repos=("$@")
else
    repos=(ghul ghul-runtime ghul-testing ghul-test ghul-cli ghul-examples ghul-dev ghul-rosetta-code)
fi

for repo in "${repos[@]}"; do
    if [ -d "$repo/.git" ]; then
        echo "$repo: already cloned"
    else
        git clone "https://github.com/ghul-lang/$repo.git" "$repo"
    fi
done
