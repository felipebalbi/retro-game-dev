!cpu 6510
!convtab scr

;; =============================================================================
;; BASIC Loader

	* = $0801

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

	+basic_loader 2022, main

;; =============================================================================
;; Imports

!src "gameMemory.asm"
!src "libMath.asm"
!src "libScreen.asm"

;; =============================================================================
;; Initialize

main:
	;; Turn off interrupts to stop LIBSCREEN_WAIT failing every so 
	;; often when the kernal interrupt syncs up with the scanline test
	sei

	;; Disable run/stop + restore keys
	lda #$FC
	sta $0328

	;; Set border and background colors
	;; The last 3 parameters are not used yet
	+LIBSCREEN_SETCOLORS Blue, White, Black, Black, Black

	;; Fill 1000 bytes (40x25) of screen memory 
	+LIBSCREEN_SET1000 SCREENRAM, 'a' ; 'a' maps to char 1

	;; Fill 1000 bytes (40x25) of color memory
	+LIBSCREEN_SET1000 COLORRAM, Black

;;==============================================================================
;; Update

gMLoop:
	+LIBSCREEN_WAIT_V 255

	;; inc EXTCOL		; start code timer change border color

	;; Game update code goes here

	;; dec EXTCOL	; end code timer reset border color
	jmp gMLoop
