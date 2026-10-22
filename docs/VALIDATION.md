# Validation record

Engine: **4.7.2.stable.official.ed1daf0bf** (official Linux x86_64).
Renderer: OpenGL Compatibility. Graphical checks used Xorg dummy display, Mesa 25.0.7 / llvmpipe software rendering on Linux. Headless tests do not start audio playback.

## Automated checks

- **81 state checks passed, 0 failed.** Includes actual gather/plant/water/harvest/care/catch/sell/buy/transfer/place/claim transactions, invalid IDs and quantities, occupied plots, no early/double harvest, daily animal output, reserved ingredients, full capacity, unaffordable purchases, save/load, mid-growth persistence, corrupted primary backup recovery, malformed schemas and a complete twelve-request playthrough ending in the festival flag.
- **25 scene/physics integration checks passed, 0 failed.** Includes keyboard-driven CharacterBody3D travel, grounding, fall/edge recovery, companion following, nearest reachable interaction selection, actual gathering, duplicate interaction, menu time pause/resume, home door transitions, camera collision retraction, upper-storey collision, fishing input timing, missed-bite recovery and repeated-reel rejection, all-region discovery, populated menus, world save/load and the visible festival gathering.
- **Startup/UI smoke passed.** Instantiates the complete world, checks more than 65 interactables and all eight villagers, visits thirteen regions, opens all major screens, enters/exits home and round-trips save data.
- **Editor import passed.** No third-party plugin or network service is required to import/play the project.

The integration suite found an inactive fishing-reel method could award an extra catch if called directly. The authoritative session method now rejects inactive fishing, and the regression check passes. An initial grounding assertion was adjusted to allow the spawn capsule to settle under gravity before checking the floor.

## Rendered review

Captured actual title, forest gameplay, character front view, market, farm, pond, garden, map, trading screen and home from Godot 4.7.2. Corrected overexposed lighting and the top-right HUD panel position. Added warm interior lights, visible fishing gear, watered-soil color feedback and full rear hair locks. Screenshots are review artifacts, not a substitute for a human playtest.

## Export validation

Windows x86_64 and Linux x86_64 release presets use the official 4.7.2 templates with embedded PCK. Both export archives and the editor binary archive were checked against the official SHA-512 manifest. The actual embedded-PCK native Linux executable passed the startup/UI/save-load smoke test after export. The native executable also rendered the title and gameplay on the virtual OpenGL display. Windows execution, GPU performance on a reference PC and Steam submission have not been tested.

Reproduce the source checks with `./tools/test.sh`. Test output is kept in `docs/test-results.txt`. The graphical capture switches are developer tools: `-- --screenshot` and `-- --gallery`. They require a real or virtual OpenGL display; they are not usable under Godot's headless dummy renderer.

No claim is made that the final commercial GDD acceptance bar is complete. See `IMPLEMENTATION.md` for production gaps and unverified behavior.
