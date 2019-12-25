#include "address_map_arm.h"

/* This program demonstrates the use of parallel ports in the DE1-SoC Computer
 * It performs the following: 
 * 	1. displays the SW switch values on the red lights LEDR
 * 	2. displays a rotating pattern on the HEX displays
 * 	3. if a KEY[3..0] is pressed, uses the SW switches as the pattern
*/
int main(void){
	int a[5] = {16,20,30,40,50};  // define array for search
	int min_val = a[0];           // current min value always in a[0]
	int i = 1;					  // loop counter
	for(i =1; i<5; i++){
		if(a[i] < min_val){
			min_val = a[i];       // after meeting a smaller number, update the current min
		}
	}
	return min_val;
}

