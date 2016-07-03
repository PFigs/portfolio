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

void setGyroscopeScale(uint8_t mode);
void setGyroscopeInterrupts(uint8_t mode);
void getGyroscopeReadings(uint8_t gyromes[], uint8_t nBytes);
void initGYRO( void );







