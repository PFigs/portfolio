clear
rwparam('clear');   % Clears persistent variables
clc
close all

% CONTROL VARIABLES
% set them if needed;
rcvtype = rwparam('Control','rcvtype','SNfile');
algtype = rwparam('Control','rcvtype','spp');
iEpoch  = rwparam('Control','rcvtype',0);
path    = rwparam('Control','path');
rwparam('Control','switchtoppp',1);

% ALGORITHM WORKFLOW
[ranges, eph] = obtaindata('SNFILE',path);  


% Only convert epochs with more than 5 satellites!
for i=1:size(ranges.TOW,1)
    if size(find(((ranges.PRL1(i,:)) ~= 0)),2) <=5
        discard=i;
    end
end

ranges.PRL1(1:discard,:) = [];
ranges.PRL2(1:discard,:) = [];
ranges.CPL1(1:discard,:) = [];
ranges.CPL2(1:discard,:) = [];
ranges.TOW(1:discard)    = [];

datatorinex(2011,11,3,ranges);
    
%(iyear,imonth,iday,ihour,imin,isec,data)
disp('File converted');