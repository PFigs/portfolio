function sAlgo = pppgao( sAlgo, TOW, DOY, WD )
%PPPGAO implements a precise point positioning solution.
%   This function uses a sequential filter to achieve PPP using a
%   combination provided by GAO
%
%   INPUT
%   #TODO
%
%   Pedro Silva, Instituto Superior Tecnico, April 2011
    % Runs SPP for initialization
    if sAlgo.count < userparams('initialconv')
        sAlgo = sppalgodf( sAlgo, TOW, DOY, WD);
        sAlgo.ignore = 1;
        return;
    end
    % Constants
    lbdf1   = gpsparams('lbdf1');
    lbdf2   = gpsparams('lbdf2');
    gama    = gpsparams('gama');
    nParams = 4;
    flags   = sAlgo.flags;
    userxyz = sAlgo.userxyz;
    rcvclk  = sAlgo.rcvclk;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';
    tropo   =1;


    phase  =(lbdf2.*sAlgo.ranges.CPL2 - gama.*lbdf1.*sAlgo.ranges.CPL1)./(1-gama);
    codeL1 = 0.5.*(sAlgo.ranges.PRL1+lbdf1.*sAlgo.ranges.CPL1);
    codeL2 = 0.5.*(sAlgo.ranges.PRL2+lbdf2.*sAlgo.ranges.CPL2);
    
    
    sAlgo.GAOCPI(sats,:) = insertsl(phase,sAlgo.GAOCPI(sats,:),1);
    sAlgo.GAOCL1(sats,:) = insertsl(codeL1,sAlgo.GAOCL1(sats,:),1);
    sAlgo.GAOCL2(sats,:) = insertsl(codeL2,sAlgo.GAOCL2(sats,:),1);

    m = sum(sAlgo.GAOCPI(sats,:)~=0,2);

    codeL1 = 1./m.*codeL1+(1-1./m).*(sAlgo.GAOCL1(sats,end-1) + phase - sAlgo.GAOCPI(sats,end-1));
    codeL2 = 1./m.*codeL2+(1-1./m).*(sAlgo.GAOCL2(sats,end-1) + phase - sAlgo.GAOCPI(sats,end-1));
%     smooth(sAlgo);

    windup   = sAlgo.windup(sats);
    rcvenu   = eceftoenu( userxyz, sAlgo.refpoint(1,:),'ECEF');
    
    Q        = zeros(nParams+nSat*2,nParams+nSat*2);
    Q(1:4,1:4) = sAlgo.noise{1};
    ambL1    = sAlgo.ambiguitiesL1(sats);
    ambL2    = sAlgo.ambiguitiesL2(sats);
    
    X = [ userxyz';
          rcvclk;
          ambL1;
          ambL2;
        ];
    C = zeros(nParams+nSat*2,nParams+nSat*2);
    C(1:nParams,1:nParams) = sAlgo.covariance{1};
    C(nParams+1:nParams+nSat,nParams+1:nParams+nSat) = sAlgo.covariance{2}(sats,sats);
    C(nParams+1+nSat:nParams+2*nSat,nParams+1+nSat:nParams+2*nSat) = sAlgo.covariance{3}(sats,sats);
%     C(nParams+1:end,nParams+1:end) = sAlgo.covariance{2}(sats,sats);
%     C(nSat*2+nParams+1:end,nParams+1:end) = sAlgo.covariance{2}(sats,sats);
%     Q(1:nParams,1:nParams)         = sAlgo.noise{1};
%     Q(nParams+1:end,nParams+1:end) = sAlgo.noise{2}(sats,sats);
    
    [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw,satxyzdiff,satclkdiff] ...
                            = getConstellation(sAlgo.iEpoch,DOY,WD,TOW,userxyz,eph,...
                            flags,tropo,rcvenu,windup,sAlgo.antex,sAlgo.sun);
    H  = [ 
          -cosvec ones(nSat,1) eye(nSat)        zeros(nSat,nSat);%   eye(nSat);
          -cosvec ones(nSat,1) zeros(nSat,nSat) eye(nSat) ;
        ];
    
    
    R  = getMeasurementsWeight(nSat,ura,satelv,sAlgo.ranges.SNR); % Weight Matrix             
    
    % Init new sats
    newsats           = ambL1 == 0;
    if any(newsats)
        ambL1(newsats)  = (codeL1(newsats) - nvec(newsats) + satclk(newsats) - zpd(newsats) - rcvclk);
    end
    newsats           = ambL2 == 0;
    if any(newsats)
        ambL2(newsats)  = (codeL2(newsats) - nvec(newsats) + satclk(newsats) - zpd(newsats) - rcvclk);
    end
    
    % Compute residualssatclk  - eph.tgd'
    Z = zeros(nSat*2,1); %- gpsparams('c')*eph.tgd' - gpsparams('c')*gpsparams('gama').*eph.tgd'
    Z(1:nSat,1)        = codeL1 + satclk - ( nvec  + rcvclk + zpd + ambL1);  
    Z(nSat+1:nSat*2,1) = codeL2 + satclk - ( nvec  + rcvclk + zpd + ambL2);
    
    X(nParams+1:end,1) = [ambL1;ambL2;];

    % Parameter updates
    dX = (H'/R*H + inv(C))\H'/R*Z;
    X  = X + dX;
    
    % Weight coefficient matrix
    Edt = sAlgo.iEpoch-sAlgo.lastseen;
    Q(4,4) = X(4)/sAlgo.rcvclk ;
    if ~isnan(Edt), Q = Q.*Edt; end;
    C = inv(H'/R*H + inv(C)) + Q;
%     V = Z-H*dX;    
%     if nSat*2 == nParams
%         P = V'/R*V; %trace(C)
%     else
%         P = V'/R*V./(nSat*2-nParams); %trace(C)
%     end
%     C = P./C;
    
    residuals       = Z-H*dX;
    sAlgo.residuals = zeros(nSat,2);
    

    % ESTIMATED
    sAlgo.userxyz                   = X(1:3)';
    sAlgo.rcvclk                    = X(4);
    sAlgo.ambiguitiesL1(sats)       = X(nParams+1:nParams+nSat);
    sAlgo.ambiguitiesL2(sats)       = X(nParams+nSat+1:end);
    sAlgo.residuals(:,1)            = residuals(1:nSat);
    sAlgo.residuals(:,2)            = residuals(nSat+1:end);
    sAlgo.windup(sats)              = windup;
    
    % PREDITECD
    sAlgo.covariance{1}             = C(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = C(nParams+1:nParams+nSat,nParams+1:nParams+nSat);
    sAlgo.covariance{3}(sats,sats)  = C(nParams+1+nSat:nParams+2*nSat,nParams+1+nSat:nParams+2*nSat);
    sAlgo.satxyz(sats,:)            = satxyzdiff;
    sAlgo.satclk(sats)              = satclkdiff;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = sataz;
    sAlgo.cosH                      = H;

end

