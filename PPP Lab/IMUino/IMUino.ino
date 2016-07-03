/**
 *  Instituto Superior Tecnico - Instituto Telecomunicacoes
 *  Pedro Silva, May 2012
 * 
 *  CREDITS
 *    Pedro Rui Ceia
 *    http://www.den-uijl.nl/gyro.html
**/
// Wire.h <> I2C library
//  http://arduino.cc/it/Reference/Wire
//  http://en.wikipedia.org/wiki/I%C2%B2C
//  http://arduino.cc/playground/Main/InterfacingWithHardware#DOF
//
// On UNO devices :
//   ANALOG INPUT PIN 4 - SDA (data line)
//   ANALOG INPUT PIN 5 - SCL (clock line)
#include <avr/wdt.h>
#ifndef WPROGRAM_H
#define WPROGRAM_H
#include "Arduino.h"
#endif

#ifndef WIRE_H
#define WIRE_H
#include <Wire.h>
#endif

#ifndef STDIN_H
#define STDIN_H
#include <stdint.h>
#endif

#ifndef ADXL345_h
#define ADXL345_h
#include "ADXL345.h"
#endif

#ifndef ACCELOMETER_H
#define ACCELOMETER_H
extern "C"{
#include "accelometer.h"
}
#endif

#ifndef GYROSCOPE_H
#define GYROSCOPE_H
extern "C"{
#include "gyroscope.h"
}
#endif

#ifndef COMMUNICATION_H
extern "C"{
#define COMMUNICATION_H
}
#include "communication.h"
#endif


#define SERIAL_RATE  9600

#define START           1
#define RUNNING         2
#define CONFIGURE       3
#define WAIT            4
#define CALIBRATE       5
#define EXIT            8
#define IDLE            9

#define HDRH            255
#define HDRL            181

#define ID_ACC          0
#define ID_GRO          1
#define ID_MAG          2

#define NEW_LINE        10 // \n
#define CARRIAGE        13 // \r


#define CONF_EOM        7
#define NSAMPLES_DISC   30
#define NSAMPLES_MEAN   100
#define NSAMPLES_PASS   1

#define ACC_BYTES       6
#define ACC_EOM         9 // Terminator 1 - 2+1+ACC_BYTES

#define GYRO_BYTES      8
#define GYRO_EOM        11

//#define DEBUG_FLAG

// Needs checksum
char confmsg[CONF_EOM+1]; // Buffer for configure messages (HEADER + , + CMD + \n)

uint8_t accmsg[ ACC_EOM +1]; // Header (2) | ID (2) | VALUES (2)*3 | EOM
uint8_t gyromsg[ GYRO_EOM +1]; // Header (2) | ID (2) | VALUES (2)*4 | EOM


uint8_t operation = 0;  // State flag
uint8_t sampling  = 10; // miliseconds

int16_t offsetX = 1;
int16_t offsetY = 1;
int16_t offsetZ = 1;

// Establishes I2C and SERIAL connections
void setup( void )
{
    // Clears the buffers
    memset((void *)(confmsg), '\0', CONF_EOM+1);
    memset((void *)(accmsg), '\0', ACC_EOM+1); 
    memset((void *)(gyromsg), '\0', GYRO_EOM+1);

    Wire.begin();       //Initiate an SPI communication instance.
    Serial.begin(SERIAL_RATE); //Create a serial connection to display the data on the terminal.
    operation = IDLE; // Awaits instructions from the host

    #ifdef DEBUG_FLAG
    Serial.println("At your service");
    #endif
}


// Operation loop
void loop( void ) {

    // #ifdef DEBUG_FLAG
    // Serial.println("Looping");
    // #endif
	
    switch(operation)
    {
		
        // Initializes sensors when a GO is received
        case START:
        {
            
            #ifdef DEBUG_FLAG
            Serial.println("ACC INIT");
            #endif
            
            // Accelometer
            initACC();
            
            // Builds accelometer message
            accmsg[0]       = HDRH;
            accmsg[1]       = HDRL;
            accmsg[2]       = ID_ACC;
            accmsg[ACC_EOM] = NEW_LINE;

            #ifdef DEBUG_FLAG
            Serial.println("GYRO INIT");
            #endif
            
            // Gyroscope
            initGYRO();
            
            // Builds accelometer message
            gyromsg[0]        = HDRH;
            gyromsg[1]        = HDRL;
            gyromsg[2]        = ID_GRO;
            gyromsg[GYRO_EOM] = NEW_LINE;
            
            #ifdef DEBUG_FLAG
            Serial.println("WAITING");
            #endif
            wdt_enable(WDTO_2S);
            operation = WAIT;  // Jumps to next state
            break;
        }
        
        // Obtains data from sensors
        case RUNNING:
        {
            memset ((void *)(accmsg+3), '\0', ACC_BYTES); // Clears the buffer
            memset ((void *)(gyromsg+3), '\0', GYRO_BYTES);
            
            getAccelometerReadings(accmsg+3, ACC_BYTES, offsetX, offsetY, offsetZ);          // Reads the values on the FIFO
            Serial.write(accmsg,ACC_EOM+1);
            
            getGyroscopeReadings(gyromsg+3, GYRO_BYTES);          // Reads the values on the FIFO
            Serial.write(gyromsg,GYRO_EOM+1);
            
            #ifdef DEBUG_FLAG
            serialPrintVector(accmsg, ACC_EOM);
            serialPrintVector(accmsg, GYRO_EOM);
            #endif
            
            operation = WAIT;
            break;
        }

        case CALIBRATE:
        {
            uint8_t counter = 0;
            
            while(counter < NSAMPLES_PASS)
            {
                counter++;
                
                // Calibrate ACC X
                #ifdef DEBUG_FLAG_CAL
                Serial.println("Calibrating X");
                #endif
                getAxesMean("x");
                #ifdef DEBUG_FLAG_CAL
                Serial.println("Calibrating y");
                #endif
                getAxesMean("y");
                #ifdef DEBUG_FLAG_CAL
                Serial.println("Calibrating Z");
                #endif
                getAxesMean("z");
                offsetZ = abs(255 - abs(offsetZ));

                #ifdef DEBUG_FLAG_CAL
                Serial.print("OFFSET X: ");
                Serial.println(offsetX);
                Serial.print("OFFSET Y: ");
                Serial.println(offsetY);
                Serial.print("OFFSET Z: ");
                Serial.println(offsetZ);
                #endif
            }
            
            // Signals the host that calibration is done
            Serial.write("$CAL\n");
            operation = IDLE;
            break;
        }
        // Changes sensors configuration
        case CONFIGURE:
        {
            operation = START;
            break;
        }
        
        //Sleeps
        case WAIT:
        {
            delay(sampling);
            // Serial.flush();
            operation = RUNNING;
            break;
        }
        
        // Cleans up and exits
        case EXIT:
        {
            Serial.end();
            operation = IDLE;
            break;
        }
        default:
        {
            delay(10);
            // #ifdef DEBUG_FLAG
            // Serial.print("Doing Nothing\n");
            // #endif
            break;
            // does nothing
        }
    }
	wdt_reset();
}


