*******************************************************************************
* TurbOS
*******************************************************************************
* See LICENSE.txt for licensing information.
********************************************************************
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/08/29  BGP
* Created.
*          2026/06/25  Codex
* Annotated source and normalized comments.

                    nam       go        ; name this module "go"
                    ttl       Very simple initial program ; set listing title

                    use       defs.d    ; include TurbOS and CoCo definitions

tylg                set       Prgrm+Objct ; module type/language: executable object
atrv                set       ReEnt+rev ; module attributes/revision byte
rev                 set       $01       ; module revision value
edition             set       1         ; module edition byte

                    mod       eom,name,tylg,atrv,start,size ; declare OS-9/TurbOS module header

                    org       0         ; begin module static storage layout
screenstart         rmb       2         ; 512-byte-aligned VDG screen base address
screenend           rmb       2         ; first address beyond the VDG screen buffer
nextcharpos         rmb       2         ; next character cell to write
stack               rmb       200       ; process stack space requested by module
size                equ       .         ; total static storage requirement

name                fcs       /go/                ; module name string
                    fcb       edition   ; module edition byte

* This is a CoCo-specific program that prints a few characters onto the VDG
* screen area of the CoCo. It's meant to demonstrate that the kernel is
* functioning and works.
*
* This program allocates 512 bytes for the 32x16 VDG screen and writes to that area.
start
                    lbsr      VDGInit   ; allocate and map a VDG text screen
                    bcs       exit      ; exit if screen setup failed
                    lbsr      ClearScreen ; blank the newly allocated screen

_SLEEP_TIME         equ       TkPerSec ; delay between screen refreshes
                    leax      banner,pcr ; point X at the static screen labels
                    lbsr      VDGWrite  ; render labels before live values
loop
                    ldd       #(32*1)+16 ; select row 1, column 16 for D.Ticks
                    addd      screenstart,u ; convert screen offset to absolute address
                    std       nextcharpos,u ; position the VDG writer at the tick field
                    ldd       >D.Ticks  ; read high word of the 32-bit system tick count
                    lbsr      PRINT_HEX_16 ; print high word as four hex digits
                    ldd       >D.Ticks+2 ; read low word of the 32-bit system tick count
                    lbsr      PRINT_HEX_16 ; print low word as four hex digits
                    leax      crt,pcr   ; point X at carriage-return terminator
                    lbsr      VDGWrite  ; advance to the next displayed row

                    ldd       #(32*2)+16 ; select row 2, column 16 for D.Slice
                    addd      screenstart,u ; convert screen offset to absolute address
                    std       nextcharpos,u ; position the writer at the slice field
                    ldb       >D.Slice  ; read the current process time-slice counter
                    lbsr      PRINT_HEX_8 ; print slice value as two hex digits

                    leax      crt,pcr   ; point X at carriage-return terminator
                    lbsr      VDGWrite  ; advance to the next displayed row
                    ldd       #(32*3)+16 ; select row 3, column 16 for D.AProcQ
                    addd      screenstart,u ; convert screen offset to absolute address
                    std       nextcharpos,u ; position the writer at active-queue field
                    ldd       >D.AProcQ ; read active process queue pointer
                    lbsr      PRINT_HEX_16 ; print active queue pointer

                    leax      crt,pcr   ; point X at carriage-return terminator
                    lbsr      VDGWrite  ; advance to the next displayed row
                    ldd       #(32*4)+16 ; select row 4, column 16 for D.SProcQ
                    addd      screenstart,u ; convert screen offset to absolute address
                    std       nextcharpos,u ; position the writer at sleeping-queue field
                    ldd       >D.SProcQ ; read sleeping process queue pointer
                    lbsr      PRINT_HEX_16 ; print sleeping queue pointer

                    leax      crt,pcr   ; point X at carriage-return terminator
                    lbsr      VDGWrite  ; advance to the next displayed row
                    ldd       #(32*5)+16 ; select row 5, column 16 for D.WProcQ
                    addd      screenstart,u ; convert screen offset to absolute address
                    std       nextcharpos,u ; position the writer at waiting-queue field
                    ldd       >D.WProcQ ; read waiting process queue pointer
                    lbsr      PRINT_HEX_16 ; print waiting queue pointer

                    ldx       #_SLEEP_TIME ; request a short sleep between display updates
                    os9       F$Sleep   ; yield until the next tick
                    bra       loop      ; refresh the live values forever

