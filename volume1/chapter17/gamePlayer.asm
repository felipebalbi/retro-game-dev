;; =============================================================================
;; Constants

PlayerIdleLeftAnim	= 5
PlayerIdleRightAnim	= 0
PlayerJumpLeftAnim	= 9
PlayerJumpRightAnim	= 4

PlayerFrame		= 1
PlayerHorizontalSpeed	= 2

PlayerStartXHigh	= 0
PlayerStartXLow		= 40
PlayerStartY		= 205

PlayerXMinHigh		= 0	; 0*256 + 20 = 20  minX
PlayerXMinLow		= 28
PlayerXMaxHigh		= 1	; 1*256 + 68 = 324 maxX
PlayerXMaxLow		= 60
PlayerYMax		= 205
PlayerXMinScrollHigh	= 0	; 0*256 + 150 = 150 minX
PlayerXMinScrollLow	= 150
PlayerXMaxScrollHigh	= 0	; 0*256 + 190 = 190 maxX
PlayerXMaxScrollLow	= 190

PlayerStateIdleLeft	= 0
PlayerStateIdleRight	= 1
PlayerStateRunLeft	= 2
PlayerStateRunRight	= 3
PlayerStateJumpLeft	= 4
PlayerStateJumpRight	= 5

PlayerJumpAmount	= 28
PlayerYVelocityMax	= 8

PlayerAnimDelay		= 6

PlayerLeftCollX		= 4
PlayerLeftCollY		= 14
PlayerRightCollX	= 20
PlayerRightCollY	= 14
PlayerBottomLeftCollX	= 7
PlayerBottomLeftCollY	= 20
PlayerBottomRightCollX	= 13
PlayerBottomRightCollY	= 20

;; =============================================================================
;; Variables

playerState:		!byte PlayerStateIdleRight
playerSprite:		!byte 0
playerXVelocity:	!byte 0
playerXVelocityAbs:	!byte 0
playerXHigh:		!byte PlayerStartXHigh
playerXLow:		!byte PlayerStartXLow
playerYVelocity:	!byte 0
playerYVelocityAbs:	!byte 0
playerYVelocityScaled:	!byte 0
playerY:		!byte PlayerStartY
playerCollXHigh		!byte 0
playerCollXLow		!byte 0
playerCollY		!byte 0
playerXChar		!byte 0
playerXOffset		!byte 0
playerYChar		!byte 0
playerYOffset		!byte 0
playerOnGround:		!byte True
playerActive:		!byte False

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
	+LIBSPRITE_SETPRIORITY_AV	playerSprite, True
	
	rts

;; =============================================================================

gamePlayerUpdate:
	lda playerActive
	beq gPUSkip

	jsr gamePlayerUpdateState
	jsr gamePlayerUpdateVelocity
	jsr gamePlayerUpdatePosition
	jsr gamePlayerUpdateBackgroundCollisions
	jsr gamePlayerUpdateSpriteCollisions

gPUSkip:
	;; reset the scroll value back even if not scrolling as the
	;; high score sets it to 0
	+LIBSCREEN_SETSCROLLXVALUE_A screenScrollXValue

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

	;; Scale absolute velocity down to get speed (allows sub-pixel
	;; precision)
	lda playerYVelocityAbs
	lsr			; divided by 2
	lsr			; divided by 4
	sta playerYVelocityScaled

	;;  clamp so collisions don't break if moving faster than 1
	;;  character per frame
	+LIBMATH_MIN8BIT_AV playerYVelocityScaled, 6
	
	rts

;; =============================================================================

gamePlayerCollideBottom:
	;; Find the screen character at the player position
	+LIBSCREEN_PIXELTOCHAR_AAVAVAAAA playerCollXHigh, playerCollXLow, 24, playerCollY, 50, playerXChar, playerXOffset, playerYChar, playerYOffset
	+LIBSCREEN_SETCHARPOSITION_AA playerXChar, playerYChar
	+LIBSCREEN_GETCHAR ZeroPageTemp

	;; Handle any death characters
	jsr gamePlayerDeathCharsHandle

	;; Handle any pickups (char 0)
	jsr gamePickupsHandle

	;; Handle end flag (char 98)
	jsr gamePlayerEndingHandle

	;; Handle any collisions with character code > 32
	lda #32
	cmp ZeroPageTemp
	bcs gPCBNoCollision
	
	;; Collision response
	lda playerCollY
	and #%11111000
	sta playerCollY

	;; extra adjustment for the 50 pixel y subtraction 50 / 8
	;; leaves 2 pixels. adding 1 lines it back up
	inc playerCollY
	
	lda #0
	sta playerYVelocity
	lda #True
	sta playerOnGround

gPCBNoCollision:
	rts

;; ========================================================================

