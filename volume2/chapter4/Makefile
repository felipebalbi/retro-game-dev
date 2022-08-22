SRC1		:= gameMain1.asm
SRC2		:= gameMain2.asm
SRC3		:= gameMain3.asm

CHAP1		:= chapter4_1
CHAP2		:= chapter4_2
CHAP3		:= chapter4_3

PRG1		:= $(CHAP1).prg
PRG2		:= $(CHAP2).prg
PRG3		:= $(CHAP3).prg

SYM1		:= $(PRG1:%.prg=%.sym)
SYM2		:= $(PRG2:%.prg=%.sym)
SYM3		:= $(PRG3:%.prg=%.sym)

D641		:= $(PRG1:%.prg=%.d64)
D642		:= $(PRG2:%.prg=%.d64)
D643		:= $(PRG3:%.prg=%.d64)

DISK1		:= $(CHAP1)
DISK2		:= $(CHAP2)
DISK3		:= $(CHAP3)

# Pretty print
V		= @
Q		= $(V:1=)
QUIET_AS	= $(Q:@=@echo    '     AS       '$@;)
QUIET_X64	= $(Q:@=@echo    '     X64      '$@;)
QUIET_D64	= $(Q:@=@echo    '     D64      '$@;)
QUIET_CLEAN	= $(Q:@=@echo    '     CLEAN    '$@;)

# Programs
X64		:= $(shell which x64)

ifeq (, $(X64))
X64		:= $(shell which x64sc)
endif

AS		:= $(shell which acme)
RM		:= $(shell which rm)
C1541		:= $(shell which c1541)

# Flags
ASFLAGS1	:= --color -l $(SYM1) -I ../lib/ -I ../assets/
ASFLAGS2	:= --color -l $(SYM2) -I ../lib/ -I ../assets/
ASFLAGS3	:= --color --vicelabels $(SYM3) -I ../lib/ -I ../assets/
C1541_FLAGS1	:= -format $(DISK1),1 d64 $(D641) 8 -attach $(D641)	\
                   $(foreach p,$(PRG1),-write $(p) $(subst .prg,,$(p)))
C1541_FLAGS2	:= -format $(DISK2),1 d64 $(D642) 8 -attach $(D642)	\
                   $(foreach p,$(PRG2),-write $(p) $(subst .prg,,$(p)))
C1541_FLAGS3	:= -format $(DISK3),1 d64 $(D643) 8 -attach $(D643)	\
                   $(foreach p,$(PRG3),-write $(p) $(subst .prg,,$(p)))

# Rules
all: $(D641) $(D642) $(D643)

$(D641): $(PRG1)
	$(QUIET_D64) $(C1541) $(C1541_FLAGS1) 1> /dev/null

$(D642): $(PRG2)
	$(QUIET_D64) $(C1541) $(C1541_FLAGS2) 1> /dev/null

$(D643): $(PRG3)
	$(QUIET_D64) $(C1541) $(C1541_FLAGS3) 1> /dev/null

$(PRG1): $(SRC1)
	$(QUIET_AS) $(AS) $(ASFLAGS1) -o $@ -f cbm $<

$(PRG2): $(SRC2)
	$(QUIET_AS) $(AS) $(ASFLAGS2) -o $@ -f cbm $<

$(PRG3): $(SRC3)
	$(QUIET_AS) $(AS) $(ASFLAGS3) -o $@ -f cbm $<

run1: run

run: $(D641)
	$(QUIET_X64) $(X64) -autostart $(D641) -autostart-warp

run2: $(D642)
	$(QUIET_X64) $(X64) -autostart $(D642) -autostart-warp

run3: $(D643)
	$(QUIET_X64) $(X64) -autostart $(D643) -autostart-warp

clean:
	$(QUIET_CLEAN) $(RM) -f *.prg *.d64 *.sym
