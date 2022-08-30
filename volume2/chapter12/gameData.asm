;;; ============================================================================
;;; Sounds

*= $1000
gameDataSID:
	!bin "Calypso_Bar.sid",,$7e

SFX_Crab:
	!byte $0e, $ee, $00, $dc, $81, $dc, $dc, $dc
	!byte $b1, $31, $b0, $af, $ae, $af, $ae, $ad
	!byte $ac, $90, $11, $00

SFX_Fail1:
	!byte $0e, $ee, $00, $98, $21, $98, $98, $98
	!byte $98, $98, $94, $94, $94, $94, $94, $92
	!byte $92, $92, $92, $92, $90, $11, $00

SFX_Fail2:
	!byte $0e, $ee, $00, $ac, $81, $ac, $21, $ab
	!byte $81, $ab, $21, $aa, $81, $aa, $21, $a9
	!byte $81, $a9, $21, $a8, $81, $a8, $21, $a7
	!byte $81, $a7, $21, $a6, $81, $a6, $21, $a5
	!byte $81, $a5, $21, $a4, $81, $a4, $21, $a3
	!byte $81, $a3, $21, $a2, $81, $a2, $21, $a1
	!byte $81, $a1, $21, $90, $11, $00

SFX_Great:
	!byte $0e, $00, $00, $b0, $21, $b0, $b0, $b4
	!byte $b4, $b4, $b7, $b7, $b7, $bc, $bc, $bc
	!byte $a0, $11, $00

SFX_NewCustomer:
	!byte $0e, $ee, $00, $cc, $11, $cc, $cc, $cc
	!byte $c8, $c8, $c8, $c8, $90, $00

SFX_Tadaah:
	!byte $0e, $00, $33, $b0, $21, $b4, $b7, $bc
	!byte $a0, $11, $a0, $b0, $21, $b4, $b7, $bc
	!byte $b0, $b4, $b7, $bc, $b0, $b4, $b7, $bc
	!byte $b0, $b4, $b7, $bc, $b0, $b4, $b7, $bc
	!byte $a0, $11, $00

;;; ============================================================================
;;; Charset

*= $2000			; Add charset data at $2000 memory location
	!bin "BeachBarScreensCharset.bin"

;;; ============================================================================
;;; Sprites

*= $2800						; Add sprite data at the $2800 memory location
	!bin "BeachBarSprites1.bin"
	!bin "BeachBarSprites2.bin"
	!bin "BeachBarSprites3.bin"
	!bin "BeachBarSprites4.bin"
	!bin "BeachBarSprites5.bin"
	!bin "BeachBarSprites6.bin"

;;; ============================================================================
;;; Charset

*= $3080			; Add tileset data at $3080 memory location
gameDataBackground:
	!bin "BeachBarScreenTopLeft.bin"
	!bin "BeachBarScreenTopRight.bin"
	!bin "BeachBarScreenBottomLeft.bin"
	!bin "BeachBarScreenBottomRight.bin"

gameDataBackgroundCol:
	!bin "BeachBarScreensColors.bin"
