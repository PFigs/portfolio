function sAlgo = compareorbits( sAlgo, TOW, DOY, WD  )
%COMPAREORBITS compares the error component between broadcast and precise
%orbits
%
%
%  Pedro Silva, Instituto Superior Tecnico, February 2012

    % Constants
    c    = gpsparams('C');
    f1   = gpsparams('f1');
    
    % Initializations
    userxyz = sAlgo.userxyz;
    ranges  = sAlgo.ranges.PRL1;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    iono    = sAlgo.iono;
    TOL     = userparams('tol');
    ura     = sAlgo.eph.ura';
    
    while 1
        % Obtain satellite coordinates
        [satxyz, satclk] = precisepos(userxyz, eph, WD, TOW); 
        [cosvec, enuvec, satenu] = directorcos(userxyz,satxyz,'enu');
 
        [satbroad,stdecc] = satpos(eph,userxyz,TOW); 
        [~,dtr]    = dtsv(eph, stdecc, TOW, 1); % Tsv correction   %send nSat 
        
        satclk = satclk+dtr;
        
        % Obtain corrections
        sataz  = azimuth(enuvec,'rad');
        satelv = elevation(enuvec,'rad');
        lla    = eceftolla(userxyz);
        
        ion = ionodelay(iono,lla(1),lla(2),satelv,sataz,TOW);
        zpd = zenithdelay(lla(1),lla(3),satelv,DOY); 
        
        % Obtain estimate ura = uratometer(sAlgo.eph.ura); % do this while acquiring
        ura = sAlgo.eph.ura';
        P   = diag(ura.^2./(sin(satelv).^2));
        H   = [-cosvec ones(nSat,1)];
        Z   = ranges - diag(cosvec*satxyz') + satclk*c - zpd - ion*c;
        
        est = (H'/P*H)\(H'/P*Z);

        
        % Verifies break 
        if norm(est(1:3)'- userxyz) <  TOL
            break
        end
        userxyz = est(1:3)';
        
    end
    
    % Difference vectors
    b = satbroad-satxyz;
    a = repmat(userxyz,size(b,1),1);
    a = a-satbroad;
    for k = 1:nSat
        p     = (a(k,:)'*b(k,:))/(a(k,:)'*a(k,:))*a(k,:);
        np(k) = norm(p); 
        if a'*b < 0, np(k) = -np(k); end
    end    
   
    
    % final atributions
    sAlgo.userxyz  = est(1:3)';
    sAlgo.rcvclk   = est(4);
    sAlgo.distance = norm(sAlgo.refpoint-sAlgo.userxyz);
    sAlgo.satxyz   = satxyz;
    sAlgo.satenu   = satenu;
    sAlgo.satelv   = satelv;
    sAlgo.sataz    = azimuth(satenu,'rad');

end

