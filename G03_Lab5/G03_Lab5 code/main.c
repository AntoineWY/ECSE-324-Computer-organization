#include "./drivers/inc/vga.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/audio.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/wavetable.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/ps2_keyboard.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/slider_switches.h"


/**
 * A helper method calculating the linear approximation of the waves 
 */
double getSample(float freq, int t) {   
	int freqInt = (int) (freq*t);                // integral part of the wave index
	double freqFractional = (freq*t) - freqInt;  // fractional part of the wave index
	int index = freqInt % 48000;                 //  make sure the range of the index is within 48000

	double signal = (1.0 - freqFractional) * sine[index] + freqFractional * sine[index + 1]; // linear interpolation using two nearest sample
	return signal;
}

/**
 * A helper method superpositioning different frequencies of waves
 */
double generateSignal(int* keys, int t, float* frequencies) {
	int i;
	double data = 0;
	// Loop through all keys
	for(i = 0; i < 8; i++){
		// Check if key is pressed
		if(keys[i] == 1){
			// Sum all frequency samples
			data += getSample(frequencies[i], t);
		}
	}
	return data;
}




// part 0 ---------------------------------------------------------------------------------------------------------------------------------------

//natural sampling frequency is 4800Hz and we want the wave to be 100Hz
//Thus every 480 sample make up 1 single period in the output wave 
//This generate 240 high samples and 240 low samples
int main() {

	int counter = 0;
	int signal = 0x00FFFFFF;
	while (1) {
		if (write_in_FIFO_ASM(signal)) {        // if a write is successful, increment the counter
			counter++;                          // if write fails, try writing again
		}
		if (counter >= 240) {                  
			counter = 0;                
			if (signal == 0x00FFFFFF)           // every time half a cycle of high signal (240 samples) completes
				signal = 0x00000000;			// Switch to low signal
			else 
				signal = 0x00FFFFFF;
		}
	}	
	return 0;
}




//Part 1 --------------------------------------------------------------------------------------------------------------------------------



int main() {
	// Setup timer
	int_setup(1, (int []){199}); // 199 is interrupt ID for TIM0
	HPS_TIM_config_t hps_tim;

	// Config a timer to set samplong time in to 1/48000Hz = 20.8*10(-6)s
	hps_tim.tim = TIM0; 
	hps_tim.timeout = 21; //1/48000 = 20.8
	hps_tim.LD_en = 1; 
	hps_tim.INT_en = 1; 
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);
	
	int time = 0;
	while(1){
		if(hps_tim0_int_flag == 1) {
			double signalSum = getSample(130.813, time);         // Set a test note (note c) and calculate the corresponding output from wave table
			audio_write_data_ASM(signalSum, signalSum);          // Write the wave to the audio output
			hps_tim0_int_flag = 0;                               // clear interrupt timer for next counting cycle
			time++;
			}
		if (time == 48000){                                      // check if one cycle (2pi in the sine wave) is finished
			time = 0;
			}
	}

	return 0;
}




//Part 2 --------------------------------------------------------------------------------------------------------------------------------

//array to store the keys currently pressed
//int keyPressed[8] = {0};
//array holding the frequencies, index matched to the keys pressed
//float frequencies[] = {130.813, 146.832, 164.814, 174.614, 195.998, 220.000, 246.942, 261.626};

int main() {
	// array to store the keys currently pressed
	// corresponds to keyboard [A, S, D, F, J, K, L, ;]
	// '1' corresponds to pressed, '0' corresponds to not pressed
	// initialize the array with all 0 (all not pressed)
	int keyPressed[8] = {0};
	//array holding the frequencies, index matched to the keys pressed
	float frequencies[] = {130.813, 146.832, 164.814, 174.614, 195.998, 220.000, 246.942, 261.626};
	// Setup timer
	int_setup(1, (int []){199});
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0; 								//microsecond timer
	hps_tim.timeout = 21; 							//1/48000 = 20.8
	hps_tim.LD_en = 1; 									// initial count value
	hps_tim.INT_en = 1; 								//enabling the interrupt
	hps_tim.enable = 1; 								//enable bit to 1

	HPS_TIM_config_ASM(&hps_tim);

	// whether a key has been released
	int pressed = 0;
	// counter for signal
	int t = 0;
 	// keyboard input
	char value;
	// volume multiplier
	int amplitude = 1;
	//max volume
	int max_vol = 10;
	//minimum volume
	int min_vol = 1;
	// sound signal output
	double signalSum = 0.0;



	while(1) {
			if (read_ps2_data_ASM(&value)) {		//if there is an input from the keyboard
				if(pressed==0){					//if the previous key is released
					switch (value){
				//Note: Frequency
				//C: 130.813Hz
						case 0x1C:									//case "A" (A is pressed)
							if(keyPressed[0]==1){			//if pressed (1), change it to not pressed (0)
								keyPressed[0]=0;
							}else{										//if not pressed (0), change it to pressed (1)
								keyPressed[0]=1;
							}
							break;
				//D = 146.832Hz
						case 0x1B:								//case "S" (S is pressed)
							if(keyPressed[1]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[1]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[1]=1;
							}
							break;
				//E = 164.814Hz
						case 0x23:								//case "D" (D is pressed)
							if(keyPressed[2]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[2]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[2]=1;
							}
							break;
				//F = 174.614Hz
						case 0x2B:								//case "F" (F is pressed)
							if(keyPressed[3]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[3]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[3]=1;
							}
							break;
				//G = 195.998Hz
						case 0x3B:								//case "J" (J is pressed)
							if(keyPressed[4]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[4]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[4]=1;
							}
							break;
				//A = 220.000Hz
						case 0x42:								//case "K" (K is pressed)
							if(keyPressed[5]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[5]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[5]=1;
							}
							break;
				//B = 246.942Hz
						case 0x4B:								//case "L" (L is pressed)
							if(keyPressed[6]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[6]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[6]=1;
							}
							break;
				//C = 261.626Hz
						case 0x4C:								//case ";" (; is pressed)
							if(keyPressed[7]==1){		//if pressed (1), change it to not pressed (0)
								keyPressed[7]=0;
							}else{									//if not pressed (0), change it to pressed (1)
								keyPressed[7]=1;
							}
							break;

						//volumn control
						//volume up
						case 0x55:														// if "+" is pressed on the keyboard
							if(amplitude<max_vol) amplitude++; 	// if the volumn is smaller than max volume, increase by 1
							break;
						//volume down
						case 0x4E:														// if "-" is pressed on the keyboard
							if(amplitude>min_vol)amplitude--;		// if the volumn is greater than minimum volume, decrease by 1
							break;
						case 0xF0: 			//this is used to handle the press and release action
							pressed = 1;	//if 0xF0 is detected from keyboard, it means that the key is pressed and going to be released
														//then we ignore the next input from the keyboard by setting 'pressed' to 1
							break;
						} // end of case
					} else{
						pressed = 0;
					}//end of pressed
			} // end of keyboard input

			//generate the signal at this t based on what keys were pressed
			signalSum = amplitude * generateSignal(keyPressed, t, frequencies);

			// Every 20 microseconds this flag goes high
			if(hps_tim0_int_flag == 1) {
				hps_tim0_int_flag = 0;
				audio_write_data_ASM(signalSum,  signalSum);
				t++;
			}

			if(t==48000){
				t=0;
			}
	} //end of while loop
	return 0;
}
