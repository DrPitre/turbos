*******************************************************************************
* TurbOS
*******************************************************************************
* See LICENSE.txt for licensing information.
*******************************************************************************
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ----------------------------------------------------------------------------
*          2023/08/11  Boisy Pitre
* Initial creation.
*
*******************************************************************************
* NOTES:
*
* The kernel refers to this module for configuration information.
*

 nam Init
 ttl Configuration module

 use defs.d

tylg set Systm+$00
atrv set ReEnt+rev
rev set $00
edition set 1

* The last four bytes of the module header are are for the module entry
* address and dynamic data size requirement, neither which is pertinent
* for this type of module.
* The locations are repurposed for a 24-bit maximum memory size (usually
* 64K - 256 bytes, or $00FE00), and an 8-bit IRQ polling table entry count.
*
 mod eom,name,tylg,atrv,$00FE,$0015

***** USER MODIFIABLE DEFINITIONS HERE *****

*
* Refer to "Configuration module entry offsets" in turbos.d
*
start equ *
 fcb $27 number of entries in device table
 fdb TickModule offset to ticker module
 fdb DefProg offset to initial program to fork
 ifne _FF_UNIFIED_IO
 fdb DefDev offset to default storage device
 fdb DefCons offset to default console device
 endc
 ifne _FF_BOOTING
 fdb DefBoot offset to booter
 endc
 fcb 1 OS level
 fcb TURBOS_MAJOR OS version
 fcb TURBOS_MINOR OS major revision
 fcb TURBOS_MININUM OS minor revision
 fcb CRCOff feature byte #1
 fcb $00 feature byte #2

name fcs "init"
 fcb edition

TickModule fcs "tk"
DefProg fcs "go"
 ifne _FF_UNIFIED_IO
DefDev fcs "/dd"
DefCons fcs "/term"
 endc
 ifne _FF_BOOTING
DefBoot fcs "boot"
 endc

 emod 
eom equ *
 end 
