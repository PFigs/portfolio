/**
 *  Instituto Superior Tecnico - Instituto Telecomunicacoes
 *  Pedro Silva, May 2012
 * 
 *  CREDITS
 *    Pedro Rui Ceia
 *    http://www.den-uijl.nl/gyro.html
**/

void setAccelometerDataFormat(uint8_t mode);
void setAccelometerInterrupts(uint8_t mode);
void getAccelometerReadings(uint8_t accxyz[], uint8_t nBytes, uint16_t offsetX, uint16_t offsetY, uint16_t offsetZ);
void initACC( void );



