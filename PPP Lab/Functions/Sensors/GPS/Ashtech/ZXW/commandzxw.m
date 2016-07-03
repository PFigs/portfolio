function succ = commandzxw( COM, command, varargin )
%COMMANZXW queries and sets commands to the ZXW receiver
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
        sSettings  = varargin{1};
        PORT      = sSettings.receiver.port;
        MESSAGES  = sSettings.receiver.messages;
        FORMAT    = sSettings.receiver.format;
        RATE      = sSettings.receiver.rate;
        if isnan(PORT), PORT = 'A'; end;
        if isnan(MESSAGES), MESSAGES = 'SNV,MBN,ION'; end;
        if isnan(FORMAT), FORMAT = 'BIN'; end;
        if isnan(RATE), RATE = '1'; end;
    else
        PORT     = 'A';
        MESSAGES = 'SNV,MBN,ION';
        FORMAT   = 'BIN';
        RATE     = '1';   
    end
    
    % Resets receiver - TODO: TRY SEVERAL TIMES IF THE FIRST IS NOT SUCC
    if strcmpi(command,'RST');  
        succ = 0; tries = 0;
        while ~succ
            fprintf(COM,'$PASHS,RST'); % Executes reset
            disp('commandzxw: Brief pause for receiver to do work');
            pause(1 + 0.05*tries);
            succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
            tries = tries + 1;
            if tries > 10
                break;
            end
        end
    % Sets output messages
    elseif strcmpi(command,'OUTMES');  
        setoutrate = strcat('$PASHS,DOI,',RATE);  %output at 1 sec
        setoutmess = strcat('$PASHS,OUT,',PORT,',',MESSAGES,',',FORMAT);
        fprintf(COM,setoutrate);
        confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
        fprintf(COM,setoutmess);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,

    % Polls ephemerides - reply is snv structure
    elseif strcmpi(command,'EPH')
        str      = strcat('$PASHQ,SNV');
        fprintf(COM,str);
        succ = 1;
    
    elseif strcmpi(command,'ION')
        str      = strcat('$PASHQ,ION');
        fprintf(COM,str);
        succ = 1;        
        
    % Acknowledge alarms
    elseif strcmpi(command,'WAK')
        str = '$PASHS,WAK';
        fprintf(COM,str);
        
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
    invalid = 1;
    count   = 0;
    while invalid
        header = syncashtech(COM, bytes); %reads $PASRH,ACK*3DCRCL,
%         disp(header);
        if length(header)>=2
            header(end-1:end) = []; %removes CRCL
        end
        if strcmpi(header,'ACK*3D')
            succ  = 1;
            invalid = 0;
        elseif strcmpi(header,'NAK*30')
            succ = 0;
            invalid = 0;
        else
%          disp(['Wrong header: ' header]);
           count = count +1;
           invalid = 1;
           if count > 10
               pause(0.1+0.05*count);
               succ = 0;
               break;
           end
        end
    end
end