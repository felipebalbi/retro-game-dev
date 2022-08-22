!cpu 6510
!convtab scr

;;; ============================================================================
;;; 		   RetroGameDev C64 Edition Volume 2 Chapter 5
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
!src "gamePlayer.asm"

;;; ============================================================================
;;; Initialize

gameMainInit:
	+LIBUTILITY_DISABLEBASICANDKERNAL		; Disable BASIC and KERNAL RORMs
	+LIBUTILITY_SET1000_AV SCREENRAM, Space		; Clear the screen
	+LIBSCREEN_SETSCREENCOLOR_V YELLOW		; Set the screen color

	+LIBSPRITE_ENABLEALL_V True 			; Enable all 8 hardware sprites
	+LIBSPRITE_MULTICOLORENABLEALL_V True		; Set the sprite multicolor mode
	+LIBSPRITE_SETMULTICOLORS_VV LIGHT_RED, BROWN	; Set the sprite multicolors

	jsr gamePlayerInit				; Call the player initialization subroutine

;;; ============================================================================
;;; Update

gameMainUpdate:
	jmp gameMainUpdate				; Jump back, infinite loop

;;; ============================================================================
;;; Data

*= $2800						; Add sprite data at the $2800 memory location
!bin "BeachBarSprites1.bin"	
