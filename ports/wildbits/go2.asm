*******************************************************************************
* TurbOS
*******************************************************************************
* See LICENSE.txt for licensing information.
********************************************************************
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/08/29  BGP
* Created.

               nam       go
               ttl       Very simple initial program

               use       defs.d

tylg           set       Prgrm+Objct
atrv           set       ReEnt+rev
rev            set       $01
edition        set       1

               mod       eom,name,tylg,atrv,start,size

               org       0
stack          rmb       200
size           equ       .

name           fcs       /go2/
               fcb       edition

start          equ       *


               pshs      cc
               orcc      #IntMasks
               lda       #$C2
               sta       >MMU_SLOT_1
               ldd       #'T*256+'u
               std       $2000
               ldd       #'r*256+'b
               std       $2002
               ldd       #'O*256+'S
               std       $2004
               puls      cc

loop@          pshs      cc
               orcc      #IntMasks
               inc       $2000
               puls      cc
               ldx       #$10
               os9       F$Sleep
               bra       loop@

               emod
eom            equ       *
               end

