;; =============================================================================
;; Constants

Black		= 0
White		= 1
Red		= 2
Cyan		= 3 
Purple		= 4
Green		= 5
Blue		= 6
Yellow		= 7
Orange		= 8
Brown		= 9
LightRed	= 10
DarkGray	= 11
MediumGray	= 12
LightGreen	= 13
LightBlue	= 14
LightGray	= 15
SpaceCharacter	= 32

False		= 0
True		= 1

;; =============================================================================
;; Variables

;; Operator Calc

ScreenRAMRowStartLow:	; SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
	!byte <SCREENRAM,     <SCREENRAM+40,  <SCREENRAM+80
	!byte <SCREENRAM+120, <SCREENRAM+160, <SCREENRAM+200
	!byte <SCREENRAM+240, <SCREENRAM+280, <SCREENRAM+320
	!byte <SCREENRAM+360, <SCREENRAM+400, <SCREENRAM+440
	!byte <SCREENRAM+480, <SCREENRAM+520, <SCREENRAM+560
	!byte <SCREENRAM+600, <SCREENRAM+640, <SCREENRAM+680
	!byte <SCREENRAM+720, <SCREENRAM+760, <SCREENRAM+800
	!byte <SCREENRAM+840, <SCREENRAM+880, <SCREENRAM+920
	!byte <SCREENRAM+960

ScreenRAMRowStartHigh:	; SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
	!byte >SCREENRAM,     >SCREENRAM+40,  >SCREENRAM+80
	!byte >SCREENRAM+120, >SCREENRAM+160, >SCREENRAM+200
	!byte >SCREENRAM+240, >SCREENRAM+280, >SCREENRAM+320
	!byte >SCREENRAM+360, >SCREENRAM+400, >SCREENRAM+440
	!byte >SCREENRAM+480, >SCREENRAM+520, >SCREENRAM+560
	!byte >SCREENRAM+600, >SCREENRAM+640, >SCREENRAM+680
	!byte >SCREENRAM+720, >SCREENRAM+760, >SCREENRAM+800
	!byte >SCREENRAM+840, >SCREENRAM+880, >SCREENRAM+920
	!byte >SCREENRAM+960

ColorRAMRowStartLow:	; COLORRAM + 40*0, 40*1, 40*2 ... 40*24
	!byte <COLORRAM,     <COLORRAM+40,  <COLORRAM+80
	!byte <COLORRAM+120, <COLORRAM+160, <COLORRAM+200
	!byte <COLORRAM+240, <COLORRAM+280, <COLORRAM+320
	!byte <COLORRAM+360, <COLORRAM+400, <COLORRAM+440
	!byte <COLORRAM+480, <COLORRAM+520, <COLORRAM+560
	!byte <COLORRAM+600, <COLORRAM+640, <COLORRAM+680
	!byte <COLORRAM+720, <COLORRAM+760, <COLORRAM+800
	!byte <COLORRAM+840, <COLORRAM+880, <COLORRAM+920
	!byte <COLORRAM+960

ColorRAMRowStartHigh:	; COLORRAM + 40*0, 40*1, 40*2 ... 40*24
	!byte >COLORRAM,     >COLORRAM+40,  >COLORRAM+80
	!byte >COLORRAM+120, >COLORRAM+160, >COLORRAM+200
	!byte >COLORRAM+240, >COLORRAM+280, >COLORRAM+320
	!byte >COLORRAM+360, >COLORRAM+400, >COLORRAM+440
	!byte >COLORRAM+480, >COLORRAM+520, >COLORRAM+560
	!byte >COLORRAM+600, >COLORRAM+640, >COLORRAM+680
	!byte >COLORRAM+720, >COLORRAM+760, >COLORRAM+800
	!byte >COLORRAM+840, >COLORRAM+880, >COLORRAM+920
	!byte >COLORRAM+960

;; Operator HiLo

screenColumn	  !byte 0
screenScrollXValue !byte 0

;; =============================================================================
;; Macros/Subroutines

!macro LIBSCREEN_COPYMAPROW_VVA mapRow, screenRow, offset {
	;; /1 = Map Row		(Value)
	;; /2 = Screen Row	(Value)
	;; /3 = Start Offset	(Address)

	lda #mapRow
	sta ZeroPageParam1
	lda #screenRow
	sta ZeroPageParam2
	lda offset
	sta ZeroPageParam3
	jsr libScreen_CopyMapRow
}

