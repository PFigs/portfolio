% PPP LAB
%   Script used to develop the global workflow of the algorithms. 
%   
%   Please note that the program uses persistent variables controled by the   
%   function RXPARAM. The variables can be access in a global manner but
%   are managed through it to avoid name collisions.
%   
% Pedro Silva, Instituto Superior Tecnico, 2011


% #TODO
% When saving keep date constant for leap days
% CHECK OBTAIN DATA FOR BIN FILE
% RESET filter

% UNB ZPD
% aw = interp1(sAlgo.unbvmf(:,2)',sAlgo.unbvmf(:,3)',180+9.1385);
% ah = interp1(sAlgo.unbvmf(:,2)',sAlgo.unbvmf(:,4)',180+9.1385);
% dry = interp1(sAlgo.unbvmf(:,2)',sAlgo.unbvmf(:,5)',180+9.1385);
% wet = interp1(sAlgo.unbvmf(:,2)',sAlgo.unbvmf(:,6)',180+9.1385);
% [vmf1h,vmf1w] = vmf1(ah,aw,DOY,dlat,zd);
% zpd = dry.*vmf1h + wet.*vmf1w;
% 
% unbzenithdelay(sAlgo.lla,satelv,DOY)


%TODO run with other samples
smoothvec = [0 0 0 0];  % smoothing
antexvec  = [1 1 1 1];  % antex
csvec     = [0 1 1 0];  % cycle slips
datagapvec = [0 1 0 1]; % data regen 

obsrange = [{'L15L20'}];

%{'horizons_results17April.txt'},{'horizons_results17April.txt'},{'horizons_results17April.txt'},...
%{'Aquisition/17Apr2012ALL/'},{'Aquisition/17Apr2012ALL/'},{'Aquisition/17Apr2012ALL/'},...
% inputpath   = [{'Aquisition/170914proflex03-Aug-2012/'},{'Aquisition/170914proflex03-Aug-2012/'},{'Aquisition/170914proflex03-Aug-2012/'},{'Aquisition/170914proflex03-Aug-2012/'},{'Aquisition/170914proflex03-Aug-2012/'},{'Aquisition/170914proflex03-Aug-2012/'},{'Aquisition/170914proflex03-Aug-2012/'}];
horizonstxt = [{'horizons_results03August-2.txt'},{'horizons_results03August-2.txt'},{'horizons_results03August-2.txt'},{'horizons_results03August-2.txt'}];


% obsrange    = {'WED-TEST-'};
% inputpath   = {'Aquisition/17Apr2012ALL/'};
inputpath   = {'Aquisition/170914proflex03-Aug-2012/'};
    

% inputpath   = {'Aquisition/17Apr2012ALL/'};

% horizonstxt = [];

