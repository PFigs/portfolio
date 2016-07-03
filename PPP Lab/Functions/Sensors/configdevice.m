function [ device ] = configdevice( COM, receiver, varargin )
%CONFIGDEVICE serves as an abstraction to configure the target receiver
%   The function describes in a broad sense what is done to configure the
%   target device, allowing for changing easily the configuration steps if
%   needed.
%
%   Default values for messages and output rates can be overriden by:
%       'PORT', value
%       'MESSAGES', value
%       'RATE', value
%       'FORMAT', value
%
%   INPUT
%   COM      - String with COM port
%   Receiver - Name/type of receiver
%   RST      - Reset switcher
%
%   OUTPUT
%   DEVICE - FD for accessing device
%
%   Pedro Silva, Instituto Superior Tecnico, 2011
  
    % Initialise
    if strcmpi(receiver,'ZXW')
        device = configzxw(COM,varargin{:});
    elseif strcmpi(receiver,'PROFLEX')
        device = configproflex(COM,varargin{:});
    elseif strcmpi(receiver,'UBLOX')
        device = configublox(COM,varargin{:});
    elseif strcmpi(receiver,'AC12')
        device = configac12(COM,varargin{:});
    elseif strcmpi(receiver,'BINFILE')
        device = configbinfile(COM,varargin{:});
    elseif strcmpi(receiver,'6DOF') || strcmpi(receiver,'IMU6DOF')
        device = configimu6dof(COM,varargin{:});
    else
        disp('Unknown device');
    end
    
end