libScreen_CopyMapRow:
	ldy ZeroPageParam1			; load y position as index into list
	lda MapRAMRowStartLow,y			; load low address byte
	sta ZeroPageLow2
	lda MapRAMRowStartHigh,y		; load high address byte
	sta ZeroPageHigh2

	;; add on the offset to the map address
	+LIBMATH_ADD16BIT_AAVAAA ZeroPageHigh2, ZeroPageLow2, 0, ZeroPageParam3, ZeroPageHigh2, ZeroPageLow2  

	ldy ZeroPageParam2			; load y position as index into list
	lda ScreenRAMRowStartLow,y		; load low address byte
	sta ZeroPageLow
	lda ScreenRAMRowStartHigh,y		; load high address byte
	sta ZeroPageHigh
	
	ldy #0

lSCMRLoop:
	lda (ZeroPageLow2),y
	sta (ZeroPageLow),y
	iny
	cpy #39
	bne lSCMRLoop

	rts

;; ========================================================================

!macro LIBSCREEN_COPYMAPROWCOLOR_VVA mapRow, screenRow, offset {
	;; /1 = Map Row		(Value)
	;; /2 = Screen Row	(Value)
	;; /3 = Start Offset	(Address)

	lda #mapRow
	sta ZeroPageParam1
	lda #screenRow
	sta ZeroPageParam2
	lda offset
	sta ZeroPageParam3
	jsr libScreen_CopyMapRowColor
}

libScreen_CopyMapRowColor:
	ldy ZeroPageParam1			; load y position as index into list
	lda MapRAMCOLRowStartLow,y		; load low address byte
	sta ZeroPageLow2
	lda MapRAMCOLRowStartHigh,y		; load high address byte
	sta ZeroPageHigh2

	;; add on the offset to the map address
	+LIBMATH_ADD16BIT_AAVAAA ZeroPageHigh2, ZeroPageLow2, 0, ZeroPageParam3, ZeroPageHigh2, ZeroPageLow2  

	ldy ZeroPageParam2			; load y position as index into list
	lda ColorRAMRowStartLow,y		; load low address byte
	sta ZeroPageLow
	lda ColorRAMRowStartHigh,y		; load high address byte
	sta ZeroPageHigh
	
	ldy #0

lSCMRCLoop:
	lda (ZeroPageLow2),y
	ora #%00001000				; set multicolor bit
	sta (ZeroPageLow),y
	iny
	cpy #39
	bne lSCMRCLoop

	rts

;; ========================================================================

!macro LIBSCREEN_DEBUG8BIT_VVA xpos, ypos, ptr {
	;; /1 = X Position Absolute
	;; /2 = Y Position Absolute
	;; /3 = 1st Number Low Byte Pointer
	
	lda #White
	sta $0286	; set text color
	lda #$20	; space
	jsr $ffd2	; print 4 spaces
	jsr $ffd2
	jsr $ffd2
	jsr $ffd2
	;; jsr $E566	; reset cursor
	ldx #ypos	; Select row 
	ldy #xpos	; Select column 
	jsr $E50C	; Set cursor 

	lda #0
	ldx ptr
	jsr $BDCD	; print number
}

;; =============================================================================

!macro LIBSCREEN_DEBUG16BIT_VVAA xpos, ypos, hiptr, loptr {
	;; /1 = X Position Absolute
	;; /2 = Y Position Absolute
	;; /3 = 1st Number High Byte Pointer
	;; /4 = 1st Number Low Byte Pointer
	
	lda #White
	sta $0286	; set text color
	lda #$20	; space
	jsr $ffd2	; print 4 spaces
	jsr $ffd2
	jsr $ffd2
	jsr $ffd2
	;jsr $E566	; reset cursor
	ldx #ypos	; Select row 
	ldy #xpos	; Select column 
	jsr $E50C	; Set cursor 

	lda hiptr
	ldx loptr
	jsr $BDCD	; print number
}

;; =============================================================================

