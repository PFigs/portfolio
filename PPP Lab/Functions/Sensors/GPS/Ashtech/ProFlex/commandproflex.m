function succ = commandproflex( COM, command, varargin )
%COMMANPROFLEX queries and sets commands to the PROFLEX receiver
%
%   INPUT
%   COM - File descriptor
%   COMMAND  - Command identifier, eg, RST, OUT, ...
%   VARARGIN - Necessary arguments in acordance with COMMAND
%
%   OUTPUT
%   SUCC - 0 in case of error 1 otherwise
%
%   Pedro Silva, Instituto Superior Tecnico, January 2011
      

    % Default values
    if nargin == 3
        sSettings = varargin{1};
        PORT     =  sSettings.receiver.port;
        MESSAGES =  sSettings.receiver.messages;
        FORMAT   =  sSettings.receiver.format;
        RATE     =  sSettings.receiver.rate;
        MTP      =  sSettings.receiver.mtp;
        
        if isnan(PORT), PORT = 'A'; end;
        if isnan(MESSAGES), MESSAGES = 'SNV,MPC,ION'; end;
        if isnan(FORMAT), FORMAT = 'BIN'; end;
        if isnan(RATE), RATE = '1'; end;
        if isnan(MTP), MTP = '3'; end;
    else
        PORT     = 'A';
        MESSAGES = 'SNV,MPC,ION';
        FORMAT   = 'BIN';
        RATE     = '1';  
        MTP      = '3';  
    end

    % Resets receiver
    if strcmpi(command,'RST');
        if COM.BytesAvailable
            fread(COM,COM.BytesAvailable);
        end
        fprintf(COM,'$PASHS,RST'); % Executes reset
        disp('commandzxw: Brief pause for receiver to do work');
        pause(2);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
    
    % Sets output messages
    elseif strcmpi(command,'OUTMES');          
        MSG        = MESSAGES(MESSAGES~=',');
        for i = 1:size(MSG,2)/3 % number of messages
           str      = strcat('$PASHS,RAW,',MSG(1:3),',',PORT,',ON,1');
           fprintf(COM,str);
           succ     = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
           MSG(1:3) = [];
        end

    % Polls ephemerides - ACK ignored
    elseif strcmpi(command,'EPH')
        str  = strcat('$PASHS,RAW,SNV,A,ON');
        fprintf(COM,str);
        succ = 1;
    
    elseif strcmpi(command,'ION')
        str  = strcat('$PASHS,RAW,ION,A,ON');
        fprintf(COM,str);
        succ = 1;
        
    % Disables Messages
    elseif strcmpi(command,'OFF')
        MSG      = MESSAGES(MESSAGES~=',');
        for i = 1:size(MSG,2)/3 % number of messages
            str      = strcat('$PASHS,RAW,',MSG(1:3),',',PORT,',OFF');
            fprintf(COM,str);
            succ     = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
            MSG(1:3) = [];
        end

    elseif strcmpi(command,'MTP')
        str = strcat('$PASHS,CPD,MTP,',MTP);  %output at 1 sec
        fprintf(COM,str);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,

    % Acknowledge alarms
    elseif strcmpi(command,'WAK')
        str = '$PASHS,WAK';
        fprintf(COM,str);

    % Disables all ATOM messages
    elseif strcmpi(command,'disableATOM')
        str = ['$PASHS,ATM,ALL,',PORT,',OFF'];
        fprintf(COM,str);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,

    % Disables all NMEA messages        
    elseif strcmpi(command,'disableNMEA')
        str = ['$PASHS,NME,ALL,',PORT,',OFF'];
        fprintf(COM,str);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,

    % Disables all RAW messages        
    elseif strcmpi(command,'disableRAW')
        str = ['$PASHS,RAW,ALL,',PORT,',OFF'];
        fprintf(COM,str);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,        
        
    % Command not found
    else
        disp('Command not found...');
        disp('FYI, Default values considered');
        fprintf('OUTPUT => MESSAGES ''%s'' AT PORT ''%c''\n',MESSAGES,PORT);
        fprintf('\tRATE: ''%c'' IN ''%s'' FORMAT\n',RATE,FORMAT);
        succ = 0; 
    end
       
end


function succ = confirmreply( COM, bytes )
%CONFIRMREPLY waits for an ACK or NACK message from the receiver
%
%   INPUT
%   COM - File descriptor
%   BYTES - Number of bytes to read (overwrites default value 4)
%
%   OUTPUT
%   SUCC - 0 in case of error 1 otherwise
%
%   Pedro Silva, Instituto Superior Tecnico, January 2011
    tries = 0;
    succ  = 0;
    while tries < 10
        header = syncashtech(COM, bytes); %reads $PASRH,ACK*3DCRCL,
        if length(header) >= 2
            header(end-1:end) = []; %removes CRCL
        end
        if strcmpi(header,'ACK*3D')
            succ = 1;
            break;
        elseif strcmpi(header,'NAK*30')
            tries = tries + 1;
            break;
        else
           disp(['Wrong header: ' header]);
           tries = tries + 1;
        end
    end
end