upper = 5250;
lower = 250;
% fprintf('%d run with cs correction\n',upper);
torun=...
[...
% 

% 
% [{'spp'},{'L1'},{'broadcast'},{'broadcast'},{lower},{upper}];
% [{'spp'},{'L1'},{'igs'},{'broadcast'},{lower},{upper}];
% [{'spp'},{'L1'},{'gmv'},{'gmv'},{lower},{upper}];
% [{'spp'},{'L1'},{'igr'},{'broadcast'},{lower},{upper}];
% [{'spp'},{'L1'},{'igu'},{'broadcast'},{lower},{upper}];%5
% [{'spp'},{'L1'},{'igr'},{'igr'},{lower},{upper}];
% [{'spp'},{'L1'},{'igu'},{'igu'},{lower},{upper}];%5
% [{'spp'},{'L1'},{'best'},{'best'},{lower},{upper}]; 


% [{'spp'},{'L1L2'},{'broadcast'},{'broadcast'},{lower},{upper}];
% [{'spp'},{'L1L2'},{'igs'},{'broadcast'},{lower},{upper}];
% [{'spp'},{'L1L2'},{'gmv'},{'gmv'},{lower},{upper}];
% [{'spp'},{'L1L2'},{'igr'},{'broadcast'},{lower},{upper}];%10
% [{'spp'},{'L1L2'},{'igu'},{'broadcast'},{lower},{upper}];
% % 
% [{'spp'},{'L1L2'},{'best'},{'best'},{lower},{upper}];
% [{'spp'},{'L1L2'},{'igr'},{'igr'},{lower},{upper}];%10
% [{'spp'},{'L1L2'},{'igu'},{'igu'},{lower},{upper}];
% 
% [{'sppdf'},{'L1L2'},{'best'},{'best'},{lower},{upper}];
% [{'sppdf'},{'L1L2'},{'broadcast'},{'broadcast'},{lower},{upper}];
% [{'sppdf'},{'L1L2'},{'best'},{'broadcast'},{lower},{upper}];
% [{'sppdf'},{'L1L2'},{'gmv'},{'gmv'},{lower},{upper}];%15
% 
% [{'sppkalman'},{'L1'},{'best'},{'broadcast'},{lower},{upper}]; %20


% [{'recursivels'},{'L1L2'},{'igu'},{'broadcast'},{lower},{upper}];
% [{'recursivels'},{'L1L2'},{'gmv'},{'gmv'},{lower},{upper}];
% [{'recursivels'},{'L1L2'},{'best'},{'broadcast'},{lower},{upper}]; %20
% [{'recursivels'},{'L1L2'},{'best'},{'best'},{lower},{upper}]; %20
% [{'recursivels'},{'L1L2'},{'broadcast'},{'broadcast'},{lower},{upper}];


% [{'pppkouba'},{'L1L2'},{'igu'},{'broadcast'},{lower},{upper}];
% [{'pppkouba'},{'L1L2'},{'gmv'},{'gmv'},{lower},{upper}];
% [{'pppkouba'},{'L1L2'},{'best'},{'broadcast'},{lower},{upper}];
% [{'pppkouba'},{'L1L2'},{'best'},{'best'},{lower},{upper}];
% [{'pppkouba'},{'L1L2'},{'broadcast'},{'broadcast'},{lower},{upper}];


% [{'pppkalman'},{'L1L2'},{'igu'},{'broadcast'},{lower},{upper}];
% [{'pppkalman'},{'L1L2'},{'gmv'},{'gmv'},{lower},{upper}];
% [{'pppkalman'},{'L1L2'},{'broadcast'},{'broadcast'},{lower},{upper}];
% [{'pppkalman'},{'L1L2'},{'best'},{'broadcast'},{lower},{upper}]; %20
[{'pppkalman'},{'L1L2'},{'best'},{'best'},{lower},{upper}]; %20
% 
% [{'pppgao'},{'L1L2'},{'gmv'},{'gmv'},{lower},{upper}];
% [{'pppgao'},{'L1L2'},{'best'},{'broadcast'},{lower},{upper}];
% [{'pppgao'},{'L1L2'},{'best'},{'best'},{lower},{upper}];
% [{'pppgao'},{'L1L2'},{'broadcast'},{'broadcast'},{lower},{upper}];
];


addpath(genpath('Functions/'));
for cmb = 1:1
    smooth  = smoothvec(cmb);
    antex   = antexvec(cmb);
    datagap = datagapvec(cmb);
    cyclesl = csvec(cmb);

for k=1:size(torun,1)
%     if cmb == 2
%         if k > 16
%             break
%         end
%     end
% try
savebreakpoints;
close all
save('.runidx.mat','k','cmb','csvec','cyclesl','obsrange','inputpath','horizonstxt');
save('.torun.mat','torun','antex','smooth','datagap','antexvec','smoothvec','datagapvec');
clear all 
clear all
% clearvars 
load('savedreakpoints');
dbstop(breakpoints);
format long g
% clc
load('.runidx.mat');
load('.torun.mat');

fprintf('########################################################\n');
fprintf('# INSTITUTO SUPERIOR TECNICO\n');
fprintf('# INSTITUTO TELECOMUNICACOES LISBOA\n');
fprintf('# PPPLAB - Precise point positioning suite for MATLAB\n')
fprintf('# Developed by: Pedro Silva, 2012\n')
fprintf('########################################################\n\n');

runargs = torun(k,:);

runalgo  = runargs{1};
runfreq  = runargs{2};
runorbit = runargs{3};
runclock = runargs{4};
runinit  = runargs{5};
runfinal = runargs{6};
fprintf('\tRUN %d\n',k);
fprintf('\tORBITS %s\n',runorbit);
fprintf('\tSAT CLOCK %s\n',runclock);
fprintf('\tRUN %s\n',obsrange{cmb});
fprintf('\tFILE %s\n',inputpath{cmb});


% inputpath = 'Aquisition/RINEX/GMV1328i/gmv';
% inputpath   = 'Aquisition/170914proflex03-Aug-2012/';
% horizonstxt = 'horizons_results03August-2.txt';

% inputpath   = 'Aquisition/LondresAlvalade/';


% inputpath   = 'Aquisition/17Apr2012ALL/';
% horizonstxt = 'horizons_results17April.txt';

% Asks for initialisation variables
sSettings  = getinput(   ...
                         'mode','offline',...
                         'algo',runalgo,'freqmode',runfreq,...
                           'inputpath',inputpath{cmb});   

