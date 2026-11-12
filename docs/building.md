# Building

`Setup.cmd` (`tools/setup.ps1`) runs exactly these commands; this is the same
thing by hand. The toolkit is pcrecomp `main`, pinned at commit `ef3f0da`
(`main` moves; that is the commit this game was tested with).

## Step by step

Prerequisites: Windows 10/11, Python 3.10+ (`py --version`), CMake 3.20+,
Git, and Visual Studio 2022 (or its Build Tools) with *Desktop development
with C++*. ffmpeg on `PATH` only for `--record`.

1. **The toolkit**, beside this folder, at the commit this game was tested with:
   ```
   git clone https://github.com/sp00nznet/pcrecomp ..\pcrecomp
   git -C ..\pcrecomp checkout ef3f0da
   set PCRECOMP_HOME=%CD%\..\pcrecomp
   ```
   Without `PCRECOMP_HOME`, `tools\lift.py` and CMake look for `..\pcrecomp`.
2. **Your game files**: copy the CD's `MARIO` folder, all of it, into
   `original\mim\` (so that `original\mim\MARIO.BIN` exists).
3. **Lift** (about 15 seconds):
   ```
   > py tools\lift.py mim
     overlays: 40 placed resident, 197220 bytes, 688 entries
   MARIO.BIN: DGROUP 1D77, 135 code segments, 1936 functions, 107256 instructions lifted, 860 stored code pointers, 24 extra entries, 44 switch tables
     6 undecodable targets, first: 1B5B:FFFF (in fn_1B5D0), ...
     renderer: 0 raycaster candidates, hi-res off
     107 self-modified code bytes
     unhandled instruction forms: 11 (4 kinds), ...
     -> ...\work\mim\gen (13 files, ...)
   ```
   `tools\mim_seeds.txt` lists the entry points earlier runs found only at run
   time; without them a fresh lift has 1,887 functions and the game stops at a
   garbled screen.
4. **Build** (a few minutes):
   ```
   cmake -B build -A Win32 -DPCRECOMP_HOME=%PCRECOMP_HOME%
   cmake --build build --config Release -- -m
   build\Release\selftest.exe
   ```
   Expected: `build\Release\marioismissing.exe`, and `selftest: all passed`.
5. **Play**, from this folder (it reads `original\mim` and keeps CONFIG and
   saved games in `saves\mim`):
   ```
   build\Release\marioismissing.exe
   ```
   It is played with the mouse.

The usual trip-ups: `python` opening the Microsoft Store (that is Windows'
alias placeholder; use `py`, or turn the alias off in *Settings > Apps >
Advanced app settings > App execution aliases*); a freshly installed tool not
being on `PATH` until you open a new window; and a `..\pcrecomp` on a branch
other than the tested commit (it may lift differently).

## Usage

```
build\Release\marioismissing.exe                                   # play, in a window
build\Release\marioismissing.exe --fullscreen --display crt         # fullscreen, CRT look (F11 cycles)
build\Release\marioismissing.exe --headless --seconds 40 --shot-at "35000:C:\tmp\castle.bmp"
build\Release\marioismissing.exe --headless --keys "4000:ENTER,6000:CLICK@160;100" --record run.mp4
build\Release\selftest.exe                                          # the hardware models, no game data
```

| Flag | |
|---|---|
| `--data DIR`, `--save DIR` | the game's files (default `original\mim`), CONFIG and saved games (default `saves\mim`) |
| `--headless` | no window, no audio device; time is deterministic |
| `--realtime` | headless, but on the wall clock |
| `--record OUT.mp4` | video and audio through ffmpeg |
| `--seconds N` | quit after N seconds of emulated time |
| `--keys LIST` | scripted input, `ms:KEY[+holdms],...`; `ms:CLICK@x;y` clicks the mouse |
| `--shot FILE.bmp`, `--shot-at "ms:file.bmp,..."` | the last frame at exit, or frames at emulated times |
| `--wav OUT.wav` | write the audio |
| `--mute`, `--scale N`, `--fullscreen`, `--display sharp\|pixel\|crt` | sound off, window size, fullscreen (Alt+Enter toggles), display mode |
| `--trace` | log DOS calls to stderr |

The full list is at the top of [`src/main.c`](src/main.c).

## How it fits together

Steps 1 to 4 above; `Setup.cmd` runs the same commands. How the pieces fit is
[docs/architecture.md](docs/architecture.md) (the pipeline and the machine
model, from Blake Stone); what this game needed (Borland overlays, the 8087
emulator's segment overrides, the mouse, its sound drivers) is
[docs/lifting.md](docs/lifting.md). The selftest builds without any game
data, so it builds and runs on its own.

## netlab

On [recomp-netlab](https://github.com/sp00nznet/recomp-netlab) the recipe is
`marioismissing-dos`: `netlab build marioismissing-dos`, and
`netlab check marioismissing-dos` runs the self-test as QA.
