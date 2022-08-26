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