exit                os9       F$Exit    ; terminate this process

* Write a null-terminated string to the VDG screen.
* Entry: X = address of string to write.
* Uses nextcharpos,u as the current cursor and updates it on exit.
VDGWrite            ldy       nextcharpos,u ; load destination screen pointer
loop@               lda       ,x+       ; fetch next source character and advance X
                    beq       ex1@      ; stop at the null terminator
                    cmpa      #C$CR     ; detect carriage return
                    bne       fixchar@  ; handle printable characters normally
                    ldd       nextcharpos,u ; fetch current cursor address
                    addd      #32       ; move to the same column on the next row
                    andb      #%11100000 ; force column zero by clearing low five bits
                    cmpd      screenend,u ; test whether the new row is past the screen
                    bge       scroll@   ; scroll if the cursor moved off screen
                    std       nextcharpos,u ; save the new row start as cursor position
                    tfr       d,y       ; use the same address as write pointer
                    bra       loop@     ; continue scanning the string
fixchar@            cmpa      #$40      ; check whether character needs VDG ASCII bias
                    bcc       store@    ; characters at $40 and above are already VDG-ready
                    adda      #$40      ; bias ASCII control/space range into VDG display codes
store@              sta       ,y+       ; store character and advance screen pointer
                    cmpy      screenend,u ; test for end of 32x16 text buffer
                    blt       loop@     ; continue if still inside the screen
truescroll          set       1         ; choose true scroll instead of wraparound
scroll@
                  IFEQ    truescroll
                    ldy       screenstart,u ; wrap cursor to top-left when true scroll is disabled
                    sty       nextcharpos,u ; save wrapped cursor
                  ELSE
                    pshs      x,y       ; preserve source and current screen pointers while scrolling
                    ldy       #32*15    ; copy fifteen 32-byte rows upward
                    ldx       screenstart,u ; start at the top row
                    leax      32,x      ; source begins at second row
scrollloop@         ldd       ,x++      ; copy two VDG cells from next row
                    std       -34,x     ; store them one row above the source
                    leay      -2,y      ; count two copied bytes
                    bne       scrollloop@ ; keep copying until fifteen rows moved
                    stx       nextcharpos,u ; cursor lands at start of final row after scroll
                    puls      x,y       ; restore string and screen pointers
                  ENDC
                    bra       loop@     ; continue writing after scroll/wrap
ex1@                sty       nextcharpos,u ; save final cursor position
                    rts                 ; return to caller
* Initialize a 32x16 VDG screen.
* Stack frame after "pshs u":
stk_vdg_saved_u     equ       0         ; saved caller U while F$SRqMem returns memory in U
VDGInit             pshs      u         ; preserve module static storage pointer
                    ldd       #512+256  ; request screen plus one page for alignment slack
                    os9       F$SRqMem  ; allocate memory; U returns allocation address
                    bcs       ex@       ; return error if memory allocation failed
good@               tfr       u,d       ; copy allocated address into D for alignment math
                    ldu       ,s        ; restore module static storage pointer from stk_vdg_saved_u
                    tfr       a,b       ; save allocation high byte in B
                    bita      #$01      ; test whether allocation began on an odd page
                    beq       lastpage@ ; even page is already 512-byte aligned
                    adda      #$01      ; use the following even page as VDG screen
                    bra       firstpage@ ; return the unneeded first page
