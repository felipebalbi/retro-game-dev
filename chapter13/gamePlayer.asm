;; =============================================================================
;; Constants

PlayerIdleLeftAnim	= 5
PlayerIdleRightAnim	= 0
PlayerJumpLeftAnim	= 9
PlayerJumpRightAnim	= 4

PlayerFrame		= 1
PlayerHorizontalSpeed	= 2
PlayerXMinHigh		= 0	; 0*256 + 20 = 20  minX
PlayerXMinLow		= 20
PlayerXMaxHigh		= 1	; 1*256 + 68 = 324 maxX
PlayerXMaxLow		= 68
PlayerYMax		= 229

PlayerStateIdleLeft	= 0
PlayerStateIdleRight	= 1
PlayerStateRunLeft	= 2
PlayerStateRunRight	= 3
PlayerStateJumpLeft	= 4
PlayerStateJumpRight	= 5

PlayerJumpAmount	= 28
PlayerYVelocityMax	= 8

PlayerAnimDelay		= 6

;; =============================================================================
;; Variables

playerState:		!byte PlayerStateIdleRight
playerSprite:		!byte 0
playerXVelocity:	!byte 0
playerXVelocityAbs:	!byte 0
playerXHigh:		!byte 0
playerXLow:		!byte 175
playerYVelocity:	!byte 0
playerYVelocityAbs:	!byte 0
playerYVelocityScaled:	!byte 0
playerY:		!byte 229
playerOnGround:		!byte True


;; =============================================================================
;; Jump Tables

gamePlayerJumpTableLow:
        !byte <gamePlayerUpdateIdleLeft
        !byte <gamePlayerUpdateIdleRight
        !byte <gamePlayerUpdateRunLeft
        !byte <gamePlayerUpdateRunRight
        !byte <gamePlayerUpdateJumpLeft
        !byte <gamePlayerUpdateJumpRight

gamePlayerJumpTableHigh:
        !byte >gamePlayerUpdateIdleLeft
        !byte >gamePlayerUpdateIdleRight
        !byte >gamePlayerUpdateRunLeft
        !byte >gamePlayerUpdateRunRight
        !byte >gamePlayerUpdateJumpLeft
        !byte >gamePlayerUpdateJumpRight

;; =============================================================================
;; Macros/Subroutines

gamePlayerInit:
	+LIBSPRITE_ENABLE_AV		playerSprite, 1
	+LIBSPRITE_SETFRAME_AV		playerSprite, PlayerIdleRightAnim
	+LIBSPRITE_SETCOLOR_AV		playerSprite, Blue
	+LIBSPRITE_MULTICOLORENABLE_AV	playerSprite, True
	
	rts

;; =============================================================================

gamePlayerUpdate:
	jsr gamePlayerUpdateState
	jsr gamePlayerUpdateVelocity
	jsr gamePlayerUpdatePosition

	rts

;; =============================================================================

gamePlayerUpdateVelocity:
	;; X Velocity

	;; Apply friction if on ground
	lda playerOnGround
	beq gPUVNoFriction

	lda #0
	sta playerXVelocity

gPUVNoFriction:
	;; Apply left/right velocity if left/right pressed
	+LIBINPUT_GETHELD GameportLeftMask
	bne gPUVRight

	lda #-PlayerHorizontalSpeed
	sta playerXVelocity

gPUVRight:
	+LIBINPUT_GETHELD GameportRightMask
	bne gPUVEnd

	lda #PlayerHorizontalSpeed
	sta playerXVelocity

gPUVEnd:
	;; Get absolute X velocity
	+LIBMATH_ABS_AA playerXVelocity, playerXVelocityAbs

	;; Y Velocity

	;; Apply Gravity
	inc playerYVelocity

	;; Apply jump velocity if on ground & jump pressed
	lda playerOnGround
	beq gPUVNoJump

	+LIBINPUT_GETFIREPRESSED
	bne gPUVNoJump

	+LIBMATH_SUB8BIT_AVA playerYVelocity, PlayerJumpAmount, playerYVelocity
	lda #False
	sta playerOnGround

