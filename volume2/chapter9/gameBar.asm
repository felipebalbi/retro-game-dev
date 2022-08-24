;;; ============================================================================
;;; Constants

BarSpriteMax			= 6
BarStateWalking			= 0
BarStateWaiting			= 1
BarStateDrinking		= 2
BarWalkDirRight			= 0
BarWalkDirLeft			= 1
BarAnimDelay			= 7
BarSittingWait			= 7
BarDrinkingWait			= 8

;;; ============================================================================
;;; Variables

;;; Arrays
bBarStateArray:			!byte   0,   0,   0,   0,   0,   0
wBarXArray:			!byte   0,   0,   0,   0,   0,   0
bBarYArray:			!byte   0,   0,   0,   0,   0,   0
bBarWalkDirArray:		!byte   0,   0,   0,   0,   0,   0
bBarTimerHArray:		!byte   0,   0,   0,   0,   0,   0
bBarTimerLArray:		!byte   0,   0,   0,   0,   0,   0
bBarChairTakenArray:		!byte   0,   0,   0,   0,   0,   0
bBarChairArray:			!byte   0,   1,   2,   3,   4,   5
bBarSpriteColorArray:		!byte   1,   0,   5,   0,   2,   6
bBarDrinkColorArray:		!byte   2,   4,   6,   2,   4,   5
bBarDrinkColumn1Array:		!byte   9,  13,  17,  21,  25,  29
bBarDrinkColumn2Array:		!byte  10,  14,  18,  22,  26,  30
bBarDrinkRowArray:		!byte  17,  17,  17,  17,  17,  17
bBarDrinkChar1Array:		!byte  89,  91,  93,  95,  97,  99
bBarDrinkChar2Array:		!byte  90,  92,  94,  96,  98, 100
bBarWalk1Array:			!byte  10,  16,  10,  28,  10,  22
bBarWalk2Array:			!byte  11,  17,  11,  29,  11,  24
bBarWalk3Array:			!byte   8,  14,   8,  26,   8,  20
bBarWalk4Array:			!byte   9,  15,   9,  27,   9,  21
bBarSitArray:			!byte  13,  19,  13,  31,  13,  25
bBarChairXArray:		!byte  91, 123, 155, 187, 219, 251
bBarChairYArray:		!byte 195, 195, 195, 195, 195, 195
bBarWalkYArray:			!byte 220, 220, 220, 220, 220, 220

;;; Current Element Values
bBarSprite:			!byte 0
bBarState:			!byte 0
bBarElement:			!byte 0
wBarX:				!word 0
bBarY:				!byte 0
bBarWalkDir:			!byte 0
bBarChair:			!byte 0
bBarSpriteColor:		!byte 0
bBarDrinkColor:			!byte 0
bBarDrinkColumn1:		!byte 0
bBarDrinkColumn2:		!byte 0
bBarDrinkRow:			!byte 0
bBarDrinkChar1:			!byte 0
bBarDrinkChar2:			!byte 0
bBarWalk1:			!byte 0
bBarWalk2:			!byte 0
bBarWalk3:			!byte 0
bBarWalk4:			!byte 0
bBarSit:			!byte 0
bBarChairX:			!byte 0
bBarChairY:			!byte 0
bBarWalkY:			!byte 0
wBarTimer:			!word 0
bBarTimerIsZero:		!byte 0

;;; ============================================================================
;;; JumpTables

gameBarUpdateStateJumpTable:
	!word gameBarUpdateStateWalking
	!word gameBarUpdateStateWaiting
	!word gameBarUpdateStateDrinking

gameBarUpdateSpriteJumpTable:
	!word gameBarUpdateSpriteWalking
	!word gameBarUpdateSpriteWaiting
	!word gameBarUpdateSpriteDrinking

;;; ============================================================================
;;; Subroutines

gameBarInit:
	ldx #0
gBILoop:
	inc bBarSprite		; x + 1
	jsr gameBarGetVariables
	lda #0
	sta bBarState
	sta wBarX
	sta bBarWalkDir

	;; Fil the char
	lda #True
	sta bBarChairTakenArray,x

	;; Get a random timerhigh wait time (0 -> 5)
	+LIBMATH_RAND_AAA bMathRandoms2, bMathRandomCurrent2, wBarTimer + 1

	;; Get a random timerlow wait time (0 -> 255)
	+LIBMATH_RAND_AAA bMathRandoms1, bMathRandomCurrent1, wBarTimer
	jsr gameBarSetVariables

	+LIBSPRITE_SETPOSITION_AAA bBarSprite, wBarX, bBarY
	inx
	cpx #BarSpriteMax
	bne gBILoop
	rts

;;; ============================================================================

gameBarUpdate:
	ldx #0
	stx bBarSprite
gBULoop:
	inc bBarSprite		; x + 1
	jsr gameBarGetVariables
	jsr gameBarUpdateState
	jsr gameBarSetVariables

	;; Only if on bar screen
	lda bMapScreen
	bne gBUNotOnBarScreen
	jsr gameBarUpdateSprite

gBUNotOnBarScreen:
	inx
	cpx #BarSpriteMax
	bne gBULoop
	rts

;;; ============================================================================

