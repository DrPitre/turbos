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
* This module can be configured to remove features, such as F$VIRQ support and
* software real-time clock updating. These features may not be needed in some
* embedded system applications.

               nam       tkf256
               ttl       Foenix Retro Systems F256/F256 Jr. ticker module

               use       defs.d

tylg           set       Systm+Objct
atrv           set       ReEnt+rev
rev            set       1
edition        set       1

               mod       len,name,tylg,atrv,init,0

name           fcs       "tk"
               fcb       edition

TkPerTS        equ       TkPerSec/10         ticks per time slice

*
* Table to set up Service Calls
*
NewSvc
               ifne      _FF_WALLTIME
               fcb       F$Time
               fdb       FTime-*-2
               fcb       F$STime
               fdb       FSTime-*-2
               endc
               ifne      _FF_VIRQ_POLL
               fcb       F$VIRQ
               fdb       FVIRQ-*-2
               endc
               fcb       $80                 end of service call installation table

;;; F$STime
;;;
;;; Set the current system time.
;;;
;;; Entry:  X = The address of the current time.
;;;
;;; Exit:   The system's time is updated.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$STime sets the current system date and time. The packet format is:
;;;     - Year (one byte from 0-255 representing 1900-2155)
;;;     - Month (one byte from 1-12 representing the month)
;;;     - Day (one byte from 0-31 representing the day)
;;;     - Hour (one byte from 0-23 representing the hour)
;;;     - Minute (one byte from 0-59 representing the minute)
;;;     - Second (one byte from 0-59 representing the second)

               ifne      _FF_WALLTIME
FSTime         ldx       R$X,u               get caller's pointer to time packet
               ldd       ,x                  get year and month
               std       <D.Year             save to globals
               ldd       2,x                 get day and hour
               std       <D.Day              save to globals
               ldd       4,x                 get minute and second
               std       <D.Min              save to globals
               lda       #TkPerSec           reset to start of second
               sta       <D.Tick             save to current tick
               rts                           and return to the caller
               endc

* Ticker initialization
*
* The kernel calls this routine during system initialization.
init
               ifne      _FF_WALLTIME
               ldd       #59*256+$01         last second and last tick
               std       <D.Sec              will prompt RTC read at next time slice
               endc
               ldb       #TkPerSec           get ticks per second
               stb       <D.TSec             set global
               ldb       #TkPerTS            get ticks per time slice
               stb       <D.TSlice           set global
               stb       <D.Slice            set first time slice
               leax      SvcIRQ,pcr          get interrupt service routine pointer
               stx       <D.IRQ              set global
               leay      NewSvc,pcr          point to new system call table
               os9       F$SSvc              install it
* Initialize the clock hardware
* Use the Start Of Frame (SOF) to get a 1/60th or 1/70th interrupt
               pshs      cc                  save IRQ enable status (and Carry clear)
               orcc      #IntMasks
               lda       #$FF                load A with all bits set
               sta       INT_PENDING_0       clear any pending interrupts at set 0
               sta       INT_PENDING_1       clear any pending interrupts at set 1
               sta       INT_MASK_1          set the interrupt masks for set 1
               anda      #~INT_VKY_SOF       mask out the SOF bit
               sta       INT_MASK_0          and save it to the I/O mask port
               puls      cc,pc               recover IRQ enable status and return

* Clock IRQ Entry Point
*
SvcIRQ         clra                          clear A
               tfr       a,dp                set direct page to zero
               lda       INT_PENDING_0       get the interrupt pending byte
               bita      #INT_VKY_SOF        test to see if it's a clock interrupt
               bne       clearirq@           it's a clock interrupt -- clear it
               jmp       [>D.SvcIRQ]         else service other possible IRQ
clearirq@      sta       INT_PENDING_0       clear clock interrupt by writing bit back
               dec       <D.Tick             decrement tick counter
               bne       handlevirq@         go around if not zero
               ifne      _FF_WALLTIME
* Perform wall time update
               ldb       <D.Sec              get minutes/seconds
* Seconds increment
               incb                          increment seconds
               stb       <D.Sec              update sec
               cmpb      #60                 are we at a full minute
               blt       updatetick@
