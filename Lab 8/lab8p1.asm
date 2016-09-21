; Lab8 Part I - Program to prompt the user to enter a string
;				Gets characters from the keyboard one at a time
; 				Checks if the user presses 'ENTER'
;				Once 'ENTER' is pressed, echos the string back from the stack in REVERSE order

; Constant definitions
DISPLAY	.EQU 04E9h	; address of Libra display


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Insert Sub-routines getChar, printStr, and newLine from Lab 7 here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printStr:
	; Save registers modified by this subroutine
	PUSH AX			; FIXED
	PUSH SI			; FIXED
	PUSH DX			; FIXED

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
	POP DX			; FIXED
	POP SI			; FIXED
	POP AX			; FIXED

	RET

s_CR .EQU 0Dh		; ASCII value for Carriage return
s_LF .EQU 0Ah		; ASCII value for NewLine

newLine:
	; Save registers modified by this subroutine
	PUSH AX				; FIXED
	PUSH DX				; FIXED

	MOV DX, DISPLAY		; Initialize the output port number in DX
	MOV AL, s_LF			; Load line feed (LF) into AL
	out DX,AL					; print the char
	MOV AL, s_CR			; Load carriage return (CR) into AL
	out DX,AL					; print the char

	; Restore registers
	POP DX			; FIXED
	POP AX			; FIXED

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
; END OF SUBROUTINES FROM lab7.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;
; print2Str: Subroutine to print a '$'-terminated string
;			Each character in the string is stored
; 			as a 2-byte value. Only the lower byte is meaningful
; Input parameters:
; 	SI: Address of start of string to be printed
; Output parameters:
;	None.
print2Str:

;
; FIXED -- Complete this subroutine. Use printStr, and just change one line...
;
call printStr
Inc SI
Inc SI

	RET


Message1: .DB	'Enter a string$'		; Prompt to be printed on screen


;;;;;;;;;;;;;
; Main function: Asks the user to enter a string
; 				Echos the string to screen in reverse order.
;				Uses printStr, newline, and getChar subroutines.
main:
	mov SI, Message1		; FIXED -- prompt the user
	call printStr				; FIXED
	call newLine				; FIXED




	MOV AH, 00h					; FIXED -- These three lines should push a '$' (zero-padded to 16 bits). WHY??
	MOV AL, '$'
	PUSH AX			;
gsAgain:
	CALL getChar				; FIXED -- Get a character
	cmp AL, 0Ah					; FIXED -- Next two lines should check if the user pressed ENTER, then stop accepting characters
	JE gsPrint
	push AX							; FIXED -- Push the character as a 16-bit value
	jmp gsAgain					; FIXED -- Get the next char
gsPrint:
	;I don't know what's the starting address...
	Mov SI, SP					; FIXED -- Load the starting address of the string
	CALL print2Str			; FIXED -- Print the string in reverse
	CALL newLine				; FIXED

gsDone:
	;Quit
	HLT


.END main		;Entry point of program is main()
