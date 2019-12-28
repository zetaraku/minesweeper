displaySettings PROC USES eax edx
	; display width
	mov dx, 0F0Ch
	call Gotoxy

	mSetColor lightGray
	mov edx, OFFSET widthMsg
	call WriteString

	mSetColor lightRed
	.IF w < 10
		mov al, ' '
		call WriteChar
	.ENDIF
	mov eax, w
	call WriteDec

	; display height
	mov dx, 0F1Fh
	call Gotoxy

	mSetColor lightGray
	mov edx, OFFSET heightMsg
	call WriteString

	mSetColor lightRed
	.IF h < 10
		mov al, ' '
		call WriteChar
	.ENDIF
	mov eax, h
	call WriteDec

	; display mine density
	mov dx, 0F31h
	call Gotoxy

	mSetColor lightGray
	mov edx, OFFSET minesMsg
	call WriteString

	mSetColor lightRed
	.IF minesPercent < 10
		mov al, ' '
		call WriteChar
	.ENDIF
	mov eax, minesPercent
	call WriteDec
	mov al, '%'
	call WriteChar

	ret
displaySettings ENDP

printGameStatus PROC USES eax edx
	mov dx, 0000h
	call Gotoxy

	; print number of remaining mines (minesCount - flagsCount)
	mSetColor lightGray
	mov edx, OFFSET gameStatusMsg1
	call WriteString

	mSetColor lightRed
	mov eax, minesCount
	sub eax, flagsCount
	push eax	; save the number of remaining mines
	call WriteInt

	mov al, ' '
	call WriteChar

	; print number of remaining tiles need to open (fsize - minesCount - openCount)
	mSetColor lightGray
	mov edx, OFFSET gameStatusMsg2
	call WriteString

	mSetColor lightRed
	mov eax, fsize
	sub eax, minesCount
	sub eax, openCount
	call WriteDec

	mov al, ' '
	call WriteChar

	pop eax		; restore the number of remaining mines
	cmp eax, 0
	jl no_positive
		mov dx, LENGTHOF gameStatusMsg1-1
		call Gotoxy
		mov al, ' '
		call WriteChar
	no_positive:

	ret
printGameStatus ENDP
