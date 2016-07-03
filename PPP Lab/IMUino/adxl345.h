/**
 *  Instituto Superior Tecnico - Instituto Telecomunicacoes
 *  Pedro Silva, May 2012
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
#define ADXL            0x53 // Alternative address used as SDO is grounded
#define ADXLW           0xA6 // Write
#define ADXLR           0xA7 // Read
#define DEVID           0x00 // Device ID

// TAP
#define THD_TAP         0x1D // Tap Threshold
#define DUR_TAP         0x21 // Tap duration
#define LAT_TAP         0x22 // Tap latency
#define WIN_TAP         0x23 // Tap window

#define AXS_TAP         0x2A // Axis control dor tap/double tap
#define ACT_STATUS_TAP  0x2B // Source of tap/double tap

// ACTIVITY
#define THD_ACT         0x24 // Activity threshold
#define THD_INACT       0x25 // Inactivity threshold
#define TIM_INACT       0x26 // Inactivity time
#define CTRL_ACT_INACT  0x27 // Axis enable control for activity and inactivity detection

// FREE FALL
#define THD_FF          0x28 // Free fall threshold
#define TIM_FF          0x29 // Free fall time

// POWER SAVING
#define RATE_BW         0x2C // Data rate and power mode control
#define CTRL_PW         0x2D // Power-saving features control

// INTERRUPTS
#define ENB_INT         0x2E // Interrupt enable control
#define MAP_INT         0x2F // Interrupt map ping control
#define SRC_INT         0x30 // Source of interrupts

// DATA ACCESS
#define FRM_DATA        0x31 // Data format control
#define X0_DATA         0x32 // X-Axis data 0
#define X1_DATA         0x33 // X Axis data 1
#define Y0_DATA         0x34 // Y-Axis data 0
#define Y1_DATA         0x35 // Y-Axis data 1
#define Z0_DATA         0x36 // Z-Axis data 0
#define Z1_DATA         0x37 // Z-Axis data 1
#define CTRL_FIFO       0x38 // FIFO control
#define STAT_FIFO       0x39 // FIFO status


#define ADXL_STANDBY    0x00 
#define ADXL_MEASURE    0x08

#define DATA_FULL2G     0x00
#define DATA_FULL4G     0x01
#define DATA_FULL8G     0x02
#define DATA_FULL16G    0x03

#define FIFO_BYPASS     0x00
#define FIFO_FIFO       0x01
#define FIFO_STREAM     0x02
#define FIFO_TRIGGER    0x03

#define INT_DISABLE     0x00
#define INT_ENABLE      0x01

#define RATE_3200       0xF
#define RATE_1600       0xE
#define RATE_800        0xD
#define RATE_400        0xC
#define RATE_200        0xB
#define RATE_100        0xA
#define RATE_50         0x9
#define RATE_25         0x8
#define RATE_12         0x7
#define RATE_6          0x6

