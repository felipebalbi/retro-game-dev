;; =============================================================================
;; Constants

SpriteAnimsMax = 8

;; =============================================================================
;; Variables

spriteAnimsActive:		!fill SpriteAnimsMax, 0
spriteAnimsStartFrame:		!fill SpriteAnimsMax, 0
spriteAnimsFrame:		!fill SpriteAnimsMax, 0
spriteAnimsEndFrame:		!fill SpriteAnimsMax, 0
spriteAnimsStopFrame:		!fill SpriteAnimsMax, 0
spriteAnimsSpeed:		!fill SpriteAnimsMax, 0
spriteAnimsDelay:		!fill SpriteAnimsMax, 0
spriteAnimsLoop:		!fill SpriteAnimsMax, 0

spriteAnimsCurrent:		!byte 0
spriteAnimsFrameCurrent:	!byte 0
spriteAnimsEndFrameCurrent:	!byte 0

spriteNumberMask:
	!byte %00000001, %00000010, %00000100, %00001000
	!byte %00010000, %00100000, %01000000, %10000000

;; =============================================================================
;; Macros/Subroutines

!macro LIBSPRITE_DIDCOLLIDEWITHSPRITE_A sprite {
	;; /1 = Sprite Number (Address)
       
	ldy sprite
	lda spriteNumberMask,y
	and SPSPCL
}

;; =============================================================================

!macro LIBSPRITE_ENABLE_AV sprite, enable {
	;; /1 = Sprite Number (Address)
	;; /2 = Enable/Disable (Value)

	ldy sprite
	lda spriteNumberMask,y
	
	ldy #enable
	beq @disable
@enable:
	ora SPENA ; merge with the current SpriteEnable register
	sta SPENA ; set the new value into the SpriteEnable register
	jmp @done 
@disable:
	eor #$FF ; get mask compliment
	and SPENA
	sta SPENA
@done:
}

;; ============================================================================

!macro LIBSPRITE_ISANIMPLAYING_A sprite {
	;; /1 = Sprite Number    (Address)

	ldy sprite
	lda spriteAnimsActive,y
}

;; =============================================================================

!macro LIBSPRITE_MULTICOLORENABLE_AA sprite, enable {
	;; /1 = Sprite Number (Address)
	;; /2 = Enable/Disable (Address)

	ldy sprite
	lda spriteNumberMask,y
	
	ldy enable
	beq @disable
@enable:
	ora SPMC
	sta SPMC
	jmp @done 
@disable:
	eor #$FF ; get mask compliment
	and SPMC
	sta SPMC
@done:
}

;; =============================================================================

!macro LIBSPRITE_MULTICOLORENABLE_AV sprite, enable {
	;; /1 = Sprite Number (Address)
	;; /2 = Enable/Disable (Value)

	ldy sprite
	lda spriteNumberMask,y
	
	ldy #enable
	beq @disable
@enable:
	ora SPMC
	sta SPMC
	jmp @done 
@disable:
	eor #$FF ; get mask compliment
	and SPMC
	sta SPMC
@done:
}

;; ============================================================================

!macro LIBSPRITE_PLAYANIM_AVVVV sprite, start_frame, end_frame, speed, loop {
	;; /1 = Sprite Number	(Address)
	;; /2 = StartFrame	(Value)
	;; /3 = EndFrame	(Value)
	;; /4 = Speed		(Value)
	;; /5 = Loop True/False	(Value)

	ldy sprite

	lda #True
	sta spriteAnimsActive,y
	lda #start_frame
	sta spriteAnimsStartFrame,y
	sta spriteAnimsFrame,y
	lda #end_frame
	sta spriteAnimsEndFrame,y
	lda #speed
	sta spriteAnimsSpeed,y
	sta spriteAnimsDelay,y
	lda #loop
	sta spriteAnimsLoop,y
}

;; =============================================================================

!macro LIBSPRITE_SETCOLOR_AV sprite, color {
	;; /1 = Sprite Number	(Address)
	;; /2 = Color		(Value)

	ldy sprite 
	lda #color
	sta SP0COL,y
}

;; =============================================================================

!macro LIBSPRITE_SETCOLOR_AA sprite, color {
	;; /1 = Sprite Number	(Address)
	;; /2 = Color		(Address)

	ldy sprite
	lda color
	sta SP0COL,y
}

;; =============================================================================

!macro LIBSPRITE_SETFRAME_AA sprite, index {
	;; /1 = Sprite Number	(Address)
	;; /2 = Anim Index	(Address)

	ldy sprite
	
	clc			; Clear carry before add
	lda index		; Get first number
	adc #SPRITERAM ; Add
	 
	sta SPRITE0,y
}

;; =============================================================================

!macro LIBSPRITE_SETFRAME_AV sprite, index {
	;; /1 = Sprite Number	(Address)
	;; /2 = Anim Index	(Value)

	ldy sprite
	
	clc			; Clear carry before add
	lda #index		; Get first number
	adc #SPRITERAM		; Add
	 
	sta SPRITE0,y
}

