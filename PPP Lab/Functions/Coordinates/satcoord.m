function [ rxyz, eccanomaly, vxyz, lxy ] = satcoord(eph,TOW,delta)
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
    a           = eph.sqra.^2;                   % 1 - Obtain the major semi-axis associated to the elipse orbit
    angvel      = sqrt(G./(a.^3)) + eph.deltan;  % 2 - Angular velocity
    dt          = checktime(TOW - eph.toe);                 % 3 - Time difference
    meananomaly = eph.mo + angvel.*dt; % 4 - Mean anomaly
    eccanomaly  = meananomaly;          % 5 - Eccentricity anomaly
      
    while any(abs(eccanomaly - (meananomaly+eph.ecc.*sin(eccanomaly)))>TOL)
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
    lxy = zeros(nSat,3);
    xl = cr.*cos(clat);
    yl = cr.*sin(clat);
    xyz(:,1) = xl.*cos(omega) - yl.*cos(inc).*sin(omega);
    xyz(:,2) = xl.*sin(omega) + yl.*cos(inc).*cos(omega);
    xyz(:,3) = yl.*sin(inc);
    lxy(:,1) = xl;
    lxy(:,2) = yl;
    lxy(:,3) = 0;
    
    % Rotates coordinates
    gama = (OMEGAE-eph.omegadot').*delta';
    rxyz(:,1) = xyz(:,1).*cos(gama) + xyz(:,2).*sin(gama);
    rxyz(:,2) = -xyz(:,1).*sin(gama) + xyz(:,2).*cos(gama);
    rxyz(:,3) = xyz(:,3);

    % Sat velocity
    % REFERENCE
    % GPS Solutions, Volume 8, Number 2, 2004 (in press).
    % "Computing Satellite Velocity using the Broadcast Ephemeris", by Benjamin W. Remondi  
    
    mkdot  = angvel;
    ekdot  = mkdot./(1-eph.ecc.*cos(eccanomaly));                   
    takdot = sin(eccanomaly).*ekdot.*(1+eph.ecc.*cos(realanomaly))./(sin(realanomaly).*(1-eph.ecc.*cos(eccanomaly)));
    
    ukdot = takdot + 2.*(eph.cus.*cos(2.*clat)-eph.cuc.*sin(2.*clat)).*takdot;
    rkdot = a.*eph.ecc.*sin(eccanomaly).*angvel./(1-eph.ecc.*cos(eccanomaly))+2.*(eph.crs.*cos(2.*clat)-eph.crc.*sin(2.*clat)).*takdot;
    ikdot = eph.idot + (eph.cis.*cos(2.*clat)-eph.cic.*sin(2.*clat)).*2.*takdot;
    
    xpkdot = rkdot.*cos(clat)-yl.*ukdot;
    ypkdot = rkdot.*sin(clat)+xl.*ukdot;
    
    omegakdot = eph.omegadot-OMEGAE;
    vxyz(:,1)  = (xpkdot - yl.*cos(inc).*omegakdot).*cos(omega) ...
               - (xl.*omegakdot + ypkdot.*cos(inc) - yl.*sin(inc).*ikdot).*sin(omega);
    vxyz(:,2)  = (xpkdot - yl.*cos(inc).*omegakdot).*sin(omega) ...
               + (xl.*omegakdot + ypkdot.*cos(inc) - yl.*sin(inc).*ikdot).*cos(omega);
    vxyz(:,3)  = ypkdot.*sin(inc) + yl.*cos(inc).*ikdot;
             
end