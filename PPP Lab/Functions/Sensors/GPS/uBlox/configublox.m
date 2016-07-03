function device = configublox( COM, varargin )
%CONFIGUBLOX configures output messages for ublox receiver
%   The function assumes default values for baud rate.
%   
%   INPUT
%   COM   - COM port in string
%   VARARGIN - Modifiers for default values
%
%   OUTPUT
%   DEVICE - Receiver's file descriptor
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    if nargin == 2
        sSettings = varargin{1};
        reset     = sSettings.receiver.reset;
        configure = sSettings.receiver.configure;
    else
        reset     = 1;
        configure = 0;    
    end

    % Obtains device file descriptor
    device = initublox(COM);
    if configure
        if reset
            if ~commandublox(device, 'RST', varargin{:})
                error('Reset failed'); 
            end    
        else
            flushinput(device);
        end
        commandublox(device,'DISABLEUBX',varargin{:});
        commandublox(device,'DISABLENMEA',varargin{:});
        if ~commandublox(device,'OUTMES',varargin{:}),
            error('Setting output messages failed'); 
        end
    end
    
end

function device = initublox( COM, varargin )
%INITUBLOX open ublox at the designated COM port
%   This functions uses the default values to establish a connection to the
%   receivers.
% 
%   INPUT
%   COM      - String with COM port to connect to
%   VARARGIN - For future scalability
%
%   OUTPUT
%   DEVICE   - A descriptor to access the receiver
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    br = 9600;      % baud rate
    db = 8;         % data bits
    p  = 'none';    % parity
    sb = 1;         % stop bits
    buffer  = userparams('receiverbuffer'); % input buffer size
    timeout = 1;    % time to wait for an operation timeout  

    device = serial(COM,'BaudRate',br,...
                   'DataBits',db,...
                   'Parity',p,...
                   'StopBits',sb,...
                   'Terminator',{'CR/LF','CR/LF'},...
                   'InputBufferSize',buffer,...
                   'Timeout',timeout,...
                   'FlowControl','none',...
                   'ByteOrder','bigEndian'); % create serial port object
    fopen(device); % connect
    disp('Cleaning buffer')
    count = 5;
    while count
        count = count - 1;
        pause(0.1);    % waits
        fread(device); % cleans buffer
    end
end