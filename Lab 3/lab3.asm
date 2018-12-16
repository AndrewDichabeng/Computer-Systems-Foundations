; SYSC2001 - Lab 3
; Program to complete 8-bit unsigned shift & add multiplication
; AH = A; CH = Q; BH = M; Final 16-bit result in AX

.ORG 0000h
Data:
    Y:	.DB	5   ; Multiplicand
    X: 	.DB	2   ; Multiplier

.ORG 0010h

Init:
    mov AX, 0   ; Initialize AX to zero. AH serves as accumulator and AX will hold product
    mov CH, [X] ; Initialize CH (Q) = X
    mov BH, [Y] ; Init BH (M) = Y
    mov DL, 8   ; Init DL as a loop counter with number of iterations required

mainLoop:
    shr CH, 1   ; Shift out the lsb of the multiplier (Q[0]) into the carry flag
    cmp CH, 0   ; Check the carry flag: If Q[0] was not set, skip over Add and just shift
    jnc shift

AddM:
    add AH, BH  ; A = A + M

shift:
    rcr	AX, 1   ; Shift AH and AL (16-bit result will be here eventually). Also need to shift C into MSb of AH...
    dec DL      ; Decrement loop counter
    cmp DL, 0   ; If loop counter reaches zero, quit, else, loop back
    jne mainLoop
quit:
    HLT

.END	Init
