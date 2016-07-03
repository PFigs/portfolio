function sEpoch = readublox( device, sEpoch )
%READUBLOX implements the serial reading of messages from ublox's receivers
%
%   INPUT
%   DEVICE  - FD for device access
%   MESSAGE - Structure to keep known data 
%
%   OUTPUT
%   MESSAGE - Parsed data updated
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    persistent ioncounter;
    
    if isempty(ioncounter)
        ioncounter = 0;
    end
    
    ioncounter = ioncounter +1;
    
    if ioncounter == 15*60
        commandrcv( sEpoch.inputpath, sEpoch.receiver, 'HUI' );
    end

    sEpoch.dirty = 0;
    sEpoch.msgID = 'NOTKNOWN';
    % Break only if you got eph and ranges (dont care if it is enough)
    while 1
        header = syncublox(device);
        sEpoch = identifymsg(device,header,sEpoch);

        % For data saving
        if sEpoch.logging && sEpoch.dirty
            storeublox(sEpoch, sEpoch.logpath);
            sEpoch.dirty = 0;
        end
        
        % Check for ephemerides information
        if ~isstruct(sEpoch.eph)
            commandrcv( sEpoch.inputpath, sEpoch.receiver, 'EPH' );
            continue;
        
        % Check for iono information
        elseif ~isstruct(sEpoch.iono)
            commandrcv( sEpoch.inputpath, sEpoch.receiver, 'HUI' );
            continue;
        end
        
        % Breaks when all measurements are available
        if strcmpi( sEpoch.msgID,'RAW')
            if isstruct(sEpoch.iono)
                break;
            end
        end
    end
   
end


function message = identifymsg( device, msgHD, message )
%IDENTIFYMSG receives a header returns the written message
% This function identifies the message type and provides the necessary 
% inputs for retrieving it.
% It starts by obtaining the length of the message so that it can be
% entirely read from the serial port
%
% INPUT
% DEVICE  - Descriptor to access serial device
% MSGHD   - The message header and payload size
% MESSAGE - Contains known data until now (NaN fields if starting)
%
% OUTPUT
% MESSAGE - Structure with data read
%
% Please refer to ublox's reference manual page 82 for general description
% of the message received
%
% Pedro Silva, Instituto Superior Tecnico, Janeiro 2012

    %Retrieve data
    datalength     = u2(uint8(msgHD(3:4))) + 2; % Plus chksum
    message        = acquire( device, msgHD, datalength, message);
    
end


function previous = acquire( device, msgHD, datalength, previous )
%ACQUIRE obtains the message payload
% The payload is obtained acording to the msgHD and cksumtype. There are 
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
    
    % Wait for message to be available
    while device.BytesAvailable < datalength, end; 
    payload = fread(device,datalength);
    [ckequal, payload] = checksum([msgHD; payload]); % PAYLOAD MUST BE DOUBLE (MATLAB does not overflow)
    if ckequal % Compute checksum
        previous.dirty = 1; % sets flag for WRITE
        previous = parsemsg(msgHD, payload, previous);
    else
        previous.dirty  = 0; % sets flag for NO WRITE
        previous.ranges = NaN;
        warning('UBLOX:acquire',['Checksum failed for: ' sprintf('%s',msgHD)]);
    end
    
end


function message = parsemsg( msgHD, payload, message )
%PARSEMSG is a parser for UBLOX replies
%   This function parses the data read from the receiver and returns the
%   decoded fields
%
%   INPUT
%   MSGID - Message ID
%   payload  - Message payload
%   VARARGIN - Message specific input
%
%   OUTPUT
%   VARARGOUT - Message specific output
%
% Pedro Silva, Instituto Superior Tecnico, Janeiro 2012
    
payload = uint8(payload);
    CLASS   = msgHD(1);
    ID      = msgHD(2);
    
    if CLASS == 11 % AID
        if ID == 49 % AID EPH
            msgID = 'EPH';
        end
        if ID == 2  % AID HUI
            msgID = 'HUI';
        end
    elseif CLASS == 2  % RXM
        if ID == 16 %RXM RAW
            msgID = 'RAW';
        end
    else
%         fprintf('Unknown message: %d\n',dec2hex(msgHD,2));
        message.dirty = 0;
        return;    
    end
    
%     fprintf('parsemsg:Decoding message: %s\n',msgID);
    
    % DBN MESSAGE - Pseudorange and carrier phase
    if strcmpi(msgID,'RAW')
        message.ranges = decodeRXMRAW(payload);
    
    % EPH MESSAGE - Ephemerides
    elseif strcmpi(msgID,'EPH')
        if ~isstruct(message.eph)
            message.eph    = ubloxstructs( 'EPH' );
        end
        [message.eph,message.dirty] = decodeAIDEPH(payload,message.eph);
        if isnan(message.eph.update)
            message.dirty=0;
        end
        
    % HUI MESSAGE - Ionosphere message
    elseif strcmpi(msgID,'HUI')
        message.iono = decodeAIDHUI(payload);
    else
    %donothing    
    end
    
    %stamp after to know previous message
    message.msgID  = msgID; 
    
end


function [ check, message ] = checksum( message )
%CHECKSUM calculates the checksum for the given data
%   This function uses the 8-Bit Fletcher Algorithm also used by TCP
%   standard.
%
%   Please note that the checksum is calculate from the CLASS field to the
%   last byte before CKACKB.
%
%   INPUT
%   MESSAGE - Decimal fields
%
%   OUTPUT
%   CKSUM - The sum of unsigned shorts
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % It accepts either row or collumn vectors
    [i,j] = size(message);
    if i>1 && j>1
        error('checksum: INPUT DATA should be a vector or row');
    end
    
    dim  = max(i,j); cka  = 0; ckb  = 0;
    txchecksum         = message(end-1:end); % Store tx checksum
    message(end-1:end) = []; dim = dim - 2;      % Remove tx checksum
    for i=1:dim
        cka = mod(cka + message(i),256);
        ckb = mod(ckb + cka,256);
    end;
    cka = mod(cka,256);
    ckb = mod(ckb,256);
    
    % Verifies if the checksum is correct
    check = txchecksum(1) == cka && txchecksum(2) == ckb;
    
    % removes the Class, ID and Paload
    message(1:4)=[];
end


       
