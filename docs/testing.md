# Testing

There is no conformance harness against the game yet ([ROADMAP.md](../ROADMAP.md)).
What there is:

## The self-test

`tests/selftest.c` builds without game data and checks the hardware models:
the VGA, the x87 and the Sound Blaster/AdLib.

```
> build\Release\selftest.exe
selftest: all passed
```

netlab's QA for the `marioismissing-dos` recipe is this self-test.

## Headless runs

`--headless` runs with no window and no audio device, on deterministic
emulated time, so a scripted run lands on the same frame every time:

```
build\Release\marioismissing.exe --headless --seconds 40 --shot-at "35000:castle.bmp"
build\Release\marioismissing.exe --headless --keys "4000:ENTER,6000:CLICK@160;100" --record run.mp4
```

- `--keys "ms:KEY[+holdms],..."` presses keys at emulated times;
  `ms:CLICK@x;y` clicks the mouse at a 320x200 position.
- `--shot-at "ms:file.bmp,..."` saves frames at emulated times; `--shot` the
  last one.
- `--record out.mp4` pipes video and audio to ffmpeg (on `PATH`).
- `--realtime` keeps headless but on the wall clock.

The screenshots in `docs/screenshots/` were taken this way.
