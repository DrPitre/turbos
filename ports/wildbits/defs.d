* Assemble-time capability flags
*
* Feature Flags - eliminating one or more of these capabilities saves code space.
*
* Manage your own interrupts or install interrupt service routines using F$IRQ.
_FF_IRQ_POLL   equ       0                   Set to 1 for interrupt service routine polling

* Use virtual interrupt service routines using F$VIRQ.
_FF_VIRQ_POLL  equ       0                   Set to 1 for virtual interrupt service routine polling

* Wall time gives year/month/date/hour/minute/second support.
_FF_WALLTIME   equ       0                   Set to 1 for a software wall time clock

* Module CRC and header parity checks are useful for integrity, but slows down loading.
_FF_MODCHECK   equ       0                   Set to 1 for module header and CRC checking

* Unified I/O adds a standard device interface at the expense of more memory.
_FF_UNIFIED_IO equ       0                   Set to 1 for unified I/O

* Booting from an external storage device can bring in additional functionality.
_FF_BOOTING    equ       1                   Set to 1 for bootfile loading

* TurbOS system definitions
               use       turbos.d

* F256 Jr. specific definitions
               use       f256.d

* F256 Jr. mapped I/O boundaries
MappedIOStart  equ       $FE00
MappedIOEnd    equ       $FFFF

* F256 Jr. ticks per second support
TkPerSec       set       60
