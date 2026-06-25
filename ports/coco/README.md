# TurbOS (CoCo Port)

## Building

To build a bootable VDG test disk image named `vdg.dsk`, type: `make clean dsk`.

## Running

Mount `vdg.dsk` on a real CoCo or an emulator, then in Disk BASIC, type: `RUN "*"`.
To start it in MAME from this directory, type: `make run`.

The 32x16 VDG screen remains intact, with the system stack appearing in the middle of the screen.

The `go` program is a simple test program that increments the first two characters of the screen at alternating intervals.

See [go.asm](go.asm) for more information.
