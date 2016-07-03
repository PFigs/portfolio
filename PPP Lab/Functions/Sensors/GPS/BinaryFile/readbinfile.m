function [ sEpoch ] = readbinfile( sEpoch )
%READBINFILE reads the contents of a binary file recorded from an ASHTECH
%receiver (this can be extended in the future)
%
%   INPUT
%   DEVICE  - FD for device access
%   MESSAGE - Structure to keep known data 
%
%   OUTPUT
%   MESSAGE - Parsed data updated
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    sfile        = sEpoch.sfile;
    sEpoch.msgID = 'NONE';
    % Break only if you got eph and ranges (dont care if it is enough)
    while 1
        [header, sfile] = syncbinfile(sfile); %searchs next $PASHR,
        [sEpoch, sfile] = identifymsg(sfile,header,sEpoch);
        
        % Converts data to SN format
        if sEpoch.logging && sEpoch.dirty
            storeashtech(sEpoch, sEpoch.logpath);
            sEpoch.dirty = 0;
        end
        
        % Check for ephemerides information
        if ~isstruct(sEpoch.eph) 
            continue;

        % Check for iono data
%         elseif ~isstruct(sEpoch.iono)
%             continue;
        end
     
        % Check for ranges information
        if strcmpi( sEpoch.msgID,'MPC') 
            if isstruct(sEpoch.ranges) && sEpoch.ranges.LEFT == 0
                break;
            end
        elseif strcmpi( sEpoch.msgID,'RPC')
            break;
            
        elseif strcmpi( sEpoch.msgID,'DPC')
            break;            
        
        elseif strcmpi( sEpoch.msgID,'MCA') 
            if isstruct(sEpoch.ranges) && sEpoch.ranges.LEFT == 0
                break;
            end
        end
        
    end
   
    sEpoch.sfile = sfile;
    
end



function [message,sfile] = identifymsg( sfile, msgID, message )
%IDENTIFYMSG receives a header returns the written message
% This function identifies the message type and provides the necessary 
% inputs for retrieving it.
% It starts by obtaining the length of the message so that it can be
% entirely read from the serial port, taking in mind that the last bytes
% are checksum bytes
%
% INPUT
% DEVICE  - Descriptor to access serial device
% msgID   - The message header
% MESSAGE - Contains known data until now (NaN fields if starting)
%
% OUTPUT
% MESSAGE - Structure with data read
%
% Pedro Silva, Instituto Superior Tecnico, Janeiro 2012

    % For those that use it
    datalength = sfile.content(sfile.position:sfile.position+1);

    % DBN MESSAGE - Information regarding pseudo range
    if strcmpi(msgID,'RPC')
        datalength = u2(datalength,'bigendian');
        cksum      = '16b';
        
    elseif strcmpi(msgID,'DPC')
        datalength = u2(datalength,'bigendian');
        cksum      = '16b';     
        
    % SNV MESSAGE - Information regarding sat ephemerides
    elseif strcmpi(msgID,'SNV')
        datalength = 130+1;
        cksum      = '16b';

    % MPC MESSAGE - Ranges to the satellites (C\A, L1, L2)
    elseif strcmpi(msgID,'MPC') 
        datalength = 94;
        cksum      = 'XOR';
    
    % MPC MESSAGE - Ranges to the satellites (C\A only)
    elseif strcmpi(msgID,'MCA') 
        datalength = 94;
        cksum      = 'XOR';

    % ION MESSAGE - Ionosphere message
    elseif strcmpi(msgID,'ION')
        datalength = 74+1;
        cksum      = '16b';

    % PFS MARKER - Time marker for initial message sync 
    elseif strcmpi(msgID,'PFS')
        datalength = 34;
        cksum      = 'SKIP';
    
    else 
        message.dirty = 0;
        return;    
    end
    
    %Retrieve data
    message        = acquire( sfile, msgID, datalength, message, cksum);
    sfile.position = sfile.position + datalength+1;
    message.msgID  = msgID; %stamp after to know previous message
    
end


function previous = acquire( sfile, msgID, datalength, previous, cksumtype )
%ACQUIRE obtains the message payload
% The payload is obtained acording to the msgID and cksumtype. There are 
% two types of checksums available, short sum and bytewise XOR.
%
% INPUT
% DEVICE - Serial device descritor
% MSGID  - Message Identifier
% DATALENGTH - Size of the payload
% CKSUMTYPE - Checksum to be used
%
% OUTPUT
% RANGES - Structure with acquired data
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

