# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `Setup.cmd` (`tools/setup.ps1`): checks and offers to install the tools,
  copies the CD's `MARIO` folder, fetches pcrecomp at the tested commit,
  lifts, builds, runs the self-test and leaves a shortcut. Tested from a
  clean clone.
- `launcher/launcher.json` for recomp-launcher, and an installer workflow
  (manual only while the repo is private).
- `tools/mim_seeds.txt`: the run-time entry points earlier runs recorded, read
  by `tools/lift.py`, so a fresh clone lifts all 1,936 functions and reaches
  the castle without play-and-relift rounds.
- A recomp-netlab recipe (`marioismissing-dos`) with the self-test as QA.

- `CONTRIBUTING.md`, `CONTRIBUTORS.md`, `docs/building.md` (step by step,
  the command line, netlab) and `docs/testing.md` (the self-test, headless
  runs).
- `setup.sh`, which says there is no Linux or macOS build yet and exits.

### Changed
- Builds against pcrecomp main; Setup and the launcher no longer pin
  commit `ef3f0da`.
- README in the redalert2-recomp section order; the step by step and the
  command line moved to `docs/building.md`.
- `NOTICE` is now `NOTICE.md`: what the MIT license covers and what it
  doesn't, and a table of the third-party code (ymfm).

## [0.1.0] - 2026-11-08

### Added
- First playable: `MARIO.BIN` (CD-ROM Deluxe) lifted to C, 1,936 functions
  including its 40 Borland VROOMM overlays, made resident. It boots to
  Bowser's castle; the Koopaling talks; clicking a door walks Luigi through
  the pipe to the first city.
- Lifter: VROOMM overlays (segment-table fixups, stub entries as far jumps,
  unaligned and overlapping stubs); Borland 8087-emulator segment overrides
  read as ES for `3`; stubs for near calls into nothing.
- Runtime: an absolute mouse with press counts and the game's event handler;
  Borland `intr()` stubs; DOS mkdir/rmdir; no sound card (the game's silent
  path).
- `docs/lifting.md`.
