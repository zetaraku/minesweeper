displayWelcomeScreen PROC USES eax edx
	; clear the screen
	mSetColor
	call Clrscr

	; set random text color for the title
	mov eax, 16
	call RandomRange
	call SetTextColor

	; print the main title
	mov dx, 0406h
	call Gotoxy
	mov edx, OFFSET titleMsg1
	call WriteString

	mov dx, 0506h
	call Gotoxy
	mov edx, OFFSET titleMsg2
	call WriteString

	mov dx, 0606h
	call Gotoxy
	mov edx, OFFSET titleMsg3
	call WriteString

	; set the color for the sub-title
	mSetColor white

	; print the sub-title
	mov dx, 0805h
	call Gotoxy
	mov edx, OFFSET titleMsg4
	call WriteString

	; set the color for the instruction
	mSetColor lightGreen

	; print the instruction
	mov dx, 1506h
	call Gotoxy
	mov edx, OFFSET startMsg
	call WriteString

	ret
displayWelcomeScreen ENDP

enterSettingEditMode PROC USES eax edx
	mov selectedSetting, 0

	beginAdjustSettings:
		call displaySettings

		.IF selectedSetting == 0
			; set cursor to the position
			mov dx, 0F0Ch + 8
			call Gotoxy

			call ReadChar
			.IF ah == 48h		; up
				.IF w < max_w
					inc w
				.ENDIF
			.ELSEIF ah == 50h	; down
				.IF w > 1
					dec w
				.ENDIF
			.ELSE
				jmp otherInputs
			.ENDIF
		.ELSEIF selectedSetting == 1
			; set cursor to the position
			mov dx, 0F1Fh + 9
			call Gotoxy

			call ReadChar
			.IF ah == 48h		; up
				.IF h < max_h
					inc h
				.ENDIF
			.ELSEIF ah == 50h	; down
				.IF h > 1
					dec h
				.ENDIF
			.ELSE
				jmp otherInputs
			.ENDIF
		.ELSEIF selectedSetting == 2
			; set cursor to the position
			mov dx, 0F31h+15
			call Gotoxy

			call ReadChar
			.IF ah == 48h		; up
				.IF minesPercent < 99
					inc minesPercent
				.ENDIF
			.ELSEIF ah == 50h	; down
				.IF minesPercent > 0
					dec minesPercent
				.ENDIF
			.ELSE
				jmp otherInputs
			.ENDIF
		.ENDIF

		jmp beginAdjustSettings

		otherInputs:
			.IF ah == 4Bh		; left
				.IF selectedSetting == 0
					mov selectedSetting, 2
				.ELSE
					dec selectedSetting
				.ENDIF
			.ELSEIF ah == 4Dh	; right
				.IF selectedSetting == 2
					mov selectedSetting, 0
				.ELSE
					inc selectedSetting
				.ENDIF
			.ELSEIF ah == 1Ch	; enter
				ret
			.ENDIF

		jmp beginAdjustSettings
	ret
enterSettingEditMode ENDP

initBoard PROC
	; fsize = w * h
	mov eax, w
	mov edx, h
	mul edx
	mov fsize, eax

	; minesCount = fsize * minesPercent
	mov edx, minesPercent
	mul edx
	mov ebx, 100
	div ebx
	mov minesCount, eax

	; fill field[] with 0
	mov edi, OFFSET field
	mov ecx, fsize
	init_field:
		mov BYTE PTR [edi], 0
		inc edi
	loop init_field

	; fill tileState[] with 0
	mov edi, OFFSET tileState
	mov ecx, fsize
	init_tileState:
		mov BYTE PTR [edi], 0
		inc edi
	loop init_tileState

	mov processStackCount, 0

	mov gameStarted, 0	; false
	mov gameover, 0		; false

	mov flagsCount, 0
	mov openCount, 0

	; initialize the mine selection set
	mov edi, OFFSET tmpm
	mov ecx, fsize
	L_init_mpos:			; ecx = fsize-1 ... 0
		dec ecx
		mov [edi], cx
		add edi, TYPE WORD
		jecxz L_init_mpos_end
	jmp L_init_mpos
	L_init_mpos_end:

	; shuffle the mine selection set (and we will select the first n mines)
	mov ecx, fsize
	L_shuffle_mpos:			; ecx = LENGTHOF tmpm ... 1
		mov eax, ecx
		call RandomRange
		lea esi, [(tmpm-TYPE WORD)+ecx*TYPE WORD]
		lea edi, [tmpm+eax*TYPE WORD]

		mov ax, [edi]
		xchg [esi], ax
		mov [edi], ax
	loop L_shuffle_mpos

	.IF minesCount == 0
		ret		; prevent loop underflow!!
	.ENDIF

	; for each selected mines: increase neighbor tiles' number
	mov ecx, minesCount
	L_increse_mark:			; ecx = minesCount ... 1
		lea ebx, [(tmpm-TYPE WORD)+ecx*TYPE WORD]
		mov ax, [ebx]
		call trXY	; field[ah][al]
		call getNeighborValidFlag	; dl=xxxx

		lea ebx, [(tmpm-TYPE WORD)+ecx*TYPE WORD]
		movzx eax, WORD PTR [ebx]
		lea ebx, [field+eax*TYPE BYTE]
		call incNumber
	loop L_increse_mark

	; for each selected mines: place the selected mines
	mov ecx, minesCount
	L_place_mine:
		lea ebx, [(tmpm-TYPE WORD)+ecx*TYPE WORD]
		movzx eax, WORD PTR [ebx]
		lea ebx, [field+eax*TYPE BYTE]
		mov BYTE PTR [ebx], '*'-'0'
	loop L_place_mine

	ret
