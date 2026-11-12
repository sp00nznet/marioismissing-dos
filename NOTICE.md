# Notice

The MIT license in [LICENSE](LICENSE) covers what is ours in this repository:
the runtime, the lift driver, the setup scripts, the tools and the
documentation. It does not cover the game.

*Mario Is Missing! CD-ROM Deluxe* is © 1993 The Software Toolworks; Mario and
Luigi are © Nintendo. They are not ours to license. The game's executables,
data, videos and art are not in this repository and are excluded by
`.gitignore`.

- You need your own copy of the game to use any of this. Setup copies the CD's
  `MARIO` folder into `original/mim/`; the pipeline reads it from there.
- Lifted code is a derivative work of the binary it came from. Anything the
  pipeline writes into `work/` (the lifted C is `work/mim/gen/`) carries
  whatever license the original carries, not this one. The MIT grant stops at
  our own work.

## Third-party code

| Path | Upstream | Version | License |
|---|---|---|---|
| `third_party/ymfm/` | [ymfm](https://github.com/aaronsgiles/ymfm), © 2021 Aaron Giles | OPL family sources only (opl, fm, adpcm, pcm), unmodified | BSD-3-Clause, [LICENSES/BSD-3-Clause-ymfm.txt](LICENSES/BSD-3-Clause-ymfm.txt) |

It builds against, but does not include, the
[pcrecomp](https://github.com/sp00nznet/pcrecomp) toolkit (MIT). The runtime
(`src/`) and `tools/lift.py` began as the
[Corridor 7](https://github.com/sp00nznet/corridor7) recomp's, itself from the
[Blake Stone](https://github.com/sp00nznet/blakestone) recomp's; both are ours
and MIT.
