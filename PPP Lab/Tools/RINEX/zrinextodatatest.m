
% data = ppplabstructs('ranges');
% 
% data.PRL1     = zeros(1000,88);
% data.PRL2     = zeros(1000,88);
% data.CPL1     = zeros(1000,88);
% data.CPL2     = zeros(1000,88);
% data.SNRL1    = zeros(1000,88);
% data.SNRL2    = zeros(1000,88);
% data.SNRCA    = zeros(1000,88);
% data.PRCAL1   = zeros(1000,88);
% data.PRCAL2   = zeros(1000,88);
% data.PRCA     = zeros(1000,88);
% data.CPCA     = zeros(1000,88);
% data.TOW      = zeros(1000,1);
% data = rinextodata('gap1113t.12o',data,'o');


data.eph.time  = [];    % Number of epochs for each satellite
data.eph.data  = [];

data = rinextodata('aira1130.12n',data);