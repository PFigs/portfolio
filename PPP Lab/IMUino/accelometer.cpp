/**
 *  Instituto Superior Tecnico - Instituto Telecomunicacoes
 *  Pedro Silva, May 2012
 * 
 *  CREDITS
 *    Pedro Rui Ceia
 *    http://www.den-uijl.nl/gyro.html
**/

#if defined(ARDUINO) && ARDUINO >= 100
  #include "Arduino.h"
#else
  #include "WProgram.h"
  #include <pins_arduino.h>
#endif

#ifndef STDIN_H
#define STDIN_H
#include <stdint.h>
#endif

#ifndef ADXL345_h
#define ADXL345_h
#include "ADXL345.h"
#endif

#ifndef COMMUNICATION_H
extern "C"{
#define COMMUNICATION_H
}
#include "communication.h"
#endif


extern "C"{
// Configures Accelometer data format
void setAccelometerDataFormat(uint8_t mode){
    
    switch(mode){
        case DATA_FULL2G:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET RANGE TO 2G");
            #endif
            write(ADXL, FRM_DATA, 0x8); // +/-2g with full precision 10 bits
            break;
        }
        
        case DATA_FULL4G:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET RANGE TO 4G");
            #endif        
            write(ADXL, FRM_DATA, 0x9); // +/-4g with full precision 11 bits
            break;
        }
        
        case DATA_FULL8G:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET RANGE TO 8G");
            #endif
            write(ADXL, FRM_DATA, 0xA); // +/-8g with full precision 12 bits
            break;
        }
        
        case DATA_FULL16G:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET RANGE TO 16G");
            #endif        
            write(ADXL, FRM_DATA, 0xB); // +/-16g with full precision 13 bits
            break;
        }
        
        default:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET RANGE TO 2G BY DEFAULT");
            #endif
            write(ADXL, FRM_DATA, 0x8); // +/-2g with full precision 10 bits
            break;
        }
    
    }
}
}


extern "C"{
// Configure Accelometer Interrupts
void setAccelometerInterrupts(uint8_t mode){
    
    switch(mode)
    {
    
        case INT_DISABLE:
        {
            #ifdef DEBUG_FLAG
            Serial.println("DISABLED INTERRUPTS");
            #endif
            write(ADXL, ENB_INT, 0x0); // Disable all interrupts
            break;
        }
    
        default: 
        {
            #ifdef DEBUG_FLAG
            Serial.println("DISABLED INTERRUPTS BY DEFAULT");
            #endif
            write(ADXL, ENB_INT, 0x0); // Disable all interrupts
            break;
        }
    }
    
}
}



extern "C"{
// Configure Accelometer FIFO
void setAccelometerFIFO(uint8_t mode){
    
    switch(mode)
    {
    
        case FIFO_BYPASS:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET FIFO TO BYPASS MODE");
            #endif
            write(ADXL, CTRL_FIFO, 0x00); // FIFO not used
        }
        
        case FIFO_STREAM:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET FIFO TO STREAM MODE");
            #endif
            write(ADXL, CTRL_FIFO, 0x46); // Stream mode with six samples (overwrites oldest data)
            break;
        }
        
        
        default: 
        {
        // nothing done
        }
    }
    // #define CTRL_FIFO       0x38 // FIFO control
    // #define STAT_FIFO       0x39 // FIFO status
}
}


extern "C"{
void setAccelometerBandwith(uint8_t mode){
    switch(mode)
    {
        case RATE_50:
        {
            write(ADXL, RATE_BW,RATE_50);
            break;
        }
        default:
        {
            write(ADXL, RATE_BW,RATE_100);
            break;
        }
        
    }
}
}


