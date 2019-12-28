; push a tile with (offset: ax) into the user defined stack of list to be processed
pushProcessStack PROC uses eax edi
	and eax, 0000FFFFh
	mov BYTE PTR [tileState+eax*TYPE BYTE], opened
	mov edi, processStackCount
	mov [processStack+edi*TYPE WORD], ax
	inc processStackCount
	ret
pushProcessStack ENDP

; push a tile with (offset: ax) into the user defined stack of list to be numberAutoOpen
pushNumOpenStack PROC uses eax edi
	and eax, 0000FFFFh
	mov edi, numStackCount
	mov [numOpenStack+edi*TYPE WORD], ax
	inc numStackCount
	ret
pushNumOpenStack ENDP

; open each tile in the processStack
openTiles PROC USES eax ebx edx esi
	L_loop:
		.IF processStackCount == 0
			ret
		.ENDIF

		; pop offset to ax
		dec processStackCount
		mov esi, processStackCount
		mov ax, [processStack+esi*TYPE WORD]

		; bx = offset
		movzx ebx, ax

		call trXY
		; ax = (row, col)
		mov dx, ax

		; record the start time (first open)
		.IF gameStarted == 0
			call GetMseconds
			mov startTime, eax
			mov gameStarted, 1
		.ENDIF

		; al: tile data (number or mine)
		xor eax, eax
		mov al, [field+ebx*TYPE BYTE]
		add al, '0'

		; space (number==0)
		; .IF al == '0'
		; 	mov al, ' '
		; .ENDIF

		push dx
		inc dh
		inc dl

		; gameover (player opens a mine)
		.IF al == '*'
			mSetColor lightRed, lightGray
			call Gotoxy
			call WriteChar
			mov gameover, 1
			pop dx
			ret
		.ENDIF

		inc openCount
		call printGameStatus

		.IF al == '0'
			mSetColor lightGray, lightGray
		.ELSEIF al == '1'
			mSetColor lightBlue, lightGray		; cyan
		.ELSEIF al == '2'
			mSetColor lightgreen, lightGray
		.ELSEIF al == '3'
			mSetColor red, lightGray			; lightmagenta
		.ELSEIF al == '4'
			mSetColor blue, lightGray			; white
		.ELSEIF al == '5'
			mSetColor brown, lightGray			; cyan
		.ELSEIF al == '6'
			mSetColor magenta, lightGray		; lightcyan
		.ELSEIF al == '7'
			mSetColor black, lightGray			; white
		.ELSEIF al == '8'
			mSetColor gray, lightGray			; lightMagenta
		.ENDIF

		call Gotoxy
		call WriteChar

		pop dx

		.IF BYTE PTR [field+ebx*TYPE BYTE] != 0
			jmp L_loop	; continue
		.ENDIF

		; ======== auto-open ========

		mov ax, dx
		call getNeighborValidFlag

		; ax = bx-w-1
		mov ax, bx
		sub ax, WORD PTR w
		dec ax

		test dl, 1010b
		jnz _1
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _1
			call pushProcessStack
		_1:
		inc ax

		test dl, 1000b
		jnz _2
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _2
			call pushProcessStack
		_2:
		inc ax

		test dl, 1001b
		jnz _3
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _3
			call pushProcessStack
		_3:
		add ax, WORD PTR w
		sub ax, 2

		test dl, 0010b
		jnz _4
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _4
			call pushProcessStack
		_4:
		inc ax

		_5:
		inc ax

		test dl, 0001b
		jnz _6
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _6
			call pushProcessStack
		_6:
		add ax, WORD PTR w
		sub ax, 2

		test dl, 0110b
		jnz _7
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _7
			call pushProcessStack
		_7:
		inc ax

		test dl, 0100b
		jnz _8
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _8
			call pushProcessStack
		_8:
		inc ax

		test dl, 0101b
		jnz _9
		cmp BYTE PTR [tileState+eax*TYPE BYTE], 0
		jne _9
			call pushProcessStack
		_9:

	jmp L_loop

	ret
openTiles ENDP

numberAutoOpen PROC USES eax ebx edx esi
	mov bx, ax
	call trXY
	call getNeighborValidFlag

	mov ax, bx
	sub ax, WORD PTR w
	dec ax

	mov nFlagCounter, 0
	mov numStackCount, 0

	test dl, 1010b
	jnz _1
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _1
		inc nFlagCounter
	_1:
	inc ax

	test dl, 1000b
	jnz _2
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _2
		inc nFlagCounter
	_2:
	inc ax

	test dl, 1001b
	jnz _3
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _3
		inc nFlagCounter
	_3:
	add ax, WORD PTR w
	sub ax, 2

	test dl, 0010b
	jnz _4
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _4
		inc nFlagCounter
	_4:
	inc ax

	_5:
	inc ax

	test dl, 0001b
	jnz _6
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _6
		inc nFlagCounter
	_6:
	add ax, WORD PTR w
	sub ax, 2

	test dl, 0110b
	jnz _7
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _7
		inc nFlagCounter
	_7:
	inc ax

	test dl, 0100b
	jnz _8
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _8
		inc nFlagCounter
	_8:
	inc ax

	test dl, 0101b
	jnz _9
		call pushNumOpenStack
	cmp BYTE PTR [tileState+eax*TYPE BYTE], flagged
	jne _9
		inc nFlagCounter
	_9:

	movzx eax, bx
	mov dl, BYTE PTR [field+eax*TYPE BYTE]
	.IF nFlagCounter != dl
		ret
	.ENDIF

	L_open:
		.IF numStackCount == 0
			jmp stack_finish
		.ENDIF

		; pop offset to ax
		dec numStackCount
		mov esi, numStackCount
		movzx eax, WORD PTR [numOpenStack+esi*TYPE WORD]

		.IF BYTE PTR [tileState+eax*TYPE BYTE] == closed
			call pushProcessStack
		.ENDIF
	jmp	L_open

	stack_finish:

	call openTiles

	ret
numberAutoOpen ENDP

; toggle a tile with (offset: ax)
toggleFlag PROC USES eax ebx edx
	and eax, 0000FFFFh
	mov ebx, eax
	call trXY
	mov dx, ax

	.IF BYTE PTR [tileState+ebx*TYPE BYTE] & opened
		ret
	.ENDIF

	; toggle
	xor BYTE PTR [tileState+ebx*TYPE BYTE], flagged

	; display
	.IF BYTE PTR [tileState+ebx*TYPE BYTE] & flagged
		mov al, 'P'
		inc flagsCount
		mSetColor lightRed, gray
	.ELSEIF
		mov al, ' '
		dec flagsCount
		mSetColor lightGray, gray
	.ENDIF

	inc dh
	inc dl
	call Gotoxy
	call WriteChar

	call printGameStatus

	ret
toggleFlag ENDP
