PORTNAME	= wildbits

ifndef TURBOSDIR
	TURBOSDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
endif

include $(TURBOSDIR)/ports/rules.mak

VPATH=$(TURBOSDIR)/source/modules $(TURBOSDIR)/source/commands $(TURBOSDIR)/source/kernel $(TURBOSDIR)/tests

AFLAGS += -DPORTNAME="$(PORTNAME)" -D$(PORTNAME)

COMMANDS	= go go2
MODULES	= kernel init tkf256
OBJS	= $(MODULES) $(COMMANDS)

all:	loader

KERNEL_SOURCES = $(TURBOSDIR)/source/kernel/kernel.asm $(TURBOSDIR)/source/kernel/firq.asm $(NITROS9_KERNEL_DIR)/fallbit.asm $(NITROS9_KERNEL_DIR)/faproc.asm $(NITROS9_KERNEL_DIR)/fchain.asm $(NITROS9_KERNEL_DIR)/fcmpnam.asm $(NITROS9_KERNEL_DIR)/fcrc.asm \
	$(NITROS9_KERNEL_DIR)/ffork.asm $(NITROS9_KERNEL_DIR)/flink.asm $(NITROS9_KERNEL_DIR)/fnproc.asm $(NITROS9_KERNEL_DIR)/fprsnam.asm $(NITROS9_KERNEL_DIR)/fsrqmem.asm $(NITROS9_KERNEL_DIR)/fssvc.asm \
	$(NITROS9_KERNEL_DIR)/fvmodul.asm \
	$(NITROS9_KERNEL_DIR)/iocall.asm $(NITROS9_KERNEL_DIR)/funlink.asm $(NITROS9_KERNEL_DIR)/fwait.asm $(NITROS9_KERNEL_DIR)/fexit.asm $(NITROS9_KERNEL_DIR)/fmem.asm $(NITROS9_KERNEL_DIR)/fsend.asm $(NITROS9_KERNEL_DIR)/fsleep.asm \
	$(NITROS9_KERNEL_DIR)/ficpt.asm $(NITROS9_KERNEL_DIR)/fsprior.asm $(NITROS9_KERNEL_DIR)/fid.asm $(NITROS9_KERNEL_DIR)/fsswi.asm \
	$(NITROS9_KERNEL_DIR)/ffind64.asm $(NITROS9_KERNEL_DIR)/fall64.asm $(NITROS9_KERNEL_DIR)/fret64.asm

MODULE_SOURCES	= init.asm tkf256.asm

kernel: $(KERNEL_SOURCES)
	$(AS) $(AFLAGS) $< -o$@

lint: *.asm $(KERNEL_SOURCES) $(MODULE_SOURCES)
	$(foreach file,$^,mamou -ls -p $(file) > /tmp/lint.out; mv /tmp/lint.out $(file) ;)

loader: $(OBJS)
	cat $(OBJS) > kernel.rom
	os9 dump -a kernel.rom > kernel.dump
	$(ASBIN) $(AFLAGS) --raw loader.asm $(ASOUT)loader
	ls -l loader

clean:
	-$(RM) $(OBJS) kernel.rom loader kernel.dump *.list *.map

gh:
	open "http://www.github.com/boisy/turbos"

upload: loader
	upload loader e000

# Rebuild layout-dependent modules when shared flags or port definitions change.
$(OBJS): $(NITROS9_KERNEL_DIR)/features.d defs.d $(DEFSDIR)/turbos.d $(DEFSDIR)/defsfile $(DEFSDIR)/scf.d Makefile