lastpage@           incb                ; return page after the aligned screen
* Stack frame after "pshs u,a":
stk_vdg_screen      equ       0         ; selected screen high byte
stk_vdg_saved_u2    equ       1         ; saved module static storage pointer
firstpage@          pshs      u,a       ; save static pointer and selected screen page
                    tfr       b,a       ; move high byte of page to return into A
                    clrb                ; make D point to start of page being returned
                    tfr       d,u       ; pass return-page address in U
                    ldd       #256      ; return exactly one unused page
                    os9       F$SRtMem  ; return alignment slack to the system pool
                    puls      u,a       ; restore static pointer and selected screen page
                    bcs       exit      ; exit process if the memory return failed
                    clrb                ; form selected screen base address in D
                    std       screenstart,u ; save aligned VDG screen base
                    std       nextcharpos,u ; initialize cursor to top-left
                    addd      #32*16    ; compute one byte past 32x16 screen
                    std       screenend,u ; save end-of-screen address
                    lda       screenstart,u ; get high byte of screen base for SAM setup
* Set up VDG alpha mode screen for text.
                    ldx       #$FFC6    ; point at highest SAM display-offset select address
                    stb       -6,x      ; clear SAM VDG mode/address select bit at $FFC0
                    stb       -4,x      ; clear SAM VDG mode/address select bit at $FFC2
                    stb       -2,x      ; clear SAM VDG mode/address select bit at $FFC4
                    ldb       #$07      ; program seven SAM address-select bit pairs
                    lsra                ; discard low bit not used by SAM screen base
loop1@              lsra                ; shift next screen-base bit into carry
                    bcs       odd@      ; choose odd SAM register address when bit is set
                    sta       ,x++      ; tickle even SAM register address when bit is clear
                    bra       next@     ; advance to next SAM bit pair
odd@                leax      1,x       ; skip even SAM register address
                    sta       ,x+       ; tickle odd SAM register address when bit is set
next@               decb                ; count programmed SAM bit pair
                    bne       loop1@    ; continue until all seven bits are programmed
                    clrb                ; clear carry to report success
ex@                 puls      u,pc      ; restore static pointer and return

ClearScreen
                    ldx       screenstart,u ; point X at first VDG screen byte
                    ldd       #(C$SPACE+$40)*256+(C$SPACE+$40) ; prepare two VDG space characters
loop@               std       ,x++      ; clear two screen cells and advance
                    cmpx      screenend,u ; test whether screen end was reached
                    bne       loop@     ; keep clearing until the full screen is blank
                    rts                 ; return after clearing screen

*************************************
* Print 4 digit (16-bit) hex number.
*
* Entry:  D = value to print
*
* Exit:   B error code, if any
*        CC carry set if error
*
* Stack frame after "pshs b":
stk_hex16_low_byte  equ       0         ; original low byte while high byte is printed
PRINT_HEX_16
                    pshs      b         ; save low byte for second pair of hex digits
                    tfr       a,b       ; move high byte into B for PRINT_HEX_8
                    bsr       PRINT_HEX_8 ; print high byte as two hex digits
                    ldb       ,s+       ; recover original low byte from stk_hex16_low_byte
* Fall through to PRINT_HEX_8.

*************************************
* Print 2 digit (8-bit) hex number.
*
* Entry:  B = value to print
*
* Exit:   B = error code, if any
*        CC = carry set if error
*
* Stack frame after "pshs a,x" and "leas -3,s":
stk_hex8_buffer     equ       0         ; three-byte null-terminated output buffer
stk_hex8_saved_x    equ       3         ; saved X register
stk_hex8_saved_a    equ       5         ; saved A register
stk_hex8_return     equ       6         ; return address to caller
PRINT_HEX_8
                    pshs      a,x       ; preserve registers clobbered by conversion/write
                    leas      -3,s      ; reserve two hex digits plus null terminator
                    tfr       s,x       ; pass stack buffer address in X
                    lbsr      BIN_HEX_8 ; convert B to null-terminated hex string
                    lbsr      VDGWrite  ; write converted string to VDG screen
                    leas      3,s       ; release local buffer
                    puls      a,x,pc    ; restore registers and return

