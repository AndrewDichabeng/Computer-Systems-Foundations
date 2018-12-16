DisplayPort .EQU 04E9h

.ORG 0010h             ; .ORG 0000h

HayStack:

.DB 8
.DB 2
.DB 4
.DB 9

Sentinal: .DB 'a'
Needle: .DB 9

.ORG 0100h

FoundItMsg:  .DB 'Found the needle at index $'

notfoundmsg: .DB 'The Needle was not found! $'

.ORG 0200h
Main:
    mov DX, DisplayPort
    mov AL, [Needle]   ; Load the needle into AL for comparisons
    mov SI,HayStack    ; Create a pointer into the haystack

Comparison:
    mov AL, [SI]
    cmp SI, Sentinal   ; Compare the pointer to the sentinel value
    jz notfound        ; If the difference resulted in a zero and the zero flag was placed, jump to 'notfound'
    cmp AL,[Needle]    ; Compare the AL register that has a value the pointer pointing at, to the needle.
    jz foundIt         ; If the difference resulted in a zero and the zero flag was placed, jump to 'foundIt'
    inc SI
    jmp Comparison     ; Loop back.

notfound:              ; if the needle wasn't found.
    mov BX,notfoundmsg ; Copy message into BX.

printSadMsg:
    mov AL, [BX]       ; This works because we're moving a single character at a time.
    cmp AL, '$'
    je quit
    out DX,AL
    inc BX
    jmp printSadMsg

foundIt:               ; We get here if we found the needle
    mov BX,FoundItMsg

printHappyMsg:
    mov AL, [BX]
    cmp AL, '$'
    je Index
    out DX,AL
    inc BX
    jmp printHappyMsg

Index:
    sub SI, HayStack
    mov AX, SI
    add AL,30h
    out DX,AL
    jmp quit

quit:                  ; Program done
    HLT
    
.END Main
