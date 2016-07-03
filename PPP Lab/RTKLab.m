clc
close all
clear 
clear gethandles % clears persistent handles
clear configppplab
clear workflow
clear precisepos;
clear sppdf;
clear readcustomfile;
clear storeashtech
format long g

% Delete old COM ports if any
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

fprintf('########################################################\n');
fprintf('# INSTITUTO SUPERIOR TECNICO\n');
fprintf('# INSTITUTO TELECOMUNICACOES LISBOA\n');
fprintf('# PPPLAB - Precise point positioning suite for MATLAB\n')
fprintf('# Developed by: Pedro Silva, 2012\n')
fprintf('########################################################\n\n');

% Asks for initialisation variables


sSettings  = getinput(   ...
                         'mode','online',...
                         'algo','sppdf','freqmode','L1L2');

sSettings.receiver.logtype = 'SNFILE'; 
sSettings.receiver.logging = 0;

sSettings.receiver.name = 'PROFLEX';
sSettings.receiver.com  = 'COM1';
sSettings.receiver.port = 'A';
sSettings.receiver.rate = '1';
sSettings.receiver.format = 'BIN';
sSettings.receiver.reset  = 0;
sSettings.receiver.configure  = 0;
sSettings.receiver.messages = 'SNV,MPC';
[sEpoch2, sAlgo2, sStat2] = configppplab(sSettings);
  ref  = sStat2.refpoint(1,:);
sSettings.receiver.name = 'ZXW';
sSettings.receiver.com  = 'COM9';
sSettings.receiver.port = 'A';
sSettings.receiver.rate = '1';
sSettings.receiver.format = 'BIN';
sSettings.receiver.reset  = 0;
sSettings.receiver.configure  = 0;
sSettings.receiver.messages = 'SNV,MBN';
[sEpoch1, sAlgo1, sStat1] = configppplab(sSettings);

time    = 60*60;
counter = 0;





Receivers = [sEpoch1; sEpoch2];
% ranges(1:60,1:2) = ashtechstructs('MPC');
% Gets first data - Ephs and all
disp('reading PF500');
Receivers(2).iEpoch = Receivers(2).iEpoch + 1; % does not save statistics
Receivers(2) = obtaindata( Receivers(2) );
disp('reading ZXW');
Receivers(1).iEpoch = Receivers(1).iEpoch + 1; % does not save statistics
Receivers(1) = obtaindata( Receivers(1) );


% time1 = Receivers(1).TOW;
% time2 = Receivers(2).TOW;
% if Receivers(1).TOW < Receivers(2).TOW
    skip1 = 0;
    skip2 = 0;
% elseif Receivers(1).TOW > Receivers(2).TOW
%     skip1 = 1;
%     skip2 = 0;
% end

if Receivers(1).inputpath.BytesAvailable
fread(Receivers(1).inputpath,Receivers(1).inputpath.BytesAvailable);
end
if Receivers(1).inputpath.BytesAvailable
fread(Receivers(2).inputpath,Receivers(2).inputpath.BytesAvailable);
end

% ranges = zeros(userparams('MAXSAT'),time);
single = zeros(userparams('MAXSAT'),time);
double = zeros(userparams('MAXSAT'),time);
triple = zeros(userparams('MAXSAT'),time);

Receivers(1).logging = 1;
Receivers(2).logging = 1;


clk = clock;
hour = sprintf('%02d',clk(4));
min  = sprintf('%02d',clk(5));
sec  = sprintf('%02d',round(clk(6))); 
logpath = strcat(sEpoch1.logpath,hour,min,sec,sEpoch1.receiver,date,'/');
if ~exist(logpath,'dir')
  mkdir(logpath);
  mkdir(logpath,'ion'); 
  mkdir(logpath,'eph'); 
  mkdir(logpath,'mes');
  mkdir(logpath,'raw');
end
Receivers(1).logpath=logpath;


