!cpu 6510
!convtab scr

;;; ============================================================================
;;; 		   RetroGameDev C64 Edition Volume 2 Chapter 9
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
!src "gameData.asm"
!src "gameBar.asm"

;;; ============================================================================
;;; Initialize

gameMainInit:
	+LIBUTILITY_DISABLEBASICANDKERNAL		; Disable BASIC and KERNAL RORMs
	+LIBUTILITY_SET1000_AV SCREENRAM, Space		; Clear the screen
	+LIBSCREEN_SETSCREENCOLOR_V YELLOW		; Set the screen color

	+LIBSPRITE_ENABLEALL_V True 			; Enable all 8 hardware sprites
	+LIBSPRITE_MULTICOLORENABLEALL_V True		; Set the sprite multicolor mode
	+LIBSPRITE_SETMULTICOLORS_VV LIGHT_RED, BROWN	; Set the sprite multicolors
	+LIBSCREEN_SETMULTICOLORMODE_V True		; Set the background multicolor mode
	+LIBSCREEN_SETMULTICOLORS_VV BLACK, BROWN	; Set the background multicolors
	+LIBSCREEN_SETCHARMEMORY_V CharacterSlot2000	; Set the custom charset
	+LIBSCREEN_SETBACKGROUND_AA gameDataBackground + PlayerScreenTopLeft*1000, gameDataBackgroundCol ; Set the background screen

	+LIBMATH_RANDSEED_AA bMathRandomCurrent1, TIMALO ; Seed the random number lists
	+LIBMATH_RANDSEED_AA bMathRandomCurrent2, TIMALO

	jsr gamePlayerInit				; Call the player initialization subroutine
	jsr gameBarInit					; Call the bar initialize subroutine

;;; ============================================================================
;;; Update

gameMainUpdate:
	+LIBSCREEN_WAIT_V 250				; Wait for scanline 250
	+LIBSPRITE_UPDATE				; Update the sprites
	jsr gamePlayerUpdate				; Update the player subroutines
	jsr gameBarUpdate				; Update the bar subroutines
	jmp gameMainUpdate				; Jump back, infinite loop
