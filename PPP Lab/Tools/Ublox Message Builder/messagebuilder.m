
clc

% IN HEX STRING            
HEADER  = 'B562';
ID      = '0B30';
PAYLOAD = '0000';

% COMPUTE CHECKSUM - CLASS, ID AND PAYLOAD
strpayload = strcat(ID,PAYLOAD);
ascpayload = char(sscanf(strpayload,'%2x').'); % converts to decimal
strmsg     = strcat(HEADER,strpayload,ubxchecksum(ascpayload));
ascmsg     = char(sscanf(strmsg,'%2x').'); % converts to decimal

fprintf('UBLOX HEX string\n str = ''%s'';\n',upper(strmsg));



% RAW 02100000