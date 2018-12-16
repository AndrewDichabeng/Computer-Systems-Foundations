; Program to accept a signed decimal number in the format +/-xxxx
; Calculate the 8-bit "quarter precision" IEEE-754 encoding and print it to screen.


; Format -/+xxxx in decimal, entered as ASCII.
; 1) Get sign
; 2) Get number
; 3) Normalize number to get exponent
; 3) Compute bias-** representation of exponent
; 4) Create final IEEE-754 representation

; Constant definitions
DISPLAY	.EQU 04E9h                               ; address of Libra display

; Global variables
.ORG 0000
SIGN:	.DB	0                                      ; Sign of entered number (0=positive, 1=negative)
SUM:	.DB	0                                       ; Unsigned  binary representation of entered number
EXP:	.DB	0                                       ; Excess/bias representation of exponent (only uses lower 3 bits)
FP:		.DB	0                                       ; 8-bit quarter-precision IEEE-754 representation of number

.ORG 1000h
; -------------------------------------------------------------------
; Insert Sub-routines getChar, printStr, and newLine from Lab 8 here
; -------------------------------------------------------------------
printStr:
    ; Save registers modified by this subroutine
    push AX                                      ; FIXED
    push SI                                      ; FIXED
    push DX                                      ; FIXED

    mov DX, DISPLAY

LoopPS:
    mov AL, [SI]                                 ; Load the next char to be printed - USING INPUT PARAMETER SI
    cmp AL, '$'                                  ; Compare the char to '$'
    je quitPS                                    ; If it is equal, then quit subroutine and return to calling code
    out DX,AL                                    ; If it is not equal to '$', then print it
    inc SI                                       ; Point to the next char to be printed
    jmp LoopPS                                   ; Jump back to the top of the loop

quitPS:
    ; Restore registers
    pop DX                                       ; FIXED
    pop SI                                       ; FIXED
    pop AX                                       ; FIXED

    RET

s_CR .EQU 0Dh                                    ; ASCII value for Carriage return
s_LF .EQU 0Ah                                    ; ASCII value for NewLine

newLine:
    ; Save registers modified by this subroutine
    push AX                                      ; FIXED
    push DX                                      ; FIXED

    mov DX, DISPLAY                              ; Initialize the output port number in DX
    mov AL, s_LF                                 ; Load line feed (LF) into AL
    out DX,AL                                    ; print the char
    mov AL, s_CR                                 ; Load carriage return (CR) into AL
    out DX,AL                                    ; print the char

                                                 ; Restore registers
    pop DX                                       ; FIXED
    pop AX                                       ; FIXED

    RET

; ---------------------------------------------------------------
; getChar: waits for a keypress and returns pressed key in AL
; Input parameters:
; none.
; Output parameters:
; AL: ASCII Value of key pressed by user
; ---------------------------------------------------------------

    ; Constants used by this subroutine
KBSTATUS .EQU 	0064h                             ; FIXED port number of keyboard STATUS reg
KBBUFFER .EQU 	0060h                             ; FIXED port number of keyboard BUFFER reg

getChar:
    push DX                                      ; save reg used

GCWait:
    mov DX,	KBSTATUS                             ; load addr of keybrd STATUS
    in AL,DX                                     ; Read contents of keyboard STATUS register
    cmp AL,0                                     ; key pressed?
    je GCWait                                    ; no, go back and check again for keypress
    mov DX,	KBBUFFER                             ; load port number of kbrd BUFFER register
    in AL,DX                                     ; get key into AL from BUFFER

GCDone:
    pop DX                                       ; restore regs
    ret


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SUBROUTINES FROM lab8.asm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ---------------------------------------------------------------
; getSign: waits for user to press '+' or '-'. Ignores other chars.
; Valid input sign character is echoed to screen.
; Input parameters:
; none.
; Output parameters:
; AL: Returns a zero for '+' and one for '-'
; ---------------------------------------------------------------
getSign:
    call getChar
    mov DX, DISPLAY
    out DX, AL
    cmp AL, '-'
    je getpos
    cmp AL, '+'
    je getneg
    jmp getSign

getpos:
    mov AL, 0
    RET

getneg:
    mov AL,1
    RET


