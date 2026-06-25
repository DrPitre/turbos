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

 ifne TURBOS.D-1

TURBOS.D set 1

 nam turbos.d
 ttl TurbOS system definitions

* Common definitions
true equ 1
false equ 0

 pag
*****************************************
* System service request code definitions
*
 org 0
* User and system state calls
F$Link rmb 1 link to module
F$Load rmb 1 load module from file
F$UnLink rmb 1 unlink module
F$Fork rmb 1 start new process
F$Wait rmb 1 wait for child process to die
F$Chain rmb 1 chain process to new module
F$Exit rmb 1 terminate process
F$Mem rmb 1 set memory size
F$Send rmb 1 send signal to process
F$Icpt rmb 1 set signal intercept
F$Sleep rmb 1 suspend process
F$ID rmb 1 return process ID
F$SPrior rmb 1 set process priority
F$SSWI rmb 1 set software interrupt
F$PErr rmb 1 print Error
F$PrsNam rmb 1 parse pathlist name
F$CmpNam rmb 1 compare two names
F$SchBit rmb 1 search bit map
F$AllBit rmb 1 allocate in bit map
F$DelBit rmb 1 deallocate in bit map
F$Time rmb 1 get current time
F$STime rmb 1 set current time
F$CRC rmb 1 generate CRC

 org $27 beginning of system reserved calls
* System state (privileged) calls
F$VIRQ rmb 1 install/delete virtual IRQ
F$SRqMem rmb 1 system memory request
F$SRtMem rmb 1 system memory return
F$IRQ rmb 1 enter IRQ polling table
F$IOQu rmb 1 enter I/O queue
F$AProc rmb 1 enter active process queue
F$NProc rmb 1 start next process
F$VModul rmb 1 validate module
F$Find64 rmb 1 find process/path descriptor
F$All64 rmb 1 allocate process/path descriptor
F$Ret64 rmb 1 return process/path descriptor
F$SSvc rmb 1 service request table initialization
F$IODel rmb 1 delete I/O module

*
* System calls $70 through $7F are reserved for user definitions
*
 org $70
 rmb 16 reserved for user definition

 pag
**************************************
* I/O service request code definitions
*
 org $80
I$Attach rmb 1 attach I/O device
I$Detach rmb 1 detach I/O device
I$Dup rmb 1 duplicate path
I$Create rmb 1 create new file
I$Open rmb 1 open existing file
I$MakDir rmb 1 make directory file
I$ChgDir rmb 1 change default directory
I$Delete rmb 1 delete file
I$Seek rmb 1 change current position
I$Read rmb 1 read data
I$Write rmb 1 write data
I$ReadLn rmb 1 read line of ASCII data
I$WritLn rmb 1 write line of ASCII data
I$GetStt rmb 1 get path status
I$SetStt rmb 1 set path status
I$Close rmb 1 close path
I$DeletX rmb 1 delete from current exec dir

*******************
* File access modes
*
READ. equ %00000001
WRITE. equ %00000010
UPDAT. equ READ.+WRITE.
EXEC. equ %00000100
PREAD. equ %00001000
PWRIT. equ %00010000
PEXEC. equ %00100000
SHARE. equ %01000000
DIR. equ %10000000
ISIZ. equ %00100000

**************
* Signal codes
*
 org 0
S$Kill rmb 1 non-interceptable abort
S$Wake rmb 1 wake-up sleeping process
S$Abort rmb 1 keyboard abort
S$Intrpt rmb 1 keyboard interrupt

 pag
**********************************
* Status codes for GetStat/SetStat
*
 org 0
SS.Opt rmb 1 read/Write path descriptor options
SS.Ready rmb 1 check for device ready
SS.Size rmb 1 read/write file size
SS.Reset rmb 1 device restore
 rmb 1
SS.Pos rmb 1 get file's current position
SS.EOF rmb 1 test for end of file
SS.Link rmb 1 link to status routines
SS.ULink rmb 1 unlink status routines
 rmb 1
