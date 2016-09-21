; Lab6 - Subroutine to retrieve and print a salary from
;		  an Employee record from an array of structures

; Constant definitions
Display	.EQU 04E9h	; address of Libra display

; Offsets to access individual fields within the records
ID			.EQU 0	; Zero bytes from start of record is ID
NAME 		.EQU 1	; One byte from start of record is name
GENDER 		.EQU 3	; 3 bytes from start of record is gender
SALARY 		.EQU 4	; 4 bytes from start of record is salary
REC_SIZE	.EQU 5	; Total size of each record is 5 bytes


;;;;;;;;;;;;;;;;;;;;
; Function: getSalary
; Function to retrive the salary of the specified employee record.
;
; Input Parameters:
; 	Stack: 16-bit address of start of array of structures
;	Stack: 8-bit record number to be printed (record numbering starts at 0)
; Output Paramters:
;	Stack: returns 8-bit salary of specified Employee record
getSalary:
	; Save register values that will be modified in this routine
	Push AX							;	FIXED
	Push SI							;	FIXED
	Push BP							;	FIXED
	Push BX							;	FIXED

	; Get input parameters from the stack.
	; Use SI for the start address of the array of structures
	; Use AL for record number
	mov BP, SP					;	FIXED
	mov SI, [BP+10]			;	FIXED
	Mov AL, [BP+12]			;	FIXED

	; Calculate OFFSET of this record (distance from starting address of array of structures)
	; Offset is REC_NUM*REC_SIZE)
	mov AH, REC_SIZE		;	FIXED: Load REC_SIZE into suitable register (for MUL)
	MUL AH							;	FIXED: Multiply REC_NUM by REC_SIZE
	ADD Bx,Ax						;	FIXED: move offset into a suitable register (see next line)

	; For the next instruction, you MUST USE BASED-INDEXED Addressing mode (look it up!)
	MOV AL, [BX+SI+SALARY]	;	FIXED - Load the salary of this record into AL

	MOV [BP+14], AX					;	FIXED - Save return value into reserved slot in stack frame

	; Restore registers
	Pop BX							;	FIXED
	Pop BP							;	FIXED
	Pop SI							;	FIXED
	Pop AX							;	FIXED


	; Return to calling function
	RET							;	FIXED


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INSERT SUBROUTINES FROM lab6-P1.asm HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;
; printInt: Subroutine to print a 1-byte unsigned (short) integer between 0-255
; Input parameters:
; 	Stack: Unsigned short int to be printed
; Output parameters:
;	None.
printInt:
	; Save registers modified by this subroutine
	PUSH AX			;	FIXED
	PUSH CX			;	FIXED
	PUSH BP			;	FIXED

	; Retrieve input parameter from stack into AL
	MOV BP, SP				;	FIXED - make a copy of SP
	MOV AL, [BP + 8]	;	FIXED - read from the appropriate slot of your stack frame

	MOV CL, 10		; Will be dividing by 10...

LoopPI:
	CMP AL, 10		; Compare the number to 10
	JL printLast	; If it is less than 10, then print this digit
								; If it is greater than 10, divide by 10
	MOV AH, 0			; Clear AH
	DIV CL				; Divide number by 10
	push AX				;	FIXED - Push the input parameter of printDigit onto the stack
	CALL printDigit ; Print the quotient in AL
	pop AX				;	FIXED - Pop the input parameter of printDigit back off the stack
	MOV AL, AH		; Move remainder into AL to be printed
	jmp LoopPI		; Jump back to the top of the loop
printLast:
	push AX				;	FIXED - Push the input parameter of printDigit onto the stack
	CALL printDigit ; Print the quotient in AL
	pop AX				;	FIXED - Pop the input parameter of printDigit back off the stack

	; Restore registers
	POP Bp				;	FIXED
	POP CX				;	FIXED
	POP AX				;	FIXED

	RET


;;;;;;;;;;;;;;;;;
; printDigit: Subroutine to print a single decimal digit
; Input parameters:
; 	Stack: Unsigned decimal digit (between 0-9) to be printed
; Output parameters:
;	None.
printDigit:
	; Save registers modified by this subroutine
	PUSH AX			;	FIXED
	PUSH DX			;	FIXED
	PUSH Bp			;	FIXED

	; Retrieve input parameter from stack into AL
	MOV BP,SP				;	FIXED- make a copy of SP
	MOV AL, [BP+8]	;	FIXED - read from the appropriate slot of your stack frame

	MOV DX, Display
	ADD AL, '0'			; Convert number to ASCII code
	OUT DX,AL				; Print it

	; Restore registers
	POP Bp			;	FIXED
	POP DX			;	FIXED
	POP AX			;	FIXED

	RET


;;;;;;;;;;;;;;;;;
; printSalary: Subroutine to print employee salary
; Input parameters:
; 	Stack: Unsigned short int (0-255) representing salary in 1000's of $
; Output parameters:
;	None.