********************************************
* Binary to hexadecimal convertor
*
* This subroutine will convert the binary value in
* 'D' to a 4 digit hexadecimal ASCII string.
*
* OTHER MODULES NEEDED: BIN2HEX
*
* Entry: D = value to convert
*        X = buffer for hex string-null terminated
*
* Exit: all registers (except CC) preserved.
*
* Stack frame after "pshs d,x":
stk_bin16_saved_x   equ       0         ; caller output buffer pointer
stk_bin16_saved_d   equ       2         ; caller 16-bit value
bin_hex_16:
                    pshs      d,x       ; preserve input value and buffer pointer
                    ldb       ,s        ; load high byte from stk_bin16_saved_d
                    lbsr      BIN2HEX   ; convert byte in B to two ASCII hex digits in D
                    std       ,x++      ; store first two digits and advance buffer
                    ldb       1,s       ; load low byte from stk_bin16_saved_d+1
                    lbsr      BIN2HEX   ; convert low byte to ASCII hex
                    std       ,x++      ; store second two digits and advance buffer
                    clr       ,x        ; terminate output string with NUL
                    puls      d,x       ; restore caller registers

* Stack frame after "pshs b,x":
stk_bin8_saved_x    equ       0         ; caller output buffer pointer
stk_bin8_saved_b    equ       2         ; caller byte value
bin_hex_8:
                    pshs      b,x       ; preserve input byte and buffer pointer
                    ldb       ,s        ; reload byte from stk_bin8_saved_b
                    lbsr      BIN2HEX   ; convert byte in B to two ASCII hex digits in D
                    std       ,x++      ; store converted byte and advance buffer
                    clr       ,x        ; terminate output string with NUL
                    puls      b,x       ; restore caller registers

****************************************
* Convert hex byte to 2 hex digits.
*
* OTHER MODULES REQUIRED: none
*
* Entry: B = value to convert
*
* Exit:  D = 2 byte hex digits
*
* Stack frame after "pshs b":
stk_bin2hex_lsn     equ       0         ; original byte used later for low nibble
BIN2HEX
                    pshs      b         ; save original byte for low-nibble conversion
                    lsrb                ; move high nibble toward low nibble bit 3
                    lsrb                ; move high nibble toward low nibble bit 2
                    lsrb                ; move high nibble toward low nibble bit 1
                    lsrb                ; move high nibble into low nibble position
                    bsr       ToHex     ; convert high nibble to ASCII in B
                    tfr       b,a       ; save first ASCII digit in A
                    puls      b         ; restore original byte for low nibble
                    andb      #%00001111 ; isolate low nibble

ToHex
                    addb      #'0       ; bias nibble into ASCII digit range
                    cmpb      #'9       ; test whether digit is 0-9
                    bls       ToHex1    ; return if ASCII digit is in numeric range
                    addb      #7        ; adjust ':' through '?' into 'A' through 'F'
ToHex1
                    rts                 ; return with ASCII hex digit in B

banner              fcc       /TURBOS/            ; display title string
                    fcb       C$CR      ; move to next VDG row
                    fcc       /D.TICKS/           ; label for 32-bit system tick counter
                    fcb       C$CR      ; move to next VDG row
                    fcc       /D.SLICE/           ; label for process time-slice counter
                    fcb       C$CR      ; move to next VDG row
                    fcc       /D.APROCQ/          ; label for active process queue pointer
                    fcb       C$CR      ; move to next VDG row
                    fcc       /D.SPROCQ/          ; label for sleeping process queue pointer
                    fcb       C$CR      ; move to next VDG row
                    fcc       /D.WPROCQ/          ; label for waiting process queue pointer
crt                 fcb       C$CR,$00  ; carriage return plus string terminator

                    emod      ;         emit module CRC
eom                 equ       *         ; end of module address
                    end       ;         end assembly
