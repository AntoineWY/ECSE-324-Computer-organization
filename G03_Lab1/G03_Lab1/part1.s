			.text
			.global _start

_start:
			LDR R4, =RESULT    //r4 points to the result location
			LDR R2, [R4,#4]    //R2 holds the number of elements in the list
			ADD R3, R4, #8     //R3 POINTS TO THE FIRST NUMBER
            LDR R0, [R3]       //R0 HOLDS THE FIRST NUMBER IN THE LIST



LOOP:       SUBS R2, R2, #1    // DECREMENT THE LOOP COUNTER
       		BEQ DONE	   // END LOOP IF COUNTER HAS REACHED 0
			ADD R3, R3, #4     //R3 POINTS TO THE NEXT NUMBER IN THE LIST
			LDR R1, [R3]       // R1 HOLDS THE NEXT NUMBER IN THE LIST
            CMP R0, R1         // CHECK IF IT IS GREATER THAN THE MAXIMUM
			BGE LOOP           // IF NO, BRANCH BACK TO THE LOOP
            MOV R0, R1         // IF YES, UPDATE THE CURRENT MAX
			B LOOP             // BRANCH BACK TO THE LOOP

DONE: 		STR R0, [R4]

        
END:        B END              // INFINITE LOOP!

RESULT:		.word	0          // memory assigned for result location
N:			.word	7          // number of entries in the list
NUMBERS:    .word	512, 73, 84, 88 // the list data
			.word	16, 12, 143