printSalary:
	; Save registers modified by this subroutine
	PUSH AX
	PUSH SI				; Not strictly necessary, but please keep
	PUSH DX
	PUSH Bp				;	FIXED

	; Retrieve input parameter from stack into AL
	MOV BP,SP					;	FIXED - make a copy of SP
	MOV AL, [BP+ 10]	;	FIXED - read from the appropriate slot of your stack frame

	MOV DX, Display

	MOV AH,AL				; Keep a copy of the salary in AH (need AL for printing...)
	MOV AL, '$'			; Print '$' preceeding number
	OUT DX,AL				; Print it
	MOV AL,AH				; Move salary back into AL
	push AX					;	FIXED - Push the input parameter of printInt onto the stack
	CALL printInt		; Print the salary (0-255)
	pop AX					;	FIXED - Pop the input parameter of printInt back off the stack

	MOV AL, ','			; Print ',' after number
	OUT DX,AL				; Print it
	MOV AL, '0'			; Print '0' after comma
	OUT DX,AL				; Print a zero
	OUT DX,AL				; Print a zero
	OUT DX,AL				; Print a zero

	; Restore registers
	POP Bp					;	FIXED
	POP DX
	POP SI
	POP AX

	RET


;;;;;;;;;;;;;;;;;
; newLine: Subroutine to print a newline and a linefeed character
; Input parameters:
; 	None.
; Output parameters:
;	None.

; Constants for this subroutine:
s_CR .EQU 0Dh		; ASCII value for Carriage return
s_LF .EQU 0Ah		; ASCII value for NewLine

newLine:
	; Save registers modified by this subroutine
	PUSH AX
	PUSH DX

	MOV DX, Display		; Initialize the output port number in DX
	MOV AL, s_LF			; Load line feed (LF) into AL
	out DX,AL					; print the char
	MOV AL, s_CR			; Load carriage return (CR) into AL
	out DX,AL					; print the char

	; Restore registers
	POP DX
	POP AX

	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FROM lab6-P1.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;
; main: Main function to test all subroutines
main:

	; Print salary of dayShiftDB[0]
	MOV BX, dayShiftDB
	MOV AL,0
	;MOV AL, 0
	push AX						;	FIXED Make room on stack for return value from getSalary
	push AX						; FIXED Push record number
	push BX						; FIXED Push starting address of array of structures
	call getSalary		; FIXED Invoke getSalary subroutine
	pop BX						; FIXED Pop starting address of array of structures
	pop AX						; FIXED Pop record number

	call printSalary	; Input parameter for printSalary is already on the stack!
	CALL newLine
	pop AX						; FIXED Pop the return value from getSalary

	; Print dayShiftDB[3] FIX ME. Add LINES BELOW TO DO THIS

	MOV BX, dayShiftDB
	MOV AL, 3
	push AX						; FIXED Make room on stack for return value from getSalary
	push AX						; FIXED Push record number
	push BX						; FIXED Push starting address of array of structures
	call getSalary		; FIXED Invoke getSalary subroutine
	pop BX						; FIXED Pop starting address of array of structures
	pop AX						; FIXED Pop record number
	call printSalary	; Input parameter for printSalary is already on the stack!
	CALL newLine
	pop AX						; FIXED Pop the return value from getSalary
	; Print nightShiftDB[0] FIX ME. Add LINES BELOW TO DO THIS
MOV BX, nightShiftDB
	MOV AL, 0
	push AX						; FIXED Make room on stack for return value from getSalary
	push AX						; FIXED Push record number
	push BX						; FIXED Push starting address of array of structures
	call getSalary		; FIXED Invoke getSalary subroutine
	pop BX						; FIXED Pop starting address of array of structures
	pop AX						; FIXED Pop record number

	call printSalary	; Input parameter for printSalary is already on the stack!
	CALL newLine
	pop AX						; FIXED Pop the return value from getSalary
	;Quit
	HLT


;;;;;;;;;;;;;;;;;;;;;;;;
; Test data
;

; Record format:
;Struct Employee {
;	char* name;	// 2-byte pointer to string of chars
;	bool gender;	// 1-byte Boolean (zero-->male, else-->female)
;	short salary;	// 1-byte unsigned short int salary (in $1000�s)
;	int id;		// 1-byte unsigned integer ID
;};
.ORG 5000h

dayShiftDB:
	; Record dayShiftDB[0]
	.DB 12			; dayShiftDB[0].id
	.DW name0		; dayShiftDB[0].name
	.DB 0				; dayShiftDB[0].gender
	.DB 50			; dayShiftDB[0].salary

	; Record dayShiftDB[1]
	.DB 27
	.DW name1
	.DB 1
	.DB 58

	; Record dayShiftDB[2]
	.DB 1
	.DW name2
	.DB 1
	.DB 70

	; Record dayShiftDB[3]
	.DB 77
	.DW name3
	.DB 0
	.DB 32

nightShiftDB:
	.DB 7
	.DW name4		; Record nightShiftDB[0]
	.DB 1
	.DB 99

	.DB 80
	.DW name5		; Record nightShiftDB[1]
	.DB 0
	.DB 75

name0: .DB 'Sam Jones$'
name1: .DB 'Sara Thomas$'
name2: .DB 'Samira Smith$'
name3: .DB 'Max Golshani$'
name4: .DB 'The Boss!$'
name5: .DB 'Sven Svenderson$'

.END main		;Entry point of program is main()
