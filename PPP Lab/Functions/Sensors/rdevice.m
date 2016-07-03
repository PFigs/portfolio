function sEpoch = rdevice( device, sEpoch )
%RDEVICE is an abstraction from the receiver/brand specific functions
%
%   Any future device should be implemented using the following primitives
%   function message  = read<device name>(device,message)
%   function message  = identifymsg( device, msgID, message )
%   function previous = acquire( device, msgID, datalength, previous, cksumtype )
%   function message  = parsemsg( msgID, payload, message )
%   function [ check, message ] = checksum( message, checktype )
%
%   INPUT
%   DEVICE  - FD for device access
%   MESSAGE - Structure to keep known data 
%
%   OUTPUT
%   MESSAGE - Parsed data updated
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    
    if strcmpi(sEpoch.receiver,'ZXW')
        sEpoch = readashtech(device, sEpoch);
    
    elseif strcmpi(sEpoch.receiver,'PROFLEX')
        sEpoch = readashtech(device, sEpoch);
    
    elseif strcmpi(sEpoch.receiver,'AC12')
        sEpoch = readashtech(device, sEpoch);
    
    elseif strcmpi(sEpoch.receiver,'UBLOX')
        sEpoch = readublox(device, sEpoch);
    
    elseif strncmpi(sEpoch.receiver,'IMU',3) || strcmpi(sEpoch.receiver,'6dof')
        sEpoch = readimu(device,sEpoch);
        
    elseif strcmpi(sEpoch.receiver,'BINFILE')
        sEpoch.sfile     = device;
        sEpoch           = readbinfile(sEpoch);
        sEpoch.inputpath = sEpoch.sfile; % To improve
    else
        error('rdevice: Not implemented');
        
    end    

end




