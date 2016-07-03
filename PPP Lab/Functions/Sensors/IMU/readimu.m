function IMU = readimu(device,IMU)
%READIMU retrieves information from the IMU
%
%   Pedro Silva, Instituto Superior Tecnico, June 2012
    TH       = 0.1;
    headerH  = 255;
    headerL  = 181;
    k        = 1;
    message  = [];
    accscale = adxl345params(IMU.grange)*earthparams('gforce');
    
    % Read buffer
%     while 1
%         if device.UserData.isNew==1
%             message = device.UserData.newData;
%             device.UserData.isNew = 0;
%             break;
%         end
%     end
    
    while device.BytesAvailable   
        message = [message; uint8(fread(device,device.BytesAvailable))];
    end
    
    % Search for header start and delete buffer
    while ~isempty(message) || numel(message) > 6
        % finds the header
        if message(k) == headerH;
            message(k) = [];    
            if ~isempty(message) 
                if message(k) == headerL; 
                    message(k) = [];

                    % FREE IMU - G Values
                    if numel(message) > 15 && message(k) == 3
                        x = r4(message(k+1:k+4))*earthparams('gforce');  % X
                        y = r4(message(k+5:k+8))*earthparams('gforce');  % Y
                        z = r4(message(k+9:k+12))*earthparams('gforce'); % Z
%                         assert(~isnan(x))
%                         assert(~isnan(y))
%                         assert(~isnan(z))
                        IMU.windowACC = insertsl([x;y;z],IMU.windowACC,1);
                    
                        
                    % ACCELOMETER
                    % Do not set th it will be worse
                    elseif numel(message) > 7 && message(k) == 0 
                        IMU.windowACC        = shiftwindow(IMU.windowACC,1);
                        IMU.windowACC(1,end) = i2(message(k+1:k+2),'bigendian')*accscale;  % X
                        IMU.windowACC(2,end) = i2(message(k+3:k+4),'bigendian')*accscale;  % Y
                        IMU.windowACC(3,end) = (255-i2(message(k+5:k+6),'bigendian'))*accscale;  % Z
                        message(1:k+7) = [];  % identifier and EOMSG

                        
                    % GYROSCOPE
                    elseif numel(message) > 9 && message(k) == 1
                        IMU.windowGYR        = shiftwindow(IMU.windowGYR,1);
                        IMU.windowGYR(1,end) = i2(message(k+3:k+4),'bigendian');  % X
                        IMU.windowGYR(2,end) = i2(message(k+5:k+6),'bigendian');  % Y
                        IMU.windowGYR(3,end) = i2(message(k+7:k+8),'bigendian');  % Z 
                        IMU.windowGYR(4,end) = i2(message(k+1:k+2),'bigendian');  % Temperature
                        message(1:k+9) = []; % identifier and EOMSG

                    % MAGNETOMETER
                    elseif numel(message) > 7 && message(k) == 2
                        message(1:k+7) = [];  % identifier and EOMSG
                    end

                else
                    message(k) = [];
                end
            end
        else
           message(k) = []; 
        end
    end
    
end

