			.text
			.global _start

_start:
			LDR R4, =RESULT    //r4 points to the result location
			LDR R2, [R4,#4]    //R2 holds the number of elements in the list
			ADD R3, R4, #8     //R3 POINTS TO THE FIRST NUMBER
            LDR R0, [R3]       //R0 HOLDS THE FIRST NUMBER IN THE LIST



MAX:        SUBS R2, R2, #1    // DECREMENT THE LOOP COUNTER
       		BEQ DONE_MAX	// END LOOP IF COUNTER HAS REACHED 0
			ADD R3, R3, #4     //R3 POINTS TO THE NEXT NUMBER IN THE LIST
			LDR R1, [R3]       // R1 HOLDS THE NEXT NUMBER IN THE LIST
            CMP R0, R1         // CHECK IF IT IS GREATER THAN THE MAXIMUM
			BGE MAX           // IF NO, BRANCH BACK TO THE LOOP
            MOV R0, R1         // IF YES, UPDATE THE CURRENT MAX
			B MAX             // BRANCH BACK TO THE LOOP

DONE_MAX: 		STR R0, [R4]

RESET:		MOV R2, #5         // SET BACK THE COUNTER
			LDR R4, =RESULT    // SET R4 POINT BACK TO RESULT LOCATION
            ADD R3, R4, #8     // R3: FIRST NUMBER IN MIN LOOP
			LDR R5, [R3]       //R5: VALUE OF R3 IN MIN LOOP

MIN:        SUBS R2, R2, #1    // DECREMENT THE LOOP COUNTER
			BEQ DONE_MIN		   // END LOOP IF COUNTER HAS REACHED 0
			ADD R3, R3, #4     //R3 POINTS TO THE NEXT NUMBER IN THE LIST
            LDR R1, [R3]       // R1 NOW HOLDS WHAT R3 POINTS
			CMP R1, R5         // CHECK IF THE MEXT NUMBER IS LARGER THAN CURRENT MIN
			BGE MIN             // IF NEXT NUMBER IS LARGER (NOT MIN), BACK TO LOOP
			MOV R5, R1          // R5 HOLES WHAT R1 FINDS
			B MIN


DONE_MIN: 		STR R5, [R4]

FIND_RANGE:		SUBS R1, R0, R5
				STR  R1, [R4]

END:        B END              // INFINITE LOOP!

RESULT:		.word	0          // memory assigned for result location
N:			.word	6          // number of entries in the list
NUMBERS:    .word	512, 273, 284, 288 // the list data
			.word	256, 300
