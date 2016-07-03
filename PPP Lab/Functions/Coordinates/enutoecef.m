function [ xyz ] = enutoecef( enu, ref, varargin )
% ENUTOECEF converts enu coordinates into ECEF coordinates for a given 
% reference point in ECEF or WGS84.
%
%   INPUT
%   ENU    - ENU coordinates (matrix M by 3)
%   REF    - Reference point used for the conversion (matrix M by 3)
%   MODE   - Modifier to set REF as ECEF or LLA. For LLA mode should be rad
%   or deg
%
%   OUTPUT
%   XYZ    - ECEF coordinate to convert (matrix M by 3)
%
%   Pedro Silva, Instituto Superior Tecnico, November 2011
   
    %Check inputs
    error(nargchk(2, 3, nargin)) % future usage: error(narginchk(3, 3));
    if nargin == 3
        mode = varargin{1};
    else
        mode = 'ECEF'; % FASTEST mode depends on previous operations to ref
    end
    
    if ~isnumeric(enu)
        error('enutoecef: ENU must be numeric');
    end
    
    if ~isnumeric(ref)
        error('enutoecef: REF must be numeric');
    end
    
    if ~ischar(mode)
        error('enutoecef: MODE must be numeric');
    end
    
    if size(enu,2) ~= 3
        error('enutoecef: XYZ must be an M by 3 matrix');
    end

    if size(ref,2) ~= 3
        error('enutoecef: REF must be an M by 3 matrix');
    end
    
    %Obtains the WGS84 or ECEF coordinates
    if strcmpi(mode,'ECEF')
        reflla = eceftolla(ref,'rad');
        refxyz = ref;
    elseif strcmpi(mode,'RAD')
        refxyz = llatoecef(ref,mode);
        reflla = ref;
    elseif strcmpi(mode,'DEG')
        refxyz = llatoecef(ref,mode);
        reflla = [rad(ref(:,1)),rad(ref(:,2)),ref(:,3)];
    else
        error('enutoecef: MODE must be ECEF, RAD or DEG');
    end
    
    % Applies the inverse transformation from eceftoenu
    elemNo = numel(enu(:,1));
    xyz = zeros(elemNo,3);
    for i=1:elemNo
        xyz(i,:) = enu(i,:)*Rotx(reflla(1) - pi/2)*Rotz( -reflla(2) - pi/2); 
    end
    xyz = xyz+refxyz;

end

