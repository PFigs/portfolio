function [ dcos, varargout ] = directorcos( userxyz, satxyz, varargin )
%DIRECTORCOS Computes the cosine directors
%
%   INPUT
%   USERXYZ - Receiver coordinate
%   SATXYZ  - Satellite coordinates
%   VARARGIN - Enables ecos output   
%
%
%   OUTPUT
%   DCOS - Director cosine
%   ECOS - Director cosines in enu
%
%   Pedro Silva, Instituto Superior Tecnico, Novembro 2011
    
    % CHECK INPUT
    error(nargchk(2, 3, nargin)) % future usage: error(narginchk(3, 3));
    
    if nargin == 3 && strcmpi(varargin{1},'enu')
        enu = 1;
    else
        enu = 0;
    end
    
    % EXTENDS MATRIX
    nSat = size(satxyz,1);
    userxyz = repmat(userxyz,nSat,1);
    vec  = satxyz - userxyz;
    nvec = sqrt(sum(vec.^2,2));
    dcos = zeros(nSat,3);
    for i = 1:nSat
        dcos(i,:) = vec(i,:)/nvec(i);
    end
    
    if enu
        evec  = eceftoenu(satxyz,userxyz,'ecef'); %diff inside
        nevec = sqrt(sum(evec.^2,2));
        ecos  = zeros(nSat,3);
        for i = 1:nSat
            ecos(i,:) = evec(i,:)/nevec(i);
        end
        varargout{1} = ecos;
        varargout{2} = evec;
        varargout{3} = nvec;
    end
end

