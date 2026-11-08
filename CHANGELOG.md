# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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
