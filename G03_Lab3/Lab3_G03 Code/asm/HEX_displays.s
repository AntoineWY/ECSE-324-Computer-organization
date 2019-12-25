.text
	.equ HEX_3_0_BASE, 0xFF200020
	.equ HEX_5_4_BASE, 0xFF200030
	.global HEX_clear_ASM
	.global HEX_flood_ASM
	.global HEX_write_ASM

//-------------------------------------------------------------------MAIN FUNCTION------------------------------------------
HEX_clear_ASM:
		PUSH {R1-R8,LR}           // Start of the subroutine
		LDR R1, =HEX_3_0_BASE	  // pointing R1 to lower 4 LEDs
		MOV R3, #0	              // Counter
		B clear_LOOP

HEX_flood_ASM:
		PUSH {R1-R8,LR}  
		LDR R1, =HEX_3_0_BASE	
		MOV R3, #0	
		B flood_LOOP

HEX_write_ASM:
		MOV R5, R0
		//PUSH {R1-R12, R14}		//push all data
		BL HEX_clear_ASM		//Clear displays that are being written to
		//POP {R1-R12, R14}		//pop all data
		MOV R0, R5

		PUSH {R4-R12, R14}
		LDR R2, =HEX_3_0_BASE		// Load first half of the displays
		MOV R4, #0
		B case_0


//--------------------------------------------------CLEAR------------------------------------------------------------------------

clear_LOOP:
		CMP R3, #6				  
		BEQ clear_check_lwr_upr	
		AND R4, R0, #1			 // compare the lower bit of R0 (one hot coded HEX)
		CMP R4, #1				 // See if the Hex is selected
		BEQ clear_check_lwr_upr	 
							
cLABEL:
		ASR R0, R0, #1			 // SHift R0 right one bit to check the next input
		ADD R3, R3, #1			 // update counter
		B clear_LOOP	

clear_check_lwr_upr:
		MOV R6, R3
		CMP R3, #3				 // check if the selected HEX is in 0-3 or 4-5
		LDRGT R1, =HEX_5_4_BASE	// If 4-5, point R1 to register hloding HEx 4-5
		SUBGT R3, R3, #4		 // in higher bits, counter is decremented by 4		
		MOV R5, #0xFFFFFF00	    // Generate a corrector with last 8 bits padded 0	
		B clear_align		

clear_align:

		CMP R3, #0				// use counter to find desired 8 bits (corresponds to a HEX)
		BEQ clear_store			
		LSL R5, R5, #8			// left shift 8 bit to make the corrector align with the desired HEX
		ADD R5, R5, #0xFF		// Pad 1 behind thus the original value is unchanged
		SUB R3, R3, #1			// update counter
		B clear_align

clear_store:
		LDR R2, [R1]             // read out original HEX status
		AND R2, R2, R5			 // CLEAR (store all zeros) to a hex 
		STR R2, [R1]			 // put the corrested reg in memory
		
		MOV R3, R6               // restore counter (since R3 might be changed in upper hex case)
		CMP R3 , #5              // compare finished?
        BLT cLABEL				 // if not, go back to the loop 

		POP {R1-R8, R14}         // if finished restore reg and exit subroutine
		BX LR                    

//-------------------------------------------------------------------FLOOD------------------------------------------
// Floof subroutine is symmetrical with the clear routine
// The difference is that instead of AND 0 to clear
// to flood we use OR 1

flood_LOOP:
		CMP R3, #6			   // ??????????see if really needed	
		BEQ flood_check_lwr_upr	
		AND R4, R0, #1			
		CMP R4, #1				
		BEQ flood_check_lwr_upr	
							
fLABEL:
		ASR R0, R0, #1			
		ADD R3, R3, #1			
		B flood_LOOP		
flood_check_lwr_upr:
	    MOV R6, R3
		CMP R3, #3				
		SUBGT R3, R3, #4		
		LDRGT R1, =HEX_5_4_BASE
		MOV R5, #0x000000FF		// create corrector with 8 bits of 1 
		B flood_align		

flood_align:
		CMP R3, #0				
		BEQ flood_store			
		LSL R5, R5, #8			//based on the HEX position, Align the all-1 8 bits pattern to its position	
		SUB R3, R3, #1			
		B flood_align
