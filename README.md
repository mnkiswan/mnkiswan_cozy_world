# MNKISWAN · Cozy World

A playable single-player 3D woodland life game for **Godot 4.7.2 stable**. Built from the supplied full GDD and character consistency kit. Mnki explores; Swan accompanies him; a compact twelve-request story ends in a village gathering. You can continue tending the village afterward.

## Downloads

Ready-to-run packages are kept in the repository's `downloads/` folder:

- `MNKISWAN_Cozy_World_Windows_x64.zip`
- `MNKISWAN_Cozy_World_Linux_x64.zip`

The repository itself is the complete Godot 4.7.2 source project. On GitHub, use **Code → Download ZIP** to download the source without Git.

This is a complete playable **systems foundation**, not a finished commercial release. The original reference portraits are used unchanged. In-world characters are articulated procedural 3D interpretations with the canonical features; they are not final artist-approved, skinned production models. See [the scope and remaining work](docs/IMPLEMENTATION.md).

## Play

- **Windows:** unzip the Windows build and run `MNKISWAN_Cozy_World.exe`. No editor or installation required. The build is unsigned. Exported successfully; Windows execution has not been tested on this Linux machine.
- **Linux:** unzip the Linux build, run `chmod +x MNKISWAN_Cozy_World.x86_64`, then launch it. Requires an OpenGL 3.3-capable desktop. Embedded game data means there is no separate PCK file to lose.
- **Editor:** import `project.godot` in **Godot 4.7.2**, allow the asset import to complete, and press **F6/F5**. No addons, package installation, API keys, online accounts, or backend services are needed. Use F5 for the full game; F6 runs the selected scene.
- **This cloud workspace:** `./tools/godot.sh --editor` or `./tools/godot.sh` when a graphical display is available. The wrapper selects the exact downloaded engine and uses writable XDG data paths in this sandbox.

Use the **Compatibility renderer**, the tested default. Forward+ and other engine versions are not validated. Install the official 4.7.2 export templates through the Godot editor to export on another machine. Windows and Linux export presets are included.

## A first visit

1. Begin in Sunshine Forest. Walk to a berry bush; the `[E] Gather` prompt names the focused source. The bush visibly empties and regrows later.
2. Gather at least 3 berries. Open the map with **M** and pin **Village Park**. Follow the compass distance toward the park and read its request board.
3. Deliver **A welcome basket** at the board for coins and a visible basket in the park. **J** reads and tracks requests anywhere; rewards are delivered only at the board.
4. Explore the orchard, fish at the waterfall jetty, meet Thronn, or plant at the paddy field. The early requests can be done in any order.
5. At the market, choose a quantity, review its payout, and sell surplus goods. Request ingredients are reserved automatically. Buy seeds, decorations, and three visible stall upgrades.
6. Enter the treehouse at its front steps. The central home station opens rest, storage and furnishing; the east station leads upstairs. Watered crops mature during a rest. Place purchased decorations at ten curated anchors.
7. Complete eleven local requests and discover all thirteen regions, then return to the board for the final gathering. No ordinary task expires, kills a crop, or removes a friendship.

## Controls

| Action | Default |
| --- | --- |
| Move | WASD / arrow keys |
| Look | Mouse |
| Interact / reel after a bite | E |
| Jump / run | Space / Left Shift |
| Camera distance | Mouse wheel |
| Select seed | 1–5 (rice, carrot, tomato, greens, bloom) |
| Bag / journal / map | I or Tab / J / M |
| Pause or close menu | Esc |
| Cancel fishing | Esc or right-click |
| Save / hide HUD | F5 / F2 |

Settings offer rebinding, music/ambience/effects volume, sensitivity, invert Y, reduced decorative motion, larger text, fullscreen and relaxed fishing. Escape remains the menu recovery key. Menus pause the simulation and release the mouse.

## The village

All thirteen named locations are present in one connected map: Sunshine Forest; Waterfall & Ponds; Cherry Berry Maze; Flower Garden; Paddy Field; Tropical Fruit Forest; Thronn's Animal Farm; Three Guardians; Village Park; the shared two-storey Treehouse; Willow Colony; Canopy Colony; and Market Square.

Core content: 8 named villagers, 12 requests, 5 crops, 6 fish, 3 animal species, 10 furnishings, 3 stall improvements, gathering/regrowth, persistent world restoration and a day/evening cycle. Farming takes 75–140 seconds of watered game time; resting can advance it immediately. A full day lasts 12 minutes of active play. Time stops in menus. The clock is fictional village time; no real-time waiting is used.

## Saves

Manual F5, 90-second autosave during play, quest hand-ins, furnishing, resting, and save/quit write a versioned JSON save under Godot's `user://`. Settings and controls are separate. A verified previous save is retained as `.bak`; loading automatically attempts it if the primary is invalid. Failed transactions and full bags preserve their original state.

Typical paths:

- Windows: `%APPDATA%/Godot/app_userdata/MNKISWAN · Cozy World/`
- Linux: `~/.local/share/godot/app_userdata/MNKISWAN · Cozy World/`
- Prepared cloud machine: `/workspace/.runtime/data/godot/app_userdata/MNKISWAN · Cozy World/`

Tests use isolated save names and never touch `cozy_world.json`. A new-world confirmation appears when a primary or backup save exists.

## Verify and export

```sh
./tools/test.sh
./tools/godot.sh --headless --export-release 'Windows Desktop'
./tools/godot.sh --headless --export-release 'Linux Desktop'
```

Set `GODOT_BIN` to an exact 4.7.2 executable if it is installed elsewhere. The test runner preserves failing exit codes. It imports assets, runs authoritative system tests, runs actual scene/physics integration tests, then runs a startup/UI smoke test. See [validation](docs/VALIDATION.md) for the recorded results and limits.

All source files are in this checkout; none have been committed or pushed. Reference art and the full GDD are retained under `reference/`. Asset provenance is recorded in [ASSETS.md](docs/ASSETS.md).
