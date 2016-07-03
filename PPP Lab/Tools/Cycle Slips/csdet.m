

clc
close all
clear
clear gethandles % clears persistent handles
clear configppplab
clear workflow
clear precisepos;
clear sppdf;
clear readcustomfile;
format long g
fprintf('########################################################\n');
fprintf('# INSTITUTO SUPERIOR TECNICO\n');
fprintf('# INSTITUTO TELECOMUNICACOES LISBOA\n');
fprintf('# Cycle slip detector\n')
fprintf('# Developed by: Pedro Silva, 2012\n')
fprintf('########################################################\n\n');

% Asks for initialisation variables
%%% DOY HAS CHANGED! Be careful with this!!! FREQMODE
[mode,doy,receiver,com,reset,...
 skipcfg,messages,algtype,...
 freqmode] = getinput('algo','mwslip','freqmode','L1L2');

doy = dayofyear(2012,03,29);

% Sets reference points
logging  = 1;
refpoint = [4918533.320,-791212.572, 3969758.451; % Professor's
            4918531.93, -791212.65, 3969754.13];  % Ublox      

% initialises structures
[sEpoch, sAlgo, sStat] = configppplab(mode,'COM',com,'reset',reset,...
                                    'receiver', receiver,...
                                    'dayofyear', doy,...
                                    'messages', messages,...
                                    'skipconfig', skipcfg,...
                                    'logging',logging,...
                                    'refpoint',refpoint(1,:),...
                                    'algtype',algtype,...
                                    'inputpath','../29Ma2012OK/',...
                                    'freqmode',freqmode...
                                    );
                                    %'inputpath','Aquisition/221643proflex29-Mar-2012/',...
%                                     'inputpath','../../ThesisData/Aquisition/29Ma2012OK/',...


sEpoch.nbEpoch = 1200;
% sAlgo.userxyz  = refpoint(1,:);


%% ALGORITHM WORKFLOW              
close all

% sEpoch.ranges.PRL1(720,

fighandle       = figure('Name','LG combination','NumberTitle','off');
sEpoch.slipfig1 = axes('Parent',fighandle);
% title('Receiver position in ENU coordinates',...
%       'fontsize',12,'fontweight','b');
% xlabel('East (m)','fontsize',11,'fontweight','b');
% ylabel('North (m)','fontsize',11,'fontweight','b');
hold(sEpoch.slipfig1);

fighandle       = figure('Name','Slips','NumberTitle','off');
sEpoch.slipfig2 = axes('Parent',fighandle);
% title('Receiver position in ENU coordinates',...
%       'fontsize',12,'fontweight','b');
% xlabel('East (m)','fontsize',11,'fontweight','b');
% ylabel('North (m)','fontsize',11,'fontweight','b');
hold(sEpoch.slipfig2);

sAlgo.mwstd   = 0;
sAlgo.ndelta  = 0; 
sAlgo.biasvar = 0;
   
sEpoch.iEpoch=0;
while sEpoch.iEpoch < sEpoch.nbEpoch 

   
   % Obtain new data if online processing
   sEpoch.iEpoch = sEpoch.iEpoch + 1; % Epoch counter
   sEpoch.TOW    = sEpoch.ranges.TOW(sEpoch.iEpoch);
   sEpoch.WD     = towtoweekday(sEpoch.ranges.TOW(sEpoch.iEpoch));    
   
   
   % Process data and updates display information
   [sAlgo,sStat] = myworkspace( sEpoch, sAlgo, sStat );
   updatedisplay(sEpoch.iEpoch,sEpoch.TOW,sAlgo,sStat,-1);

   
end

