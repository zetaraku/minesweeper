TITLE Minesweeper

INCLUDE Irvine32.inc

main EQU mainCRTStartup
; main EQU start@0

; ==================Macros=================

mSetColor MACRO color:=<lightGray>, bgcolor:=<black>
	push eax
	mov eax, bgcolor
	shl eax, 4
	add eax, color
	call SetTextColor
	pop eax
ENDM

; ============Data and Variables===========

INCLUDE data.asm

; ===============CODE SEGMENT==============

.code

; ==============Main Procedure=============

main PROC
	call Randomize

	L_gameloop:
		call displayWelcomeScreen
		call enterSettingEditMode
		call initBoard
		call initBoardDisplay
		call listenInput	; wait for keyboard inputs
	test eax, eax	; check for listenInput's return value
	jnz L_gameloop

	exit
main ENDP

; ================Tasks====================

INCLUDE tasks.asm

; ===========Display Functions=============

INCLUDE disp.asm

; ============Events handler===============

INCLUDE event.asm

; ==========Board manipulations============

INCLUDE board.asm

; ==============Utilities==================

INCLUDE utils.asm

; =========================================

END
