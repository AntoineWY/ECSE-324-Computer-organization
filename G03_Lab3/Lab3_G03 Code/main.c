#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switch.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/HPS.TIM.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/address_map_arm.h"


int toAscii(int input){
	if (input< 10) { //0-9
		input = input + 48;
	} else { //ABCDEF
		input = input + 55;
	}

	return input;

}

int main(){


//--------------------------------Q1 basic in out--------------------------
/*
	while (1) {
		write_LEDs_ASM(read_slider_switches_ASM());
		if(read_slider_switches_ASM() & 0x200){              //Check if the 10th switch (sw9) is enabled
			HEX_clear_ASM(HEX0|HEX2|HEX1|HEX3|HEX4|HEX5);    //if yes, clear all hex display as long as the switch remains 1

		}
		else{                                                //if not, flood HEX 4 and 5
			HEX_flood_ASM(HEX4|HEX5);
			char value = (0xF & read_slider_switches_ASM()); //extract the lower 4 bit, which is the switch reading
			int pushbutton = (0xF & read_PB_data_ASM());     //extract the lower 4 bit, the push button reading
			//if (value < 10) { //ASCII Number
			//	value = value + 48;
			//} else { //ASCII Letter
			//	value = value + 55;
			//}
			HEX_write_ASM(pushbutton, toAscii(value));       //convert the switch reading into ascii value
		}                                                    // then Writing to the HEX base on the choice of push button.
	}*/



















//Timer Example part of the lab***************************
/*
	int count0 = 0, count1 = 0, count2 = 0, count3 = 0;
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0|TIM1|TIM2|TIM3;
	hps_tim.timeout = 100000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;          // After testing this I flag should be zero to start the timer!!!
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);
	while (1) {
		write_LEDs_ASM(read_slider_switches_ASM());
		if (HPS_TIM_read_INT_ASM(TIM0)) {
			HPS_TIM_clear_INT_ASM(TIM0);
			if (++count0 == 10)
				count0 = 0;
		HEX_write_ASM(HEX0, (count0+48));
		}
		if (HPS_TIM_read_INT_ASM(TIM1)) {
			HPS_TIM_clear_INT_ASM(TIM1);
			if (++count1 == 10)
				count1 = 0;
			HEX_write_ASM(HEX1, (count1+48));
		}
		if (HPS_TIM_read_INT_ASM(TIM2)) {
			HPS_TIM_clear_INT_ASM(TIM2);
			if (++count2 == 10)
				count2 = 0;
		HEX_write_ASM(HEX2, (count2+48));
		}
		if (HPS_TIM_read_INT_ASM(TIM3)) {
			HPS_TIM_clear_INT_ASM(TIM3);
			if (++count3 == 10)
				count3 = 0;
			HEX_write_ASM(HEX3, (count3+48));
		}
	}
*/



//--------------------------------q3 timer
/*
// TIM0 is used to trigger the HEX display 
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000; //timer 0 should have a period of 10ms. Timer 0 is 100Mhz
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim); // Store those configuration in timer 0


// TIM1 is used to poll the button reading
	HPS_TIM_config_t hps_tim_pb;
	hps_tim_pb.tim = TIM1;
	hps_tim_pb.timeout = 5000;
	hps_tim_pb.LD_en = 1;
	hps_tim_pb.INT_en = 0;
	hps_tim_pb.enable = 1;
	HPS_TIM_config_ASM(&hps_tim_pb); //config timer 2

// Initialize the variable holding the reading of the pushbutton
	int pb = 0;

// Initialize variables of the stop watch
	int centiSecond = 0; // 0.01s = 10ms
	int second = 0;
	int minute = 0;

// Getting a flag see the status of the timer
	int status = 0;

// Timer
	while(1) {
		if (HPS_TIM_read_INT_ASM(TIM0) && status) {  // everytime that the timer finished counting a cycle (0.01s)
			HPS_TIM_clear_INT_ASM(TIM0);             // restart the HPStimer
			centiSecond += 1;                        // Increment the primary unit, centisecond by 1

			// The if loop below handles the modulo and the carry of centisecond, second and minute
			if (centiSecond >= 100) {                
				centiSecond = centiSecond - 100; 
				second++;

				if (second >= 60) {
					second = second - 60;
					minute++;

					if (minute >= 60) {
						minute = 0;
					}
				}
			}


			//Write the current time to HEX LED
			HEX_write_ASM(HEX0, toAscii (centiSecond % 10));
			HEX_write_ASM(HEX1, toAscii (centiSecond / 10));
			HEX_write_ASM(HEX2, toAscii (second % 10) );
			HEX_write_ASM(HEX3, toAscii (second / 10));
			HEX_write_ASM(HEX4, toAscii (minute % 10) );
			HEX_write_ASM(HEX5, toAscii (minute / 10) );
		}

		// Polling the pushButton
		if (HPS_TIM_read_INT_ASM(TIM1)) {              // everytime the second bottom finishes a cycle, the pushbotton is checked
			HPS_TIM_clear_INT_ASM(TIM1);               // restart the timer
			int pb = 0xF & read_PB_edgecap_ASM();      // check Edge of the button
		
			if ((pb & 1) && (!status)) {               // If start (pb0) is pressed
				status = 1;                            // start the timer
				PB_clear_edgecap_ASM(PB2|PB1);		   // Make sure the timer is only at start mode
				                                       // meaning the clear and the reset edge is OFF!!!


			} else if ((pb & 2) && (status)) {         // If stop is pressed
				status = 0;                            // Stop the timer and make sure the timer is Not in START mode (clear pb0)
				PB_clear_edgecap_ASM(PB0);             // No need to check RESET since the "Status" flag in the condition


			} else if (pb & 4) {                       // If restart is pressed
				centiSecond = 0;                       // Clear current content of the stopWatch
				second = 0;
				minute = 0;

				status = 0; 	                       // Stop timer

				PB_clear_edgecap_ASM(PB0|PB1);		   // clear push button status
				
				HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5, toAscii(0) ); // display "000000" on LED
				
			}
		}
	}
*/
//----------------------------------------------------------------------------	


//timer with interrupts----------------------------------------------------------------------------------

	//let system to receive INT from pb(ID = 73) and HPStimer (ID = 199) 
	int_setup(2, (int[]) {73, 199 });

	// this timer (TIM0) is to trigger the stop watch
	// since now the push button is detect by the interruption, there is no need to poll them with another timer
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);

	// Timer status
	int isStart=0;

	// Initial status of timer
	int centis = 0;
	int seconds = 0;
	int minutes = 0;

    //Enable PB 0-2 to generate interruption
	enable_PB_INT_ASM(PB0 | PB1 | PB2);

	while (1) {
		
		//everytime that the timer finished counting a cycle (0.01s), it generate a interrupt
		// Thus the flag will be enabled
		if (hps_tim0_int_flag && isStart) {
			hps_tim0_int_flag = 0;
			centis += 1; 

			// The if loop below handles the modulo and the carry of centisecond, second and minute
			if (centis >= 100) {
				centis -= 100;
				seconds++;
				
				if (seconds >= 60) {
					seconds -= 60;
					minutes++;
					
					if (minutes >= 60) {
						minutes = 0;
					}
				}
			}

			//Write the current time to HEX LED
			HEX_write_ASM(HEX0, toAscii(centis % 10));
			HEX_write_ASM(HEX1, toAscii(centis / 10));
			HEX_write_ASM(HEX2, toAscii(seconds % 10));
			HEX_write_ASM(HEX3, toAscii(seconds / 10));
			HEX_write_ASM(HEX4, toAscii(minutes % 10));
			HEX_write_ASM(HEX5, toAscii(minutes / 10));
		}

		//When a pb is pressed, it generate a interruption
		//Machine will read the status of which button is pressed and return the corresponding pb automatically
		if (pb_int_flag != 0){
			if(pb_int_flag == 1) // pb0 is START
				isStart = 1;

			else if(pb_int_flag == 2) // PB1 is stop
				isStart = 0;

			else if(pb_int_flag == 4 ){ // PB2 is reset
				// reset timer
				centis = 0;
				seconds = 0;
				minutes = 0;

				HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5, toAscii(0) ); // display "000000" on LED

				isStart = 0;
			}
			pb_int_flag = 0;   // after dealing int, clear the int flag for next detection
		}
	}

		return 0;
}

