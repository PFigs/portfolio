function [corr] = igssatcorr( eph, WD, TOW )
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

    % CHECK INPUT
%     [i,j] = size(userxyz);
%     if i~=1 && j~=3
%         error('precisepos: USERXYZ must be a 1-by-3 vector');
%     end
%     
%     if ~isscalar(TOW)
%         error('precisepos: TOW should be a scalar');
%     end
%     
    persistent igsdata;
%     persistent clkdata;
    
    % INITIALIZATION
    nSat     = numel(eph.satid);
    
    % OBTAIN IGS FILE
    [ success, filepath, type ] = pullfile( unique(eph.weeknb), WD, TOW ); 
    if ~ success
        error('File not retrieve. Please check your Internet connection');
    end
    
    % INITIAL ESTIMATE - REUSABLE INTERPOLATION DATA
    if isempty(igsdata) 
        igsdata = readigs(filepath(1,:), WD);   % 900 sec epochs
    end

    
    
    % Valid idx for this current epochs
    a           = TOW - 900*6; 
    b           = TOW + 900*6;
    igsdata.IDX = igsdata.TOW >= a & igsdata.TOW <= b;
    if isempty(igsdata.IDX)
        error('No valid data for the specified range. Please check downloaded file')
    end
    
    % Interpolate position data
    igsxyz = interpolateigs(eph.satid, igsdata, eph.omegadot, nSat, TOW, 'nev'); % obtain position

    
    
%     % Obtains satxyz at the sp3 know epoch
%     igsxyz = zeros(nSat,3);
%     idx = igsdata.TOW == TOW;
%     l   = 1;
%     for s = eph.satid
%         igsxyz(l,1)     = igsdata.sat(s).epoch(idx,1);
%         igsxyz(l,2)     = igsdata.sat(s).epoch(idx,2);
%         igsxyz(l,3)     = igsdata.sat(s).epoch(idx,3);
%         l = l+1;
%     end
    
    satxyz = satcoord(eph,TOW);  % Position correct for Earth Rotation
    
    corr = igsxyz-satxyz;
    
    
%     data.sat(id).epoch(iEpoch,1)  
%     % Interpolate clock information
%     tsv = zeros(nSat,1);
%     % Use clock information from the sp3 file
%     if strcmpi(type,'igu')
%         n = 1;
%         x = igsdata.TOW(igsdata.IDX,:);
%         for s = eph.satid
%             yc     = igsdata.sat(s).epoch(igsdata.IDX,4);
%             tsv(n) = nev( x, yc, TOW ); % Interpolates z
%             n = n +1;
%         end
%     % Use clock information from rinex file
%     else
%         if isempty(clkdata)
%             clkdata = readclk(filepath(2,:), WD); % 300 sec epochs 
%         end
%         a   = TOW - 300*6; 
%         b   = TOW + 300*6;
%         idx = clkdata.TOW >= a & clkdata.TOW <= b;
%         n = 1;
%         x = clkdata.TOW(idx,:);
%         for s = eph.satid
%             yc     = clkdata.clkb(idx,s);
%             tsv(n) = nev( x, yc, TOW ); % Interpolates z
%             n = n +1;
%         end
%     end


end



function [ xyz, eccanomaly ] = satcoord(eph,TOW)
%SATCOORD Computes satellite coordinates for the given TOW with Ephemeride
%data
%   The position given by this function takes into account the Earth
%   rotation in the period of time given by DELTA.
%
%   INPUT
%   ... - See above
%   DELTA - Period of time to correct earth rotation
%  
%   OUTPUT
%   ... - See above
%
% Pedro Silva, Instituto Superior Tecnico, November 2011
    
    % CHECK INPUTS - SANITY CHECK
%     if ~isrow(delta)
%         error('satpos:satcoord: DELTA must be a row vector');
%     end
% 
%     if ~isrow(TOW)
%         error('satpos:satcoord: TOW must be a scalar');
%     end
    
    % CONSTANTS
    OMEGAE = earthparams('OMEGAE'); % Angular velocity for the Earth rotation
    G      = earthparams('G');      % Earth gravitaniotal constant
    
    % USER DEFINED   
    TOL    = userparams('tolerance');  
    nSat   = size(eph.satid,2);   % Number of satellites

    % COMPUTE SAT POSITION FOR TIME OF TRANSMISSION
    a           = eph.sqra.^2;            % 1 - Obtain the major semi-axis associated to the elipse orbit
    angvel      = sqrt(G./(a.^3)) + eph.deltan;  % 2 - Angular velocity
    dt          = TOW - eph.toe;               % 3 - Time difference
    if dt > 302400;
        dt = dt - 604800;
    elseif dt < - 302400;
        dt = dt + 604800;
    end
    meananomaly = eph.mo + angvel.*dt; % 4 - Mean anomaly
    eccanomaly = meananomaly;         % 5 - Eccentricity anomaly
      
    while any(abs(eccanomaly - (meananomaly+eph.ecc.*sin(eccanomaly))>TOL))
        eccanomaly = meananomaly + eph.ecc.*sin(eccanomaly);     
    end
    eccanomaly  = meananomaly + eph.ecc.*sin(eccanomaly);   
    realanomaly = atan2(sqrt(1-eph.ecc.^2).*sin(eccanomaly),...
                       cos(eccanomaly)-eph.ecc);              % 6  - Real anomaly                   
    lat         = realanomaly + eph.omega;                    % 7  - Latitude
    du          = eph.cuc.*cos(2*lat) + eph.cus.*sin(2*lat);  % 8  - Latitude corrected
    clat        = lat + du;
    ro          = a.*(1-eph.ecc.*cos(eccanomaly));            % 9  - Orbit radius
    dr          = eph.crc.*cos(2*lat) + eph.crs.*sin(2*lat);  % 10 - Orbit radius corrected
    cr          = ro + dr;
    di          = eph.cic.*cos(2*lat) + eph.cis.*sin(2*lat);  % 11 - Orbit inclination
    inc         = eph.i0 + di + eph.idot.*dt; 
    omega       = eph.omega0 - OMEGAE*TOW + eph.omegadot.*dt; % 12 - Ascendent node longitude corrected
       
    % Computes Earth-fixed coordinates
    xyz = zeros(nSat,3);
    xl = cr.*cos(clat);
    yl = cr.*sin(clat);
    xyz(:,1) = xl.*cos(omega)-yl.*cos(inc).*sin(omega);
    xyz(:,2) = xl.*sin(omega)+yl.*cos(inc).*cos(omega);
    xyz(:,3) = yl.*sin(inc);
    
end



function [ satxyz ] = interpolateigs( satlist, igsdata, omegadot, nSat, TOW, varargin )
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
    
    % Initializations
    OMEGAE = earthparams('OMEGAE'); % Angular velocity for the Earth rotation
    satxyz = zeros(numel(satlist),3);

    if nargin == 8
        type = varargin{1};
    else
        type = 'nev';
    end
    
    if strcmpi(type,'nev')
        x  = igsdata.TOW(igsdata.IDX,:); % xaux = igsdata(satlist(idx)).pos(:,1)'/900; % x = xaux-xaux(1)+1;
        xnew = TOW;
        for idx = 1:nSat         
            yx = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,1);
            yy = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,2);
            yz = igsdata.sat(satlist(idx)).epoch(igsdata.IDX,3);
            satxyz(idx,1)   = nev( x,yx,xnew); % Interpolates x
            satxyz(idx,2)   = nev( x,yy,xnew); % Interpolates y
            satxyz(idx,3)   = nev( x,yz,xnew); % Interpolates z
        end  
    end
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

