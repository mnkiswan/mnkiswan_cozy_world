# MNKISWAN: Cozy World — Wings & Friends

Godot **4.7.2**, version **0.2.0**. This revision uses the owner's uploaded Claude project as its base, retaining its village, quests and gameplay systems while adding playable character switching, Swan flight and revised character art.

## Download and play

- [Windows x64 game ZIP](https://github.com/mnkiswan/mnkiswan_cozy_world/raw/refs/heads/main/downloads/MNKISWAN_Cozy_World_Windows_x64.zip)
- [Linux x64 game ZIP](https://github.com/mnkiswan/mnkiswan_cozy_world/raw/refs/heads/main/downloads/MNKISWAN_Cozy_World_Linux_x64.zip)
- [Godot 4.7.2 source ZIP](https://github.com/mnkiswan/mnkiswan_cozy_world/raw/refs/heads/main/downloads/MNKISWAN_Cozy_World_Source_0.2.0.zip)

Extract the whole ZIP first. On Windows, run `MNKISWAN_Cozy_World.exe`; Godot is not required to play. On Linux, run `./MNKISWAN_Cozy_World.x86_64` (use `chmod +x MNKISWAN_Cozy_World.x86_64` if your extractor removes executable permissions).

To edit, extract the **source ZIP**, open Godot **4.7.2**, choose **Import**, select `project.godot`, then press **F5**. Both desktop export presets are included; install the matching 4.7.2 export templates to build locally. The Compatibility renderer supports OpenGL 3.3 hardware.

## Controls

| Input | Action |
| --- | --- |
| WASD / arrows | Move relative to the camera |
| Mouse / wheel | Look around / zoom |
| C | Switch between Mnki and Swan on the ground |
| F, as Swan | Take off; toggle landing / hover while airborne |
| Space | Jump on foot; rise while flying |
| Ctrl | Descend while flying |
| Shift | Run / fly faster |
| E | Talk, gather, farm, fish and interact |
| R | Change seed |
| Tab / I, J, M | Inventory, journal, map |
| Esc | Pause or close a menu; cancel fishing |

Actions can be rebound in Settings. Flight has no stamina penalty. Release movement to hover; press F for a gentle landing. Land before switching. Mnki waits on the ground while Swan flies and rejoins after she lands. Low ceilings block takeoff, solid roofs stop ascent, and flight stays within the village boundary and a 24 m altitude limit.

Follow the six gold sky-feather rings. Each pays five coins once; finishing the route pays twenty more and adds a journal note. Remaining feathers appear on the map. This optional route does not replace the village story.

Both characters share inventory, coins, quests and tools. Saves remember the selected character; saving during flight records the last safe ground position. Existing saves from the uploaded Claude build default to Mnki when they lack a character field. Saves from the earlier, different Codex prototype are not migrated.

## What's changed

![Revised Mnki and Swan character models](docs/screenshots/char_preview_three.png)

![Swan flying in the village](docs/screenshots/swan_flying.png)

- Both Mnki and Swan are playable, with one camera/input owner and the other character as companion.
- Swan has controllable, collision-aware flight, expanding feather wings, banking, hovering and landing. The HUD shows character, flight controls and altitude.
- Curved hair locks, curled ends on Swan's long hair, layered feathers, an open hood shell, pleated skirt geometry, richer eyes, facial details, cuffs, thumbs and crossed sneaker laces. Their signature accessories and outfits remain intact.
- Softer materials, improved close-up shadows, muted terrain, distant hills and drifting clouds.
- Fishing pauses while menus are open. Saves protect the last valid backup from a corrupt primary. Interaction height is revalidated at use time. Cosmetic gestures no longer block takeoff or movement.
- The uploaded project's thirteen regions, farming, fishing, animal care, trading, home decoration, quests, journal, settings and day cycle remain available.

## Development and verification

```bash
GODOT_BIN=/path/to/Godot_v4.7.2-stable_linux.x86_64 ./tools/test.sh
./tools/build.sh
```

Tests use temporary save directories. `tests/playtest.tscn` covers the village gameplay loop, `tests/flight_switch.tscn` checks physics and persistence, and `tests/ui_flow.tscn` exercises title → game → save → Continue. See [validation](docs/VALIDATION.md) and [revision notes](docs/REVISION.md).

For a packaged Linux smoke check, use a temporary save directory:

```bash
XDG_DATA_HOME=$(mktemp -d) ./MNKISWAN_Cozy_World.x86_64 --headless --fixed-fps 60 -- --verify-build
```

It loads the village, switches to Swan, flies and lands, then exits with a success/failure status. Without `--headless`, it also writes a `build-flight.png` screenshot in that temporary Godot user-data folder.

This is a playable procedural 3D build. Character models are stylized meshes built in code, not artist-authored, skinned production models. Their geometry and animation remain editable in `scripts/art/`. Windows exports are provided; execution testing was performed on Linux.

Character designs and supplied reference art belong to the MNKISWAN creator. Godot's MIT license and third-party notices are included in `docs/` and the game ZIPs.
