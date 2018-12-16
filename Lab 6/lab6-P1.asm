; Lab6-P1 - Subroutines to print integers, digits, and salaries

; Constant definitions
Display	.EQU 04E9h               ; address of Libra display

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; START OF SUBROUTINES to COPY to lab6-P2.asm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ---------------------------------------------------------------
; printInt: Subroutine to print a 1-byte unsigned (short) integer between 0-255
; Input parameters:
; Stack: Unsigned short int to be printed
; Output parameters:
; None.
; ---------------------------------------------------------------
printInt:
    ; Save registers modified by this subroutine
    push AX
    push CX
    push BX                      ; FIXED
                                 ; Retrieve input parameter from stack into AL
    mov BP, SP                   ; FIXED - make a copy of SP
    mov AL, [BP+4]               ; FIXED - read from the appropriate slot of your stack frame
    mov CL, 10                   ; Will be dividing by 10...

LoopPI:
    cmp AL, 10                   ; Compare the number to 10
    jl printLast                 ; If it is less than 10, then print this digit
                                 ; If it is greater than 10, divide by 10
    mov AH, 0                    ; Clear AH
    div CL                       ; Divide number by 10
    push BX                      ; FIXED - Push the input parameter of printDigit onto the stack
    call printDigit              ; Print the quotient in AL
    pop BX                       ; FIXED - Pop the input parameter of printDigit back off the stack
    mov AL, AH                   ; Move remainder into AL to be printed
    jmp LoopPI                   ; Jump back to the top of the loop

printLast:
    push BX                      ; FIXED - Push the input parameter of printDigit onto the stack
    call printDigit              ; Print the quotient in AL
    pop BX                       ; FIXED - Pop the input parameter of printDigit back off the stack
                                 ; Restore registers
    pop BX                       ; FIXED
    pop CX                       ; FIXED
    pop AX                       ; FIXED
    RET


; ---------------------------------------------------------------
; printDigit: Subroutine to print a single decimal digit
; Input parameters:
; Stack: Unsigned decimal digit (between 0-9) to be printed
; Output parameters:
; None.
; ---------------------------------------------------------------
printDigit:
    ; Save registers modified by this subroutine
    push AX
    push DX
    push BX                      ; FIXED
                                 ; Retrieve input parameter from stack into AL
    mov BP,SP                    ; FIXED - make a copy of SP
    mov AL, [BP+4]               ; FIXED - read from the appropriate slot of your stack frame
    mov DX, Display
    add AL, '0'                  ; Convert number to ASCII code
    out DX,AL                    ; Print it
                                 ; Restore registers
    pop BX                       ; FIXED
    pop DX                       ; FIXED
    pop AX                       ; FIXED
    RET


; ---------------------------------------------------------------
; printSalary: Subroutine to print employee salary
; Input parameters:
; Stack: Unsigned short int (0-255) representing salary in 1000's of $
; Output parameters:
; None.
; ---------------------------------------------------------------

printSalary:
    ; Save registers modified by this subroutine
    push AX
    push SI                      ; Not strictly necessary, but please keep
    push DX
    push BX                      ; FIXED
                                 ; Retrieve input parameter from stack into AL
    mov BP,SP                    ; FIXED - make a copy of SP
    mov AL, [BP+ 6]              ; FIXED - read from the appropriate slot of your stack frame
    mov DX, Display
    mov AH,AL                    ; Keep a copy of the salary in AH (need AL for printing...)
    mov AL, '$'                  ; Print '$' preceeding number
    out DX,AL                    ; Print it
    mov AL,AH                    ; Move salary back into AL
    push BX                      ; FIXED - Push the input parameter of printInt onto the stack
    call printInt                ; Print the salary (0-255)
    pop BX                       ; FIXED - Pop the input parameter of printInt back off the stack
    mov AL, ','                  ; Print ',' after number
    out DX,AL                    ; Print it
    mov AL, '0'                  ; Print '0' after comma
    out DX,AL                    ; Print a zero
    out DX,AL                    ; Print a zero
    out DX,AL                    ; Print a zero
                                 ; Restore registers
    pop BX                       ; FIXED
    pop DX                       ; FIXED
    pop SI                       ; FIXED
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
    push AX
    push DX
    mov DX, Display              ; Initialize the output port number in DX
    mov AL, s_LF                 ; Load line feed (LF) into AL
    out DX,AL                    ; print the char
    mov AL, s_CR                 ; Load carriage return (CR) into AL
    out DX,AL                    ; print the char
                                 ; Restore registers
    pop DX
    pop AX
    RET

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FOR lab6-P2.asm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ---------------------------------------------------------------
; Test data
; ---------------------------------------------------------------

.ORG 00A0h

num1: .DB 86                     ; Should print as decimal 86
sal1: .DB 34                     ; Should print as '$34,000'

; ---------------------------------------------------------------
; main: Main function to test all subroutines
; ---------------------------------------------------------------
.ORG 00B0h

main:
    ; Print a short unsigned int (0-99). Use num1
    mov AL, [num1]               ; FIXED - get input parameter
    push AX                      ; FIXED - place input parameter on stack
    call printInt
    pop AX                       ; FIXED - remove input parameter from stack
    call newLine

    ; Print a salary. Use sal1
    mov AL, [sal1]               ; FIXED - get input parameter
    push AX                      ; FIXED - place input parameter on stack
    call printSalary
    pop AX                       ; FIXED - remove input parameter from stack
    call newLine

    ; Quit
    HLT

.END main                        ; Entry point of program is main()
