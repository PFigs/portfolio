function [lla] = eceftolla( xyz, varargin )
% ECEFTOLLA converts between ECEF to WGS84 coordinates. 
%   INPUT
%   XYZ - ECEF coordinates in meters ( M by 3 matrix )
%   VARARGIN: OUTPUTUNIT - Modifier for output, either rad or deg
%             DEFAULT VALUE = DEG
%   OUTPUT
%   LLA - LLA coordinates with units according to OUTPUTUNIT (M by 3 matrix)
%
% Reference
% Paul R. Wolf and Bon A. Dewitt, "Elements of Photogrammetry with
% Applications in GIS," 3rd Ed., McGraw-Hill, 2000 (Appendix F-3).
%
% Pedro Silva, Instituto Superior Tecnico, November 2011
% Based on work done by mathworks
    
    %Check inputs
    error(nargchk(1, 2, nargin)) % future usage: error(narginchk(1, 2));
    if nargin == 2
        outputUnit = varargin{1};
    else
        outputUnit = 'deg';
    end
    
    if ~isnumeric(xyz)
        error('xyztolla: XYZ must be numeric');
    end
    
    if size(xyz,2) ~= 3
        error('xyztolla: XYZ must be an M by 3 matrix');
    end
    
    if ~ischar(outputUnit)
        error('llatoxyz: UNIT must be numeric');
    end
    
    if ~strcmpi(outputUnit,'deg') && ~strcmpi(outputUnit,'rad')
        error('llatoxyz: UNIT must be either "deg" or "rad"');
    end
    
    %Constants
    a    = earthparams('a');    % Semimajor axis
    f    = earthparams('f');    % Flattening
    
    b    = a*(1-f);             % Semiminor axis
    e2   = 1 - (b^2)/(a^2);     % Square of first eccentricity
    el2  = (a^2)/(b^2)-1;       % Square of second eccentricity
    
    r   = hypot(xyz(:,1),xyz(:,2));    % Distance from Z-axis
    
    % Bowring's formula for initial parametric and geodetic latitudes
    tau = atan2(xyz(:,3), r.*(1 - f));
    lat = atan2(xyz(:,3) + b*el2*sin(tau).^3, r - a*e2*cos(tau).^3);
    
    % Iteration loop
    tauNew = atan2((1 - f)*sin(lat), cos(lat));
    count = 0;
    while any(tau(:) ~= tauNew(:)) && count < 5
        tau = tauNew;
        lat = atan2(xyz(:,3)   + b * el2 * sin(tau).^3,...
                    r - a * e2  * cos(tau).^3);
        tauNew = atan2((1 - f)*sin(lat), cos(lat));
        count = count + 1;
    end
    
    % Calculate ellipsoidal height from the final value for latitude
    sinlat = sin(lat);
    N = a ./ sqrt(1 - e2 * sinlat.^2);
    h = r .* cos(lat) + (xyz(:,3) + e2 * N .* sinlat) .* sinlat - N;
    
    % Longitude
    long = atan2(xyz(:,2),xyz(:,1));
    
    if strcmpi(outputUnit,'rad')
      lla = [lat,long,h];
    else
      lla = [deg(lat),deg(long),h]; 
    end
       
end

