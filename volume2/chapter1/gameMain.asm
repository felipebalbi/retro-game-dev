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
;;; Initialize

gameMainInit:
	+LIBUTILITY_SET1000_AV SCREENRAM, Space		; Clear the screen
	+LIBSCREEN_SETSCREENCOLOR_V YELLOW		; Set background & border colors
	;; 16 C64 Colors -	BLACK, WHITE, RED, CYAN, PURPLE, GREEN, BLUE, YELLOW,
	;;			ORANGE, BROWN, LIGHT_RED, DARK_GRAY, GRAY, LIGHT_GREEN,
	;;			LIGHT_BLUE, LIGHT_GRAY

;;; ============================================================================
;;; Update

gameMainUpdate:
	+LIBSCREEN_WAIT_V 250				; Wait for scanline 250
	jmp gameMainUpdate				; Jump back, infinite loop