flood_store:
		LDR R2, [R1]
		ORR R2, R2, R5			// OR 1 to flood desire bits, OR 0 to keep all other bits same
		STR R2, [R1]			
		
		MOV R3, R6
		CMP R3 , #5
        BLT  fLABEL

		POP {R1-R8, R14}
		BX LR
//-------------------------------------------------------------------WRITE------------------------------------------

//The 16 cases
case_0:
				CMP R1, #48
				BNE case_1
				MOV R5, #0x3F
				//MOV R8, R5
				B write_loop
			

case_1:	
				CMP R1, #49
				BNE case_2
				MOV R5, #0x06
				//MOV R8, R5
				B write_loop
			

case_2:	
				CMP R1, #50
				BNE case_3
				MOV R5, #0x5B
				//MOV R8, R5
				B write_loop
			

case_3:	
				CMP R1, #51
				BNE case_4
				MOV R5, #0x4F
				//MOV R8, R5
				B write_loop
			

case_4:	
				CMP R1, #52
				BNE case_5
				MOV R5, #0x66
				//MOV R8, R5
				B write_loop
			

case_5:	
				CMP R1, #53
				BNE case_6
				MOV R5, #0x6D
				//MOV R8, R5
				B write_loop
			

case_6:	
				CMP R1, #54
				BNE case_7
				MOV R5, #0x7D
				//MOV R8, R5
				B write_loop
			

case_7:	
				CMP R1, #55
				BNE case_8
				MOV R5, #0x07
				//MOV R8, R5
				B write_loop
			

case_8:	
				CMP R1, #56
				BNE case_9
				MOV R5, #0x7F
				//MOV R8, R5
				B write_loop
			

case_9:	
				CMP R1, #57
				BNE case_10
				MOV R5, #0x6F
				//MOV R8, R5
				B write_loop
			

case_10:	
				CMP R1, #65
				BNE case_11
				MOV R5, #0x77
				//MOV R8, R5
				B write_loop
			

case_11:	
				CMP R1, #66
				BNE case_12
				MOV R5, #0x7C
				//MOV R8, R5
				B write_loop
			

case_12:	
				CMP R1, #67
				BNE case_13
				MOV R5, #0x39
				//MOV R8, R5
				B write_loop
			

case_13:	
				CMP R1, #68
				BNE case_14
				MOV R5, #0x5E
				//MOV R8, R5
				B write_loop
			

case_14:	
				CMP R1, #69
				BNE case_15
				MOV R5, #0x79
				//MOV R8, R5
				B write_loop
			

case_15:	
				CMP R1, #70
				//BNE case_DEFAULT
				MOV R5, #0x71
				//MOV R8, R5
				B write_loop
			

//case_DEFAULT:
				//MOV R5, #0
				//MOV R8, R5
				//B write_loop
			

write_loop:
				MOV R8, R5              // temporarily hold the input char, it might be changed later

				CMP R4, #5				//finished check the one hot code of hex selection?
				BGT write_done	        //if yes, done
				AND R7, R0, #1          //if not, compare the lower bit

				CMP R7, #0              // is the lower bit selected?
				ADDEQ R4, R4, #1		// if not selected (CMP with zero!), update counter
				LSLEQ R5, #8			// Align input char to next HEX LED by shifting left

				ASR R0, R0, #1			// right shift to check next bit

				//CMP R5, #0
				//MOVEQ R5, R8			//If 0, move original value back in

				//CMP R7, #0 really need? since the flag is not updated

				BEQ write_loop          // if not selected (flag is still from CMP with zero), loop back for next check
	

write_ck_upr:				
				CMP R4, #4                  // if selected, check is the bit in HEX4
				LDRGE R2, =HEX_5_4_BASE		// address for higher two bits
				MOVGE R5, R8                // restore R5! In the write_loop r5 is shifted left
			
				CMP R4, #5                  // if the bit is in HEX5?
				LSLEQ R5, #8                // if yes, shift left R5 to align

write_store:	LDR R7, [R2]                // get the current cleared bit pattern in the HEX
				ORR R7, R7, R5		     	// OR the pattern into desired 8 bits 
				STR R7, [R2]		        //Store back to the HEX

				ADD R4, R4, #1			    //Increment counter for the selected case
				LSL R5, #8				    //Align input char to next HEX LED by shifting left for selected case
				//CMP R5, #0
				//MOVEQ R5, R8			//If 0, move original value back in

				B write_loop
			

write_done:
				POP {R4-R12,R14}            // END of subroutine, restore regs and exit  
				BX LR


	.end
