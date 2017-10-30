; CpS 230 Lab 7: Ryan Longacre (rlong315)
;				 Zac Hayes (zhaye769)
;---------------------------------------------------
; micro-printf ("uprintf") function implementation.
;---------------------------------------------------
bits 32

; This is the only libc function we use
extern _putchar

; Our helpers are written in C (also using only _putchar)
extern _uprintf_puts
extern _uprintf_putx
extern _uprintf_putu
extern _uprintf_putd
extern _uprintf_putb

section .text

global _uprintf
; void uprintf(const char *fmt, ...)
; Supported format specifiers:
;	%s := 32-bit pointer to NUL-terminated ASCII string to print
;	%c := 32-bit DWORD containing ASCII char code to print [can just use _putchar!]
;	%x := 32-bit DWORD to print in [unsigned] hexadecimal]
;	%u := 32-bit DWORD to print in [unsigned] decimal
;	%d := 32-bit DWORD to print in [signed] decimal
;	%b := 32-bit DWORD to print in [unsigned] binary
_uprintf:
	push	ebp			;#1 Standard prologue
	mov		ebp, esp
	push	esi			;#1 No locals needed, but we need to save ESI
	
	mov		esi, [ebp + 8]		;#3 %esi = fmt
	mov		ebx, 3 ;#5 ebx holds index of next argument
	
	; For each char in <fmt>
.fmtLoop:
	movzx	eax, byte [esi]		;#3 eax = fmt[esi]
	inc		esi			;#1 ++esi
	
	cmp		eax, 0			;#3 if char was not NUL...
	jne		.keepGoing		;#2 ...print
	jmp		.breakOut		;#2 ...else break out of the loop
.keepGoing:
	cmp		eax, '%'
	je		.format
	jmp		.print

.format:
	; get format char
	movzx	eax, byte [esi]		;#3 eax = fmt[esi]
	inc		esi			;#1 ++esi
	cmp		eax, '%'
	je		.print
	push	dword [ebp + ebx*4] ;#4 push next argument to print
	inc		ebx
	cmp		eax, 's'
	je		.s
	jmp		.not_s

.s:
	call	_uprintf_puts
	add		esp, 4
	jmp		.fmtLoop

.not_s:
	cmp		eax, 'c'
	je		.c
	jmp		.not_c

.c:
	call	_putchar
	add		esp, 4
	jmp		.fmtLoop

.not_c:
	cmp		eax, 'd'
	je		.d
	jmp		.not_d

.d:
	call	_uprintf_putd
	add		esp, 4
	jmp		.fmtLoop

.not_d:
	cmp		eax, 'u'
	je		.u
	jmp		.not_u

.u:
	call	_uprintf_putu
	add		esp, 4
	jmp		.fmtLoop

.not_u:
	cmp		eax, 'x'
	je		.x
	jmp		.not_x

.x:
	call	_uprintf_putx
	add		esp, 4
	jmp		.fmtLoop

.not_x:
	cmp		eax, 'b'
	je		.b

.b:
	call	_uprintf_putb
	add		esp, 4
	jmp		.fmtLoop
	
.print:
	push	eax
	call	_putchar
	add		esp, 4
	
	jmp		.fmtLoop		;#2 back to top of loop

.breakOut:
	pop		esi			;#1 restore original ESI value
	pop		ebp			;#1 standard epilogue
	ret
