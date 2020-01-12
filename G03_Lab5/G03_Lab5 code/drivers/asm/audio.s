
.text
.equ Fifo_space, 0xFF203044    
.equ Left_data, 0xFF203048
.equ Right_data, 0xFF20304C

.word WSLC_pattern, 0xFF000000
.word WSRC_pattern, 0x00FF0000

.global write_in_FIFO_ASM    

write_in_FIFO_ASM:

	LDR R1, =Fifo_space      // Loading the address of FifoSpace register in R1
	LDR R2, =Left_data		 // R2 points to leftdata register
	LDR R3, =Right_data		 // R3 points to rightdata register

	MOV R5, #0xFF000000		 // R5 will be used to check if WSLC is all zero (meaning that left fifo is full)
	MOV R6, #0x00FF0000		 // R6 will be used to check if WSRC is all zero (meaning that right fifo is full)

	LDR R1, [R1]             // loading the content of the fifospace in R1

	ANDS R5, R1              // check bit 24-31, if wslc equals to zero, update flag
	BEQ FULL                 // if equals to zero, meaning left fifo full, branch to FULL
	ANDS R6, R1				 // check bit 23-16, if wsrc equals to zero, update flag
	BEQ FULL				 // if equals to zero, meaning right fifo full, branch to FULL
	
	// If both left and right has space, starting the write operation
	STR R0, [R2]             // Store R0, the input parameter into both left and right
	STR R0, [R3]
	MOV R0, #1                // return R0 with 1, indicating a successful return
	BX LR

// If either left and right is full, the writing fails.
// return a zero and end subroutine
FULL:
	MOV R0, #0               // return R0 with 0
	BX LR
