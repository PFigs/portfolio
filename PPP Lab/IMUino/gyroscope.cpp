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

#ifndef ITG3200_H
#define ITG3200_H
#include "ITG3200.h"
#endif

#ifndef COMMUNICATION_H
extern "C"{
#define COMMUNICATION_H
}
#include "communication.h"
#endif




// #define DEBUG_FLAG


extern "C"{
// Configures Accelometer data format
void setGyroscopeScale(uint8_t mode)
{
    
    switch(mode){
        case FULL_SCALE_256:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 256kHz");
            #endif
            write(ITG, DLPF_FS, 0x18);
            break;
        }
        
        case FULL_SCALE_188:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 188kHz");
            #endif
            write(ITG, DLPF_FS, 0x19);
            break;
        }
        
        case FULL_SCALE_98:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 98kHz");
            #endif
            write(ITG, DLPF_FS, 0x1A);
            break;
        }
        
        case FULL_SCALE_42:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 42kHz");
            #endif
            write(ITG, DLPF_FS, 0x1B);
            break;
        }
        
        case FULL_SCALE_20:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 20kHz");
            #endif
            write(ITG, DLPF_FS, 0x1C);
            break;
        }
        
        case FULL_SCALE_10:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 10kHz");
            #endif
            write(ITG, DLPF_FS, 0x1D);
            break;
        }
        
        case FULL_SCALE_5:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET TO FULL SCALE @ 5kHz");
            #endif
            write(ITG, DLPF_FS, 0x1E);
            break;
        }
        
        default:
        {
            #ifdef DEBUG_FLAG
            Serial.println("SET RANGE TO 256kHz BY DEFAULT");
            #endif
            write(ITG, DLPF_FS, 0x18); 
            break;
        }
    
    }
}
}


extern "C"{
// Configure Accelometer Interrupts
void setGyroscopeInterrupts(uint8_t mode)
{
    
    switch(mode)
    {
    
        case INT_DISABLE:
        {
            #ifdef DEBUG_FLAG
            Serial.println("DISABLED INTERRUPTS");
            #endif
            write(ITG, INT_CFG, 0x0); // Disable all interrupts
            break;
        }
    
        default:
        {
            #ifdef DEBUG_FLAG
            Serial.println("DISABLED INTERRUPTS BY DEFAULT");
            #endif
            write(ITG, INT_CFG, 0x0); // Disable all interrupts
            break;
        }
    }
    
}
}


extern "C"{
//Function for reading the accelerometers
void getGyroscopeReadings(uint8_t gyromes[], uint8_t nBytes)
{
    // Temperature and Gyro data is read (already big endian)
    read(ITG,TEMP_OUT_H,nBytes,gyromes); 
}
}


extern "C"{
// Configures ITG to start measuring
void initGYRO( void )
{
    write(ITG, PWR_MGM, ITG_RESET);      // Forces Reset on ITG
    setGyroscopeInterrupts(INT_DISABLE); // Disables interrupts 
    setGyroscopeScale(FULL_SCALE_5);     // 20kHz filter at 1kHz
    write(ITG, SMPLRT_DIV, 0x07); 
    write(ITG,PWR_MGM,ITG_MEASURE);      // Puts device on measure mode

}
}



