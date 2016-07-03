function [ satxyz, satclk, iTime, satxyzdiff, satclkdiff,health] = precisepos(iEpoch,userxyz, eph, WD, TOW, flags, antex, sundata,offset)
%PRECISEPOS returns the satellite coordinates obtained from the IGS file
%   The objective of this function is to interpolate the IGS data file and
%   return more accurate satellite positions. Besides that, the clock
%   information is also returned along side.
%   The function does the best it can as it will pull from the IGS servers
%   the best data available, meaning the most accurate.
%
%   INPUT
%   USERXYZ - Best known user position
%   EPH, WEEKDAY, TIMEOFWEEK - Information from the
%   measurements obtained from the receiver
%
%   OUTPUT   
%   SATXYZ - Satellite coordinates
%   TSV    - Satellite time information
%
%   Pedro Silva, Instituto Superior Técnico, Novembro 2011

    persistent timecounter;
    persistent igsdata;
    persistent clkdata;

    persistent todelete;
    
    if isempty(todelete)
        todelete = 1;
    end
    
    % CHECK INPUT
    [i,j] = size(userxyz);
    if i~=1 && j~=3
        error('precisepos: USERXYZ must be a 1-by-3 vector');
    end
    
    if ~isscalar(TOW)
        error('precisepos: TOW should be a scalar');
    end
    
    % INITIALIZATION
    satxyzdiff = NaN;
    satclkdiff = NaN;
    iTime      = NaN;
    nSat       = numel(eph.satid);
    C          = gpsparams('C');      % Speed of light
    health     = 1;
    try
        % Decides how to compute the ephemerides
        if flags.usepreciseorbits || flags.usepreciseclk
            % IGS only initializations
            lastpos  = Inf;
            userxyz  = repmat(userxyz,nSat,1);
            iTime    = repmat(TOW,nSat,1);
            resample = 0;
            
            % Resamples data to avoid large interpolation error
            if isempty(timecounter) || abs(timecounter-iEpoch) > 1800
                resample    = 1;
                timecounter = iEpoch;