gPUVNoJump:
	;; Clamp velocity if fire not help (Mario-style variable height jump)
	lda playerYVelocity
	bpl gPUVYDone				; if velocity is not negative, we're done

	+LIBINPUT_GETHELD GameportFireMask	; only do if fire released
	beq gPUVYDone

	+LIBMATH_MAX8BIT_AV playerYVelocity, -PlayerYVelocityMax

gPUVYDone:
	;; Get absolute Y velocity
	+LIBMATH_ABS_AA playerYVelocity, playerYVelocityAbs

	;; Scale absolute velocity down to get speed (allows sub-pixel precision)
	lda playerYVelocityAbs
	lsr			; divided by 2
	lsr			; divided by 4
	sta playerYVelocityScaled
	
	rts

;; =============================================================================

gamePlayerUpdateState:
	;; Now run the satte machine
	ldy playerState

	;; Write the state's routine address to a zeropage temporary
	lda gamePlayerJumpTableLow,y
	sta ZeroPageLow
	lda gamePlayerJumpTableHigh,y
	sta ZeroPageHigh

	;; Jump to the update routine that temp address now points to
	jmp (ZeroPageLow)

;; =============================================================================

gamePlayerUpdatePosition:
	;; X position
	lda playerXVelocity
	beq gPUPXDone		; if zero velocity
	bpl gPUPXPositive

	;; gPUPXNegative
	;; Subtract the X velocity absolute from the X position
	+LIBMATH_SUB16BIT_AAVAAA playerXHigh, playerXLow, 0, playerXVelocityAbs, playerXHigh, playerXLow
	jmp gPUPXDone

gPUPXPositive:
	;; Add the X velocity abs to the X position
	+LIBMATH_ADD16BIT_AAVAAA playerXHigh, playerXLow, 0, playerXVelocityAbs, playerXHigh, playerXLow

gPUPXDone:
	;; Clamp the player x position
	+LIBMATH_MIN16BIT_AAVV playerXHigh, playerXLow, PlayerXMaxHigh, PlayerXMaxLow
	+LIBMATH_MAX16BIT_AAVV playerXHigh, playerXLow, PlayerXMinHigh, PlayerXMinLow

	;; Y Position
	lda playerYVelocity
	beq gPUPYDone		; if zero velocity
	bpl gPUPYPositive

	;; gPUPYNegative
	;; Subtract the Y velocity scaled from the Y position
	+LIBMATH_SUB8BIT_AAA playerY, playerYVelocityScaled, playerY
	jmp gPUPYDone

gPUPYPositive:
	;; Add the Y velocity scaled to the Y position
	+LIBMATH_ADD8BIT_AAA playerY, playerYVelocityScaled, playerY

gPUPYDone:
	;; Clamp the Y position to the ground
	lda #PlayerYMax
	cmp playerY
	bcs gPUPNotBelowGround

	sta playerY
	lda #True
	sta playerOnGround

	lda #0
	sta playerYVelocity

gPUPNotBelowGround:
	;; set the sprite position
	+LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY

	rts

;; =============================================================================

gamePlayerUpdateIdleLeft:
	lda playerXVelocity
	beq gPUILDone			; if zero velocity
	bpl gPUILPositive

	;; gPUILNegative		; if negative velocity
	jsr gamePlayerSetRunLeft
	jmp gPUILDone

gPUILPositive:				; if positive velocity
	jsr gamePlayerSetRunRight

gPUILDone:
	;; Switch to jump state if not on ground
	lda playerOnGround
	bne gPUILNoJump
	jsr gamePlayerSetJumpLeft

gPUILNoJump:
	rts

;; =============================================================================

gamePlayerUpdateIdleRight:
	lda playerXVelocity
	beq gPUIRDone			; if zero velocity
	bpl gPUIRPositive

	;;gPUIRNegative			; if negative velocity
	jsr gamePlayerSetRunLeft
	jmp gPUIRDone

gPUIRPositive:				; if positive velocity
	jsr gamePlayerSetRunRight

