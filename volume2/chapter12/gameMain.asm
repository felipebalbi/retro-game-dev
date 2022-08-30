!cpu 6510
!convtab scr

;;; ============================================================================
;;; 		   RetroGameDev C64 Edition Volume 2 Chapter 12
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
!src "gameData.asm"
!src "gamePlayer.asm"
!src "gameBar.asm"
!src "gameLoungers.asm"
!src "gameCrabs.asm"

;;; ============================================================================
;;; Constants

IrqFast				= True
Irq1ScanLine			= 10
Irq2ScanLine			= 140

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

	+LIBSOUND_INIT_A gameDataSID			; Initialize the sound
	+LIBRASTERIRQ_INIT_VAV Irq1ScanLine, gameMainIRQ1, IrqFast ; Initialize IRQ

	jsr gamePlayerInit				; Call the player initialization subroutine
	jsr gameBarInit					; Call the bar initialize subroutine
	jsr gameLoungersInit				; Call the loungers initialize subroutine

;;; ============================================================================
;;; Update

gameMainUpdate:
	+LIBSCREEN_WAIT_V 250				; Wait for scanline 250
	+LIBSPRITE_UPDATE				; Update the sprites
	jsr gamePlayerUpdate				; Update the player subroutines
	jsr gameBarUpdate				; Update the bar subroutines
	jsr gameLoungersUpdate				; Update the loungers subroutines
	jsr gameCrabsUpdate				; Update the crabs subroutines
	jmp gameMainUpdate				; Jump back, infinite loop

;;; ============================================================================
;;; IRQ Handlers

gameMainIRQ1:
	+LIBRASTERIRQ_START_V IrqFast 			; Start the IRQ
	+LIBSOUND_UPDATE_A gameDataSID			; Update the sound player
	jsr gameCrabsUpdateTop
	+LIBRASTERIRQ_SET_VAV Irq2ScanLine, gameMainIRQ2, IrqFast ; Point to 2nd IRQ
	+LIBRASTERIRQ_END_V IrqFast			; End the IRQ

gameMainIRQ2:
	+LIBRASTERIRQ_START_V IrqFast 			; Start the IRQ
	jsr gameCrabsUpdateBottom
	+LIBRASTERIRQ_SET_VAV Irq1ScanLine, gameMainIRQ1, IrqFast ; Point to the 1st IRQ
	+LIBRASTERIRQ_END_V IrqFast			; End the IRQ
