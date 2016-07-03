function device = configproflex( COM, varargin )
%CONFIGPROFLEX configures output messages for proflex receiver
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
    device = initproflex(COM);
    
    % Configure
    if configure
        if reset
            if ~commandproflex( device, 'RST', varargin{:}),
                error('Reset failed'); 
            end    
        end
        
        commandproflex( device, 'disableNMEA', varargin{:});
        commandproflex( device, 'disableATOM', varargin{:});
        commandproflex( device, 'disableRAW', varargin{:});
        
        if ~commandproflex( device, 'OUTMES', varargin{:}),
            error('Setting output messages failed'); 
        end
    end
    
    flushinput(device);
    if device.BytesAvailable
        fread(device,device.BytesAvailable);
    end

end


function [ device ] = initproflex( COM, varargin )
%INITPROFLEX contains the configuration for connecting to Pro Flex 500
%
% Pedro Silva, Instituto Superior Tecnico, January 2011

    br          = 19200;      % baud rate
    db          = 8;          % data bits
    p           = 'none';     % parity
    sb          = 1;          % stop bits
    buffer      = userparams('receiverbuffer');      % input buffer size
    timeout     = 1;          % time to wait for an operation timeout  
    flowcontrol = 'hardware'; % hardware flow control
    
    device = serial(COM,'BaudRate',br,...
                   'DataBits',db,...
                   'Parity',p,...
                   'StopBits',sb,...
                   'Terminator',{'CR/LF','CR/LF'},...
                   'InputBufferSize',buffer,...
                   'Timeout',timeout,...
                   'FlowControl',flowcontrol,...
                   'ByteOrder','bigEndian'); % create serial port object
    fopen(device); % connect
    
end