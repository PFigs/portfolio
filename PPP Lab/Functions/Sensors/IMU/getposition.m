function IMU = getposition(IMU)

    % position in X
    if isnan(IMU.windowVEL(1,end-1))
        position = 0;
    else        
        position = IMU.windowPOS(1,end) ...
                 + inttrap(IMU.windowVEL(1,end:-1:end-1),IMU.rate); 
    end
    IMU.windowPOS(1,:) = insertsl( position, IMU.windowPOS(1,:), 1 );
    
    % position on Y
    if isnan(IMU.windowVEL(2,end-1))
        position = 0;
    else
        position = IMU.windowPOS(2,end) ...
                 + inttrap(IMU.windowVEL(2,end:-1:end-1),IMU.rate); 
    end    
    IMU.windowPOS(2,:) = insertsl( position, IMU.windowPOS(2,:), 1 );    
    
    % position on Z
    if isnan(IMU.windowVEL(3,end-1))
        position = 0;
    else
        position = IMU.windowPOS(3,end) ...
                 + inttrap(IMU.windowVEL(3,end:-1:end-1),IMU.rate); 
    end        
    IMU.windowPOS(3,:) = insertsl( position, IMU.windowPOS(3,:), 1 );


end