gameBarGetVariables:
	;; Read this element's variables
	lda bBarStateArray,x
	sta bBarState
	lda wBarXArray,x
	sta wBarX
	lda bBarYArray,x
	sta bBarY
	lda bBarWalkDirArray,x
	sta bBarWalkDir
	lda bBarChairArray,x
	sta bBarChair
	lda bBarSpriteColorArray,x
	sta bBarSpriteColor
	lda bBarDrinkColorArray,x
	sta bBarDrinkColor
	lda bBarWalk1Array,x
	sta bBarWalk1
	lda bBarWalk2Array,x
	sta bBarWalk2
	lda bBarWalk3Array,x
	sta bBarWalk3
	lda bBarWalk4Array,x
	sta bBarWalk4
	lda bBarSitArray,x
	sta bBarSit
	lda bBarChairYArray,x
	sta bBarChairY 
	lda bBarWalkYArray,x
	sta bBarWalkY 
	lda bBarTimerHArray,x
	sta wBarTimer+1
	lda bBarTimerLArray,x
	sta wBarTimer

	;; Get the drink icon variables
	ldy bBarChair
	lda bBarDrinkColumn1Array,y
	sta bBarDrinkColumn1
	lda bBarDrinkColumn2Array,y
	sta bBarDrinkColumn2
	lda bBarDrinkRowArray,y
	sta bBarDrinkRow
	lda bBarDrinkChar1Array,y
	sta bBarDrinkChar1
	lda bBarDrinkChar2Array,y
	sta bBarDrinkChar2

	;; Save X register
	stx bBarElement

	rts

;;; ============================================================================

gameBarSetVariables:
	;; Restore X register
	ldx bBarElement

	;; Write this element's variables
	;; Read only variables need not be in here
	lda bBarState
	sta bBarStateArray,x
	lda wBarX
	sta wBarXArray,x
	lda bBarY
	sta bBarYArray,x
	lda bBarWalkDir
	sta bBarWalkDirArray,x
	lda bBarChair
	sta bBarChairArray,x
	lda wBarTimer+1
	sta bBarTimerHArray,x
	lda wBarTimer
	sta bBarTimerLArray,x

	rts

;;; ============================================================================

gameBarUpdateState:
	jsr gameBarUpdateStateTimer

	lda bBarState				; Get the current state into A
	asl					; Multiply by 2
	tay					; Copy A to Y
	lda gameBarUpdateStateJumpTable, y	; Lookup low byte
	sta ZeroPage1				; Store in a temporary variable
	lda gameBarUpdateStateJumpTable+1,y	; Lookup high byte
	sta ZeroPage2				; Storage in temporary variable+1
	jmp (ZeroPage1)				; Indirect jump to subroutine

;;; ============================================================================

gameBarUpdateStateTimer:
	lda #False
	sta bBarTimerIsZero

	lda wBarTimer+1
	bne gBUSTimerHighNotZero
	lda wBarTimer
	beq gBUSTimerIsZero

gBUSTimerHighNotZero:
	;; decrement the timer
	+LIBMATH_SUB16BIT_AVA wBarTimer, 1, wBarTimer
	rts

gBUSTimerIsZero:
	lda #True
	sta bBarTimerIsZero
	rts

;;; ============================================================================

gameBarUpdateStateWalking:
	lda bBarWalkY				; Get the Y position for this customer
	sta bBarY				; Set the Y position for this customer

	lda bBarTimerIsZero			; If bBarTimerIsZero = True, then zero flag = False
	bne gBUSWTimerIsZero			; If zero flag not set, jump to gBUSWTimerIsZero
	jmp gBUSWEnd				; Jump to end

gBUSWTimerIsZero:
	lda bBarWalkDir				; Is facing left?
	beq gBUSWRightWalk			; No, so jump to walking right

	;; Walking left
	dec wBarX				; Move left
	beq gBUSWEndSkip			; If at left edge, jump to gBUSWEndSkip
	jmp gBUSWEnd				; Jump to end

gBUSWEndSkip:
	;; Move right 1 so we can try again next frame if no chair is
	;; available
	inc wBarX

	;; Set a random chair (if available)
	+LIBMATH_RAND_AAA bMathRandoms2, bMathRandomCurrent2, ZeroPage1
	ldy ZeroPage1
	lda bBarChairTakenArray,y
	bne gBUSWEnd

	;; Fill the chair
	lda #True
	sta bBarChairTakenArray,y

	;; Set the walk direction
	lda #BarWalkDirRight
	sta bBarWalkDir

	;; Get a random timerhigh wait time (0 -> 5)
	+LIBMATH_RAND_AAA bMathRandoms2, bMathRandomCurrent2, wBarTimer+1

	;; Get a random timerlow wait time (0 -> 255)
	+LIBMATH_RAND_AAA bMathRandoms1, bMathRandomCurrent1, wBarTimer

	jmp gBUSWEnd

	;; Walking Right
gBUSWRightWalk:
	inc wBarX				; Move right

	;; Check if reached target chair position
	ldy bBarChair
	lda bBarChairXArray,y
	sta ZeroPage1
	+LIBMATH_GREATEREQUAL8BIT_AA wBarX, ZeroPage1
	bcc gBUSWEnd				; If not reached chair, jump to end
	
	;; Set the state
	lda #BarStateWaiting
	sta bBarState

	;; Set the timer
	lda #BarSittingWait
	sta wBarTimer+1

gBUSWEnd:
	rts
	
;;; ============================================================================

gameBarUpdateSprite:
	rts


