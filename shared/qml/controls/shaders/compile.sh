#!/usr/bin/env bash
# Run in a VM or CI. Rebuild only the portable liquid-surface shader pair.
set -euo pipefail
cd "$(dirname "$0")"
PATH="$PATH:/usr/lib/qt6/bin"
for stage in vert frag; do
    qsb --qsbversion 64 --qt6 -o "liquid_surface.$stage.qsb" "liquid_surface.$stage"
done
