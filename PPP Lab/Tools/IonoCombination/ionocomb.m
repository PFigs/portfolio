% This script serves as an indicator to the measurements quality

if ~exist('Print')
   mkdir('Print'); 
end

Epoch = struct(...
          'msgID',NaN,...                        % ID for online use
          'iEpoch',NaN, 'nbEpoch', NaN,...       % Epoch counter (online = Inf)
          'WD', NaN, 'WN', NaN, 'TOW', NaN,...   % Week info
          'DOY',NaN,...                          % Day of Year
          'ranges',NaN,'eph',NaN,...             % Measurements
          'iono',NaN,...                         % For ionosphere coefficients
          'receiver', NaN, 'inputpath', NaN, ... % Receiver name and input path
          'operation', NaN,...                   % For flagging offline/online
          'freqmode', NaN,...                    % Frequency operation mode
          'dirty',NaN);                          % When IO should be done       

sEpoch.msgID     = 'SNFILE';
sEpoch.receiver  = 'SNFILE'; % default
sEpoch.operation = 0;

sEpoch.iEpoch    = 0;
sEpoch.WD        = 0;
sEpoch.WN        = 0;
sEpoch.DOY       = 82;
% sEpoch.inputpath = '../../../../ThesisData/Aquisition/';
sEpoch.inputpath = '../../../../ThesisData/Aquisition/21Mar2321ZXWMPC/';


if ~ischar(path), error('obtaindata: PATH must be a string'); end;
[ranges, eph, nbepoch, iono, satlist] = readcustomfile( sEpoch.inputpath );   
sEpoch.ranges  = ranges;
sEpoch.iono    = iono;
sEpoch.eph     = struct('msgID','SNFILE','data',eph);
sEpoch.TOW     = ranges.TOW(1);
sEpoch.WD      = towtoweekday(ranges.TOW(1));
sEpoch.WN      = sEpoch.eph.data(ephidx('wn'));
sEpoch.nbEpoch = nbepoch;

fprintf('Results started at epoch %d through %d\n',sEpoch.ranges.TOW(1), sEpoch.ranges.TOW(end));
%%
close all
gama = (77/60)^2;

for k=satlist'
    for l=1: nbepoch

       ionpr(l) = (ranges.PRL2(l,k) - gama*ranges.PRL1(l,k))/(1-gama);
    end
    h=figure;
    h = axes('Parent',h);
%     y=figure;
%     y = axes('Parent',y);

    hold(h)
%     hold(y)
    plot(h,ionpr,'.k');
    plot(h,ranges.PRL1(:,k),'dg');
    
%     plot(y,ionpr./1e6,'.k');
    plot(h,ranges.PRL2(:,k),'db');

%     plot(h,ionpr-ranges.PRL1(:,k)','.g');
%     plot(y,ionpr-ranges.PRL2(:,k)','.b');
end

