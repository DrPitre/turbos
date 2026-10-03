# TurbOS (Simulator Port)

## Building

To build an image that you can load into the Turbo9 simulator, type: `make clean all`.

## Running
The `go` program is a simple test program that increments the first character of the screen.

See [go.asm](go.asm) for more information.

## Running on Turbo9 RTL

The interrupt-enabled Turbo9 checkout includes `sim/run_turbos.sh` and a
virtual board matching this port's `$FF00` terminal/timer interface.
Build `turbos_smoke.img` and `turbos_dev.img`, then run:

```sh
/path/to/turbo9/sim/run_turbos.sh "$PWD/turbos_smoke.img"
/path/to/turbo9/sim/run_turbos.sh "$PWD/turbos_dev.img" dev
```

The development regression enters `mfree` via terminal interrupts and checks
its result, a second shell prompt, and timer acknowledgements across all six
CPU pipeline types. It requires Icarus Verilog and Python 3, but no FPGA board.
The images contain the complete 64 KiB address space, including reset and
interrupt vectors. `Reg.Stat` uses write-one-to-clear acknowledgements; a
terminal handler must read `Term.In` before acknowledging `Term.RxReady`.

For hardware, implement this memory map, a 60 Hz timer, and terminal byte I/O
backed by the FPGA UART. The accelerated virtual timer is for regression only.
