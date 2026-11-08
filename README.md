<div align="center">

# Mario Is Missing! CD-ROM Deluxe (DOS), recompiled

**Mario Is Missing! CD-ROM Deluxe** (1993), The Software Toolworks,
taken apart from its shipping DOS executable and rebuilt as a native Windows program.
No DOSBox. No emulator.

<img src="docs/screenshots/castle-koopa.png" width="480" alt="Bowser's castle: a Koopaling taunts Luigi, running as recompiled native code">

</div>

## What it is

A static recompilation of `MARIO.BIN`, the game behind the CD's small
`MARIO.EXE` launcher. Its 1,936 functions, including the 197 KB of code in
its 40 Borland overlays, are lifted to C by [pcrecomp](https://github.com/sp00nznet/pcrecomp),
compiled with MSVC, and run against a small model of a 1993 PC (DOS, VGA,
EMS, mouse). The game's own code does everything else.

The SNES version is a separate project: [sp00nznet/marioismissing](https://github.com/sp00nznet/marioismissing).

**Generated source is not distributed.** You supply your own copy of the game,
and the lifted C is generated on your machine. Nothing from the game is in this
repository.

## Status: early. It boots to Bowser's castle and you can walk into the first city.

| | |
|---|---|
| Version recompiled | `MARIO.BIN`, CD-ROM Deluxe (USA), Aug 1993 |
| Functions lifted | 1,936 (40 VROOMM overlays made resident) |
| Castle, Koopaling dialogue, the cursor | ✅ |
| Mouse (absolute pointer, the game's event handler) | ✅ |
| Choosing a door, the pipe, arriving in a city | ✅ |
| City streets, map, phone, computer | first screen seen, not played |
| Sound and music (DIGPAK/MIDPAK) | no: the game runs its own silent path |
| Videos (`VIDEO/`) | untested |
| Saving and loading | untested |
| A full city, a full playthrough | not yet |
| Linux, macOS | not yet (SDL2 host present, untested; its mouse is still the old relative one) |
| Setup script, installer | not yet |

| | |
|---|---|
| ![A door](docs/screenshots/castle-door.png) | ![The pipe](docs/screenshots/castle-pipe.png) |
| Luigi at a door | Through the pipe |
| ![A city](docs/screenshots/city.png) | |
| The first city | |

## Getting started

You need the CD-ROM Deluxe disc, Python 3, CMake, Visual Studio 2022 with
C++, and a checkout of [pcrecomp](https://github.com/sp00nznet/pcrecomp)
next to this one (or `PCRECOMP_HOME` set to one).

1. Copy the CD's `MARIO` folder (all of it) into `original/mim/`.
2. Lift it: `py tools/lift.py mim`, which writes `work/mim/gen/`.
3. Build it:
   ```
   cmake -B build -A Win32
   cmake --build build --config Release
   ```
4. Run it: `build\Release\marioismissing.exe`. It is played with the mouse.

Options (`--headless`, `--keys` including `ms:CLICK@x;y`, `--shot-at`,
`--trace`) are listed at the top of [`src/main.c`](src/main.c).

## How it works

[docs/architecture.md](docs/architecture.md) is the pipeline and the machine
model (from Blake Stone). [docs/lifting.md](docs/lifting.md) is what this game
needed: Borland overlays, the 8087 emulator's segment overrides, the mouse,
and its sound drivers.

## Credits

The runtime and lifter came from the [Corridor 7 recomp](https://github.com/sp00nznet/corridor7)
and, before it, the [Blake Stone recomp](https://github.com/sp00nznet/blakestone).
[ymfm](https://github.com/aaronsgiles/ymfm) (BSD-3-Clause). See [NOTICE](NOTICE).

## License

MIT for the code in this repository; see [LICENSE](LICENSE). Mario Is Missing!
is commercial software and is not included; Mario and Luigi are Nintendo's.
