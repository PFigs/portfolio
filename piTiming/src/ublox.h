/**
 * @file ublox.h
 *
 * @brief This file contains ublox particulars
 *
 */

#ifndef UBLOX
#define UBLOX

#include "main.h"

#define UBX_HEADER_SIZE      2 // B5 62
#define UBX_MSG_TAG_SIZE     4 // class, id, length(2)
#define UBX_CHECKSUM_SIZE    2 // CK_A, CK_B
#define UBX_H_ST          0xB5
#define UBX_H_CF          0x62
#define UBX_NAV           0x01
#define UBX_RXM           0x02
#define UBX_INF           0x04
#define UBX_ACK           0x05
#define UBX_CFG           0x06
#define UBX_MON           0x0A
#define UBX_AID           0x0B
#define UBX_TIM           0x0D
#define UBX_ESF           0x10

// AID
#define UBX_ACK_ACK       0x01
#define UBX_ACK_NAK       0x00

#define UBX_AID_ALM       0x30
#define UBX_AID_ALPSRV    0x32
#define UBX_AID_ALP       0x50
#define UBX_AID_AOP       0x33
#define UBX_AID_DATA      0x10
#define UBX_AID_EPH       0x31
#define UBX_AID_HUI       0x02
#define UBX_AID_INI       0x01
#define UBX_AID_REQ       0x00

// CFG
#define UBX_CFG_ANT       0x13
#define UBX_CFG_CFG       0x09
#define UBX_CFG_DAT       0x06
#define UBX_CFG_EKF       0x12
#define UBX_CFG_ESFGWT    0x29
#define UBX_CFG_FXN       0x0E
#define UBX_CFG_INF       0x02
#define UBX_CFG_ITFM      0x39
#define UBX_CFG_MSG       0x01
#define UBX_CFG_NAV5      0x24
#define UBX_CFG_NAVX5     0x23
#define UBX_CFG_NMEA      0x17
#define UBX_CFG_NVS       0x22
#define UBX_CFG_PM2       0x3B
#define UBX_CFG_PM        0x32
#define UBX_CFG_PRT       0x00
#define UBX_CFG_RATE      0x08
#define UBX_CFG_RINV      0x34
#define UBX_CFG_RST       0x04
#define UBX_CFG_RXM       0x11
#define UBX_CFG_SBAS      0x16
#define UBX_CFG_TMODE2    0x3D
#define UBX_CFG_TMODE     0x1D
#define UBX_CFG_TP5       0x31
#define UBX_CFG_TP        0x07
#define UBX_CFG_USB       0x1B

// ESF
#define UBX_ESF_MEAS      0x02
#define UBX_ESF_STATUS    0x10

// INF
#define UBX_INF_DEBUG     0x04
#define UBX_INF_ERROR     0x00
#define UBX_INF_NOTICE    0x02
#define UBX_INF_TEST      0x03
#define UBX_INF_WARNING   0x01

// MON
#define UBX_MON_HW2       0x0B
#define UBX_MON_HW        0x09
#define UBX_MON_IO        0x02
#define UBX_MON_MSGPP     0x06
#define UBX_MON_RXBUF     0x07
#define UBX_MON_RXR       0x21
#define UBX_MON_TXBUF     0x08
#define UBX_MON_VER       0x04

// NAV
#define UBX_NAV_AOPSTATUS 0x60
#define UBX_NAV_CLOCK     0x22
#define UBX_NAV_DGPS      0x31
#define UBX_NAV_DOP       0x04
#define UBX_NAV_EKFSTATUS 0x40
#define UBX_NAV_POSECEF   0x01
#define UBX_NAV_POSLLH    0x02
#define UBX_NAV_SBAS      0x32
#define UBX_NAV_SOL       0x06
#define UBX_NAV_STATUS    0x03
#define UBX_NAV_SVINFO    0x30
#define UBX_NAV_TIMEGPS   0x20
#define UBX_NAV_TIMEUTC   0x21
#define UBX_NAV_VELECEF   0x11
#define UBX_NAV_VELNED    0x12

// RXM
#define UBX_RXM_ALM       0x30
#define UBX_RXM_EPH       0x31
#define UBX_RXM_PMREQ     0x41
#define UBX_RXM_RAW       0x10
#define UBX_RXM_SFRB      0x11
#define UBX_RXM_SVSI      0x20

// TIM
#define UBX_TIM_SVIN      0x04
#define UBX_TIM_TM2       0x03
#define UBX_TIM_TP        0x01
#define UBX_TIM_VRFY      0x06


typedef enum {LFHEAD,CFHEAD} ubx_states_header;
typedef enum {UBXCLASS,UBXID,UBXPAYLOAD} ubx_states;

void* track_ublox_time(void *arg);
int start_ublox(sensor* gnss);
void lookup_header(sensor *device, int header_start, int header_confirm, uint8_t *header);
uint8_t* fetch_payload(sensor *device, uint8_t* message,uint16_t* message_len);
void dump_message(int fd, uint8_t* message, uint8_t CLASS, uint8_t ID, uint16_t msglen);
void init_log_file(int *fd, char *location);
void safe_write(int fd, void *buff, int len);
void parse_ubx_nav_timegps(uint8_t *buf,int payload_start);
#endif
/*EOF*/
