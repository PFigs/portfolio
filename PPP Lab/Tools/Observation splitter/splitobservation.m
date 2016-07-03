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
sEpoch.DOY       = 67;
sEpoch.inputpath = '../../../../ThesisData/Aquisition/21Mar2321ZXWMPC/';


if ~ischar(path), error('obtaindata: PATH must be a string'); end;
[ranges, ~, nbepoch, iono, satlist, date, eph] = readcustomfile( sEpoch.inputpath );   
sEpoch.ranges  = ranges;
sEpoch.eph     = struct('msgID','SNFILE','data',eph);
sEpoch.TOW     = ranges.TOW(1);
sEpoch.WD      = towtoweekday(ranges.TOW(1));
sEpoch.WN      = sEpoch.eph.data(ephidx('wn'));
sEpoch.nbEpoch = nbepoch;

fprintf('Results started at epoch %d through %d\n',sEpoch.ranges.TOW(1), sEpoch.ranges.TOW(end));

%%

biggest = [0];
l=1;
initialTOW = NaN;
initialIDX = NaN;
lastTOW    = NaN;
lastIDX    = NaN;
for k=1:size(sEpoch.ranges.PRL1,1)
    
    if sum(sEpoch.ranges.PRL1(k,:)~=0) >= 4
        biggest(l) = biggest(l) + 1;
        if isnan(initialTOW(l))
            initialTOW(l) = sEpoch.ranges.TOW(k);
            initialIDX(l) = k;
        end
%     elseif sum(sEpoch.ranges.PRL1(k,:)~=0) == 0
%         continue;
    elseif biggest(l) > 0
        lastTOW(l) = sEpoch.ranges.TOW(k);
        lastIDX(l) = k;
        l=l+1;
        biggest(l) = 0;
        initialTOW(l) = NaN;
    end 
    
end

%%
bigIDX = find(biggest == max(biggest));
iTOW   = initialTOW(bigIDX);
fTOW   = lastTOW(bigIDX);
idx    = initialIDX(bigIDX);
lidx   = lastIDX(bigIDX);

%% CREATE FILE 

% PRL1 CPL1 PRL2 CPL2 TOW
if ~exist('Split','dir')
    mkdir('Split')
end
usedsats = [];
message = sEpoch.ranges;
for k = idx:lidx
    satlist = find(sEpoch.ranges.PRL1(k,:)~=0);
    if length(satlist) > length(usedsats)
       usedsats = satlist; 
    end
    for id = satlist
        fid = fopen(strcat('Split/',date,'pseudoranges',sprintf('%02d',id)),'a');
            fprintf(fid,'%e\t%e\t%e\t%e\t%d\r\n',...
                        message.PRL1(k,id), message.CPL1(k,id),...
                        message.PRL2(k,id), message.CPL2(k,id),...
                        message.TOW(k));
        fclose(fid);
    end
end

%% CREATE EPH FILE
% for id = usedsats
%     eph(id).epoch(
%     
% end




