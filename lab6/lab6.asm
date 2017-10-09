; CpS 230 Lab 6: Zachary Hayes (zhaye769)
;				 Ryan Longacre (rlong315)

bits 32

extern _printf
extern _scanf

section .text

global _main

_hanoi:
	; recursive function for solving Tower of Hanoi
	; TODO implement recursion
	push	ebp
	mov		ebp, esp
	
	; PoC - print first three params
	push 	dword [ebp + 16]
	push	dword [ebp + 12]
	push	dword [ebp + 8]
	push	str_move
	call	_printf
	add		esp, 16
	
	; PoC - return fourth to print
	mov		eax, [ebp + 20]
	
	mov		esp, ebp
	pop		ebp
	ret

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
	; TODO remove PoC stuff
	; TODO call _hanoi(num_disks, 1, 2, 3) once recursive _hanoi works
	; PoC - call _hanoi(num_disks, 64, 128, 42)
	; in _hanoi, print first 3 params
	; return fourth
	push	42d
	push	128d
	push	64d
	push	dword [ebp - 4]
	call	_hanoi
	add		esp, 16
	
	; PoC - print return value of hanoi (though hanoi won't return anything in final ver.)
	push 	0d
	push	0d
	push	eax
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
