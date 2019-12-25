
.text
.global _start

_start:
		LDR R0, =MIN 		//point R0 to the address of minimum value
		PUSH {R0}				// push R0 onto the stack
		BL SUBROUTINE   // call subroutine
		POP {R0-R1}			//pop the top 2 elements in the stack
										//R0 has the minimum value, R1 has the address to store the minimum value
		STR R0,[R1]			//store the minimum value to the designated memory address

stop: B stop

SUBROUTINE:
			LDR R1, =NUMBERS   // load the address of the first number to R1
			LDR R0, NUMBERS		// load the first number to R1 (contain the minimum value in the subroutine)
			LDR R3, COUNTER		// load the counter to R3

MIN_LOOP:
		 SUBS R3, R3, #1 		// decrement counter
	 	 BEQ DONE				// finished comparing, jump to done
	 	 LDR R2, [R1, #4]!      // Load the next number to R2, update R1 to the address of next number
	   CMP R0, R2 			// Compare R0, R2
	   BLE MIN_LOOP			// if smaller or equal, not minimum, jump back to MIN_LOOP
	 	 MOV R0, R2				// if larger, copy the smaller number to R0
	 	 B MIN_LOOP

DONE:
	  PUSH R0 		// push the smallest number to the stack
	  BX LR				// branch back

NUMBERS: .word 32,200,3,400,1,6
COUNTER: .word 6
MIN: .word 0
.end
