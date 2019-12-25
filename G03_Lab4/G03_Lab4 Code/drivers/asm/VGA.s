.text

	.equ PIXEL_BUFF, 0xC8000000 // Base address for pixel buffer
	.equ CHAR_BUFF, 0xC9000000 // Base address for character buff
	.equ H_PIXEL_RESOL, 320 // Maximum X coor of pixel
	.equ V_PIXEL_RESOL, 240 // Maximum Y coor of pixel
	.equ H_CHARACTER_RESOL, 80 //Maximum X coor of char
	.equ V_CHARACTER_RESOL, 60 //Maximum Y coor of char

	// Define several names especially for registers
	X .req R0
	Y .req R1
	C .req R2
	BASE .req R5
	OFST .req R6

	.global VGA_clear_charbuff_ASM // no return, no input
	.global VGA_clear_pixelbuff_ASM // no return, no input
	.global VGA_write_char_ASM //VGA_write_char_ASM(x, y, char c)
	.global VGA_write_byte_ASM //VGA_write_byte_ASM(x, y, char byte)
	.global VGA_draw_point_ASM //VGA_write_byte_ASM(x, y, short colour)

	Ascii_Array:
	.ascii "0123456789ABCDEF"


//----------------------------------------------------------------VGA_clear_charbuff_ASM---------------------------------------------
VGA_clear_charbuff_ASM:
// for (i = 0, i<X_max, i++){
//	for (j=0, j<y+max, j++){
//    clear
//}
//}
	PUSH {R0-R10,LR} // Start of the subroutine
	LDR BASE, =CHAR_BUFF // Load base address of character into BASE register

	MOV R2, #-1	//X counter
	MOV R3, #0	//Y counter
	MOV R4, #0x00	// Allocate R4 to hold address after combining X and Y

	MOV R7, #0x00	//clear pattern
	B clear_char_xloop

clear_char_xloop:
	ADD R2, R2, #1
	CMP R2, #79 // see if counter exceeds XMaximum
	BGT clear_char_Done
	MOV R3, #0 // every time move to a new row, clear the Y counter to zero
clear_char_yloop:	
	CMP R3, #60 //y<=59
	BEQ clear_char_xloop

	LSL OFST, R3, #7		//shift Y offset (y counter) into corresponding position (bit 7-12)
	ORR OFST, OFST, R2      // combine x offset and Y offset
	ADD R4, BASE, OFST	//combine X ,y and the base to get final address
	STRB R7, [R4]		//clear the char pattern at that address

	ADD R3, R3, #1 // looping
	B clear_char_yloop
clear_char_Done:
	POP {R0-R10,LR}
	BX LR


//----------------------------------------------------------------VGA_clear_pixelbuff_ASM---------------------------------------------
VGA_clear_pixelbuff_ASM:
	// parallel with VGA_clear_charbuff_ASM
	PUSH {R0-R10,LR}
	LDR BASE, =PIXEL_BUFF	
	MOV R2, #-1			//X	
	MOV R3, #0			//Y
	MOV R4, #0	 		// address holder
	MOV R9, #0			// clear pattern

	
    B clear_pixel_xloop
clear_pixel_xloop:
	ADD R2, R2, #1	//X loop
	CMP R2, #320    // If all rows checked
	BEQ clear_pixel_Done
	MOV R3, #0

clear_pixel_yloop:	
	CMP R3, #240 //check each unit in a row from top to bottom
	BEQ clear_char_xloop
	
	LSL OFST, R3, #10	//Y address shift to bit 10-17
	LSL R8, R2, #1		//X bit from 1-9, leave bit 0
	ORR OFST, OFST, R8	
	ADD R4, BASE, OFST	//generate final address
	STRH R9, [R4]		//clear by writing zeros
	
	ADD R3, R3, #1 // Y loop
	B clear_pixel_xloop
clear_pixel_Done:
	POP {R0-R10,LR}
	BX LR


//----------------------------------------------------------------VGA_write_char_ASM---------------------------------------------
VGA_write_char_ASM:
	PUSH {R0-R10,LR}

	LDR R3, =H_CHARACTER_RESOL //R3 holds maxi value of X
	LDR R4, =V_CHARACTER_RESOL //R4 holds maxi value of Y

	// check if the input coor are valid
	// if not valid, exit the subroutine without writing anything
	CMP X, R3		
	BGE write_char_failed
	CMP X, #0		
	BLT write_char_failed
	CMP Y, R4			
	BGE write_char_failed
	CMP Y, #0			
	BLT write_char_failed

	LDR BASE, =CHAR_BUFF
	LSL OFST, Y, #7		
	ORR OFST, OFST, X
	ADD R4, BASE, OFST	//find the designated address directly

	STRB C, [R4]		//store char (ascii value) 
write_char_end:
	POP {R0-R10,LR}
	BX LR
write_char_failed:
	POP {R0-R10,LR}
	BX LR
	


//----------------------------------------------------------------VGA_write_byte_ASM---------------------------------------------
VGA_write_byte_ASM:
// Using VGA_write_char_ASM twice
	PUSH {R0-R10,LR} // start of subroutine

	LDR R7, =Ascii_Array
	MOV R3, R2          // duplicated input char
	LSR R2, R3, #4      // discard lower 4 bit in one of the char duplication
	AND R2, R2, #15 	// extract bit 4-7
	LDRB R2, [R7, R2]   // Using the input number (essentially a number from 0-F) to find corresponding ascii code
	BL VGA_write_char_ASM // use write subroutine to store the 

	AND R2, R3, #15 		// get bit 0-3
	ADD R0, R0, #1 			// go to next unit , x+1
	LDRB R2, [R7, R2]       // find corresponding letter for these 4 bits
	BL VGA_write_char_ASM   // use write again
	
	B write_byte_end
	
write_byte_end:
	POP {R0-R10,LR}
	BX LR
	
//----------------------------------------------------------------VGA_draw_point_ASM---------------------------------------------
VGA_draw_point_ASM:
	PUSH {R0-R10,LR}
	LDR BASE, =PIXEL_BUFF
	MOV R10, R2			//place input color (16 bit RGB) in R10

	LSL OFST, Y, #10	//Y address shift to bit 10-17
	LSL R5, X, #1		//X bit from 0-9, leave bit 0

	ADD OFST, OFST, R5	//get final offset (X+Y)
	ADD R4, BASE, OFST	//get final address (base +y+x)
	STRH R10, [R4]		//store colour at the address (color is 16 bits, half word)
	B draw_Point_end

draw_Point_end:
	POP {R0-R10, LR}
	BX LR


	.end