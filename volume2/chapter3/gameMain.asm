!cpu 6510
!convtab scr

;;; ============================================================================
;;; 		   RetroGameDev C64 Edition Volume 2 Chapter 1
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
;;; Variables

bVariable:	!byte 0
wVariable:	!word 0
bVariableText:	!scr "byte variable: "
!byte 0
wVariableText:	!scr "word variable: "
!byte 0
zeroPage1Text:	!scr "zeropage1: "
!byte 0
zeroPage2Text:	!scr "zeropage2: "
!byte 0

;;; ============================================================================
;;; Initialize

gameMainInit:
	+LIBUTILITY_SET1000_AV SCREENRAM, Space		; Clear the screen
	+LIBSCREEN_SETBACKGROUNDCOLOR_V YELLOW		; Set the background color
	+LIBSCREEN_SETBORDERCOLOR_V BLUE		; Set the border color

	+LIBSCREEN_DRAWTEXT_VVA 1, 5, bVariableText 	; Draw byte variable text
	+LIBSCREEN_DRAWTEXT_VVA 1, 7, wVariableText	; Draw word variable text
	+LIBSCREEN_DRAWTEXT_VVA 1, 14, zeroPage1Text	; Draw zeropage1 text
	+LIBSCREEN_DRAWTEXT_VVA 1, 16, zeroPage2Text	; Draw zeropage2 text

;;; ============================================================================
;;; Update

gameMainUpdate:
	+LIBSCREEN_WAIT_V 250				; Wait for scanline 250
	+LIBSCREEN_SETBORDERCOLOR_V RED			; Start profiling bar
	+LIBSCREEN_DEBUG8BIT_VVA 18, 5, bVariable	; Draw byte variable value
	inc bVariable					; Increment byte variable
	+LIBSCREEN_SETBORDERCOLOR_V CYAN		; Start profiling bar
	+LIBSCREEN_DEBUG16BIT_VVA 18, 7, wVariable	; Draw word variable value
	+LIBMATH_ADD16BIT_AVA wVariable, 1, wVariable	; Increment word variable
	+LIBSCREEN_SETBORDERCOLOR_V PURPLE		; Start profiling bar
	+LIBSCREEN_DEBUG8BIT_VVA 18, 14, ZeroPage1	; Draw zeropage1 value
	+LIBSCREEN_DEBUG8BIT_VVA 18, 16, ZeroPage2	; Draw zeropage2 value
	+LIBSCREEN_SETBORDERCOLOR_V BLUE		; Reset border color to default
	jmp gameMainUpdate				; Jump back, infinite loop