gamePlayerCollideLeft:
	;; Find the screen character at the player position
	+LIBSCREEN_PIXELTOCHAR_AAVAVAAAA playerCollXHigh, playerCollXLow, 24, playerCollY, 50, playerXChar, playerXOffset, playerYChar, playerYOffset
	+LIBSCREEN_SETCHARPOSITION_AA playerXChar, playerYChar
	+LIBSCREEN_GETCHAR ZeroPageTemp

	;; Handle any death characters
	jsr gamePlayerDeathCharsHandle

	;; Handle any pickups (char 0)
	jsr gamePickupsHandle

	;; Handle end flag (char 98)
	jsr gamePlayerEndingHandle

	;; Handle any collisions with character code > 32
	lda #32
	cmp ZeroPageTemp
	bcs gPCLNoCollision
	
	;; Collision response
	lda playerCollXLow
	and #%11111000
	sta playerCollXLow
	+LIBMATH_ADD16BIT_AAVVAA playerCollXHigh, playerCollXLow, 0, 8, playerCollXHigh, playerCollXLow

gPCLNoCollision:
	rts

;; ========================================================================

gamePlayerCollideRight:
	;; Find the screen character at the player position
	+LIBSCREEN_PIXELTOCHAR_AAVAVAAAA playerCollXHigh, playerCollXLow, 24, playerCollY, 50, playerXChar, playerXOffset, playerYChar, playerYOffset
	+LIBSCREEN_SETCHARPOSITION_AA playerXChar, playerYChar
	+LIBSCREEN_GETCHAR ZeroPageTemp

	;; Handle any death characters
	jsr gamePlayerDeathCharsHandle

	;; Handle any pickups (char 0)
	jsr gamePickupsHandle

	;; Handle end flag (char 98)
	jsr gamePlayerEndingHandle

	;; Handle any collisions with character code > 32
	lda #32
	cmp ZeroPageTemp
	bcs gPCRNoCollision
	
	;; Collision response
	lda playerCollXLow
	and #%11111000
	sta playerCollXLow

gPCRNoCollision:
	rts

;; ========================================================================

gamePlayerDeathCharsHandle:
	lda ZeroPageTemp

	;; using characters 60 & 61 in the custom character set as
	;; death characters
	cmp #60
	bne gPDCNot60

	jsr gameFlowPlayerDied

gPDCNot60:
	cmp #61
	bne gPDCNot61

	jsr gameFlowPlayerDied

gPDCNot61:
	rts

;; ========================================================================

gamePlayerEndingHandle:
	lda ZeroPageTemp

	;; using character 98 in the custom character set as the end
	;; flag
	cmp #98
	bne gPEHNot98

	jsr gameFlowPlayerEnded

	;; play the ending sound
	+LIBSOUND_PLAY_VAA 1, soundEndingHigh, soundEndingLow

	;; disable player
	lda #0
	sta playerActive

	+LIBSPRITE_STOPANIM_A playerSprite
	+LIBSPRITE_SETFRAME_AV playerSprite, PlayerIdleRightAnim

gPEHNot98:
	rts

;; ========================================================================

gamePlayerUpdateBackgroundCollisions:
	;; adjust for the screen scroll value
	+LIBMATH_SUB16BIT_AAVAAA playerXHigh, playerXLow, 0, screenScrollXValue, playerXHigh, playerXLow

	;; Transform left collision point
	+LIBMATH_ADD16BIT_AAVVAA playerXHigh, playerXLow, 0, PlayerLeftCollX, playerCollXHigh, playerCollXLow  
	+LIBMATH_ADD8BIT_AVA playerY, PlayerLeftCollY, playerCollY
	
	;; Run collision check & response
	jsr gamePlayerCollideLeft

	;; Transform back to sprite space
	+LIBMATH_SUB16BIT_AAVVAA playerCollXHigh, playerCollXLow, 0, PlayerLeftCollX, playerXHigh, playerXLow 
	+LIBMATH_SUB8BIT_AVA playerCollY, PlayerLeftCollY, playerY

	;; Transform right collision point
	+LIBMATH_ADD16BIT_AAVVAA playerXHigh, playerXLow, 0, PlayerRightCollX, playerCollXHigh, playerCollXLow  
	+LIBMATH_ADD8BIT_AVA playerY, PlayerRightCollY, playerCollY
	
	;; Run collision check & response
	jsr gamePlayerCollideRight

	;; Transform back to sprite space
	+LIBMATH_SUB16BIT_AAVVAA playerCollXHigh, playerCollXLow, 0, PlayerRightCollX, playerXHigh, playerXLow 
	+LIBMATH_SUB8BIT_AVA playerCollY, PlayerRightCollY, playerY

	;; Transform bottom left collision point
	+LIBMATH_ADD16BIT_AAVVAA playerXHigh, playerXLow, 0, PlayerBottomLeftCollX, playerCollXHigh, playerCollXLow  
	+LIBMATH_ADD8BIT_AVA playerY, PlayerBottomLeftCollY, playerCollY

	;; Run collision check & response
	jsr gamePlayerCollideBottom

	;; Transform back to sprite space
	+LIBMATH_SUB16BIT_AAVVAA playerCollXHigh, playerCollXLow, 0, PlayerBottomLeftCollX, playerXHigh, playerXLow 
	+LIBMATH_SUB8BIT_AVA playerCollY, PlayerBottomLeftCollY, playerY

	;; Transform bottom right collision point
	+LIBMATH_ADD16BIT_AAVVAA playerXHigh, playerXLow, 0, PlayerBottomRightCollX, playerCollXHigh, playerCollXLow  
	+LIBMATH_ADD8BIT_AVA playerY, PlayerBottomRightCollY, playerCollY

	;; Run collision check & response
	jsr gamePlayerCollideBottom

	;; Transform back to sprite space
	+LIBMATH_SUB16BIT_AAVVAA playerCollXHigh, playerCollXLow, 0, PlayerBottomRightCollX, playerXHigh, playerXLow 
	+LIBMATH_SUB8BIT_AVA playerCollY, PlayerBottomRightCollY, playerY

	;; revert the screen scroll value adjustment
	+LIBMATH_ADD16BIT_AAVAAA playerXHigh, playerXLow, 0, screenScrollXValue, playerXHigh, playerXLow

	;; set the sprite position (moved from updateposition as this
	;; subroutine adjusts the position with collision response)
	+LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY
  
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
	jsr gamePlayerClampXandScroll

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
	rts

