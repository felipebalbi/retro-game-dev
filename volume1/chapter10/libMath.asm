;===============================================================================
; Macros/Subroutines

!macro LIBMATH_ABS_AA num, addr {
	;; /1 = Number (Address)
	;; /2 = Result (Address)
	
	lda num
	bpl @positive
	eor #$FF		; invert the bits
	sta addr
	inc addr		; add 1 to give the two's compliment
	jmp @done
@positive
	sta /2
@done
}

;==============================================================================

!macro LIBMATH_ADD8BIT_AAA num1, num2, sum {
	;; /1 = 1st Number (Address)
	;; /2 = 2nd Number (Address)
	;; /3 = Sum (Address)

	clc			; Clear carry before add
	lda num1		; Get first number
	adc num2		; Add to second number
	sta sum			; Store in sum
}

;==============================================================================

!macro LIBMATH_ADD8BIT_AVA addr, imm, sum {
	;; /1 = 1st Number (Address)
	;; /2 = 2nd Number (Value)
	;; /3 = Sum (Address)

	clc			; Clear carry before add
	lda addr		; Get first number
	adc #imm		; Add to second number
	sta sum			; Store in sum
}

;==============================================================================

!macro LIBMATH_ADD16BIT_AAVAAA hi1, lo1, hi2, lo2, hisum, losum {
	;; /1 = 1st Number High Byte (Address)
	;; /2 = 1st Number Low Byte (Address)
	;; /3 = 2nd Number High Byte (Value)
	;; /4 = 2nd Number Low Byte (Address)
	;; /5 = Sum High Byte (Address)
	;; /6 = Sum Low Byte (Address)

	clc			; Clear carry before first add
	lda lo1			; Get LSB of first number
	adc lo2			; Add LSB of second number
	sta losum		; Store in LSB of sum
	lda hi1			; Get MSB of first number
	adc #hi2		; Add carry and MSB of NUM2
	sta hisum		; Store sum in MSB of sum
}

;==============================================================================

!macro LIBMATH_ADD16BIT_AAVVAA hi1, lo1, hi2, lo2, hisum, losum {
	;; /1 = 1st Number High Byte (Address)
	;; /2 = 1st Number Low Byte (Address)
	;; /3 = 2nd Number High Byte (Value)
	;; /4 = 2nd Number Low Byte (Value)
	;; /5 = Sum High Byte (Address)
	;; /6 = Sum Low Byte (Address)

	clc			; Clear carry before first add
	lda lo1			; Get LSB of first number
	adc #lo2		; Add LSB of second number
	sta losum		; Store in LSB of sum
	lda hi1			; Get MSB of first number
	adc #hi2		; Add carry and MSB of NUM2
	sta hisum		; Store sum in MSB of sum
}

;==============================================================================

!macro LIBMATH_MIN8BIT_AV addr, imm {
	;; /1 = Number 1 (Address)
	;; /2 = Number 2 (Value)
	
	lda #imm		; load Number 2
	cmp addr		; compare with Number 1
	bcs @skip		; if Number 2 >= Number 1 then skip
	sta addr		; else replace Number1 with Number2
@skip
}

;==============================================================================

!macro LIBMATH_MAX8BIT_AV addr, imm {
	;; /1 = Number 1 (Address)
	;; /2 = Number 2 (Value)
	
	lda #imm		; load Number 2
	cmp addr		; compare with Number 1
	bcc @skip		; if Number 2 < Number 1 then skip
	sta addr		; else replace Number1 with Number2
@skip
}

;==============================================================================

!macro LIBMATH_MIN16BIT_AAVV hi1, lo1, hi2, lo2 {
	;; /1 = Number 1 High (Address)
	;; /2 = Number 1 Low (Address)
	;; /3 = Number 2 High (Value)
	;; /4 = Number 2 Low (Value)
	
	;; high byte
	lda hi1			; load Number 1
	cmp #hi2		; compare with Number 2
	bmi @skip		; if Number 1 < Number 2 then skip
	lda #hi2
	sta hi1			; else replace Number1 with Number2

	;; low byte
	lda #lo2		; load Number 2
	cmp lo1			; compare with Number 1
	bcs @skip		; if Number 2 >= Number 1 then skip
	sta lo1			; else replace Number1 with Number2
@skip
}

;==============================================================================

!macro LIBMATH_MAX16BIT_AAVV hi1, lo1, hi2, lo2 {
	;; /1 = Number 1 High (Address)
	;; /2 = Number 1 Low (Address)
	;; /3 = Number 2 High (Value)
	;; /4 = Number 2 Low (Value)
	
	;; high byte
	lda #hi2		; load Number 2
	cmp hi1			; compare with Number 1
	bcc @skip		; if Number 2 < Number 1 then skip
	sta hi1			; else replace Number1 with Number2

	;; low byte
	lda #lo2		; load Number 2
	cmp lo1			; compare with Number 1
	bcc @skip		; if Number 2 < Number 1 then skip
	sta lo1			; else replace Number1 with Number2
@skip
}

;==============================================================================

!macro LIBMATH_SUB8BIT_AAA addr1, addr2, sum {
	;; /1 = 1st Number (Address)
	;; /2 = 2nd Number (Address)
	;; /3 = Sum (Address)

	sec			; sec is the same as clear borrow
	lda addr1		; Get first number
	sbc addr2		; Subtract second number
	sta sum			; Store in sum
}

;==============================================================================

!macro LIBMATH_SUB8BIT_AVA addr, imm, sum {
	;; /1 = 1st Number (Address)
	;; /2 = 2nd Number (Value)
	;; /3 = Sum (Address)

	sec			; sec is the same as clear borrow
	lda addr		; Get first number
	sbc #imm		; Subtract second number
	sta sum			; Store in sum
}

;==============================================================================

!macro LIBMATH_SUB16BIT_AAVAAA hi1, lo1, hi2, lo2, hisum, losum {
	;; /1 = 1st Number High Byte (Address)
	;; /2 = 1st Number Low Byte (Address)
	;; /3 = 2nd Number High Byte (Value)
	;; /4 = 2nd Number Low Byte (Address)
	;; /5 = Sum High Byte (Address)
	;; /6 = Sum Low Byte (Address)

	sec			; sec is the same as clear borrow
	lda lo1			; Get LSB of first number
	sbc lo2			; Subtract LSB of second number
	sta losum		; Store in LSB of sum
	lda hi1			; Get MSB of first number
	sbc #hi2		; Subtract borrow and MSB of NUM2
	sta hisum		; Store sum in MSB of sum
}

;==============================================================================

!macro LIBMATH_SUB16BIT_AAVVAA hi1, lo1, hi2, lo2, hisum, losum {
	;; /1 = 1st Number High Byte (Address)
	;; /2 = 1st Number Low Byte (Address)
	;; /3 = 2nd Number High Byte (Value)
	;; /4 = 2nd Number Low Byte (Value)
	;; /5 = Sum High Byte (Address)
	;; /6 = Sum Low Byte (Address)

	sec			; sec is the same as clear borrow
	lda lo1			; Get LSB of first number
	sbc #lo2		; Subtract LSB of second number
	sta losum		; Store in LSB of sum
	lda hi1			; Get MSB of first number
	sbc #hi2		; Subtract borrow and MSB of NUM2
	sta hisum		; Store sum in MSB of sum
}
