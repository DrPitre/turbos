* Wildbits profile; undefined switches inherit upstream defaults.
_FF_IRQ_POLL equ 0
_FF_MODCHECK equ 0
_FF_UNIFIED_IO equ 0
_FF_BOOTING equ 1
_FF_ID equ 0
_FF_SPRIOR equ 0
_FF_SSWI equ 0
_FF_VIRQ_POLL equ 0
_FF_WALLTIME equ 0
 use features.d

* TurbOS system definitions
               use       turbos.d

* F256 Jr. specific definitions
               use       f256.d

* F256 Jr. mapped I/O boundaries
MappedIOStart  equ       $FE00
MappedIOEnd    equ       $FFFF

* F256 Jr. ticks per second support
TkPerSec       set       60