clk = clock;
hour = sprintf('%02d',clk(4));
min  = sprintf('%02d',clk(5));
sec  = sprintf('%02d',round(clk(6))); 
logpath = strcat(sEpoch2.logpath,hour,min,sec,sEpoch2.receiver,date,'/');
if ~exist(logpath,'dir')
  mkdir(logpath);
  mkdir(logpath,'ion'); 
  mkdir(logpath,'eph'); 
  mkdir(logpath,'mes');
  mkdir(logpath,'raw');
end
Receivers(2).logpath=logpath;

while counter < time 
   % Obtain new data if online processing
  
    disp('reading ZXW');
    if ~skip1
    Receivers(1).iEpoch = Receivers(1).iEpoch + 1; % does not save statistics
    Receivers(1) = obtaindata( Receivers(1) );
    disp('reading PF500');
%     time1 = counter;
    end
    
    if ~skip2
    
    Receivers(2) = obtaindata( Receivers(2) );
%     time2 = counter;
    end
    
    % Validates entries
    if Receivers(1).TOW == Receivers(2).TOW && (~isempty(Receivers(1).TOW) || Receivers(2).TOW)
        
        disp('YES');
        
        % Saves timed info
        counter           = counter + 1;
        ranges(:,counter) = [Receivers(:).ranges];
    
        % Gets visible sats
        satids1 =  Receivers(1).getids((ranges(1,counter).CPCA ~= 0));
        satids2 =  Receivers(2).getids((ranges(2,counter).CPCA ~= 0));

        % Trims not common
        if length(satids1) < length(satids2)
            valid = satids1;
        else
            valid = satids2;
        end
        
        % Computes single difference - Difference between receivers
        single(valid,counter) = ranges(1,counter).CPCA(valid)-ranges(2,counter).CPCA(valid);

        % Obtains reference sat (highest elevation)
        satid = getreferencesat(ranges(1,counter).SATELV);
        try
        % Computes double difference - Difference between satellites
        double(valid,counter) = single(valid,counter) - single(satid,counter);
        catch
            continue
        end
        % Computes triple difference - Difference between epochs
        if counter > 1
            triple(valid,counter) = double(valid,counter) - double(valid,counter-1);
        end
        
        try
        % Compute position 1
        [ Receivers(1), sAlgo1, sStat1] = workflow( Receivers(1), sAlgo1, sStat1 );
        
        % Compute position 2
        [ Receivers(2), sAlgo2, sStat2] = workflow( Receivers(2), sAlgo2, sStat2 );
        
        % Compute vector
        vec   = eceftoenu(sAlgo2.userxyz,ref) - eceftoenu(sAlgo1.userxyz,ref); %ZXW to PROFLEX
        arrow = vec./norm(vec);
        
%         [THETA,RHO,Z] = cart2pol(vec(1),vec(2),vec(3));
%         polar(THETA,RHO);

        compass(vec(1),vec(2));

        drawnow;
        end
    end
    disp(['time at 1: ',sprintf('%d',Receivers(1).TOW)])
    disp(['time at 2: ',sprintf('%d',Receivers(2).TOW)])
    if Receivers(1).TOW < Receivers(2).TOW
        skip1 = 0;
        skip2 = 1;
        Receivers(1).iEpoch = Receivers(1).iEpoch + 1; % does not save statistics
        Receivers(2).iEpoch = Receivers(2).iEpoch; % does not save statistics
        
    elseif Receivers(1).TOW > Receivers(2).TOW
        skip1 = 1;
        skip2 = 0;
        Receivers(1).iEpoch = Receivers(1).iEpoch; % does not save statistics
        Receivers(2).iEpoch = Receivers(2).iEpoch+1; % does not save statistics
    else
        skip1 = 0;
        skip2 = 0;
        Receivers(1).iEpoch = Receivers(1).iEpoch+1; % does not save statistics
        Receivers(2).iEpoch = Receivers(2).iEpoch+1; % does not save statistics
    end
    
end

% save('RTKranges.mat','ranges')





