function device = configAC12( COM, varargin )
%CONFIGAC12 configures output messages for ac12 receiver
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
    device = initac12(COM);

    % Configure
    if configure
        if reset
            if ~commandac12( device, 'RST', varargin{:}),
                error('Reset failed'); 
            end    
        else
            flushinput(device);
        end

        if ~commandac12( device, 'OUTMES', varargin{:}),
            error('Setting output messages failed'); 
        end
    end

end

function device  = initac12( COM, varargin )
%INITAC12 initialises communications with the AC12 receiver
%   This function returns a file descriptor to access the receiver
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
