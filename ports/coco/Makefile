PORTNAME	= coco

ifndef TURBOSDIR
	TURBOSDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
endif

include $(TURBOSDIR)/ports/rules.mak

VPATH=$(TURBOSDIR)/source/modules $(TURBOSDIR)/source/commands $(TURBOSDIR)/source/kernel $(TURBOSDIR)/tests

AFLAGS += -DPORTNAME="$(PORTNAME)" -D$(PORTNAME)
MAME_AUTOBOOT_DELAY ?= 2

MODULES	= kernel init tkcc
OBJS_VDG	= $(MODULES) go

all:	dsk

KERNEL_SOURCES = $(TURBOSDIR)/source/kernel/kernel.asm $(TURBOSDIR)/source/kernel/firq.asm $(NITROS9_KERNEL_DIR)/fallbit.asm $(NITROS9_KERNEL_DIR)/faproc.asm $(NITROS9_KERNEL_DIR)/fchain.asm $(NITROS9_KERNEL_DIR)/fcmpnam.asm $(NITROS9_KERNEL_DIR)/fcrc.asm \
	$(NITROS9_KERNEL_DIR)/ffork.asm $(NITROS9_KERNEL_DIR)/flink.asm $(NITROS9_KERNEL_DIR)/fnproc.asm $(NITROS9_KERNEL_DIR)/fprsnam.asm $(NITROS9_KERNEL_DIR)/fsrqmem.asm $(NITROS9_KERNEL_DIR)/fssvc.asm \
	$(NITROS9_KERNEL_DIR)/fvmodul.asm $(TURBOSDIR)/source/kernel/firq.asm \
	$(NITROS9_KERNEL_DIR)/iocall.asm $(NITROS9_KERNEL_DIR)/funlink.asm $(NITROS9_KERNEL_DIR)/fwait.asm $(NITROS9_KERNEL_DIR)/fexit.asm $(NITROS9_KERNEL_DIR)/fmem.asm $(NITROS9_KERNEL_DIR)/fsend.asm $(NITROS9_KERNEL_DIR)/fsleep.asm \
	$(NITROS9_KERNEL_DIR)/ficpt.asm $(NITROS9_KERNEL_DIR)/fsprior.asm $(NITROS9_KERNEL_DIR)/fid.asm $(NITROS9_KERNEL_DIR)/fsswi.asm \
	$(NITROS9_KERNEL_DIR)/ffind64.asm $(NITROS9_KERNEL_DIR)/fall64.asm $(NITROS9_KERNEL_DIR)/fret64.asm

MODULE_SOURCES	= init.asm tkcc.asm

kernel: $(KERNEL_SOURCES)
	$(AS) $(AFLAGS) $< -o$@

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
	xroar --load-fd0 vdg.dsk

run: vdg.dsk
	mame -rompath $(MAME_ROM_PATH) coco2b -flop1 $^ -window -skip_gameinfo -nothrottle -autoboot_delay $(MAME_AUTOBOOT_DELAY) -autoboot_command 'RUN"*"\n'

showsizes: all
	ls -l $(OBJS_VDG)

# Rebuild layout-dependent modules when shared flags or port definitions change.
$(MODULES) go: $(NITROS9_KERNEL_DIR)/features.d defs.d $(DEFSDIR)/turbos.d $(DEFSDIR)/defsfile $(DEFSDIR)/scf.d Makefile