initBoard ENDP

initBoardDisplay PROC USES ecx edx esi
	call Clrscr

	call printGameStatus

	mov dx, 0101h
	call Gotoxy

	mSetColor lightGray, gray
	mov esi, OFFSET field
	mov ecx, h
	disp1:
		push ecx
		mov ecx, DWORD PTR w
		disp2:
			mov eax, ' '	; 0B1h chcp 437
			call WriteChar	; print the tile
			inc esi
		loop disp2
		inc dh
		call Gotoxy
		pop ecx
	loop disp1
	ret
initBoardDisplay ENDP

listenInput PROC
	L_input:
		; move the cursor to the current position
		mov dl, nowX
		inc dl
		mov dh, nowY
		inc dh
		call Gotoxy

		; wait for a single char to be input
		call ReadChar

		.IF !gameover
			.IF ah == 48h		; up
				.IF nowY > 0
					dec nowY
				.ENDIF
			.ELSEIF ah == 50h	; down
				mov edx, h
				dec dl
				sub dl, nowY
				; nowY++ if nowY < h - 1
				.IF dl > 0
					inc nowY
				.ENDIF
			.ELSEIF ah == 4Bh	; left
				.IF nowX > 0
					dec nowX
				.ENDIF
			.ELSEIF ah == 4Dh	; right
				mov edx, w
				dec dl
				sub dl, nowX
				; nowX++ if nowX < w - 1
				.IF dl > 0
					inc nowX
				.ENDIF
			.ELSEIF al == 'z'	; 'z'
				mov ah, nowY
				mov al, nowX
				call trN
				and eax, 0000FFFFh
				.IF BYTE PTR [tileState + eax * TYPE BYTE] == closed
					call pushProcessStack
					call openTiles
					call checkWinOrLose
				.ENDIF
			.ELSEIF al == 'x'	; 'x'
				mov ah, nowY
				mov al, nowX
				call trN
				and eax, 0000FFFFh
				.IF BYTE PTR [tileState + eax * TYPE BYTE] != opened	; closed or flagged
					call toggleFlag
				.ELSE
					call numberAutoOpen		; opened tile
					call checkWinOrLose
				.ENDIF
			.ENDIF
		.ENDIF

		; exit game
		cmp ax, 011Bh	; Esc
		jne esc_end
			mov eax, 0
			ret
		esc_end:

		; restart game
		cmp al, 'r'
		jne r_end
			mov eax, 1
			ret
		r_end:

	jmp L_input

	ret
listenInput ENDP

checkWinOrLose PROC USES eax ebx
	.IF gameover == 1
		call onGameOver
	.ENDIF
	mov eax, minesCount
	add eax, openCount
	.IF eax == fsize
		call GetMseconds
		sub eax, startTime
		mov timeDelta, eax

		mov dx, 0B10h
		call Gotoxy

		mSetColor lightGreen
		mov edx, OFFSET gameWinMsg
		call WriteString

		mov dx, 0C10h
		call Gotoxy

		mSetColor yellow
		mov edx, OFFSET playtimeMsg
		call WriteString

		mov eax, timeDelta
		xor edx, edx
		mov ebx, 1000
		div ebx
		call WriteDec

		mov al, 's'
		call WriteChar

		mSetColor cyan
		mov dx, 0D10h
		call Gotoxy

		mov edx, OFFSET exitOrRestartMsg
		call WriteString

		mov gameover, 2
	.ENDIF
	ret
checkWinOrLose ENDP
