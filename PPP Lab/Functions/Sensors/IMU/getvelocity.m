function IMU = getvelocity(IMU)
%GETVELOCITY computes the IMU velocity integrating the acceleration

    % Velocity in X
    if isnan(IMU.windowACC(1,end-1))
        velocity = 0;
    else
        velocity = IMU.windowVEL(1,end) ...
                 + inttrap(IMU.windowACC(1,end:-1:end-1),IMU.rate);
        if abs(velocity) < 0.1
            velocity = 0;
        end
    end
    IMU.windowVEL(1,:) = insertsl( velocity, IMU.windowVEL(1,:), 1 );
    
    % Velocity on Y
    if isnan(IMU.windowACC(2,end-1))
        velocity = 0;        
    else
        velocity = IMU.windowVEL(2,end) ...
                 + inttrap(IMU.windowACC(2,end:-1:end-1),IMU.rate);
        if abs(velocity) < 0.1
            velocity = 0;
        end
    end
    IMU.windowVEL(2,:) = insertsl( velocity, IMU.windowVEL(2,:), 1 );    
    
    % Velocity on Z
    if isnan(IMU.windowACC(3,end-1))
        velocity = 0;
    else
        velocity = IMU.windowVEL(3,end) ...
                 + inttrap(IMU.windowACC(3,end:-1:end-1),IMU.rate);
        if abs(velocity) < 0.1
            velocity = 0;
        end
    end
    IMU.windowVEL(3,:) = insertsl( velocity, IMU.windowVEL(3,:), 1 );    
    
end