try
    imudata = load('Aquisition/LondresAlvalade/imumes.txt');
end


displaymode                       = 0;
sSettings.displaymode             = displaymode;

% Algo flags
sSettings.receiver.rate           = 1;
sSettings.algorithm.refpoint      = [4918533.320,-791212.572,3969758.451]; %SUL Prof Pos
% sSettings.algorithm.refpoint      = [4918531.91,-791212.65,3969754.15]; %SUL

% sSettings.algorithm.refpoint      = [4914855.00284,-791859.36532,3974148.48842];

sSettings.algorithm.interpolation = 'neville';
sSettings.algorithm.orbitproduct  = runorbit;
sSettings.algorithm.clockproduct  = runclock;
sSettings.algorithm.tropomodel    = 'Broadcast';
sSettings.algorithm.ionomodel     = 'combination';
% sSettings.algorithm.ionomodel     = 'none';


% FILTER SETTINGS! IMPORTANT!
% X Y Z CLK TROPO AMB
sSettings.algorithm.filterVar    = [10 10 10 50 0.1 100000]; % will affect P
sSettings.algorithm.filterNoise  = [0 0 0 10 0 0];         % will affect Q
sSettings.algorithm.filterDyn    = [0 0 0 30 0];          % Phi static
% sSettings.algorithm.filterDyn    = [10 10 10 30 0];          % Phi static

sSettings.algorithm.smooth        = smooth;
sSettings.algorithm.antex         = antex;
sSettings.algorithm.csdetection   = cyclesl;
sSettings.algorithm.cscorrection  = cyclesl;
sSettings.algorithm.csalgorithm   = 0;
sSettings.algorithm.datagaps      = datagap;
sSettings.algorithm.satvelocity   = 'ephemerides';

sSettings.algorithm.polydegreesat = 12; %12
sSettings.algorithm.polydegreeclk = 9;
sSettings.algorithm.computedtr    = 0;

% Algo log to process
sSettings.file.logtype            = 'SNFILE';
% sSettings.file.logtype            = 'BINFILE';                     
% sSettings.file.logtype            = 'RINEX';
sSettings.file.finalepoch         = runfinal;
sSettings.file.startingepoch      = runinit;

% IMU definitions
sSettings.IMU.useimu              = 0;
sSettings.IMU.device              = 'IMU6DOF';
sSettings.IMU.com                 = 'COM3';
sSettings.IMU.calibrate           = 1;
sSettings.IMU.rate                = 0.005;

% Configures structures with given initialisations
[sEpoch, sAlgo, sStat] = configppplab(sSettings);
%                                     'inputpath','../../ThesisData/Aquisition/17Abr/',...
                                    %'inputpath','../29Ma2012OK/',...
                                    % 'inputpath','Aquisition/162024proflex24-Apr-2012/',...
                                    % 'inputpath','Aquisition/163144ublox27-Apr-2012/',...

sEpoch.accumtempcs     = 0;
sAlgo.aleatorio        = Inf;
sAlgo.csvalaleatorio   = 10;      
sAlgo.csvalaleatoriol2 = 0;      
sEpoch.oktogo          = 0;
% try                                    
% sEpoch.IMU.data = imudata;
% end
sEpoch.idx = 1;                                    
sEpoch.IMU.velocity = [0,0,0];
sEpoch.IMU.position = [0,0,0];
                           
                                    
sAlgo.ambiguitiesL1 = zeros(32,1);
sAlgo.ambiguitiesL2 = zeros(32,1);

% sAlgo.sun = [-6.642740842872109E-01  7.670009817955573E-01 -1.929721561156264E-05].*149598000000;
% sAlgo.sun = [1.040927618017534E+11  1.008452111762939E+11  4.506404436256782E+10];
if sSettings.algorithm.antex
    sAlgo.sun     = readsunhorizons(['Aquisition/',horizonstxt{cmb}],10*3600,20*3600);
    sAlgo.sun.TOW = sAlgo.sun.TOW + sEpoch.WD*24*60*60;
end


% sEpoch.IMU.velocity =  -711111/3600 + 7.2921151467;
% sEpoch.IMU.position = 19.44;
% sAlgo.type = 'dynamic';


sEpoch.counters.tec = 0;
sEpoch.counters.mw  = 0;      
sEpoch.counters.lg  = 0;
sEpoch.counters.dop = 0;
sEpoch.counters.correctedL1 = 0;
sEpoch.counters.correctedL2 = 0;
sEpoch.counters.insertedcs  = 0;

%REMOVE
sStat.lgtemp1 = zeros(32,5000);
sStat.lgtemp2 = zeros(32,5000);

