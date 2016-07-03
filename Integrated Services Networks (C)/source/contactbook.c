#include "../headers/tools.h"
#include "../headers/contactbook.h"
/**
 * Destroy the contact Book
 **/
void destroyBook(sContactBook* psContactBook)
{
	sContactBook *aux;

	while(psContactBook!=NULL)
	{
		aux = psContactBook;
		psContactBook = psContactBook->next;
		free(aux);
	}
	
	callid = 0;
}


/*
* Obtains the item in index number idx.
* Always starts from the beginning of the list
*/
sContactBook* popContactBook(int idx)
{
	sContactBook* aux = callers;
	int i;
	
	for( i=0 ; (i<idx) && (aux) ; i++ )
	{
		aux=aux->next;
	}
	
	return aux;
}

/*
* Obtains the item in index number idx.
* Starts at the given member (pointer).
*/
sContactBook* popContactBookNext(sContactBook* psContactBook, int idx)
{
	sContactBook* aux = psContactBook;
	int i;
	
	if(aux==NULL)
		return callers;
		
	for( i=0 ; (i<idx) && (aux) ; i++ )
	{
		aux=aux->next;
	}
	
	return aux;
}

/**
 *Inserts a new entry with the given parameters. The insertion is made on the head
 */
sContactBook* insertUniqueContactBook(unsigned int id, int fd, char *sipname,  char *sipext, char *sipip, char *sipport, char *fromtag, char *sipcallid)
{
	sContactBook * Caller;

	Caller = searchContactExt(callers,sipext);

	if(Caller==NULL)
	{
		if( (Caller = (sContactBook *) malloc(sizeof(sContactBook))) == NULL )
		{
			/**colocar perror*/
			exit(EXIT_FAILURE);
		}
	}else
		return NULL;

	/*Fills the struct with the info provided*/
	memcpy((void *)Caller->sipname,(void*)sipname,strlen(sipname));
	memcpy((void *)Caller->sipext,(void*)sipext,strlen(sipext));
	memcpy((void *)Caller->sipip,(void*)sipip,strlen(sipip));
	memcpy((void *)Caller->sipport,(void*)sipport,strlen(sipport));
	memcpy((void *)Caller->siptagfrom,(void*)fromtag,strlen(fromtag));
	memcpy((void *)Caller->sipcallid,(void*)sipcallid,strlen(sipcallid));
	Caller->id = id;
	Caller->fd = fd;

	/*Pushes the element into the structure*/
	Caller->next = callers;
	callers = Caller;

	return Caller;
}


/**
 *Searches and returns the wanted contact by its ID.
 */
sContactBook* searchContactID(sContactBook* psContactBook, unsigned int id)
{
	sContactBook* aux = psContactBook;
	
	while((aux!=NULL) && (aux->id != id))
		aux=aux->next;

	return aux;
}


/**
 *Searches and returns the wanted contact by its extension.
 */
sContactBook* searchContactExt(sContactBook* psContactBook, char *ext)
{
	sContactBook* aux = psContactBook;
	
	while((aux!=NULL) && (strcmp(aux->sipext,ext)))
		aux=aux->next;

	return aux;
}


/**
 *Searches and returns the wanted contact by its name.
 */
sContactBook* searchContactName(sContactBook* psContactBook, char *sipname)
{
	sContactBook* aux = psContactBook;
	
	while((aux!=NULL) && (strcmp(aux->sipname,sipname)))
		aux=aux->next;

	return aux;
}


/**
 * Searches and deletes the wanted contact by its id
 */
void deleteContactID(sContactBook* psContactBook, unsigned int id)
{
	sContactBook *cpy, *aux = psContactBook;
	
	while(aux->next->id != id)
		aux=aux->next;

	cpy = aux-> next;
	aux = aux->next->next;
	free(cpy);
}


/**
 * Searches and deletes the wanted contact by its pointer
 */
void deleteContactPTR(sContactBook* psContactBook, sContactBook* quitter)
{
	sContactBook *prev,*next;
	sContactBook *aux = psContactBook;

	
	prev = NULL;
	next = psContactBook;
	
	while(aux != NULL && aux != quitter) {
		prev = aux;
		aux = aux->next;
		next = aux->next;
	}

	/*Did not found pointer in the contactbook*/
	if(aux == NULL) return;
	
	if(aux!=callers)
	{
		prev->next = next;
		free(aux);
	}
	else
	{
		callers=callers->next;
		free(aux);
		
		if(!callers)
			callid=0;
	}
}


/**
 * Searches and deletes the wanted contact by its fd
 */
void deleteContactFD(sContactBook* psContactBook, unsigned int fd)
{
	sContactBook *cpy, *aux = psContactBook;
	
	while(aux->next->fd != fd)
		aux=aux->next;

	cpy = aux-> next;
	aux = aux->next->next;
	free(cpy);
}

/*
* Prints several details about the user
*/
void showContact(sContactBook* psContactBook)
{
	if(psContactBook)
		printf ("ID:%d\nFD:%d\nSIPNAME:%s\nSIPEXT:%s\nSIPIP:%s\nSIPPORT:%s\nRTPPORT:%s\nOUTPORT:%d\nINPORT:%d\n",\
		psContactBook->id,\
		psContactBook->fd,\
		psContactBook->sipname,\
		psContactBook->sipext,\
		psContactBook->sipip,\
		psContactBook->sipport,\
		psContactBook->rtpportin,\
		ntohs(psContactBook->addrout.sin_port),\
		ntohs(psContactBook->addrin.sin_port));
}

/*
* Prints details about every contact
*/
void showAllContacts(sContactBook* psContactBook)
{
	sContactBook *aux = psContactBook;

	while(aux!=NULL)
	{
		showContact(aux);
		aux=aux->next;
	}
}

/*** Setters and getters for several atributes of the ContactBook struct*/
void setrtpportIN(sContactBook* psContactBook)
{
	unsigned int length = sizeof(psContactBook->addrin);
	struct sockaddr_in *aux = &(psContactBook->addrin);
	int port;

	if (getsockname(psContactBook->fd, (struct sockaddr *) aux, &length)) {
		perror("getting socket name");
		exit(1);
	}
	port = ntohs(aux->sin_port);
	
	#ifdef __DEBUG__
	printf("%s:%d Socket has port #%d\n",__FILE__,__LINE__,port);
	#endif

	sprintf(psContactBook->rtpportin,"%d",port);
}

int getContactFD(sContactBook* psContactBook)
{
	return psContactBook->fd;

}

unsigned int getContactID(sContactBook* psContactBook)
{
	return psContactBook->id;
}

char *getContactSIPNAME(sContactBook* psContactBook)
{
	return psContactBook->sipname;
}

char *getContactSIPEXT(sContactBook* psContactBook)
{
	return psContactBook->sipext;
}

char *getContactSIPIP(sContactBook* psContactBook)
{
	return psContactBook->sipip;
}

char *getContactSIPPORT(sContactBook* psContactBook)
{
	return psContactBook->sipport;
}

char *getContactRTPPORTIN(sContactBook* psContactBook)
{
	return psContactBook->rtpportin;
}

char *getContactSIPTAGFROM(sContactBook* psContactBook)
{
	return psContactBook->siptagfrom;
}

struct sockaddr_in getContactADDROUT(sContactBook* psContactBook)
{
	return psContactBook->addrout;
}

struct sockaddr_in getContactADDRIN(sContactBook* psContactBook)
{
	return psContactBook->addrin;
}
