PORTNAME	= coco

ifndef TURBOSDIR
	TURBOSDIR=$(HOME)/Projects/turbos
endif

include $(TURBOSDIR)/ports/rules.mak

VPATH=$(TURBOSDIR)/source/modules $(TURBOSDIR)/source/commands $(TURBOSDIR)/source/kernel $(TURBOSDIR)/tests

AFLAGS += -DPORTNAME="$(PORTNAME)" -D$(PORTNAME)
MAME_AUTOBOOT_DELAY ?= 2

MODULES	= kernel init tkcc
OBJS_VDG	= $(MODULES) go

all:	dsk

KERNEL_SOURCES = kernel.asm fallbit.asm faproc.asm fchain.asm fcmpnam.asm fcrc.asm \
	ffork.asm flink.asm fnproc.asm fprsnam.asm fsrqmem.asm fssvc.asm \
	fvmodul.asm firq.asm \
	iocall.asm funlink.asm fwait.asm fexit.asm fmem.asm fsend.asm fsleep.asm \
	ficpt.asm fsprior.asm fid.asm fsswi.asm \
	ffind64.asm fall64.asm fret64.asm

MODULE_SOURCES	= init.asm tkcc.asm

kernel: $(KERNEL_SOURCES) defs.d

lint: *.asm $(KERNEL_SOURCES) $(MODULE_SOURCES)
	$(foreach file,$^,mamou -ls -p $(file) > /tmp/lint.out; mv /tmp/lint.out $(file) ;)

dsk: vdg.dsk

vdg.dsk: $(OBJS_VDG)
	cat $^ > kernel.rom
	os9 dump -a kernel.rom > kernel.dump
	$(ASBIN) $(AFLAGS) cocoloader.asm $(ASOUT)cocoloader
	decb dskini $@
	echo "10 LOADM\"KERNEL.BIN\":EXEC" > /tmp/loader.bas
	decb copy -b -0 -t /tmp/loader.bas $@,\*.BAS
	decb copy -b -2 cocoloader $@,KERNEL.BIN

clean:
	-$(RM) $(OBJS_VDG) kernel.rom kernel.dump cocoloader *.dsk *.list *.map

gh:
	open "http://www.github.com/boisy/turbos"

xroar_mac: dsk
	/Applications/Xroar.app/Contents/MacOS/xroar --load-fd0 vdg.dsk

run: vdg.dsk
	mame -rompath $(MAME_ROM_PATH) coco2b -flop1 $^ -window -skip_gameinfo -nothrottle -autoboot_delay $(MAME_AUTOBOOT_DELAY) -autoboot_command 'RUN"*"\n'

showsizes: all
	ls -l $(OBJS_VDG)
