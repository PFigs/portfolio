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

               
% initialises structures
[sEpoch, sAlgo, sStat] = configcompare(); % what about a sStat ?
                                
% YOU BETTER WATCH OUT!
% sEpoch.nbEpoch = 100;
% 
% st(1:sEpoch.nbEpoch) = struct('data',[]);
% sStat.satxyz   = st;
% sStat.satenu   = st;
% sStat.satelv   = st;
% sStat.sataz    = st;
% sEpoch.iEpoch  = 100;                                
C       = gpsparams('C');      % Speed of light                                
%% ALGORITHM WORKFLOW                            
while sEpoch.iEpoch < sEpoch.nbEpoch %inf for online
   % ADVANCES TIME
   sEpoch.iEpoch      = sEpoch.iEpoch + 1;          % Epoch counter
   TOW         = sEpoch.ranges.TOW(sEpoch.iEpoch);
   WD          = towtoweekday(sEpoch.ranges.TOW(sEpoch.iEpoch));    
   
   % ALGO INFORMATION
   availableSat = find(sEpoch.ranges.PRL1(sEpoch.iEpoch,:) ~= 0);
   nSat         = size(availableSat,2);
   eph          = buildsEph(sEpoch.eph.data(:,availableSat));
   eph.tow      = sEpoch.TOW;
   
   
   [satxyz,ecc] = satpos(eph,sAlgo.refpoint,TOW); %check
   [tsv,dtr]    = dtsv(eph, ecc, TOW, 1); % Tsv correction   %send nSat     
   stsv         = clockcorrection(eph, ecc, TOW, 1);
   
   
   sattm     = satpos(eph,sAlgo.refpoint,TOW-1); %check
   sattp     = satpos(eph,sAlgo.refpoint,TOW+1); %check
   satvel    = (sattp - sattm)./(2);
   satclk    = stsv+dtr;
   
   for k=1:nSat
        dtrc(k) = -2.*satxyz(k,:)*satvel(k,:)'./(C^2);
   end
   
   saveddiff = tsv-satclk;
   disp(saveddiff);
   
   if ~mod(sEpoch.iEpoch,500)
       fprintf('. ');
   end
   
end
% plot(saveddiff(1,:),'g.');