; -------------------------------------------------------------------------------
; getDigit: waits for user to press 0-9 digit. Ignores other chars except RETURN
; Input parameters:
; none.
; Output parameters:
; AL: Returns binary value of digit in AL. Returns 99 if user presses ENTER
; ------------------------------------------------------------------------------

; Constants used by this subroutine
ENTERK .EQU 0Ah

getDigit:
    call getChar
    cmp AL, ENTERK                               ; Check for ENTER Key (ENTERK)
    jne skipGD
    mov AL, DONE                                 ; if yes, return 99 in AL
    RET

skipGD:
    cmp AL, '0'                                  ; check for '0'
    jb getDigit                                  ; if below '0', get another char
    cmp AL, '9'                                  ; check for '9'
    ja getDigit                                  ; if above '9', get another char
    call printStr                                ; Echo digit back to screen (remember to save/restore any used registers)
                                                 ; Shift ASCII --> binary
    RET


; -----------------------------------------------------------------------------------------
; getNumber: Accepts a series of decimal digits and builds a binary number using shift-add
; Input parameters:
; none.
; Output parameters:
; AL: Returns binary value of number in AL.
; -----------------------------------------------------------------------------------------

; Constants used by this subroutine
DONE .EQU 99

getNumber:                                       ; FIXED -- complete entire subroutine
    push CX                                      ; Save CX register
    mov CH, 0                                    ; Use CH for running sum
    mov CL, 10                                   ; Use CL for multiplier=10

loopGN:
    call getDigit                                ; get a digit
    cmp	AL, ENTERK                               ; Check if user pressed ENTER
    je doneGN                                    ; If so, we are done this subroutine
    push AX                                      ; Save entered character onto stack
    mov AL,CH                                    ; Copy running sum into AL
    mul CL                                       ; Compute AX=sum*10 (then ignore AH)
    mov CH, AL                                   ; Move running sum back into CH
    pop AX                                       ; Restore saved character
    add CH,AL                                    ; Add entered digit to shifted running sum
    jmp loopGN

doneGN:
    mov AL, CH                                   ; Put final sum into AL
    pop CX                                       ; Restore CX
    RET

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lab 10 code section
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print:
    push SI
    push DX
    push CX
    mov CX, 8
    mov DX, DISPLAY

ploop:
    shl BL, 1
    jnc zero
    mov AL, 31h
    jmp printnumber

zero:
    mov AL, 30h

printnumber:
    out DX, AL
    dec CX
    cmp CX, 0
    jne ploop

    pop CX
    pop DX
    pop SI

    RET


normalize:
    push AX
		
looop:
    rcl CL, 1
    inc BX
    jnc looop
    mov AL, 8
    sub AL, BL
    add AL, 3
    mov [EXP], AL
    mov [SUM], CL
    pop AX

    RET

quarterprecisionform:
    mov AL, 0
    mov CL, [SIGN]
    add AL, CL
    shl AL, 3
    mov CL, [EXP]
    add AL, CL
    shl AL, 4
    mov CL, [SUM]
    shr CL, 4
    add AL, CL

    RET


Message1: .DB	'Enter a number BW -33 to +33.$'   ; FIXED -- Message to be printed on screen
Message2: .DB 	'Your normalized number is...$'

; ---------------------------------------------------------------------------
; Main function: Asks the user to enter a signed number between -MAX to +MAX
; Computes quarter-precision 8-bit IEEE-754 representation
; Uses printStr, newline, and getChar subroutines.
; ---------------------------------------------------------------------------
main:
    mov SI, Message1                             ; FIXED Print prompt
    call printStr                                ; FIXED
    call newLine                                 ; FIXED

part1:
    call getSign                                 ; FIXED - call getSign to get +/- sign from keyboard
    mov [SIGN], AL                               ; FIXED - Save sign to global variable SIGN
    call getNumber                               ; FIXED -  call getNumber to get the unsigned number
    mov [SUM], AL                                ; FIXED -  Save number to global variable SUM

part2:
    call normalize
    call quarterprecisionform
    mov BL, AL
    mov SI, Message2
    call printStr
    call print

    HLT                                          ; Quit



.END main                                        ; Entry point of program is main()
