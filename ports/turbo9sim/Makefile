PORTNAME	= turbo9sim

# Assemble-time capability flags
#
# Feature Flags - eliminating one or more of these capabilities saves code space.
#
# Manage your own interrupts or install interrupt service routines using F$IRQ.
#_FF_IRQ_POLL           Set to 1 for interrupt service routine polling
#
# Use virtual interrupt service routines using F$VIRQ.
#_FF_VIRQ_POLL          Set to 1 for virtual interrupt service routine polling
#
# Wall time gives year/month/date/hour/minute/second support.
#_FF_WALLTIME           Set to 1 for a software wall time clock
#
# Module CRC and header parity checks are useful for integrity, but slows down loading.
#_FF_MODCHECK           Set to 1 for module header and CRC checking
#
# Unified I/O adds a standard device interface at the expense of more memory.
#_FF_UNIFIED_IO         Set to 1 for unified I/O
#
# Booting from an external storage device can bring in additional functionality.
#_FF_BOOTING            Set to 1 for bootfile loading

KERNEL_FULL = -D_FF_IRQ_POLL=1 -D_FF_VIRQ_POLL=1 -D_FF_WALLTIME=1 -D_FF_MODCHECK=1 -D_FF_UNIFIED_IO=1 -D_FF_BOOTING=1
KERNEL_MIN  = -D_FF_IRQ_POLL=0 -D_FF_VIRQ_POLL=0 -D_FF_WALLTIME=0 -D_FF_MODCHECK=0 -D_FF_UNIFIED_IO=0 -D_FF_BOOTING=0
KERNEL_UIO  = -D_FF_IRQ_POLL=0 -D_FF_VIRQ_POLL=0 -D_FF_WALLTIME=0 -D_FF_MODCHECK=0 -D_FF_UNIFIED_IO=1 -D_FF_BOOTING=0

ifndef TURBOSDIR
	TURBOSDIR=$(HOME)/Projects/turbos
endif

include $(TURBOSDIR)/ports/rules.mak

VPATH=$(TURBOSDIR)/source/modules $(TURBOSDIR)/source/commands $(TURBOSDIR)/source/kernel $(TURBOSDIR)/tests

AFLAGS += -DPORTNAME="$(PORTNAME)" -D$(PORTNAME) -DLEVEL=1

COMMANDS = go
KERNELS  = kernel_full kernel_uio kernel_min

OBJS_FULL = kernel_full init tkt9sim_full ioman_full scf scvt term go_fork shell mfree mdir procs
OBJS_UIO = kernel_uio init tkt9sim_uio ioman_uio scf scvt term $(COMMANDS)
OBJS_MIN = kernel_min init tkt9sim_min $(COMMANDS)
OBJS_SMOKE = kernel_min init tkt9sim_min go_smoke

all:	turbos_full.img turbos_uio.img turbos_min.img
	ls -l turbos_full.img.rom turbos_uio.img.rom turbos_min.img.rom

KERNEL_SOURCES = kernel.asm fallbit.asm faproc.asm fchain.asm fcmpnam.asm fcrc.asm \
	ffork.asm flink.asm fnproc.asm fprsnam.asm fsrqmem.asm fssvc.asm \
	fvmodul.asm \
	iocall.asm funlink.asm fwait.asm fexit.asm fmem.asm fsend.asm fsleep.asm \
	ficpt.asm fsprior.asm fid.asm fsswi.asm \
	ffind64.asm fall64.asm fret64.asm

MODULE_SOURCES	= init.asm tkt9sim.asm

kernel_full: $(KERNEL_SOURCES)
	$(AS) $(KERNEL_FULL) $? -o$@

kernel_uio: $(KERNEL_SOURCES)
	$(AS) $(KERNEL_UIO) $? -o$@
	
kernel_min: $(KERNEL_SOURCES)
	$(AS) $(KERNEL_MIN) $? -o$@
	
ioman_full: ioman.asm
	$(AS) $(KERNEL_FULL) $? -o$@

ioman_uio: ioman.asm
	$(AS) $(KERNEL_UIO) $? -o$@
	
tkt9sim_full: tkt9sim.asm
	$(AS) $(KERNEL_FULL) $? -o$@

tkt9sim_uio: tkt9sim.asm
	$(AS) $(KERNEL_UIO) $? -o$@
	
tkt9sim_min: tkt9sim.asm
	$(AS) $(KERNEL_MIN) $? -o$@

go_smoke: go_smoke.asm
	$(AS) $(KERNEL_MIN) $? -o$@
	
lint: *.asm $(KERNEL_SOURCES) $(MODULE_SOURCES)
	$(foreach file,$^,mamou -ls -p $(file) > /tmp/lint.out; mv /tmp/lint.out $(file) ;)

#PADSIZE=65280
PADSIZE=65280

turbos_full.img: $(OBJS_FULL)
	cat $^ > $@.rom
	cat $@.rom > $@.tmp
	os9 padrom -b -c=0 $(PADSIZE) $@.tmp
	dd if=/dev/zero of=lastpage.tmp bs=1 count=240
	printf "\x00\x00\x01\x00\x01\x03\x01\x0F\x01\x0C\x01\x06\x01\x09" > vectors.tmp
	echo "obase=16; $(PADSIZE)-`wc -c <$@.rom`+20" | bc | xxd -r -p >> vectors.tmp
	cat $@.tmp lastpage.tmp vectors.tmp > $@
	rm *.tmp

turbos_uio.img: $(OBJS_UIO)
	cat $^ > $@.rom
	cat $@.rom > $@.tmp
	os9 padrom -b -c=0 $(PADSIZE) $@.tmp
	dd if=/dev/zero of=lastpage.tmp bs=1 count=240
	printf "\x00\x00\x01\x00\x01\x03\x01\x0F\x01\x0C\x01\x06\x01\x09" > vectors.tmp
	echo "obase=16; $(PADSIZE)-`wc -c <$@.rom`+20" | bc | xxd -r -p >> vectors.tmp
	cat $@.tmp lastpage.tmp vectors.tmp > $@
	rm *.tmp

turbos_min.img: $(OBJS_MIN)
	cat $^ > $@.rom
	cat $@.rom > $@.tmp
	os9 padrom -b -c=0 $(PADSIZE) $@.tmp
	dd if=/dev/zero of=lastpage.tmp bs=1 count=240
	printf "\x00\x00\x01\x00\x01\x03\x01\x0F\x01\x0C\x01\x06\x01\x09" > vectors.tmp
	echo "obase=16; $(PADSIZE)-`wc -c <$@.rom`+20" | bc | xxd -r -p >> vectors.tmp
	cat $@.tmp lastpage.tmp vectors.tmp > $@
	rm *.tmp

turbos_smoke.img: $(OBJS_SMOKE)
	cat $^ > $@.rom
	cat $@.rom > $@.tmp
	os9 padrom -b -c=0 $(PADSIZE) $@.tmp
	dd if=/dev/zero of=lastpage.tmp bs=1 count=240
	printf "\x00\x00\x01\x00\x01\x03\x01\x0F\x01\x0C\x01\x06\x01\x09" > vectors.tmp
	echo "obase=16; $(PADSIZE)-`wc -c <$@.rom`+20" | bc | xxd -r -p >> vectors.tmp
	cat $@.tmp lastpage.tmp vectors.tmp > $@
	rm *.tmp
	
clean:
	-$(RM) $(OBJS_FULL) $(OBJS_UIO) $(OBJS_MIN) $(OBJS_SMOKE) *.rom *.img *.tmp *.list *.map lastpage

gh:
	open "http://www.github.com/boisy/turbos"
