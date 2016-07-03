/**
 *  Instituto Superior Tecnico - Instituto Telecomunicacoes
 *  Pedro Silva, May 2012
 * 
 *  CREDITS
 *    Pedro Rui Ceia
 *    http://www.den-uijl.nl/gyro.html
**/


#ifndef WIRE_H
#define WIRE_H
#include <Wire.h>
#endif

#ifndef STDIN_H
#define STDIN_H
#include <stdint.h>
#endif

//Function for writing a byte to an address on an I2C device
void write(uint8_t device, uint8_t addr, uint8_t val) {
    
    // I2C push
    Wire.beginTransmission(device);  
    Wire.write(addr);        
    Wire.write(val);        
    Wire.endTransmission();
    
}



//Function for reading num bytes from addresses on an I2C device
void read(uint8_t device, uint8_t addr, uint8_t num, uint8_t buffer[]) {
    
    // I2C pull
    Wire.beginTransmission(device);
    Wire.write(addr);
    Wire.endTransmission();
    Wire.requestFrom(device, num);
    
    // Reads until the correct amount is provided
    uint8_t i = 0;
    while(Wire.available() && i < num){
        buffer[i] = Wire.read();
        i++;
    }
}







