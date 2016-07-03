function [sAlgo,health] = sppalgo( sAlgo, TOW, DOY, WD )
%SPPALGO implements a precise point positioning solution.
%   This function implements the standard point positioning method which
%   uses the information provided by the GNSS system. In other others, no
%   auxiliary data is pushed from the Internet.
%   This function will receive and process data valid for only one epoch.
%   
%   NOTE:  THE SO CALLED MISCLOSURE VECTOR!  
%       pseudo(i) - dot(cosvec(i,:),satxyz(i,:))
%
%   INPUT
%   WD    - Week Day
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
    c    = gpsparams('C');
    
    % Initializations
    userxyz = sAlgo.userxyz;
    rcvclk  = sAlgo.rcvclk;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';
    iono    = sAlgo.iono;
    TOL     = userparams('tol');
    flags   = sAlgo.flags;
    fmode   = flags.freqmode;
    if strcmpi(fmode,'L1')
        ranges = sAlgo.ranges.PRL1;
    elseif strcmpi(fmode,'L2')
        ranges = sAlgo.ranges.PRL2;
    else
%         error('not able to run for L1L2');
         flags.useiono = 0;
        gama   = gpsparams('gama');
        ranges = (sAlgo.ranges.PRL2 - gama.*sAlgo.ranges.PRL1)./(1-gama);
%         ranges = sAlgo.ranges.PRL1;
%         flags.freqmode = 'L1';
    end
    
    
    X(1:3,1)= userxyz;
    X(4,1)  = sAlgo.rcvclk;
    count   = 0;
    health  = 0;
    while count < 10
        % Obtain satellite coordinates
        [ satxyz, satclk, ~, satxyzdiff, satclkdiff,health] = precisepos(sAlgo.iEpoch,userxyz, eph, WD, TOW, flags, sAlgo.antex, sAlgo.sun, sAlgo.rcvclk./c); 
        [cosvec, enuvec, satenu, nvec] = directorcos(userxyz,satxyz,'enu');
        
        % Obtain corrections
        sataz   = azimuth(satenu,'rad');
        satelv  = elevation(enuvec,'rad');
        lla     = eceftolla(userxyz);
        if flags.useiono
            ion = ionodelay(iono,lla(1),lla(2),satelv,sataz,TOW,fmode)*c;
        else
            ion = 0;
%             ion = sAlgo.ranges.PRL1 - sAlgo.ranges.PRL2;
        end
        if flags.usetropo
            zpd = zenithdelay(lla(1),lla(3),satelv,DOY); 
        else
            zpd = 0;
        end
        
        % LS
        R       = diag(ura.^2./(sin(satelv).^2));
        H       = [-cosvec ones(nSat,1)];
        Z       = ranges - nvec + satclk - rcvclk - zpd - ion;% -218.763454401*sAlgo.count;
        dX      = (H'/R*H)\(H'/R*Z);
        X       = X + dX;
        
        userxyz = X(1:3)';
        rcvclk  = X(4);    
        
        % Verifies break 
        if all(abs(dX) < TOL)
            health  = 1;
            break
        end
        count = count + 1;
    end
    
    
    sAlgo.residuals      = zeros(nSat,2);
    % Final atributions
    sAlgo.estimate{1}         = X(1:4);
    sAlgo.userxyz             = userxyz;
    sAlgo.rcvclk              = rcvclk;
    sAlgo.residuals(:,1)      = Z-H*dX;
    sAlgo.satxyz(sats,:)      = satxyzdiff;
    sAlgo.satclk(sats)        = satclkdiff;
    sAlgo.satelv(sats)        = satelv;
    sAlgo.sataz               = sataz;
    sAlgo.cosH                = H; 
    sAlgo.nvec                = nvec;
    sAlgo.zpd                 = zpd;
    nParams = 4;
    P = inv(H'/R*H+eye(size(H,2)));
    V = Z-H*dX;
    C = V'/R*V./(nSat*2-nParams);
    C = C./P;
    sAlgo.covariance{1} = C(1:nParams,1:nParams);
    
end

