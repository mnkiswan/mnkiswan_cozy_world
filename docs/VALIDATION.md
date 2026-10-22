# Validation — Living Village 0.3.0

Engine: `4.7.2.stable.official.ed1daf0bf`. Desktop exports use matching official 4.7.2 release templates. Renderer: Compatibility / OpenGL 3.3.

`tools/test.sh` runs these suites with a temporary user-data directory:

- Parse/load check: **88 scripts and scenes, 0 failures**. The test runner also rejects runtime script errors even when Godot returns exit code zero, and bounds each test process to three minutes.

- Village playtest: **54 passed, 0 failed**. Opening quests, gathering, duplicate harvest prevention, animal care, economy, invalid sales, farming, fishing, upgrades, decoration, save/load and corrupt-primary backup recovery.
- Flight/switch regression: **44 passed, 0 failed**. Outward mesh normals; both playable models; equipment ownership; shared inventory; Swan walking, takeoff, ascent, descent, hovering and landing; grounded Mnki; blocked airborne switching; paused flight; blocked menu commands; altitude and village limits; safe airborne saving; selected-character restoration; sky-feather collection, invalid IDs and duplicate-reward prevention; low-ceiling takeoff rejection; solid-ceiling collision; backup preservation after a corrupt primary.
- UI flow: title → new game → inventory, journal, map, storage, settings, pause and shops → sleep/save → title → Continue. Four assertions verify seed purchase, next-day save, title return and restored day/coins. **UI FLOW OK**.
- Village-life regression: **195 passed, 0 failed**. Thirteen gathering places, 39 activities, 23 villagers, all 13 host spawn locations clear of scenery, all 39 standing approaches clear, all 39 activities selectable by the actual keyboard interaction scanner; first/double/day-reset rewards; completed prop visibility; saved world-state round trip; accept/decline dialogue callbacks; out-of-reach rejection; all-region keepsake; idle threshold and two speakers; movement/menu/flight/settings interruption; cooldown and non-repetition; switched character identity; NPC menu pause and wall avoidance; cancelled, first and repeated friendship visits.

The corruption tests deliberately produce the warning “Primary save invalid; trying backup.” This is expected and the backup assertions pass.

Rendered inspection used Xorg with Mesa llvmpipe software OpenGL at 1280×720. All thirteen gathering places, the actual idle-conversation card, and the evening market were captured using `tests/living_gallery.tscn`. These are real scene renders, not concept art; overview captures use a staged review camera and character positions. Earlier character and flight screenshots remain available. Collision checks caught a pond approach obstructed by a rock; the gathering place was moved. The existing walking regression caught a flowering tree near the movement test's clearing; that tree was moved and the full suite passed again.

Windows and Linux desktop ZIPs contain embedded-PCK executables, launch/control instructions and Godot license notices. ZIP CRC integrity and SHA-256 hashes are recorded by `tools/package_release.py`. A dedicated source ZIP excludes editor caches, native builds and nested download archives.

The source ZIP was extracted to a clean directory, with recorded executable permissions restored, then imported and tested from scratch: **88 files loaded, 54 + 44 + 195 assertions passed, UI FLOW OK**. The packaged Linux executable also passed the headless `--verify-build` check: **switch=true, takeoff=true, airborne=true, landed=true, world=true, activity=true**. Official release templates disable command-line scene overrides, so this check loads the actual packaged village and exercises its exported code. Tests use disposable user-data directories.

The packaged executable passed the same six checks in a real OpenGL window and produced `native_build_flight.png`. Final ZIPs contain the tested code; validation prose and screenshots were updated after the clean-source run. ZIP CRCs and SHA-256 hashes were regenerated after that documentation update.

Linux is the execution-tested platform. Windows is exported with the official template but was not executed in this Linux environment. Software-renderer screenshots do not establish performance on a gaming GPU. The graphical native smoke test reported six ObjectDB instances at process cleanup, after successful checks; headless regression suites finish without that cleanup warning. The display driver also reports that changing V-Sync is unsupported. Neither the final rendered gallery nor the packaged smoke tests reported runtime script errors.
