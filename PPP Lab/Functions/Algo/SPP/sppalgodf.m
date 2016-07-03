function [sAlgo,health] = sppalgodf( sAlgo, TOW, DOY, WD)
%SPPALGODF implements a single point positioning solution.
%   This function implements the standard point positioning method which
%   uses the information provided by the GNSS system. In other others, no
%   auxiliary data is pushed from the Internet.
%   This function will receive and process data valid for only one epoch.
%   
%   NOTE:  THE SO CALLED MISCLOSURE VECTOR!  
%       pseudo(i) - dot(cosvec(i,:),satxyz(i,:))
%
%   INPUT
%   DOY   - Day of Year
%   TOW   - Time of Week
%   SALGO - Struct with the available data for the current constellation.
%           It must contain at least code, phase and TOW information.
%           The struct should use PRLx and CPLx for code and phase
%           measurements with x designing the frequency it relates to.
%         
%   OUTPUT
%   SALGO - Structure with updated fields
%
%   Pedro Silva, Instituto Superior Tecnico, Novembro 2011

% Com correcao antena 4918533.83206218         -791212.393040957          3969757.83920876

    % Constants
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
    
    % Initializations
    ura     = sAlgo.eph.ura';
    sats    = sAlgo.availableSat;
    userxyz = sAlgo.userxyz;
    rcvclk  = sAlgo.rcvclk;
    flags   = sAlgo.flags;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    health  = 0;
    TOL     = userparams('tol');
    
    if sAlgo.flags.useiono
        code     = (sAlgo.ranges.PRL2 - gama.*sAlgo.ranges.PRL1)./(1-gama);
        phase    = (lbdf2.*sAlgo.ranges.CPL2 - gama.*lbdf1*sAlgo.ranges.CPL1)./(1-gama);
    else
        code     = sAlgo.ranges.PRL1;
        phase    = sAlgo.ranges.CPL1;
        flags.freqmode = 'L1';
    end
    
    rcvenu = eceftoenu( userxyz, sAlgo.refpoint(1,:),'ECEF');
    windup = sAlgo.windup(sats);
    
    count = 0;
    amb   = sAlgo.ambiguities(sats);
    X     = getModelMatrices(sAlgo,nSat,sats,amb,nParams);
    
    % Iterative computation
    while count < 100
        
        [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw,satxyzdiff,satclkdiff] ...
                            = getConstellation(sAlgo.iEpoch,DOY,WD,TOW,userxyz,eph,flags,tropo,rcvenu,windup,sAlgo.antex,sAlgo.sun);
        [Z,amb]             = getObservedMinusComputed(nSat,nvec,satclk,...
                              rcvclk,zpd,code,phase,amb,windup); % Residuals
        H                   = getDesignMatrix(nSat,cosvec,tropo,mw);  % Design Matrix - Jacobian
        R                   = getMeasurementsWeight(nSat,ura,satelv,sAlgo.ranges.SNR); % Weight Matrix             
        X(nParams+1:end,1)  = amb;
        dX                  = (H'/R*H)\(H'/R*Z); % offset
        X                   = X + dX;
        
        userxyz = X(1:3)';
        rcvclk  = X(nParams);    
        amb     = X(nParams+1:end);
        
        % Verifies break 
        if all(abs(dX) < TOL)
            health = 1;
            break
        end
        count = count + 1;
    end
    
    residuals         = Z-H*dX;
    sAlgo.residuals   = zeros(nSat,2);
    
    % Final atributions
    sAlgo.estimate{1}         = X(1:nParams);
    sAlgo.estimate{2}(sats,:) = X(nParams+1:end);
    sAlgo.ambiguities(sats)   = X(nParams+1:end);
    sAlgo.userxyz             = userxyz;
    sAlgo.rcvclk              = rcvclk;
    sAlgo.residuals(:,1)      = residuals(1:nSat);
    sAlgo.residuals(:,2)      = residuals(nSat+1:end);
    sAlgo.satxyz(sats,:)      = satxyzdiff;
    sAlgo.satclk(sats)        = satclkdiff;
    sAlgo.satelv(sats)        = satelv;
    sAlgo.sataz               = sataz;
    sAlgo.cosH                = H; 
    sAlgo.nvec                = nvec;
    sAlgo.zpd                 = zpd;
    sAlgo.windup(sats)        = windup;
    
    P = inv(H'/R*H+eye(size(H,2)));
    V = Z-H*dX;
    rNum = (nSat*2-(nParams+nSat));
    if rNum
        C = V'/R*V./rNum;
    else
        C = V'/R*V;
    end
    C = C./P;
%     C = ones(nParams+nSat);
    sAlgo.covariance{1}             = C(1:nParams,1:nParams);
    sAlgo.covariance{2}(sats,sats)  = C(nParams+1:end,nParams+1:end);
    sAlgo.covariance{3}(sats,sats)  = C(nParams+1:end,nParams+1:end);
end

%
%     sAlgo.covariance = sAlgo.residuals'*P*sAlgo.residuals/n;
%
%     Multipath computation
%     sAlgo.M1        = sAlgo.ranges.PRL1 - sAlgo.ranges.CPL1 ...
%                     + 2/(1-(77/60)^2).*(sAlgo.ranges.CPL1 - sAlgo.ranges.CPL2);
%     sAlgo.M2        = sAlgo.ranges.PRL2 - sAlgo.ranges.CPL2 ...
%                     + 2*(77/60)^2/(1-(77/60)^2).*(sAlgo.ranges.CPL1 - sAlgo.ranges.CPL2);

    %     Multipath computation
%     b = 1./(1-gama);
%     
%     codeL1  = sAlgo.ranges.PRL1;
%     codeL2  = sAlgo.ranges.PRL2;
%     phaseL1 = lbdf1.*sAlgo.ranges.CPL1;
%     phaseL2 = lbdf2.*sAlgo.ranges.CPL2;
%     sAlgo.M1(sAlgo.iEpoch,sats)  = codeL1 + (2*b-1).*phaseL1 - 2*b.*phaseL2;
%     sAlgo.M2(sAlgo.iEpoch,sats)  = codeL2 + (2*gama*b).*phaseL1 - (1+2*gama*b).*phaseL2;
  

% % Obtain satellite coordinates
% [satxyz, satclk]               = precisepos( userxyz, eph, WD, TOW, flags, sAlgo.antex); 
% [cosvec, enuvec, satenu, nvec] = directorcos(userxyz,satxyz,'enu');
% 
% % Obtain corrections
% satelv = elevation(enuvec,'rad');
% if flags.usetropo
%     lla = eceftolla(userxyz);
%     zpd = zenithdelay(lla(1),lla(3),satelv,DOY); 
% else
%     zpd = 0;
% end