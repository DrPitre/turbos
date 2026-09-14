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

;;; F$IRQ
;;;
;;; Add or remove an interrupt source.
;;;
;;; Entry: D = The address of the source's interrupt status register.
;;; X = The address of the interrupt packet.
;;; Y = The address of the interrupt service routine.
;;; U = The address of the interrupt service routine's memory area.
;;;
;;; Exit: CC = Carry flag clear to indicate success.
;;; 
;;; Error: B = A non-zero error code.
;;; CC = Carry flag set to indicate error.
;;;
;;; F$IRQ installs or removes an interrupt service handler that handles an interrupt source.
;;; It uses an interrupt packet to describe how to handle the interrupt.
;;;
;;; Flip byte: Determines whether the bits in the device status register indicate
;;; active when set or active when cleared. If a bit in the flip byte is set, it
;;; indicates that the task is active whenever the corresponding bit in the status
;;; register is clear (and vice versa).
;;;
;;; Mask Byte: Selects one or more bits within the device status register that are
;;; interrupt request flag(s). One or more set bits identify which task or device is active.
;;;
;;; Priority Byte: Contains the device priority number (0 = lowest priority, 255 = highest priority).

FIRQ ldx R$X,u get the address of the interrupt packet
 ldb ,x load B with the flip byte
 ldx 1,x load X with the mask & priority bytes
 clra clear carry
 pshs cc save CC
 pshs x,b and save flip, mask, & priority bytes on the stack
 ldx <D.Init get the init module address
 ldb CM$PollCnt,x load B with the maximum polling count
 ldx <D.PolTbl get the address of the polling table
 ldy R$X,u get the address of the interrupt packet
 beq RemoveIRQ branch if 0 (remove the interupt service routine)
 tst 1,s test the mask byte
 beq PollError branch if it's 0
 decb decrement the poll table count
 lda #POLSIZ get the poll table entry size in A
 mul get the product
 leax d,x point to the next entry in table
 lda Q$MASK,x get the mask byte from the table
 bne PollError branch if not zero
 orcc #FIRQMask+IRQMask else mask interrupts
loop@ ldb 2,s get the priority byte off the stack
 cmpb -1,x compare with the previous entry's priority
 bcs L052F branch if it's lower or same
 ldb #POLSIZ else copy the previous entry
copyloop@ lda ,-x get a byte from the previous entry
 sta POLSIZ,x store it in this one
 decb decrement the count
 bne copyloop@ branch if not done
 cmpx <D.PolTbl are we at the head of the polling table?
 bhi loop@ keep going until done
L052F ldd R$D,u get the device status register
 std Q$POLL,x save it to the polling table
 ldd ,s++ get the flip/mask bytes
 sta Q$FLIP,x save the flip byte to the polling table
 stb Q$MASK,x save the mask byte to the polling table
 ldb ,s+ get the priority
 stb Q$PRTY,x save the priority to the polling table
 ldd R$Y,u get the interrupt service routine address
 std Q$SERV,x save it to the polling table
 ldd R$U,u get the interrupt service routine memory pointer
 std Q$STAT,x save it to the polling table
 puls pc,cc restore registers and return to the caller

* remove IRQ poll entry
RemoveIRQ leas 4,s clean the stack
 ldy R$U,u get the interrupt service routine memory area
rmloop@ cmpy Q$STAT,x is it this entry?
 beq L0558 branch if so
 leax POLSIZ,x else point to next entry
 decb decrement count
 bne rmloop@ branch if not done
 clrb clear carry
 rts return to the caller
L0558 pshs b,cc save registers
 orcc #FIRQMask+IRQMask mask interrupts
 bra L0565 start at top of loop
copyloop@ ldb POLSIZ,x get first byte of the next entry
 stb ,x+ store it in this entry
 deca decrement the counter
 bne copyloop@ branch if not done
L0565 lda #POLSIZ load A with the polling table entry size
 dec 1,s decrement the counter on the stack
 bne copyloop@ branch if not done
eraseloop@ clr ,x+ clear the byte of the entry
 deca decrement the counter
 bne eraseloop@ branch if not done
 puls pc,a,cc restore registers and return
PollError leas 4,s clean stack
PollError2 comb set the carry flag
 ldb #E$Poll this is a polling error
 rts return to the caller

* IRQ polling routine
FIRQPoller ldy <D.PolTbl get the pointer to the IRQ polling table
 ldx <D.Init get the pointer to the configuration module
 ldb CM$PollCnt,x get the number of polling entries
 bra looptop@ start polling
loop@ leay POLSIZ,y
 decb 
 beq PollError2
looptop@ lda [Q$POLL,y] get the polling byte at the entry
 eora Q$FLIP,y XOR with the flip byte
 bita Q$MASK,y test the bit with the mask byte
 beq loop@ branch if not the interrupt source
 ldu Q$STAT,y else get the static storage from the entry
 pshs y,b save off registers
 jsr [<Q$SERV,y] call the interrupt service routine
 puls y,b restore the registers
 bcs loop@ branch if carry set (try next entry)
 rts return to the caller
