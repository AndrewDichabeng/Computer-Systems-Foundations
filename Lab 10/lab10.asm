; Program to accept a signed decimal number in the format +/-xxxx
; Calculate the 8-bit "quarter precision" IEEE-754 encoding and print it to screen.
;

; Format -/+xxxx in decimal, entered as ASCII.
; 1) Get sign
; 2) Get number
; 3) Normalize number to get exponent
; 3) Compute bias-** representation of exponent
; 4) Create final IEEE-754 representation

; Constant definitions
DISPLAY	.EQU 04E9h	; address of Libra display

; Global variables
.ORG 0000
SIGN:	.DB	0		; Sign of entered number (0=positive, 1=negative)
SUM:	.DB	0		; Unsigned  binary representation of entered number
EXP:	.DB	0		; Excess/bias representation of exponent (only uses lower 3 bits)
FP:		.DB	0		; 8-bit quarter-precision IEEE-754 representation of number

.ORG 1000h
;---------------------------
;Insert Sub-routines getChar, printStr, and newLine from Lab 8 here
;---------------------------
printStr:
	; Save registers modified by this subroutine
	PUSH AX				; FIXED
	PUSH SI				; FIXED
	PUSH DX				; FIXED

	MOV DX, DISPLAY
LoopPS:
	MOV AL, [SI]	; Load the next char to be printed - USING INPUT PARAMETER SI
	CMP AL, '$'		; Compare the char to '$'
	JE quitPS			; If it is equal, then quit subroutine and return to calling code
	OUT DX,AL			; If it is not equal to '$', then print it
	INC SI				; Point to the next char to be printed
	jmp LoopPS		; Jump back to the top of the loop
quitPS:
	; Restore registers
	POP DX				; FIXED
	POP SI				; FIXED
	POP AX				; FIXED

	RET

s_CR .EQU 0Dh		; ASCII value for Carriage return
s_LF .EQU 0Ah		; ASCII value for NewLine

newLine:
	; Save registers modified by this subroutine
	PUSH AX						; FIXED
	PUSH DX						; FIXED

	MOV DX, DISPLAY		; Initialize the output port number in DX
	MOV AL, s_LF			; Load line feed (LF) into AL
	out DX,AL					; print the char
	MOV AL, s_CR			; Load carriage return (CR) into AL
	out DX,AL					; print the char

	; Restore registers
	POP DX						; FIXED
	POP AX						; FIXED

	RET

;;;;;;;;;;;;;;;;;
; getChar: waits for a keypress and returns pressed key in AL
; Input parameters:
; 	none.
; Output parameters:
;	AL: ASCII Value of key pressed by user

; Constants used by this subroutine
KBSTATUS .EQU 	0064h		; FIXED port number of keyboard STATUS reg
KBBUFFER .EQU 	0060h		; FIXED port number of keyboard BUFFER reg

getChar:
	push DX        			; save reg used
GCWait:
	MOV DX,	KBSTATUS		; load addr of keybrd STATUS
	IN AL,DX						; Read contents of keyboard STATUS register
	CMP AL,0						; key pressed?
	JE GCWait						; no, go back and check again for keypress

	MOV DX,	KBBUFFER		; load port number of kbrd BUFFER register
	IN AL,DX						; get key into AL from BUFFER
GCDone:
	pop DX        			; restore regs
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FROM lab8.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;
; getSign: waits for user to press '+' or '-'. Ignores other chars.
;          Valid input sign character is echoed to screen.
; Input parameters:
; 	none.
; Output parameters:
;	AL: Returns a zero for '+' and one for '-'
getSign:
; FIXED -- Complete entire subroutine. Suggest you create a flow chart first!
	Call getChar
	mov DX, DISPLAY
	OUT DX, AL
	cmp AL, '-'
	JE getpos

	cmp AL, '+'
	JE getneg

	jmp getSign
getpos:
mov AL, 0
RET
getneg:
mov AL,1
RET



