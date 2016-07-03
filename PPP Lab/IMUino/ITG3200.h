/**
 *  Instituto Superior Tecnico - Instituto Telecomunicacoes
 *  Pedro Silva, May 2012
 *
 *  Headers and register information for the ITG3200 gyroscope
 *
 *  CREDITS
 *    Pedro Rui Ceia
 *    http://www.den-uijl.nl/gyro.html
**/

#ifndef STDIN_H
#define STDIN_H
#include <stdint.h>
#endif


// SPI/I2C ACCESS
#define ITG             0x68 // Alternative address used as SDO is grounded

#define WHO_AM_I        0x00 // Who Am I register (contains I2C addr which can be changed)

#define SMPLRT_DIV      0x15 // Fsample = Finternal (1kHz or 8kHz) / (divider (this register value) + 1)
#define DLPF_FS         0x16 // Scale configuration

// INTERRUPTS
#define INT_CFG         0x17 // Interrupt configuration
#define INT_STATUS      0x1A // Interrupt status

// SENSOR REGISTERS
#define TEMP_OUT_H      0x1B // Temperature data
#define TEMP_OUT_L       0x1C
#define GYRO_XOUT_H     0x1D // X gyro output data
#define GYRO_XOUT_L     0x1E
#define GYRO_YOUT_H     0x1F // Y gyro output data
#define GYRO_YOUT_L     0x20
#define GYRO_ZOUT_H     0x21 // Z gyro output data
#define GYRO_ZOUT_L     0x22

// POWER
#define PWR_MGM         0x3E // Power managment (For better stability external clock or one of the Gyros should be used)


// MEASURE
#define ITG_RESET       0x80
#define ITG_STANDBY     0x58
#define ITG_MEASURE     0x01

// CLK_SEL
#define ITG_CLK_REFINT  0x00
#define ITG_CLK_REFX    0x10
#define ITG_CLK_REFY   0x20
#define ITG_CLK_REFZ      0x30
#define ITG_CLK_REF32k   0x40
#define ITG_CLK_REF19M  0x50


#define INT_DISABLE     0x00
#define INT_ENABLE      0x01


#define FULL_SCALE_256  0x00
#define FULL_SCALE_188  0x01
#define FULL_SCALE_98   0x02
#define FULL_SCALE_42   0x03
#define FULL_SCALE_20   0x04
#define FULL_SCALE_10   0x05
#define FULL_SCALE_5    0x06




