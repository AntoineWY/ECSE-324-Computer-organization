			.text
			.global _start

			//Trial: github see if changes in the comment gonna be committed

_start:
			LDR R4, =RESULT_MAX     //r4 points to the result max location
			LDR R2, [R4,#8]    		//R2 holds the number of elements in the list
			ADD R3, R4, #28     	//R3 points to the first product 
            								
									//we have four numbers, x1, x2, x3, x4

MULTIPLY: 	LDR R8, [R4,#12]		//R8 holds the input x1
            LDR R9, [R4,#16] 		//R9 holds the input x2
			ADD R6, R8, R9    		//R6 holds the sum of x1 and x2
			LDR R8, [R4,#20]		//R8 holds the input x3
            LDR R9, [R4,#24] 		//R9 holds the input x4
			ADD R7, R8, R9 			//R7 holds the sume of x3 and x4
			MUL R6, R6, R7			//R6 holds the multiplication of the two sums
			STR R6, [R4, #28] 		//Store first product in memory			

            LDR R8, [R4,#12]		//R8 holds the input x1
            LDR R9, [R4,#20] 		//R9 holds the input x3
			ADD R6, R8, R9    		//R6 holds the sum of x1 and x3
  			LDR R8, [R4,#16]		//R8 holds the input x2
            LDR R9, [R4,#24] 		//R9 holds the input x4
			ADD R7, R8, R9  		//R7 holds the sume of x2 and x4
			MUL R6, R6, R7			//R6 holds the multiplication of the two sums
			STR R6, [R4, #32] 		// Store second product in memory

			LDR R8, [R4,#12]		//R8 holds the input x1
            LDR R9, [R4,#24] 		//R9 holds the input x4
			ADD R6, R8, R9    		// R6 holds the sum of x1 and x4
			LDR R8, [R4,#16]		//R8 holds the input x2
            LDR R9, [R4,#20]		//R9 holds the input x3
			ADD R7, R8, R9 			//R7 holds the sume of x2 and x3
			MUL R6, R6, R7			//R6 holds the multiplication of the two sums
			STR R6, [R4, #36] 		// Store third product in memory

			LDR R0, [R3]       		//R0 holds the value of the first product

MAX:       	SUBS R2, R2, #1    		// DECREMENT THE LOOP COUNTER
       		BEQ DONE_MAX		    // END LOOP IF COUNTER HAS REACHED 0
			ADD R3, R3, #4     		// R3 POINTS TO THE NEXT product IN THE LIST
			LDR R1, [R3]       		// R1 HOLDS THE NEXT value of product IN THE LIST
            CMP R0, R1         		// CHECK IF IT IS GREATER THAN THE MAXIMUM
			BGE MAX           		// IF NO, BRANCH BACK TO THE LOOP
            MOV R0, R1         		// IF YES, UPDATE THE CURRENT MAX
			B MAX             		// BRANCH BACK TO THE LOOP

DONE_MAX: 	STR R0, [R4]			//store the value of R0 into the memory address stored in R4

RESET:		MOV R2, #3         		// SET BACK COUNTER
			LDR R4, =RESULT_MAX		// SET R4 back to RESULT_MAX
            ADD R3, R4, #28     	// R3: FIRST NUMBER IN MIN LOOP
			LDR R5, [R3]       		// R5: VALUE OF R3 IN MIN LOOP

MIN:        SUBS R2, R2, #1    		// DECREMENT THE LOOP COUNTER
			BEQ DONE_MIN		    // END LOOP IF COUNTER HAS REACHED 0
			ADD R3, R3, #4     		//R3 POINTS TO THE NEXT product IN THE LIST
            LDR R1, [R3]       		// R1 NOW HOLDS WHAT R3 POINTS
			CMP R1, R5         		// CHECK IF THE MEXT NUMBER IS LARGER THAN CURRENT MIN
			BGE MIN             	// IF NEXT NUMBER IS LARGER (NOT MIN), BACK TO LOOP
			MOV R5, R1         		// R5 HOLDS WHAT R1 FINDS
			B MIN


DONE_MIN: 	STR R5, [R4, #4]		//store the value of R5 into the memory address RESULT_MIN

END:        B END              // INFINITE LOOP!

RESULT_MAX:	.word	0          // memory assigned for max result location
RESULT_MIN:	.word	0          // memory assigned for min result location
N:			.word	3          // number of entries in the list
NUMBERS:    .word	1, 3, 1, 3 // the list data
PRODUCT:    .word   0, 0, 0    // Allocate 3 word in the memory for 3 products		
