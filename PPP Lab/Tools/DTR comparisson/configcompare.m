function [sEpoch, sAlgo, sStat] = configcompare( operation, varargin )
%CONFIGPPPLAB configures a structure for the intended operation
%   
%   INPUT
%   OPERATION - Can either be ONLINE (1) or OFFLINE (0)
%
%   OUTPUT
%   SEPOCH - Structure ready for given operation
%   SALGO  - Structure to receive algorythm details
%   SSTAT  - Structure to keep statistic information
%
%   Pedro Silva, Instituto Superior Tecnico, January 2012

    % Declarations - Set default values in the bottom
    persistent Epoch;
    persistent Stat;
    
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

    sAlgo = struct(...
          'cosH',NaN,...                         % Design matrix for xDOP calculation
          'enuH',NaN,...                         % Director cosines in ENU for H calculation
          'algtype',NaN ,...                     % Algorythm to use
          'refpoint',NaN,...                     % Algorythm reference point
          'userxyz',NaN,...                      % Current user position
          'ranges',NaN,...                       % Measurements used
          'iono',NaN,...                         % Ionosphere data
          'eph',NaN,...                          % Ephemerides used
          'zpd',NaN,...                          % Estimation for ZPD
          'rcvclk',NaN,...                       % Estimation for Receiver clock
          'amb',NaN,...                          % Ambiguities estimation
          'cov',NaN,...                          % Covariance matrix
          'distance',NaN,...                     % Distance to refpoint
          'availableSat',NaN,...                 % Sats to be used
          'nSat',NaN,...                         % Number of satellites
          'lastSats',NaN,...                     % Last satellites available
          'lastNSats',NaN,...                    % Last number of available satellites
          'satxyz',NaN,...                       % Satellite coordinates in ECEF
          'satenu',NaN,...                       % Satellite coordinates in ENU
          'satelv',NaN,...                       % Satellite elevation
          'sataz',NaN...                         % Satellite azimuth
      );
  
    sRanges = struct(...
          'PRL1', NaN, 'CPL1', NaN,...           % P-Code measurements in L1 frequency
          'PRL2', NaN, 'CPL2', NaN,...           % P-Code measurements in Le frequency
          'CPCA', NaN, 'PRCA', NaN,...           % C/A measurements in L1 frequency
          'SNRL1',NaN, 'SNRL2',NaN,...           % SNR values for P-Code
          'SNRCA',NaN...                         % SNR values for C/A-Code
      );             
    
    Stat = struct(...
          'refpoint',[],...                      % Reference point vector
          'userxyz',[],...                       % User ECEF position vector
          'userenu',[],...                       % User ENU position vector 
          'satxyz',[],...                        % Satellite ECEF coordinates
          'satenu',[],...                        % Satellite ENU coordinates
          'satelv',[],...                        % Satellite elevation vector
          'sataz',[],...                         % Satellite azimuth vector
          'errposition',[],...                   % Array for error in position
          'errx',[],...                          % Array for error in X
          'erry',[],...                          % Array for error in Y
          'errz',[],...                          % Array for error in Z
          'sigmapos',NaN,...                     % Standard deviation for position error
          'sigmaeast',NaN,...                    % Standard deviation for East coordinate
          'sigmanorth',NaN,...                   % Standard deviation for North coordinate
          'meanerror',NaN,...                    % Mean possition error
          'pdop',NaN,...                         % Position Dilution of precision
          'hdop',NaN,...                         % Horizontal Dilution of precision
          'vdop',NaN,...                         % Vertical Dilution of precision
          'gdop',NaN...                          % Geometric Dilution of precision
      );

    % Copies output variables to output
    sEpoch = Epoch;
    sStat  = Stat;  
    

    % Sets default values for EPOCH  
    sEpoch.msgID    = 'SNFILE';
    sEpoch.iEpoch    = 0; % set in obtain data
    sEpoch.WD        = 0; % set in obtain data
    sEpoch.WN        = 0; % set in obtain data
    sEpoch.receiver  = 'SNFILE'; % default
    sEpoch.inputpath = '../../Aquisition/rcvdata/';
    sEpoch.operation = 0; % OFFLINE
    sEpoch.dirty     = 0;
    sEpoch           = obtaindata(sEpoch); %
   
    
    % Sets default values for ALGO
    sAlgo.algtype      = 'SPP';
    sAlgo.refpoint     = [4918533.320,-791212.572, 3969758.451]; % Professor's
    sAlgo.userxyz      = [0,0,0];
    sAlgo.ranges       = sRanges;
    sAlgo.availableSat = [];
    sAlgo.nSat         = 0;
    sAlgo.lastSats     = [];
    sAlgo.lastNSats    = [];
   
    
    % Sets default values for STAT
    st(1:sEpoch.nbEpoch) = struct('data',[]);
    sStat.refpoint = [4918533.320,-791212.572, 3969758.451]; % Professor's
    sStat.satxyz   = st;
    sStat.satenu   = st;
    sStat.satelv   = st;
    sStat.sataz    = st;
    sStat.satclk   = st;
end


