# TurbOS (Foenix F256 Port)

## Building

To build an image that you can load into the Foenix Retro Systems F256 with the FNX6809, type: `make clean upload`. This builds and uploads the
loader into RAM using the [FoenixMgr tools](https://github.com/pweingar/FoenixMgr).

## Running
The `go` program is a simple test program that increments the first character of the screen.

See [go.asm](go.asm) for more information.