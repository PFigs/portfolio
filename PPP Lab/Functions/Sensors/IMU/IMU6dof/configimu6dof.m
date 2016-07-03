function device = configimu6dof(COM, varargin)
%CONFIGIMU6DOF opens and prepares the IMU for operation
%   The function returns a file descriptor to obtain data from the IMU
%   
%   INPUT
%   INPUTPATH - Contains the path to the binary file
%   VARARGIN  - Modifiers for default values
%
%   OUTPUT
%   BINFILE - Returns the binary file
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    

    br = 9600;      % baud rate
    db = 8;         % data bits
    p  = 'none';    % parity
    sb = 1;         % stop bits
    buffer  = 1000;   % input buffer size
    timeout = 0.2;    % time to wait for an operation timeout  

    device = serial(COM,'BaudRate',br,...
                   'DataBits',db,...
                   'Parity',p,...
                   'StopBits',sb,...
                   'Terminator',{'LF','LF'},...
                   'InputBufferSize',buffer,...
                   'Timeout',timeout,...
                   'FlowControl','none',...
                   'ReadAsyncMode','continuous',...
                   'ByteOrder','bigEndian'); % create serial port object
%     device.ReadAsyncMode = 'continuous';
%     device.BytesAvailableFcnMode = 'byte';
%     device.BytesAvailableFcnCount = 4;
%     device.UserData.newData=[];
%     device.UserData.isNew=0;
%     device.BytesAvailableFcn = {@getNewData};
    fopen(device); % connect
    disp('IMU 6DOF warming up, please wait...');
    pause(10);
    disp('IMU is now available...');

end


% Data Processing Function
function getNewData(obj,event,arg1)
% GETNEWDATA processes data that arrives at the serial port.
%  GETNEWDATA is the "BytesAvailableFcn" for the serial port object, so it
%  is called automatically when BytesAvailableFcnCount bytes of data have
%  been received at the serial port.

% Read the data from the port.
% For binary data, use fread. You will have to supply the number of bytes
%  to read and the format for the data. See the MATLAB documentation.
% For ASCII data, you might still use fread with format of 'char', so that
%  you do not have to handle the termination characters.
[Dnew, Dcount, Dmsg]=fread(obj);

% You can do some initial processing of the data here in this function. 
%  However, I recommend keeping  processing here to a minimum and doing
%  most of the work in the main loop for best performance.

% Return the data to the main loop for plotting/processing
if Dcount
    if obj.UserData.isNew==0
        % indicate that we have new data
        obj.UserData.isNew=1; 
        obj.UserData.newData=Dnew;
    else
        % If the main loop has not had a chance to process the previous batch
        % of data, then append this new data to the previous "new" data
        obj.UserData.newData=[obj.UserData.newData; Dnew];
    end
    pause(0.01)
    disp('checking for data');
end
end