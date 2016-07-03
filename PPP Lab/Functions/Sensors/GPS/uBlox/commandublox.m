function succ = commandublox( COM, command, varargin )
%COMMANUBLOX queries and sets commands to the UBLOX receiver
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
        MESSAGES =  sSettings.receiver.messages;
    else
        MESSAGES = 'HUI,RAW,EPH';
    end

    % Resets receiver
    if strcmpi(command,'RST');  
        rststr = 'B56206040400FF8709009D07';
        fprintf(COM,'B5620604');
        asc = char(sscanf(rststr,'%2x').');
        fwrite(COM,asc,'uint8'); %check with tmtool if fprintf can be used
        succ = confirmreply(COM); %reads $PASRH,ACK*3DCRCL,
    
    % Enables measurement messages
    elseif strcmpi(command,'OUTMES');  
        ephstr = 'B562060103000B310147C3'; %eph
        rawstr = 'B562060103000210011D66'; %raw
        huistr = 'B5620B0200000D32'; %hui
        MSG    = MESSAGES(MESSAGES~=',');
        for i = 1:size(MSG,2)/3 % number of messages
           if strcmpi(MSG(1:3),'HUI')
               asc = char(sscanf(huistr,'%2x').');
           elseif strcmpi(MSG(1:3),'EPH')
               asc = char(sscanf(ephstr,'%2x').');
           elseif strcmpi(MSG(1:3),'RAW')
               asc = char(sscanf(rawstr,'%2x').');
           end
           fwrite(COM,asc,'uint8');
           MSG(1:3) = [];
        end
        succ = 1;

    % Polls ephemerides
    elseif strcmpi(command,'EPH')
        ephstr = 'B5620B3100003CBF';
        asc = char(sscanf(ephstr,'%2x').');
        fwrite(COM,asc,'uint8');
        succ = 1; 
    
    % Asks for Klobuchar data
    elseif strcmpi(command,'HUI')
        huistr = 'B5620B0200000D32'; %hui
        asc    = char(sscanf(huistr,'%2x').');
        fwrite(COM,asc,'uint8');
        succ = 1; 
    
    elseif strcmpi(command,'DISABLEUBX')
        str = {
            'B562060103000B300045C0'
            'B562060103000B50006500'
            'B562060103000B330048C6'
            'B562060103000B310046C2'
            'B562060103001002001C73'
            'B562060103001010002A8F'
            'B562060103000A05001967'
            'B562060103000A09001D6F'
            'B562060103000A0B001F73'
            'B562060103000A02001661'
            'B562060103000A03001763'
            'B562060103000A06001A69'
            'B562060103000A07001B6B'
            'B562060103000A2100359F'
            'B562060103000A0100155F'
            'B562060103000A08001C6D'
            'B562060103000A0A001E71'
            'B562060103000160006B02'
            'B562060103000122002D86'
            'B562060103000131003CA4'
            'B562060103000104000F4A'
            'B562060103000140004BC2'
            'B562060103000101000C44'
            'B562060103000102000D46'
            'B562060103000108001352'
            'B562060103000132003DA6'
            'B56206010300010600114E'
            'B562060103000103000E48'
            'B562060103000130003BA2'
            'B562060103000120002B82'
            'B562060103000121002C84'
            'B562060103000111001C64'
            'B562060103000112001D66'
            'B562060103000230003CA5'
            'B562060103000231003DA7'
            'B562060103000210001C65'
            'B562060103000211001D67'
            'B562060103000213001F6B'
            'B562060103000220002C85'
            'B562060103000D04001B6E'
            'B562060103000D0200196A'
            'B562060103000D03001A6C'
            'B562060103000D01001868'
            'B562060103000D06001D72'
            };     
        for k=1:numel(str)
            asc  = char(sscanf(str{k},'%2x').');
            fwrite(COM,asc,'uint8');
            confirmreply(COM);
        end
        succ = 1;
        
    % Disables all NMEA messages
    elseif strcmpi(command,'DISABLENMEA')
        str = {
            'B56206010300F00000FA0F'
            'B56206010300F00A000423'
            'B56206010300F00A000423'
            'B56206010300F00A000423'
            'B56206010300F00A000423'
            'B56206010300F009000321'
            'B56206010300F009000321'
            'B56206010300F009000321'
            'B56206010300F009000321'
            'B56206010300F00100FB11'
            'B56206010300F00100FB11'
            'B56206010300F00100FB11'
            'B56206010300F00100FB11'
            'B56206010300F00D000729'
            'B56206010300F00D000729'
            'B56206010300F00D000729'
            'B56206010300F00D000729'
            'B56206010300F00600001B'
            'B56206010300F00600001B'
            'B56206010300F00600001B'
            'B56206010300F00600001B'
            'B56206010300F00200FC13'
            'B56206010300F00200FC13'
            'B56206010300F00200FC13'
            'B56206010300F00200FC13'
            'B56206010300F00700011D'
            'B56206010300F00700011D'
            'B56206010300F00700011D'
            'B56206010300F00700011D'
            'B56206010300F00300FD15'
            'B56206010300F00300FD15'
            'B56206010300F00300FD15'
            'B56206010300F00300FD15'
            'B56206010300F00300FD15'
            'B56206010300F00400FE17'
            'B56206010300F00400FE17'
            'B56206010300F00400FE17'
            'B56206010300F00400FE17'
            'B56206010300F00500FF19'
            'B56206010300F00500FF19'
            'B56206010300F00500FF19'
            'B56206010300F00500FF19'
            'B56206010300F00800021F'
            'B56206010300F00800021F'
            'B56206010300F00800021F'
            'B56206010300F00800021F'
            'B56206010300F10000FB12'
            'B56206010300F10100FC14'
            'B56206010300F10300FE18'
            'B56206010300F10400FF1A'
            'B56206010300F10500001C'
            'B56206010300F10600011E'
            };
        for k=1:numel(str)
            asc  = char(sscanf(str{k},'%2x').');
            fwrite(COM,asc,'uint8');
            confirmreply(COM);
        end
        succ = 1;
        
    else
       disp('Developing...'); 
       succ = 0; 
    end
       
       
end


function succ = confirmreply( COM )
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
        
        header = syncublox(COM);
        header = [dec2hex(header(1),2) dec2hex(header(2),2)]; 
        
        % Checks for ack or nak
        if strcmpi(header,'0501')
            succ = 1;
        elseif strcmpi(header,'0500')
            succ = 0;
            break;
        end

    end
end
