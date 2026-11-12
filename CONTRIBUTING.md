# Contributing

Issues and pull requests are welcome.

## The one rule

**Nothing from the game goes in the repository.** No game files (`original/`),
no lifted C (`work/mim/gen/`), no disassembly listings, nothing generated from
`MARIO.BIN`. The tool ships; its output is made on each person's machine from
their own copy. `.gitignore` covers the usual paths; check `git status` before
you commit anyway. Screenshots of the game running are fine.

## Where your code comes from

Write it from the game's behavior, hardware documentation and our own tools.
Don't port code from GPL projects (DOSBox, MAME, Wine and the like) or from
anything without a license; see the license rules in [NOTICE.md](NOTICE.md).

## Before a pull request

1. Lift and build from clean ([docs/building.md](docs/building.md)):
   `py tools\lift.py mim`, then `cmake --build build --config Release`.
2. Run the self-test and a headless run ([docs/testing.md](docs/testing.md)):
   ```
   build\Release\selftest.exe
   build\Release\marioismissing.exe --headless --seconds 40 --shot-at "35000:castle.bmp"
   ```
   The self-test must print `selftest: all passed`, and the shot must show
   Bowser's castle.

## Where a fix belongs

- A bug in the 16-bit lifter, the overlay handling or the CPU model belongs in
  [pcrecomp](https://github.com/sp00nznet/pcrecomp), not here.
- The PC model (DOS, VGA, EMS, mouse, sound) lives here in `src/`, and a fix
  to the game's own quirks goes in `tools/lift.py`, with a comment that says
  what it fixes and why.
- A wall you got past goes in `docs/lifting.md`: what it looked like, what it
  was, what moved it.