SS.Frz rmb 1 freeze DD. information
SS.SPT rmb 1 set DD.TKS to given value
 rmb 1
SS.DCmd rmb 1 send direct command to disk
SS.DevNm rmb 1 return device name (32-bytes at [X])
SS.FD rmb 1 return file descriptor (Y-bytes at [X])
SS.Ticks rmb 1 set lockout honor duration
SS.Lock rmb 1 lock/release record
 rmb 1
 rmb 1
SS.BlkRd rmb 1 block read
SS.BlkWr rmb 1 block write
SS.Reten rmb 1 retension cycle
SS.WFM rmb 1 write file mark
SS.RFM rmb 1 read past file mark
SS.ELog rmb 1 read error log
SS.SSig rmb 1 send signal on data ready
SS.Relea rmb 1 release device
 rmb 1
 rmb 1
SS.RsBit rmb 1 reserve bitmap sector (do not allocate in) LSB(X)=sct#
 rmb 1 reserved
 rmb 1
 rmb 3
 rmb 1
 rmb 1
 rmb 1
 rmb 1
SS.ComSt rmb 1 Getstat/SetStat for baud/parity
SS.Open rmb 1 SetStat to tell driver a path was opened
SS.Close rmb 1 SetStat to tell driver a path was closed
SS.HngUp rmb 1 SetStat to tell driver to hangup phone
SS.FSig rmb 1 new signal for temp locked files
 rmb 19

 org $A0
 rmb 1
SS.Fill rmb 1 enable command-line history erase (scf)
 ttl Direct Page Definitions
 pag

**********************************
* Direct page variable definitions
*
 org $00
 org $20
D.FMBM rmb 4 free memory bit map pointers
D.MLIM rmb 2 upper RAM memory limit
D.ModDir rmb 4 module directory pointers (start and end)
D.Init rmb 2 configuration module base address
D.SWI3 rmb 2 SWI3 vector
D.SWI2 rmb 2 SWI2 vector
D.FIRQ rmb 2 FIRQ vector
D.IRQ rmb 2 IRQ vector
D.SWI rmb 2 SWI vector
D.NMI rmb 2 NMI vector
D.SvcIRQ rmb 2 interrupt service entry
D.Poll rmb 2 interrupt polling routine
D.UsrIRQ rmb 2 user interrupt routine
D.SysIRQ rmb 2 system interrupt routine
D.UsrSvc rmb 2 user service request routine
D.SysSvc rmb 2 system service request routine
D.UsrDis rmb 2 user service request dispatch table
D.SysDis rmb 2 system service reuest dispatch table
D.Slice rmb 1 process time slice count
D.PrcDBT rmb 2 process descriptor block table
D.Proc rmb 2 process descriptor address
D.AProcQ rmb 2 active process queue
D.WProcQ rmb 2 waiting process queue
D.SProcQ rmb 2 sleeping process queue
D.Time equ . time
D.Year rmb 1 current year
D.Month rmb 1 current month
D.Day rmb 1 current da
D.Hour rmb 1 current hour
D.Min rmb 1 current minute
D.Sec rmb 1 current second
D.Ticks rmb 4 number of ticks since boot
D.Tick rmb 1 current tick
D.TSec rmb 1 ticks per second
D.TSlice rmb 1 ticks per time-slice
D.IOML rmb 2 I/O manager free memory low bound
D.IOMH rmb 2 I/O manager free memory hi bound
D.DevTbl rmb 2 device driver table address
D.PolTbl rmb 2 interrupt polling table address
D.PthDBT rmb 2 path descriptor block table addrress
D.BTLO rmb 2 bootstrap low address
D.BTHI rmb 2 bootstrap hi address
D.Clock rmb 2 address of clock tick routine
D.Boot rmb 1 bootstrap attempted flag
D.URtoSs rmb 2 address of user to system routine (VIRQ)
D.VIRQTable rmb 2 pointer to virtual IRQ table
D.CRC rmb 1 CRC checking mode flag

 org $100
