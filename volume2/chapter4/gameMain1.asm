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
;;; Constants

IrqFast = False
Irq1Scanline = 100
Irq2Scanline = 180

;;; ============================================================================
;;; Variables

irqVectorLowText:	!scr "irq vector low ($fffe): "
!byte 0
irqVectorHighText:	!scr "irq vector high ($ffff): "
!byte 0

;;; ============================================================================
;;; Initialize

gameMainInit:
	+LIBUTILITY_SET1000_AV SCREENRAM, Space				; Clear the screen
	+LIBRASTERIRQ_INIT_VAV Irq1Scanline, gameMainIRQ1, IrqFast	; Initialize irq

	+LIBSCREEN_DRAWTEXT_VVA 5, 0, irqVectorLowText 			; Draw IRQ vector low text
	+LIBSCREEN_DEBUG8BIT_VVA 30, 0, $fffe				; Draw IRQ vector low byte
	+LIBSCREEN_DRAWTEXT_VVA 5, 1, irqVectorHighText 		; Draw IRQ vector high text
	+LIBSCREEN_DEBUG8BIT_VVA 30, 1, $fff4				; Draw IRQ vector high byte

;;; ============================================================================
;;; Update

gameMainUpdate:
	+LIBSCREEN_SETBORDERCOLOR_V BLUE				; Reset border color to default
	jmp gameMainUpdate						; Jump back, infinite loop

;;; ============================================================================
;;; Update

gameMainIRQ1:
	+LIBRASTERIRQ_START_V IrqFast					; Start the irq
	+LIBSCREEN_SETSCREENCOLOR_V GREEN				; Set the screen color
	+LIBUTILITY_WAITLOOP_V 50					; Wait for a while
	+LIBRASTERIRQ_SET_VAV Irq2Scanline, gameMainIRQ2, IrqFast	; Point to 2nd irq
	+LIBSCREEN_SETSCREENCOLOR_V WHITE				; Set the screen color
	+LIBRASTERIRQ_END_V IrqFast					; End the irq

gameMainIRQ2:
	+LIBRASTERIRQ_START_V IrqFast					; Start the irq
	+LIBSCREEN_SETSCREENCOLOR_V RED					; Set the screen color
	+LIBUTILITY_WAITLOOP_V 50					; Wait for a while
	+LIBRASTERIRQ_SET_VAV Irq1Scanline, gameMainIRQ1, IrqFast	; Point to 1st irq
	+LIBSCREEN_SETSCREENCOLOR_V WHITE				; Set the screen color
	+LIBRASTERIRQ_END_V IrqFast					; End the irq
