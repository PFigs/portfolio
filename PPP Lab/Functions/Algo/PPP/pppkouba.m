function sAlgo = pppkouba( sAlgo, TOW, DOY, WD )
%PPPALGO implements a precise point positioning solution.
%   This function implements the standard PPP method and should be
%   universal to all kind of receivers.
%   
%   INPUT
%   USERXYZ - ECEF coordinates of the last receiver position estimate
%
%   PARAM - Parameters outputed by the filter, by order (x,y,z,clock,tropo,
%   ambiguities);
%
%   RANGE - Struct with the available data for the current constellation.
%           It must contain at least code, phase and TOW information.
%           The struct should use PRLx and CPLx for code and phase
%           measurements with x designing the frequency it relates to.
%
%   EPH - Contains the OMEGADOT information for the current satellite
%         constelation.
%         
%   OUTPUT
%   USERPOS - ECEF Position of the user
%   ERROR METRICS - Some error metrics (too develop)
%
%   Reference:
%   J. Kouba, 
%   �A guide to using International GNSS Service (IGS) products,� 
%   Geodetic Survey Division, Natural Resources Canada, OttawaMay, 2009. [Online]. 
%   Available: http://graypantherssf.igs.org/igscb/resource/pubs/UsingIGSProductsVer21.pdf.
%
%   Pedro Silva, Instituto Superior Técnico, Novembro 2011


    % Runs SPP for initialization
   if sAlgo.count < userparams('initialconv')
       sAlgo = sppalgodf( sAlgo, TOW, DOY, WD);
       sAlgo.ignore = 1;
       return;
   elseif sAlgo.count == 1 && userparams('initialconv') == 0
       sAlgo = sppalgodf( sAlgo, TOW, DOY, WD);
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
    userxyz = sAlgo.userxyz;
    rcvclk  = sAlgo.rcvclk;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';
   

    amb      = sAlgo.ambiguities(sats);
    [X,C,Q]  = getModelMatrices(sAlgo,nSat,sats,amb,nParams);
    windup   = sAlgo.windup(sats);
    rcvenu   =[];% eceftoenu( userxyz, sAlgo.refpoint(1,:),'ECEF');
    [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw,satxyzdiff,satclkdiff]  ...
               = getConstellation(sAlgo.iEpoch,DOY,WD,TOW,...
                  userxyz,eph,flags,tropo,rcvenu,windup,sAlgo.antex,sAlgo.sun);
    H          = getDesignMatrix(nSat,cosvec,tropo,mw);  % Design Matrix - Jacobian
    R          = getMeasurementsWeight(nSat,ura,satelv,sAlgo.ranges.SNR); % Weight Matrix             
    [Z,amb]    = getObservedMinusComputed(nSat,nvec,satclk,...
             rcvclk,zpd,code,phase,amb,windup); % Residuals     
    X(nParams+1:end,1) = amb;

    % Parameter updates
    dX      = (H'/R*H + inv(C))\H'/R*Z;
    X       = X + dX;

    
    % Weight coefficient matrix
    Edt = sAlgo.iEpoch-sAlgo.lastseen;
    Q(4,4) = X(4)/sAlgo.rcvclk ;
    if ~isnan(Edt), Q = Q.*Edt; end;

    C = inv(H'/R*H + inv(C)) + Q;
% if sAlgo.count > 2
%     V = Z-H*dX;    
%     if nSat*2 == nParams
%         P = V'/R*V; %trace(C)
%     else
%         P = V'/R*V./trace(C); %(nSat*2-nParams); %
%     end
%     C = P.*C;
% end
%     if any(sum(Z)>trace(P(1:4,1:4)))
%        disp('NOooot goood'); 
%     end
    

    residuals = Z-H*dX;
    sAlgo.residuals   = zeros(nSat,2);

    % ESTIMATED
    sAlgo.userxyz                   = X(1:3)';
    sAlgo.rcvclk                    = X(4);
    sAlgo.ambiguities(sats)         = X(nParams+1:end);
    sAlgo.residuals(:,1)            = residuals(1:nSat);
    sAlgo.residuals(:,2)            = residuals(nSat+1:end);
    sAlgo.windup(sats)              = windup;
    
    % PREDITECD
    sAlgo.estimate{1}               = X(1:nParams);
    sAlgo.estimate{2}(sats,:)       = X(nParams+1:end);
    sAlgo.covariance{1}             = C(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = C(nParams+1:end,nParams+1:end);
    
    sAlgo.satxyz(sats,:)            = satxyzdiff;
    sAlgo.satclk(sats)              = satclkdiff;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = sataz;
    sAlgo.cosH                      = H;
    
end


%     W(1:nSat,1)                    = code  - nvec + c.*satclk - zpd;  
%     W(nSat+1:nSat*2,1)             = phase - nvec + c.*satclk - zpd;
%     if all(W > 4.47*postvar)
%         disp('no no no')
%     else
%         disp('yes yes yes')
%     end