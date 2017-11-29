; CpS 230 Lab 10: Zachary Hayes (zhaye769)
;				  Ryan Longacre (rlong315)
;---------------------------------------------------
; Timer-interrupt-hook demo.  Updates a 16-bit count
; 18.2 times per second (thanks to the INT 8 timer
; interrupt); displays the current count in the
; upper-left corner of the text-mode screen while
; the "main" program waits for user input...
;---------------------------------------------------
bits 16

; COM program (CS = DS = SS), so we need an ORG 0x100
org	0x100

; Where to find the INT 8 handler vector within the IVT [interrupt vector table]
IVT8_OFFSET_SLOT	equ	4 * 8			; Each IVT entry is 4 bytes; this is the 8th
IVT8_SEGMENT_SLOT	equ	IVT8_OFFSET_SLOT + 2	; Segment after Offset

section	.text
start:
	; Set ES=0x0000 (segment of IVT)
	mov	ax, 0x0000
	mov	es, ax
	
	; Install interrupt hook
	; disable interrupts (so we can't be...INTERRUPTED...)
	cli
	; save current INT 8 handler address (segment:offset) into ivt8_offset and ivt8_segment
	mov		ax, 0
	mov		es, ax
	mov		dx, [es:IVT8_OFFSET_SLOT]
	mov		[ivt8_offset], dx
	mov		ax, [es:IVT8_SEGMENT_SLOT]
	mov		[ivt8_segment], ax
	; set new INT 8 handler address (OUR code's segment:offset)
	mov		dx, timer_isr
	mov		word [es:IVT8_OFFSET_SLOT], timer_isr
	mov		ax, cs
	mov		[es:IVT8_SEGMENT_SLOT], ax
	; reenable interrupts (GO!)
	sti
	
	; Start the "main" program that prompts for user input until an empty line is entered
	mov	dx, msg_finish
	call	puts
.loopy:
	; Prompt for a string
	mov	dx, msg_prompt
	call	puts
	
	; Read a line (this will BLOCK/HANG until we get data back...)
	mov	dx, input_buff
	mov	cx, 32
	call	gets
	
	; Break out if nothing entered
	test	ax, ax
	jz	.breakout
	
	; Print out a reply
	mov	dx, msg_hello
	call	puts
	mov	dx, input_buff
	call	puts
	mov	dx, msg_bangbang
	call	puts
	
	; Repeat!
	jmp	.loopy
.breakout:

	; Uninstall interrupt handler (disable interrupts, restore the old INT 8 vector, reenable interrupts)
	mov		ax, 0
	mov		es, ax
	mov		dx, [ivt8_offset]
	mov		[es:IVT8_OFFSET_SLOT], dx
	mov		ax, [ivt8_segment]
	mov		[es:IVT8_SEGMENT_SLOT], ax
	
	; Quit to DOS, cleanly
	mov	ah, 0x4c
	mov	al, 0
	int	0x21

; INT 8 Timer ISR (interrupt service routine)
; cannot clobber anything; must CHAIN to original caller (for interrupt acknowledgment)
; DS/ES == ???? (at entry, and must retain their original values at exit)
timer_isr:
	; save any registers we clobber to the stack
	push	ax
	push	bx
	push	cx
	push	dx
	; print current counter value in upper-left corner of the screen
	; save old cursor position
	mov		ah, 0x03
	int		0x10
	push	dx
	; set cursor position to 74,0
	mov		ah, 0x02
	mov		dx, 74
	int		0x10
	; print "0x"
	mov		ah, 0x0A
	mov		al, '0'
	mov		cx, 1
	int		0x10
	inc		dl
	mov		ah, 0x02
	int		0x10
	mov		ah, 0x0A
	mov		al, 'x'
	int		0x10
	inc		dl
	mov		ah, 0x02
	int		0x10
	; print counter value
	mov		ah, 0x0A
	mov		bx, [counter]
	shr		bx, 12
	and		bx, 0x000F
	mov		al, [digits + bx]
	int		0x10
	inc		dl
	mov		ah, 0x02
	int		0x10
	mov		ah, 0x0A
	mov		bx, [counter]
	shr		bx, 8
	and		bx, 0x000F
	mov		al, [digits + bx]
	int		0x10
	inc		dl
	mov		ah, 0x02
	int		0x10
	mov		ah, 0x0A
	mov		bx, [counter]
	shr		bx, 4
	and		bx, 0x000F
	mov		al, [digits + bx]
	int		0x10
	inc		dl
	mov		ah, 0x02
	int		0x10
	mov		ah, 0x0A
	mov		bx, [counter]
	and		bx, 0x000F
	mov		al, [digits + bx]
	int		0x10
	; reset cursor position
	pop		dx
	mov		ah, 0x02
	int		0x10
	
	; increment current counter value
	inc		word [counter]
	
	; restore any registers we clobbered from the stack
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	
	; Chain (i.e., jump) to the original INT 8 handler 
	jmp	far [cs:ivt8_offset]	; Use CS as the segment here, since who knows what DS is now


; print NUL-terminated string from DS:DX to the screen (at the current "cursor" location) using BIOS INT 0x10
; takes NUL-terminated string pointed to by DS:DX
; clobbers nothing
; returns nothing
puts:
	push	ax
	push	cx
	push	si
	
	mov	ah, 0x0e
	mov	cx, 1		; no repetition of chars
	
	mov	si, dx
.loop:	mov	al, [si]
	inc	si
	cmp	al, 0
	jz	.end
	int	0x10
	jmp	.loop
.end:
	pop	si
	pop	cx
	pop	ax
	ret

; read NUL-terminated string from keyboard into CX-sized buffer at DS:DX using BIOS INT 0x16
; takes pointer to buffer in DS:DX, takes size of buffer in CX-sized
; clobbers nothing (but ax, the return value)
; returns number of characters read/stored (not counting NUL) in ax
gets:
	cmp	cx, 1
	ja	.ok
	xor	ax, ax
	ret
.ok:
	push	di
	push	cx
	
	mov	di, dx
	dec	cx		; Reserve space for NUL
.loop:
	mov	ah, 0x10
	int	0x16
	cmp	al, 13		; Stop on CR (Enter key)
	je	.gotcr
	
	push	cx		; Echo entered character
	mov	cx, 1
	mov	ah, 0x0e
	int	0x10
	pop	cx
	
	mov	[di], al	; Stash entered character
	inc	di
	loop	.loop
.flush:
	cmp	al, 13		; Read (and drop) chars until we get a CR
	je	.gotcr		; (This happens if we run out of room before CR)
	mov	ah, 0x10
	int	0x16
	
	push	cx		; Echo entered character
	mov	cx, 1
	mov	ah, 0x0e
	int	0x10
	pop	cx
	
	jmp	.flush
	
.gotcr:	mov	byte [di], 0	; Tack on the NUL
	
	mov	ax, 0x0e0a	; Always emit a CRLF pair
	mov	cx, 1
	int	0x10
	mov	al, 13
	int	0x10
	
	mov	ax, di		; Compute &end - &start - 1 (number of non-NUL chars)
	sub	ax, dx
	
	pop	cx
	pop	di
	ret

section	.data
digits		db	"0123456789abcdef"
counter		dw	0
ivt8_offset	dw	0
ivt8_segment	dw	0
msg_finish	db	"Enter an empty string to quit...", 10, 13, 10, 13, 0
msg_prompt	db	"What is your name? ", 0
msg_hello	db	"Why, hello, ", 0
msg_bangbang	db	"!!", 10, 13, 0
input_buff	times 32 db 0
