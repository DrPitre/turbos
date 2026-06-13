PORTNAME	= f256

ifndef TURBOSDIR
	TURBOSDIR=$(HOME)/Projects/turbos
endif

include $(TURBOSDIR)/ports/rules.mak

VPATH=$(TURBOSDIR)/source/modules $(TURBOSDIR)/source/commands $(TURBOSDIR)/source/kernel $(TURBOSDIR)/tests

AFLAGS += -DPORTNAME="$(PORTNAME)" -D$(PORTNAME)

COMMANDS	= go go2
MODULES	= kernel init tkf256
OBJS	= $(MODULES) $(COMMANDS)

all:	loader

KERNEL_SOURCES = kernel.asm fallbit.asm faproc.asm fchain.asm fcmpnam.asm fcrc.asm \
	ffork.asm flink.asm fnproc.asm fprsnam.asm fsrqmem.asm fssvc.asm \
	fvmodul.asm \
	iocall.asm funlink.asm fwait.asm fexit.asm fmem.asm fsend.asm fsleep.asm \
	ficpt.asm fsprior.asm fid.asm fsswi.asm \
	ffind64.asm fall64.asm fret64.asm

MODULE_SOURCES	= init.asm tkf256.asm

kernel: $(KERNEL_SOURCES)

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