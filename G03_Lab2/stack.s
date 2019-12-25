.text
.global _start


_start:		LDR R4, =COUNTER		//place R4 as a pointer to the counter position
			LDR R5, [R4]			//R5 hold the number of the entire list
			ADD R6,	R4, #4 			//place R6 as the pointer to the first number to the list

PUSH_LOOP:	SUBS R5, R5, #1  		//decrement on the number of the rest of the element
			BLT POP_LOOP	        // if all the elements in the list are pushed, jump to pop loop
			LDR R0, [R6] 	        // place one of the element in the list into the stack buffer R0
			ADD R6, R6, #4	        // move R6 to the next number in the list
			SUBS SP, SP, #4			// the stack grow in descensing direction by one word
			STR R0, [SP]			//push element in the stack buffer
			B PUSH_LOOP         	// in the loop

POP_LOOP:	LDR R1, [SP]			//pop the top of stack into R1
   			ADD SP, SP, #4			// move the stack pointer down pointing the new TOS
 			LDR R2, [SP]		    // pop TOS
			ADD SP, SP, #4		    // point to new TOS
			LDR R3, [SP]		
			ADD SP, SP, #4		

END:		B END 				    // loop infinite

COUNTER:	.word	3               // number of element in the list
NUMBERS:	.word	2, 3, 4         // list