%             else
%                 abs(timecounter-iEpoch)
            end

            if isempty(igsdata)                
                % Read IGS FILE
                if ~strcmpi(flags.orbitproduct,'GMV')
                    [ success, filepath, type ] = pullfile( unique(eph.weeknb), WD, TOW, flags.orbitproduct ); 
                    
                    % Continue with broadcast if download failed
                    if ~ success
                        throw(ppplabexceptions('404'));
                    end
                    igsdata = readigs(filepath(1,:), WD);   % Reads file
                    if ~strcmpi(type,'igu')
                        if isempty(clkdata)
                            clkdata = readclk(filepath(2,:), WD); % 300 sec epochs
                        end
                    end
                    
                    % Create polyfit here
                    
                % Read GMV file    
                else
                    datefile = [num2str(eph.weeknb(1)),num2str(WD)];
                    igsdata  = readigs(['IGSFiles/gmv/gmv',datefile,'.sp3'],WD);
                    clkdata  = readclk(['IGSFiles/gmv/gmv',datefile,'.clk'],WD);
                end
                
            end
            
            if flags.usepreciseorbits
                % Sample data (obtains indexes to use during interpolation)
                if resample 
                    if resample
                        samples = (flags.polydegreesat+1)/2;
                        igsdata.IDX = igsdata.TOW >= TOW - 900*floor(samples) & igsdata.TOW <= TOW + 900*ceil(samples);
                        if isempty(igsdata.IDX)
                            throw(ppplabexceptions('resample'));
                        end
                    end
                end
                
                % Interpolate position data
                satxyz          = interpolateigs(eph.satid, igsdata, nSat, iTime, flags.interpolation); % obtain position
                [satxyz, iTime] = correctsagnac(userxyz,satxyz,eph.omegadot,TOW,lastpos);
                lastpos         = satxyz;
                count = 0;
                while count < 50
                    satxyz  = interpolateigs(eph.satid, igsdata, nSat, iTime, flags.interpolation); % obtain position
                    if flags.antex
                        ns = sqrt(sum(satxyz.^2,2));
                        K  = zeros(nSat,3);
                        J  = zeros(nSat,3);
                        I  = zeros(nSat,3);
                        E  = zeros(nSat,3);
                        sunxyz = sundata.sun(sundata.TOW==TOW,:);
                        for l = 1:nSat
                            K(l,:) = -satxyz(l,:)./ns(l,:);
                            E(l,:) = (sunxyz - satxyz(l,:))./sqrt(sum((sunxyz-satxyz(l,:)).^2,2));
                            J(l,:) = cross(K(l,:),E(l,:));
                            I(l,:) = cross(J(l,:),K(l,:));
                            R = [I(l,:);J(l,:);K(l,:)];
							nvec = sqrt(sum(R.^2,2));
                            R(1,:) = R(1,:)./nvec(1);
                            R(2,:) = R(2,:)./nvec(2);
                            R(3,:) = R(3,:)./nvec(3);
                            satxyz(l,:) = satxyz(l,:) + (R*antex(eph.satid(l),:)')';
                        end        
                    end
                    [satxyz, iTime, conv]  = correctsagnac(userxyz,satxyz,eph.omegadot,TOW,lastpos);
                    if conv, break; end;
                    lastpos         = satxyz;
                    count = count +1;
                end  
                
                if count == 100,
                    warning('coordinates:precisepos','number of max iterations exceded (should not happen)');
                    health = 0;
                end;

                satxyzdiff = satxyz - satpos(eph,userxyz(1,:),TOW); 
            else
                satxyz     = satpos(eph,userxyz,TOW); 
                satxyzdiff = satxyz;
            end
            
            % Interpolates clock information
            if flags.usepreciseclk
                satclk = interpolateclk(eph, igsdata, clkdata, nSat, flags.polydegreeclk, TOW);
                if strcmpi(flags.freqmode,'L1')
                    satclk  = satclk  - eph.tgd';
                elseif strcmpi(flags.freqmode, 'L2')
                    satclk  = satclk  - (77/60)^2.*eph.tgd';
                end
                satclkdiff = (satclk - clockcorrection(eph, TOW, flags.freqmode))*C;
            else
                satclk     = clockcorrection(eph, TOW, flags.freqmode);
                satclkdiff = satclk*C;
            end
                
            % Decides which dtr to use, broadcast or computed
            if ~flags.computedtr
                if ~exist('stdecc','var')
                    [~, eccanomaly] = satpos(eph, userxyz(1,:), TOW); 
                    dtr             = relativistic(eph, eccanomaly);
                end
            
            else
                satp = interpolateigs(eph.satid, igsdata, nSat, iTime+1, flags.interpolation);
                satm = interpolateigs(eph.satid, igsdata, nSat, iTime-1, flags.interpolation);
                satv = (satp - satm)./(2);
                dtr  = zeros(nSat,1);
                for k=1:nSat
                    dtr(k,1) = -2.*satxyz(k,:)*satv(k,:)'./(C^2);
                end
            end
            
            % Ads dtr to satclk
            satclk = satclk + dtr + signalcorrection(userxyz,satxyz);
            
        % Computes position with broadcast information        
        else
            [satxyz,stdecc] = satpos(eph,userxyz, TOW - offset); 
            satclk          = dtsv(eph, stdecc, TOW - offset, flags.freqmode); % Clock correct with dtr         
            %satclk          = satclk + signalcorrection(userxyz,satxyz); % Correct bending
            satxyzdiff      = satxyz;
            satclkdiff      = satclk;
        end
        
    catch exception404
        
        if ~isequal(exception404,ppplabexceptions('404'))
            outputexception(exception404);    
        end
        
        % Computes position with broadcast information
        [satxyz,stdecc] = satpos(eph,userxyz(1,:),TOW); 
        satclk          = dtsv(eph, stdecc, TOW, flags.freqmode) + signalcorrection(userxyz,satxyz); % Clock correct with dtr 
        satxyzdiff      = satxyz;
        satclkdiff      = satclk;
    end
    satclk = satclk*C;
end

function satclk = interpolateclk( eph, igsdata, clkdata, nSat, degree, TOW )
%INTERPOLATECLK interpolates sat clocks from a clock rinex or the standard
%sp3 file where the precise ephemerides are also present
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    samples = (degree+1)/2;
    satclk  = zeros(nSat,1);
    n       = 1;
    
    % Use clock information from the sp3 file
    if isempty(clkdata)
        idx = igsdata.TOW >= TOW - 900*floor(samples) & igsdata.TOW <= TOW + 900*ceil(samples);
        x = igsdata.TOW(idx,:);
        for s = eph.satid
            yc        = igsdata.sat(s).epoch(idx,4);
            satclk(n) = nev( x, yc, TOW ); % Interpolates z
            n = n + 1;
        end
        
    % Use clock information from rinex file
    else
        rate = clkdata.TOW(2) - clkdata.TOW(1);
        idx = clkdata.TOW >= TOW - rate*floor(samples) ...
              & clkdata.TOW <= TOW + rate*ceil(samples);        
        x   = clkdata.TOW(idx,:);
        for s = eph.satid
            yc        = clkdata.clkb(idx,s);
            satclk(n) = nev( x, yc, TOW ); % Interpolates z
            n = n + 1;
        end
    end

end


function [ satxyz ] = interpolateigs( satlist, igsdata, nSat, TOW, method )
%INTERPOLATEIGS uses the igs file to obtain satellite coordinates
%   The FILEPATH given is used to access an IGS SP3c file in order to
%   obatin precise information regarding the satellite orbits and clock.
%   This function uses the neville method to further interpolate the data
%   read from the IGS file and thus it only needs information from 12
%   epochs, as 11 degree polynomial provides the best results.
%
%   INPUT
%   SATLIST - List with the satellites' ID numbers
%   IGSDATA - Epoch data read from the file for further use. This also
%   contributes to a much faster solution as the file is not read more
%   times than necessary.
%   TOW - Time of week
%
%   OUTPUT
%   SATXYZ  - Satellite coordinates
%   TSV - Clock information
%
%   REFERENCE
%   Schenewerk, "A brief review of basic GPS orbit interpolation strategies,
%   " GPS Solutions (2003) 6:265-267 DOI:10.1007/s10291-002-0036-0 
%
%   Pedro Silva, Instituto Superior Técnico, Novembro 2011
%   Last Revision: may 2012


    persistent pdata;
    satxyz = zeros(numel(satlist),3);    
    
    if strcmpi(method,'neville')
        x  = igsdata.TOW(igsdata.IDX,:); 
        for idx = 1:nSat         
            yx = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,1);
            yy = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,2);
            yz = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,3);
            xnew          = TOW(idx);
            satxyz(idx,1) = nev(x,yx,xnew); % Interpolates x -10319943.4587294
            satxyz(idx,2) = nev(x,yy,xnew); % Interpolates y
            satxyz(idx,3) = nev(x,yz,xnew); % Interpolates z
        end  

    elseif strcmpi(method,'lagrange')
        x  = igsdata.TOW(igsdata.IDX,:);
        for idx = 1:nSat         
            yx = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,1);
            yy = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,2);
            yz = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,3);
            xnew          = TOW(idx); 
            satxyz(idx,1) = lagrange( x,yx,xnew); % Interpolates x
            satxyz(idx,2) = lagrange( x,yy,xnew); % Interpolates y
            satxyz(idx,3) = lagrange( x,yz,xnew); % Interpolates z
        end

    elseif strcmpi(method,'newton')
        x  = igsdata.TOW(igsdata.IDX,:);
        x  = x-x(1)+(x(1)-x(end))/2;
        for idx = 1:nSat         
            yx   = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,1)*1e-03;
            yy   = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,2)*1e-03;
            yz   = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,3)*1e-03;
            xnew = TOW(idx) - x(1)+(x(1)-x(end))/2; 
            
            satxyz(idx,1) = newint( x,yx,xnew)*1e03; % Interpolates x
            satxyz(idx,2) = newint( x,yy,xnew)*1e03; % Interpolates y
            satxyz(idx,3) = newint( x,yz,xnew)*1e03; % Interpolates z
        end        
        
    elseif strcmpi(method,'poly')
        x  = igsdata.TOW(igsdata.IDX,:);
        for idx = 1:nSat         
            yx = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,1)/1000;
            yy = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,2)/1000;
            yz = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,3)/1000;
            xnew          = TOW(idx) - x(1)+(x(1)-x(end))/2; 
            x             = x-x(1)+(x(1)-x(end))/2;
