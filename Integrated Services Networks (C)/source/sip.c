#include "../headers/sip.h"
#include "../headers/tools.h"


char *str_sip_reg(char *sip_message,char *app_name,char *app_ext,char *sip_ip,char *sip_port,char *app_ip,char *app_port,char *tag_from,int CSeq, int EXPIRATION)
{	
	/*TAG DO CAMPO FROM AINDA NAO E ALEATORIO*/
	/*CSEQ TA CERTO? */
	/*MAX_FORWARDS CONSTANTE OU ARGUMENTO?*/
		
	sprintf(sip_message,"REGISTER sip:%s SIP/2.0\nVia: SIP/2.0/UDP %s:%s;branch=%s\nMax-Forwards: %d\nTo: %s <sip:%s@%s>\nFrom: %s <sip:%s@%s>;tag=%s\nCall-ID: %s@%s\nCSeq: %d REGISTER\nContact: %s <sip:%s@%s:%s>\nExpires: %d\nContent-Length: 0\n\n",sip_ip,app_ip,app_port,BRANCH,MAX_FORWARDS,app_name,app_ext,sip_ip,app_name,app_ext,sip_ip,tag_from,CALL_ID,app_ip,CSeq,app_name,app_ext,app_ip,app_port,EXPIRATION);	
	
	return sip_message;
}

/*CONTENT LENGTH sempre 129?*/
char *str_sip_ok(char *sip_message,char *receiver_name,char *receiver_ext,char *sip_ip,char *sip_port,char *receiver_ip,char *receiver_port,char *caller_name,char *caller_ext,char *caller_ip,char *caller_port,char *tag_to,char *tag_from,int session_id,int session_version,char *audio_port,char *CSeq,char *CALLID)
{
	char v[PARAM_LENGTH];
	char o[PARAM_LENGTH];
	char s[PARAM_LENGTH];
	char t[PARAM_LENGTH];
	char c[PARAM_LENGTH];
	char m[PARAM_LENGTH];
	char a[PARAM_LENGTH];
	char *aux="";
	
	char content[MSG_LENGTH];
	
	strcpy(v,"0");
	sprintf(o,"%s %d %d IN IP4 %s",receiver_ext,session_id,session_version,receiver_ip);
	strcpy(s,"");
	strcpy(t,"0 0");
	sprintf(c,"IN IP4 %s",receiver_ip);
	sprintf(m,"audio %s RTP/AVP 0",audio_port);
	sprintf(a,"rtpmap:0 pcmu/8000");
	
	sprintf(content,"v=%s\no=%s\ns=%s\nt=%s\nc=%s\nm=%s\na=%s",v,o,s,t,c,m,a);
	
	
	if(!caller_name)
		caller_name = aux;
	
	
	sprintf(sip_message,"SIP/2.0 200 OK\nVia: SIP/2.0/UDP %s:%s;branch=%s\nTo: <sip:%s@%s>;tag=%s\nFrom: %s <sip:%s@%s>;tag=%s\nCall-ID: %s\nCSeq: %s INVITE\nContact: %s <sip:%s@%s:%s>\nContent-Type: application/sdp\nContent-Length: %d\n\n%s\n",caller_ip,caller_port,BRANCH,receiver_ext,sip_ip,tag_to,caller_name,caller_ext,sip_ip,tag_from,CALLID,CSeq,receiver_name,receiver_ext,receiver_ip,receiver_port,(int)strlen(content),content); /*CONTACT LENGTH SEMPRE 129 OU CALCULAR COM SIZEOF(CONTENT)?*/
	
	
	if(caller_name == aux)
		caller_name = NULL;
	return sip_message;
}



char *str_sip_bye(char *sip_message,char *caller_ext,char *sip_ip,char *caller_ip,char *caller_port,char *receiver_ext,char *receiver_ip,char *tag_to, char *tag_from,char *call_id)
{
	sprintf(sip_message,"BYE sip:%s:%s SIP/2.0\nVia: SIP/2.0/UDP %s:%s;branch=%s\nMax-Forwards:%d\nFrom: sip:%s@%s;tag=%s\nTo: sip:%s@%s;tag=%s\nCall-ID: %s\nCSeq: 2 BYE\nContent-Length: 0\n\n",receiver_ext,sip_ip,caller_ip,caller_port,BRANCH,MAX_FORWARDS,caller_ext,sip_ip,tag_from,receiver_ext,sip_ip,tag_to,call_id);
	
	return sip_message;
}



char *str_sip_okbye(char *sip_message,char *caller_ext,char *sip_ip,char *caller_ip,char *caller_port,char *receiver_ext,char *receiver_ip,char *tag_to,char *tag_from)
{
	sprintf(sip_message,"SIP/2.0 200 OK\nVia: SIP/2.0/UDP %s:%s;branch=%s\nFrom: sip:%s@%s;tag=%s\nTo: sip:%s@%s;tag=%s\nCall-ID: %s@%s\nCSeq: 2 BYE\nContent-Length: 0\n\n",caller_ip,caller_port,BRANCH,caller_ext,sip_ip,tag_from,receiver_ext,sip_ip,tag_to,CALL_ID,receiver_ip);
	
	return sip_message;
}

