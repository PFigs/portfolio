function sAlgo = pppitkalman( sAlgo, TOW, DOY, WD )
%PPPKALMAN implements a precise point positioning solution.
%   This function uses an iterated kalman filter to achieve PPP
%
%   Pedro Silva, Instituto Superior Tecnico, April 2011

    % Constants
    lbdf1   = gpsparams('lbdf1');
    lbdf2   = gpsparams('lbdf2');
    gama    = gpsparams('gama');
    tropo   = sAlgo.flags.usetropo;
    if tropo
        nParams = 4;
    else
        nParams = 5;
    end
    
    % IONO FREE RANGE COMBINATIONS
    flags   = sAlgo.flags;
    if sAlgo.flags.useiono
        code     = (sAlgo.ranges.PRL2 - gama*sAlgo.ranges.PRL1)./(1-gama);
        phase    = (lbdf2*sAlgo.ranges.CPL2 - gama*lbdf1*sAlgo.ranges.CPL1)./(1-gama);
    else
        code     = sAlgo.ranges.PRL1;
        phase    = sAlgo.ranges.CPL1;
        flags.freqmode = 'L1';
    end
    
    % INIT
    userxyz = sAlgo.userxyz;
    rcvclk  = sAlgo.rcvclk;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';

    % Runs SPP for initialization
    if sAlgo.count < 3
        sAlgo             = sppalgodf( sAlgo, TOW, DOY, WD);
        return;
    elseif sAlgo.count == 3
%         sSPP              = sppalgodf( sAlgo, TOW, DOY, WD);
%         userxyz           = sSPP.userxyz;
%         sAlgo.estimate    = {};
%         sAlgo.estimate{1} = [sSPP.userxyz, sSPP.rcvclk];
    end
    windup  = sAlgo.windup(sats);
    rcvenu  = eceftoenu( userxyz, sAlgo.refpoint(1,:),'ECEF');
    amb     = sAlgo.ambiguities(sats);
    [X,P,Q] = getModelMatrices(sAlgo,nSat,sats,amb,nParams);
    Xp      = X;
    Phi     = eye(nParams + nSat);   
    count   = 0;
    while count < 500
        [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw]...
                   = getConstellation(DOY,WD,TOW,...
                     userxyz,eph,flags,tropo,rcvenu,windup,sAlgo.antex);
        [Z,amb]    = getObservedMinusComputed(nSat,nvec,satclk,...
                        rcvclk,zpd,code,phase,amb,windup); % Residuals
        H          = getDesignMatrix(nSat,cosvec,tropo,mw);  % Design Matrix - Jacobian
        R          = getMeasurementsWeight(nSat,ura,satelv); % Weight Matrix             
        Xp(nParams+1:end) = amb;
        
        % Measurement update
        K = P*H'/(H*P*H'+R);           % Kalman Gain     - H[i]
        X = Xp + K*(Z);    
               
        userxyz = X(1:3)';
        rcvclk  = X(4);
        amb     = X(nParams+1:end);
        P = P - K*H*P;  
        
%         sqrt(sum((X-Xp).^2,2))
        
        if all(sqrt(sum((X-Xp).^2,2)) < 1e-06)
            break
        end
        Xp = X;
        
        count = count +1;
    end
    
    if count == 500
        disp('oh oh')
    end
    
    %         X = Xm + K*(Z - H*X - H*(Xm-X)); % Estimate update - residuals[i-1]
    %                       Z  
    
    % Time update (next state)
    Q(4,4) = mean(X(4))/Xp(4);       
    X      = Phi*X;
    P      = Phi*P*Phi'+Q;
    
    % ESTIMATED
    sAlgo.userxyz                   = X(1:3)';
    sAlgo.rcvclk                    = X(4);
    sAlgo.ambiguities(sats)         = X(nParams+1:end);
    sAlgo.residuals                 = Z-H*K*(Z);
    sAlgo.windup(sats)              = windup;
    
     % PREDITECD
    sAlgo.estimate{1}               = X(1:nParams);
    sAlgo.estimate{2}(sats,:)       = X(nParams+1:end);
    sAlgo.covariance{1}             = P(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = P(nParams+1:end,nParams+1:end);
    sAlgo.obsvariance{1}            = Q(1:nParams,1:nParams);
    sAlgo.obsvariance{2}(sats,sats) = Q(nParams+1:end,nParams+1:end);
    
    sAlgo.satxyz                    = satxyz;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = sataz;
    sAlgo.cosH                      = H;
    
end

