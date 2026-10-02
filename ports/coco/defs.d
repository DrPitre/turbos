 use features.d
_FF_VIRQ_POLL equ 1
_FF_WALLTIME equ 1

* TurbOS system definitions
               use       turbos.d

* CoCo specific definitions

* CoCo mapped I/O boundaries
MappedIOStart  equ       $FF00
MappedIOEnd    equ       $FFEF

* CoCo ticks per second support
TkPerSec       set       60
