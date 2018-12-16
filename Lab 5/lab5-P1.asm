; Lab5 - Subroutine to print a record from an array of structures

; Constant definitions
Display	.EQU 04E9h                  ; address of Libra display


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; START OF SUBROUTINES to COPY to lab5-P2.asm
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
    push AX                         ; FIXED
    push SI                         ; FIXED
    push DX                         ; FIXED
    mov DX, Display                 ; Load the Libra display into register DX

LoopPS:
    mov AL, [SI]                    ; Load the next char to be printed - USING INPUT PARAMETER SI
    cmp AL, '$'                     ; Compare the char to '$'
    je quitPS                       ; If it is equal, then quit subroutine and return to calling code
    out DX,AL                       ; If it is not equal to '$', then print it
    inc SI                          ; Point to the next char to be printed
    jmp LoopPS                      ; Jump back to the top of the loop

quitPS:
    ; Restore registers
    pop DX                          ; FIXED
    pop SI                          ; FIXED
    pop AX                          ; FIXED
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
    push AX                         ; FIXED
    push CX                         ; FIXED
    push DX                         ; FIXED
    mov DX, Display
    mov CL, 10                      ; Will be dividing by 10...

LoopPI:
    cmp AL, 10                      ; Compare the number to 10
    jl printLast                    ; If it is less than 10, then print this digit
                                    ; If it is greater than 10, divide by 10
    mov AH, 0                       ; Clear AH
    div CL                          ; Divide number by 10
    call printDigit                 ; Print the quotient in AL
    mov AL, AH                      ; Move remainder into AL to be printed
    jmp LoopPI                      ; Jump back to the top of the loop

printLast:
    call printDigit

    ; Restore registers
    pop DX                          ; FIXED
    pop CX                          ; FIXED
    pop AX                          ; FIXED
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
    push AX                         ; FIXED
    push DX                         ; FIXED
    mov DX, Display
    add AL, '0'                     ; Convert number to ASCII code
    out DX,AL                       ; Print it
                                    ; Restore registers
    pop DX                          ; FIXED
    pop AX                          ; FIXED
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
    push AX                         ; FIXED
    push DX                         ; FIXED
    push SI                         ; FIXED
    mov DX, Display
    mov AH,AL                       ; Keep a copy of the salary in AH (need AL for printing...)
    mov AL, [s_dollars]             ; Print '$' preceeding number
    out DX,AL                       ; Print it
    mov AL,AH                       ; Move salary back into AL
    call printInt                   ; Print the salary (0-255)
    mov SI, s_thousands             ; Move the starting address of s_thousands string into BX
    call printStr                   ; Print ',000'
                                    ; Restore registers
    pop SI                          ; FIXED
    pop DX                          ; FIXED
    pop AX                          ; FIXED
    RET

; ---------------------------------------------------------------
; newLine: Subroutine to print a newline and a linefeed character
; Input parameters:
; None.
; Output parameters:
; None.
; ---------------------------------------------------------------

; Constants for this subroutine:
s_CR .EQU 0Dh                       ; ASCII value for Carriage return
s_LF .EQU 0Ah                       ; ASCII value for NewLine

newLine:
    ; Save registers modified by this subroutine
    push AX                         ; FIXED
    push DX                         ; FIXED
    mov DX, Display                 ; Initialize the output port number in DX
    mov AL, s_LF                    ; Load line feed (LF) into AL
    out DX,AL                       ; print the char
    mov AL, s_CR                    ; Load carriage return (CR) into AL
    out DX,AL                       ; print the char
                                    ; Restore registers
    pop DX                          ; FIXED
    pop AX                          ; FIXED
    RET

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FOR lab5-P2.asm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ---------------------------------------------------------------
; Test data
; ---------------------------------------------------------------

.ORG 00A0h

str1: .DB 'Hello World!$'           ; Should print as 'Hello World!'
num1: .DB 86                        ; Should print as decimal 86
sal1: .DB 34                        ; Should print as '$34,000'


; main: Main function to test all subroutines
.ORG 00B0h

main:
    ; Print a string. Use str1
    mov SI, str1                    ; FIXED
    call printStr
    call newLine

    ; Print a short unsigned int (0-99). Use num1
    mov AL, [num1]                  ; FIXED
    call printInt
    call newLine

    ; Print a salary. Use sal1
    mov AL,[sal1]                   ; FIXED
    call printSalary
    call newLine

    ; Quit
    HLT

.END main                           ; Entry point of program is main()
