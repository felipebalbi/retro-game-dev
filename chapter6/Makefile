SRC		:= gameMain.asm
CHAP		:= chapter6
PRG		:= $(CHAP).prg
SYM		:= $(PRG:%.prg=%.sym)
D64		:= $(PRG:%.prg=%.d64)
DISK		:= $(basename $(SRC))

# Pretty print
V		= @
Q		= $(V:1=)
QUIET_AS	= $(Q:@=@echo    '     AS       '$@;)
QUIET_X64	= $(Q:@=@echo    '     X64      '$@;)
QUIET_D64	= $(Q:@=@echo    '     D64      '$@;)
QUIET_CLEAN	= $(Q:@=@echo    '     CLEAN    '$@;)

# Programs
X64		:= $(shell which x64)
AS		:= $(shell which acme)
RM		:= $(shell which rm)
C1541		:= $(shell which c1541)

# Flags
ASFLAGS		:= --color -l $(SYM)
C1541_FLAGS	:= -format $(DISK),1 d64 $(D64) 8 -attach $(D64)	\
                   $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(p)))

# Rules
all: $(D64)

$(D64): $(PRG)
	$(QUIET_D64) $(C1541) $(C1541_FLAGS) 1> /dev/null

$(PRG): $(SRC)
	$(QUIET_AS) $(AS) $(ASFLAGS) -o $@ -f cbm $<

run: $(D64)
	$(QUIET_X64) $(X64) -autostart $(D64) -autostart-warp

clean:
	$(QUIET_CLEAN) $(RM) -f *.prg *.d64 *.sym
