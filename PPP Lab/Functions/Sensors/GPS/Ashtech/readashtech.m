function sEpoch = readashtech( device, sEpoch )
%READASHTECH implements the serial reading of messages from ashtech's
%receivers
%
%   INPUT
%   DEVICE  - FD for device access
%   MESSAGE - Structure to keep known data 
%
%   OUTPUT
%   MESSAGE - Parsed data updated
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    sEpoch.dirty = 0;
    sEpoch.msgID = 'NONE';
    requested    = 0;
    counter      = 1;
    % Break only if you got eph and ranges (dont care if it is enough)
    while 1
        header = syncashtech(device); %reads $PASHR,
        sEpoch = identifymsg(device,header,sEpoch);
                
        % For data saving
        if sEpoch.logging
            storeashtech(sEpoch, sEpoch.logpath);
        end
        
        % Check for ephemerides information
        if ~isstruct(sEpoch.eph) 
            if ~requested || counter > 50
                commandrcv( sEpoch.inputpath, sEpoch.receiver, 'EPH' );
                counter   = 0;
                requested = 1;
                disp('ASKED FOR EPH');
            end
            counter = counter + 1;
            continue;

        % Check for iono data
        elseif ~isstruct(sEpoch.iono)
            if ~requested || counter > 100
                commandrcv( sEpoch.inputpath, sEpoch.receiver, 'ION' );
                counter   = 0;
                requested = 1;
                disp('ASKED FOR ION');
            end
            counter = counter + 1;
            continue;
        end
        
        % Poll data
%         if  ~mod(sEpoch.iEpoch,300)
%             commandrcv( sEpoch.inputpath, sEpoch.receiver, 'ION' );
%             disp('ASKED FOR ION 300'); 
%         end

        
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
   
end


function message = identifymsg( device, msgID, message )
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

    % DBN MESSAGE - Information regarding pseudo range
    if strcmpi(msgID,'RPC,')
        datalength = uint8(fread(device,2));
        datalength = u2(datalength,'bigendian')+2;
        msgID(end) = [];
        cksum      = '16b';
        
    elseif strcmpi(msgID,'DPC,')
        datalength = uint8(fread(device,2));
        datalength = u2(datalength,'bigendian')+2;
        msgID(end) = [];
        cksum      = '16b';     
        
    % SNV MESSAGE - Information regarding sat ephemerides
    elseif strcmpi(msgID,'SNV,')
        datalength = 130+2;
        msgID(end) = [];
        cksum      = '16b';

    % MPC MESSAGE - Ranges to the satellites (C\A, L1, L2)
    elseif strcmpi(msgID,'MPC,') 
        datalength = 94+1;
        msgID(end) = [];
        cksum      = 'XOR';
    
    % MPC MESSAGE - Ranges to the satellites (C\A only)
    elseif strcmpi(msgID,'MCA,') 
        datalength = 94+1;
        msgID(end) = [];
        cksum      = 'XOR';
        
    elseif strcmpi(msgID,'ION,');
        datalength = 74+2;
        msgID(end) = [];
        cksum      = '16b';
%     
%     elseif strcmpi(msgID,'ACK*') %|| strcmpi(msgID,'3D\r\n')
% %         fread(device,2+2); %3D\r\n
%         message.dirty = 0;
%         return;    
    else
        message.dirty = 0;
        return;    
    end
    
    %Retrieve data
    message = acquire( device, msgID, datalength, message, cksum);
    message.msgID = msgID; %stamp after to know previous message
    
end


function previous = acquire( device, msgID, datalength, previous, cksumtype )
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
    
   
    
    % Wait for message to be available
    while device.BytesAvailable < datalength + 2, end; % Plus cr, cl
    payload = fread(device,datalength+2);
%     previous.rawmsg = ['$';'P';'A';'S';'H';'R';',';msgID';',';payload];
    payload(end-1:end) = []; % Remove CR and LF
    payload            = uint8(payload); % Reshapes bits 
    [ckequal, payload] = checksum(payload,cksumtype);
    if ckequal % Compute checksum
        previous.dirty = 1; % sets default flag for WRITE
        previous = parsemsg(msgID, payload, previous);
    else
        previous.dirty  = 0; % sets flag for NO WRITE
        previous.ranges = NaN; % forces ranges clean
        previous.msgID  = 'NULL';
        warning('ASHTECH:acquire',['Checksum failed for: ' sprintf('%s',msgID)]);
%         fprintf('DUMP MESSAGE PAYLOAD')
%         disp(char(payload'));
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
        % not declared or changes between mes, eg, RPC to MPC
        if ~isstruct(message.ranges) 
            message.ranges = ashtechstructs('MPC');
        elseif message.ranges.LEFT == 0 || ~strcmpi(message.ranges.msgID,'MPC') % with old data
            message.ranges = ashtechstructs('MPC');
        end
        message = decodeMPC(payload,message);
        
    % MPC MESSAGE - Measurements SNR, CA, DOPPLER
    elseif strcmpi(msgID,'MCA')
        % not declared or changes between mes, eg, DPC to MCA
        if ~isstruct(message.ranges) || ~strcmpi(message.ranges.msgID,'MCA') 
            message.ranges = ashtechstructs('MCA');
        elseif message.ranges.LEFT == 0 % with old data
            message.ranges = ashtechstructs('MCA');
        end
        message.ranges = decodeMCA(payload,message.ranges);

    elseif strcmpi(msgID,'ION')
        message.iono = decodeION(payload);
        
    else
    %donothing    
    end

end


function [ check, message ] = checksum( message, checktype )
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
           cksum = cksum + u2(message(i:i+1),'bigendian'); % MATLAB does not overflow
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
        
    else
        txchecksum = 0;
        cksum = 1;
    end

    % Verifies if the checksum is correct
    check = txchecksum == cksum;
    
end


       
