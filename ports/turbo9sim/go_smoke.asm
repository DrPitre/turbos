*******************************************************************************
* TurbOS
*******************************************************************************
* Hyper9 command-line smoke test program.

 nam go
 ttl Hyper9 smoke test program

 use defs.d

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $01
edition set 1

 mod eom,name,tylg,atrv,start,size

 org 0
stack rmb 200
size equ .

name fcs /go/
 fcb edition

start leax message,pcr
write@ lda ,x+
 beq sleep@
 sta MappedIOStart+Term.Out
 bra write@
sleep@ ldx #0
 os9 F$Sleep
 bra sleep@

message fcc "TurbOS OK"
 fcb C$CR,$0A,0

 emod
eom equ *
 end
