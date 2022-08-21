!cpu 6510
!convtab scr

;; =============================================================================
;; Imports

!src "gameMemory.asm"
!src "libMath.asm"
!src "libInput.asm"
!src "libScreen.asm"
!src "libSprite.asm"
!src "libSound.asm"
!src "gameMap.asm"
!src "gamePickups.asm"
!src "gameEnemies.asm"
!src "gameFlow.asm"
!src "gamePlayer.asm"

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
;; Initialize

main:
	;; Turn off interrupts to stop LIBSCREEN_WAIT failing every so
	;; often when the kernal interrupt syncs up with the scanline
	;; test
	sei

	;; Disable run/stop + restore keys
	lda #$FC
	sta $0328

	;; Set border and background colors
	+LIBSCREEN_SETCOLORS LightBlue, LightBlue, Black, Brown, White

	;; Fill 1000 bytes (40x25) of screen memory 
	+LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter

	;; Fill 1000 bytes (40x25) of color memory
	+LIBSCREEN_SET1000 COLORRAM, White

	;; Set sprite multicolors
	+LIBSPRITE_SETMULTICOLORS_VV LightRed, Black

	;; Set the memory location of the custom character set
	+LIBSCREEN_SETCHARMEMORY 14

	;; Set multicolor background mode
	+LIBSCREEN_SETMULTICOLORMODE

	;; Set 38 column screen mode
	+LIBSCREEN_SET38COLUMNMODE

	;; Initialize the sound library
	jsr libSoundInit

	;; Initialize the game
	jsr gameMapInit
	jsr gameEnemiesInit
	jsr gamePlayerInit
	jsr gameFlowInit

;; =============================================================================
;; Update

gMLoop:
	;; Wait for scanline 235
	+LIBSCREEN_WAIT_V 235

	;; Start code timer change border color
	;; inc EXTCOL

	;; reset the scroll register for the score line
	+LIBSCREEN_SETSCROLLXVALUE_V 0

	;; Update the library
	jsr libSoundUpdate
	jsr libInputUpdate
	jsr libSpritesUpdate

	;; Update the game
	jsr gameEnemiesUpdate
	jsr gamePlayerUpdate
	jsr gameFlowUpdate

	;; End code timer reset border color
	;; dec EXTCOL
	
	;; Loop back to the start of the game loop
	jmp gMLoop
