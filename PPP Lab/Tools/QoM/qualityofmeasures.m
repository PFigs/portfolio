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
sEpoch.inputpath = '../../../../ThesisData/Aquisition/17Apr2012OK/';
% sEpoch.inputpath = '../../Aquisition/rcvdata/';


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

% 
% sEpoch.ranges.PRL1(1201:end) = [];
% sEpoch.ranges.PRL2(1201:end) = [];
% sEpoch.ranges.CPL1(1201:end) = [];
% sEpoch.ranges.CPL2(1201:end) = [];

for k=1:numel(satlist)
    titlestr = ['QoM over an observation time of ' sprintf('%d',length(sEpoch.ranges.PRL1)) ' seconds for satellite ' sprintf('%02d',satlist(k))];
    handle = figure('Name',['Quality of Measurements for satellite ' sprintf('%02d',satlist(k))],'NumberTitle','off');
    sthdl.pos = axes('Parent',handle);
    xlim([0 length(sEpoch.ranges.PRL1)]);
    title(titlestr,...
          'fontsize',12,'fontweight','b');
    xlabel('Epochs (s)','fontsize',11,'fontweight','b');
    ylabel('Carrier Phase (Mega cycles)','fontsize',11,'fontweight','b');
    hold(sthdl.pos);

    % Determines figure positons
    set(handle,'Units','normalized');
    set(handle,'Position',[0.0125+0.06*(k-1) 0.5-0.05*(k) 0.45 0.40]);
    
    % Plot data
%     sEpoch.ranges.CPL1(sEpoch.ranges.CPL1(:,satlist(k))==0,satlist(k)) = NaN;
%     sEpoch.ranges.CPL2(sEpoch.ranges.CPL2(:,satlist(k))==0,satlist(k)) = NaN;
    
    plot(sEpoch.ranges.CPL1(:,satlist(k))*1e-06,'-b');
    plot(sEpoch.ranges.CPL2(:,satlist(k))*1e-06,'-r');
    
    aux      = 1:size(sEpoch.ranges.CPL1(:,satlist(k))); 
    blackpt  = aux(sEpoch.ranges.CPL1(:,satlist(k))==0);
    nulldata = zeros(max(size(blackpt)),1);
    if ~isempty(blackpt)
        plot(blackpt,nulldata,'.k');
    end
    
    aux      = 1:size(sEpoch.ranges.CPL2(:,satlist(k)));
    blackpt  = aux(sEpoch.ranges.CPL2(:,satlist(k))==0);
    nulldata = zeros(max(size(blackpt)),1);
    if ~isempty(blackpt)
        plot(blackpt,nulldata,'.k');
    end
    
    
    hleg = legend('CPL1','CPL2','CP = 0','Location','Best');
    set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1])
    set(handle,'PaperType','a4','PaperOrientation','landscape');
    fillPage(handle);
    fname(k,:) = sprintf('Print/QoMCP%02d.pdf',satlist(k));
    print(handle,'-dpdf',fname(k,:))
    aux=cellstr(fname)';
    drawnow
    
end

finalname = 'Print/QoMCP.pdf';
if exist(finalname)
   delete(finalname); 
end
append_pdfs(finalname, aux{:});
delete(aux{:});


for k=1:numel(satlist)
     titlestr = ['QoM over an observation time of ' sprintf('%d',length(sEpoch.ranges.PRL1)) ' seconds for satellite ' sprintf('%02d',satlist(k))];
    handle = figure('Name',['Quality of Measurements for satellite ' sprintf('%02d',satlist(k))],'NumberTitle','off');
    sthdl.pos = axes('Parent',handle);
    xlim([0 length(sEpoch.ranges.PRL1)]);
    title(titlestr,...
          'fontsize',12,'fontweight','b');
    xlabel('Epochs (s)','fontsize',11,'fontweight','b');
    ylabel('Pseudo Range (Mm)','fontsize',11,'fontweight','b');
    hold(sthdl.pos);

    % Determines figure positons
    set(handle,'Units','normalized');
    set(handle,'Position',[0.0125+0.06*(k-1) 0+0.05*(k) 0.45 0.40]);
    
    
    plot(sEpoch.ranges.PRL1(:,satlist(k))*1e-06,'-b');
    plot(sEpoch.ranges.PRL2(:,satlist(k))*1e-06,'-r');
    
    aux      = 1:size(sEpoch.ranges.PRL1(:,satlist(k))); 
    blackpt  = aux(sEpoch.ranges.PRL1(:,satlist(k))==0);
    nulldata = zeros(max(size(blackpt)),1);
    if ~isempty(blackpt)
        plot(blackpt,nulldata,'.k');
    end
    
    aux      = 1:size(sEpoch.ranges.PRL2(:,satlist(k)));
    blackpt  = aux(sEpoch.ranges.PRL2(:,satlist(k))==0);
    nulldata = zeros(max(size(blackpt)),1);
    if ~isempty(blackpt)
        plot(blackpt,nulldata,'.k');
    end
    
    
    hleg = legend('PRL1','PRL2','PR = 0','Location','Best');
    set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1])
    set(handle,'PaperType','a4','PaperOrientation','landscape');
    fillPage(handle);
    fname(k,:) = sprintf('Print/QoMPR%02d.pdf',satlist(k));
    print(handle,'-dpdf',fname(k,:))
    aux=cellstr(fname)';
    drawnow
end


finalname = 'Print/QoMPR.pdf';
if exist(finalname)
   delete(finalname); 
end
append_pdfs(finalname, aux{:});
delete(aux{:});

close all
