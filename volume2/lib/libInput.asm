;;; ============================================================================
;;;			   RetroGameDev Library C64 v2.02
;;; ============================================================================

;;; ============================================================================
;;; Constants

;;; Port Masks
GameportUpMask	    = %00000001
GameportDownMask	    = %00000010
GameportLeftMask	    = %00000100
GameportRightMask    = %00001000
GameportFireMask	    = %00010000

;;; ============================================================================
;;; Macros

!macro LIBINPUT_GET_V bPortMask {
	lda CIAPRA	; Load joystick 2 state to A
	and #bPortMask	; Mask out direction/fire required
}	; Test with bne immediately after the call