gamePlayerClampXandScroll:
	;; Clamp the player x position

	;; different min values based on first column or not
	lda screenColumn
	cmp #0
	bne gPCXSNotFirstColumn
	
	+LIBMATH_MAX16BIT_AAVV playerXHigh, playerXLow, PlayerXMinHigh, PlayerXMinLow

	jmp gPCXSFirstColumnEnd

gPCXSNotFirstColumn:
	+LIBMATH_MAX16BIT_AAVV playerXHigh, playerXLow, PlayerXMinScrollHigh, PlayerXMinScrollLow

gPCXSFirstColumnEnd:
	;; different min values based on last column or not
	lda screenColumn
	cmp #MapLastColumn
	bcs gPCXSNotLastColumn
	
	+LIBMATH_MIN16BIT_AAVV playerXHigh, playerXLow, PlayerXMaxScrollHigh, PlayerXMaxScrollLow

	jmp gPCXSLastColumnEnd

gPCXSNotLastColumn:
	+LIBMATH_MIN16BIT_AAVV playerXHigh, playerXLow, PlayerXMaxHigh, PlayerXMaxLow

gPCXSLastColumnEnd:
	;; Scroll the screen
	lda playerXVelocity
	beq gPCXSDone		; if zero velocity
	bpl gPCXSPositive

;; gPCXSNegative:		; If negative velocity
	;; Skip right scroll if at first column
	lda screenColumn
	cmp #0
	beq gPCXSDone

	;; Scroll the screen right if player X = min scrollX
	lda playerXHigh
	cmp #PlayerXMinScrollHigh
	bne gPCXSDone

	lda playerXLow
	cmp #PlayerXMinScrollLow
	bne gPCXSDone

	+LIBSCREEN_SCROLLXRIGHT_A gameMapUpdate
	jmp gPCXSDone

gPCXSPositive:
	;; Skip left scroll if at last column
	lda screenColumn
	cmp #MapLastColumn
	bcs gPCXSDone

	;; Scroll the screen left if player X = max scrollX
	lda playerXHigh
	cmp #PlayerXMaxScrollHigh
	bne gPCXSDone

	lda playerXLow
	cmp #PlayerXMaxScrollLow
	bne gPCXSDone

	+LIBSCREEN_SCROLLXLEFT_A gameMapUpdate

gPCXSDone:
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

;; =============================================================================

gamePlayerUpdateSpriteCollisions:
	+LIBSPRITE_DIDCOLLIDEWITHSPRITE_A playerSprite
	beq gPUSCNoCollide

	jsr gameFlowPlayerDied

gPUSCNoCollide:
	rts

;; =============================================================================

gamePlayerDie:
	;; disable palyer
	lda #0
	sta playerActive

	;; play death animation
	+LIBSPRITE_PLAYANIM_AVVVV playerSprite, 16, 27, 3, False

	;; play death sound
	+LIBSOUND_PLAY_VAA 2, soundExplosionHigh, soundExplosionLow

	rts

;; =============================================================================

gamePlayerReset:
	+LIBSCREEN_SCROLLXRESET_A gameMapUpdate

	lda #1
	sta playerActive
	+LIBSPRITE_ENABLE_AV	playerSprite, True
	+LIBSPRITE_SETFRAME_AV	playerSprite, PlayerIdleRightAnim

	lda #PlayerStartXHigh
	sta playerXHigh

	lda #PlayerStartXLow
	sta playerXLow

	lda #PlayerStartY
	sta playerY

	+LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY

	lda #0
	sta playerXVelocity
	sta playerYVelocity

	lda SPSPCL		; reset the collister by reading it

	rts
