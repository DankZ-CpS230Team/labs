// CpS 230 Lab 7: Ryan Longacre (rlong315)
//				  Zac Hayes (zhaye769)
//---------------------------------------------------
// Helper functions for uprintf.  Logic to print
// various kinds of output using nothing from the
// standard library except `putchar()`.
//---------------------------------------------------

// All we will use from this is `putchar()`
#include <stdio.h>

// Print all the characters from the string pointed to by <string>
void uprintf_puts(const char *string) {
    while (*string != '\0') {
        putchar(*string++);
    }
}

// Print <number> as 8 hexadecimal digits
// E.g., uprintf_putx(42) --> 0000002a
void uprintf_putx(unsigned int number) {
    const char hex_digits[16] = "0123456789abcdef";     // Hint: this array might help
	for (int i = 7; i >= 0; --i) {
		putchar(hex_digits[(number >> (4 * i)) & 0xf]);
	}
}

// Prints <number> in decimal (assuming unsigned semantics)
// E.g., uprintf_putu(42) --> 42
void uprintf_putu(unsigned int number) {
	int nums[11] = { 0 };
	int next = 0;
	while (number > 0) {
		nums[next++] = number % 10;
		number /= 10;
	}
	if (next == 0) { ++next; }
	while (--next >= 0) {
		putchar(nums[next] + '0');
	}
}

// Print <number> in decimal (assuming signed semantics)
// E.g., uprintf_putd(-42) --> -42
void uprintf_putd(int number) {
	if (number < 0) {
		putchar('-');
		number = -number;
	}
	uprintf_putu(number);
}

// Print <number> as 32 binary digits ('0' or '1')
// E.g., uprintf_putb(42) --> 00000000000000000000000000101010
void uprintf_putb(unsigned int number) {
	for (int i = 31; i >= 0; --i)
		(number & (1 << i)) ? putchar('1') : putchar('0');
}
