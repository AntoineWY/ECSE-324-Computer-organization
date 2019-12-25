.text
		.equ PUSH_BUTTON_DATA, 0xFF200050
		.equ PUSH_BUTTON_MASK, 0xFF200058
		.equ PUSH_BUTTON_EDGE, 0xFF20005C
		.global read_PB_data_ASM
		.global PB_data_is_pressed_ASM

		.global read_PB_edgecap_ASM
		.global PB_edgecap_is_pressed_ASM
		.global PB_clear_edgecap_ASM
		.global enable_PB_INT_ASM
		.global disable_PB_INT_ASM

// R0 is used to pass which button is presses for all subroutines below

read_PB_data_ASM:
		LDR R1, =PUSH_BUTTON_DATA //Load the address of "PUSH_BUTTON_DATA" to R1
		LDR R0, [R1]				//load the contents of the pushbutton into R1
		AND R0, R0, #0xF		//Except the first four one-hot bits, clear other bits
		BX LR								//exit subroutine

PB_data_is_pressed_ASM:
		LDR R1, =PUSH_BUTTON_DATA	//Load the address of "PUSH_BUTTON_DATA" to R1
		LDR R2, [R1]							//load the contents of the pushbutton into R1
		AND R2, R2, R0						//check if the designated button is pressed
		CMP R2, R0
		MOVEQ R0, #1				//if pressed, R0 has value 1
		MOVNE R0, #0				//if not pressed, R0 has value 0
		BX LR								//exit subroutine
												//R0 is used to return value
//---------------------------------------------------------------
read_PB_edgecap_ASM:
		LDR R1, =PUSH_BUTTON_EDGE		//Load the address of "PUSH_BUTTON_EDGE" to R1
		LDR R0, [R1]								//load the contents into R1
		AND R0, R0, #0xF						//Except the first four one-hot bits, clear other bits
																//only get the edge bits
		BX LR												//exit subroutine
																//R0 is used to return value
PB_edgecap_is_pressed_ASM:
		LDR R1, =PUSH_BUTTON_EDGE   //Load the address of "PUSH_BUTTON_EDGE" to R1
		LDR R2, [R1]								//load contents of into R2
		AND R2, R2, R0							//check if the designated button is pressed
		CMP R2, R0
		MOVEQ R0, #1							//if pressed, R0 has value 1
		MOVNE R0, #0							//if not pressed, R0 has value 0
		BX LR											//exit subroutine
															//R0 is used to return value

PB_clear_edgecap_ASM:
		LDR R1, =PUSH_BUTTON_EDGE	   //Load the address of "PUSH_BUTTON_EDGE" to R1
		MOV R2, R0									// Give R2 a value other than 0 if want to clear (if a button is pushed to be clear, R0 can never be 0)
		STR R2, [R1]								//store any value except 0 will reset
		BX LR												//exit subroutine
//----------------------------------------------------------------
enable_PB_INT_ASM:
		LDR R1, =PUSH_BUTTON_MASK		//Load the address of "PUSH_BUTTON_MASK" to R1
		AND R2, R0, #0xF						//Except the first four one-hot bits, clear other bits
		STR R2, [R1]								//store it back into "PUSH_BUTTON_MASK"
		BX LR												//exit subroutine

disable_PB_INT_ASM:
		LDR R1, =PUSH_BUTTON_MASK	//Load the address of "PUSH_BUTTON_MASK" to R1
		LDR R2, [R1]							//load mask bits to R2
		BIC R2, R2, R0						//AND R2 with the complement of R0 (R0 is the pushbutton input)
		STR R2, [R1]							//store R2 back to the mask bits address
		BX LR											//exit subroutine
		.end
