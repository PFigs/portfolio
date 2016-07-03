function succ = commandimu6dof(device, command, varargin)
%COMMANDIMU6DOF configures the IMU6DOF for wakeup and operation instructions 
%   
%   TODO
%   Operational commands ;)
%
%   Pedro Silva, Instituto Superior Tecnico, June 2012

    % To reset the receiver
    if strcmpi(command,'CFG');  
        %TODO

    % For initial initialisation
    elseif strcmpi(command,'RUN');          
        count = 0;
        succ  = 0;
        while count < 10 && ~succ
            count = count +1;
            fprintf(device,'CFG,RUN\n');
            succ = confirmcmd(device,'ACK');
        end
        assert(succ>0);
        
    % When ephemerides are needed - Poll comand
    elseif strcmpi(command,'EXT') || strcmpi(command,'STOP')
        fprintf(device,'CFG,EXT\n');
        succ = 1;
        
    % To disable a message
    elseif strcmpi(command,'CAL')
        disp('Device will be calibrated please don''t move the sensor...');
        pause(5)
        disp('3...');
        pause(1)
        disp('2...');
        pause(1)
        disp('1...');
        pause(1)
        
        count = 0;
        succ  = 0;
        while count < 10 && ~succ
            count = count +1;
            fprintf(device,'CFG,CAL\n');
            succ = confirmcmd(device,'ACK');
        end
        assert(succ>0);
        disp('Waiting for device to finish (could take a while)...');
        pause(10);
        succ = confirmcmd(device,'CAL');
        disp('Calibration is complete...');
        assert(succ>0);
        
    % Command not found
    else
       disp('Command not found...');
       succ = 0; 
    end

    
    
end


function succ = confirmcmd(device,tocheck)

    discard = 0;
    succ    = 1;
    exit    = 0;
    count   = 0;
    nbytes  = numel(tocheck);
    while 1 && ~exit

        if device.BytesAvailable
            discard = fread(device,1,'char');
            char(discard)
        else
            count = count +1;
            if count > 3
                succ = 0;
                exit = 1;
                break;
            end 
            pause(0.1);
            continue;
        end
        
        if discard == 36
            count = 0;
            while device.BytesAvailable < nbytes
                count = count +1;
                if count > 100
                    succ = 0;
                    exit = 1;
                    break;
                end
                pause(0.1);
            end;
            discard = char(fread(device,nbytes+1,'char'));
            succ = strncmpi(discard',tocheck,nbytes);
            break;
        end
    end
   
%         while 1 && ~exit
% 
%         if device.UserData.isNew==1
%             discard = device.UserData.newData';
%             device.UserData.isNew = 0;
%         else
%             count = count +1;
%             if count > 3
%                 succ = 0;
%                 exit = 1;
%                 break;
%             end 
%             pause(0.5);
%             continue;
%         end
%         succ = strfind(char(discard),tocheck);
%         if isempty(succ)
%             succ = 0;
%         else
%             break;
%         end
%         end
        
        
end