% creat a gloal loop for the MPC messages
% the output must be provided in the following iterations (use NaN for
% first)

    % Checks if message is valid and parses it
    payload = uint8(sfile.content(sfile.position:sfile.position+datalength));
    if checksum(payload,cksumtype);
        previous.dirty = 1; % sets default flag for WRITE
        previous       = parsemsg(msgID, payload, previous);
    else
        previous.dirty  = 0; % sets flag for NO WRITE
        previous.ranges = NaN; % forces ranges clean
        previous.msgID  = 'NULL';
        warning('ASHTECH:acquire',['Checksum failed for: ' sprintf('%s',msgID)]);
        fprintf('DUMP MESSAGE PAYLOAD')
        disp(char(payload'));
    end
    
end


function message = parsemsg( msgID, payload, message )
%PARSEMSG is a parser for ZXW replies
% This function parses the data read from the receiver and returns the
% decoded fields
%
% INPUT
% MSGID - Message ID
% payload  - Message payload
% VARARGIN - Message specific input
%
% OUTPUT
% VARARGOUT - Message specific output
%
% Pedro Silva, Instituto Superior Tecnico, Janeiro 2012

    % Default outputs is input
%     disp(['parsemsg: Decoding ' sprintf('%s',msgID)]);
    
    % DBN MESSAGE - Pseudorange and carrier phase
    if strcmpi(msgID,'RPC')
        message.ranges = decodeRPC(payload);
    
    % DPC MESSAGE - Pseudorange message with time information
    elseif strcmpi(msgID,'DPC')
        message.ranges = decodeDPC(payload);
        
    % SNV MESSAGE - Processed Ephemerides
    elseif strcmpi(msgID,'SNV')
        if ~isstruct(message.eph)
            message.eph    = ashtechstructs( 'SNV' );
        end
        message.eph = decodeSNV(payload,message.eph);
    
    % MPC MESSAGE - Measurements SNR, CA, PR, CP, DOPPLER
    elseif strcmpi(msgID,'MPC')
        if ~isstruct(message.ranges)  
            message.ranges = ashtechstructs('MPC');
        elseif message.ranges.LEFT == 0 || ~strcmpi(message.ranges.msgID,'MPC') % with old data
            message.ranges = ashtechstructs('MPC');
        end
        message = decodeMPC(payload, message);
        
    % MPC MESSAGE - Measurements SNR, CA, DOPPLER
    elseif strcmpi(msgID,'MCA')
        if ~isstruct(message.ranges) % not declared - tests NaN
            message.ranges = ashtechstructs('MCA');
        elseif message.ranges.LEFT == 0 || ~strcmpi(message.ranges.msgID,'MCA') % with old data
            message.ranges = ashtechstructs('MCA');
        end
        message.ranges = decodeMCA(payload,message.ranges);

    elseif strcmpi(msgID,'ION')
        message.iono = decodeION(payload);
        
    
     elseif strcmpi(msgID,'PFS')
        % 14 data     - yyyyMMddHHmmss
        % 7 rate
        % 10 seq tag
        % 
        comma   = char(payload) == ',';
        numvec  = 1:length(payload);
        comma   = numvec(comma);
        
        reftime = payload(1:comma(1)-1);
        reftime = char(reftime)';
        year    = str2double(reftime(1:4));
        month   = str2double(reftime(5:6));
        day     = str2double(reftime(7:8));
        hour    = str2double(reftime(9:10));
        min     = str2double(reftime(11:12));
        sec     = str2double(reftime(13:14));
        stime   = datenum(year,month,day,hour,min,sec);
        
        refseq  = payload(comma(2)+1:end);
        seq     = str2double(num2str(char(refseq)'));
                
        message.TOW     = seqtotow(seq,0,hour,min,weekday(stime)-1);
        message.lastSEQ = seq;
    
    else
    %donothing    
    end

end


function check = checksum( message, checktype )
%CHECKSUM calculates the checksum for the given data
% This checksum is the lsb of the sum of 16 bit input data and made for ZXW
% gps interface
%
% INPUT
% DATA - Decimal fields
%
% OUTPUT
% CKSUM - The sum of unsigned shorts
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % It accepts either row or collumn vectors
    [i,j] = size(message);
    if i>1 && j>1
        error('checksum: INPUT DATA should be a vector or row');
    end
    
    dim   = max(i,j); cksum = 0;
    if strcmpi(checktype,'16b')
        txchecksum   = u2(message(end-1:end),'bigendian'); % Store tx checksum
        message(end-1:end) = []; % Remove tx checksum
        dim = dim - 2;
        for i = 1:2:dim
           cksum = cksum + u2(message(i:i+1),'bigendian');
        end
        cksum = bitand(cksum,2^16-1);
        
    elseif strcmpi(checktype,'xor') 
        txchecksum   = message(end); % Store tx checksum
        message(end) = [];       % Remove tx checksum
        dim = dim-1;
        cksum = 0;
        for i = 1:dim
            cksum = bitxor(cksum,message(i));
        end
        
    elseif strcmpi(checktype,'SKIP')
        txchecksum = 1;
        cksum      = 1;
        
    else
        txchecksum = 0;
        cksum      = 1;
    end
    
    % Verifies if the checksum is correct
    check = txchecksum == cksum;
    
end

function  [header,sfile] = syncbinfile(sfile)      
%SYNCFILE searches for the next $PASHR,
     
    file = sfile.content;
    for k=sfile.position:sfile.depth
        if file(k) == 36 % $
            if strncmpi(char(file(k+1:k+6))','PASHR,',6)
                header = char(file(k+7:k+9))';
                break
            end
        end
    end
    
    % Saves reading point (payload start)
    sfile.position = k+11;
    
    if k == sfile.depth
        throw(ppplabexceptions('binfilend'));
    end
    
end


