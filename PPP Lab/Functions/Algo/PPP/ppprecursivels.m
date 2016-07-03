function sAlgo = ppprecursivels( sAlgo, TOW, DOY, WD  )
%PPPRECURSIVELS Summary of this function goes here
%   Detailed explanation goes here

    % Assert entries
    assert(all(sAlgo.ranges.PRL1~=0));
    assert(all(sAlgo.ranges.PRL2~=0));
    assert(all(sAlgo.ranges.CPL1~=0));
    assert(all(sAlgo.ranges.CPL2~=0));
    
    % Runs SPP for initialization
    if sAlgo.count <  userparams('initialconv')
        sAlgo        = sppalgodf( sAlgo, TOW, DOY, WD);
        sAlgo.ignore = 1;
        return;
    end
    
    % Constants
    c       = gpsparams('C');
    lbdf1   = gpsparams('lbdf1');
    lbdf2   = gpsparams('lbdf2');
    gama    = gpsparams('gama');
    nParams = 4;
    
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
    tropo   = sAlgo.flags.usetropo;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';
   
    windup = sAlgo.windup(sats);
    rcvenu = [];% eceftoenu( userxyz, sAlgo.refpoint(1,:),'ECEF');
    
    [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw,satxyzdiff,satclkdiff] ...
               = getConstellation(sAlgo.iEpoch,DOY,WD,TOW,...
                  userxyz,eph,flags,tropo,rcvenu,windup,sAlgo.antex,sAlgo.sun);
    [Z,amb]    = getObservedMinusComputed(nSat,nvec,satclk,...
                 rcvclk,zpd,code,phase,sAlgo.ambiguities(sats),windup); % Residuals
    H          = getDesignMatrix(nSat,cosvec,tropo,mw);  % Design Matrix - Jacobian
    R          = getMeasurementsWeight(nSat,ura,satelv,sAlgo.ranges.SNR); % Weight Matrix             
    [X,P,~]    = getModelMatrices(sAlgo,nSat,sats,amb,nParams);
   
    % Estimator
    S = H*P*H' + R;
    W = P*H'/S;  % P(k)
    P = P - W*S*W';    
    W = P*H'/R;  % Alternative with P(k+1)
    X = X + W*(Z);    
   
    % Final atributions
    residuals       = Z;
    sAlgo.residuals = zeros(nSat,2);
    % ESTIMATED
    sAlgo.userxyz                   = X(1:3)';
    sAlgo.rcvclk                    = X(4);
    sAlgo.ambiguities(sats)         = X(nParams+1:end);
    sAlgo.residuals(:,1)            = residuals(1:nSat);
    sAlgo.residuals(:,2)            = residuals(nSat+1:end);
    sAlgo.windup(sats)              = windup;
    
    % PREDITECD
    sAlgo.inovation                 = W*Z;
    sAlgo.estimate{1}               = X(1:nParams);
    sAlgo.estimate{2}(sats,:)       = X(nParams+1:end);
    sAlgo.covariance{1}             = P(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = P(nParams+1:end,nParams+1:end);
%     sAlgo.obsvarianceCode(sats)     = diag(R);
%     sAlgo.obsvariancePhase(sats)    = diag(R);
    sAlgo.satxyz(sats,:)            = satxyzdiff;
    sAlgo.satclk(sats)              = satclkdiff;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = sataz;
    sAlgo.cosH                      = H;
    
    

end



