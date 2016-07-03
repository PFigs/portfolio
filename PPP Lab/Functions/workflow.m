function [ sEpoch, sAlgo, sStat ] = workflow( sEpoch, sAlgo, sStat, sSettings)
%PROCESSGPS retrieves and processes GPS data as well as retrieving IMU data

    % Obtain new data if online processing
    if sEpoch.operation
        sEpoch.iEpoch = sEpoch.iEpoch+1; % does not save statistics
        sEpoch = obtaindata( sEpoch );
    else
        if strcmpi(sEpoch.receiver,'SNFILE') || strcmpi(sEpoch.receiver,'RINEX')
            sEpoch.iEpoch = sEpoch.iEpoch + 1; % Epoch counter
            sEpoch.TOW    = sEpoch.ranges.TOW(sEpoch.iEpoch);
            sEpoch.WD     = towtoweekday(sEpoch.ranges.TOW(sEpoch.iEpoch));    
%             sEpoch        = chooseeph( sEpoch );
        elseif strcmpi(sEpoch.receiver,'BINFILE')
            sEpoch.iEpoch = sEpoch.iEpoch + 1; % Epoch counter
%             try
            sEpoch        = obtaindata( sEpoch );
%             catch exceptioneof 
                
%                 outputexception(exceptioneof);
%                 sEpoch.nbEpoch = -1; % Forces cycle termination
                
%            end
        end
    end
%    
    % Process GPS data 
    if sSettings.IMU.useimu && sEpoch.operation, tic; end;
    [sEpoch,sAlgo,sStat] = processgnss( sEpoch, sAlgo, sStat );
    if sSettings.IMU.useimu && sEpoch.operation
        sEpoch = processimu( sEpoch, sSettings );
        if sSettings.displaymode == -2
            fprintf('VEL@IMU:');fprintf(' %d ',sEpoch.IMU.velocity);fprintf('\n');
            fprintf('POS@IMU:');fprintf(' %d ',sEpoch.IMU.position);fprintf('\n');
        end
    end
    
    if  sSettings.IMU.useimu && ~sEpoch.operation
        
        ln = sEpoch.IMU.data(sEpoch.IMU.data(:,1) == sEpoch.TOW+1,:);
        if ~isempty(ln)
            sEpoch.IMU.velocity = ln(2:4);
            sEpoch.IMU.position = ln(5:end);
        end
        
        if sum(sEpoch.IMU.position)~=0 || sum(sEpoch.IMU.velocity)~=0
            sEpoch.IMU.velocity
            sEpoch.IMU.position
        end
    end
    
    % Display cmd line information
    updatedisplay(sEpoch.iEpoch,sEpoch.TOW,sAlgo,sStat,sSettings.displaymode);
    
%     sEpoch.tosave.imu{sEpoch.iEpoch} = sEpoch.IMU;
%     sEpoch.tosave.gps{sEpoch.iEpoch} = {sEpoch.ranges,sEpoch.eph};
    
    
end

