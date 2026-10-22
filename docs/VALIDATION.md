# Validation — Wings & Friends 0.2.0

Engine: `4.7.2.stable.official.ed1daf0bf`. Desktop exports use matching official 4.7.2 release templates. Renderer: Compatibility / OpenGL 3.3.

`tools/test.sh` runs these suites with a temporary user-data directory:

- Village playtest: **54 passed, 0 failed**. Opening quests, gathering, duplicate harvest prevention, animal care, economy, invalid sales, farming, fishing, upgrades, decoration, save/load and corrupt-primary backup recovery.
- Flight/switch regression: **44 passed, 0 failed**. Outward mesh normals; both playable models; equipment ownership; shared inventory; Swan walking, takeoff, ascent, descent, hovering and landing; grounded Mnki; blocked airborne switching; paused flight; blocked menu commands; altitude and village limits; safe airborne saving; selected-character restoration; sky-feather collection, invalid IDs and duplicate-reward prevention; low-ceiling takeoff rejection; solid-ceiling collision; backup preservation after a corrupt primary.
- UI flow: title → new game → inventory, journal, map, storage, settings, pause and shops → sleep/save → title → Continue. Four assertions verify seed purchase, next-day save, title return and restored day/coins. **UI FLOW OK**.

The corruption tests deliberately produce the warning “Primary save invalid; trying backup.” This is expected and the backup assertions pass.

Rendered inspection used Xorg with Mesa llvmpipe software OpenGL at 1280×720. Character front/back/side views and in-game Mnki, Swan and flight views were captured. The screenshot gallery is generated from real scene geometry and the gameplay camera; it is not concept art. Some screenshots stage locations and restored world flags to show the content.

Windows and Linux desktop ZIPs contain embedded-PCK executables, launch/control instructions and Godot license notices. ZIP CRC integrity and SHA-256 hashes are recorded by `tools/package_release.py`. A dedicated source ZIP excludes editor caches, native builds and nested download archives.

The source ZIP was extracted to a clean directory, with its recorded executable permissions restored, then imported and tested from scratch. The same 54 + 44 checks and UI flow passed. The exported Linux binary passed `--verify-build` both headlessly and in a real OpenGL window: `switch=true takeoff=true airborne=true landed=true`. The graphical executable also saved `native_build_flight.png`. Both runs exited successfully without runtime script errors. Official release templates disable command-line scene overrides, so this in-game verification route loads the actual packaged village and tests its compiled code.

Linux is the execution-tested platform. Windows is exported with the official template but was not executed in this Linux environment. Software-renderer screenshots do not establish performance on a gaming GPU. Short graphical exits can report four engine ObjectDB cleanup leaks; headless regression suites finish without those leaks. No runtime script errors appeared in the final rendered gallery.