char *str_sip_okbyeteste(char *sip_message,char *bye)
{
	char *aux = index(bye,'\n')+1;
	sprintf(sip_message,"SIP/2.0 200 OK\n%s",aux);
	return sip_message;
}

int data_sipbye(char *msg)
{
	char *aux = msg;
	char ext[10];
	int i=0;
	
	
	/*posicionar apontador no campo from:*/
	while(strncmp(aux,"From:",5))
		aux = index(aux,'\n')+1;
	
	/*ler e devolver extensao*/
	aux = index(aux,'<')+5;
	while(aux[i]!='@')
	{
		ext[i]=aux[i];
		i++;
	}
	ext[i]='\0';
	return atoi(ext);
}

int data_sipinvite(char peer[PEER_ROWS][PEER_SIZE],char *msg)
{
	char *contact;
	char *aux;
	char *tmp;
	int k;
	int j;
	
	
	/*ler atributos da mensagem invite*/
	for(k=4,contact=strtok(msg,"\n");k!=0;contact = strtok(NULL,"\n")) {
		
		/*ler informacao de contacto*/
		if( !strncmp(contact,"Contact:",8) )
		{
			k--;
			
			/*adquirir nome do chamador*/
			aux=index(contact,(int)':')+2;
			for(j=0;aux[0]!='<';aux++,j++)
			{
				peer[PEER_NAME][j] = aux[0];
			}
			peer[PEER_NAME][j]='\0';

			while (aux[0]!=':')
				aux++;
			
			/*adquirir extensao do chamador*/
			for(j=0,aux++;aux[0]!='@';j++,aux++)
				peer[PEER_EXT][j] = aux[0];
			peer[PEER_EXT][j]='\0';

			/*adquirir endereco ip do chamador*/
			for(j=0,aux++;aux[0]!=':' && aux[0]!='>';j++,aux++)
				peer[PEER_IP][j] = aux[0];
			peer[PEER_IP][j]='\0';

			
			/*atribuir porta por defeito caso nao seja especificada no convite*/
			if(aux[0] == '>')
				strcpy(peer[PEER_PORT],"5060");
				
			/*adquirir porta definida no convite*/
			else
			{
				for(j=0,aux++;aux[0]!='>';j++,aux++)
					peer[PEER_PORT][j] = aux[0];
				peer[PEER_PORT][j]='\0';
			}
			
		}
		
		
		/*adquirir tagfrom*/
		if( !strncmp(contact,"From:",5) )
		{
			int i;
			k--;
			aux = index(contact,';')+5;
			
			strcpy(peer[PEER_FROMTAG],aux);
			
			for(i=0;peer[PEER_FROMTAG][i]!='\r' && peer[PEER_FROMTAG][i]!='\n';i++);
			peer[PEER_FROMTAG][i]='\0';
			
		}
		
		
		/*adquirir call-id*/
		if( !strncmp(contact,"Call-ID:",8) )
		{
			int i;
			k--;
			aux = index(contact,' ')+1;
			
			strcpy(peer[PEER_CALLID],aux);
			
			for(i=0;peer[PEER_CALLID][i]!='\r' && peer[PEER_CALLID][i]!='\n';i++);
			peer[PEER_CALLID][i]='\0';
		}
		
		
		/*adquirir numero de sequencia*/
		if( !strncmp(contact,"CSeq:",5) )
		{
			int i;
			k--;
			aux = index(contact,' ')+1;
			
			strcpy(peer[PEER_CSEQ],aux);
			
			for(i=0;peer[PEER_CSEQ][i]!=' ';i++);
			peer[PEER_CSEQ][i]='\0';
		}
	}
	
	j=0;
	
	/*ler conteudo do invite*/
	while(j<2)
	{
		tmp=strtok(NULL,"\r\n");
		
		if(!tmp)
			return -1;
		
		/*adquirir ip para o protocolo rtp*/
		if(!strncmp(tmp,"c=",2))
		{
			j++;
			strcpy(peer[PEER_RTPIP],tmp+9);
		}
		
		/*adquirir a porta para o protocolo rtp*/
		if(!strncmp(tmp,"m=",2))
		{
			j++;
			sscanf(tmp,"m=audio %s",peer[PEER_RTPPORT]);
		}
	}
	
	return 0;
}

int is_sipbye(char *msg)
{	
	if (!strncmp(msg,"BYE",3))
		return TRUE;
	return FALSE;
}

int is_sipinvite(char *msg)
{
	if (!strncmp(msg,"INVITE",6))
		return TRUE;
	return FALSE;
}

int is_sipok(char *msg)
{
	if (!strncmp(msg,"SIP/2.0 200 OK",14))
		return TRUE;
	return FALSE;
}
