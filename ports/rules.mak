# Project-Wide Rules

# Included source-generation rules appear before each port's `all` target.
# Keep those helper rules from becoming GNU Make's implicit default goal.
.DEFAULT_GOAL := all

# Environment variables are used to specify any directories other
# than the defaults below:
#
#   TURBOSDIR   - base directory of the project on your system
#
# If the defaults below are fine, then there is no need to set any
# environment variables.

# TurbOS version, major and minor release numbers are here
TURBOS_MAJOR       = 0
TURBOS_MINOR       = 1
TURBOS_MININUM     = 0

#################### DO NOT CHANGE ANYTHING BELOW THIS LINE ####################

OS9                 = os9

TURBOS_VERSION     = v$(TURBOS_MAJOR).$(TURBOS_MINOR)

DEFSDIR             = $(TURBOSDIR)/source/include
DSKDIR              = $(TURBOSDIR)/disk_images
NITROS9_CHECKOUT     = $(TURBOSDIR)/.upstream/nitros9
NITROS9_GENERATED    = $(TURBOSDIR)/.upstream/generated/source
NITROS9_KERNEL_DIR   = $(NITROS9_GENERATED)/kernel
NITROS9_COMMAND_DIR  = $(NITROS9_GENERATED)/commands
NITROS9_MODULE_DIR   = $(NITROS9_GENERATED)/modules
NITROS9_IMPORTER     = $(TURBOSDIR)/scripts/nitros9-upstream.py

NITROS9_DERIVED_SOURCES = $(NITROS9_KERNEL_DIR)/features.d \
	$(NITROS9_KERNEL_DIR)/fall64.asm \
	$(NITROS9_KERNEL_DIR)/fchain.asm $(NITROS9_KERNEL_DIR)/fcrc.asm \
	$(NITROS9_KERNEL_DIR)/ffind64.asm $(NITROS9_KERNEL_DIR)/ficpt.asm \
	$(NITROS9_KERNEL_DIR)/fid.asm $(NITROS9_KERNEL_DIR)/flink.asm \
	$(NITROS9_KERNEL_DIR)/fret64.asm $(NITROS9_KERNEL_DIR)/fsend.asm \
	$(NITROS9_KERNEL_DIR)/fsprior.asm $(NITROS9_KERNEL_DIR)/fsrqmem.asm \
	$(NITROS9_KERNEL_DIR)/fssvc.asm $(NITROS9_KERNEL_DIR)/fsswi.asm \
	$(NITROS9_KERNEL_DIR)/funlink.asm $(NITROS9_KERNEL_DIR)/fallbit.asm \
	$(NITROS9_KERNEL_DIR)/faproc.asm $(NITROS9_KERNEL_DIR)/fexit.asm \
	$(NITROS9_KERNEL_DIR)/ffork.asm $(NITROS9_KERNEL_DIR)/fmem.asm \
	$(NITROS9_KERNEL_DIR)/fnproc.asm $(NITROS9_KERNEL_DIR)/fvmodul.asm \
	$(NITROS9_KERNEL_DIR)/fwait.asm $(NITROS9_KERNEL_DIR)/iocall.asm \
	$(NITROS9_KERNEL_DIR)/fcmpnam.asm $(NITROS9_KERNEL_DIR)/fprsnam.asm \
	$(NITROS9_KERNEL_DIR)/fsleep.asm \
	$(NITROS9_COMMAND_DIR)/mfree.asm $(NITROS9_COMMAND_DIR)/procs.asm \
	$(NITROS9_MODULE_DIR)/ioman.asm $(NITROS9_MODULE_DIR)/scf.asm

# Assembler definitions
KERNELINCLUDES      = --includedir=$(TURBOSDIR)/source/kernel --includedir=$(NITROS9_KERNEL_DIR)
AS                  = lwasm --6309 --format=os9 --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=. --includedir=$(DEFSDIR) $(KERNELINCLUDES)
ASROM               = lwasm --6309 --format=raw --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=. --includedir=$(DEFSDIR) $(KERNELINCLUDES)
ASBIN               = lwasm --6309 --format=decb --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=. --includedir=$(DEFSDIR) $(KERNELINCLUDES)
ASOUT               = -o
ifdef LISTDIR
ASOUT               = --list=$(LISTDIR)/$@.lst --symbols -o
endif
AFLAGS              = -DTURBOS_MAJOR=$(TURBOS_MAJOR) -DTURBOS_MINOR=$(TURBOS_MINOR) -DTURBOS_MININUM=$(TURBOS_MININUM) -DLEVEL=1
# RMA/RLINK
ASM                 = lwasm --6309 --format=obj --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,noforwardrefmax,export --includedir=. --includedir=$(DEFSDIR)
LINKER              = lwlink --format=os9
LWAR                = lwar -c

# Commands
MAKDIR              = $(OS9) makdir
RM                  = rm -f
MERGE               = cat
MOVE                = mv
ECHO                = echo
CD                  = cd
CP                  = cp
OS9COPY             = $(OS9) copy -o=0
CPL                 = $(OS9COPY) -l
TAR                 = tar
CHMOD               = chmod
IDENT               = $(OS9) ident
IDENT_SHORT         = $(IDENT) -s
OS9FORMAT           = $(OS9) format -e
OS9RENAME           = $(OS9) rename
OS9ATTR             = $(OS9) attr -q
OS9ATTR_TEXT        = $(OS9ATTR) -npe -npw -pr -ne -w -r
OS9ATTR_EXEC        = $(OS9ATTR) -pe -npw -pr -e -w -r
PADROM              = $(OS9) padrom
MOUNT               = sudo mount
UMOUNT              = sudo umount
LOREMOVE            = sudo losetup -d
LOSETUP             = sudo losetup
LINK                = ln
SOFTLINK            = $(LINK) -s
ARCHIVE             = zip -D -9 -j

# One producer for the complete generated set (compatible with Make 3.81).
NITROS9_STAMP = $(TURBOSDIR)/.upstream/generated/.materialized
ifneq ($(words $(wildcard $(NITROS9_DERIVED_SOURCES))),$(words $(NITROS9_DERIVED_SOURCES)))
.PHONY: nitros9-missing
$(NITROS9_STAMP): nitros9-missing
endif

$(NITROS9_STAMP): $(NITROS9_IMPORTER) $(TURBOSDIR)/upstream/nitros9.sources $(TURBOSDIR)/upstream/nitros9.rev
	python3 $(NITROS9_IMPORTER) materialize --checkout $(NITROS9_CHECKOUT)
	touch $@

$(NITROS9_DERIVED_SOURCES): $(NITROS9_STAMP)
	@test -f $@

# C Rules
%.o: %.c
	$(CC) $(CFLAGS) $< -r

%.a: %.o
	lwar -c $@ $?

%: %.o
	$(LINKER) $(LFLAGS) $^ -o$@

%: %.a
	$(LINKER) $(LFLAGS) $^ -o$@

%.o: %.as
	$(ASM) $(AFLAGS) $< $(ASOUT)$@

# File managers
%.mn: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Device drivers
%.dr: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Device descriptors
%.dd: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Subroutine modules
%.sb: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Terminal device descriptors
%.dt: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# I/O subroutines
%.io: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# All other modules
%: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@