* Minutes increment
               lda       <D.Min              grab current minute
               inca                          increase the minute field by 1
               cmpa      #60                 are we at full hour?
               blo       UpdMin              no, set start of minute
               ldd       <D.Day              get day and hour
               incb                          increase hour by 1
               cmpb      #24                 are at a full day?
               blo       UpdHour             branch if not
               inca                          else increase day by 1
               leax      months-1,pcr        point to months table with offset-1: Jan = +1
               ldb       <D.Month            get this month
               cmpa      b,x                 are we at a full month?
               bls       UpdDay              branch if not to update the day
               cmpb      #2                  else check if we are in February
               bne       NoLeap              branch if not
               ldb       <D.Year             else get the year
               andb      #$03                check for leap year: good until 2099
               cmpd      #$1D00              29th on leap year?
               beq       UpdDay              yes, update the day
NoLeap         ldd       <D.Year             else get the year and month
               incb                          increment the month
               cmpb      #13                 at end of year?
               blo       UpdMonth            branch if not
               inca                          else increment the year
               ldb       #$01                and set the month to January
UpdMonth       std       <D.Year             store off both year and month
               lda       #$01                new month, so set day to 1
UpdDay         clrb                          hour is now 0 (midnight)
UpdHour        std       <D.Day              save the day and hour
               clra                          minute is now 0 (top of the hour)
UpdMin         clrb                          seconds is now 0 (top of the minute)
               std       <D.Min              store off the minutes and seconds
               endc
updatetick@    lda       <D.TSec             get ticks per second value
               sta       <D.Tick             and repopulate tick decrement counter
handlevirq@
               ifne      _FF_VIRQ_POLL
               ldy       <D.VIRQTable        get pointer to VIRQ table
               beq       GoAltIRQ            table isn't initialized, so service kernel
               clra                          clear flag byte to indicate we're not at terminal count
               pshs      a                   and save it on the stack for later
               bra       getnext@            go to the processing portion of the loop
nextentry@     ldd       Vi.Cnt,x            get count down counter
               subd      #$0001              subtract tick count
               bne       savecount@          branch if not at terminal count ($0000)
               lda       #$01                we're at terminal count... save flag on stack
               sta       ,s                  set flag on stack to 1
               lda       Vi.Stat,x           get status byte
               bne       setiflag@           if not zero, set interrupted flag
               bsr       DelVIRQ             otherwise delete VIRQ entry
setiflag@      ora       #Vi.IFlag           set interrupted flag
               sta       Vi.Stat,x           save in packet
               ldd       Vi.Rst,x            get reset count
savecount@     std       Vi.Cnt,x            save tick count back
getnext@       ldx       ,y++                get address of next entry in VIRQ polling table
               bne       nextentry@          if not zero, branch
               lda       ,s+                 else timer reached zero... get flag off stack
               beq       GoAltIRQ            branch if zero
               ldx       <D.Proc             else get pointer to current process descriptor
               beq       dopoll@             branch if none
               tst       P$State,x           test process state
               bpl       UsrPoll             branch if system state not set
dopoll@        jsr       [>D.Poll]           poll ISRs
               bcc       dopoll@             keep polling until carry set
               endc
* Increment the 32-bit timer
               inc       <D.Ticks+3
               bne       next@
               inc       <D.Ticks+2
               bne       next@
               inc       <D.Ticks+1
               bne       next@
               inc       <D.Ticks
next@
GoAltIRQ       jmp       [>D.Clock]          jump into clock routine

               ifne      _FF_VIRQ_POLL
UsrPoll        leay      >up@,pcr            point to routine to execute
               jmp       [>D.URtoSs]         User to System
up@            jsr       [>D.Poll]           call interrupt polling routine
               bcc       up@                 keep polling until carry set
               ldx       <D.Proc             get current process descriptor
               ldb       P$State,x           and its state
               andb      #^SysState          turn off system state bit
               stb       P$State,x           save new state
               ldd       <P$SWI2,x           get process descriptor's SWI2 vector
               std       <D.SWI2             save off in system globals
               ldd       <D.UsrIRQ           get user IRQ routine vector
               std       <D.SvcIRQ           save off in system globals
               bra       GoAltIRQ            go do kernel multitasking stuff

DelVIRQ        pshs      y,x                 save off Y,X
dl@            ldx       ,y++                get next entry
               stx       -$04,y              move up
               bne       dl@                 continue until all are moved
               puls      y,x                 restore
               leay      -2,y                move back 2 from Y (points to last entry)
               rts                           return
               endc

