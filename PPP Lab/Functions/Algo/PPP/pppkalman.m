function sAlgo = pppkalman( sAlgo, TOW, DOY, WD )
%PPPKALMAN implements a precise point positioning solution.
%   This function uses a kalman filter to achieve PPP
%
%   INPUT
%   #TODO
%       IF missing EPOCH then Q*dt
%
%   Pedro Silva, Instituto Superior Tecnico, April 2011

    % Runs SPP for initialization
    if sAlgo.count < userparams('initialconv')
        sAlgo = sppalgodf( sAlgo, TOW, DOY, WD);
        sAlgo.ignore = 1;
        return;
%     elseif sAlgo.count == userparams('initialconv')+1
%         sAlgo.ignore = 1;
    end

    % Assert entries
    assert(all(sAlgo.ranges.PRL1~=0));
    assert(all(sAlgo.ranges.PRL2~=0));
    assert(all(sAlgo.ranges.CPL1~=0));
    assert(all(sAlgo.ranges.CPL2~=0));
    
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
    if flags.useiono
        code           = (sAlgo.ranges.PRL2 - gama*sAlgo.ranges.PRL1)./(1-gama);
        phase          = (lbdf2*sAlgo.ranges.CPL2 - gama*lbdf1*sAlgo.ranges.CPL1)./(1-gama);
    else
        code           = sAlgo.ranges.PRL1;
        phase          = sAlgo.ranges.CPL1;
        flags.freqmode = 'L1';
    end
    
    
    % INIT
    userxyz = sAlgo.estimate{1}(1:3);
    rcvclk  = sAlgo.estimate{1}(4);
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';


    
    windup = sAlgo.windup(sats);
    rcvenu = [];% eceftoenu( userxyz, sAlgo.refpoint(1,:),'ECEF');
    %TODO: GO UP WITH THIS. COMMIT FIRST!
    [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw,satxyzdiff,satclkdiff] ...
               = getConstellation(sAlgo.iEpoch,DOY,WD,TOW,...
                  userxyz,eph,flags,tropo,rcvenu,windup,sAlgo.antex,sAlgo.sun);
    [Z,amb]    = getObservedMinusComputed(nSat,nvec,satclk,...
                 rcvclk,zpd,code,phase,sAlgo.ambiguities(sats),windup); % Residuals
    H          = getDesignMatrix(nSat,cosvec,tropo,mw);  % Design Matrix - Jacobian
    R          = getMeasurementsWeight(nSat,ura,satelv,sAlgo.ranges.SNR); % Weight Matrix             
    [X,P,Q]    = getModelMatrices(sAlgo,nSat,sats,amb,nParams);
    
    % Measurement update
    K  = P*H'/(H*P*H'+R);  % Kalman Gain
    X  = X + K*Z;          % Estimate update
    P  = P - K*H*P;        % Update the error covariance    

    % Time update (next state)
    Edt = sAlgo.iEpoch-sAlgo.lastseen;
    if ~isnan(Edt), Q = Q.*Edt; end;
%     Q(4,4) = mean(X(4))/sAlgo.rcvclk;
    Phi    = eye(nParams + nSat);          
    Xnew   = Phi*X;
    P      = Phi*P*Phi'+Q;
        
    residuals = Z;
    sAlgo.residuals = zeros(nSat,2);
    % ESTIMATED
    sAlgo.userxyz                   = X(1:3)';
    sAlgo.rcvclk                    = X(4);
    sAlgo.ambiguities(sats)         = X(nParams+1:end);
    sAlgo.residuals(:,1)            = residuals(1:nSat);
    sAlgo.residuals(:,2)            = residuals(nSat+1:end);
    sAlgo.windup(sats)              = windup;
    
    % PREDITECD
    sAlgo.inovation                 = K*Z;
    sAlgo.estimate{1}               = Xnew(1:nParams)';
    sAlgo.estimate{2}(sats,:)       = Xnew(nParams+1:end);
    sAlgo.covariance{1}             = P(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = P(nParams+1:end,nParams+1:end);
    sAlgo.noise{1}                  = Q(1:nParams,1:nParams);
    sAlgo.noise{2}(sats,sats)       = Q(nParams+1:end,nParams+1:end);
%     sAlgo.obsvarianceCode(sats)     = diag(R);
%     sAlgo.obsvariancePhase(sats)    = diag(R);
    sAlgo.satxyz(sats,:)            = satxyzdiff;
    sAlgo.satclk(sats)              = satclkdiff;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = sataz;
    sAlgo.cosH                      = H;

end

%     skipped = sAlgo.skipped>1;
%     if any(skipped>1)
%         sAlgo.covariance{2}(sats(skipped)*sAlgo.skipped,sats(skipped)*sAlgo.skipped);
%     end

