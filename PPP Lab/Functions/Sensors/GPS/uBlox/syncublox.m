function header = syncublox( device )
%SYNCUBLOX looks for the next message start
%   
%   INPUT
%   DEVICE   - File descriptor to access device
%
%   OUTPUT
%   HEADER   - The message header that was read
%
%   header = syncublox( device )
%
%   Pedro Silva, Instituto Superior Tecnico, January 2012
%   Last revision: March 2012

    % Default values
    msgtag     = 181;
    headersize = 4;
    msgchk     = 98;
    
    % Computes minimun lengths
    lmsgtag    = length(msgtag);
    lmsgchk    = length(msgchk);
    waitfor    = lmsgtag+lmsgchk+headersize;
    
    % Waits for bytes to be availabe (pause to minimize CPU polling)
    while 1
        % Waits for bytes to be availabe 
        while device.BytesAvailable < waitfor, end
        
        % Searches for message start
        discard = 0;
        while discard ~= msgtag
            discard = fread(device,lmsgtag,'uint8');
%             fprintf('%c ',discard);
        end

        % Waits for the buffer to fill
        while device.BytesAvailable < waitfor, end
        
        % Confirms if it really is a message
        count = 0;
        while count ~= lmsgchk
            [discard, count] = fread(device,lmsgchk,'uint8');
        end
        if discard == msgchk, break; end   
        
    end
    
    % Reads message ID
    header = fread(device,headersize,'uint8'); 

end

