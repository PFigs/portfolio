% PPP LAB
%   Script used to develop the global workflow of the algorithms. 
%   
%   Please note that the program uses persistent variables controled by the   
%   function RXPARAM. The variables can be access in a global manner but
%   are managed through it to avoid name collisions.
%   
% Pedro Silva, Instituto Superior Tecnico, 2011

addpath(genpath('Functions/'));
savebreakpoints;
close all
clear all
load('savedreakpoints');
dbstop(breakpoints);
format long g

% RUN switchers
smooth      = 0;            % enable smoothing
antex       = 0;            % enable usage of antex files
cyclesl     = 0;            % enable cycle slip detection and correction
dummycs     = 0;            % enable artificial cycle slip to be added
datagap     = 0;            % perform data regeneration
printkml    = 0;            % print kml file
rcvdynamic  = 'static';     % either static or dynamic
runalgo     = 'pppkalman';        % Algorithm to use
runfreq     = 'L1L2';         % Frequency 
runorbit    = 'broadcast';  % Orbit product    
runclock    = 'broadcast';  % Clock product
runinit     = 501;          % first epoch
runfinal    = 800;          % last epoch
horizonstxt = 'horizons_results03August-2.txt'; % '153958ublox08-Mar-2013/Horizons_results08March.txt'; %
displaymode = -1; %controls which information to show during the scrip exec

% Input data
gpstype     = 'SNFILE'; % other possibilities BINFILE or RINEX
imufile     = 'Aquisition/imuoffline.log';

%Output data
runname     = 'WithMinusOffset'; % Name to identify this run
inputpath   = 'Aquisition/170914proflex03-Aug-2012/';%'Aquisition/153958ublox08-Mar-2013/';%

%Artificial cycle slips

csl1        = 20;
csl2        = 0;
startepoch  = inf;
cssats      = 6;

fprintf('########################################################\n');
fprintf('# INSTITUTO SUPERIOR TECNICO\n');
fprintf('# INSTITUTO TELECOMUNICACOES LISBOA\n');
fprintf('# PPPLAB - Precise point positioning suite for MATLAB\n')
fprintf('# Developed by: Pedro Silva, 2012\n')
fprintf('########################################################\n\n');

% Asks for initialisation variables
sSettings  = getinput(   ...
                         'mode','offline',...
                         'algo',runalgo,'freqmode',runfreq,...
                           'inputpath',inputpath);   

% Algo flags
sSettings.displaymode             = displaymode;
sSettings.receiver.rate           = 1;
sSettings.algorithm.refpoint      = [4918532.99699294,-791216.891156653, 3969758.13365811];
%sSettings.algorithm.refpoint      = [4918533.320,-791212.572,3969758.451]; %SUL Prof Pos
sSettings.algorithm.interpolation = 'neville';
sSettings.algorithm.orbitproduct  = runorbit;
sSettings.algorithm.clockproduct  = runclock;
sSettings.algorithm.tropomodel    = 'Broadcast';
sSettings.algorithm.ionomodel     = 'broadcast';
sSettings.algorithm.horizons      = horizonstxt;

sSettings.algorithm.filterVar     = [10 10 10 50 0.1 100000]; % will affect P
sSettings.algorithm.filterNoise   = [0 0 0 10 0 0];         % will affect Q
sSettings.algorithm.filterDyn     = [0 0 0 30 0];          % Phi static


%sSettings.algorithm.filterVar     = [10 10 10 5e10 0.1 100000]; % will affect P
%sSettings.algorithm.filterNoise   = [0 0 0 220 0 0];         % will affect Q
%sSettings.algorithm.filterDyn     = [0 0 0 200 0];          % Phi static

sSettings.algorithm.smooth        = smooth;
sSettings.algorithm.antex         = antex;
sSettings.algorithm.csdetection   = cyclesl;
sSettings.algorithm.cscorrection  = cyclesl;
sSettings.algorithm.csalgorithm   = 0;
sSettings.algorithm.datagaps      = datagap;
sSettings.algorithm.satvelocity   = 'ephemerides';

sSettings.algorithm.polydegreesat = 12;
sSettings.algorithm.polydegreeclk = 9;
sSettings.algorithm.computedtr    = 0;
sSettings.algorithm.rcvdynamic    = rcvdynamic;


sSettings.algorithm.artificialcs    = dummycs;
sSettings.algorithm.artificialcsl1  = csl2;
sSettings.algorithm.artificialcsl2  = csl1;
sSettings.algorithm.artificialepoch = startepoch;
sSettings.algorithm.cssatellites    = cssats;

% Algo log to process
sSettings.file.logtype            = gpstype;
sSettings.file.finalepoch         = runfinal;
sSettings.file.startingepoch      = runinit;

% IMU definitions
sSettings.IMU.logfile             = imufile;
sSettings.IMU.useimu              = 0;
sSettings.IMU.device              = 'IMU6DOF';
sSettings.IMU.com                 = 'COM3';
sSettings.IMU.calibrate           = 1;
sSettings.IMU.rate                = 0.005;

% Configures structures with given initialisations
[sEpoch, sAlgo, sStat] = configppplab(sSettings);                       


sAlgo.addartificialcs = 1;

%TODO
sAlgo.tempcount(1:32,1)=1;
sAlgo.tempcountregen(1:32,1)=1;


% ALGORITHM WORKFLOW
time           = 0;
fprintf('Now Running...');
while sEpoch.iEpoch < sEpoch.nbEpoch
    time = time + 1;
    if time == sSettings.receiver.obsperiod, break; end;
    [ sEpoch, sAlgo, sStat ] = workflow(sEpoch, sAlgo, sStat, sSettings);    
end
fprintf('done!\n');

% Generates report
createreport(sEpoch,sAlgo,sSettings,sStat,runname)


