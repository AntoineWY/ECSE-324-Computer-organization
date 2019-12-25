.text



	.global read_PS2_data_ASM

	.equ PS2_Data, 0xFF200100						//keyboard data address

	.equ PS2_Control, 0xFF200104				//control address



//checks rvalid
//if valid, load data to correct pointer and return 1
//if not valid, return 0 immediately

read_PS2_data_ASM:

	//r0 is character pointer that the keyboard data will be stored at

	LDR R3, =PS2_Data		//R3 holds the address of keyboard data

	LDR R4, [R3]				//R4 holds the keyboard data

	MOV R1, #0x8000			//R1 holds a value that only the 16th bit is 1

	MOV R5, #0xFF				//lowest 8 bits are 1

	AND R2, R4, R1 			//R2 will be 1 if rvalid is set to 1

	CMP R2, #0					//to see if rvalid is 1 or not

	BEQ INVALID					//if not 1, jump to invalid (end)

	//if rvalid is 1, read keyboard data

	AND R6, R4, R5			//get the lowest 8 bits from the keyboard data

	STRB R6, [R0]				//store data to the desired location



	MOV R0, #1					//return 1 if successfully get the data

	BX LR								//exit subroutine

INVALID:

	MOV R0, #0					//return 0 if no data received

	BX LR								//exit subroutine



	.end