%             x = x-3600; %half of fit interval
            [cx,~,mx]  = polyfit(x,yx,length(x)-1);
            [cy,~,my]  = polyfit(x,yy,length(x)-1);
            [cz,~,mz]  = polyfit(x,yz,length(x)-1);
            
            satxyz(idx,1) = polyval(cx,xnew,[],mx)*1000; % Interpolates x
            satxyz(idx,2) = polyval(cy,xnew,[],my)*1000; % Interpolates y
            satxyz(idx,3) = polyval(cz,xnew,[],mz)*1000; % Interpolates z
        end
        
        
        
    elseif strcmpi(method, 'interp')
        x  = igsdata.TOW(igsdata.IDX,:);
            for idx = 1:nSat         
                yx = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,1)*1e-03;
                yy = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,2)*1e-03;
                yz = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,3)*1e-03;
%                 xnew          = TOW(idx); 
                xnew          = TOW(idx) - x(1)+(x(1)-x(end))/2; 
                x             = x-x(1)+(x(1)-x(end))/2;
                satxyz(idx,1) = interp1( x,yx,xnew,'pchip','extrap')*1e03; % Interpolates x
                satxyz(idx,2) = interp1( x,yy,xnew,'pchip','extrap')*1e03; % Interpolates y
                satxyz(idx,3) = interp1( x,yz,xnew,'pchip','extrap')*1e03; % Interpolates z
            end
        
    else
        
        % Weighted least squares
        if strcmpi(method,'wls')
            % Creates polynomial
            if isempty(pdata)
                st(1:32) = struct('ppx',NaN,'ppy',NaN,'ppz',NaN,'ppc',NaN);
                pdata    = st; 
                x  = igsdata.TOW(igsdata.IDX,:); 
                for idx = 1:32
                    yx             = igsdata.sat(idx).epoch(igsdata.IDX,1);
                    sdx            = igsdata.sat(idx).epoch(igsdata.IDX,5).^2; 
                    [p,S,mu]       = wpolyfit(x,yx,11,sdx.^2);
                    pdata(idx).ppx = struct('p',p,'S',S,'mu',mu);        

                    yy             = igsdata.sat(idx).epoch(igsdata.IDX,2);
                    sdy            = igsdata.sat(idx).epoch(igsdata.IDX,6).^2;
                    [p,S,mu]       = wpolyfit(x,yy,11,sdy.^2);
                    pdata(idx).ppy = struct('p',p,'S',S,'mu',mu);                

                    yz             = igsdata.sat(idx).epoch(igsdata.IDX,3);
                    sdz            = igsdata.sat(idx).epoch(igsdata.IDX,7).^2;
                    [p,S,mu]       = wpolyfit(x,yz,11,sdz.^2);
                    pdata(idx).ppz = struct('p',p,'S',S,'mu',mu);  
                end
            end 
        
        % PCHIP
        elseif strcmpi(method,'pchip')
            % Creates polynomial
            if isempty(pdata)
                st(1:32) = struct('ppx',NaN,'ppy',NaN,'ppz',NaN,'ppc',NaN);
                pdata    = st; 
                x  = igsdata.TOW(igsdata.IDX,:); 
                for idx = 1:32
                    yx             = igsdata.sat(idx).epoch(igsdata.IDX,1);
                    [p,S,mu]       = pchip(x,yx);
                    pdata(idx).ppx = struct('p',p,'S',S,'mu',mu);        

                    yy             = igsdata.sat(idx).epoch(igsdata.IDX,2);
                    [p,S,mu]       = pchip(x,yy);
                    pdata(idx).ppy = struct('p',p,'S',S,'mu',mu);                

                    yz             = igsdata.sat(idx).epoch(igsdata.IDX,3);
                    [p,S,mu]       = pchip(x,yz);
                    pdata(idx).ppz = struct('p',p,'S',S,'mu',mu);  
                end
            end 
            
            
            for idx = 1:nSat         
                xnew = TOW(idx); % xnew = TOW(idx)/900-xaux(1)+1;
                p  = pdata(satlist(idx)).ppx.p;
                S  = pdata(satlist(idx)).ppx.S;
                mu = pdata(satlist(idx)).ppx.mu;
                satxyz(idx,1) = polyval(p,xnew,S,mu); % Interpolates x

                p  = pdata(satlist(idx)).ppy.p;
                S  = pdata(satlist(idx)).ppy.S;
                mu = pdata(satlist(idx)).ppy.mu;
                satxyz(idx,2) = polyval(p,xnew,S,mu); % Interpolates y

                p  = pdata(satlist(idx)).ppz.p;
                S  = pdata(satlist(idx)).ppz.S;
                mu = pdata(satlist(idx)).ppz.mu;
                satxyz(idx,3) = polyval(p,xnew,S,mu); % Interpolates z                
            end  
            
            
        elseif strcmpi(method,'spline')
            % Creates polynomial
            if isempty(pdata)
                st(1:32) = struct('ppx',NaN,'ppy',NaN,'ppz',NaN,'ppc',NaN);
                pdata    = st; 
                x  = igsdata.TOW(igsdata.IDX,:); 
                for idx = 1:32
                    yx             = igsdata.sat(idx).epoch(igsdata.IDX,1);
                    [p,S,mu]       = spline(x,yx);
                    pdata(idx).ppx = struct('p',p,'S',S,'mu',mu);        

                    yy             = igsdata.sat(idx).epoch(igsdata.IDX,2);
                    [p,S,mu]       = spline(x,yy);
                    pdata(idx).ppy = struct('p',p,'S',S,'mu',mu);                

                    yz             = igsdata.sat(idx).epoch(igsdata.IDX,3);
                    [p,S,mu]       = spline(x,yz);
                    pdata(idx).ppz = struct('p',p,'S',S,'mu',mu);  
                end
            end 
            
            
            for idx = 1:nSat         
                xnew = TOW(idx); % xnew = TOW(idx)/900-xaux(1)+1;
                p  = pdata(satlist(idx)).ppx.p;
                S  = pdata(satlist(idx)).ppx.S;
                mu = pdata(satlist(idx)).ppx.mu;
                satxyz(idx,1) = polyval(p,xnew,S,mu); % Interpolates x

                p  = pdata(satlist(idx)).ppy.p;
                S  = pdata(satlist(idx)).ppy.S;
                mu = pdata(satlist(idx)).ppy.mu;
                satxyz(idx,2) = polyval(p,xnew,S,mu); % Interpolates y

                p  = pdata(satlist(idx)).ppz.p;
                S  = pdata(satlist(idx)).ppz.S;
                mu = pdata(satlist(idx)).ppz.mu;
                satxyz(idx,3) = polyval(p,xnew,S,mu); % Interpolates z                
            end

        elseif strcmpi(method,'splinefit')
            % Creates polynomial
            if isempty(pdata)
                st(1:32) = struct('ppx',NaN,'ppy',NaN,'ppz',NaN,'ppc',NaN);
                pdata    = st; 
                x  = igsdata.TOW(igsdata.IDX,:); 
                for idx = 1:32
                    yx             = igsdata.sat(idx).epoch(igsdata.IDX,1);
                    [p,S,mu]       = splinefit(x,yx);
                    pdata(idx).ppx = struct('p',p,'S',S,'mu',mu);        

                    yy             = igsdata.sat(idx).epoch(igsdata.IDX,2);
                    [p,S,mu]       = splinefit(x,yy);
                    pdata(idx).ppy = struct('p',p,'S',S,'mu',mu);                

                    yz             = igsdata.sat(idx).epoch(igsdata.IDX,3);
                    [p,S,mu]       = splinefit(x,yz);
                    pdata(idx).ppz = struct('p',p,'S',S,'mu',mu);  
                end
            end 
            
            
            for idx = 1:nSat         
                xnew = TOW(idx); % xnew = TOW(idx)/900-xaux(1)+1;
                p  = pdata(satlist(idx)).ppx.p;
                S  = pdata(satlist(idx)).ppx.S;
                mu = pdata(satlist(idx)).ppx.mu;
                satxyz(idx,1) = polyval(p,xnew,S,mu); % Interpolates x

                p  = pdata(satlist(idx)).ppy.p;
                S  = pdata(satlist(idx)).ppy.S;
                mu = pdata(satlist(idx)).ppy.mu;
                satxyz(idx,2) = polyval(p,xnew,S,mu); % Interpolates y

                p  = pdata(satlist(idx)).ppz.p;
                S  = pdata(satlist(idx)).ppz.S;
                mu = pdata(satlist(idx)).ppz.mu;
                satxyz(idx,3) = polyval(p,xnew,S,mu); % Interpolates z                
            end

        else
            error('interpolation algo not known');
        end
        
    end
    
    
   
