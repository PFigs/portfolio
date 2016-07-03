#include "tools.h"

sContactBook* insertUniqueContactBook(unsigned int id, int fd, char *sipname,  char *sipext, char *sipip, char *sipport, char *fromtag, char * sipcallid);
sContactBook* popContactBook(int idx);
sContactBook* popContactBookNext(sContactBook* psContactBook, int idx);
sContactBook* searchContactID(sContactBook* psContactBook, unsigned int id);
sContactBook* searchContactExt(sContactBook* psContactBook, char *ext);
sContactBook* searchContactName(sContactBook* psContactBook, char *sipname);

void deleteContactID(sContactBook* psContactBook, unsigned int id);
void deleteContactFD(sContactBook* psContactBook, unsigned int fd);
void deleteContactPTR(sContactBook* psContactBook, sContactBook* quitter);
void destroyBook(sContactBook* psContactBook);
void showContact(sContactBook* psContactBook);
void showAllContacts(sContactBook* psContactBook);
void setrtpportIN(sContactBook* psContactBook);

int getContactFD(sContactBook* psContactBook);
unsigned int getContactID(sContactBook* psContactBook);
char *getContactSIPNAME(sContactBook* psContactBook);
char *getContactSIPEXT(sContactBook* psContactBook);
char *getContactSIPPORT(sContactBook* psContactBook);
char *getContactSIPIP(sContactBook* psContactBook);
char *getContactRTPPORTIN(sContactBook* psContactBook);
char *getContactSIPTAGFROM(sContactBook* psContactBook);
struct sockaddr_in getContactADDROUT(sContactBook* psContactBook);
struct sockaddr_in getContactADDRIN(sContactBook* psContactBook);
