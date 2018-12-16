; Lab3b Part I - Subroutine to prompt the user to enter a key
; get a character from the keyboard
; and check if the user presses 'y'

; Constant definitions
DISPLAY	.EQU 04E9h                                             ; address of Libra display

; --------------------------------------------------------
; Insert subroutines printStr and newLine from Lab 5 here
; --------------------------------------------------------

printStr:
    ; Save registers modified by this subroutine
    push AX                                                    ; FIXED
    push SI                                                    ; FIXED
    push DX                                                    ; FIXED

    mov DX, DISPLAY

LoopPS:
    mov AL, [SI]                                               ; Load the next char to be printed - USING INPUT PARAMETER SI
    cmp AL, '$'                                                ; Compare the char to '$'
    je quitPS                                                  ; If it is equal, then quit subroutine and return to calling code
    out DX,AL                                                  ; If it is not equal to '$', then print it
    inc SI                                                     ; Point to the next char to be printed
    jmp LoopPS                                                 ; Jump back to the top of the loop
quitPS:
    ; Restore registers
    pop DX                                                     ; FIXED
    pop SI                                                     ; FIXED
    pop AX                                                     ; FIXED

    RET

s_CR .EQU 0Dh                                                  ; ASCII value for Carriage return
s_LF .EQU 0Ah                                                  ; ASCII value for NewLine

newLine:
    ; Save registers modified by this subroutine
    push AX                                                    ; FIXED
    push DX                                                    ; FIXED

    mov DX, DISPLAY                                            ; Initialize the output port number in DX
    mov AL, s_LF                                               ; Load line feed (LF) into AL
    out DX,AL                                                  ; print the char
    mov AL, s_CR                                               ; Load carriage return (CR) into AL
    out DX,AL                                                  ; print the char

                                                               ; Restore registers
    pop DX                                                     ; FIXED
    pop AX                                                     ; FIXED

    RET


; --------------------------------------------------------
; End of subroutines printStr and newLine from Lab 5 here
; --------------------------------------------------------


; ---------------------------------------------------------------
; getChar: waits for a keypress and returns pressed key in AL
; Input parameters:
; none.
; Output parameters:
; AL: ASCII Value of key pressed by user
; ---------------------------------------------------------------

; Constants used by this subroutine
KBSTATUS .EQU 	0064h                                           ; FIXED port number of keyboard STATUS reg
KBBUFFER .EQU 	0060h                                           ; FIXED port number of keyboard BUFFER reg

getChar:
    push DX                                                    ; save reg used
GCWait:
    mov DX,	KBSTATUS                                           ; load addr of keybrd STATUS
    in AL,DX                                                   ; Read contents of keyboard STATUS register
    cmp AL,0                                                   ; key pressed?
    je GCWait                                                  ; no, go back and check again for keypress

    mov DX,	KBBUFFER                                           ; load port number of kbrd BUFFER register
    in AL,DX                                                   ; get key into AL from BUFFER
GCDone:
    pop DX                                                     ; restore regs
    ret

Message1: .DB	'Please enter an Even number. $'
HappyMessage: .DB	'You have entered an even number! Yuppii! $' ; Message to be printed on screen
AnotherMessage: .DB	'Sorry not even. $'                        ; Message to be printed on screen
QuitChoice: .DB 'Would you like to quit? (y/n) $'

; ---------------------------------------------------------------
; Main function: Asks the user whether they want to quit or not.
; Repeats until user presses 'y'
; Uses printStr, newline, and getChar subroutines.
; ---------------------------------------------------------------
main:
    mov SI, Message1                                           ; Move starting address of Message1 to SI
    call printStr                                              ; Call prtstr to print Message1
    call newLine                                               ; Print a new line

    call getChar                                               ; call Getchar to get value from keyboard
    mov DX, DISPLAY
    out Dx, AL                                                 ; Echo the character back to the display
    call newLine

    mov AH, AL
    mov CL, 2
    div CL
    cmp AH, 0
    je HappyMsg

SadMessage:
		mov SI, AnotherMessage
		call printStr
		call newLine
		mov SI, QuitChoice
		call printStr
		call newLine
		call getChar
		call newLine
		cmp AL, 'y'                                                    ; compare input character with 'y'
		jne main
		je Quit

HappyMsg:
		mov SI, HappyMessage
		call printStr
		call newLine
		mov SI, QuitChoice
		call printStr
		call newLine
		call getChar
		call newLine
		cmp AL, 'y'                                                    ; compare input character with 'y'
		jne main
		je Quit


; If user did not press 'y', then re-prompt (start over)
Quit:
    HLT



.END main                                                      ; Entry point of program is main()