D.XSWI3 rmb 3
D.XSWI2 rmb 3
D.XSWI rmb 3
D.XNMI rmb 3
D.XIRQ rmb 3
D.XFIRQ rmb 3

* Table Sizes
BMAPSZ equ 65536/256/8 memory allocation bitmap table size
SVCTNM equ 2 number of service request tables
SVCTSZ equ (256-BMAPSZ)/SVCTNM-2 service request table size

 ttl Structure Formats
 pag
************************************
* Module directory entry definitions
*
 org 0
MD$MPtr rmb 2 module pointer
MD$Link rmb 1 module link count
 rmb 1
MD$ESize equ . module directory entry size

************************************
* Module definitions
*
* Universal module offsets
*
 org 0
M$ID rmb 2 ID code
M$Size rmb 2 module size
M$Name rmb 2 module name
M$Type rmb 1 type / language
M$Revs rmb 1 attributes / revision level
M$Parity rmb 1 header parity
M$IDSize equ . Mmdule ID size

*
* Type-dependent module offsets
*
* System, file manager, device driver, program module
*
M$Exec rmb 2 execution entry offset
*
* Device driver, program module
*
M$Mem rmb 2 stack requirement
*
* Device driver, device descriptor module
*
M$Mode rmb 1 device driver mode capabilities
*
* Device descriptor module
*
 org M$IDSize
M$FMgr rmb 2 file manager name offset
M$PDev rmb 2 device driver name offset
 rmb 1 M$Mode (defined above)
M$Port rmb 3 port address
M$Opt rmb 1 device default options
M$DTyp rmb 1 device type
IT.DTP equ M$DTyp descriptor type offset

*
* Configuration module entry offsets
*
 org M$IDSize
CM$MaxMem rmb 3 maximum free memory
CM$PollCnt rmb 1 entries in interrupt polling table
CM$DevCnt rmb 1 entries in device table
CM$TickMod rmb 2 tick generator module name
CM$GoMod rmb 2 startup module name
 ifne _FF_UNIFIED_IO
CM$StoreMod rmb 2 initial storage device name
CM$ConsoleMod rmb 2 initial console device name
 endc
 ifne _FF_BOOTING
CM$BootMod rmb 2 boot module name
 endc
CM$OSLevel rmb 1 operating system level
CM$OSVer rmb 1 operating system version
CM$OSMajor rmb 1 operating system major
CM$OSMinor rmb 1 operating system minor
CM$Feature1 rmb 1 feature byte 1
CM$Feature2 rmb 1 feature byte 2
 rmb 4 reserved for future use

* Feature1 byte definitions
CRCOn equ %00000001 CRC checking on
CRCOff equ %00000000 CRC checking off

 pag
**************************
* Module field definitions
*
* ID field - first two bytes of a module
*
M$ID1 equ $87 module ID code byte one
M$ID2 equ $CD module ID code byte two
M$ID12 equ M$ID1*256+M$ID2

*
* Module type/language field masks
*
TypeMask equ %11110000 type field
LangMask equ %00001111 language field

*
* Module type values
*
Devic equ $F0 device descriptor module
Drivr equ $E0 physical device driver
FlMgr equ $D0 file manager
Systm equ $C0 system module
Data equ $40 data module
Sbrtn equ $20 subroutine module
Prgrm equ $10 program module

*
* Module language values
*
Objct equ 1 object code module

*
* Module attributes / revision byte
*
* Field masks
*
AttrMask equ %11110000 attributes field
RevsMask equ %00001111 revision level field

*
* Attribute flags
*
ReEnt equ %10000000 re-entrant module

********************
* Device type values
*
* These values define various classes of devices, which are
* managed by a file manager module.  The device type is embedded
* in a device descriptor.
*
DT.SCF equ 0 sequential character file manager
DT.RBF equ 1 random block file manager
DT.Pipe equ 2 pipe file manager

*********************
* CRC result constant
*
CRCCon1 equ $80
CRCCon23 equ $0FE3

 ttl Process Information
 pag
