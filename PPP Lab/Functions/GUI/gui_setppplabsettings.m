function sSettings = gui_setppplabsettings(screen,debug)
%SETPPPLABSETTINGS sets the sSettings structure according to the user
%defined settings on the settings panel of the PPPLab GUI
%
%   INPUT
%   SCREEN - User selected sttings
%
%   OUTPUT
%   SETTINGS - PPPLab settings structure
%
%   Pedro Silva, Instituto Superior Tecnico, July 2012
    
    sSettings                     = ppplabstructs('Settings');
    sSettings.displaymode         = screen.displaymode;
    sSettings.graph.leftplottype  = 1;
    sSettings.graph.rightplottype = 1;
    % OPERATION SETTINGS
    % ONLINE
    if screen.online.enablebutton
        sSettings.operation             = 'online';
        sSettings.receiver.obsperiod    = screen.online.gpsobsperiod;
        sSettings.receiver.rate         = screen.online.gpsrate;
        sSettings.receiver.reset        = screen.online.gpsreset;
        sSettings.receiver.configure    = screen.online.gpsconf;
        sSettings.receiver.logging      = screen.online.gpsstore;
        sSettings.receiver.com          = screen.online.gpscom;
        sSettings.IMU.useimu            = screen.online.useimu;
        
%%% TODO        
        if strcmpi(screen.online.gpsreceiverstr,'Pro Flex 500')
            sSettings.receiver.name = 'proflex';
            sSettings.receiver.messages = 'SNV,MPC,ION';
        elseif strcmpi(screen.online.gpsreceiverstr,'ZXW')
            sSettings.receiver.name = 'zxw';
            sSettings.receiver.messages = 'SNV,DBN';
        elseif strcmpi(screen.online.gpsreceiverstr,'uBlox 6T')
            sSettings.receiver.name = 'ublox';
            sSettings.receiver.messages = 'EPH,HUI,RAW';
        elseif strcmpi(screen.online.gpsreceiverstr,'AC12')
            sSettings.receiver.name = 'ac12';
            sSettings.receiver.messages = 'MCA,SNV';
        end
        
%%% TODO
        sSettings.receiver.logpath      = 'Aquisition/';
        if strcmpi(screen.online.gpslog,'SN')
           sSettings.receiver.logtype = 'SNFILE';
        elseif strcmpi(screen.online.gpslog,'RINEX')
           sSettings.receiver.logtype = 'RINEX';
        elseif strncmpi(screen.online.gpslog,'BIN',3)
           sSettings.receiver.logtype = 'BINFILE';
        end


        clk                          = clock;
        sSettings.time.day           = clk(3);
        sSettings.time.month         = clk(2);
        sSettings.time.year          = clk(1);
        sSettings.time.startingepoch = 1;
        sSettings.time.finalepoch    = Inf;
        sSettings.time.doy           = fix(dayofyear());
        sSettings.time.operation     = 'online';
        

    % OFFLINE
    else
        sSettings.operation          = 'offline';
        sSettings.receiver.obsperiod = inf;
        sSettings.file.folderpath    = screen.offline.gpsdisplaypath;
        if strcmpi(screen.online.gpslogstr,'SN')
           sSettings.file.logtype = 'SNFILE';
        elseif strcmpi(screen.online.gpslogstr,'RINEX')
           sSettings.file.logtype = 'RINEX';
        elseif strncmpi(screen.online.gpslogstr,'BIN',3)
           sSettings.file.logtype = 'BINFILE';
        end
        sSettings.receiver.logging = 0;
        sSettings.time.doy           = dayofyear(screen.offline.gpsyear,...
                                       screen.offline.gpsmonth, ...
                                       screen.offline.gpsday);  % Dados salgueiro     
        sSettings.time.day           = screen.offline.gpsday;
        sSettings.time.month         = screen.offline.gpsmonth;
        sSettings.time.year          = screen.offline.gpsyear;
        sSettings.file.finalepoch    = screen.offline.gpsstartepoch;
        sSettings.file.startingepoch = screen.offline.gpsfinalepoch;
        sSettings.IMU.useimu         = screen.offline.readimu;
    end
    
    % ALGO SEETINGS
    if strcmpi(screen.algo.algoselectorstr,'SPP')
        sSettings.algorithm.name     = 'spp';
        sSettings.algorithm.freqmode = 'L1';
    elseif strcmpi(screen.algo.algoselectorstr,'PPP kouba')
        sSettings.algorithm.name = 'pppkouba';
        sSettings.algorithm.freqmode = 'L1L2';
    elseif strcmpi(screen.algo.algoselectorstr,'PPP Gao')
        sSettings.algorithm.name = 'pppgao';
        sSettings.algorithm.freqmode = 'L1L2';
    elseif strcmpi(screen.algo.algoselectorstr,'PPP It. Kalman')
        sSettings.algorithm.name = 'pppiteratedkalman';
        sSettings.algorithm.freqmode = 'L1L2';
    end
    sSettings.algorithm.interpolation = screen.algo.algointerpolationstr;
    sSettings.algorithm.orbitproduct  = screen.algo.algoorbitproductstr;
    sSettings.algorithm.clockproduct  = screen.algo.algoclockproduct;
    sSettings.algorithm.polydegreesat = screen.algo.algopolysatdeg;
    sSettings.algorithm.polydegreeclk = screen.algo.algopolyclkdeg;
    sSettings.algorithm.satvelocity   = screen.algo.algosatvelocitystr;
