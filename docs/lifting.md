# Lifting Mario Is Missing!: what it took

The runtime and lifter came from Corridor 7, which came from Blake Stone, so
DOS, VGA, EMS and the Borland startup were already there. What follows is
everything this game needed on top, in the order it turned up.

## 1. MARIO.EXE is a launcher; the game is MARIO.BIN

`MARIO.EXE` loads the sound drivers and execs `MARIO.BIN`. That one is lifted.

## 2. Borland VROOMM overlays

The resident image is 192 KB. Another 197 KB of code follows it in an `FBOV`
block: 40 overlays, paged in at run time by Borland's overlay manager.

```
FBOV header:  'FBOV'  dd size  dd file offset of the segment table  dd entries
stub segment: +00 CD 3F  +04 dd code offset in FBOV  +08 dw code size
              +0A dw fixup bytes  +0C dw entries  +20 entries: CD 3F <dw off> 00
```

`place_overlays()` in `tools/lift.py` does once what the manager does each
time it loads one. Every overlay gets a fixed home in upper memory that
nothing else uses (C000–DFFF, F100–FFEF, and B000–B7FF), and every stub entry
becomes `jmp far home:offset`. The lifter then sees one resident program, and
INT 3Fh never fires. What it took to get right:

- **Fixups are segment-table offsets, not segments.** An overlay's fixup word
  holds `entry * 8` into the segment table the FBOV header points at, and the
  entry's first word is the paragraph. Read as segments, 96% of the overlays'
  far calls landed mid-instruction; through the table, 96% land on a prologue
  or a stub entry.
- **The lifter's walk ended at DGROUP and at `jmp far`.** Both are true of a
  plain Borland program and false here.
- **Stub headers and entry tables are data**, except the entries themselves.
  A one-entry stub's entry can share its bytes with the next stub's header
  (`1C6B:0020` is `1C6D`'s first five), so entries win.
- A sign-extended imm8 that overlaps a `cs:` write is code and data sharing
  bytes (the far heap keeps DS in its code segment, under a long decode). The
  constant is kept, and the lifter says so.

## 3. The 8087 emulator's segment override

Borland emits x87 code as `INT 34h`–`3Dh`. `CD 3C xx` is an x87 op with a
segment override, with the segment in the top two bits of `xx`. pcrecomp read
`3` as DS. All 54 in `MARIO.BIN` are `3`, and all follow `pop es` or `les`,
so `3` is ES. With DS, an `fstp` into a far object wrote over the script
keyword table, and the first door you clicked died with "Error #-5009"
(unknown script word). The lifter now uses 0 DS, 1 CS, 2 SS, 3 ES. Only 3 is
proven by this game; the rest follows from how the emulator fixups rewrite
the ESC byte. This belongs in pcrecomp.

## 4. Borland's `intr()`

Besides `int86()`'s `push bp / int nn / pop bp / retf` stub, `intr()` writes
`mov bp,[bp+d8] / int nn / retf n`. `dispatch_far` runs both.

## 5. The mouse

It is point-and-click, so the mouse is now:

- **absolute**: the pointer's place in the picture, mapped onto the driver's
  range. The game never sets one and divides by 4 for its 320x240 screen, so
  the default is 1280x960.
- **always present**, headless too, so tests can click (`--keys "ms:CLICK@x;y"`).
- **press counts** (33h/05h, 06h).
- **the event handler** (33h/0Ch). The game reacts to clicks only through
  it. It is far-called from the timer tick, like the driver's IRQ, with the
  registers saved around it.

## 6. Sound drivers: none

The game loads John Ratcliff's DIGPAK (`SOUNDRV.COM`) and MIDPAK
(`MIDPAK.COM`) into its heap and calls their jump tables. They are not the
game's code. A loaded driver that does nothing makes its voice clips fail
(-5009 again), so the runtime reports both files as missing, and the game
takes its own silent path. Sound means modelling their INT 66h interface.

## Debugging aids added here

| | |
|---|---|
| `--trace`, "Error ..." | the call stack when the game prints an error |
| `[ems] ... failed` | every EMS call that returned an error |
| `[mouse]`, `[snd]` | the event handler's address; driver calls and INT 66h |
| `[miss] near call res_...` | a near call the lifter could not resolve |
