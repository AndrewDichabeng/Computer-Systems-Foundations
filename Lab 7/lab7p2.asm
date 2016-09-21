; Lab3b Part I - Subroutine to prompt the user to enter a key
;				get a character from the keyboard
; 				and check if the user presses 'y'

; Constant definitions
DISPLAY	.EQU 04E9h	; address of Libra display


;---------------------------
;Insert subroutines printStr and newLine from Lab 5 here
;---------------------------
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
	PUSH AX			; FIXED
	PUSH DX			; FIXED

	MOV DX, DISPLAY		; Initialize the output port number in DX
	MOV AL, s_LF			; Load line feed (LF) into AL
	out DX,AL					; print the char
	MOV AL, s_CR			; Load carriage return (CR) into AL
	out DX,AL					; print the char

	; Restore registers
	POP DX			; FIXED
	POP AX			; FIXED

	RET


;---------------------------
;End of subroutines printStr and newLine from Lab 5 here
;---------------------------


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

Message1: .DB	'Please enter an Even number. $'
HappyMessage: .DB	'You have entered an even number! Yuppii! $'		; Message to be printed on screen
AnotherMessage: .DB	'Sorry not even. $'		; Message to be printed on screen
QuitChoice: .DB 'Would you like to quit? (y/n) $'
;;;;;;;;;;;;;
; Main function: Asks the user whether they want to quit or not.
; 				Repeats until user presses 'y'
;
;				Uses printStr, newline, and getChar subroutines.
main:
	MOV SI, Message1						;Move starting address of Message1 to SI
	CALL printStr								;Call prtstr to print Message1
	CALL newLine								;Print a new line

	CALL getChar								;call Getchar to get value from keyboard
	Mov DX, DISPLAY
	Out Dx, AL									; Echo the character back to the display
	CALL newLine

	MOV AH, AL
	MOV CL, 2
	DIV CL
	cmp AH, 0
	JE HappyMsg

SadMessage:
Mov SI, AnotherMessage
CALL printStr
CALL newLine
Mov SI, QuitChoice
CALL printStr
CALL newLine
CALL getChar
CALL newLine
CMP AL, 'y'								; compare input character with 'y'
JNE main
JE Quit

HappyMsg:
Mov SI, HappyMessage
CALL printStr
CALL newLine
Mov SI, QuitChoice
CALL printStr
CALL newLine
CALL getChar
CALL newLine
CMP AL, 'y'								; compare input character with 'y'
JNE main
JE Quit




									;If user did not press 'y', then re-prompt (start over)
	Quit:
	HLT



.END main		;Entry point of program is main()
