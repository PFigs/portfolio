/*************************************************************************
* Sample sketch based on OBD-II library for Arduino
* Distributed under GPL v2.0
* Copyright (c) 2012-2013 Stanley Huang <stanleyhuangyc@gmail.com>
* All rights reserved.
*************************************************************************/

#include <Arduino.h>
#include "OBD.h"

#define WAIT 1
#define SEND 0
#define FIRST 2

volatile int state = FIRST;

int value;
COBD obd;

void setup()
{
  // Debug LED
  pinMode(13, OUTPUT);

  // Initiates OBD-II connection
  OBDUART.begin(OBD_SERIAL_BAUDRATE);
  while (!obd.Init());

  // Initiates USB serial
  Serial.begin(9600);
  while(!Serial);

  // Attaches interrupt for sending data
  attachInterrupt(3, onInterrupt, RISING);
}

void loop(){
  switch(state){

    case FIRST:
      obd.ReadSensor(PID_SPEED, value);
      state = WAIT;
      break;
    
    case WAIT:
      //does nothing
      break;

    case SEND:
      // Retrieves data from OBD
        obd.ReadSensor(PID_SPEED, value);
        Serial.write(value);
        Serial.write(10);
        digitalWrite(13, state);
        state = WAIT;
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
