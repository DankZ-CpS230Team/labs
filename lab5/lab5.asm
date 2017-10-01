; CpS 230 Lab 5: Zachary Hayes (zhaye769)
;				 Ryan Longacre (rlong315)

bits 32

extern _printf
extern _scanf
extern _rand_s

section .text

global _main

_main:
	; Boilerplate "function prologue"
	push	ebp
	mov		ebp, esp
	
	; generate random magic_number
	push	int_magic_number
	call	_rand_s
	add		esp, 4
	mov		ebx, 100d ; move immediate 100 into ebx for division (can't divide by immediate)
	mov		eax, [int_magic_number] ; move magic number to eax
	mov		edx, 0d ; move 0s to edx
	div		ebx
	mov		[int_magic_number], edx ; divides magic number by 100 and sets it to remainder
									; (rand_s generates a random number from 0 to 2^31 - 1,
									;  which is too big)
	add		dword [int_magic_number], 1	; add 1 to make it in range 1-100
	
while_start:
	; prompt, call printf
	push	str_intro
	call	_printf
	add		esp, 4
	; get input, call scanf, increment guess count
	push	int_guess
	push	str_scanfmt
	call	_scanf
	inc		dword [int_num_guesses]
	add		esp, 8
	
	; compare guess and magic number
	mov		ebx, [int_magic_number]
	cmp		ebx, [int_guess]
	je		exit_loop
	jl		less_than
	jmp		greater_than
	
less_than:
	; print less-than message, then jump to loop begin
	push	str_toohigh
	call	_printf
	add		esp, 4
	jmp		while_start

greater_than:
	; print greater-than message, then jump to loop begin
	push	str_toolow
	call	_printf
	add		esp, 4
	jmp		while_start

exit_loop:
	
	; print win message and number of guesses
	push	str_correct
	call	_printf
	add		esp, 4
	push	dword [int_num_guesses]
	push	str_guessnum
	call	_printf
	add		esp, 8
	
	; return 0
	mov		eax, 0
	
	; Boilerplate "function epilogue"/return
	pop		ebp
	ret

section .data

str_intro	db	"I'm thinking of a number between 1 and 100; what is it? ", 0
str_correct	db	"You guessed it! Thanks for playing...", 10, 0
str_guessnum	db	"It took you %d guesses.", 10, 0
str_toolow	db	"Too low!", 10, 0
str_toohigh	db	"Too high!", 10, 0
str_scanfmt	db	"%d", 0

int_magic_number	dd	0
int_guess	dd	0
int_num_guesses		dd	0