end



function y=lagrange(pointx,pointy,x)
%
%LAGRANGE   approx a point-defined function using the Lagrange polynomial interpolation
%
%      LAGRANGE(X,POINTX,POINTY) approx the function definited by the points:
%      P1=(POINTX(1),POINTY(1)), P2=(POINTX(2),POINTY(2)), ..., PN(POINTX(N),POINTY(N))
%      and calculate it in each elements of X
%
%      If POINTX and POINTY have different number of elements the function will return the NaN value
%
%      function wrote by: Calzino
%      7-oct-2001
%

% tab =[...
%         1.73564379072e+028;
%         -2.1695547384e+027;
%           6.198727824e+026;
%          -3.099363912e+026;
%          2.4794911296e+026;
%          -3.099363912e+026;
%           6.198727824e+026;
%         -2.1695547384e+027;
%         1.73564379072e+028;
%         ];
% tic
    n=numel(pointx);
    L=ones(n,size(x,2));
    for i=1:n
      for j=1:n
         if (i~=j)
            L(i,:)=L(i,:).*(x-pointx(j))/(pointx(i)-pointx(j));
         end
      end
    end
% toc
%     tic
%     L(1,1) = prod(x-pointx(2:end))/tab(1);
%     L(2,1) = prod(x-pointx([1,3:end]))/tab(2);
%     L(3,1) = prod(x-pointx([1:2,4:end]))/tab(3);
%     L(4,1) = prod(x-pointx([1:3,5:end]))/tab(4);
%     L(5,1) = prod(x-pointx([1:4,6:end]))/tab(5);
%     L(6,1) = prod(x-pointx([1:5,7:end]))/tab(6);
%     L(7,1) = prod(x-pointx([1:6,8:end]))/tab(7);
%     L(8,1) = prod(x-pointx([1:7,9]))/tab(8);
%     L(9,1) = prod(x-pointx(1:8))/tab(9);
%     toc
    y = sum(pointy.*L);
