% TESTECEFTOENU script serves as a debug tool for the fuction xyztolla.

%   INPUT : xyz = [4910445.093380, -821633.480531, 3973410.564928]
%   OUTPUT: enu = [142.768289, 161.966841, 20.403658]

%   INPUT : xyz = [6910384.3, -321478.6, 2973549.6];
%   OUTPUT: enu = [592401.482477179, -1701426.02703467, 1415701.22486627];

%   INPUT : xyz = [775858.6194, 4903039.9874, 3991748.6190];
%   OUTPUT: enu = [2.09547579288483e-09, -6246866.5355431, 7716455.75043843];

%   INPUT : xyz = [-775858.6194, -4903039.9874, 3991748.6190];
%   OUTPUT: enu = [2.79396772384644e-09, -6246866.5355431, 7716455.75043843]; 

%   INPUT : xyz = [4910384.3, -821478.6, 3973549.6];
%   OUTPUT: enu = [-823148.928003576, 1963405.78396477, -847032.212976721];

% Pedro Silva, Instituto Superior Técnico, November 2011

clc
clear

disp('ENU CONVERSION TESTING SCRIPT');

% EVALUATION POINTS

xyz = [17470061.756, 5280112.510, 19475621.940;
       10081305.057, -11358237.163, 21898193.330;
       19708617.912, -17112872.613, 4390953.666;
       20128532.878, 15650090.344, -7214159.148;
       19306102.483, -17206751.407, -5750022.432;
       14769273.088, 2406371.804, 21895510.022;
       23073350.036, -6475687.131, 11337675.627;
       24956495.640, 9354439.566, -1432061.552;
       -4170233.068, -17417305.117, 19911832.025;
       22928894.305, -269125.348, -13734543.278];
   
   
% REFERENCE POINTS
refxyz=[4918526.668,       -791212.115,       3969767.14];

% SWITCH REFXYZ TO DESIRABLE UNIT

enu = eceftoenu(xyz,refxyz,'ECEF');
azdeg = azimuth(enu,'deg');
eldeg = elevation(enu,'deg');
azrad = rad(azdeg);
elrad = rad(eldeg);
prn=1:size(eldeg,1);
% skyPlot3d(az,el,prn);
% h=skyplot(azdeg,eldeg,prn);
h = mmpolar(azdeg,eldeg,'dk',...
    'Style','compass',...
    'TTickDirection','out','RLimit',[0,90],...
    'TTickDelta',30,'RTickValue',[30,60,90]...
    );

set(h,'MarkerFaceColor',[.49 1 .63]);
set(h,'MarkerEdgeColor','black');
set(h,'MarkerSize',10);
set(h,'LineWidth',2);
% 'TZeroDirection','North',...
%     'Grid','on','Border','off',...
%     'BorderColor','b',...
%     'BackgroundColor','c',...
