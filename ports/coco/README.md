# TurbOS (CoCo Port)

## Building

To build a bootable VDG test disk image named `vdg.dsk`, type: `make clean dsk`.

## Running

Mount `vdg.dsk` on a real CoCo or an emulator, then in Disk BASIC, type: `RUN "*"`.
To start it in MAME from this directory, type: `make run`.

The `go` program displays a 32x16 VDG status screen with the TurbOS banner,
system tick count, time slice, and process queue pointers. It sleeps between
updates, exercising timer interrupts and process wakeups.

See [go.asm](go.asm) for more information.