!macro LIBSCREEN_DRAWTEXT_AAAV xpos, ypos, str, color {
	;; /1 = X Position 0-39 (Address)
	;; /2 = Y Position 0-24 (Address)
	;; /3 = 0 terminated string (Address)
	;; /4 = Text Color (Value)

	ldy ypos			; load y position as index into list
	
	lda ScreenRAMRowStartLow,Y	; load low address byte
	sta ZeroPageLow

	lda ScreenRAMRowStartHigh,Y	; load high address byte
	sta ZeroPageHigh

	ldy xpos			; load x position into Y register

	ldx #0
@loop:
	lda str,X
	cmp #0
	beq @done
	sta (ZeroPageLow),Y
	inx
	iny
	jmp @loop

@done:
	ldy ypos			; load y position as index into list
	
	lda ColorRAMRowStartLow,Y	; load low address byte
	sta ZeroPageLow

	lda ColorRAMRowStartHigh,Y	; load high address byte
	sta ZeroPageHigh

	ldy xpos			; load x position into Y register

	ldx #0
@loop2:
	lda str,X
	cmp #0
	beq @done2
	lda #color
	sta (ZeroPageLow),Y
	inx
	iny
	jmp @loop2
@done2:
}

;; =============================================================================

!macro LIBSCREEN_DRAWDECIMAL_AAAV xpos, ypos, addr, color {
	;; /1 = X Position 0-39 (Address)
	;; /2 = Y Position 0-24 (Address)
	;; /3 = decimal number 2 nybbles (Address)
	;; /4 = Text Color (Value)

	ldy ypos			; load y position as index into list
	
	lda ScreenRAMRowStartLow,Y	; load low address byte
	sta ZeroPageLow

	lda ScreenRAMRowStartHigh,Y	; load high address byte
	sta ZeroPageHigh

	ldy xpos			; load x position into Y register

	;; get high nybble
	lda addr
	and #$F0
	
	;; convert to ascii
	lsr
	lsr
	lsr
	lsr
	ora #$30

	sta (ZeroPageLow),Y

	;; move along to next screen position
	iny 

	;; get low nybble
	lda addr
	and #$0F

	;; convert to ascii
	ora #$30  

	sta (ZeroPageLow),Y
    

	;; now set the colors
	ldy ypos			; load y position as index into list
	
	lda ColorRAMRowStartLow,Y	; load low address byte
	sta ZeroPageLow

	lda ColorRAMRowStartHigh,Y	; load high address byte
	sta ZeroPageHigh

	ldy xpos			; load x position into Y register

	lda #color
	sta (ZeroPageLow),Y

	;; move along to next screen position
	iny 
	
	sta (ZeroPageLow),Y
}

;; =============================================================================

!macro LIBSCREEN_GETCHAR addr {
	;; /1 = Return character code (Address)

	lda (ZeroPageLow),Y
	sta addr
}

;; =============================================================================

!macro LIBSCREEN_PIXELTOCHAR_AAVAVAAAA xhipx, xlopx, xadj, ypx, yadj, xch, xoff, ych, yoff {
	;; /1 = XHighPixels	 (Address)
	;; /2 = XLowPixels	 (Address)
	;; /3 = XAdjust		 (Value)
	;; /4 = YPixels		 (Address)
	;; /5 = YAdjust		 (Value)
	;; /6 = XChar		 (Address)
	;; /7 = XOffset		 (Address)
	;; /8 = YChar		 (Address)
	;; /9 = YOffset		 (Address)

	lda xhipx
	sta ZeroPageParam1
	lda xlopx
	sta ZeroPageParam2
	lda #xadj
	sta ZeroPageParam3
	lda ypx
	sta ZeroPageParam4
	lda #yadj
	sta ZeroPageParam5
	
	jsr libScreen_PixelToChar

	lda ZeroPageParam6
	sta xch
	lda ZeroPageParam7
	sta xoff
	lda ZeroPageParam8
	sta ych
	lda ZeroPageParam9
	sta yoff
}