********************************
* Process descriptor definitions
*
DefIOSiz equ 12
NumPaths equ 16 number of local paths

 org 0
P$ID rmb 1 process ID
P$PID rmb 1 parent's ID
P$SID rmb 1 sibling's ID
P$CID rmb 1 child's ID
P$SP rmb 2 stack pointer
P$CHAP rmb 1 process chapter number
P$ADDR rmb 1 user address beginning page number
P$PagCnt rmb 1 memory page count
P$User rmb 2 user index
P$Prior rmb 1 priority
P$Age rmb 1 age
P$State rmb 1 status
P$Queue rmb 2 queue link (process pointer)
P$IOQP rmb 1 previous I/O queue link (process ID)
P$IOQN rmb 1 next I/O queue link (process ID)
P$PModul rmb 2 primary module
P$SWI rmb 2 SWI entry point
P$SWI2 rmb 2 SWI2 entry point
P$SWI3 rmb 2 SWI3 entry point
P$DIO rmb DefIOSiz default I/O pointers
P$PATH rmb NumPaths I/O path table
P$Signal rmb 1 signal code
P$SigVec rmb 2 signal intercept vector
P$SigDat rmb 2 signal intercept data address
P$NIO rmb 4
 rmb $40-. unused
P$Size equ . size of process descriptor

*
* Process state flags
*
SysState equ %10000000
TimSleep equ %01000000
TimOut equ %00100000
ImgChg equ %00010000
Condem equ %00000010
Dead equ %00000001

 ttl I/O Definitions
 pag
*************************
* Path descriptor offsets
*
 org 0
PD.PD rmb 1 path number
PD.MOD rmb 1 mode (read/write/update)
PD.CNT rmb 1 number of open images
PD.DEV rmb 2 device table entry address
PD.CPR rmb 1 current process
PD.RGS rmb 2 caller's register stack
PD.BUF rmb 2 buffer address
PD.FST rmb 32-. file manager's storage
PD.OPT equ . path descriptor options
PD.DTP rmb 1 device type
 rmb 64-. path options end
PDSIZE equ .

*
* Pathlist special symbols
*
PDELIM equ '/ pathlist name separator
PDIR equ '. directory
PENTIR equ '@ entire device

 pag
****************************
* File manager entry offsets
*
 org 0
FMCREA rmb 3 create (open new) file
FMOPEN rmb 3 open file
FMMDIR rmb 3 make directory
FMCDIR rmb 3 change directory
FMDLET rmb 3 delete file
FMSEEK rmb 3 position file
FMREAD rmb 3 read from file
FMWRIT rmb 3 write to file
FMRDLN rmb 3 read line
FMWRLN rmb 3 write line
FMGSTA rmb 3 get file status
FMSSTA rmb 3 set file status
FMCLOS rmb 3 close file

*****************************
* Device driver entry offsets
*
 org 0
D$INIT rmb 3 device initialization
D$READ rmb 3 read from device
D$WRIT rmb 3 write to device
D$GSTA rmb 3 get device status
D$PSTA rmb 3 put device status
D$TERM rmb 3 device termination

*********************
* Device table format
*
 org 0
V$DRIV rmb 2 device driver module
V$STAT rmb 2 device driver static storage
V$DESC rmb 2 device descriptor module
V$FMGR rmb 2 file manager module
V$USRS rmb 1 use count
DEVSIZ equ .

*******************************
* Device static storage offsets
*
 org 0
V.PAGE rmb 1 port extended address
V.PORT rmb 2 device 'base' port address
V.LPRC rmb 1 last active process ID
V.BUSY rmb 1 active process ID (0=not busy)
V.WAKE rmb 1 active process descriptor if driver MUST wake-up
V.USER equ . driver allocation origin

********************************
* Interrupt polling table format
*
 org 0
Q$Poll rmb 2 absolute polling address
Q$Flip rmb 1 flip (EOR) byte; normally zero
Q$Mask rmb 1 polling mask (after flip)
Q$Serv rmb 2 absolute service routine Address
Q$Stat rmb 2 static storage address
Q$Prty rmb 1 priority (low numbers=top priority)
POLSIZ equ .

