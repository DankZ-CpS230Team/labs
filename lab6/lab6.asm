; CpS 230 Lab 6: Zachary Hayes (zhaye769)
;				 Ryan Longacre (rlong315)

bits 32

extern _printf
extern _scanf

section .text

global _main

_main:
	; Boilerplate "function prologue"
	push	ebp
	mov		ebp, esp
	
	; prompt, call printf
	push	str_prompt
	call	_printf
	; don't clean off the stack because we are reserving space for num_disks
	lea		ecx, [ebp - 4]
	push 	ecx
	push 	str_scanfmt
	call 	_scanf
	add 	esp, 8
	; num_disks is at ebp - 4
	
	cmp 	dword eax, 1
	jne		invalid
	jmp 	valid
	
invalid:
	push 	str_error
	call 	_printf
	add		esp, 4
	
	; return 1
	mov		eax, 1
	mov 	esp, ebp
	pop 	ebp
	ret
	
valid:
	; DEBUG - print input as first arg in str_move
	push 	30d
	push	20d
	push	dword [ebp - 4]
	push	str_move
	call	_printf
	add		esp, 16
	
	; Boilerplate "function epilogue"/return
	; return 0
	mov		eax, 0
	mov 	esp, ebp
	pop 	ebp
	ret

section .data

str_move	db	"Move disk %d from %d to %d", 10, 0
str_prompt	db	"How many disks do you want to play with? ", 0
str_error	db	"Uh-oh, I couldn't understand that...  No towers of Hanoi for you!", 10, 0
str_scanfmt	db	"%d", 0
; TODO remove hello string
hello		db "Hello", 10, 0