%     sSettings.algorithm.csdetection   = screen.algo.algocsdetection;
%     sSettings.algorithm.cscorrection  = screen.algo.algocscorrection;
%     sSettings.algorithm.datagaps      = screen.algo.algodatagaps;
    
    if screen.algo.algotropocorrection
        sSettings.algorithm.tropomodel = 'Best';
    else
        sSettings.algorithm.tropomodel = 'None';
    end
    
    if screen.algo.algoionocorrection 
        sSettings.algorithm.ionomodel = 'Best';
    else
        sSettings.algorithm.ionomodel = 'None';
    end
   
%%% TODO
    smooth      = 0;            % enable smoothing
    antex       = 0;            % enable usage of antex files
    cyclesl     = 0;            % enable cycle slip detection and correction
    dummycs     = 0;            % enable artificial cycle slip to be added
    datagap     = 0;            % perform data regeneration
   
    rcvdynamic  = 'static';     % either static or dynamic
    horizonstxt = 'horizons_results03August-2.txt'; % Sun ephs
    imufile     = 'Aquisition/imuoffline.log';
    
    sSettings.report.runname    = 'L15L20'; % Name to identify this run
    sSettings.report.outputpath = 'Aquisition/170914proflex03-Aug-2012/';

    %Artificial cycle slips
    csl1        = 0;
    csl2        = 2;
    startepoch  = inf;
    cssats      = [3 6];

    sSettings.algorithm.refpoint      = [4918533.320,-791212.572,3969758.451];
    sSettings.algorithm.computedtr    = 0;
    sSettings.algorithm.csalgorithm   = 0; 
%     sSettings.displaymode             = displaymode;
    
    sSettings.algorithm.horizons      = horizonstxt;
    sSettings.algorithm.smooth        = smooth;
    sSettings.algorithm.antex         = antex;
    sSettings.algorithm.csdetection   = cyclesl;
    sSettings.algorithm.cscorrection  = cyclesl;
    sSettings.algorithm.csalgorithm   = 0;
    sSettings.algorithm.datagaps      = datagap;
    sSettings.algorithm.rcvdynamic    = rcvdynamic;
    
    
    sSettings.algorithm.filterVar    = [10 10 10 500 0.1 100]; % will affect P
    sSettings.algorithm.filterNoise  = [0 0 0 10 0 0];         % will affect Q
    sSettings.algorithm.filterDyn    = [0 0 0 30 0];          % Phi static
    
    sSettings.algorithm.artificialcs    = dummycs;
    sSettings.algorithm.artificialcsl1  = csl2;
    sSettings.algorithm.artificialcsl2  = csl1;
    sSettings.algorithm.artificialepoch = startepoch;
    sSettings.algorithm.cssatellites    = cssats;

    % IMU SETTINGS
    if strcmpi(screen.imu.enable,'on')
        sSettings.IMU.useimu    = 1;
        sSettings.IMU.com       = screen.imu.imucom;
        sSettings.IMU.device    = screen.imu.imudevicestr;
        sSettings.IMU.rate      = screen.imu.imurate; 
        sSettings.IMU.calibrate = screen.imu.imucalibrate;
        sSettings.IMU.logging   = screen.imu.imustore;
    else
        sSettings.IMU.useimu    = 0;
        sSettings.IMU.logfile   = imufile;
    end

end