********************
* VIRQ packet format
*
 org 0
Vi.Cnt rmb 2 count down counter
Vi.Rst rmb 2 reset value for counter
Vi.Stat rmb 1 status byte
Vi.PkSz equ .

Vi.IFlag equ %00000001 status byte virq flag

 pag
*************************************
* Machine characteristics definitions
*
R$CC equ 0 condition codes register
R$A equ 1 A accumulator
R$B equ 2 B accumulator
R$D equ R$A combined A:B accumulator
R$DP equ 3 direct page register
R$X equ 4 X index register
R$Y equ 6 Y index register
R$U equ 8 user stack register
R$PC equ 10 program counter register
R$Size equ 12 total register package size

Entire equ %10000000 full register stack flag
FIRQMask equ %01000000 fast interrupt mask bit
HalfCrry equ %00100000 half carry flag
IRQMask equ %00010000 interrupt mask bit
Negative equ %00001000 negative flag
Zero equ %00000100 zero flag
TwosOvfl equ %00000010 two's complement overflow flag
Carry equ %00000001 carry bit
IntMasks equ IRQMask+FIRQMask
Sign equ %10000000 sign bit

 ttl Error code definitions
 pag
************************
* Error code definitions
*
 org 200
E$PthFul rmb 1 path table full
E$BPNum rmb 1 bad path number
E$Poll rmb 1 polling table Full
E$BMode rmb 1 bad Mode
E$DevOvf rmb 1 device table overflow
E$BMID rmb 1 bad module ID
E$DirFul rmb 1 module directory full
E$MemFul rmb 1 process memory full
E$UnkSvc rmb 1 unknown service code
E$ModBsy rmb 1 module busy
E$BPAddr rmb 1 bad page address
E$EOF rmb 1 end of file
 rmb 1
E$NES rmb 1 non-existent segment
E$FNA rmb 1 file not accesible
E$BPNam rmb 1 bad path name
E$PNNF rmb 1 path name Not Found
E$SLF rmb 1 segment list full
E$CEF rmb 1 creating existing file
E$IBA rmb 1 illegal block address
E$HangUp rmb 1 carrier detect lost
E$MNF rmb 1 module not found
 rmb 1
E$DelSP rmb 1 deleting stack pointer memory
E$IPrcID rmb 1 illegal process ID
E$BPrcID equ E$IPrcID bad process ID
 rmb 1
E$NoChld rmb 1 no children
E$ISWI rmb 1 illegal SWI code
E$PrcAbt rmb 1 process aborted
E$PrcFul rmb 1 process table full
E$IForkP rmb 1 illegal fork parameter
E$KwnMod rmb 1 known module
E$BMCRC rmb 1 bad module CRC
E$USigP rmb 1 unprocessed signal pending
E$NEMod rmb 1 non-existent module
E$BNam rmb 1 bad name
E$BMHP rmb 1 bad module header parity
E$NoRAM rmb 1 no system RAM available
E$DNE rmb 1 directory not empty
E$NoTask rmb 1 no available task number
 rmb $F0-. reserved
E$Unit rmb 1 illegal media unit
E$Sect rmb 1 bad sector number
E$WP rmb 1 write protect
E$CRC rmb 1 bad checksum
E$Read rmb 1 read error
E$Write rmb 1 write error
E$NotRdy rmb 1 device not ready
E$Seek rmb 1 seek error
E$Full rmb 1 media full
E$BTyp rmb 1 bad type (incompatible) media
E$DevBsy rmb 1 device busy
E$DIDC rmb 1 media ID change
E$Lock rmb 1 record is busy (locked out)
E$Share rmb 1 non-sharable file busy
E$DeadLk rmb 1 I/O deadlock error

* Character definitions
C$Space set $20
C$Period set '.
C$Comma set ',
C$CR set $0D
C$LF set $0A

 endc
