.text
			//base addresses of timers
			.equ TIME0, 0xFFC08000
			.equ TIME1, 0xFFC09000
			.equ TIME2, 0xFFD00000
			.equ TIME3, 0xFFD01000

			//subroutines can be seen by other files in the package
			.global HPS_TIM_config_ASM
			.global HPS_TIM_read_INT_ASM
			.global HPS_TIM_clear_INT_ASM
//-------------------------------------------------------
HPS_TIM_config_ASM:
			PUSH {R1-R7}
			LDR R3, [R0]				//Load HPS_TIM_config_t structual type instance to R3
			AND R3, R3, #0xF		//Except the first four one-hot bits, clear other bits
			MOV R1, #0					//Use R1 as counter, initialize it with 0

config_loop:
			CMP R1, #4					//compare counter to 4
			BGE config_end			//if greater than 4, no more timer needs to be configured, jump to end
			AND R5, R3, #1			//get status of the timer
			CMP R5, #0					//to know if the corresponding timer is used
			ASR R3, R3, #1			//Shift input by 1 bit to the right (preparation for configuring next timer)
			ADD R1, R1, #1			//update counter
			BEQ config_loop			//Branch back to config_loop if corresponding timer is not used

			//Load timer into R2
			CMP R1, #1					//first timer in use
			LDREQ R2, =TIME0
			CMP R1, #2					//second timer in use
			LDREQ R2, =TIME1
			CMP R1, #3					//third timer in use
			LDREQ R2, =TIME2
			CMP R1, #4					//fourth timer in use
			LDREQ R2, =TIME3

			//configuration section
			LDR R4, [R0, #0x8]		//Load "LD_en" from HPS_TIM_config_t instance
			AND R4, R4, #0x6			//change E bit to 0, keep others the same
			STR	R4, [R2, #0x8]		//update the control byte of the timer

			LDR R4, [R0, #0x4]		//Load timeout from HPS_TIM_config_t instance
			STR R4, [R2] 					//Config Timeout

			LDR R4, [R0, #0x8]		//Load "LD_en" from HPS_TIM_config_t instance
			LSL R4, R4, #1				//Shift left by 1 bit (M bit)

			LDR R5, [R0, #0xC]		//Load "INT_en" from HPS_TIM_config_t instance
			LSL R5, R5, #2				//Shift left by 2 bits (I bit)

			LDR R6, [R0, #0x10]		//Load "enable" from HPS_TIM_config_t instance

			ORR R7, R4, R5
			ORR R7, R7, R6				//Get the correct initialization for M, I and E bits

			STR R7, [R2, #0x8]			//update control byte of timer
			//ADD R1, R1, #1
			B config_loop

config_end:					//configuration finished
			POP {R1-R7}		//restore original data in the registers
			BX LR					//exit subroutine
//------------------------------------------------------------------------------
HPS_TIM_read_INT_ASM:
			PUSH {R1-R4}				//get ready to enter subroutine
			AND R0, R0, #0xF		//Except the first four one-hot bits, clear other bits
			MOV R1, #0					//Use R1 as counter, initialize it with 0

read_loop:
			CMP R1, #4								//compare counter to 4
			BGE read_end	//if counter is greater than 4, jump to end
			AND R4, R0, #1						//get the status of the timer
			CMP R4, #0								//to see if the corresponding timer is in use or not
			ASR R0, R0, #1						//Shift input by 1 bit to the right (preparation for check of next timer)
			ADD R1, R1, #1						//update counter
			BEQ read_loop	//Branch back to timer not in use

			//Load timer into R2
			CMP R1, #1							//first timer in use
			LDREQ R2, =TIME0
			CMP R1, #2							//second timer in use
			LDREQ R2, =TIME1
			CMP R1, #3							//third timer in use
			LDREQ R2, =TIME2
			CMP R1, #4							//fourth timer in use
			LDREQ R2, =TIME3

			LDR R3, [R2, #0x10]			//Load S-bit of the timer
			AND R0, R3, #1
			B read_end 	//do not have to consider multiple input, jump to end directly

read_end:
			POP {R1-R4}							// restore original data
			BX LR										// exit subroutine
//-----------------------------------------------------------------------------
HPS_TIM_clear_INT_ASM:
			PUSH {R1-R4}
			AND R0, R0, #0xF			//Except the first four one-hot bits, clear other bits
			MOV R1, #0						//Use R1 as counter, initialize it with 0

clear_loop:
			CMP R1, #4					//compare counter to 4
			BGE clear_end				//if counter is greater than 4, jump to end
			AND R4, R0, #1			//get the status of the timer
			CMP R4, #0					//to see if the corresponding timer is in use or not
			ASR R0, R0, #1			//Shift input by 1 bit to the right (preparation for clear of next timer)
			ADD R1, R1, #1			//update counter
			BEQ clear_loop			//Branch back if current timer not in use

			//Load timer into R2
			CMP R1, #1					//first timer in use
			LDREQ R2, =TIME0
			CMP R1, #2					//second timer in use
			LDREQ R2, =TIME1
			CMP R1, #3					//third timer in use
			LDREQ R2, =TIME2
			CMP R1, #4					//fourth timer in use
			LDREQ R2, =TIME3

			LDR R4, [R2, #0xC]			//Reading F bit automatically clears the entire timer

			//ADD R1, R1, #1				//Increment counter
			B clear_loop

clear_end:
			POP {R1-R4}						//restore original data
			BX LR									//exit subroutine

			.end
