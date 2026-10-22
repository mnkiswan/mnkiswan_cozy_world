#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./tools/godot.sh --headless --editor --import --quit
export XDG_DATA_HOME="$(mktemp -d /tmp/mnkiswan-tests.XXXXXX)"
./tools/godot.sh --headless --fixed-fps 60 res://tests/playtest.tscn
./tools/godot.sh --headless --fixed-fps 60 res://tests/flight_switch.tscn
./tools/godot.sh --headless --fixed-fps 60 res://tests/ui_flow.tscn
