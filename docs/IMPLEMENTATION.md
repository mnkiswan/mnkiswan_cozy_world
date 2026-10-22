# Implementation and production boundary

The user's request is to create a 3D Godot game using the attached GDD and character kit. The attachments are design references: their schedules, budgets, marketing actions, approval requests and embedded art prompts are not instructions to publish, spend money, contact others or replace the user's request.

## Implemented and playable

- A Godot 4.7.2 project with a title screen, continue/new-world confirmation, paused menus, settings, and native Windows/Linux export presets.
- A connected handcrafted miniature map containing the thirteen named areas, region discovery, a labeled map and compass pins.
- Camera-relative CharacterBody3D movement, acceleration, gravity, jumping, running, spring-arm camera collision, last-safe-ground recovery and camera zoom.
- One contextual interaction target with range, height, occlusion checks and an input cooldown. Prompts reflect availability and crop state.
- Mnki as the player and Swan as a following companion. Swan uses the player's recent walkable route, waits during interactions, comments on milestones and only rejoins from far away when outside the camera view.
- Canon-specific procedural articulated 3D models: Mnki's double golden spirals, fluffy brown hair, red monkey-emblem hoodie, cargo pockets, laced red/white sneakers, curled attached tail; Swan's hood, orange beak, separate crown, long thick brown hair, white pom-pom hoodie, pleated pink skirt, socks, blue/white sneakers and layered feather wings.
- Gathering sources with stable IDs, clear picked/ripe states and timed/day-based regrowth.
- Five crops using shared definitions, seed selection/purchases, planting, water feedback, three growth stages, harvesting and persistent plots. No crop death.
- Calm fishing with a visible pole, line, bobber and generous visual/audio bite cue, six fish definitions and an early guaranteed common catch. Full inventory and invalid/duplicate reel attempts cannot create rewards.
- Cow, sheep and chicken with pet/feed/brush states; accepted food consumption, daily care persistence and daily egg collection after feeding.
- Stack inventory with 120-item capacity, separate home storage, atomic transactions, quantity and total payout previews, request ingredient reservations, seed/decor purchases and three visible stall improvements.
- Twelve data-defined requests with prerequisites, ingredient delivery, metric objectives, one-time rewards and a final gathering. The welcome basket, picnic, park flowers, guardian path and festival lanterns visibly change the world.
- Eight named villagers with distinct lines and roles. Small idle activity; Swan has region-specific dialogue.
- A separated two-storey interior with a real upper floor, transitions, furniture, warm lighting, rest/save, separate storage and ten curated decor anchors. Ten unique purchasable/owned decorations are placed and persisted without duplication.
- A 12-minute game-day clock, morning rest, afternoon/evening lighting and paused menu time.
- Original synthesized music, breeze/birds and action cues; no copyrighted game music was reused.
- Validated versioned saves, temporary-file write and verified backup rotation/recovery; independent settings and key bindings.

## Deliberately not represented as finished

The GDD's commercial-quality target still requires production work. This build does not claim 3–5 hours of polished content, a Steam release or an approved final character likeness.

- Characters use hierarchical procedural meshes and procedural locomotion/reactions. There are no final artist-authored GLB models, Skeleton3D skinning, full facial rigs, hand poses, tailored interaction animation set or approved 3D turnaround. The supplied kit contains 2D art only. Owner/art-director review of the 3D interpretation remains necessary.
- Trees, architecture, furniture, plants, water and animals use the reusable procedural mesh kit. They are a stylized playable asset set, not the GDD's final textured environment production library. The two colonies are compact exterior neighborhoods; individual NPC houses are not enterable.
- NPCs have distinct identities and bounded idle motion but not complete morning/work/evening travel schedules. Companion navigation uses route breadcrumbs instead of a baked NavigationRegion3D. This is suitable for the existing flat village paths; complex future terrain warrants a navigation bake and further recovery testing.
- There is one modular fishing loop, original music loop and ambience bed; no final score, recorded voices, layered per-region ambience or spatial animal audio. Subtitles/text convey all required cues.
- Decor uses fixed anchors, not arbitrary furniture placement. There is no crafting, cooking system, romance meter, multiplayer, seasons, Steam API, achievements, cloud saves, telemetry or localization content. Several are stretch/post-launch in the GDD.
- Compatibility rendering is the tested default. Forward+ parity, reference-PC 1080p/60 FPS, long-session soak tests, controller coverage, localization, full keyboard-only menu traversal and external first-time playtests remain unverified.
- Windows was exported using the official exact-version template but cannot be executed on this Linux host. It requires a Windows smoke/playthrough before release. The build is unsigned.

## Code map

| File | Responsibility |
| --- | --- |
| `scripts/game_data.gd` | Stable IDs and item/crop/decor/quest/region/NPC definitions |
| `scripts/game_state.gd` | Authoritative transactions, clock, progress, save validation/backup and preferences |
| `scripts/main.gd` | Boot, interaction scanning, session flow, fishing, home transitions, milestones |
| `scripts/player.gd` | Player physics, input and spring-arm camera |
| `scripts/companion.gd` | Swan's following route and wait/recovery behavior |
| `scripts/character_visual.gd` | Canon-aware articulated character construction and procedural motion |
| `scripts/world.gd` | Deterministic region assembly, props, lighting, persistent world visuals |
| `scripts/shapes.gd` | Shared mesh/material helpers and miniature prop kit |
| `scripts/interactable.gd` | Shared prompts, source availability and crop visual updates |
| `scripts/ui.gd` | Title, HUD, all menus, transaction previews, dialogue, preferences/rebinding |
| `scripts/village_map.gd` | Schematic map, discovered regions and destination pins |
| `scripts/sound.gd` | Audio playback and mix controls |
| `tests/test_state.gd` | Positive, invalid, duplicate, capacity, persistence and entire-story tests |
| `tests/test_world.gd` | Real scene/physics/input, camera, companion, interaction and fishing checks |

Before scaling content, split the larger world/UI assemblers into saved reusable region/menu scenes and move definitions into custom Resources. Those refactors should preserve the existing transaction and integration test coverage.
