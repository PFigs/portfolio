function succ = commandac12( COM, command, varargin )
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

    if nargin == 3
        sSettings = varargin{1};
        PORT      = sSettings.receiver.port;
        MESSAGES  = sSettings.receiver.messages;
        FORMAT    = sSettings.receiver.format;
        RATE      = sSettings.receiver.rate;
        
        if isnan(PORT), PORT = 'A'; end;
        if isnan(MESSAGES), MESSAGES = 'SNV,MCA'; end;
        if isnan(FORMAT), FORMAT = 'BIN'; end;
        if isnan(RATE), RATE = '1'; end;
    else
        PORT     = 'A';
        MESSAGES = 'SNV,MCA';
        FORMAT   = 'BIN';
        RATE     = '1';   
    end

    % To reset the receiver
    if strcmpi(command,'RST');  
        fprintf(COM,'$PASHS,RST'); % Executes reset
        disp('commandzxw: Brief pause for receiver to do work');
        pause(0.5);
        succ = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
    
    % For initial initialisation
    elseif strcmpi(command,'OUTMES');          
        MSG         = MESSAGES(MESSAGES~=',');
        for i = 1:size(MSG,2)/3 % number of messages
           str      = strcat('$PASHS,NME,',MSG(1:3),',',PORT,',ON');
           fprintf(COM,str);
           succ     = confirmreply(COM,8); %reads $PASRH,ACK*3DCRCL,
           MSG(1:3) = [];
        end

    % When ephemerides are needed - Poll comand
    elseif strcmpi(command,'EPH')
        str  = strcat('$PASHQ,SNV');
        fprintf(COM,str);
        succ = 1;
    
    % To disable a message
    elseif strcmpi(command,'OFF')
       disp('Not implemented...'); 
       succ = 0; 
       
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

    succ = 0;
    while ~succ
        header = syncashtech(COM, bytes); %reads $PASRH,ACK*3DCRCL,
        if length(header)>=2
            header(end-1:end) = []; %removes CRCL
        end
        if strcmpi(header,'ACK*3D')
            succ = 1;
        elseif strcmpi(header,'NAK*30')
            succ = 0;
            break;
        else
           disp(['Wrong header: ' header]);
           succ = 0;
        end
    end
end