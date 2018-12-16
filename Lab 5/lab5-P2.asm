; Lab5 - Subroutine to print a record from an array of structures

; Constant definitions
Display		.EQU 04E9h              ; address of Libra display


; Constant strings (prompts or labels to be printed to screen, etc)
s_name: 	.DB 'Name: $'
s_male: 	.DB 'Mr. $'
s_female: 	.DB 'Ms. $'
s_empNum: 	.DB 'Employee number: $'
s_salary: 	.DB 'Salary: $'

; Offsets to access individual fields within the records
ID			.EQU 0                  ; Zero bytes from start of record is ID
NAME 		.EQU 1                  ; One byte from start of record is name
GENDER 		.EQU 3                  ; 3 bytes from start of record is gender
SALARY 		.EQU 4                  ; 4 bytes from start of record is salary
REC_SIZE	.EQU 5                  ; Total size of each record is 5 bytes

; Other defines
male		.EQU 0                  ; Gender field: 0=male
female		.EQU 1                  ; Gender field: 1=female

; ---------------------------------------------------------------
; Function: printEmployee
; Function to print an employee record to screen.

; Input Parameters:
; BX: Address of start of array of structures
; AL: Record number to be printed (record numbering starts at 0)
; Output Paramters:
; None.
; ---------------------------------------------------------------
printEmployee:
        ; Save register values that will be modified in this routine
        push AX                  ; FIXED
        push BX                  ; FIXED
        push SI                  ; FIXED
                                 ; Calculate starting address of this record
                                 ; Starting address is START+(REC_NUM*REC_SIZE)
        mov AH,	REC_SIZE         ; FIXED  Load REC_SIZE into AH
        mul AH                   ; FIXED  Multiply REC_NUM (already in AL) by REC_SIZE (in AH)
        add Bx,Ax                ; FIXED  Compute START+(REC_NUM*REC_SIZE)

                                 ; Print 'Name: ' label
        mov SI, s_name           ; FIXED
        call printStr

        ; Print Mr/Mrs according to gender
        mov AL, [BX+3]           ; FIXED  Load the gender field into AL. Need to use displacement addressing mode
        cmp AL, male             ; Compare gender to zero
        je printMale
    printFemale:
        mov SI, s_female         ; FIXED  Print Ms.
        call printStr
        jmp	printName
    printMale:
        mov SI, s_male           ; FIXED  Print Mr.
        call printStr

        ; Print name. Must load name pointer into DX, then call printStr
    printName:
        mov SI, [BX+1]           ; FIXED  Load the name field into SI. Need to use displacement addressing mode
        call printStr
        call newLine             ; Print a newLine character

                                 ; Print employee number
    printEmpNum:
        mov AL, [s_empNum]       ; FIXEDPrint 'Employee number: '
        call printStr
        mov AL, [BX]             ; FIXED  Load the ID field into AL. Need to use displacement addressing mode
        call printInt
        call newLine

        ; Print employee salary
    printEmpSalary:
        mov AL, [s_salary]       ; FIXED  Print the 'Salary: ' label
        call printStr
        mov AL, [BX+4]           ; FIXED  Load the SALARY field into AL. Need to use displacement addressing mode
        call printSalary         ; Prints salary in 1000's of $
        call newLine             ; Print a newline

                                 ; Restore registers
        pop SI                   ; FIXED
        pop BX                   ; FIXED
        pop AX                   ; FIXED

                                 ; Return to calling function
    RET


    ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; INSERT SUBROUTINES FROM lab5-P1.asm HERE
    ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ---------------------------------------------------------------
; printStr: Subroutine to print a '$'-terminated string
; Input parameters:
; SI: Address of start of string to be printed
; Output parameters:
; None.
; ---------------------------------------------------------------
printStr:
    ; Save registers modified by this subroutine
    push AX                      ; FIXED
    push CX                      ; FIXED
    push DX                      ; FIXED

    mov DX, Display

LoopPS:
    mov AL, [SI]                 ; Load the next char to be printed - USING INPUT PARAMETER SI
    cmp AL, '$'                  ; Compare the char to '$'
    je quitPS                    ; If it is equal, then quit subroutine and return to calling code
    out DX,AL                    ; If it is not equal to '$', then print it
    inc SI                       ; Point to the next char to be printed
    jmp LoopPS                   ; Jump back to the top of the loop

quitPS:
    ; Restore registers
    pop DX                       ; FIXED
    pop CX                       ; FIXED
    pop AX                       ; FIXED

    RET

; ---------------------------------------------------------------
; printInt: Subroutine to print a 1-byte unsigned (short) integer between 0-255
; Input parameters:
; AL: Unsigned short int to be printed
; Output parameters:
; None.
; ---------------------------------------------------------------
printInt:
    ; Save registers modified by this subroutine
    push AX                      ; FIXED
    push CX                      ; FIXED
    push DX                      ; FIXED
    mov DX, Display
    mov CL, 10                   ; Will be dividing by 10...

