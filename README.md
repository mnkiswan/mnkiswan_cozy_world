# MNKISWAN: Cozy World — Living Village

Godot **4.7.2**, version **0.3.0**. Explore thirteen connected regions with **23 villagers, 39 new activities, flowering scenery, and quiet conversations between Mnki and Swan**. Both characters remain playable, and Swan can fly. This continues the owner's uploaded Claude project and the Wings & Friends revision.

## Download and play

- [Windows x64 game ZIP](https://github.com/mnkiswan/mnkiswan_cozy_world/raw/refs/heads/main/downloads/MNKISWAN_Cozy_World_Windows_x64.zip)
- [Linux x64 game ZIP](https://github.com/mnkiswan/mnkiswan_cozy_world/raw/refs/heads/main/downloads/MNKISWAN_Cozy_World_Linux_x64.zip)
- [Godot 4.7.2 source ZIP](https://github.com/mnkiswan/mnkiswan_cozy_world/raw/refs/heads/main/downloads/MNKISWAN_Cozy_World_Source_0.3.0.zip)

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

![Mnki and Swan sharing a quiet moment](docs/screenshots/life_conversation.png)

[See all thirteen locations and the evening market](docs/screenshots/LIVING_VILLAGE.md).

- Thirteen gathering places with new hosts, open pergolas, striped awnings, hanging lights, climbing leaves, and flower borders.
- **39 activities**: share tea, tend flowers, arrange gift baskets, refill bird feeders, turn waterwheels, light lanterns, and play chimes. Props change when used. Each activity rewards two coins once per day; repeats remain available without extra rewards.
- **23 villagers** in total. New hosts stroll, greet you, explain their activities, offer wisdom, and remember the days you stop to chat. Capsule sweeps keep villagers from walking straight through scenery; blocked routes wait rather than teleport.
- Stay still together on the ground for **35 seconds** to begin an occasional, two-way conversation about love, kindness, rest, and the place you're visiting. Movement, camera input, menus, flight, or switching interrupt it. Conversations leave controls active, use the correct character portraits, and have a long cooldown. Disable them in Settings → Gameplay & Display.
- **Map:** teal diamonds mark gathering places. **Journal → Village life:** track activities and friendship visits. Collect all 39 memories for a shared keepsake entry.
- Flowering trees, petal beds, textured earth paths, staggered waterfall cliffs, lily pads, rice-drying racks, hay bundles, candle paths, lane lanterns, and batched pollen/fireflies.

The uploaded video exceeded the attachment tool's **32 MiB transfer limit**, so its frames could not be inspected. These additions follow the user's requested direction and the existing thirteen-region design; they are not a reconstruction of unseen video scenes. See [Living Village notes](docs/LIVING_VILLAGE.md) for scope and implementation details.

The previous revision's character and flight improvements remain:

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

Tests use temporary save directories. The original gameplay, flight/switch, and UI suites remain. `tests/village_life.tscn` adds **195 passing checks**, including all 39 standing approaches and keyboard-focus targets, daily rewards, cancellation, persistence, conversation interruption, friendship visits, and NPC collision avoidance. The runner also loads every script/scene and rejects runtime script errors. See [validation](docs/VALIDATION.md) and [earlier revision notes](docs/REVISION.md).

For a packaged Linux smoke check, use a temporary save directory:

```bash
XDG_DATA_HOME=$(mktemp -d) ./MNKISWAN_Cozy_World.x86_64 --headless --fixed-fps 60 -- --verify-build
```

It loads the village, switches to Swan, flies and lands, checks the 39 activities and 23 villagers, and completes an activity before exiting with a success/failure status. Without `--headless`, it also writes a `build-flight.png` screenshot in that temporary Godot user-data folder.

This is a playable procedural 3D build. Character models are stylized meshes built in code, not artist-authored, skinned production models. Their geometry and animation remain editable in `scripts/art/`. Windows exports are provided; execution testing was performed on Linux.

Character designs and supplied reference art belong to the MNKISWAN creator. Godot's MIT license and third-party notices are included in `docs/` and the game ZIPs.
