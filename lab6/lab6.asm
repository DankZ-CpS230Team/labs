; CpS 230 Lab 6: Zachary Hayes (zhaye769)
;				 Ryan Longacre (rlong315)

bits 32

extern _printf
extern _scanf

section .text

global _hanoi
_hanoi:
	; recursive function for solving Tower of Hanoi
	; hanoi(int disk, int src, int dst, int tmp)
	; parameters:
	;	disk: [ebp + 8]
	;	src: [ebp + 12]
	;	dst: [ebp + 16]
	;	tmp: [ebp + 20]

	push	ebp
	mov		ebp, esp
	
	; check if we should break or recurse
	cmp		dword [ebp + 8], 1
	je		_true
	jmp		_false
		
_true:
	; printf("Move disk 1 from %d to %d\n", src, dst);
	push	dword [ebp + 16]
	push	dword [ebp + 12]
	push	1d
	push	str_move
	call	_printf
	add		esp, 16

	mov		esp, ebp
	pop		ebp
	ret

_false:
	; move num_disks to ecx and decrement by 1
	mov		ecx, dword [ebp + 8]
	dec		ecx
	push	ecx
	
	; hanoi(disk - 1, src, tmp, dst);
	push 	dword [ebp + 16]
	push	dword [ebp + 20]
	push	dword [ebp + 12]
	push	dword [ebp - 4]
	call	_hanoi
	add		esp, 16

	; printf("Move disk %d from %d to %d\n", disk, src, dst);
	push 	dword [ebp + 16]
	push	dword [ebp + 12]
	push	dword [ebp + 8]
	push	str_move
	call	_printf
	add		esp, 16

    ; hanoi(disk - 1, tmp, dst, src);
	push 	dword [ebp + 12]
	push	dword [ebp + 16]
	push	dword [ebp + 20]
	push	dword [ebp - 4]
	call	_hanoi
	add		esp, 16

	mov		esp, ebp
	pop		ebp
	ret

global _main
_main:
	; Boilerplate "function prologue"
	push	ebp
	mov		ebp, esp
	
	; prompt, call printf
	push	str_prompt
	call	_printf
	; don't clean off the stack because we are reserving space for num_disks (at [ebp - 4])
	lea		ecx, [ebp - 4]
	push 	ecx
	push 	str_scanfmt
	call 	_scanf
	add 	esp, 8
	
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
	; call _hanoi(num_disks, 1, 2, 3)
	push	3d
	push	2d
	push	1d
	push	dword [ebp - 4]
	call	_hanoi
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