LoopPI:
    cmp AL, 10                   ; Compare the number to 10
    jl printLast                 ; If it is less than 10, then print this digit
                                 ; If it is greater than 10, divide by 10
    mov AH, 0                    ; Clear AH
    div CL                       ; Divide number by 10
    call printDigit              ; Print the quotient in AL
    mov AL, AH                   ; Move remainder into AL to be printed
    jmp LoopPI                   ; Jump back to the top of the loop
printLast:
    call printDigit
    ; Restore registers
    pop DX                       ; FIXED
    pop CX                       ; FIXED
    pop AX                       ; FIXED
    RET


; ---------------------------------------------------------------
; printDigit: Subroutine to print a single decimal digit
; Input parameters:
; AL: Unsigned decimal digit (between 0-9) to be printed
; Output parameters:
; None.
; ---------------------------------------------------------------
printDigit:
    ; Save registers modified by this subroutine
    push AX                      ; FIXED
    push DX                      ; FIXED
    mov DX, Display
    add AL, '0'                  ; Convert number to ASCII code
                                 ; RET ;-------------------> REMOVE COMMENT
    out DX,AL                    ; Print it
                                 ; Restore registers
    pop DX                       ; FIXED
    pop AX                       ; FIXED
    RET


; ---------------------------------------------------------------
; printSalary: Subroutine to print employee salary
; Input parameters:
; AL: Unsigned short int (0-99) representing salary in 1000's of $
; Output parameters:
; None.
; ---------------------------------------------------------------

; Constant strings for this subroutine:
s_thousands: .DB ',000$'
s_dollars: .DB '$'

printSalary:
    ; Save registers modified by this subroutine
    push AX                      ; FIXED
    push DX                      ; FIXED
    push SI                      ; FIXED
    mov DX, Display
    mov AH,AL                    ; Keep a copy of the salary in AH (need AL for printing...)
    mov AL, [s_dollars]          ; Print '$' preceeding number
    out DX,AL                    ; Print it
    mov AL,AH                    ; Move salary back into AL
    call printInt                ; Print the salary (0-255)
    mov SI, s_thousands          ; Move the starting address of s_thousands string into BX
    call printStr                ; Print ',000'
                                 ; Restore registers
    pop SI                       ; FIXED
    pop DX                       ; FIXED
    pop AX                       ; FIXED
    RET

; ---------------------------------------------------------------
; newLine: Subroutine to print a newline and a linefeed character
; Input parameters:
; None.
; Output parameters:
; None.
; ---------------------------------------------------------------

; Constants for this subroutine:
s_CR .EQU 0Dh                    ; ASCII value for Carriage return
s_LF .EQU 0Ah                    ; ASCII value for NewLine

newLine:
    ; Save registers modified by this subroutine
    push AX                      ; FIXED
    push DX                      ; FIXED
    mov DX, Display              ; Initialize the output port number in DX
    mov AL, s_LF                 ; Load line feed (LF) into AL
    out DX,AL                    ; print the char
    mov AL, s_CR                 ; Load carriage return (CR) into AL
    out DX,AL                    ; print the char
                                 ; Restore registers
    pop DX                       ; FIXED
    pop AX                       ; FIXED
    RET


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FROM lab5-P1.asm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ---------------------------------------------------------------
; main: Main function to test all subroutines
; ---------------------------------------------------------------
main:
    ; Print dayShiftDB[0]
    mov BX, dayShiftDB           ; FIXED Load address of dayShiftDB
    mov AL, 0                    ; FIXED Load record number
    call printEmployee
    call newLine

    ; ;HEEEEELPPPP!!!!!
    ; Print dayShiftDB[3]
    mov BX, dayShiftDB           ; FIXED Load address of dayShiftDB
    mov AL, 3                    ; FIXED Load record number
    call printEmployee
    call newLine

    ; Print nightShiftDB[0]
    mov BX, nightShiftDB         ; FIXED Load address of nightShiftDB
    mov AL, 0                    ; FIXED Load record number
    call printEmployee
    call newLine

    ; Quit
    HLT


; ---------------------------------------------------------------
; Test data
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Record format:
; Struct Employee {
; int id;			// 1-byte unsigned integer ID
; char* name;		// 2-byte pointer to string of chars
; bool gender;	// 1-byte Boolean (zero-->male, else-->female)
; short salary;	// 1-byte unsigned short int salary (in $1000�s)
; };
; ---------------------------------------------------------------
.ORG 5000h

dayShiftDB:
    ; Record dayShiftDB[0]
    .DB 12                       ; dayShiftDB[0].id
    .DW name0                    ; dayShiftDB[0].name
    .DB 0                        ; dayShiftDB[0].gender
    .DB 50                       ; dayShiftDB[0].salary

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
    .DW name4                    ; Record nightShiftDB[0]
    .DB 1
    .DB 99

    .DB 80
    .DW name5                    ; Record nightShiftDB[1]
    .DB 0
    .DB 75

name0: .DB 'Sam Jones$'
name1: .DB 'Sara Thomas$'
name2: .DB 'Samira Smith$'
name3: .DB 'Max Golshani$'
name4: .DB 'The Boss!$'
name5: .DB 'Sven Svenderson$'

.END main                        ; Entry point of program is main()
