#!/usr/bin/env bash
# Τοπικό build μέσα σε WSL/Linux (στα Windows το Verso δεν κάνει link).
# Χρήση από Windows:  wsl -d Ubuntu -- bash ./build.sh
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
WORK="$HOME/learn-lean4-gr-build"
export PATH="$HOME/.elan/bin:$PATH"
mkdir -p "$WORK"
rsync -a --delete --exclude .lake --exclude _out --exclude .git --exclude raw "$SRC/" "$WORK/"
cd "$WORK"
rm -rf .lake/build   # τα δικά μας modules: διαβάζουν css/svg που το lake δεν παρακολουθεί
lake build
rm -rf _out
lake exe site
mkdir -p "$SRC/_out"
rsync -a --delete _out/ "$SRC/_out/"   # όχι rm: ο local server κρατά τον φάκελο ανοιχτό
echo "OK: $SRC/_out/html-multi/index.html"
