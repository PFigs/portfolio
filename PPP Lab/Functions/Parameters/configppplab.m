function [sEpoch, sAlgo, sStat] = configppplab( sSettings )
%CONFIGPPPLAB initialises the structures needed for the program operation
%   
%   INPUT
%   sSettings - Receives a structure with param information and
%   initialization
%
%   OUTPUT
%   SEPOCH - Structure ready for given operation
%   SALGO  - Structure to receive algorythm details
%   SSTAT  - Structure to keep statistic information
%
%   Pedro Silva, Instituto Superior Tecnico, April 2012

    % Cleans old connections
    if ~isempty(instrfind)
        fclose(instrfind);
        delete(instrfind);
    end
           
    % Copies output variables to output
    sEpoch = ppplabstructs('Epoch');
    sStat  = ppplabstructs('Stat');
    sAlgo  = ppplabstructs('Algo');
    
    % Converts operation to flag
    if strcmpi(sSettings.operation,'ONLINE')
        operation = 1;
    else
        operation = 0;
    end
    
    %IMU operation
    sEpoch.IMU.operation = sSettings.IMU.useimu;
    if sSettings.IMU.useimu
        sEpoch.IMU.operation = sSettings.IMU.useimu;
        sEpoch.IMU.receiver  = sSettings.IMU.device;
        sEpoch.IMU.rate      = sSettings.IMU.rate;
        sEpoch.IMU.grange    = 'scale2g';
        
        if operation
            sEpoch.IMU.inputpath = configdevice(sSettings.IMU.com, sEpoch.IMU.receiver, sSettings);
        else
            sEpoch.IMU.logfyle   = sSettings.IMU.logfile ; 
        end
        sEpoch.IMU.windowACC = NaN(3,100); %100 epoch window
        sEpoch.IMU.windowGYR = NaN(4,100); %100 epoch window
        sEpoch.IMU.windowMAG = NaN(3,100); %100 epoch window 
        sEpoch.IMU.windowVEL = NaN(3,100); %100 epoch window 
        sEpoch.IMU.windowPOS = NaN(3,100); %100 epoch window 
        
        sEpoch.IMU.windowACC(:,end) = 0;
        sEpoch.IMU.windowGYR(:,end) = 0;
        sEpoch.IMU.windowMAG(:,end) = 0;
        sEpoch.IMU.windowVEL(:,end) = 0;
        sEpoch.IMU.windowPOS(:,end) = 0;
        
        sEpoch.IMU.velocity         = zeros(1,3);
        sEpoch.IMU.position         = zeros(1,3);
        sEpoch.IMU.iniflag          = 1;
        sEpoch.IMU.position         = 0;
        if sSettings.IMU.calibrate && operation
            commandrcv(sEpoch.IMU.inputpath,sEpoch.IMU.receiver,'CAL');
        end
    end
    
    
    % Sets values for EPOCH
    % ONLINE PROCESSING
    if operation
        sEpoch.operation      = 1; % ONLINE
        sEpoch.receiver       = sSettings.receiver.name;  
        sEpoch.iEpoch         = 0; 
        sEpoch.nbEpoch        = Inf; 
        sEpoch.WD             = weekday(datenum(date))-1;
        sEpoch.WN             = 0; % set in obtain data
        sEpoch.TOW            = 0; % set in obtain data
        sEpoch.UTCoffset      = 1;
        sEpoch.DOY            = sSettings.time.doy;
        sEpoch.eph            = NaN;
        sEpoch.dirty          = 0;
        sEpoch.logging        = sSettings.receiver.logging;
        sEpoch.logpath        = sSettings.receiver.logpath;
        sEpoch.freqmode       = sSettings.algorithm.freqmode;
        sEpoch.inputpath      = configdevice(sSettings.receiver.com, sEpoch.receiver,sSettings);
        sEpoch.visibleSatsPCA = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsPL1 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsPL2 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsCL1 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsCL2 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.slipl1         = zeros(userparams('MAXSAT'),1);
        sEpoch.slipl2         = zeros(userparams('MAXSAT'),1);
        if sEpoch.logging
            clk = clock;
            hour = sprintf('%02d',clk(4));
            min  = sprintf('%02d',clk(5));
            sec  = sprintf('%02d',round(clk(6))); 
            sEpoch.logpath = strcat(sEpoch.logpath,hour,min,sec,sEpoch.receiver,date,'/');
            if ~exist(sEpoch.logpath,'dir')
                mkdir(sEpoch.logpath);
                mkdir(sEpoch.logpath,'ion'); 
                mkdir(sEpoch.logpath,'eph'); 
                mkdir(sEpoch.logpath,'mes');
                mkdir(sEpoch.logpath,'raw');
                if sSettings.IMU.useimu
                    mkdir(sEpoch.logpath,'imu');
                    sEpoch.IMU.logfyle=[sEpoch.logpath,'imumes.txt'];
                end

            end
        end

    % OFFLINE PROCESSING
    else
        sEpoch.operation      = 0; % OFFLINE
        sEpoch.receiver       = sSettings.file.logtype;
        sEpoch.iEpoch         = 0;
        sEpoch.UTCoffset      = 1;
        sEpoch.DOY            = sSettings.time.doy;
        sEpoch.WD             = 0; % set in obtain data
        sEpoch.WN             = 0; % set in obtain data
        sEpoch.dirty          = 0;
        sEpoch.logging        = 0;
        sEpoch.visibleSatsPCA = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsCCA = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsPL1 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsPL2 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsCL1 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.visibleSatsCL2 = zeros(userparams('MAXSAT'),userparams('largearray'));
        sEpoch.slipl1         = zeros(userparams('MAXSAT'),1);
        sEpoch.slipl2         = zeros(userparams('MAXSAT'),1);
        
        % BINFILE is seen as a receiver
        if strcmpi(sEpoch.receiver,'BINFILE')
            sEpoch.inputpath  = configdevice(sSettings.file.folderpath, sEpoch.receiver,sSettings);
            sEpoch.nbEpoch    = Inf;
            
            % Checks if the custom range is valid (not bigger than file)
            if ~isnan(sSettings.file.finalepoch)   
                if sSettings.file.finalepoch < sEpoch.nbEpoch
                    sEpoch.nbEpoch = sSettings.file.finalepoch;
                end
            end 
            
        % General case such as SNFILE
        else
            sEpoch.inputpath  = sSettings.file.folderpath;   
            sEpoch            = obtaindata(sEpoch); % Read data from files
            
            if strcmpi(sEpoch.receiver,'RINEX')
               try
                   sSettings.algorithm.refpoint = sEpoch.ranges.refpoint;
               end
            end
            
            % Validates the starting epoch
            if isnan(sSettings.file.startingepoch)            
                sEpoch.iEpoch = 0;
            else
                sEpoch.iEpoch = sSettings.file.startingepoch - 1;
            end
            
            % Checks if the custom range is valid (not bigger than file)
            if ~isnan(sSettings.file.finalepoch)   
                if sSettings.file.finalepoch < sEpoch.nbEpoch
                    sEpoch.nbEpoch = sSettings.file.finalepoch;
                end
            end 
            sEpoch.visibleSatsPCA = zeros(userparams('MAXSAT'),sEpoch.nbEpoch);
            sEpoch.visibleSatsCCA = zeros(userparams('MAXSAT'),sEpoch.nbEpoch);
            sEpoch.visibleSatsPL1 = zeros(userparams('MAXSAT'),sEpoch.nbEpoch);
            sEpoch.visibleSatsPL2 = zeros(userparams('MAXSAT'),sEpoch.nbEpoch);
            sEpoch.visibleSatsCL1 = zeros(userparams('MAXSAT'),sEpoch.nbEpoch);
            sEpoch.visibleSatsCL2 = zeros(userparams('MAXSAT'),sEpoch.nbEpoch);
        end
        
    end
    
    
    % Sets values for ALGO
    sAlgo.algtype                = sSettings.algorithm.name;
    sAlgo.refpoint               = sSettings.algorithm.refpoint;
    sAlgo.userxyz                = sSettings.algorithm.refpoint;
    sAlgo.availableSat           = [];
    sAlgo.satelv                 = NaN(userparams('MAXSAT'),1);
    sAlgo.satvelocity            = sSettings.algorithm.satvelocity;
    sAlgo.nSat                   = 0;
    sAlgo.lastavailableSat       = zeros(32,1);
    sAlgo.lastnSat               = [];
    sAlgo.rcvclk                 = 1;
    sAlgo.ambiguities            = zeros(32,1); %vector of ambiguities - change to sat definition
    sAlgo.ambiguitiesL1          = zeros(32,1);
    sAlgo.ambiguitiesL2          = zeros(32,1);
    sAlgo.residuals              = [];
    sAlgo.sun                    = [];
    sAlgo.stdL1                  = zeros(userparams('MAXSAT'),4);
    sAlgo.stdL2                  = zeros(userparams('MAXSAT'),4);
    sAlgo.type                   = 'static'; 
    sAlgo.lgpredicted            = NaN(userparams('MAXSAT'),1);
    sAlgo.mwpredicted            = NaN(userparams('MAXSAT'),1);
    sAlgo.visibleSats            = ones(userparams('MAXSAT'),1).*userparams('visiblewatchdog');
    
    sAlgo.flags.smooth           = sSettings.algorithm.smooth;
    sAlgo.flags.antex            = sSettings.algorithm.antex;
    sAlgo.flags.freqmode         = sSettings.algorithm.freqmode;
    sAlgo.flags.orbitproduct     = sSettings.algorithm.orbitproduct;
    sAlgo.flags.clockproduct     = sSettings.algorithm.clockproduct;
    sAlgo.flags.interpolation    = sSettings.algorithm.interpolation;
    sAlgo.flags.usepreciseorbits = strncmpi(sAlgo.flags.orbitproduct,'Best',4) || strncmpi(sAlgo.flags.orbitproduct,'IG',2) || strcmpi(sAlgo.flags.orbitproduct,'GMV');
    sAlgo.flags.usepreciseclk    = strncmpi(sAlgo.flags.clockproduct,'Best',4) || strncmpi(sAlgo.flags.clockproduct,'IG',2) || strcmpi(sAlgo.flags.clockproduct,'GMV');
    sAlgo.flags.usecycleslip     = sSettings.algorithm.csdetection;
    sAlgo.flags.csalgorithm      = sSettings.algorithm.csalgorithm;
    sAlgo.flags.tropomodel       = sSettings.algorithm.tropomodel;
    sAlgo.flags.ionomodel        = sSettings.algorithm.ionomodel;
    sAlgo.flags.usetropo         = ~isnan(sAlgo.flags.tropomodel(1)) && ~strcmpi(sAlgo.flags.tropomodel,'None');
    sAlgo.flags.useiono          = ~isnan(sAlgo.flags.tropomodel(1)) && ~strcmpi(sAlgo.flags.ionomodel,'None'); 
    sAlgo.flags.polydegreesat    = sSettings.algorithm.polydegreesat;
    sAlgo.flags.polydegreeclk    = sSettings.algorithm.polydegreeclk;
    sAlgo.flags.computedtr       = sSettings.algorithm.computedtr;
    sAlgo.flags.datagaps         = sSettings.algorithm.datagaps;
    
    sAlgo.imuCPL1                = zeros(userparams('MAXSAT'),5);
    sAlgo.imuCPL2                = zeros(userparams('MAXSAT'),5);
    
    sAlgo.pCPL1                  = zeros(userparams('MAXSAT'),5);
    sAlgo.pCPL2                  = zeros(userparams('MAXSAT'),5);
    sAlgo.pPRL1                  = zeros(userparams('MAXSAT'),5);
    sAlgo.pPRL2                  = zeros(userparams('MAXSAT'),5);
    sAlgo.dRangeL1               = zeros(userparams('MAXSAT'),5);
    sAlgo.dRangeL2               = zeros(userparams('MAXSAT'),5);    
    
    sAlgo.slipdetectl1           = zeros(userparams('MAXSAT'),1);
    sAlgo.slipdetectl2           = zeros(userparams('MAXSAT'),1);
    sAlgo.type                   = sSettings.algorithm.rcvdynamic;
    
    sAlgo.addartificialcs        = sSettings.algorithm.artificialcs;
    sAlgo.artificialcsl1         = sSettings.algorithm.artificialcsl1;
    sAlgo.artificialcsl2         = sSettings.algorithm.artificialcsl2;
    sAlgo.artificialepoch        = sSettings.algorithm.artificialepoch;
    sAlgo.cssatellites           = sSettings.algorithm.cssatellites;
    
    if sSettings.algorithm.antex
        sAlgo.sun     = readsunhorizons(['Aquisition/',sSettings.algorithm.horizons],10*3600,20*3600);
        sAlgo.sun.TOW = sAlgo.sun.TOW + sEpoch.WD*24*60*60;
    end
    
    if exist('IGSFiles/atx/igs08.atx','file')
        sAlgo.antex = rinextodata('IGSFiles/atx/igs08.atx',[],'ATX');
    else
        disp('Antex file not found...');
    end
    
