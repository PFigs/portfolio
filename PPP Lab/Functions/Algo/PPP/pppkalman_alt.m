function sAlgo = pppkalman( sAlgo, TOW, DOY, WD )
%PPPKALMAN implements a precise point positioning solution.
%   This function uses a kalman filter to achieve PPP
%
%   INPUT
%   #TODO
%
%   Pedro Silva, Instituto Superior Tecnico, April 2011

    % Assert entries
    assert(all(sAlgo.ranges.PRL1~=0));
    assert(all(sAlgo.ranges.PRL2~=0));
    assert(all(sAlgo.ranges.CPL1~=0));
    assert(all(sAlgo.ranges.CPL2~=0));
    
    
    % Constants
    c       = gpsparams('C');
    lbdf1   = gpsparams('lbdf1');
    lbdf2   = gpsparams('lbdf2');
    gama    = gpsparams('gama');
    if sAlgo.flags.usetropo    
        nParams = 4;
    else
        nParams = 5;
    end
    
    % IONO FREE RANGE COMBINATIONS
    flags   = sAlgo.flags;
    if flags.useiono
        code     = (sAlgo.ranges.PRL2 - gama*sAlgo.ranges.PRL1)./(1-gama);
        phase    = (lbdf2*sAlgo.ranges.CPL2 - gama*lbdf1*sAlgo.ranges.CPL1)./(1-gama);
    else
        code     = sAlgo.ranges.PRL1;
        phase    = sAlgo.ranges.CPL1;
        flags.freqmode = 'L1';
    end
    userxyz = sAlgo.userxyz;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';
   
    P   = zeros(nParams+nSat,nParams+nSat);
    Q   = zeros(nParams+nSat,nParams+nSat);
    X   = zeros(nParams+nSat,1);
    Phi = eye(nParams + nSat);

    if ~sum(sAlgo.ambiguities)

        % Runs SPP for initialization
        sSPP = sppalgodf( sAlgo, TOW, DOY, WD );

        % Weight matrix P
        P(1:nParams,1:nParams)         = diag(sAlgo.filter.Variance(1:4));
        P(nParams+1:end,nParams+1:end) = diag(ones(nSat,1).*sAlgo.filter.Variance(end));         
        
        % Variance Matrix Q 
        Q(1:nParams,1:nParams)         = diag(sAlgo.filter.Noise(1:4));
        Q(nParams+1:end,nParams+1:end) = diag(ones(nSat,1).*sAlgo.filter.Noise(end));
        
        % Estimate
        X(1:3,1)                      = sSPP.userxyz;
        X(4,1)                        = 0;
        X(nParams+1:nParams + nSat,1) = phase - code;
        
        sAlgo.pclk                    = 1;
    else
        
        % Statistical information
        X(1:3,1)                       = userxyz;
        X(4,1)                         = sAlgo.rcvclk;
        X(nParams+1:end,1)             = sAlgo.ambiguities(sats);

        P(1:nParams,1:nParams)         = sAlgo.covariance{1};
        P(nParams+1:end,nParams+1:end) = sAlgo.covariance{2}(sats,sats);
        
        Q(1:nParams,1:nParams)         = sAlgo.obsvariance{1};
        Q(nParams+1:end,nParams+1:end) = sAlgo.obsvariance{2}(sats,sats);
                
    end
    
    % Obtain satellite coordinates
    [satxyz, satclk] = precisepos(userxyz, eph, WD, TOW, flags, sAlgo.antex); 
    
    % Obtain corrections
    [cosvec, enuvec, satenu, nvec] = directorcos(userxyz,satxyz,'enu');
    satelv                         = elevation(enuvec,'rad');
    lla                            = eceftolla(userxyz);
    [zpd,drycomp,mw]               = zenithdelay(lla(1),lla(3),satelv,DOY); 
    % Design and OMC calculations
    if sAlgo.flags.usetropo
            H                      = [ 
                                     -cosvec ones(nSat,1) zeros(nSat,nSat) ; % Code
                                     -cosvec ones(nSat,1) eye(nSat)  % Phase
                                     ];
            Z(1:nSat,1)            = code  - diag(cosvec*satxyz') + c.*satclk - zpd;  
            Z(nSat+1:nSat*2,1)     = phase - diag(cosvec*satxyz') + c.*satclk - zpd;            
    else
            H                      = [ 
                                       -cosvec ones(nSat,1) ones(nSat,1).*mw zeros(nSat,nSat) ; % Code
                                       -cosvec ones(nSat,1) ones(nSat,1).*mw eye(nSat)  % Phase
                                     ];
            Z(1:nSat,1)            = code  - diag(cosvec*satxyz') + c.*satclk - drycomp;  
            Z(nSat+1:nSat*2,1)     = phase - diag(cosvec*satxyz') + c.*satclk - drycomp;
     end
    
    % Variance Matrix R 
    R(1:nSat,1:nSat)               = diag(ura.^2./(sin(satelv).^2)); % Code csc(satelv)
    R(nSat+1:nSat*2,nSat+1:nSat*2) = diag(ura.^2./(sin(satelv).^2)); % Phase    
    
    % Measurement update
    K  = P*H'/(H*P*H'+R);   % Kalman Gain
    X  = X + K*(Z-H*X);      % Estimate update
    P  = P - K*H*P;         % Update the error covariance
    
    % Clock prediction
    nclock = sAlgo.ranges.PRL1- (nvec - satclk);
    dclock = nclock./sAlgo.pclk;
    Q(4,4) = mean(dclock);
    if dclock < 0.9    
        dclock
        pause(0.2);
    end
    % Position Prediction
    X      = Phi*X;
    P      = Phi*P*Phi'+Q;
    
    % Final atributions
    sAlgo.userxyz                   = X(1:3)';
    sAlgo.rcvclk                    = X(4);
    sAlgo.ambiguities(sats)         = X(nParams+1:end);
    
    sAlgo.pclk                      = mean(sAlgo.ranges.PRL1 - (nvec - satclk));
    sAlgo.distance                  = norm(sAlgo.refpoint-sAlgo.userxyz);
    sAlgo.satxyz                    = satxyz;
    sAlgo.satenu                    = satenu;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = azimuth(satenu,'rad');
    sAlgo.cosH                      = H;
    sAlgo.enuH                      = [-enuvec ones(nSat,1)];
    
    sAlgo.estimate{1}               = X;
    sAlgo.estimate{2}(sats,:)       = X(nParams+1:end);
    
    sAlgo.covariance{1}             = P(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = P(nParams+1:end,nParams+1:end);
    
    sAlgo.noise{1}                  = Q(1:nParams,1:nParams);
    sAlgo.noise{2}(sats,sats)       = Q(nParams+1:end,nParams+1:end);
    
    sAlgo.residuals                 = Z-H*X; 
end






%%% Experimental
%         P(1,1)                         = 50000; 
%         P(2,2)                         = 50000; 
%         P(3,3)                         = 50000; 
%         P(4,4)                         = 2000;
% %         P(5,5)                         = 0.1;
%         P(nParams+1:end,nParams+1:end) = eye(nSat).*10^12;   
%         P(1,1)                         = 2000; 
%         P(2,2)                         = 2000; 
%         P(3,3)                         = 2000; 
%         P(4,4)                         = 500;


% Lambda try outs    
% try
%     
%         [ambint,sqnorm] = lambda2(X(nParams+1:end),P(nParams+1:end,nParams+1:end));
% catch
%     pause(0.1);
% end
%     % Output arguments:
%     %    afixed: Estimated integers (colunas com int)
%     %    sqnorm: Distance between candidates and float ambiguity vector
%     %    Qzhat : Decorrelated variance/covariance matrix
%     %    Z     : Transformation matrix
%     Xp = X(1:nParams);
%      H                 = [ 
%                            -cosvec ones(nSat,1) ; % Code
%                            -cosvec ones(nSat,1)  % Phase
%                          ];
%     Z(1:nSat,1)        = code  - diag(cosvec*satxyz') + c.*satclk - zpd;  
%     Z(nSat+1:nSat*2,1) = phase - diag(cosvec*satxyz') + c.*satclk - zpd - ambint(:,1);
% %     X                  = (H'/R*H)\(H'/R*Z);
% 
%     M = P(1:nParams,1:nParams);
%     
%     % Measurement update
%     K  = M*H'/(H*M*H'+R);   % Kalman Gain
%     X = Xp + K*(Z-H*Xp);      % Estimate update
%     M  = M - K*H*M;         % Update the error covariance
% 
%     
%     
%         % Final atributions
%     sAlgo.userxyz              = X(1:3)';
%     sAlgo.rcvclk               = X(4);
%     sAlgo.ambiguities(sats)    = ambint(:,1);
%     sAlgo.distance             = norm(sAlgo.refpoint-sAlgo.userxyz);
%     sAlgo.pclk                 = mean(code - (nvec - sAlgo.rcvclk));
%     
% %     sAlgo.estimate{1}       = dX;
% %     sAlgo.estimate{2}       = dX(nParams+1:end);
%     sAlgo.estimate{1}               = X;
%     sAlgo.estimate{2}(sats,:)       = ambint(:,1);
%     sAlgo.residuals                 = Z-H*X;