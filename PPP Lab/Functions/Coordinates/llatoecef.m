function [ xyz ] = llatoecef( lla, varargin )
%LLATOECEF converts WGS84 coordinates to ECEF coordinates
%   The coordinates have the standard units, degree for lla and meters for
%   xyz.
%
%   INPUT   
%   LLA  - latitude [deg], longitude [deg], altitude [m] (M by 3 matrix)
%   VARARGIN: INTPUTUNIT - Modifier for input unit, either rad or deg.
%             DEFAULT VALUE = DEG        
%
%   OUTPUT
%   xyz - ECEF coordinates in meters (M by 3 matrix)
%
% Reference
% Paul R. Wolf and Bon A. Dewitt, "Elements of Photogrammetry with
% Applications in GIS," 3rd Ed., McGraw-Hill, 2000 (Appendix F-3).
%
% Pedro Silva, Instituto Superior Técnico, November 2011
% Based on work done by mathworks

    %Check inputs
    error(nargchk(1, 2, nargin)) % future usage: error(narginchk(1, 2));
    if nargin == 2
        inputUnit = varargin{1};
    else
        inputUnit = 'deg';
    end
    
    if ~isnumeric(lla)
        error('llatoxyz: LLA must be numeric');
    end
    
    if ~ischar(inputUnit)
        error('llatoxyz: UNIT must be numeric');
    end
    
    if ~strcmpi(inputUnit,'deg') && ~strcmpi(inputUnit,'rad')
        error('llatoxyz: UNIT must be either "deg" or "rad"');
    end
    
    if size(lla,2) ~= 3
        error('llatoxyz: LLA must be an M by 3 matrix');
    end
    
    % Convert
    if strcmpi(inputUnit,'deg')
      lla = [rad(lla(:,1)),rad(lla(:,2)),lla(:,3)]; 
    end
    
    % Constants
    a    = earthparams('r');    % Semimajor axis
    f    = earthparams('f');    % Flatenning
    e2   = 1 - ( 1 - f )^2;     % Square of first eccentricity
    
    % To ease code reading
    sinphi = sin(lla(:,1));
    cosphi = cos(lla(:,1));
    lambda = lla(:,2);
    h = lla(:,3);
    N  = a ./ sqrt(1 - e2 * sinphi.^2);
    x = (N + h) .* cosphi .* cos(lambda);
    y = (N + h) .* cosphi .* sin(lambda);
    z = (N*(1 - e2) + h) .* sinphi;
    xyz = [x,y,z];
end





