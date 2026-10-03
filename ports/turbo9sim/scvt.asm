********************************************************************
* scvt.asm - Virtual terminal
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2025/02/02  Boisy G. Pitre
* Started.

 use defs.d
 use scf.d

tylg set Drivr+Objct
atrv set ReEnt+Rev
rev set $00
edition set 1

 mod eom,name,tylg,atrv,Start,Size

 fcb READ.+WRITE.

name fcs /scvt/
 fcb edition one more revision level than the stock printer

* Device memory area: offset from U
 org V.SCF V.SCF: free memory for driver to use
V.BUFF rmb $80 room for 128 blocked processes
V.IBufH RMB 1 input buffer head
V.IBufT RMB 1 input buffer tail
V.InBuf RMB 128 input buffer ptr
size equ .

start equ *
 lbra Init
 lbra Read
 lbra Write
 lbra GetStt
 lbra SetStt

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
 ldd V.PORT,u base hardware address is status register
 addd #Reg.Stat point to interrupt status register
 ldx #$0000 remove IRQ table entry
 leay IRQSvc,pc
 os9 F$IRQ
 clrb
 rts

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init
 pshs y
 ldd V.PORT,u base hardware address
 addd #Reg.Stat point to interrupt status register
 leax IRQPckt,pcr
 leay IRQSvc,pcr
 os9 F$IRQ
 puls y
 bcs ex@ go report error...
* set bit to receive interrupt on input
 lda MappedIOStart+Reg.Ctrl
 ora #Ctrl.TermIRQ
 sta MappedIOStart+Reg.Ctrl
 clrb
ex@ rts


* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
Read

 leax V.InBuf,u point X to input buffer
 ldb V.IBufT,u get tail pointer
 orcc #IRQMask mask IRQ
 cmpb V.IBufH,u same as head pointer
 beq Put2Bed if so, buffer is empty, branch to sleep
 abx X now points to curr char
 lda ,x get char
 bsr ChkWrp check for tail wrap
 stb V.IBufT,u store updated tail
 andcc #^(IRQMask+Carry) unmask IRQ
FlashCursor
 rts

Put2Bed lda V.BUSY,u get calling process ID
 sta V.WAKE,u store in V.WAKE
 andcc #^IRQMask clear interrupts
 ldx #$0000
 os9 F$Sleep sleep forever
 clr V.WAKE,u clear wake
 ldx <D.Proc get pointer to current proc desc
 ldb <P$Signal,x get signal recvd
 beq Read branch if no signal
 cmpb #S$Intrpt+1 signal higher than S$Intrpt?
 bhs Read yes (none of the main system ones), go read
 coma Otherwise, return with signal code as error
 rts

* Check if we need to wrap around tail pointer to zero
ChkWrp incb increment pointer
 cmpb #$7F at end?
 bls L00A3 branch if not
 clrb else clear pointer (wrap to head)
L00A3 rts

* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write sta MappedIOStart+Term.Out
 clrb
 rts

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStt 
*                  sta       <V.WrChr,u          save off stat code
 cmpa #SS.EOF EOF call?
 beq SSEOF Yes, exit w/o error
 ldx PD.RGS,y Get ptr to caller's regs (all other calls require this)
 cmpa #SS.Ready Data ready call? (keyboard buffer)
 bne UnknownStat unsupported status request
 lda V.IBufH,u get buff tail ptr
 suba V.IBufT,u num of chars ready in A
 sta R$B,x Save for caller
 lbeq NotReady If no data in keyboard buffer, return with Not Ready error
L0439
SSEOF clrb
 rts

UnknownStat comb
 ldb #E$UnkSvc
 rts

NotReady comb No, exit with Not Ready error
 ldb #E$NotRdy
 rts

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStt clrb
 rts
 
IRQSvc
 ldx V.PORT,u base hardware address
 lda Term.In,x read character before acknowledging interrupt
 pshs a
 lda #Term.RxReady acknowledge only the terminal source (write-one-to-clear)
 sta Reg.Stat,x
 puls a
 ldb V.IBufH,u get head pointer in B
 leax V.InBuf,u point X to input buffer
 abx X now holds address of head
 lbsr ChkWrp check for tail wrap
 cmpb V.IBufT,u B at tail?
 beq L012F branch if so
 stb V.IBufH,u
L012F sta ,x store our char at ,X
 beq WakeIt if nul, do wake-up
 cmpa V.PCHR,u pause character?
 bne L013F branch if not
 ldx V.DEV2,u else get dev2 statics
 beq WakeIt branch if none
 sta V.PAUS,x else set pause request
 bra WakeIt

L013F ldb #S$Intrpt get interrupt signal
 cmpa V.INTR,u our char same as intr?
 beq L014B branch if same
 ldb #S$Abort get abort signal
 cmpa V.QUIT,u our char same as QUIT?
 bne WakeIt branch if not
L014B lda V.LPRC,u get ID of last process to get this device
 bra L0153 go for it

WakeIt ldb #S$Wake get wake signal
 lda V.WAKE,u get process to wake
L0153 beq L0158 branch if none
 os9 F$Send else send wakeup signal
L0158 clr V.WAKE,u clear process to wake flag

 rts
 
Stat.Flp equ %00000000 all Status bits active when set
Stat.Msk equ Term.RxReady active IRQ

IRQPckt equ *
Pkt.Flip fcb Stat.Flp flip byte
Pkt.Mask fcb Stat.Msk mask byte
 fcb $0A priority
 
 emod
eom equ *
 end
