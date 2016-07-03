function header = syncashtech( device, varargin )
%SYNCASHTECH looks for the next message start
%   
%   INPUT
%   DEVICE   - File descriptor to access device
%   VARARGIN - headersize modifier
%
%   OUTPUT
%   HEADER   - The message header that was read
%
%   header = syncashtech( device, varargin )
%
%   Pedro Silva, Instituto Superior Tecnico, January 2012
%   Last revision: March 2012
    
    % Check whats the value of the header to read
    msgtag     = 36;%'$';       % what indicates a message start
    msgchk     = 'PASHR,';  % what confirms an answer start
    headersize = 4;         % default value
    
    % Computes minimun lengths
    lmsgtag    = length(msgtag);
    lmsgchk    = length(msgchk);
    untilbytes = lmsgtag+lmsgchk+headersize;
    
    if nargin == 2
        headersize = varargin{1};
        untilbytes = headersize;
    end

    while 1
        % Waits for bytes to be availabe 
        while device.BytesAvailable < untilbytes, end
        
        % Discards data until first message is found and is an answer
        discard = 0;
        count = 0;
        try
        while discard ~= msgtag || count == 0 
%             [discard, count] = fscanf(device,'%c',lmsgtag);
            [discard, count] = fread(device,lmsgtag,'uchar');
        end
        catch
            header = NaN;
            return
        end

        % Waits for the buffer to fill
        while device.BytesAvailable < untilbytes, end
        
        % Confirms if it really is a message
        count = 0;
        while count ~= lmsgchk 
            [discard, count] = fscanf(device,'%c',lmsgchk);
        end
        if strcmpi(discard, msgchk), break; end

    end
    
    % Reads message ID
    header = fscanf(device,'%c',headersize); 

end

