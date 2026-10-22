#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./tools/godot.sh --headless --editor --import --quit
./tools/godot.sh --headless --script tests/test_state.gd
./tools/godot.sh --headless --fixed-fps 60 --script tests/test_world.gd
./tools/godot.sh --headless -- --smoke
