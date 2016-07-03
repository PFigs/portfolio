% PPP LAB
%   Script used to develop the global workflow of the algorithms. 
%   
%   Please note that the program uses persistent variables controled by the   
%   function RXPARAM. The variables can be access in a global manner but
%   are managed through it to avoid name collisions.
%
%
%  TODO
%  - VALIDATE PPPPARAM!
%  - Get next day file for observations later than 22:15 and previous day
%    for observations earlier than 01:30
%  - Error Elipse
%   
% Pedro Silva, Instituto Superior Tecnico, 2011
% fclose(instrfind)
% delete(instrfind)  

clc
close all
clear
clear gethandles % clears persistent handles
clear configppplab
clear compareorbits
format long g
fprintf('########################################################\n');
fprintf('# INSTITUTO SUPERIOR TECNICO\n');
fprintf('# INSTITUTO TELECOMUNICACOES LISBOA\n');
fprintf('# COMPARE ORBITS - IGS and Brodcast orbit comparator suite\n')
fprintf('# Developed by: Pedro Silva, 2012\n')
fprintf('########################################################\n\n');

epochs = 1500;               
% initialises structures
[sEpoch, sAlgo, sStat] = configcompare(epochs); % what about a sStat ?
                                
% YOU BETTER WATCH OUT!
% 
% st(1:sEpoch.nbEpoch) = struct('data',[]);
% sStat.satxyz   = st;
% sStat.satenu   = st;
% sStat.satelv   = st;
% sStat.sataz    = st;
% sEpoch.iEpoch  = 100;                                
                                
% ALGORITHM WORKFLOW                            
while sEpoch.iEpoch < sEpoch.nbEpoch %inf for online
   % ADVANCES TIME
   sEpoch.iEpoch      = sEpoch.iEpoch + 1;          % Epoch counter
   sEpoch.TOW         = sEpoch.ranges.TOW(sEpoch.iEpoch);
   sEpoch.WD          = towtoweekday(sEpoch.ranges.TOW(sEpoch.iEpoch));    
   
   % ALGO INFORMATION
   sAlgo.availableSat = find(sEpoch.ranges.PRL1(sEpoch.iEpoch,:) ~= 0);
   sAlgo.nSat         = size(sAlgo.availableSat,2);
   sAlgo.eph          = buildsEph(sEpoch.eph.data(:,sAlgo.availableSat));
   sAlgo.eph.tow      = sEpoch.TOW;
   sAlgo.freqmode     = 'L1';
   sAlgo              = compareorbits(sAlgo,sEpoch.TOW,sEpoch.WD);
   
   if ~mod(sEpoch.iEpoch,500)
       fprintf('. ');
   end
   
   % STATISTIC
   sStat.satxyz(sEpoch.iEpoch).data = sAlgo.satxyz;
   sStat.satenu(sEpoch.iEpoch).data = sAlgo.satenu;
   sStat.satelv(sEpoch.iEpoch).data = sAlgo.satelv;
   sStat.sataz(sEpoch.iEpoch).data  = sAlgo.sataz;
   sStat.satclk(sEpoch.iEpoch).data = sAlgo.satclk;
   
end
outputresults( sStat, sAlgo.availableSat )

