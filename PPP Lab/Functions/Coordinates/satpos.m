function [ satxyz, eccanomaly, vxyz, iTime] = satpos( eph, userxyz, TOW )
%SATPOS Obtains the position of the satellites at the time of transmission
%   This function obtains the satellite position using the data provided by
%   the ephemerides. The time tag given in TOW is corrected to the time of
%   transmission by subtracting the time taken for the signal to propagate
%   through space (PSEUDORANGE/C). With this there's no need to use
%   iterations to calculate the time of transmission.
%
%   INPUT
%   EPH    - Ephemerides data
%   PRANGE - Measurement data (not corrected). Any frequency can be used.
%   TOW    - Time of week (obtained at receiver). Must be a row vector
%
%   OUTPUT
%   XYZ - Satellite coordinates
%   ECCANOMALY - Eccentric anomaly (needed at ...)
%   
% Pedro Silva, Instituto Superior Tecnico, November 2011
    
    %Check input
    [i,j] = size(userxyz);
    if i~=1 && j~=3
        error('satpos: USERXYZ must be a 1-by-3 vector');
    end
    
    if ~isscalar(TOW)
        error('satpos: TOW should be a scalar');
    end

    % CONSTANTS
    C      = gpsparams('C');      % Speed of light
    
    % USER DEFINED
    TOL    = userparams('tolerance');  
    
    % INITIALIZATION
    nSat     = size(eph.satid,2);
    lastpos  = Inf;
    userxyz  = repmat(userxyz,nSat,1);
    iTime    = TOW;
    delta    = ones(1,nSat);
    
    % CORRECTING ORBIT FOR TX TIME
    count = 0;
    while count < 100
        count = count + 1;
        % Obtain position
        [satxyz,eccanomaly,vxyz] = satcoord(eph,iTime,delta);  % Position correct for Earth Rotation     
        if all(sqrt(sum((satxyz-lastpos).^2,2)) < TOL), break, end;
        lastpos = satxyz;                 % Saves position
        satdist = sqrt(sum((satxyz-userxyz).^2,2));  % Obtains sat distance
        delta   = satdist'/C;             % Obtains time difference
        iTime   = TOW - delta;            % Updates time
    end    
    iTime   = iTime';
    
end

