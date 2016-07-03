int pbx_reg(int sockfd,char *app_name, char *pbx,char *app,struct sockaddr_in* pbxaddr);
int pbx_unreg(int sockfd,struct sockaddr_in* pbxaddr);
int pbx_handle(char *msg,int sockfd, struct sockaddr_in *pbxaddr);
int pbx_hangup(int id,int sockfd,  struct sockaddr_in *pbxaddr);
void pbx_hangall(int sockfd, struct sockaddr_in* pbxaddr);

/*void serv_forever( pid_t pid_gestorChamadas, int pipe_WD );*/
