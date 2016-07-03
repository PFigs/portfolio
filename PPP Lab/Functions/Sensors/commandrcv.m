function succ = commandrcv( COM, receiver, command, varargin )
%COMMANDRCV queries and sets commands to the RECEIVER
%   This function provides an abstraction to send a defined COMMAND to any
%   given RECEIVER. The RECEIVER is identified by its name and its file
%   descritor COM.
%
%   INPUT
%   COM - File descriptor
%   RECEIVER - Receiver identifier, eg, ZXW, UBLOX, PROFLEX, ...
%   COMMAND  - Command identifier, eg, RST, OUT, ...
%   VARARGIN - Necessary arguments in acordance with COMMAND
%
%   OUTPUT
%   SUCC - 0 in case of error 1 otherwise
%
%   NOTE:
%   To change any implementation or add new messages please check the
%   receiver specific folder for its commandrcv implementation
%
% Pedro Silva, Instituto Superior Tecnico, January 2011
    
    % decides which function to call
    if strcmpi(receiver,'AC12')
        succ = commandac12(COM, command, varargin{:});
    elseif strcmpi(receiver,'ZXW') 
        succ = commandzxw(COM, command, varargin{:});
    elseif strcmpi(receiver,'PROFLEX')
        succ = commandproflex(COM, command, varargin{:});
    elseif strcmpi(receiver,'UBLOX') 
        succ = commandublox(COM, command, varargin{:});
    elseif strcmpi(receiver,'6dof') || strcmpi(receiver,'IMU6dof')
        succ = commandimu6dof(COM, command, varargin{:});
    else
        disp('COMMAND:commandrcv: Receiver not implemented'); 
        succ = 0;
    end
    
end

