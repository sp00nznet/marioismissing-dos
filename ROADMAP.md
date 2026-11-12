# Roadmap

## Next
- Play a city: the map, the phone, the computer, a landmark, a question.
- Sound: model DIGPAK/MIDPAK's INT 66h interface (digitized voices, XMIDI
  music on OPL2) and stop hiding the driver files.
- The videos in `VIDEO/` (cut-scenes) and saving and loading.
- A conformance harness (REPO_RULES section 9): scripted headless runs with
  a pass/fail count against fixed milestones (castle, door, city, a
  landmark), SKIP without game data, wired as the netlab QA beside the
  self-test, and its figure in the README.
- The self-test prints a pass count rather than only "all passed".

## Then
- Build and publish the recomp-launcher installer (the workflow is manual
  while the repo is private).
- Check `--headless --record out.mp4` end to end on a test VM.
- Linux and macOS: the SDL2 host still has the relative mouse; then a real
  `setup.sh` (today it says there is none and exits).
- Window: aspect is the game's 320x240 at 4:3; check the pointer mapping in
  the pixel and CRT display modes.

## Toolkit (pcrecomp)
- The 8087-emulator override table (`decode16._EMU87_SEG`): 3 is ES.
- VROOMM overlays (`place_overlays`), and the walk past DGROUP and through
  `jmp far`.
- From Corridor 7 too: EMS, MSCDEX, DOS allocation strategies, `int86()` and
  `intr()` stubs, the absolute mouse.

## Leftovers from the fork
- `src/hires.c` and the lifter's renderer hooks are Blake Stone's; they find
  nothing here and are off. `run_generated()` is Corridor 7's scaler
  interpreter; nothing here reaches it.
