function [ az ] = azimuth( enu, varargin )
% AZIMUTH calculates the azimute for the given array of enu coordinates. 
% DEGREE is the DEFAULT unit for the output angle.
%
% INPUT
% ENU - Coordinates in East, North, Up notation (M by 3 Matrix)
% VARARGIN: OUTPUTUNIT - Modifier for output unit, either rad or deg.
%           DEFAULT VALUE = DEG     
%
% OUTPUT
% AZ  - Azimuth values in OUTPUT units (M by 3 Matrix)
%
% Pedro Silva, Instituto Superior Tecnico, November 2011

    %Check inputs
    error(nargchk(1, 2, nargin)) % future usage: error(narginchk(1, 2));
    if nargin == 2
        outputUnit = varargin{1};
    else
        outputUnit = 'deg';
    end
    
    if ~isnumeric(enu)
        error('azimuth: ENU must be numeric');
    end
    
    if size(enu,2) ~= 3
        error('azimuth: ENU must be an M by 3 matrix');
    end
    
    if ~ischar(outputUnit)
        error('azimuth: UNIT must be numeric');
    end
    
    az = atan2(enu(:,1),enu(:,2));    
    
    if strcmpi(outputUnit,'deg')
        az = deg(az);
    end

end