;;; F$VIRQ
;;;
;;; Install a virtual interrupt service routine.
;;;
;;; Entry:  D = The initial counter value.
;;;         X = If 0, delete the entry; otherwise install a new entry.
;;;         Y = The address of the VIRQ packet.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; Use F$VIRQ to install or remove a virtual interrupt service routine. A virtual interrupt is
;;; useful for devices that need periodic servicing, but aren't able to source a hardware-based
;;; interrupt.
;;;
;;; The entity using the virtual interrupt service can specify how many ticks must elapse before
;;; the virtual interrupt triggers. It can also be a one-shot or repeating interrupt.
;;;
;;; To install a virtual interrupt service routine, supply the VIRQ packet:
;;;
;;; - Vi.Cnt: Two bytes for the counter's initial value.
;;; - Vi.Rst: Two bytes for the counter's reset value.
;;; - Vi.Stat: One byte for the status.
;;;            Bit 0: if 1, a virtual interrupt occurred.
;;;            Bit 7: if 1, the virtual interrupt is repeatable; otherwise, 0 is a one-shot.

               ifne      _FF_VIRQ_POLL
FVIRQ          pshs      cc                  preserve CC register
               orcc      #IntMasks           mask all interrupts
               ldy       <D.VIRQTable        get pointer to VIRQ polling table
               ldx       <D.Init             get pointer to init module
               ldb       CM$PollCnt,x        get poll count
               ldx       R$X,u               get pointer to caller's X
               beq       remove@             branch if removing
* Install VIRQ entry here
               tst       ,y                  entry available?
               beq       install@            yes, go install it
               subb      #$02                subtract from polling count
               lslb                          multiply by 2
               leay      b,y                 point Y to the location
               tst       ,y                  test
               bne       tablefull@          polling table full
loop@          tst       ,--y
               beq       loop@               keep looking
               leay      $02,y
install@       ldx       R$Y,u               get the address of the VIRQ packet from the caller
               stx       ,y                  save the address in the VIRQ entry
               ldy       R$D,u               get the initial counter value from the caller
               sty       Vi.Cnt,x            set the counter to this value
               bra       ex@                 and exit to caller without error
* Remove VIRQ entry here
remove@        leax      R$Y,u               X = caller's Y
loop1@         tst       ,y                  end of VIRQ table
               beq       ex@                 branch if so
               cmpx      ,y++                else compare to current VIRQ entry and inc Y
               bne       loop1@              continue searching if not matched
               bsr       DelVIRQ             else delete entry
ex@            puls      cc                  restore CC register
               clrb                          clear carry
               rts                           return to caller
tablefull@     puls      cc                  restore CC register
               comb                          set carry
               ldb       #E$Poll             set polling table full error
               rts                           return to the caller
               endc

;;; F$Time
;;;
;;; Return the current system time to the caller.
;;;
;;; Entry:  X = The address to store the current time.
;;;
;;; Exit:   X = The address of the current time.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Time returns the current system date and time in a 10-byte packet. The kernel copies the packet to
;;; the address passed in X. The packet format is:
;;;     - Year (one byte from 0-255 representing 1900-2155)
;;;     - Month (one byte from 1-12 representing the month)
;;;     - Day (one byte from 0-31 representing the day)
;;;     - Hour (one byte from 0-23 representing the hour)
;;;     - Minute (one byte from 0-59 representing the minute)
;;;     - Second (one byte from 0-59 representing the second)
;;;     - Ticks (four bytes from 0-2^32 representing the number of ticks since startup.)

               ifne      _FF_WALLTIME
FTime          ldx       R$X,u               get the caller's time packet in X
               ldd       <D.Year             get year and month
               std       ,x                  store in caller's 0,x
               ldd       <D.Day              get day and hour
               std       2,x                 store in caller's 2,x
               ldd       <D.Min              get minute and second
               std       4,x                 store in caller's 4,x
               ldd       <D.Ticks            get upper 16 bits of the tick count
               std       6,x                 store in caller's 6,x
               ldd       <D.Ticks+2          get the lower 16 bits of the tick count
               std       8,x                 store in caller's 8,x
               clrb                          clear carry
               rts                           return to the caller

months         fcb       31,28,31,30,31,30,31,31,30,31,30,31 Days in each month

               endc

               emod
len            equ       *
               end