/*
* GETAXESMEAN(char axes)
*   
*   Computes the mean value on the given AXES
*   The function assumes that the device is sitting idle on a table
*   With the X and Y axes pararell to the table and Z perpendicular to it
*
*/
void getAxesMean(char *axes)
{
    uint16_t counter = 0;
    uint8_t buffer[6];
    
    // Cleans older mean
    if(axes == "x")
        offsetX = 0;
    if(axes == "y")
        offsetY = 0;
    if(axes == "z")
        offsetZ = 0;
    
    delay(sampling*5);
    // Discards a few samples
    while(counter < NSAMPLES_DISC)
    {
        getAccelometerReadings(buffer, ACC_BYTES, 0,0,0);
        delay(sampling);
        counter++;
    }
    counter = 0;
    while(counter < NSAMPLES_MEAN)
    {
        getAccelometerReadings(buffer, ACC_BYTES, 0,0,0);
        
        if(axes == "x")
        {
            offsetX += (((int8_t) buffer[0] << 8) | buffer[1]);
            offsetX = offsetX/2;
        }
        else if(axes == "y")
        {
            offsetY += (((int8_t) buffer[2] << 8) | buffer[3]);
            offsetY = offsetY/2;
        }
        else if(axes == "z")
        {
            offsetZ += (((int8_t) buffer[4] << 8) | buffer[5]);
            offsetZ = offsetZ/2;
        }
        delay(sampling);
        counter++;
    }
}



/*
* SERIALPRINTVECTOR( uint8_t vec[], uint8_t size)
*   
*   Wraper for Serial.Print
*   The function makes several call to print SIZE bytes
*   from VEC to the Serial output
*
*/
void serialPrintVector( uint8_t vec[], uint8_t size)
{
    uint8_t k;

    for(k=0;k<size;k++)
    {
        Serial.print(vec[k]);
    }
    Serial.println();
}



/*
* SERIALEVENT(void)
*   
*   Callbak for host -> arduino communication
*   The function evaluates which states the host wants the
*   Arduino to jump to
*
*   MESSAGE FORMAT:
*       CFG,<CMD_NAME>\n
*
*   AVAILABLE COMMANDS
*   RUN, INIT, EXIT, CALIBRATE, STP
*
*/
void serialEvent() 
{
    uint8_t nRead = 0;

    #ifdef DEBUG_FLAG
    Serial.println("Ready to serve");
    #endif

	// Default timeout is 1 second
	nRead = Serial.readBytes(confmsg, CONF_EOM);
	    
	#ifdef DEBUG_FLAG_CAL
	Serial.print("Serial Event ");
	Serial.print(" : ");
	Serial.print(confmsg);
	Serial.println(".");
	#endif
    
	wdt_reset();
	
    if(nRead > 0 && strncmp(confmsg,"CFG",3) == 0)
    {
        // uint8_t ack[4] = {36,65,67,75};
        if(strncmp(confmsg+4,"CAL",3)==0)
        {
            #ifdef DEBUG_FLAG_CAL
            Serial.println("CALIBRATE");
            #endif
            operation = CALIBRATE;
            Serial.write("$ACK\n");
        }
        else if(strncmp(confmsg+4,"INI",3)==0)
        {
            #ifdef DEBUG_FLAG
            Serial.println("INIT");
            #endif
            operation = START;
			Serial.write("$ACK\n");
            // Serial.write(ack,sizeof(ack));
        }
        else if(strncmp(confmsg+4,"EXT",3)==0)
        {
            #ifdef DEBUG_FLAG
            Serial.println("EXIT");
            #endif
            operation = EXIT;
            // Serial.write(ack,sizeof(ack));
        }
        else if(strncmp(confmsg+4,"STP",3)==0)
        {
            #ifdef DEBUG_FLAG
            Serial.println("IDLE");
            #endif
            operation = IDLE;
            // Serial.write(ack,sizeof(ack));
        }
        else if(strncmp(confmsg+4,"RUN",3)==0)
        {
            #ifdef DEBUG_FLAG
            Serial.println("RUN");
            #endif
            operation = RUNNING;
            // Serial.write(ack,sizeof(ack));
        }
		 else
		{
			operation = operation;
			Serial.write("$NAK\n");
		}
    }
	else
	{
		operation = operation;
	}
   
    memset((void *)(confmsg), '\0', CONF_EOM+1);        
}
