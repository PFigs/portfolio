% clear all
savebreakpoints;
close all
clear all
load('savedreakpoints');
dbstop(breakpoints);
format long g
clc
try
fclose(instrfind);
delete(instrfind)
end
COM = 'COM11';
format long g
IMU.velocity  = zeros(3,1);
IMU.position  = zeros(3,1);
IMU.operation = 1;
IMU.receiver  = 'IMU6DoF';
IMU.rate      = 0.01;
IMU.grange    = 'scale2g';
device        = configimu6dof(COM);

IMU.epoch = 0;


% Device is open read serial and print


fig1 = figure;
fig1 = axes('Parent',fig1);
hold(fig1,'on');
set(fig1,'DrawMode','fast');

% fig2 = figure;
% fig3 = figure;

% fig2 = axes('Parent',fig2);
% fig3 = axes('Parent',fig3);

% hold(fig2,'on');
% hold(fig3,'on');


% set(fig2,'DrawMode','fast');
% set(fig3,'DrawMode','fast');
% N = 0;
% limx = 250;
% xlim(fig1,[limx*N limx*(N+1)]);
% xlim(fig2,[limx*N limx*(N+1)]);
% xlim(fig3,[limx*N limx*(N+1)]);
% ylim(fig1,[-500 500]);
% ylim(fig2,[-500 500]);
% ylim(fig3,[-500 500]);


commandrcv(device,IMU.receiver,'CAL');
commandrcv(device,IMU.receiver,'RUN');   
% device.BytesAvailableFcnCount = 25;
IMU.windowANGLEACC   = zeros(3,100); %100 epoch window
IMU.REst             = zeros(3,100); %100 epoch window
IMU.Axz              = zeros(3,100); %100 epoch window
IMU.Ayz              = zeros(3,100); %100 epoch window

IMU.RealAcc          = zeros(3,100); %100 epoch window

    IMU.windowACC        = zeros(3,100); %100 epoch window
    IMU.windowGYR        = zeros(4,100); %100 epoch window
    IMU.windowMAG        = zeros(3,100); %100 epoch window 
    IMU.windowVEL        = zeros(3,100); %100 epoch window 
    IMU.windowPOS        = zeros(3,100); %100 epoch window 
    IMU.position         = [0;0;0]; 

count   = 1;
elapsed = 0;
countCAzeros = 1;

while count < 500
   IMU = readimu(device,IMU); 
   count = count +1;
end


while count < 100000
%     IMU.windowACC        = zeros(3,100); %100 epoch window
%     IMU.windowGYR        = zeros(4,100); %100 epoch window
%     IMU.windowMAG        = zeros(3,100); %100 epoch window 
%     IMU.windowVEL        = zeros(3,100); %100 epoch window 
%     IMU.windowPOS        = zeros(3,100); %100 epoch window 
%     IMU.position         = [0;0;0]; 
    tic
    while elapsed <= 1
        IMU = readimu(device,IMU);
        if all(abs(IMU.windowACC(:,end))<=0.5)
            if countCAzeros > 2
                IMU.windowVEL = zeros(3,100);
                IMU.windowACC = zeros(3,100); %100 epoch window
                IMU.windowGYR = zeros(4,100); %100 epoch window
                IMU.windowMAG = zeros(3,100); %100 epoch window 
                IMU.windowVEL = zeros(3,100); %100 epoch window 
                IMU.windowPOS = zeros(3,100); %100 epoch window 
                IMU.velocity  =  [0;0;0]; 
                countCAzeros  = 1
            end
            countCAzeros = countCAzeros +1;
        else
                IMU = getvelocity(IMU);
                IMU = getposition(IMU);
                
        end
        
        pause(0.005);
        elapsed = elapsed + toc;
    end
    elapsed = 0;
    count   = count +1;
    
    % reset velocity if zero movement for a while
    vnow  = IMU.windowVEL(1,end-4:end);
    if sum(vnow)
        IMU.velocity(1) = IMU.velocity(1) + IMU.windowVEL(1,end);
        IMU.position(1) = IMU.position(1) + IMU.windowPOS(1,end);
    else
        IMU.velocity(1) = 0; 
%         IMU.position(1) = 0;   -- Position will be cleaned in the next
%         epoch
    end

    vnow  = IMU.windowVEL(2,end-4:end);
    if sum(vnow)
        IMU.velocity(2) = IMU.velocity(2) + IMU.windowVEL(2,end);
        IMU.position(2) = IMU.position(2) + IMU.windowPOS(2,end);
    else
        IMU.velocity(2) = 0; 
    end

    vnow  = IMU.windowVEL(3,end-4:end);
    if sum(vnow)
        IMU.velocity(3) = IMU.velocity(3) + IMU.windowVEL(3,end);
        IMU.position(3) = IMU.position(3) + IMU.windowPOS(3,end);
    else
        IMU.velocity(3) = 0;
    end
    
    
%     plot(fig2,count,sqrt(IMU.windowACC(1)^2+IMU.windowACC(2)^2+IMU.windowACC(3)^2));
% plot(fig2,count,IMU.windowACC(1));
%     plot3(IMU.position(1),IMU.position(2),IMU.position(3));
disp('ACC')
disp([IMU.windowACC(1),IMU.windowACC(2),IMU.windowACC(3)]);
disp('VEL')
 disp([IMU.velocity(1),IMU.velocity(2),IMU.velocity(3)]);
    plot(fig1,IMU.position(1),IMU.position(2),'.b');
    drawnow;
 disp('.');
%     disp(IMU.position(1));
end

