#ifndef IMU
#define IMU

#include "main.h"

#define USTRAIN_H_ST          0xD7
#define USTRAIN_MESSAGE_SIZE      4
#define USTRAIN_COMMAND_SIZE      8

int start_imu(sensor* imu);
void* track_ustrain_time(void *arg);
int lookup_imu_header(sensor *device, int header_start, uint8_t *header);
uint8_t* fetch_imu_payload(sensor *device, uint8_t* message,uint16_t* message_len);
void dump_imu_message(int fd, uint8_t* message, uint16_t msglen);

#endif
