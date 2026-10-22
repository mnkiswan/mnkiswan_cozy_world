# Asset provenance

| Material | Source | Treatment / rights |
| --- | --- | --- |
| Mnki, Swan and couple WebP portraits | User-uploaded `MNKISWAN_Character_Consistency_Kit (1).zip` | Original images copied without edits into `assets/portraits/`; originals, contact sheet and canon lock retained in `reference/`. Supplied by the user for this project; no claim of third-party licensing or cleared commercial rights is made. |
| Character canon and machine-readable lock | Same uploaded kit | Retained unchanged. The kit's default references guide the 3D features. Alternate detailed couple reference 053 is not treated as a redesign of the default costume. |
| Full design PDF | User-uploaded `MNKISWAN_Cozy_World_Full_GDD.pdf` | Retained in `reference/`; excluded from native game exports. |
| Procedural 3D characters/world/props/icon | Original work created for this implementation | Constructed by the project GDScript mesh kit. No external model library or generated image was used. These are reviewable interpretations, not certified final character models. |
| Music, breeze/birds and action WAV files | Original mathematical synthesis written during implementation | No downloaded samples or existing game melodies. Generator preserved in `tools/generate_audio.py`. |
| Open Sans Regular | Installed Debian `fonts-open-sans` package | Redistributable font; complete supplied copyright/license notice included beside the font. |
| DejaVu Serif | Installed Debian `fonts-dejavu-core` package | Redistributable font; complete supplied copyright/license notice included beside the font. |
| Engine and export templates | Official Godot 4.7.2 stable GitHub release | Both archives verified against the release's SHA-512 manifest. Engine license/copyright information applies to native builds. See official Godot license requirements and bundled engine notice. |

Do not replace the original portraits with unrelated generated characters. When replacing procedural models, review both from front/back/side and at gameplay scale: hair mass; double spiral and attached tail; swan hood/beak/crown; long hair and feather wings; costume colors; emblem/pom-poms; skirt; socks; sneaker colors. Keep model origins at ground contact and provide simple collision independent from detailed art.
