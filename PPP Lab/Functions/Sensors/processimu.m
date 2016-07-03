function [ sEpoch ] = processimu( sEpoch, sSettings )
%PROCESSIMU Summary of this function goes here
%   Detailed explanation goes here
        
    %Clean previous window
    sEpoch.IMU.windowACC = zeros(3,100); %100 epoch window
    sEpoch.IMU.windowGYR = zeros(4,100); %100 epoch window
    sEpoch.IMU.windowVEL = zeros(3,100); %100 epoch window
    sEpoch.IMU.windowPOS = zeros(3,100); %100 epoch window
    sEpoch.IMU.windowACC(:,end) = 0;
    sEpoch.IMU.windowGYR(:,end) = 0;
    sEpoch.IMU.windowVEL(:,end) = 0;
    sEpoch.IMU.windowPOS(:,end) = 0;
    sEpoch.IMU.position(:,:)    = 0;

    % Reads at least one so that it can be used in gps positioning
    %%% Obtain data from IMU for the remainder of the time
    if sEpoch.IMU.iniflag == 1
        sEpoch.IMU.iniflag = 0;
        commandrcv(sEpoch.IMU.inputpath,sEpoch.IMU.receiver,'RUN');
    end
    sEpoch.IMU = obtaindata( sEpoch.IMU ); %Retrieve IMU data
    sEpoch.IMU = getvelocity(sEpoch.IMU);
    sEpoch.IMU = getposition(sEpoch.IMU);
    
    vnow    = 0;
    elapsed = sSettings.receiver.rate-toc;
%     fprintf('zing\n')
    while elapsed > 0.01
        tic;
%         fprintf('Retrieving imu data\n')
        if sEpoch.IMU.iniflag == 1
            sEpoch.IMU.iniflag = 0;
            commandrcv(sEpoch.IMU.inputpath,sEpoch.IMU.receiver,'RUN');
        end
        sEpoch.IMU = obtaindata( sEpoch.IMU ); %Retrieve IMU data
        if all(abs(sEpoch.IMU.windowACC(:,end))<=0.11)
            sEpoch.IMU.windowACC = zeros(3,100); %100 epoch window
            sEpoch.IMU.windowGYR = zeros(4,100); %100 epoch window
            sEpoch.IMU.windowVEL = zeros(3,100); %100 epoch window
            sEpoch.IMU.windowPOS = zeros(3,100); %100 epoch window
            sEpoch.IMU.windowACC(:,end) = 0;
            sEpoch.IMU.windowGYR(:,end) = 0;
            sEpoch.IMU.windowVEL(:,end) = 0;
            sEpoch.IMU.windowPOS(:,end) = 0;
            sEpoch.IMU.velocity =  [0;0;0]; 
        else
            sEpoch.IMU = getvelocity(sEpoch.IMU);
            sEpoch.IMU = getposition(sEpoch.IMU);
        end
        tosleep = toc;
        tic;
        pause(0.01-tosleep);
        elapsed = elapsed - toc;
    end

    % reset velocity if zero velocity for a while
    vnow  = sum(sEpoch.IMU.windowVEL(1,end-4:end));
    if vnow
        sEpoch.IMU.velocity(1) = sEpoch.IMU.velocity(1) + sEpoch.IMU.windowVEL(1,end);
        sEpoch.IMU.position(1) = sEpoch.IMU.position(1) + sEpoch.IMU.windowPOS(1,end);
    else
        sEpoch.IMU.velocity(1) = 0; 
    end

    vnow  = sum(sEpoch.IMU.windowVEL(2,end-4:end));
    if vnow
        sEpoch.IMU.velocity(2) = sEpoch.IMU.velocity(2) + sEpoch.IMU.windowVEL(2,end);
        sEpoch.IMU.position(2) = sEpoch.IMU.position(2) + sEpoch.IMU.windowPOS(2,end);
    else
        sEpoch.IMU.velocity(2) = 0; 
    end

    vnow  = sum(sEpoch.IMU.windowVEL(3,end-4:end));
    if vnow
        sEpoch.IMU.velocity(3) = sEpoch.IMU.velocity(3) + sEpoch.IMU.windowVEL(3,end);
        sEpoch.IMU.position(3) = sEpoch.IMU.position(3) + sEpoch.IMU.windowPOS(3,end);
    else
        sEpoch.IMU.velocity(3) = 0;
    end

    storeimu(sEpoch.IMU,sEpoch.TOW);

end