;;;;;;;;;;;;;;;;;
; getDigit: waits for user to press 0-9 digit. Ignores other chars except RETURN
; Input parameters:
; 	none.
; Output parameters:
;	AL: Returns binary value of digit in AL. Returns 99 if user presses ENTER

; Constants used by this subroutine
ENTERK .EQU 0Ah

getDigit:
	CALL getChar
; FIXED -- complete entire subroutine
	cmp AL, ENTERK				; Check for ENTER Key (ENTERK)
	JNE skipGD
	mov AL, DONE					; if yes, return 99 in AL
	RET
skipGD:
	cmp AL, '0'						; check for '0'
	JB getDigit						; if below '0', get another char
	cmp AL, '9'						; check for '9'
	JA getDigit						; if above '9', get another char
	call printStr					; Echo digit back to screen (remember to save/restore any used registers)



												; Shift ASCII --> binary
	RET


;;;;;;;;;;;;;;;;;
; getNumber: Accepts a series of decimal digits and builds a binary number using shift-add
; Input parameters:
; 	none.
; Output parameters:
;	AL: Returns binary value of number in AL.

; Constants used by this subroutine
DONE .EQU 99

getNumber:				; FIXED -- complete entire subroutine
	PUSH CX					; Save CX register
	MOV CH, 0				; Use CH for running sum
	MOV CL, 10			; Use CL for multiplier=10
loopGN:
	call getDigit		; get a digit
	cmp	AL, ENTERK	; Check if user pressed ENTER
	JE doneGN				; If so, we are done this subroutine
	push AX					; Save entered character onto stack
	mov AL,CH				; Copy running sum into AL
	MUL CL					; Compute AX=sum*10 (then ignore AH)
	mov CH, AL			; Move running sum back into CH
	pop AX					; Restore saved character
	ADD CH,AL				; Add entered digit to shifted running sum
	JMP loopGN
doneGN:
	mov AL, CH			; Put final sum into AL
	POP CX					; Restore CX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 				Lab 10 code section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print:
	PUSH SI
	PUSH DX
	PUSH CX

	MOV CX, 8
	MOV DX, DISPLAY

ploop:
	SHL BL, 1
	JNC zero
	MOV AL, 31h
	JMP printnumber

zero:
	MOV AL, 30h

printnumber:
	OUT DX, AL
	DEC CX
	CMP CX, 0
	JNE ploop

	POP CX
	POP DX
	POP SI

	RET


	normalize:
	PUSH AX
looop:
	RCL CL, 1
	INC BX
	JNC looop
	MOV AL, 8
	SUB AL, BL
	ADD AL, 3
	MOV [EXP], AL
	MOV [SUM], CL
	POP AX

	RET

quarterprecisionform:
	MOV AL, 0
	MOV CL, [SIGN]
	ADD AL, CL
	SHL AL, 3


	MOV CL, [EXP]
	ADD AL, CL

	SHL AL, 4
	MOV CL, [SUM]
	SHR CL, 4
	ADD AL, CL

	RET




Message1: .DB	'Enter a number BW -33 to +33.$'		; FIXED -- Message to be printed on screen
Message2: .DB 	'Your normalized number is...$'

;;;;;;;;;;;;;
; Main function: Asks the user to enter a signed number between -MAX to +MAX
; 				Computes quarter-precision 8-bit IEEE-754 representation
;
;				Uses printStr, newline, and getChar subroutines.
main:
	mov SI, Message1						; FIXED Print prompt
	call printStr								; FIXED
	call newLine								; FIXED

part1:
	call getSign								; FIXED - call getSign to get +/- sign from keyboard
	mov [SIGN], AL							; FIXED - Save sign to global variable SIGN
	call getNumber							; FIXED -  call getNumber to get the unsigned number
	mov [SUM], AL								; FIXED -  Save number to global variable SUM

part2:
	CALL normalize
	CALL quarterprecisionform
	MOV BL, AL
	MOV SI, Message2
	CALL printStr
	CALL print



	HLT													;Quit



.END main		;Entry point of program is main()
