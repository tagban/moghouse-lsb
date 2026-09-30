#!/bin/bash
# assemble.sh <LandSandBoat checkout> - makes a LandSandBoat checkout MogHouse's: our modules and module
# list in it, the Discord bridge's module (from github.com/tagban/lsb-discord-bridge, BRIDGE_REF, main by
# default), and LandSandBoat's generated Lua enums (its Docker build can leave them out: see README).
# Needs git, and Python with jinja2, jsonschema and ruamel.yaml (LandSandBoat's codegen).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
LSB="$(cd "${1:?usage: assemble.sh <LandSandBoat checkout>}" && pwd)"
BRIDGE_REF="${BRIDGE_REF:-main}"

rm -rf "$LSB/modules/moghouse" "$LSB/modules/discord_bridge"
cp -a "$HERE/modules/moghouse" "$LSB/modules/moghouse"
cp "$HERE/modules/init.txt" "$LSB/modules/init.txt"

bridge="$(mktemp -d)"
git clone -q --depth 1 --branch "$BRIDGE_REF" https://github.com/tagban/lsb-discord-bridge "$bridge"
cp -a "$bridge/module/discord_bridge" "$LSB/modules/discord_bridge"
echo "discord_bridge from lsb-discord-bridge $(git -C "$bridge" rev-parse --short HEAD)"
rm -rf "$bridge"

(cd "$LSB" && python3 -m tools.codegen "$(mktemp -d)" > /dev/null)
echo "LandSandBoat's generated Lua enums: $(ls "$LSB/scripts/enum" | grep -c codegen)"
[ "$(ls "$LSB/scripts/enum" | grep -c codegen)" -gt 0 ] || { echo "ERROR: no generated enums"; exit 1; }
