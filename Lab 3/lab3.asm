; SYSC2001 - Lab 3
; Program to complete 8-bit unsigned shift & add multiplication
; AH = A; CH = Q; BH = M; Final 16-bit result in AX

.ORG 0000h
Data:
	Y:	.DB	5				; Multiplicand
	X: 	.DB	2				; Multiplier

.ORG 0010h
Init:
	mov AX, 0				; Initialize AX to zero. AH serves as accumulator and AX will hold product
	mov CH, [X]   	; Initialize CH (Q) = X
	mov BH, [Y]			; Init BH (M) = Y
	mov DL, 8  			; Init DL as a loop counter with number of iterations required

mainLoop:
	SHR CH, 1				; Shift out the lsb of the multiplier (Q[0]) into the carry flag
	CMP CH, 0			; Check the carry flag: If Q[0] was not set, skip over Add and just shift
	JNC shift
AddM:
	ADD AH, BH			; A = A + M
shift:
	RCR	AX, 1				; Shift AH and AL (16-bit result will be here eventually). Also need to shift C into MSb of AH...

	DEC DL					; Decrement loop counter
	CMP DL, 0				; If loop counter reaches zero, quit, else, loop back

	JNE mainLoop
quit:
	HLT
.END	Init