end



function p = intp(xj,y,xi)
%INTP        (n-1)th order polynomial Lagrange interpolation.
%            n = length(y). xj is an n by 1 vector of distinct 
%            data points, and y is an n by 1 vector of data 
%            given at xj.
%
%            See
%            Horn & Johnson: Matrix Analysis,
%            Cambridge University Press 1985, Vol. 1, 29--30

% Written by Kai Borre
% December 30, 2000

%y = [13; 17; 85];  % numerical example from B. Hofmann-Wellenhof
                    % et al., p. 71--72
%xj = [-3;1;5];     
%xi = 4;            
%y = [1;3;2];       % numerical example from Stoer, p. 33
%xj = [0;1;3];
%xi = 2;

    for i = 1:length(y)
        pronum = [xi-xj];
        pronum(i) = [];
        num = prod(pronum);
        prodenom = [];
        for j = 1:length(y)
            prodenom = [prodenom; xj(i)-xj(j)];
            if i == j, prodenom(i) = []; end
        end
        denom = prod(prodenom);
        L(i) = num/denom;
    end
    p = L*y;
end

function y = nev(x,Q,xx)
% Neville's algorithm as a function (save as "nev.m")
% 
% inputs:
%    n = order of interpolation (n+1 = # of points)
%    x(1),...,x(n+1)    x coords
%    Q(1),...,Q(n+1)    y coords
%    xx=evaluation point for interpolating polynomial p
%
% output:  p(xx)
    n = max(size(x))-1;
    for i = n:-1:1
       for j = 1:i
          Q(j) = (xx-x(j))*Q(j+1) - (xx-x(j+n+1-i))*Q(j);
          Q(j) = Q(j)/(x(j+n+1-i)-x(j));
       end
    end

    y = Q(1);
end

function fp = newint(x,y,p)
% Script for Newton's Interpolation.
% Muhammad Rafiullah Arain
% Mathematics & Basic Sciences Department
% NED University of Engineering & Technology - Karachi
% Pakistan.
% ---------
% x and y are two Row Matrices and p is point of interpolation
%
% Example
% >> x=[1,2,4,7,8]
% >> y=[-9,-41,-189,9,523]
% >> newton_interpolation(x, y, 5)
% OR
% >> a = newton_interpolation(x, y, 5)

n = length(x);
a(1) = y(1);
for k = 1 : n - 1
   d(k, 1) = (y(k+1) - y(k))/(x(k+1) - x(k));
end
for j = 2 : n - 1
   for k = 1 : n - j
      d(k, j) = (d(k+1, j - 1) - d(k, j - 1))/(x(k+j) - x(k));
   end
end
d;
for j = 2 : n
   a(j) = d(1, j-1);
end
Df(1) = 1;
c(1) = a(1);
for j = 2 : n
   Df(j)=(p - x(j-1)) .* Df(j-1);
   c(j) = a(j) .* Df(j);
end
fp=sum(c);
end