libScreen_PixelToChar
	;; subtract XAdjust pixels from XPixels as left of a sprite is first visible at x = 24
	+LIBMATH_SUB16BIT_AAVAAA ZeroPageParam1, ZeroPageParam2, 0, ZeroPageParam3, ZeroPageParam6, ZeroPageParam7

	lda ZeroPageParam6
	sta ZeroPageTemp

	;; divide by 8 to get character X
	lda ZeroPageParam7
	lsr					; divide by 2
	lsr					; and again = /4
	lsr					; and again = /8
	sta ZeroPageParam6

	;; AND 7 to get pixel offset X
	lda ZeroPageParam7
	and #7
	sta ZeroPageParam7

	;; Adjust for XHigh
	lda ZeroPageTemp
	beq @nothigh
	+LIBMATH_ADD8BIT_AVA ZeroPageParam6, 32, ZeroPageParam6 ; shift across 32 chars

@nothigh
	;; subtract YAdjust pixels from YPixels as top of a sprite is first visible at y = 50
	+LIBMATH_SUB8BIT_AAA ZeroPageParam4, ZeroPageParam5, ZeroPageParam9


	;; divide by 8 to get character Y
	lda ZeroPageParam9
	lsr					; divide by 2
	lsr					; and again = /4
	lsr					; and again = /8
	sta ZeroPageParam8

	;; AND 7 to get pixel offset Y
	lda ZeroPageParam9
	and #7
	sta ZeroPageParam9

	rts

;; =============================================================================

!macro LIBSCREEN_SCROLLXLEFT_A subroutine {
	;; /1 = update subroutine (Address)

	dec screenScrollXValue
	lda screenScrollXValue
	and #%00000111
	sta screenScrollXValue

	lda SCROLX
	and #%11111000
	ora screenScrollXValue
	sta SCROLX

	lda screenScrollXValue
	cmp #7
	bne @finished

	;; move to next column
	inc screenColumn
	jsr subroutine				; call the passed in function to update the screen rows
@finished
}

;; =============================================================================

!macro LIBSCREEN_SCROLLXRIGHT_A subroutine {
	;; /1 = update subroutine (Address)

	inc screenScrollXValue
	lda screenScrollXValue
	and #%00000111
	sta screenScrollXValue

	lda SCROLX
	and #%11111000
	ora screenScrollXValue
	sta SCROLX

	lda screenScrollXValue
	cmp #0
	bne @finished

	;; move to previous column
	dec screenColumn
	jsr subroutine				; call the passed in function to update the screen rows
@finished
}

;; =============================================================================

!macro LIBSCREEN_SCROLLXRESET_A subroutine {
	;; /1 = update subroutine (Address)

	lda #0
	sta screenColumn
	sta screenScrollXValue

	lda SCROLX
	and #%11111000
	ora screenScrollXValue
	sta SCROLX

	jsr subroutine				; call the passed in function to update the screen rows
}

;; =============================================================================

!macro LIBSCREEN_SETSCROLLXVALUE_A scrollx {
	;; /1 = ScrollX value (Address)

	lda SCROLX
	and #%11111000
	ora scrollx
	sta SCROLX
}

;; =============================================================================

!macro LIBSCREEN_SETSCROLLXVALUE_V scrollx {
	;; /1 = ScrollX value (Value)

	lda SCROLX
	and #%11111000
	ora #scrollx
	sta SCROLX
}

;; =============================================================================

;; Sets 1000 bytes of memory from start address with a value
!macro LIBSCREEN_SET1000 addr, imm {
	;; /1 = Start  (Address)
	;; /2 = Number (Value)

	lda #imm				; Get number to set
	ldx #250				; Set loop value
@loop	dex					; Step -1
	sta addr,x				; Set start + x
	sta addr+250,x				; Set start + 250 + x
	sta addr+500,x				; Set start + 500 + x
	sta addr+750,x				; Set start + 750 + x
	bne @loop				; If x<>0 loop
}

;; =============================================================================

!macro LIBSCREEN_SET38COLUMNMODE {
	lda SCROLX
	and #%11110111 ; clear bit 3
	sta SCROLX
}

;; =============================================================================

!macro LIBSCREEN_SET40COLUMNMODE {
	lda SCROLX
	ora #%00001000 ; set bit 3
	sta SCROLX
}

;; =============================================================================

!macro LIBSCREEN_SETCHARMEMORY slot {
	;; /1 = Character Memory Slot (Value)

	;; point vic (lower 4 bits of $d018)to new character data
	lda VMCSB
	and #%11110000				; keep higher 4 bits
	;; p208 M Jong book
	ora #slot				;$0E ; maps to	$3800 memory address
	sta VMCSB
}

