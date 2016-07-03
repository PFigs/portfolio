function st = ppplabstructs(name)
%PPPLABSTRUCTS returns structures definition for the PPPLAB suite
%   Please take into account that Epoch, Stat and Settings structure are
%   set to persistent, therefor clean ppplabstructs should be set in the
%   beggining of the startup script.
%
%   USAGE
%       sEpoch = ppplabstructs('Epoch');
%       It is only declared once, meaning that successive calls to it will
%       not wipe the structures that, but only return its values present in
%       memory
%
%   AVAILABLE STRUCTS
%   Epoch, Ranges, Stat, Settings, Algo, ...
%
%
%   RECOMMENDED
%       clear ppplabstructs; % clears function contents in memory
%       clear all; % also clears breakpoints
%
%   Pedro Silva, Instituto Superior Tecnico, April 2012

    persistent Epoch;
    persistent IMU;
    persistent Stat;
    persistent Settings;
    persistent Algo;
      
    
    % Ranges Structure contains information regarding the GPS sensor
    if strcmpi(name,'Ranges')
        Ranges = struct(...
                  'PRL1', NaN, 'CPL1', NaN,... % P-Code measurements in L1 frequency
                  'PRL2', NaN, 'CPL2', NaN,... % P-Code measurements in Le frequency
                  'CPCA', NaN, 'PRCA', NaN,... % C/A measurements in L1 frequency
                  'SNRL1',NaN, 'SNRL2',NaN,... % SNR values for P-Code
                  'SNRCA',NaN...               % SNR values for C/A-Code
                  );
        st = Ranges;
    
    % Epoch structure that contains information regarding each obs time
    elseif strcmpi(name,'Epoch') 
        if isempty(Epoch)
            Epoch = struct(...
                    'msgID',NaN,...                        % ID for online use
                    'IMU',NaN,...                          % IMU access and data
                    'logging',NaN,...                      % Flag for logging data
                    'iEpoch',NaN, 'nbEpoch', NaN,...       % Epoch counter (online = Inf)
                    'visibleSatsPCA',NaN,...               % Visible Sats CA
                    'visibleSatsCCA',NaN,...               % Visible Sats CA
                    'visibleSatsPL1',NaN,...               % Visible Sats P code L1
                    'visibleSatsPL2',NaN,...               % Visible Sats P Code L2
                    'visibleSatsCL1',NaN,...               % Visible Sats C. Phase L1
                    'visibleSatsCL2',NaN,...               % Visible Sats C. Phase L2
                    'slipl1',NaN,'slipl2',NaN,...          % Tables for cycle slip correction
                    'WD', NaN, 'WN', NaN, 'TOW', NaN,...   % Week info
                    'DOY',NaN,...                          % Day of Year
                    'ranges',NaN,'eph',NaN,...             % Measurements
                    'iono',NaN,...                         % For ionosphere coefficients
                    'receiver', NaN, 'inputpath', NaN, ... % Receiver name and input path
                    'operation', NaN,...                   % For flagging offline/online
                    'TOWGLO',NaN,...                       % GLONASS TOW 
                    'UTCoffset',NaN,...                    % Offset in hours to UTC
                    'lastSEQ',NaN,...                      % Last ASHTECH SEQ (GPS)
                    'lastSEQGLO',NaN,...                   % Last ASHTECH SEQ (GLONASS)
                    'getids',1:userparams('MAXSAT'),...    % number vector to index satellites
                    'rawmsg',NaN,...                       % receiver raw message
                    'dirty',NaN);                          % When IO should be done
