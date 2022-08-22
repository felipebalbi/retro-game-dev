!cpu 6510
!convtab scr

;;; ============================================================================
;;; 		   RetroGameDev C64 Edition Volume 2 Chapter 2
;;; ============================================================================
;;; Basic Loader

*= $0801

!macro basic_loader .lineno, .loadaddr {
	!word @end	    ; Next basic line
	!word .lineno	    ; Line number
	!byte $9e	    ; SYS
	!byte '0' + (.loadaddr % 100000 / 10000)
	!byte '0' + (.loadaddr % 10000 / 1000)
	!byte '0' + (.loadaddr % 1000 / 100)
	!byte '0' + (.loadaddr % 100 / 10)
	!byte '0' + (.loadaddr % 10)
	!byte $00, $00, $00 ; Terminator
@end:
}

	+basic_loader 2022, gameMainInit

;;; ============================================================================
;;; Includes

!src "libIncludes.asm"

;;; ============================================================================
;;; Macros

;;; Set the background color
!macro GAMEMAIN_SETBACKGROUNDCOLOR_V bColor {
	lda #bColor		; bColor -> A
	sta BGCOL0		; A -> background color register
}

;;; ============================================================================
;;; Subroutines

gameMainSetBorderColorGreen:
	lda #GREEN		; GREEN (5) -> A
	sta EXTCOL		; A -> border color register
	rts

;;; ============================================================================
;;; Wrapped subroutines

!macro GAMEMAIN_SETBORDERCOLOR_S_V bColor {
	lda #bColor			; bColor -> A
	sta ZeroPage1			; A -> ZeroPage1
	jsr gameMainSetBorderColor	; Jump to subroutine
}

gameMainSetBorderColor:
	lda ZeroPage1		; ZeroPage1 -> A
	sta EXTCOL		; A -> border color register
	rts

;;; ============================================================================
;;; Initialize

gameMainInit:
	+LIBUTILITY_SET1000_AV SCREENRAM, '2'		; fill the screen characters with 2's
	+LIBUTILITY_SET1000_AV COLORRAM, RED		; fill the screen colors with red

	;; Put the number 5 in memory location $fb
	lda #5			; (l)ad(d) the (a)ccumulator with the value 5
	sta $fb			; (st)ore the value in the (a)ccumulator to $fb

	;; Copy a byte from one memory location to another
	lda $fb			; (l)ad(d) the (a)ccumulator with the value in $fb
	sta $fc			; (st)ore the value in the (a)ccumulator to $fc

	;; Set the background using a macro
	+GAMEMAIN_SETBACKGROUNDCOLOR_V CYAN

	;; Set the green border color using a subroutine
	jsr gameMainSetBorderColorGreen

	+GAMEMAIN_SETBORDERCOLOR_S_V LIGHT_BLUE

	;; Put the number 8 in memory location $fe
	lda #8			; (l)ad(d) the (a)ccumulator with the value 8
	ldx #3			; (l)ad(d) the x register with the value 3
	sta $fb,x		; (st)ore the value in A to $fe

;;; ============================================================================
;;; Update

gameMainUpdate:
	+LIBSCREEN_WAIT_V 250				; Wait for scanline 250
	jmp gameMainUpdate				; Jump back, infinite loop
