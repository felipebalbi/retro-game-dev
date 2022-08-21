;;; ============================================================================
;;;                        RetroGameDev Library C64 v2.02
;;; ============================================================================

;;; ============================================================================
;;; Constants

;;; Misc
True  = 1
False = 0
Space = 32

;;; Zero Page
ZeroPage1 = $02
ZeroPage2 = $03
ZeroPage3 = $04
ZeroPage4 = $05
ZeroPage5 = $06
ZeroPage6 = $07
ZeroPage7 = $08
ZeroPage8 = $09
ZeroPage9 = $0A
ZeroPage10 = $0B
ZeroPage11 = $0C
ZeroPage12 = $0D
ZeroPage13 = $0E
ZeroPage14 = $0F
ZeroPage15 = $10

;;; Character memory slots
CharacterSlot0000 = $00	; $0000 hex,     0 decimal
CharacterSlot0800 = $02	; $0800 hex,  2048 decimal
CharacterSlot1000 = $04	; $1000 hex,  4096 decimal
CharacterSlot1800 = $06	; $1800 hex,  6144 decimal
CharacterSlot2000 = $08	; $2000 hex,  8192 decimal
CharacterSlot2800 = $0A	; $2800 hex, 10240 decimal
CharacterSlot3000 = $0C	; $3000 hex, 12288 decimal
CharacterSlot3800 = $0E	; $3800 hex, 14336 decimal

;;; Memory areas
SCREENRAM    = $0400
COLORRAM     = $D800
SPRITERAM    = 160	; 160 decimal * 64(sprite size) = 10240(hex $2800)
SPRITE0PTR   = SCREENRAM  + 1024 - 8 ; $07F8, last 8 bytes of SCREENRAM are sprite ptrs

;;; Register names taken from 'Mapping the Commodore 64' book

;;; 6510 Registers
D6510        = $0000
R6510        = $0001

;;; VIC-II Registers
SP0X         = $D000
SP0Y         = $D001
MSIGX        = $D010
SCROLY       = $D011
RASTER       = $D012
SPENA        = $D015
SCROLX       = $D016
VMCSB        = $D018
SPMC         = $D01C
SPSPCL       = $D01E
EXTCOL       = $D020
BGCOL0       = $D021
BGCOL1       = $D022
BGCOL2       = $D023
BGCOL3       = $D024
SPMC0        = $D025
SPMC1        = $D026
SP0COL       = $D027

;;; IRQ Registers
VICIRQ       = $D019
IRQMSK       = $D01A

;;; CIA #1 Registers (Generates IRQ's)
CIAPRA       = $DC00
CIAPRB       = $DC01
CIAICR       = $DC0D

;;; CIA #2 Registers (Generates NMI's)
CI2PRA       = $DD00
CI2PRB       = $DD01
CI2ICR       = $DD0D

;;; Timer Registers
TIMALO       = $DC04
TIMBHI       = $DC07

;;; Interrupt Vectors
IRQRAMVECTOR = $0314
IRQROMVECTOR = $FFFE
NMIRAMVECTOR = $0318
NMIROMVECTOR = $FFFA

;;; Interrupt Routines
IRQROMROUTINE = $EA31