;; =============================================================================

!macro LIBSCREEN_SETCHAR_V ch {
	;; /1 = Character Code (Value)
	lda #ch
	sta (ZeroPageLow),Y
}

;; =============================================================================

!macro LIBSCREEN_SETCHAR_A ch {
	;; /1 = Character Code (Address)
	lda ch
	sta (ZeroPageLow),Y
}

;; =============================================================================

!macro LIBSCREEN_SETCHARPOSITION_AA xpos, ypos {
	;; /1 = X Position 0-39 (Address)
	;; /2 = Y Position 0-24 (Address)
	
	ldy ypos				; load y position as index into list
	
	lda ScreenRAMRowStartLow,Y		; load low address byte
	sta ZeroPageLow

	lda ScreenRAMRowStartHigh,Y		; load high address byte
	sta ZeroPageHigh

	ldy xpos				; load x position into Y register
}

;; =============================================================================

!macro LIBSCREEN_SETCOLORPOSITION_AA xpos, ypos {
	;; /1 = X Position 0-39 (Address)
	;; /2 = Y Position 0-24 (Address)
			       
	ldy ypos				; load y position as index into list
	
	lda ColorRAMRowStartLow,Y		; load low address byte
	sta ZeroPageLow

	lda ColorRAMRowStartHigh,Y		; load high address byte
	sta ZeroPageHigh

	ldy xpos				; load x position into Y register
}

;; =============================================================================

;; Sets the border and background colors
!macro LIBSCREEN_SETCOLORS bdrcol, bgcol0, bgcol1, bgcol2, bgcol3 {
	;; /1 = Border Color	   (Value)
	;; /2 = Background Color 0 (Value)
	;; /3 = Background Color 1 (Value)
	;; /4 = Background Color 2 (Value)
	;; /5 = Background Color 3 (Value)
				
	lda #bdrcol				; Color0 -> A
	sta EXTCOL				; A -> EXTCOL
	lda #bgcol0				; Color1 -> A
	sta BGCOL0				; A -> BGCOL0
	lda #bgcol1				; Color2 -> A
	sta BGCOL1				; A -> BGCOL1
	lda #bgcol2				; Color3 -> A
	sta BGCOL2				; A -> BGCOL2
	lda #bgcol3				; Color4 -> A
	sta BGCOL3				; A -> BGCOL3
}

;; =============================================================================

!macro LIBSCREEN_SETMAPCHAR_VAAV mapRow, screenOffset, charOffset, char {
	;; /1 = Map Row		(Value)
	;; /2 = Screen Offset	(Address)
	;; /3 = Char Offset	(Address)
	;; /4 = Character	(Value)

	lda #mapRow
	sta ZeroPageParam1
	lda screenOffset
	sta ZeroPageParam2
	lda charOffset
	sta ZeroPageParam3
	lda #char
	sta ZeroPageParam4
	jsr libScreen_SetMapChar
}

libScreen_SetMapChar:
	ldy ZeroPageParam1			; load y position as index into list
	lda MapRAMRowStartLow,Y			; load low address byte
	sta ZeroPageLow
	lda MapRAMRowStartHigh,Y		; load high address byte
	sta ZeroPageHigh

	;; add on the screen offset to the map address
	+LIBMATH_ADD16BIT_AAVAAA ZeroPageHigh, ZeroPageLow, 0, ZeroPageParam2, ZeroPageHigh, ZeroPageLow

	;; set the char
	lda ZeroPageParam4
	ldy ZeroPageParam3			; index with the char offset
	sta (ZeroPageLow),y

	rts

;; =============================================================================

!macro LIBSCREEN_SETMULTICOLORMODE {
	lda SCROLX
	ora #%00010000				; set bit 5
	sta SCROLX
}

;; =============================================================================

;; Waits for a given scanline 
!macro LIBSCREEN_WAIT_V scanline {
	;; /1 = Scanline (Value)

@loop	lda #scanline			; Scanline -> A
	cmp RASTER			; Compare A to current raster line
	bne @loop			; Loop if raster line not reached 255
}
