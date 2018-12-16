; Lab8 Part I - Program to prompt the user to enter a string
; Gets characters from the keyboard one at a time
; Checks if the user presses 'ENTER'
; Once 'ENTER' is pressed, echos the string back from the stack in REVERSE order

; Constant definitions
DISPLAY	.EQU 04E9h              ; address of Libra display


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Insert Sub-routines getChar, printStr, and newLine from Lab 7 here
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printStr:
    ; Save registers modified by this subroutine
    push AX                     ; FIXED
    push SI                     ; FIXED
    push DX                     ; FIXED

    mov DX, DISPLAY

LoopPS:
    mov AL, [SI]                ; Load the next char to be printed - USING INPUT PARAMETER SI
    cmp AL, '$'                 ; Compare the char to '$'
    je quitPS                   ; If it is equal, then quit subroutine and return to calling code
    out DX,AL                   ; If it is not equal to '$', then print it
    inc SI                      ; Point to the next char to be printed
    jmp LoopPS                  ; Jump back to the top of the loop

quitPS:
    ; Restore registers
    pop DX                      ; FIXED
    pop SI                      ; FIXED
    pop AX                      ; FIXED

    RET

s_CR .EQU 0Dh                   ; ASCII value for Carriage return
s_LF .EQU 0Ah                   ; ASCII value for NewLine

newLine:
    ; Save registers modified by this subroutine
    push AX                     ; FIXED
    push DX                     ; FIXED

    mov DX, DISPLAY             ; Initialize the output port number in DX
    mov AL, s_LF                ; Load line feed (LF) into AL
    out DX,AL                   ; print the char
    mov AL, s_CR                ; Load carriage return (CR) into AL
    out DX,AL                   ; print the char

  	; Restore registers
    pop DX                      ; FIXED
    pop AX                      ; FIXED

    RET

; ---------------------------------------------------------------
; getChar: waits for a keypress and returns pressed key in AL
; Input parameters:
; none.
; Output parameters:
; AL: ASCII Value of key pressed by user
; ---------------------------------------------------------------

; Constants used by this subroutine
KBSTATUS .EQU 	0064h            ; FIXED port number of keyboard STATUS reg
KBBUFFER .EQU 	0060h            ; FIXED port number of keyboard BUFFER reg

getChar:
    push DX                     ; save reg used
GCWait:
    mov DX,	KBSTATUS            ; load addr of keybrd STATUS
    in AL,DX                    ; Read contents of keyboard STATUS register
    cmp AL,0                    ; key pressed?
    je GCWait                   ; no, go back and check again for keypress

    mov DX,	KBBUFFER            ; load port number of kbrd BUFFER register
    in AL,DX                    ; get key into AL from BUFFER
GCDone:
    pop DX                      ; restore regs
    ret


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FROM lab7.asm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ---------------------------------------------------------------
; print2Str: Subroutine to print a '$'-terminated string
; Each character in the string is stored
; as a 2-byte value. Only the lower byte is meaningful
; Input parameters:
; SI: Address of start of string to be printed
; Output parameters:
; None.
; ---------------------------------------------------------------
print2Str:
		; FIXED -- Complete this subroutine. Use printStr, and just change one line...
		call printStr
		inc SI
		inc SI

		RET

Message1: .DB	'Enter a string$' ; Prompt to be printed on screen


; ---------------------------------------------------------------
; Main function: Asks the user to enter a string
; Echos the string to screen in reverse order.
; Uses printStr, newline, and getChar subroutines.
; ---------------------------------------------------------------
main:
    mov SI, Message1            ; FIXED -- prompt the user
    call printStr               ; FIXED
    call newLine                ; FIXED
    mov AH, 00h                 ; FIXED -- These three lines should push a '$' (zero-padded to 16 bits). WHY??
    mov AL, '$'
    push AX

gsAgain:
    call getChar                ; FIXED -- Get a character
    cmp AL, 0Ah                 ; FIXED -- Next two lines should check if the user pressed ENTER, then stop accepting characters
    je gsPrint
    push AX                     ; FIXED -- Push the character as a 16-bit value
    jmp gsAgain                 ; FIXED -- Get the next char
		
gsPrint:
    ; I don't know what's the starting address...
    mov SI, SP                  ; FIXED -- Load the starting address of the string
    call print2Str              ; FIXED -- Print the string in reverse
    call newLine                ; FIXED

gsDone:
    ; Quit
    HLT


.END main                       ; Entry point of program is main()