sEpoch.IMU.position = 0;
sAlgo.type = 'static';
% sAlgo.type = 'dynamic';


if ~sEpoch.operation                                    
   sEpoch.IMU.logfyle = 'Aquisition/imuoffline.log'; 
end
                                    
obsperiod = sSettings.receiver.obsperiod;
sEpoch.IMU.iniflag = 1;
% ALGORITHM WORKFLOW
rate = sSettings.receiver.rate;
time = 0; iniflag = 1;
sEpoch.ephtime = ones(userparams('MAXSAT'),1);
tic
disp('Now Running...');
while sEpoch.iEpoch < sEpoch.nbEpoch
   % Obtain new data if online processing
    time = time + 1;
    if time == obsperiod, break; end;
    [ sEpoch, sAlgo, sStat ] = workflow(sEpoch, sAlgo, sStat, sSettings);    
end
fprintf('\n');
toc



% Generates report
if sSettings.algorithm.csdetection
    strobs = [obsrange{cmb},'-CSON-'];
else
    strobs = [obsrange{cmb},'-CSOFF-'];
end

if sSettings.algorithm.datagaps
    strobs = [strobs,'-REGENON-'];
else
    strobs = [strobs,'-REGENOFF-'];
end
if antex
    strantex = '-ATX-';
else
    strantex = '-NotATX-';
end
if smooth
    strsm = '-SM-';
else
    strsm = '-NotSM-';
end

folderpath                = ['./Report/',strobs,strantex,strsm,sAlgo.algtype,sAlgo.flags.freqmode,sAlgo.flags.orbitproduct(1:3),sAlgo.flags.clockproduct(1:3),'/'];
twopoints                 = datestr(now);
twopoints(twopoints==':') = '-';
disp('saving workspace');
try
    save([folderpath,'data/',twopoints,sAlgo.algtype,'.mat'],'sEpoch','sAlgo','sStat','sSettings');
catch
    try
        disp('Retrying - creating folder');
        mkdir([folderpath,'data/']);    
        save([folderpath,'data/',twopoints,sAlgo.algtype,'.mat'],'sEpoch','sAlgo','sStat','sSettings');
    catch
        disp('couldn''t save run data');
    end
end

llapoints = eceftolla(sStat.userxyz(1:135,:));
% pwr_kml('test',llapoints);

reportgenerator(sSettings,sAlgo,sStat,sEpoch,'force','silent',...
    'name',[twopoints,'-',obsrange{cmb},strantex,strsm,sAlgo.algtype,sAlgo.flags.freqmode,sAlgo.flags.orbitproduct(1:3),sAlgo.flags.clockproduct(1:3)],...
    'folderpath',folderpath,'skip','00110');

% catch
%     fprintf('Failed at K = %d\n',k);
%     continue;
% end
end
end



                       % 'inputpath','Aquisition/163748ublox02-Aug-2012/'); % scdeec - civil                     
                       %'inputpath','Aquisition/164418ublox02-Aug-2012/'); %descida alameda
                       
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                           'inputpath','Aquisition/RINEX/GMV1328i/gmv');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                          'inputpath','Aquisition/114650proflex05-Aug-2012/');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                          'inputpath','Aquisition/Ferrao/');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                          'inputpath','Aquisition/114650proflex05-Aug-2012/');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                      'inputpath','Aquisition/114650proflex05-Aug-2012/');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                          'inputpath','Aquisition/162245proflex02-Aug-2012/');
                     
%                          'inputpath','Aquisition/163748ublox02-Aug-2012/');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                          'inputpath','Aquisition/163748ublox02-Aug-2012/');
%                          'inputpath','Aquisition/170914proflex03-Aug-2012/');
%                          'inputpath','Aquisition/163748ublox02-Aug-2012/');% 164418ublox02-Aug-2012  170914proflex03-Aug-2012
%                          'inputpath','Aquisition/192107ublox24-Jul-2012/');163748ublox02-Aug-2012
%                          'inputpath','Aquisition/RINEX/GMV1328i/gmv');                          
%                          'inputpath','Aquisition/ashtech.bin');
                        
%                          'inputpath','Aquisition/RINEX/GMV1328i/gmv');
%                          'inputpath','C:\Users\silva\Documents\Thesis\PPPLab\Aquisition\ashtech.bin');
%                          'inputpath','Aquisition/RINEX/GMV1328i/gmv');
%                          'inputpath','Aquisition/ashtech1.bin');
%                          'inputpath','Aquisition/RINEX/GMV1328i/gmv');
%                          'inputpath','Aquisition/RINEX/GMV1328i/gmv');