extern "C"{
//Function for reading the accelerometers
void getAccelometerReadings(uint8_t accxyz[], uint8_t nBytes, uint16_t offsetX, uint16_t offsetY, uint16_t offsetZ)
{
    uint8_t buffer[nBytes];
    int16_t value[3];
    
    // FIFO is read through DATA_X0 to DATA_Z1 address
    read(ADXL,X0_DATA,nBytes,buffer); 

    // Orders bits from the buffer (BIG ENDIAN)
    value[0] = (((int)buffer[1]) << 8) | buffer[0];
    value[1] = (((int)buffer[3]) << 8) | buffer[2];
    value[2] = (((int)buffer[5]) << 8) | buffer[4];
    
    #ifdef DEBUG_FLAG
    Serial.print("X: "); Serial.println(value[0]);
    Serial.print("Y: "); Serial.println(value[1]);
    Serial.print("Z: "); Serial.println(value[2]);
    #endif
    
    
     // value[0] = (abs(value[0]) >= abs(offsetX) ) ? value[0] : 0;
     // value[1] = (abs(value[1]) >= abs(offsetY) ) ? value[1] : 0;
     
     // if(value[2] > 0)
     // {
        // value[2] = (value[2] >= 255 + abs(offsetZ) ) ? value[2] : 255;
        // value[2] = (value[2] <  255 - abs(offsetZ) ) ? value[2] : 255;
     // }
     
    
    // Removes X offset
    if(value[0] > 0)
    {
        if(offsetX > 0)
            value[0] = (value[0] > offsetX)? value[0] - offsetX : 0;
        else
            value[0] = value[0] + offsetX;
    }
    else if(value[0] < 0)
    {
        if(offsetX > 0)
            value[0] = value[0] + offsetX;
        else
            value[0] = (value[0] < offsetX)? value[0] + offsetX : 0;
    }
    
    // Removes Y offset
    if(value[1] > 0)
    {
        if(offsetY > 0)
            value[1] = (value[1] > offsetY)? value[1] - offsetY : 0;
        else
            value[1] = value[1] + offsetY;
    }
    else if(value[0] < 0)
    {
        if(offsetY > 0)
            value[1] = value[1] + offsetY;
        else
            value[1] = (value[1] < offsetY)? value[1] + offsetY : 0;
    }
    
    // Removes Z offset
    if(value[2] > 0)
    {
        if(value[2] < 255)
        {
            value[2] = ((255 - value[2]) > offsetZ)? value[2] + offsetZ : 255;
        }
        else
        {
            value[2] = (abs(255 - value[2]) > offsetZ)? value[2] - offsetZ : 255;
        }
    }
    else if(value[0] < 0)
    {
        value[2] = value[2] + offsetZ;
    }
    
    
    
    
    
    accxyz[0] = (uint8_t) (value[0] >> 8);
    accxyz[1] = (uint8_t) value[0];
    accxyz[2] = (uint8_t) (value[1] >> 8);
    accxyz[3] = (uint8_t) value[1];
    accxyz[4] = (uint8_t) (value[2] >> 8);
    accxyz[5] = (uint8_t) value[2];
    
    #ifdef DEBUG_FLAG
    Serial.print("X: "); Serial.println(((int8_t)accxyz[0]<<8) | accxyz[1]);
    Serial.print("Y: "); Serial.println(((int8_t)accxyz[2]<<8) | accxyz[3]);
    Serial.print("Z: "); Serial.println(((int8_t)accxyz[4]<<8) | accxyz[5]);
    Serial.println("");
    #endif

}
}

extern "C"{
// Configures ADXL to start measuring
void initACC( void )
{
    write(ADXL, CTRL_PW, ADXL_STANDBY);    // Sets ADXL to standby
    setAccelometerInterrupts(INT_DISABLE); // Disables interrupts 
    setAccelometerDataFormat(DATA_FULL2G); // 2G Sensitivity 
    setAccelometerBandwith(RATE_100);      // Sets data rate
    setAccelometerFIFO(FIFO_BYPASS);       // Configures FIFO
    write(ADXL,CTRL_PW,ADXL_MEASURE);      // Puts device on measure mode
}
}



