; CpS 230 Lab 5: Zachary Hayes (zhaye769)
;				 Ryan Longacre (rlong315)

bits 32

extern _printf
extern _scanf
;extern rand_s

section .text

global _main

_main:
	; Boilerplate "function prologue"
	push	ebp
	mov		ebp, esp
	
	; initialize magic_number
	mov		eax, 64d ; put immediate (const) value in eax
	mov		[int_magic_number], eax ; put eax in magic_number location
	
while_start:
	; prompt, call printf
	push	str_intro
	call	_printf
	add		esp, 4
	; get input, call scanf
	push	int_guess
	push	str_scanfmt
	call	_scanf
	add		esp, 8
	
	; for testing, echo input
	; TODO remove this part AND the fmt string var
	push	dword [int_guess]
	push	str_printfmt
	call	_printf
	add		esp, 8
	
	; compare guess and magic number
	mov		ebx, [int_guess]
	cmp		ebx, [int_magic_number]
	je		exit_loop
	jmp		while_start
exit_loop:
	
	; return 0
	mov		eax, 0
	
	; Boilerplate "function epilogue"/return
	pop		ebp
	ret

section .data

str_intro	db	"I'm thinking of a number between 1 and 100; what is it? ", 0
str_correct	db	"You guessed it! Thanks for playing...", 10, 0
str_toolow	db	"Too low!", 10, 0
str_toohigh	db	"Too high!", 10, 0
str_scanfmt	db	"%d", 0
str_printfmt	db	"Input: %d", 10, 0

int_magic_number	dd	0
int_guess	dd	0