%     disp('----> Static UNB VMF!')
%     lla          = eceftolla(sAlgo.refpoint(1,:));
%     sAlgo.unbvmf = readunbvmf('IGSFiles/UNBVMFG_20120803.H12.txt',lla(1),lla(2),4);   
%     if ~strcmpi(sSettings.algorithm.name,'SPP') || strcmpi(sSettings.algorithm.name,'sppdf')
        
    if sAlgo.flags.usetropo
        sSettings.algorithm.filterNoise(5) = [];
        sSettings.algorithm.filterVar(5)   = [];
    end

    sAlgo.estimate        = [{[sAlgo.refpoint,0]} {zeros(userparams('MAXSAT'),1)}];
    sAlgo.covariance      = [{diag(sSettings.algorithm.filterVar(1:end-1))};...
        {diag(ones(userparams('MAXSAT'),1).*sSettings.algorithm.filterVar(end))};
        {diag(ones(userparams('MAXSAT'),1).*sSettings.algorithm.filterVar(end))}];
    sAlgo.obsvariance     = {zeros(userparams('MAXSAT'),userparams('MAXSAT'))};
    sAlgo.noise           = [{diag(sSettings.algorithm.filterNoise(1:end-1))};...
        {ones(userparams('MAXSAT'),userparams('MAXSAT')).*sSettings.algorithm.filterNoise(end)}];
    sAlgo.filter.Noise    = sSettings.algorithm.filterNoise;
    sAlgo.filter.Variance = sSettings.algorithm.filterVar;


    sAlgo.scountL1  = ones(32,1);
    sAlgo.smoothPR1 = zeros(32,1);
    sAlgo.scountL2  = ones(32,1);
    sAlgo.smoothPR2 = zeros(32,1);
    sAlgo.GAOCPI    = zeros(32,100); %100 epoch window
    sAlgo.GAOCL1    = zeros(32,100); %100 epoch window
    sAlgo.GAOCL2    = zeros(32,100); %100 epoch window
    
    % TODO: SET NUMBER OF REFERENCE POINTS Needs structs
    % Sets default values for STAT
    if operation || strcmpi(sEpoch.receiver,'BINFILE')
        nbEpoch = userparams('largearray'); 
    else
        nbEpoch = sEpoch.nbEpoch;
    end 
    
    
    sAlgo.windup         = zeros(userparams('MAXSAT'),1);
    sAlgo.SNRCA          = NaN(userparams('MAXSAT'),nbEpoch);
    sAlgo.SNRL1          = NaN(userparams('MAXSAT'),nbEpoch);
    sAlgo.SNRL2          = NaN(userparams('MAXSAT'),nbEpoch);
    sAlgo.lastseen       = NaN;
    sAlgo.sigmaclk       = 100;
    sAlgo.count          = 1;
    sAlgo.satxyz         = NaN(userparams('MAXSAT'),3);
    
    sStat.hit            = 0;
    sStat.refpoint       = sAlgo.refpoint; 
    sStat.userxyz        = NaN(nbEpoch,3);
    sStat.userenu        = NaN(nbEpoch,3);
    sStat.rcvclk         = NaN(nbEpoch,1);
    sStat.sigmaclk       = NaN(nbEpoch,1);
    sStat.satclk         = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.ambiguities    = zeros(userparams('MAXSAT'),nbEpoch);
    sStat.ambiguitiesL1  = zeros(userparams('MAXSAT'),nbEpoch);
    sStat.ambiguitiesL2  = zeros(userparams('MAXSAT'),nbEpoch);
    sStat.sigmaamb       = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.usedsats       = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.satelv         = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.sataz          = NaN(userparams('MAXSAT'),nbEpoch);
    
    sStat.residuals      = {NaN(userparams('MAXSAT'),nbEpoch);NaN(userparams('MAXSAT'),nbEpoch)};
    
    sStat.satx            = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.saty            = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.satz            = NaN(userparams('MAXSAT'),nbEpoch);
    
    sStat.sigmaeast      = NaN(nbEpoch,1);
    sStat.sigmanorth     = NaN(nbEpoch,1);
    sStat.sigmaup        = NaN(nbEpoch,1);

    sStat.cpl1std        = zeros(userparams('MAXSAT'),3); % var mean N
    sStat.prl1std        = zeros(userparams('MAXSAT'),3); % var mean N
    sStat.cpl2std        = zeros(userparams('MAXSAT'),3); % var mean N
    sStat.prl2std        = zeros(userparams('MAXSAT'),3); % var mean N
    
    sStat.dopl1std       = zeros(userparams('MAXSAT'),4); % var mean N
    sStat.dopl2std       = zeros(userparams('MAXSAT'),4); % var mean N
    
    
    sStat.lgomc          = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.mwomc          = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.tecomc         = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.dopomcl2       = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.dopomcl1       = NaN(userparams('MAXSAT'),nbEpoch);
    
    sStat.lgth           = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.tecth          = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.mwth           = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.dopthl1        = NaN(userparams('MAXSAT'),nbEpoch);
    sStat.dopthl2        = NaN(userparams('MAXSAT'),nbEpoch);
    
    sStat.OBSPRL1        = zeros(32,nbEpoch); % var mean N
    sStat.OBSPRL2        = zeros(32,nbEpoch); % var mean N
    sStat.OBSCPL1        = zeros(32,nbEpoch); % var mean N
    sStat.OBSCPL2        = zeros(32,nbEpoch); % var mean N
    
    sStat.ionprcombination  = NaN(userparams('MAXSAT'),10);
    sStat.ioncpcombination  = NaN(userparams('MAXSAT'),10);
    sStat.ionpredictedcomb  = NaN(userparams('MAXSAT'),10);
    sStat.teccpl1           = NaN(userparams('MAXSAT'),30);
    sStat.teccpl2           = NaN(userparams('MAXSAT'),30);
    sStat.lgcombination     = NaN(userparams('MAXSAT'),10);
    sStat.mwcombination     = NaN(userparams('MAXSAT'),10);
    sStat.lgstd             = zeros(userparams('MAXSAT'),5);
    sStat.mwstd             = zeros(userparams('MAXSAT'),5);
    sStat.tecstd            = zeros(userparams('MAXSAT'),5);
    
    sStat.lifetime          = zeros(userparams('MAXSAT'),1); % time of life
    sStat.pdop              = NaN(nbEpoch,1);
    sStat.hdop              = NaN(nbEpoch,1);
    sStat.vdop              = NaN(nbEpoch,1);
    sStat.gdop              = NaN(nbEpoch,1);

    sStat.tecstd(:,3)    = gpsparams('lbdfw')/2;
    


end


