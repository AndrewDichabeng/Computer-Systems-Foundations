;	SYSC2001 Lab1b
;
; Note that many lines in this program are WRONG. These lines are marked with
; a ***FIX ME comment. You need to figure out how to fix each of these lines.
;

;; CONSTANTS
; In this case we are defining the symbol 'Display' to have the value
;  of 04E9h - the address of the Libra display screen
;
Display	.EQU 04E9h	; address of Libra display

; Define a memory location where the series of numbers to be printed will be start
; ** You will have to manually enter these numbers in memory in Libra prior to running your code!
NumAddr .EQU 0050h


;
;	Program: PrtNum - print the number in AL on the screen by converting to ASCII
;
;
Main:
;
; We must do some initialization
; First, we must initialize our pointer (BX) to point to the first number in memory that
; we wish to print (You will have to set the contents of memory!)
; To do this, we use immediate addressing mode to set BX==NumAddr
;
	mov BX, NumAddr
	mov DX, Display
;
; The next statement defines another address - the beginning of the print loop
;
mainLoop:
;
; Place the number to print into the 'AH' register
;
	MOV AH, [BX]		; FIXED Should load next number to be printed into AH

; Now we need to check if it we are done printing. If AH contains a zero, then quit.
;
	cmp AH,0				; FIXED Is the number a 0 ?
	JE EndPrt				; FIXED if so, we are done

; Now check if the number in AH is positive.



	CMP AH,0
	JG posNum				; FIXED SHOULD jump to 'posNum' label iff AH is positive.



	;mov AL, AH
	;out Dx, AL

negNum:
; If we get here, then our number is negative. We need to first print a negative sign
; and then convert our number to its positive equivalent before printing

; Print a negative sign
	mov AL, 2Dh		; FIXED Load the correct character to be printed into AL
	out DX,AL		; Send the character out to the display port

; Convert the negative number in AH to a positive number. This can be accomplished with a single instruction!
	NEG AH			; FIXED Change to the correct instruction. See the p86reference sheet.

posNum:

	CMP AH, 100
	JL secondDigit

	MOV AL, '1'
	out DX, AL
	SUB AH, 100

secondDigit:
	CMP AH, 10
	JL singleDigit
	MOV CL, 10
	MOV AL, AH
	MOV AH, 0
	DIV CL
	ADD AL, 30h
	out DX, AL


singleDigit:
; If we get here, then our number is now positive (or always was).
; We need to convert the number to its ASCII equivalent and print it
	mov AL, AH
	ADD AL, 30h
	out DX, AL




; Print a carriage return, so that the next number is printed on a new line
	MOV AL, 0Dh		; FIXED Should load carriage return (CR) into AL
	out DX,AL			; print the CR
	MOV AL, 0Ah		; FIXED Should load line feed (LF) into AL
	out DX,AL			; print the LF




; Look at the next number to be printed
	inc BX			; step along the array of numbers to the next number
;
; The next statement is an unconditional jump back to the beginning of the loop
; "Unconditional" means that the jump is ALWAYS taken (no CMP needed).
;
	jmp mainLoop; loop back

EndPrt:
	HLT			; Stop the Libra processor

.END Main