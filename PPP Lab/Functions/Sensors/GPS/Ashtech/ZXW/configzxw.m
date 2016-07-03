function device = configzxw( COM, varargin )
%CONFIGZXW configures output messages for zxw receiver
%   The function assumes default values for baud rate.
%   Please refer to ZXW reference manual for further assistance.
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
    device = initzxw(COM);

    % Configure
    if configure
        if reset
            if ~commandzxw( device, 'RST', varargin{:}),
                error('Reset failed'); 
            end    
        end

        if ~commandzxw( device, 'OUTMES', varargin{:}),
            error('Setting output messages failed'); 
        end
    end
    
    flushinput(device);
    if device.BytesAvailable
        fread(device,device.BytesAvailable);
    end

end

function [ device ] = initzxw( COM, varargin )
%INITZXW initialises communications with the ZXW receiver
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

end