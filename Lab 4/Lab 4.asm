DisplayPort .EQU 04E9h
;.ORG 0000h

.ORG 0010h

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
MOV DX, DisplayPort

MOV AL, [Needle]  ; Load the needle into AL for comparisons

MOV SI,HayStack   ; Create a pointer into the haystack

Comparison:
mov AL, [SI]
cmp SI, Sentinal  ;Compare the pointer to the sentinel value
JZ notfound       ;If the difference resulted in a zero and the zero flag was placed, jump to 'notfound'

cmp AL,[Needle]   ;Compare the AL register that has a value the pointer pointing at, to the needle.
JZ foundIt        ;If the difference resulted in a zero and the zero flag was placed, jump to 'foundIt'
inc SI
Jmp Comparison    ;Loop back.

notfound:         ;if the needle wasn't found.
MOV BX,notfoundmsg ;Copy message into BX.


printSadMsg:
mov AL, [BX]      ;This works because we're moving a single character at a time.
cmp AL, '$'
JE quit
out DX,AL
inc BX
jmp printSadMsg


foundIt:          ; We get here if we found the needle
MOV BX,FoundItMsg


printHappyMsg:
mov AL, [BX]
cmp AL, '$'
JE Index
out DX,AL
inc BX
jmp printHappyMsg

Index:
	SUB SI, HayStack
	mov AX, SI
	ADD AL,30h
	OUT DX,AL
	JMP quit


quit:           ; Program done
HLT
.END Main