%             Epoch.ranges = ppplabstructs('Ranges'); % DO NOT DO THIS! :)
            Epoch.IMU = ppplabstructs('IMU');
        end
        st = Epoch;   
    
    % IMU Structure
    elseif strcmpi(name,'IMU')
        if isempty(IMU)
            IMU = struct(...
                         'operation',NaN,...   % Flag for operation status
                         'receiver',NaN,...    % IMU identification
                         'inputpath',NaN,...   % Path to access IMU (file, COM,...)
                         'rate',NaN,...        % Measurement rate
                         'velocity',NaN,...    % Velocity information
                         'position',NaN,...    % Receiver displacement
                         'windowACC',NaN,...   % Window for Accelometer measures
                         'windowPOS',NaN,...   % Window for Position
                         'windowVEL',NaN,...   % Window for Velocity
                         'windowGYR',NaN,...   % Window for Gyroscope measures
                         'windowMAG',NaN...    % Window for Magnetometer measures
                         );
        end
        st = IMU;
        
    % Algo structure contains information necessary to the data processing
    % algorithms
    elseif strcmpi(name,'Algo')
        if isempty(Algo)
            Algo = struct(...
                    'algtype',NaN ,...          % Algorythm to use
                    'distance',NaN,...          % Distance to refpoint
                    'refpoint',NaN,...          % Algorythm reference point
                    'userxyz',NaN,...           % Current user position
                    'ranges',NaN,...            % Measurements used
                    'iono',NaN,...              % Ionosphere data
                    'eph',NaN,...               % Ephemerides used
                    'estimate',NaN,...          % Estimate vector for epoch
                    'residuals',NaN,...         % Residuals
                    'ambiguities',NaN,...       % Ambiguity vector
                    'covariance',NaN,...        % Covariance information 
                    'obsvariance',NaN,...       % Observation variance
                    'cosH',NaN,...              % Design matrix for xDOP calculation
                    'enuH',NaN,...              % Director cosines in ENU for H calculation
                    ... % Sats
                    'visibleSatsL1',NaN,...     % Watchdog for L1 sats
                    'visibleSatsL2',NaN,...     % Watchdog for L2 sats
                    'availableSat',NaN,...      % Sats to be used
                    'nSat',NaN,...              % Number of satellites
                    'lastavailableSat',NaN,...  % Last satellites available
                    'lastnSat',NaN,...          % Last number of available satellites
                    'satxyz',NaN,...            % Satellite coordinates in ECEF
                    'satenu',NaN,...            % Satellite coordinates in ENU
                    'satelv',NaN,...            % Satellite elevation
                    'sataz',NaN,...             % Satellite azimuth
                    ... % Cycle slips
                    'lgpredicted',NaN,...       % Predicted values for LG combination (cycle slips)
                    'mwpredicted',NaN,...       % Predicted values for LG combination (cycle slips)
                    ... % Flags
                    'flags',NaN...              % Flags structure
            );
        end
        Algo.ranges = ppplabstructs('Ranges');
        Algo.flags  = ppplabstructs('Algo.flags');
        st = Algo;

    elseif strcmpi(name,'Algo.flags') 
        st = struct(...
                    'orbitproduct',NaN,...      % Precise orbit product to use
                    'interpolation',NaN,...     % Interpolation method
                    'usepreciseorbits',NaN,...  % Flag for enabling precise data
                    'usepreciseclk',NaN,...     % Flag for using precise clocks
                    'usecycleslip',NaN,...      % Flag for processing cycle clips
                    'csalgorithm',NaN,...       % Cycle slip algorithm to use
                    'tropomodel',NaN,...        % Troposphere model to use
                    'ionomodel',NaN,...         % Ionosphere model to use
                    'usetropo',NaN,...          % Flag to use tropophsere model
                    'useiono',NaN,...           % Flag to use ionosphere model
                    'computedtr',NaN,...        % Flag for computing dtr
                    'polydegreesat',NaN,...     % Polynomial degree for sats
                    'polydegreeclk',NaN,...     % Polynomial degree for clocks
                    'method',NaN,...            % Interpolation method to use
                    'freqmode',NaN...           % Frequency operation mode
                    );

        
        
        
        
    % Stat structure contains statistical data regarding the
    % observations        
    elseif strcmpi(name,'Stat')
        if isempty(Stat)
            Stat = struct(...
                   'hit',NaN,...            % Counts the number of valid epochs
                   'ambiguities',[],...     % Ambiguity information
                   'refpoint',[],...        % Reference point vector
                   'userxyz',[],...         % User ECEF position vector
                   'userenu',[],...         % User ENU position vector 
                   'satxyz',[],...          % Satellite ECEF coordinates
                   'satenu',[],...          % Satellite ENU coordinates
                   'satelv',[],...          % Satellite elevation vector
                   'sataz',[],...           % Satellite azimuth vector
                   'usedsats',[],...        % Used satellites
                   'lgomc',[],...           % Residual value from the prediction
                   'mwomc',[],...           % Residual value from the prediction
                   'ioncpcombination',NaN,... % Tables for cycle slips
                   'ionprcombination',NaN,... % Tables for cycle slips
                   'ionpredictedcomb',NaN,... % Tables for cycle slips
                   'lgcombination',NaN,...  % Tables for cycle slips
                   'mwcombination',NaN,...  % Tables for cycle slips
                   'lgstd',NaN,...          % Contains [std, sum, sum of the squares]
                   'mwstd',NaN,...          % Contains [std, sum, sum of the squares]
                   'errposition',[],...     % Array for error in position
                   'sigmaamb',[],...        % Standard deviation for ambiguities
                   'sigmaclk',[],...        % Standard deviation for clock
                   'sigmapos',NaN,...       % Standard deviation for position error
                   'sigmaeast',NaN,...      % Standard deviation for EAST coordinate
                   'sigmanorth',NaN,...     % Standard deviation for NORTH coordinate
                   'sigmaup',NaN,...        % Standard deviation for UP coordinate
                   'meanerror',NaN,...      % Mean possition error
                   'pdop',NaN,...           % Position Dilution of precision
                   'hdop',NaN,...           % Horizontal Dilution of precision
                   'vdop',NaN,...           % Vertical Dilution of precision
                   'gdop',NaN...            % Geometric Dilution of precision
            );
        end
        st = Stat;

        
    % Struct that contains user input and parameters necessary for the
    % program operation
    elseif strcmpi(name,'Settings')
        if isempty(Settings)
            
            Settings = struct(...
                              'operation',NaN,...
                              'receiver',NaN,...
                              'algorithm',NaN,...
                              'time',NaN,...
                              'file',NaN,...
                              'graph',NaN);
            
            % defines specified structs
            Settings.receiver  = ppplabstructs('settings.receiver');
            Settings.algorithm = ppplabstructs('settings.algorithm');
            Settings.time      = ppplabstructs('settings.time');
            Settings.file      = ppplabstructs('settings.file');
            Settings.graph     = ppplabstructs('settings.graph');
            Settings.IMU       = ppplabstructs('settings.IMU');
        end
        st = Settings;        
        
        
    elseif strcmpi(name,'settings.receiver')
        st = struct(...
                    'name',NaN,...           % Receiver model (Pro flex 500,...)
                    'com',NaN,...            % Receiver COM port
                    'reset',NaN,...          % Receiver reset flag
                    'messages',NaN,...       % Messages to configure receiver
                    'configure',NaN,...      % Receiver configuration flag
                    'port',NaN,...           % Receiver port   
                    'rate',NaN,...           % Receiver measurements rate
                    'format',NaN,...         % Receiver output message format (BIN, DEC)
                    'mtp',NaN,...            % ?
                    'obsperiod',NaN,...      % Observation period
                    'logging',NaN,...        % Logging flag
                    'logtype',NaN,...        % Log type
                    'logpath',NaN...         % Path to save measurements in ONLINE mode                
                    );
                    
    elseif strcmpi(name,'settings.algorithm')
        st = struct(...
                    'name',NaN,...           % Algorithm to use 
                    'refpoint',NaN,...       % Reference point
                    'satvelocity',NaN,...
                    'freqmode',NaN,...       % Algorithm frequency mode
                    'interpolation',NaN,...  % Interpolation method
                    'orbitproduct',NaN,...   % Precise orbit product to use (IGS, ...)
                    'clockproduct',NaN,...   % Precise clock product to use (IGS, GMV, ...)
                    'csdetection',NaN,...    % Enabler for cycle slip detector
                    'cscorrection',NaN,...   % Enabler for cycle slip corrector
                    'csalgorithm',NaN,...    % Algorithm to use for cycle slip detection/correction
                    'tropomodel',NaN,...     % Troposhere model to use
                    'ionomodel',NaN...       % Ionosphere model to use
                    );
        
    elseif strcmpi(name,'settings.time')
        st = struct(...
                    'doy',NaN,...            % Day of year
                    'day',NaN,...            % Gregorian day
                    'month',NaN,...          % Gregorian month
                    'year',NaN,...           % Gregorian year
                    'gpsweekday',NaN,...     % GPS week day
                    'gpsweek',NaN,...        % GPS week
                    'gpstimeofweek',NaN...   % GPS time of week for first observation
                    );
        
    elseif strcmpi(name,'settings.file')
        st = struct(...
                    'folderpath',NaN,...     % Path to the folder containing measurements
                    'startingepoch',NaN,...  % First epoch to process from file
                    'finalepoch',NaN,...     % Final epoch to process from file
                    'logtype',NaN...         % Log type to be read
                    );
        
    elseif strcmpi(name,'settings.graph')
        st = struct(...
                    'lstates',zeros(4,1),... % Vector with left axes states (operation & grids)
                    'rstates',zeros(4,1),... % Vector with right axes states (operation & grids)
                    'llimits',zeros(6,1),... % Vector with left axes limits (x[low, high], y[low, high], z[low, high])
                    'rlimits',zeros(6,1),... % Vector with right axes limits (x[low, high], y[low, high], z[low, high])
                    'leftplottype',NaN,...
                    'rightplottype',NaN...
                    );    
                
    elseif strcmpi(name,'settings.IMU')
        st = struct(...
                    'useimu',NaN,...
                    'device',NaN,...
                    'rate',NaN...
            );
    else
        st = NaN;
    end
  
end