gPUIRDone:
	;; Switch to jump state if not on ground
	lda playerOnGround
	bne gPUIRNoJump
	jsr gamePlayerSetJumpRight

gPUIRNoJump:
	rts

;; =============================================================================

gamePlayerUpdateRunLeft:
	lda playerXVelocity
	beq gPURLZero			; if zero velocity
	bpl gPURLPositive

	;; gPURLNegative
	jmp gPURLDone

gPURLPositive:
	jsr gamePlayerSetRunRight
	jmp gPURLDone

gPURLZero:
	jsr gamePlayerSetIdleLeft

gPURLDone:
	;; Switch to jump state if not on ground
	lda playerOnGround
	bne gPURLNojump
	jsr gamePlayerSetJumpLeft

gPURLNojump:
	rts

;; =============================================================================

gamePlayerUpdateRunRight:
	lda playerXVelocity
	beq gPURRZero			; if zero velocity
	bpl gPURRPositive

	;; gPURRNegative
	jsr gamePlayerSetRunLeft
	jmp gPURRDone

gPURRPositive:
	jmp gPURRDone

gPURRZero:
	jsr gamePlayerSetIdleRight

gPURRDone:
	;; Switch to jump state if not on ground
	lda playerOnGround
	bne gPURRNojump
	jsr gamePlayerSetJumpRight

gPURRNojump:
	rts

;; =============================================================================

gamePlayerUpdateJumpLeft:
	lda playerXVelocity
	beq gPUJLDone			; if zero velocity
	bpl gPUJLPositive

	;; gPUJLNegative
	jmp gPUJLDone

gPUJLPositive:
	jsr gamePlayerSetJumpRight

gPUJLDone:
	lda playerOnGround
	beq gPUJLNotOnGround
	jsr gamePlayerSetIdleLeft

gPUJLNotOnGround:
	rts

;; =============================================================================

gamePlayerUpdateJumpRight:
	lda playerXVelocity
	beq gPUJRDone			; if zero velocity
	bpl gPUJRPositive

	;; gPUJRNegative
	jsr gamePlayerSetJumpLeft
	jmp gPUJRDone

gPUJRPositive:
gPUJRDone:
	lda playerOnGround
	beq gPUJRNotOnGround
	jsr gamePlayerSetIdleRight

gPUJRNotOnGround:
	rts

;; =============================================================================

gamePlayerSetIdleLeft:
	lda #PlayerStateIdleLeft
	sta playerState
	+LIBSPRITE_STOPANIM_A playerSprite
	+LIBSPRITE_SETFRAME_AV playerSprite, PlayerIdleLeftAnim
 
	rts
 
;; =============================================================================

gamePlayerSetIdleRight:
	lda #PlayerStateIdleRight
	sta playerState
	+LIBSPRITE_STOPANIM_A playerSprite
	+LIBSPRITE_SETFRAME_AV playerSprite, PlayerIdleRightAnim

	rts

;; =============================================================================

gamePlayerSetRunLeft:
	lda #PlayerStateRunLeft
	sta playerState
	+LIBSPRITE_PLAYANIM_AVVVV playerSprite, 6, 8, PlayerAnimDelay, True
	
	rts

;; =============================================================================

gamePlayerSetRunRight:
	lda #PlayerStateRunRight
	sta playerState
	+LIBSPRITE_PLAYANIM_AVVVV playerSprite, 1, 3, PlayerAnimDelay, True

	rts

;; =============================================================================

gamePlayerSetJumpLeft:
	lda #PlayerStateJumpLeft
	sta playerState
	+LIBSPRITE_STOPANIM_A playerSprite
	+LIBSPRITE_SETFRAME_AV playerSprite, PlayerJumpLeftAnim

	rts

;; =============================================================================

gamePlayerSetJumpRight:
	lda #PlayerStateJumpRight
	sta playerState
	+LIBSPRITE_STOPANIM_A playerSprite
	+LIBSPRITE_SETFRAME_AV playerSprite, PlayerJumpRightAnim
	rts
