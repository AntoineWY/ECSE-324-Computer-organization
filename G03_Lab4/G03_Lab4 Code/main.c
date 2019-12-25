#include <stdio.h>

#include "./drivers/inc/slider_switch.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/VGA.h"
#include "./drivers/inc/ps2_keyboard.h"

void test_char() {
	int x,y;									// x is row, y is column
	char c = 0;								// start with first ASCII as the input

	for (y=0; y<=59; y++) {								//start with column, then jump to next column
		for (x=0; x<=79; x++) {							//each row of current column
			VGA_write_char_ASM(x, y, c++);		//write character to each position
		}
	}
}

void test_byte() {
	int x,y;									// x is row, y is column
	char c = 0;								// start with 0 as the input, which will be translated to hexi on the screen

	for (y=0; y<=59; y++) {						//start with column, then jump to next column
		for (x=0; x<=79; x+=3) {				//each row of current column, x increases by 3, 2 for hexi, 1 for space
			VGA_write_byte_ASM(x, y, c++);		//write character
		}
	}
}

void test_pixel() {
	int x,y;												// x is row pixel, y is column pixel
	unsigned short colour = 0;			//color to be drawn on the screen

	for (y=0; y<=239; y++) {				//start with column, then jump to next column
		for (x=0; x<=319; x++) {			//each row of current column
			VGA_draw_point_ASM(x,y,colour++);				//print the color for the pixel
		}
	}
}

void vga() {
	while (1) {
		if (read_PB_data_ASM() == 1){							//if the first button is pushed
			if(read_slider_switches_ASM() == 0) {		//if no slide switch is on
				test_char();													//call test char
			}
			else {
				test_byte();													//otherwise, call test_byte
			}
		}
		else if (read_PB_data_ASM() == 2) {				//if the second button is pushed
			test_pixel();														// call test pixel
		}
		else if (read_PB_data_ASM() == 4) {				//if the third button is pushed
			VGA_clear_charbuff_ASM();								//call VGA_clear_charbuff_ASM()
		}
		else if (read_PB_data_ASM() == 8) {				//if the fourth button is pushed
			VGA_clear_pixelbuff_ASM();							//call VGA_clear_pixelbuff_ASM()
		}
	}
}

void ps2keyboard() {
	char value;																	//input character
	int x = 0;																	//x for row
	int y = 0;																	//y for column
	int max_x = 79;															//maximum for x
	int max_y = 59;															//maximum for y

	VGA_clear_charbuff_ASM();

	while(1) {
		if (read_PS2_data_ASM(&value)) {						//if data can be read successfully
			VGA_write_byte_ASM(x, y, value);					//write the data to the designated position
			x += 3;																		//space automatically (2 for data, 1 for space)
			if (x > max_x) {													//if the row is full
				x = 0;																	//reset x to 0
				y += 1;																	//jump to next row
				if (y > max_y) {												//if all rows are full
					y = 0;																//reset to first row
					VGA_clear_charbuff_ASM();
				}
			}
		}
	}
}



int main() {
	//vga();
	ps2keyboard();
	return 0;
}
