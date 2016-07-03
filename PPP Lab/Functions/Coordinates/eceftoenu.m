function [ enu ] = eceftoenu( xyz, ref, varargin )
% ECEFTOENU transforms ECEF coordinates to enu coordinates with
% respect to a given reference point in ECEF (DEFAULT) or WGS84
%
%   NOTE: XYZ is ALWAYS ECEF! Switcher is for REF
%
%   [ enu ] = eceftoenu( xyz, ref, varargin )
%
%   INPUT
%   XYZ    - ECEF coordinate to convert (matrix M by 3)
%   REF    - Reference point used for the conversion (matrix M by 3)
%   VARARGIN:MODE   - Modifier to set REF as ECEF or LLA. 
%            DEFAULT VALUE = ECEF (For LLA mode should be rad or deg). 
%
%   OUTPUT
%   ENU    - ENU coordinates (matrix M by 3)
%
%   Pedro Silva, Instituto Superior Tecnico, November 2011

    %Check inputs
    error(nargchk(2, 3, nargin)) % future usage: error(narginchk(3, 3));
    if nargin == 3
        mode = varargin{1};
        if strcmpi(mode,'lla')
            error('eceftoenu: For lla input use DEG or RAD');
        end
    else
        mode = 'ECEF'; % FASTEST mode depends on previous operations to ref
    end
    if ~isnumeric(xyz)
        error('eceftoenu: XYZ must be numeric');
    end
    
    if ~isnumeric(ref)
        error('eceftoenu: REF must be numeric');
    end
    
    if ~ischar(mode)
        error('eceftoenu: MODE must be numeric');
    end
    
    [xyzi, xyzj] = size(xyz);
    [refi, refj] = size(ref);
    if xyzj ~= 3
        error('eceftoenu: XYZ must be an M by 3 matrix');
    end

    if refj ~= 3
        error('eceftoenu: REF must be an M by 3 matrix');
    end
    
    if refi == 1 && xyzi > 1
       ref = repmat(ref,xyzi,1); %if same ref for every point
    elseif refi ~= xyzi 
        error('eceftoenu: REF must be 1 by 3 or the same size as XYZ');
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
        error('eceftoenu: MODE must be ECEF, RAD or DEG');
    end
    
    %Obtain the difference and rotate to obtain enu
    renu = xyz - refxyz;
    gama = reflla(:,2) + pi/2;
    beta = pi/2-reflla(:,1);
    
    % ROTZ*ROTX
    enu(:,1) =  renu(:,1).*cos(gama)            + renu(:,2).*sin(gama);
    enu(:,2) = -renu(:,1).*sin(gama).*cos(beta) + renu(:,2).*cos(gama).*cos(beta) + renu(:,3).*sin(beta);
    enu(:,3) =  renu(:,1).*sin(gama).*sin(beta) - renu(:,2).*cos(gama).*sin(beta) + renu(:,3).*cos(beta);
    
end