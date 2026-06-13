* FNXLoader - Loads the TurbOS kernel into an F256 Jr. in RAM mode.
*
* This program move the kernel into high RAM then jumps to the kernel.
               use       defs.d

               org       $E000

Start          equ       *               
* Include the assembly dump of the kernel here
               use       kernel.dump
 
               fill      $FF,$10000-*-14
* 6809 vectors
               fdb       $0100
               fdb       $0103
               fdb       $010F
               fdb       $010C
               fdb       $0106
               fdb       $0109
               fdb       $E014

               end
