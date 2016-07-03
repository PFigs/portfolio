/*************************************************************************
* Sample sketch based on OBD-II library for Arduino
* Distributed under GPL v2.0
* Copyright (c) 2012-2013 Stanley Huang <stanleyhuangyc@gmail.com>
* All rights reserved.
*************************************************************************/
#include <Wire.h>
#include <Arduino.h>
#include "OBD.h"

#define WAIT 1
#define SEND 0

// define slave address (0x2A = 42)
#define SLAVE_ADDRESS 0x02

volatile int state = WAIT;

void setup()
{
  // Debug LED
  pinMode(13, OUTPUT);  
  
  // initialize i2c as slave
  Wire.begin(SLAVE_ADDRESS);
  
  // Attaches interrupt for sending data
  attachInterrupt(0, onInterrupt, RISING);
}

void loop(){
  switch(state){
    case WAIT: 
      //does nothing
      state = WAIT;
      break;
    
    case SEND:
      // Retrieves data from OBD
//      noInterrupts();
      Wire.write(24);             // sends value byte  
      Wire.write(10);
      digitalWrite(13, state);
      state = WAIT;
//      interrupts();
      break;

    default:
      digitalWrite(13, state);
  }
}

void onInterrupt(){
  // On interrupt send data
  digitalWrite(13, state);
  state = SEND;
}


