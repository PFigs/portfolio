#include "../headers/tools.h"


char *str_sip_reg(char *sip_message,char *app_name,char *app_ext,char *sip_ip,char *sip_port,char *app_ip,char *app_port,char *tag_from,int CSeq, int EXPIRATION);
char *str_sip_ok(char *sip_message,char *receiver_name,char *receiver_ext,char *sip_ip,char *sip_port,char *receiver_ip,char *receiver_port,char *caller_name,char *caller_ext,char *caller_ip,char *caller_port,char *tag_to,char *tag_from,int session_id,int session_version,char *audio_port,char *CSeq,char *CALLID);
char *str_sip_bye(char *sip_message,char *caller_ext,char *sip_ip,char *caller_ip,char *caller_port,char *receiver_ext,char *receiver_ip,char *tag_to, char *tag_from,char *call_id);
char *str_sip_okbye(char *sip_message,char *caller_ext,char *sip_ip,char *caller_ip,char *caller_port,char *receiver_ext,char *receiver_ip,char *tag_to,char *tag_from);
char *str_sip_okbyeteste(char *sip_message,char *bye);
int data_sipbye(char *msg);
int data_sipinvite(char peer[PEER_ROWS][PEER_SIZE],char *msg);
int is_sipbye(char *msg);
int is_sipinvite(char *msg);
int is_sipok(char *msg);



