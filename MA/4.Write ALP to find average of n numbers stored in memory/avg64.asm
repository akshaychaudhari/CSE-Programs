; ALP for average of 64-bit numbers
;-------------------------------------------------------------------
section    .data
	nline		db	10,10
	nline_len:	equ	$-nline
	
	arr64		dq	0000000000112233H, 00112233H, 00112233H, 00112233H, 00112233H
	n:		equ	5
	msg		db	10,10,"The average of 64-bit array elements is :	"
	msg_len:	equ	$-msg

;---------------------------------------------------------------------
Section   .bss
	avg		resq	1
	char_sum	resb	16
;---------------------------------------------------------------------
;you can change the macros as per 64-bit convensions

%macro  print   2
	mov   eax, 4
	mov   ebx, 1
	mov   ecx, %1
	mov   edx, %2
	int   80h
%endmacro

%macro	exit	0
	mov  eax, 1
	mov  ebx, 0
	int  80h
%endmacro

;---------------------------------------------------------------------
; If U ARE MODIFYING 32-BIT PROGRAM then
; Check line by line and make all 'e' as 'r' and other modifications 
; for 64-bit numbers

section    .text
	global   _start
_start:

	mov	rsi, arr64	
	mov	rdi, n
	
	xor	rax, rax    		; sum register clear the contents
	xor	rdx, rdx		; carry register clear the contents

next_num:
	add	rax,[rsi]
	jnc	skip
	inc	rdx
skip:
	add 	rsi,8			; 64 bit nos i.e. 8 bytes
	dec 	rdi
	jnz  	next_num

	mov	rbx,n			; store array size in rbx
	div	rbx			; rdx:rax / rbx
					; average is in rax, remainder is in rdx
	mov	[avg], rax		; store average
	
	print	msg, msg_len

	mov 	rax,[avg]		; load value of average in rax
	call 	disp64_proc		; display sum

	print	nline, nline_len
	exit
;--------------------------------------------------------------------	
disp64_proc:

	mov 	rsi,char_sum+15		; load last byte address of char_sum buffer in rsi
	mov 	rcx,16			; number of digits 

cnt:	mov 	rdx,0			; make rdx=0 (as in div instruction rdx:rax/rbx)
	mov 	rbx,16			; divisor=16 for hex
	div 	rbx
	cmp 	dl, 09h			; check for remainder in RDX
	jbe  	add30
	add  	dl, 07h 
add30:
	add 	dl,30h			; calculate ASCII code
	mov 	[rsi],dl		; store it in buffer
	dec 	rsi			; point to one byte back

	dec 	rcx			; decrement count
	jnz 	cnt			; if not zero repeat
	
	print char_sum,16		; display result on screen
ret
;----------------------------------------------------------------
