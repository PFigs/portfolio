function sEpoch = obtaindata( sEpoch )
%OBTAINDATA This function provides data from a chosen source
% This function will provide data in real time or offline mode letting
% the user abstract himself from the lower layer.
%
%  INPUT
%  EPOCH - Structure declaration where data is stored with vital
%          information to access receiver and identify it:
%           RCVTYPE - Receiver identifier (SNFILE, RINEX, ZXW, ..)    
%           PATH    - Dir path or COM FD
%
%  OUTPUT
%  EPOCH which contains:
%  RANGES - Information regarding the current epochs. In some cases it
%           might contain more than one ranges (offline mode)
%
%  EPH    - Information regarding orbit parameters
%  Alongside other useful information, TOW, WN, WD, so on
%
%  NOTE: Might be useful to set eph persistent through a function
%
% Pedro Silva, Instituto Superior Tecnico, December 2011
    
    % CHECK INPUT
    error(nargchk(1, 1, nargin)) % future usage: error(narginchk(3, 3));
    
    % Retrieves data from IMU
    if sEpoch.operation && (strncmpi(sEpoch.receiver,'IMU',3) || strcmpi(sEpoch.receiver,'6dof') )
        sEpoch = rdevice(sEpoch.inputpath, sEpoch);
        
    elseif sEpoch.operation || strcmpi(sEpoch.receiver,'BINFILE')
        counter   = 0;
        requested = 0;
        % Retrieve and check if there might be enough data to process
        while 1
            sEpoch  = rdevice( sEpoch.inputpath, sEpoch );
            try
            onlygps = sEpoch.eph.data(ephidx('SID'),1:32) ~= 0;
            if sum(onlygps) > 3
                break;
            end
            end
            if ~requested || counter > 100
                requested = 1;
                counter = 0;
                disp('Not enough ephs');
                commandrcv( sEpoch.inputpath, sEpoch.receiver, 'EPH' );
            else
                counter = counter + 1;
            end
            
        end
        
        TOW        = sEpoch.ranges.TOW(1); % Keeps track of TOW
        sEpoch.TOW = TOW;
        sEpoch.WD  = towtoweekday(sEpoch.TOW);
        sEpoch.WN  = sEpoch.eph.data(ephidx('wn'),sEpoch.eph.update);
            
    % CUSTOM FILE  
    elseif strcmpi(sEpoch.receiver,'SNFILE')
        if ~ischar(path), error('obtaindata: PATH must be a string'); end;
        [ranges, eph, nbepoch, iono,~,~,alleph] = readcustomfile( sEpoch.inputpath );   
        sEpoch.ranges  = ranges;
        sEpoch.iono    = iono;
        sEpoch.eph     = struct('msgID','SNFILE','data',eph);
        sEpoch.alleph  = alleph;
        sEpoch.TOW     = ranges.TOW(1);
        sEpoch.WD      = towtoweekday(ranges.TOW(1));
        sEpoch.WN      = sEpoch.eph.data(ephidx('wn'));
        sEpoch.nbEpoch = nbepoch;
    
    elseif strcmpi(sEpoch.receiver,'RINEX')
        if ~ischar(path), error('obtaindata: PATH must be a string'); end;
        sEpoch.ranges        = ppplabstructs('ranges');
        sEpoch.ranges.PRL1   = zeros(1000,88);
        sEpoch.ranges.PRL2   = zeros(1000,88);
        sEpoch.ranges.CPL1   = zeros(1000,88);
        sEpoch.ranges.CPL2   = zeros(1000,88);
        sEpoch.ranges.SNRL1  = zeros(1000,88);
        sEpoch.ranges.SNRL2  = zeros(1000,88);
        sEpoch.ranges.SNRCA  = zeros(1000,88);
        sEpoch.ranges.PRCAL1 = zeros(1000,88);
        sEpoch.ranges.PRCAL2 = zeros(1000,88);
        sEpoch.ranges.TOW    = zeros(1000,1);
        sEpoch.ranges        = rinextodata([sEpoch.inputpath,'.o'], sEpoch.ranges);
        sEpoch.nbEpoch       = size(sEpoch.ranges.TOW,1);
        sEpoch.eph           = struct('time',[],'data',[]);
        sEpoch.eph           = rinextodata([sEpoch.inputpath,'.n'], sEpoch.eph);
        closer               = abs(sEpoch.ranges.TOW(end) - sEpoch.eph.time);
        [~,closer]           = min(closer);
        sEpoch.eph.data      = sEpoch.eph.data{closer};
    else
        error('data source not defined');
    end
        
end

