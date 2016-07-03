/*!
 * @file led.cpp
 * 
 * turning on and off a led on the gpio port of the raspberry pi
 * 
 */

#include <iostream>
#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
//#include <lcd.h>

//Using wiringPi

int main(void){
	
	std::cout << "This is a simple led example" << std::endl;
	
	if (wiringPiSetup () == -1)
		return 1;
	
	//SET GPIO17 to OUTPUT
	int pin=0; 
	pinMode(pin, OUTPUT);
	for(int k=0;k<10;k++){
		digitalWrite(pin, 1);
		delay(500);
		digitalWrite(pin, 0);
		delay(250);
	}
	
	return 0;
}