;; =============================================================================

!macro LIBSPRITE_SETMULTICOLORS_VV color1, color2 {
	;; /1 = Color 1		(Value)
	;; /2 = Color 2		(Value)

	lda #color1
	sta SPMC0
	lda #color2
	sta SPMC1
}

;; =============================================================================

!macro LIBSPRITE_SETPOSITION_AAAA sprite, hixpos, loxpos, ypos {
	;; /1 = Sprite Number	(Address)
	;; /2 = XPos High Byte	(Address)
	;; /3 = XPos Low Byte	(Address)
	;; /4 = YPos		(Address)

	lda sprite		; get sprite number
	asl			; *2 as registers laid out 2 apart
	tay			; copy accumulator to y register

	lda loxpos		; get XPos Low Byte
	sta SP0X,y		; set the XPos sprite register
	lda ypos		; get YPos
	sta SP0Y,y		; set the YPos sprite register
	
	ldy sprite
	lda spriteNumberMask,y	; get sprite mask
	
	eor #$FF		; get compliment
	and MSIGX		; clear the bit
	sta MSIGX		; and store

	ldy hixpos		; get XPos High Byte
	beq @end		; skip if XPos High Byte is zero
	ldy sprite
	lda spriteNumberMask,y	; get sprite mask
	
	ora MSIGX		; set the bit
	sta MSIGX		; and store
@end:
}

;; =============================================================================

!macro LIBSPRITE_SETPOSITION_VAAA sprite, hixpos, loxpos, ypos {
	;; /1 = Sprite Number	(Value)
	;; /2 = XPos High Byte	(Address)
	;; /3 = XPos Low Byte	(Address)
	;; /4 = YPos		(Address)

	ldy #(sprite*2)		; *2 as registers laid out 2 apart
	lda loxpos		; get XPos Low Byte
	sta SP0X,y		; set the XPos sprite register
	lda ypos		; get YPos
	sta SP0Y,y		; set the YPos sprite register
	
	lda #1<<#sprite		; shift 1 into sprite bit position
	eor #$FF		; get compliment
	and MSIGX		; clear the bit
	sta MSIGX		; and store

	ldy hixpos		; get XPos High Byte
	beq @end		; skip if XPos High Byte is zero
	lda #1<<#sprite		; shift 1 into sprite bit position
	ora MSIGX		; set the bit
	sta MSIGX		; and store
@end:
}

;; =============================================================================

!macro LIBSPRITE_SETPRIORITY_AV sprite, priority {
	;; /1 = Sprite Number		(Address)
	;; /2 = True = Back, False = Front (Value)

	ldy sprite
	lda spriteNumberMask,y
	
	ldy #priority
	beq @disable
@enable:
	ora SPBGPR ; merge with the current SPBGPR register
	sta SPBGPR ; set the new value into the SPBGPR register
	jmp @done 
@disable:
	eor #$FF ; get mask compliment
	and SPBGPR
	sta SPBGPR
@done:
}

;; =============================================================================

!macro LIBSPRITE_STOPANIM_A sprite {
	;; /1 = Sprite Number	(Address)

	ldy sprite
	lda #0
	sta spriteAnimsActive,y

}

;; =============================================================================

libSpritesUpdate:
	ldx #0
lSoULoop:
	;; skip this sprite anim if not active
	lda spriteAnimsActive,X
	bne lSoUActive
	jmp lSoUSkip
lSoUActive:
	stx spriteAnimsCurrent
	lda spriteAnimsFrame,X
	sta spriteAnimsFrameCurrent

	lda spriteAnimsEndFrame,X
	sta spriteAnimsEndFrameCurrent
	
	+LIBSPRITE_SETFRAME_AA spriteAnimsCurrent, spriteAnimsFrameCurrent

	dec spriteAnimsDelay,X
	bne lSoUSkip

	;; reset the delay
	lda spriteAnimsSpeed,X
	sta spriteAnimsDelay,X

	;; change the frame
	inc spriteAnimsFrame,X
	
	;; check if reached the end frame
	lda spriteAnimsEndFrameCurrent
	cmp spriteAnimsFrame,X
	bcs lSoUSkip

	;; check if looping
	lda spriteAnimsLoop,X
	beq lSoUDestroy

	;; reset the frame
	lda spriteAnimsStartFrame,X
	sta spriteAnimsFrame,X
	jmp lSoUSkip

lSoUDestroy:
	;; turn off
	lda #False
	sta spriteAnimsActive,X
	+LIBSPRITE_ENABLE_AV spriteAnimsCurrent, False

lSoUSkip:
	;; loop for each sprite anim
	inx
	cpx #SpriteAnimsMax
	;; bne lSUloop
	beq lSoUFinished
	jmp lSoULoop
lSoUFinished:

	rts
