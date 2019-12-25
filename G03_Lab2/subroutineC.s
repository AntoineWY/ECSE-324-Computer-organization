.text
.global MIN_2

MIN_2: 
	CMP R0, R1  // compare
	BXLE LR     // If less than, return to the caller since this number should not be minimum
	MOV r0, R1  // if R0 larger than r1, move current min r1 into r0
	BX LR		// return
	.end
