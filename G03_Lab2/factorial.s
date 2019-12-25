.text
.global _start


_start:		LDR R0, PARAM		// load the parameter of the fatorial
			BL FACTORIAL        // branch to factorial subroutine
			B END

FACTORIAL:  PUSH {R1, R2, LR}   // push R1, R2 and link register onto stack
			CMP R0, #1			// Check if n is equal or less than one 
			BLE ZERO_ONE		// if true, jump to ZERO_ONE block directly
			MOV R1, R0			// move param for calculation in R1
			SUB R0, R0, #1      // DECREMENT R0
			BL FACTORIAL		// N! = N * (N-1)!
			MUL R2,R1,R0
			MOV R0, R2			// move intermediate answer to R0
			POP {R1, R2, LR}	// restore R1, r2 lr, pushed from last layer
			BX LR				// back to last layer

ZERO_ONE: 
			MOV R0, #1   		// 1!=0!=1. place answer 1 into R0
			POP {R1,R2,LR}      // restore R1, R2 and link register 
			BX LR				// return to the last layer of call

END:		B END 				// loop infinite


PARAM:	.word	4





