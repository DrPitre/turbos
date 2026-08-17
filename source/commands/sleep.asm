********************************************************************
* Sleep - Sleep for some ticks
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??

 use       defs.d

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 2

 mod eom,name,tylg,atrv,start,size

 org 0
stack rmb 200
size equ .

name fcs /sleep/
 fcb edition

start clra
 clrb
; Get up to five characters from ,X (command line) 
 bsr getbyte
 bsr getbyte
 bsr getbyte
 bsr getbyte
 bsr getbyte
 tfr d,x
 os9 F$Sleep
 clrb
 os9 F$Exit
getbyte pshs d
 ldb ,x
 subb #'0'
 bcs ex@
 cmpb #$09
 bhi ex@
 leax $01,x
 pshs b
 ldb  #$0A
 mul
 stb $01,s
 lda $02,s
 ldb #$0A
 mul
 addb ,s+
 adca ,s
 std  ,s
ex@ puls pc,b,a

 emod
eom equ *
 end

