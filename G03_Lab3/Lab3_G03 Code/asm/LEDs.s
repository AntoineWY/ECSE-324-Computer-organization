.text
		.equ L_BASE, 0xFF200000
		.global read_LEDs_ASM
		.global write_LEDs_ASM

read_LEDs_ASM:
		LDR R1, =L_BASE
		LDR R0, [R1]        // load bit corresponding to the status of the LED
		BX LR               //  and pass back in R0

write_LEDs_ASM:
		LDR R1, =L_BASE
		STR R0, [R1]        //  tell LED to be on by storing new bit patterns
		BX LR
		.end